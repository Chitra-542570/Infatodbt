-- Silver: Work Order ROBAR Batches
-- Converted from Informatica workflow: wf_S_ZJ_WO_ROBAR_BATCHES
-- Mapping: m_S_ZJ_WO_ROBAR_BATCHES
-- Source: JDE F4108_WH (Lot Master) joined with F4801_WH (Work Order Master)
-- Transformations: Source Qualifier join, F0005 lookups (equal/not-equal),
--   F590048 lookups (8AM/8JM branch plants), qty calculation, ETL timestamp

WITH src_joined AS (
    -- sq_F4108_F4801_WH: Source Qualifier joining lot and work order data
    SELECT
        f41.IOLOTN,
        f41.IODOCO,
        f41.IOLITM,
        f41.IOMCU,
        f41.IOAITM,
        f41.IOUB01,
        f48.WAMOH,
        f48.WAURAT,
        f48.WATYPS,
        f48.WASTCM,
        f48.WAVR01,
        f48.WAMMCU,
        f48.WALITM
    FROM {{ ref('brz_f4108_wh') }} f41
    INNER JOIN {{ ref('brz_f4801_wh') }} f48
        ON f41.IODOCO = f48.WADOCO
),

-- exp_SET_ETL_LOAD_DTE: Compute quantity and set ETL load date
with_qty AS (
    SELECT
        src.*,
        src.WAMOH - src.WAURAT AS ORIGINAL_QTY,
        CURRENT_TIMESTAMP()    AS ETL_LOAD_DTE
    FROM src_joined src
)

SELECT
    CAST(IODOCO      AS NUMBER(20,0))  AS DOCUMENT_NO,
    CAST(ORIGINAL_QTY AS NUMBER(20,0)) AS ORIGINAL_QTY,
    CAST(IOUB01      AS NUMBER(15,0))  AS IOUB01,
    IOLOTN                             AS LOT_NO,
    IOMCU,
    IOLITM                             AS LOT_TYPE,
    IOAITM                             AS ITEM_NUMBER,
    ETL_LOAD_DTE,
    WATYPS                             AS WO_TYPE,
    WASTCM                             AS WO_COMMENT,
    WAMMCU                             AS MFG_LOCATION,
    WAVR01                             AS CUSTOMER_ORDER
FROM with_qty
