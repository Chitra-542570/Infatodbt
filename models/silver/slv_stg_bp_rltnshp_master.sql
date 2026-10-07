-- Silver: Staging BP Relationship Master (Hard Deletes)
-- Converted from Informatica workflow: wf_DI_BP_RLTNSHP_MASTER
-- Mapping: m_DI_BP_STG_BP_RLTNSHP_MASTER
-- Description: Dumps hard-delete records into staging table per CCB 133

WITH src_data AS (
    SELECT * FROM {{ ref('brz_bp_rltnshp_src') }}
    WHERE ODQ_CHANGEMODE = 'D'
),

transformed AS (
    SELECT
        RLTNSHP_NBR,
        BUS_PTNR_NBR_1,
        BUS_PTNR_NBR_2,
        VLD_TO_DT,
        VLD_FRM_DT,
        BUS_PTNR_RLTNSHP_CAT_CD,

        {{ udf_boolean_string_conv('BUS_PTNR_ROLE_IND') }} AS BUS_PTNR_ROLE_IND,

        BUS_PTNR_DIFF_TP,
        BUS_PTNR_ROLE,
        BUS_PTNR_RLTNSHP_TP,
        CREATED_BY,

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
        CURRENT_TIMESTAMP() AS ETL_LOAD_DT

    FROM src_data
)

SELECT * FROM transformed
