-- Gold: Final Business Partner Relationship Master
-- Business-ready view of BP relationship data
-- Source: slv_bp_rltnshp_master (from Informatica wf_DI_BP_RLTNSHP_MASTER)

SELECT
    RLTNSHP_NBR,
    BUS_PTNR_NBR_1,
    BUS_PTNR_NBR_2,
    VLD_TO_DT       AS VALID_TO_DATE,
    VLD_FRM_DT      AS VALID_FROM_DATE,
    BUS_PTNR_RLTNSHP_CAT_CD AS RELATIONSHIP_CATEGORY,
    BUS_PTNR_ROLE_IND        AS ROLE_INDICATOR,
    BUS_PTNR_DIFF_TP         AS DIFFERENTIATION_TYPE,
    BUS_PTNR_ROLE            AS PARTNER_ROLE,
    BUS_PTNR_RLTNSHP_TP     AS RELATIONSHIP_TYPE,
    CREATED_BY,
    CREATED_DT,
    LAST_CHG_USR   AS LAST_CHANGED_BY,
    LAST_CHG_DT    AS LAST_CHANGED_DATE,
    ODQ_CHANGEMODE AS CHANGE_MODE,
    MD5_HASH,
    ETL_LOAD_DT
FROM {{ ref('slv_bp_rltnshp_master') }}
