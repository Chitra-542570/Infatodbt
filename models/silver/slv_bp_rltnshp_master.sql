-- Silver: Business Partner Relationship Master
-- Converted from Informatica workflow: wf_DI_BP_RLTNSHP_MASTER
-- Mapping: m_DI_BP_RLTNSHP_MASTER
-- Source: SAP BP_RLTNSHP source
-- Transformations: Boolean-to-String UDF, date+time concatenation,
--   MD5 hash (mplt_MD5 mapplet), ODQ change mode, ETL load timestamp

WITH src_data AS (
    SELECT * FROM {{ ref('brz_bp_rltnshp_src') }}
),

transformed AS (
    SELECT
        RLTNSHP_NBR,
        BUS_PTNR_NBR_1,
        BUS_PTNR_NBR_2,
        VLD_TO_DT,
        VLD_FRM_DT,
        BUS_PTNR_RLTNSHP_CAT_CD,

        -- exp_BooleanStringConv: UDF_BOOLEAN_STRING_CONV(BUS_PTNR_ROLE_IND)
        {{ udf_boolean_string_conv('BUS_PTNR_ROLE_IND') }} AS BUS_PTNR_ROLE_IND,

        BUS_PTNR_DIFF_TP,
        BUS_PTNR_ROLE,
        BUS_PTNR_RLTNSHP_TP,
        CREATED_BY,

        -- exp_DateTimeConcat: Combine date and time parts
        CASE
            WHEN CREATED_DT IS NOT NULL
            THEN TRY_TO_TIMESTAMP(
                LEFT(TO_VARCHAR(CREATED_DT), 10) || ' ' || SUBSTR(TO_VARCHAR(CRTIM), 12, 8)
            )
            ELSE NULL
        END AS CREATED_DT,

        LAST_CHG_USR,

        CASE
            WHEN LAST_CHG_DT IS NOT NULL
            THEN TRY_TO_TIMESTAMP(
                LEFT(TO_VARCHAR(LAST_CHG_DT), 10) || ' ' || SUBSTR(TO_VARCHAR(CHTIM), 12, 8)
            )
            ELSE NULL
        END AS LAST_CHG_DT,

        ODQ_CHANGEMODE,

        -- exp_ETL_LOAD_DT: SYSDATE equivalent
        CURRENT_TIMESTAMP() AS ETL_LOAD_DT,

        -- mplt_MD5: MD5 hash of key columns for change detection
        {{ md5_hash([
            'RLTNSHP_NBR', 'BUS_PTNR_NBR_1', 'BUS_PTNR_NBR_2',
            'BUS_PTNR_RLTNSHP_CAT_CD', 'BUS_PTNR_DIFF_TP',
            'BUS_PTNR_ROLE', 'BUS_PTNR_RLTNSHP_TP'
        ]) }} AS MD5_HASH

    FROM src_data
)

SELECT * FROM transformed
