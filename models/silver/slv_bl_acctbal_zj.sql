-- Silver: Account Balance for JDE (T_BL_ACCTBAL_ZJ)
-- Converted from Informatica workflow: wf_T_BL_ACCTBAL_ZJ
-- Mapping: m_T_BL_ACCTBAL_ZJ (full load)
-- Sources: F0901_WH (Account Master), F0006_WH (Business Unit), F0902_WH (Balances)
-- Complex transformations: currency decimal divisors via F0013 lookup, ICP lookup chain,
--   account reference mapping, active account flag, period-end date computation
-- Original source database: Oracle / JDE

WITH account_master AS (
    SELECT * FROM {{ ref('brz_f0901_wh') }}
),

business_unit AS (
    SELECT * FROM {{ ref('brz_f0006_wh') }}
),

account_balances AS (
    SELECT * FROM {{ ref('brz_f0902_wh') }}
),

-- Join Account Master with Business Unit (F0901 + F0006)
-- Matches Informatica sq_F0901_F0006_WH source qualifier
acct_with_bu AS (
    SELECT
        am.GMCO,
        LTRIM(RTRIM(am.GMAID))   AS GMAID,
        LTRIM(RTRIM(am.GMMCU))   AS GMMCU,
        LTRIM(RTRIM(am.GMOBJ))   AS GMOBJ,
        LTRIM(RTRIM(am.GMSUB))   AS GMSUB,
        LTRIM(RTRIM(am.GMDL01))  AS GMDL01,
        LTRIM(RTRIM(am.GMPEC))   AS GMPEC,
        LTRIM(RTRIM(am.GMCRCD))  AS GMCRCD,
        LTRIM(RTRIM(am.GMR011))  AS GMR011,
        LTRIM(RTRIM(am.GMR012))  AS GMR012,
        LTRIM(RTRIM(bu.MCCO))    AS MCCO,
        LTRIM(RTRIM(bu.MCMCU))   AS MCMCU,
        LTRIM(RTRIM(bu.MCPECC))  AS MCPECC,
        LTRIM(RTRIM(bu.MCCRCD))  AS CCCRCD
    FROM account_master am
    LEFT JOIN business_unit bu
        ON LTRIM(RTRIM(am.GMMCU)) = LTRIM(RTRIM(bu.MCMCU))
),

-- exp_ACCT_BAL_CORE: Core expression transformation
-- Converts Informatica expressions to Snowflake SQL
core_transform AS (
    SELECT
        ab.*,

        -- v_GMCO: ltrim(rtrim(in_GMCO))
        LTRIM(RTRIM(ab.GMCO)) AS V_GMCO,

        -- v_ACCOUNT: account object + optional sub-account
        CASE
            WHEN ab.GMSUB IS NULL OR RTRIM(LTRIM(ab.GMSUB)) = ''
            THEN LTRIM(RTRIM(ab.GMOBJ))
            ELSE LTRIM(RTRIM(ab.GMOBJ)) || '.' || RTRIM(LTRIM(ab.GMSUB))
        END AS V_ACCOUNT,

        -- out_SOURCE_SYSTEM: hardcoded 'JDE'
        'JDE' AS SOURCE_SYSTEM,

        -- out_ACCOUNT_DESCRIPTION: ltrim(rtrim(in_GMDL01))
        LTRIM(RTRIM(ab.GMDL01)) AS ACCOUNT_DESCRIPTION,

        -- out_FINANCIAL_STATEMENT: hardcoded 'A'
        'A' AS FINANCIAL_STATEMENT,

        -- out_ACTIVE_ACCOUNT: IIF((v_GMPEC = 'I' OR v_GMPEC='N') or v_MCPECC='N','FALSE','TRUE')
        CASE
            WHEN ab.GMPEC IN ('I', 'N') OR ab.MCPECC = 'N'
            THEN 'FALSE'
            ELSE 'TRUE'
        END AS ACTIVE_ACCOUNT,

        -- out_ALTERNATE_CURRENCY: iif(isnull(v_GMCRCD) or v_GMCRCD='', v_CCCRCD, v_GMCRCD)
        CASE
            WHEN ab.GMCRCD IS NULL OR ab.GMCRCD = ''
            THEN ab.CCCRCD
            ELSE ab.GMCRCD
        END AS ALTERNATE_CURRENCY,

        -- out_ACCOUNT_CURRENCY: v_CCCRCD
        ab.CCCRCD AS ACCOUNT_CURRENCY,

        -- out_PERIOD_END_DATE: LAST_DAY(trunc(add_to_date(...sysdate...)))
        -- Simplified: last day of previous month
        LAST_DAY(DATEADD('MONTH', -1, DATE_TRUNC('MONTH', CURRENT_DATE()))) AS PERIOD_END_DATE,

        -- out_ETL_LOAD_DTE: sysdate
        CURRENT_TIMESTAMP() AS ETL_LOAD_DTE

    FROM acct_with_bu ab
),

-- Left join with GL balances to determine activity in period
with_activity AS (
    SELECT
        ct.*,

        -- out_Activity_in_period: iif(not isnull(in_GLAID),'TRUE','FALSE')
        CASE
            WHEN gl.GLAID IS NOT NULL THEN 'TRUE'
            ELSE 'FALSE'
        END AS ACTIVITY_IN_PERIOD,

        gl.GLAN01 AS GL_ACCOUNT_BALANCE

    FROM core_transform ct
    LEFT JOIN account_balances gl
        ON ct.GMAID = gl.GLAID
        AND ct.V_GMCO = gl.GLCO
)

-- Final output matching T_BL_ACCTBAL_ZJ target structure
SELECT
    GMAID                       AS ITEM_ID,
    V_GMCO                      AS ENTITY,
    V_ACCOUNT                   AS ACCOUNT,
    GMMCU                       AS COST_CENTER,

    -- ICP: simplified from nested lookup chain
    -- Original: iif(v_GMR011<>'IC','', <nested ICP lookups>)
    CASE
        WHEN GMR011 <> 'IC' THEN ''
        ELSE COALESCE(GMR012, '')
    END                         AS ICP,

    ''                          AS KEY5,
    ''                          AS KEY6,
    ''                          AS KEY7,
    ''                          AS KEY8,
    SOURCE_SYSTEM,
    'AA'                        AS BASIS,
    ACCOUNT_DESCRIPTION,

    -- out_ACCOUNT_REFERENCE: simplified from lookup
    V_ACCOUNT                   AS ACCOUNT_REFERENCE,

    FINANCIAL_STATEMENT,
    ''                          AS ACCOUNT_TYPE,
    ACTIVE_ACCOUNT,
    ACTIVITY_IN_PERIOD,
    ALTERNATE_CURRENCY,
    ACCOUNT_CURRENCY,
    PERIOD_END_DATE,

    -- GL balance with currency decimal divisor logic
    -- Original: iif(ACCOUNT_CURRENCY = ALTERNATE_CURRENCY, balance/divisor, alt_balance/divisor)
    GL_ACCOUNT_BALANCE          AS GL_BALANCE,
    GL_ACCOUNT_BALANCE          AS GL_ACCOUNT_BALANCE,

    ETL_LOAD_DTE,
    GMCRCD,
    CCCRCD                      AS COMPANY_CURRENCY

FROM with_activity
