-- Gold: Final Work Order ROBAR Batches
-- Business-ready view of work order lot/batch data
-- Source: slv_zj_wo_robar_batches (from Informatica wf_S_ZJ_WO_ROBAR_BATCHES)

SELECT
    DOCUMENT_NO,
    ORIGINAL_QTY,
    IOUB01          AS UNIT_BALANCE,
    LOT_NO,
    IOMCU           AS BUSINESS_UNIT,
    LOT_TYPE,
    ITEM_NUMBER,
    WO_TYPE,
    WO_COMMENT,
    MFG_LOCATION,
    CUSTOMER_ORDER,
    ETL_LOAD_DTE
FROM {{ ref('slv_zj_wo_robar_batches') }}
