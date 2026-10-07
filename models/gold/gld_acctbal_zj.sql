-- Gold: Final Account Balance for JDE
-- Business-ready view of account balance data
-- Source: slv_bl_acctbal_zj (from Informatica wf_T_BL_ACCTBAL_ZJ)

SELECT
    ITEM_ID,
    ENTITY,
    ACCOUNT,
    COST_CENTER,
    ICP,
    KEY5,
    KEY6,
    KEY7,
    KEY8,
    SOURCE_SYSTEM,
    BASIS,
    ACCOUNT_DESCRIPTION,
    ACCOUNT_REFERENCE,
    FINANCIAL_STATEMENT,
    ACCOUNT_TYPE,
    ACTIVE_ACCOUNT,
    ACTIVITY_IN_PERIOD,
    ALTERNATE_CURRENCY,
    ACCOUNT_CURRENCY,
    PERIOD_END_DATE,
    GL_BALANCE,
    GL_ACCOUNT_BALANCE,
    ETL_LOAD_DTE
FROM {{ ref('slv_bl_acctbal_zj') }}
