USE slc_prueba;

;WITH productos_priorizados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ItemCode
            ORDER BY
                CASE
                    WHEN U_Segmento IS NULL
                      OR U_Segmento = 'SIN SEGMENTO'
                    THEN 1
                    ELSE 0
                END,
                U_Segmento
        ) AS prioridad
    FROM dbo.oitm
),
documentos AS (
    SELECT
        'FACTURA' AS TipoDocumento,
        detalle.DocEntry,
        detalle.LineNum,
        encabezado.DocDate,
        encabezado.DocSubType,
        detalle.ItemCode,
        detalle.WhsCode,
        detalle.U_Ubicacion,
        encabezado.DocCur,
        encabezado.DocRate,
        1 AS Signo,
        detalle.Quantity,
        detalle.LineTotal,
        detalle.StockValue,
        detalle.GrssProfit
    FROM dbo.inv1 AS detalle
    INNER JOIN dbo.oinv AS encabezado
        ON detalle.DocEntry = encabezado.DocEntry
    WHERE encabezado.Canceled = 'N'
      AND encabezado.DocDate >= '20260801'
      AND encabezado.DocDate < '20260822'

    UNION ALL

    SELECT
        'NOTA_CREDITO' AS TipoDocumento,
        detalle.DocEntry,
        detalle.LineNum,
        encabezado.DocDate,
        NULL AS DocSubType,
        detalle.ItemCode,
        detalle.WhsCode,
        detalle.U_Ubicacion,
        NULL AS DocCur,
        NULL AS DocRate,
        -1 AS Signo,
        detalle.Quantity,
        detalle.LineTotal,
        detalle.StockValue,
        detalle.GrssProfit
    FROM dbo.rin1 AS detalle
    INNER JOIN dbo.orin AS encabezado
        ON detalle.DocEntry = encabezado.DocEntry
    WHERE encabezado.Canceled = 'N'
      AND encabezado.DocDate >= '20260801'
      AND encabezado.DocDate < '20260822'
)
SELECT
    documento.TipoDocumento,
    documento.DocEntry,
    documento.LineNum,
    documento.DocDate,
    documento.DocSubType,
    documento.ItemCode,
    producto.InvntryUom AS SKU,
    grupo.GrupoArticulo,
    documento.WhsCode,
    bodega.WhsName,
    ubicacion.Canal,
    ubicacion.Ubicacion,
    documento.DocCur,
    documento.DocRate,
    documento.Signo,
    documento.Quantity,
    documento.LineTotal,
    CASE
        WHEN documento.DocCur = 'USD'
            THEN documento.LineTotal * documento.DocRate
        WHEN documento.DocCur = 'QTZ'
            THEN documento.LineTotal
        WHEN documento.TipoDocumento = 'NOTA_CREDITO'
            THEN documento.LineTotal
        ELSE NULL
    END AS ImporteGTQ,
    documento.StockValue,
    documento.GrssProfit,
    SUM(
    documento.Signo *
    CASE
        WHEN documento.DocCur = 'USD'
            THEN documento.LineTotal * documento.DocRate
        WHEN documento.DocCur = 'QTZ'
            THEN documento.LineTotal
        WHEN documento.TipoDocumento = 'NOTA_CREDITO'
            THEN documento.LineTotal
        ELSE NULL
    END
) OVER () AS VentaNetaTotalGTQ
FROM documentos AS documento
LEFT JOIN productos_priorizados AS producto
    ON documento.ItemCode = producto.ItemCode
   AND producto.prioridad = 1
LEFT JOIN dbo.oitb AS grupo
    ON producto.ItmsGrpCod = grupo.ItmsGrpCod
LEFT JOIN dbo.owhs AS bodega
    ON documento.WhsCode = bodega.WhsCode
LEFT JOIN dbo.obin AS ubicacion
    ON documento.U_Ubicacion = ubicacion.AbsEntry;