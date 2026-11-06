-- Generado por preparar_importacion.py. Datos originales sin limpieza.
-- Copiar .sql-import al contenedor como /var/opt/mssql/import antes de ejecutar.
-- Ejecutar el archivo completo como script (DBeaver: Alt+X).
USE [master];
GO
IF DB_ID(N'slc_prueba') IS NULL EXEC(N'CREATE DATABASE [slc_prueba]');
GO
USE [slc_prueba];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID(N'dbo.combos_a_predecir', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.combos_a_predecir ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.etiquetas_train', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.etiquetas_train ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.inv1', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.inv1 ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.inventario_regional', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.inventario_regional ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.obin', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.obin ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.oinv', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.oinv ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.oitb', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.oitb ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.oitm', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.oitm ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.orin', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.orin ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.owhs', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.owhs ya existe. No se modificaron los datos.', 1;
    IF OBJECT_ID(N'dbo.rin1', N'U') IS NOT NULL
        THROW 50001, 'La tabla dbo.rin1 ya existe. No se modificaron los datos.', 1;

    CREATE TABLE dbo.[combos_a_predecir] (
        [id_combo] NVARCHAR(1000) NULL,
        [SKU] NVARCHAR(1000) NULL,
        [CodigoAlmacen] NVARCHAR(1000) NULL
    );
    INSERT INTO dbo.[combos_a_predecir] ([id_combo], [SKU], [CodigoAlmacen])
    SELECT [id_combo], [SKU], [CodigoAlmacen]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/combos_a_predecir.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [id_combo] NVARCHAR(1000) '$.id_combo',
        [SKU] NVARCHAR(1000) '$.SKU',
        [CodigoAlmacen] NVARCHAR(1000) '$.CodigoAlmacen'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[combos_a_predecir]) <> 392
        THROW 50002, 'Cantidad de filas incorrecta: combos_a_predecir.', 1;

    CREATE TABLE dbo.[etiquetas_train] (
        [id_combo] NVARCHAR(1000) NULL,
        [SKU] NVARCHAR(1000) NULL,
        [CodigoAlmacen] NVARCHAR(1000) NULL,
        [riesgo_quiebre] BIGINT NULL
    );
    INSERT INTO dbo.[etiquetas_train] ([id_combo], [SKU], [CodigoAlmacen], [riesgo_quiebre])
    SELECT [id_combo], [SKU], [CodigoAlmacen], [riesgo_quiebre]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/etiquetas_train.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [id_combo] NVARCHAR(1000) '$.id_combo',
        [SKU] NVARCHAR(1000) '$.SKU',
        [CodigoAlmacen] NVARCHAR(1000) '$.CodigoAlmacen',
        [riesgo_quiebre] BIGINT '$.riesgo_quiebre'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[etiquetas_train]) <> 916
        THROW 50002, 'Cantidad de filas incorrecta: etiquetas_train.', 1;

    CREATE TABLE dbo.[inv1] (
        [DocEntry] BIGINT NULL,
        [LineNum] BIGINT NULL,
        [ItemCode] NVARCHAR(1000) NULL,
        [WhsCode] NVARCHAR(1000) NULL,
        [U_Ubicacion] FLOAT(53) NULL,
        [Quantity] FLOAT(53) NULL,
        [LineTotal] FLOAT(53) NULL,
        [StockValue] FLOAT(53) NULL,
        [GrssProfit] FLOAT(53) NULL
    );
    INSERT INTO dbo.[inv1] ([DocEntry], [LineNum], [ItemCode], [WhsCode], [U_Ubicacion], [Quantity], [LineTotal], [StockValue], [GrssProfit])
    SELECT [DocEntry], [LineNum], [ItemCode], [WhsCode], [U_Ubicacion], [Quantity], [LineTotal], [StockValue], [GrssProfit]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/inv1.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [DocEntry] BIGINT '$.DocEntry',
        [LineNum] BIGINT '$.LineNum',
        [ItemCode] NVARCHAR(1000) '$.ItemCode',
        [WhsCode] NVARCHAR(1000) '$.WhsCode',
        [U_Ubicacion] FLOAT(53) '$.U_Ubicacion',
        [Quantity] FLOAT(53) '$.Quantity',
        [LineTotal] FLOAT(53) '$.LineTotal',
        [StockValue] FLOAT(53) '$.StockValue',
        [GrssProfit] FLOAT(53) '$.GrssProfit'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[inv1]) <> 18386
        THROW 50002, 'Cantidad de filas incorrecta: inv1.', 1;

    CREATE TABLE dbo.[inventario_regional] (
        [DataMartDate] DATETIME2(7) NULL,
        [pais] NVARCHAR(1000) NULL,
        [Canal] NVARCHAR(1000) NULL,
        [Ubicacion] NVARCHAR(1000) NULL,
        [CodigoAlmacen] NVARCHAR(1000) NULL,
        [GrupoArticulo] NVARCHAR(1000) NULL,
        [SKU] NVARCHAR(1000) NULL,
        [sum_Stock] BIGINT NULL,
        [sum_Comprometido] BIGINT NULL,
        [sum_Pedido] BIGINT NULL,
        [sum_CostoTotal] FLOAT(53) NULL,
        [sum_CostoTotalUSD] FLOAT(53) NULL
    );
    INSERT INTO dbo.[inventario_regional] ([DataMartDate], [pais], [Canal], [Ubicacion], [CodigoAlmacen], [GrupoArticulo], [SKU], [sum_Stock], [sum_Comprometido], [sum_Pedido], [sum_CostoTotal], [sum_CostoTotalUSD])
    SELECT [DataMartDate], [pais], [Canal], [Ubicacion], [CodigoAlmacen], [GrupoArticulo], [SKU], [sum_Stock], [sum_Comprometido], [sum_Pedido], [sum_CostoTotal], [sum_CostoTotalUSD]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/inventario_regional.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [DataMartDate] DATETIME2(7) '$.DataMartDate',
        [pais] NVARCHAR(1000) '$.pais',
        [Canal] NVARCHAR(1000) '$.Canal',
        [Ubicacion] NVARCHAR(1000) '$.Ubicacion',
        [CodigoAlmacen] NVARCHAR(1000) '$.CodigoAlmacen',
        [GrupoArticulo] NVARCHAR(1000) '$.GrupoArticulo',
        [SKU] NVARCHAR(1000) '$.SKU',
        [sum_Stock] BIGINT '$.sum_Stock',
        [sum_Comprometido] BIGINT '$.sum_Comprometido',
        [sum_Pedido] BIGINT '$.sum_Pedido',
        [sum_CostoTotal] FLOAT(53) '$.sum_CostoTotal',
        [sum_CostoTotalUSD] FLOAT(53) '$.sum_CostoTotalUSD'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[inventario_regional]) <> 502838
        THROW 50002, 'Cantidad de filas incorrecta: inventario_regional.', 1;

    CREATE TABLE dbo.[obin] (
        [AbsEntry] BIGINT NULL,
        [Ubicacion] NVARCHAR(1000) NULL,
        [WhsCode] NVARCHAR(1000) NULL,
        [Canal] NVARCHAR(1000) NULL
    );
    INSERT INTO dbo.[obin] ([AbsEntry], [Ubicacion], [WhsCode], [Canal])
    SELECT [AbsEntry], [Ubicacion], [WhsCode], [Canal]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/obin.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [AbsEntry] BIGINT '$.AbsEntry',
        [Ubicacion] NVARCHAR(1000) '$.Ubicacion',
        [WhsCode] NVARCHAR(1000) '$.WhsCode',
        [Canal] NVARCHAR(1000) '$.Canal'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[obin]) <> 135
        THROW 50002, 'Cantidad de filas incorrecta: obin.', 1;

    CREATE TABLE dbo.[oinv] (
        [DocEntry] BIGINT NULL,
        [DocDate] DATETIME2(7) NULL,
        [Canceled] NVARCHAR(1000) NULL,
        [DocSubType] NVARCHAR(1000) NULL,
        [DocCur] NVARCHAR(1000) NULL,
        [DocRate] FLOAT(53) NULL
    );
    INSERT INTO dbo.[oinv] ([DocEntry], [DocDate], [Canceled], [DocSubType], [DocCur], [DocRate])
    SELECT [DocEntry], [DocDate], [Canceled], [DocSubType], [DocCur], [DocRate]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/oinv.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [DocEntry] BIGINT '$.DocEntry',
        [DocDate] DATETIME2(7) '$.DocDate',
        [Canceled] NVARCHAR(1000) '$.Canceled',
        [DocSubType] NVARCHAR(1000) '$.DocSubType',
        [DocCur] NVARCHAR(1000) '$.DocCur',
        [DocRate] FLOAT(53) '$.DocRate'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[oinv]) <> 7206
        THROW 50002, 'Cantidad de filas incorrecta: oinv.', 1;

    CREATE TABLE dbo.[oitb] (
        [ItmsGrpCod] BIGINT NULL,
        [GrupoArticulo] NVARCHAR(1000) NULL
    );
    INSERT INTO dbo.[oitb] ([ItmsGrpCod], [GrupoArticulo])
    SELECT [ItmsGrpCod], [GrupoArticulo]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/oitb.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [ItmsGrpCod] BIGINT '$.ItmsGrpCod',
        [GrupoArticulo] NVARCHAR(1000) '$.GrupoArticulo'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[oitb]) <> 12
        THROW 50002, 'Cantidad de filas incorrecta: oitb.', 1;

    CREATE TABLE dbo.[oitm] (
        [ItemCode] NVARCHAR(1000) NULL,
        [InvntryUom] NVARCHAR(1000) NULL,
        [ItmsGrpCod] BIGINT NULL,
        [U_Familia] NVARCHAR(1000) NULL,
        [U_SubFamilia] NVARCHAR(1000) NULL,
        [U_Segmento] NVARCHAR(1000) NULL
    );
    INSERT INTO dbo.[oitm] ([ItemCode], [InvntryUom], [ItmsGrpCod], [U_Familia], [U_SubFamilia], [U_Segmento])
    SELECT [ItemCode], [InvntryUom], [ItmsGrpCod], [U_Familia], [U_SubFamilia], [U_Segmento]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/oitm.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [ItemCode] NVARCHAR(1000) '$.ItemCode',
        [InvntryUom] NVARCHAR(1000) '$.InvntryUom',
        [ItmsGrpCod] BIGINT '$.ItmsGrpCod',
        [U_Familia] NVARCHAR(1000) '$.U_Familia',
        [U_SubFamilia] NVARCHAR(1000) '$.U_SubFamilia',
        [U_Segmento] NVARCHAR(1000) '$.U_Segmento'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[oitm]) <> 12847
        THROW 50002, 'Cantidad de filas incorrecta: oitm.', 1;

    CREATE TABLE dbo.[orin] (
        [DocEntry] BIGINT NULL,
        [DocDate] DATETIME2(7) NULL,
        [Canceled] NVARCHAR(1000) NULL
    );
    INSERT INTO dbo.[orin] ([DocEntry], [DocDate], [Canceled])
    SELECT [DocEntry], [DocDate], [Canceled]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/orin.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [DocEntry] BIGINT '$.DocEntry',
        [DocDate] DATETIME2(7) '$.DocDate',
        [Canceled] NVARCHAR(1000) '$.Canceled'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[orin]) <> 224
        THROW 50002, 'Cantidad de filas incorrecta: orin.', 1;

    CREATE TABLE dbo.[owhs] (
        [WhsCode] NVARCHAR(1000) NULL,
        [WhsName] NVARCHAR(1000) NULL,
        [Canal] NVARCHAR(1000) NULL
    );
    INSERT INTO dbo.[owhs] ([WhsCode], [WhsName], [Canal])
    SELECT [WhsCode], [WhsName], [Canal]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/owhs.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [WhsCode] NVARCHAR(1000) '$.WhsCode',
        [WhsName] NVARCHAR(1000) '$.WhsName',
        [Canal] NVARCHAR(1000) '$.Canal'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[owhs]) <> 44
        THROW 50002, 'Cantidad de filas incorrecta: owhs.', 1;

    CREATE TABLE dbo.[rin1] (
        [DocEntry] BIGINT NULL,
        [LineNum] BIGINT NULL,
        [ItemCode] NVARCHAR(1000) NULL,
        [WhsCode] NVARCHAR(1000) NULL,
        [U_Ubicacion] FLOAT(53) NULL,
        [Quantity] FLOAT(53) NULL,
        [LineTotal] FLOAT(53) NULL,
        [StockValue] FLOAT(53) NULL,
        [GrssProfit] FLOAT(53) NULL,
        [BaseEntry] BIGINT NULL,
        [BaseType] BIGINT NULL
    );
    INSERT INTO dbo.[rin1] ([DocEntry], [LineNum], [ItemCode], [WhsCode], [U_Ubicacion], [Quantity], [LineTotal], [StockValue], [GrssProfit], [BaseEntry], [BaseType])
    SELECT [DocEntry], [LineNum], [ItemCode], [WhsCode], [U_Ubicacion], [Quantity], [LineTotal], [StockValue], [GrssProfit], [BaseEntry], [BaseType]
    FROM OPENROWSET(BULK '/var/opt/mssql/import/rin1.json', SINGLE_CLOB) AS archivo
    CROSS APPLY OPENJSON(archivo.BulkColumn)
    WITH (
        [DocEntry] BIGINT '$.DocEntry',
        [LineNum] BIGINT '$.LineNum',
        [ItemCode] NVARCHAR(1000) '$.ItemCode',
        [WhsCode] NVARCHAR(1000) '$.WhsCode',
        [U_Ubicacion] FLOAT(53) '$.U_Ubicacion',
        [Quantity] FLOAT(53) '$.Quantity',
        [LineTotal] FLOAT(53) '$.LineTotal',
        [StockValue] FLOAT(53) '$.StockValue',
        [GrssProfit] FLOAT(53) '$.GrssProfit',
        [BaseEntry] BIGINT '$.BaseEntry',
        [BaseType] BIGINT '$.BaseType'
    ) AS datos;
    IF (SELECT COUNT_BIG(*) FROM dbo.[rin1]) <> 431
        THROW 50002, 'Cantidad de filas incorrecta: rin1.', 1;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
SELECT 'combos_a_predecir' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[combos_a_predecir]
UNION ALL
SELECT 'etiquetas_train' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[etiquetas_train]
UNION ALL
SELECT 'inv1' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[inv1]
UNION ALL
SELECT 'inventario_regional' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[inventario_regional]
UNION ALL
SELECT 'obin' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[obin]
UNION ALL
SELECT 'oinv' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[oinv]
UNION ALL
SELECT 'oitb' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[oitb]
UNION ALL
SELECT 'oitm' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[oitm]
UNION ALL
SELECT 'orin' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[orin]
UNION ALL
SELECT 'owhs' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[owhs]
UNION ALL
SELECT 'rin1' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[rin1];
