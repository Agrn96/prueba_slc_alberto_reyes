"""Exporta los datos originales a JSON y genera import.sql para SQL Server."""

import json
from pathlib import Path

import pandas as pd
from pandas.api.types import is_datetime64_any_dtype, is_float_dtype, is_integer_dtype


BASE = Path(__file__).resolve().parent
DATOS = BASE.parent / "datos"
SALIDA = BASE / ".sql-import"


def preparar():
    SALIDA.mkdir(exist_ok=True)
    tablas = []
    for archivo in sorted(DATOS.iterdir()):
        if archivo.suffix == ".parquet":
            tabla = pd.read_parquet(archivo)
        elif archivo.suffix == ".csv":
            tabla = pd.read_csv(archivo)
        else:
            continue

        columnas = []
        for nombre, tipo in tabla.dtypes.items():
            if is_datetime64_any_dtype(tipo):
                tipo_sql = "DATETIME2(7)"
                tabla[nombre] = tabla[nombre].map(
                    lambda valor: None if pd.isna(valor) else valor.isoformat()
                )
            elif is_integer_dtype(tipo):
                tipo_sql = "BIGINT"
            elif is_float_dtype(tipo):
                # Staging: conserva el tipo flotante original; no redondea importes.
                tipo_sql = "FLOAT(53)"
            else:
                tipo_sql = "NVARCHAR(1000)"
                assert tabla[nombre].dropna().str.len().le(1000).all(), nombre
            columnas.append((nombre, tipo_sql))

        # JSON conserva null y cadenas vacías como valores distintos.
        registros = tabla.astype(object).where(tabla.notna(), None).to_dict("records")
        with (SALIDA / f"{archivo.stem}.json").open("w", encoding="ascii") as destino:
            json.dump(registros, destino, ensure_ascii=True, allow_nan=False)
        tablas.append((archivo.stem, columnas, len(tabla)))
        print(f"{archivo.stem}: {len(tabla):,} filas")

    sql = [
        "-- Generado por preparar_importacion.py. Datos originales sin limpieza.",
        "-- Copiar .sql-import al contenedor como /var/opt/mssql/import antes de ejecutar.",
        "-- Ejecutar el archivo completo como script (DBeaver: Alt+X).",
        "USE [master];",
        "GO",
        "IF DB_ID(N'slc_prueba') IS NULL EXEC(N'CREATE DATABASE [slc_prueba]');",
        "GO",
        "USE [slc_prueba];",
        "GO",
        "SET NOCOUNT ON;",
        "SET XACT_ABORT ON;",
        "BEGIN TRY",
        "    BEGIN TRANSACTION;",
    ]
    for nombre, _, _ in tablas:
        sql.extend([
            f"    IF OBJECT_ID(N'dbo.{nombre}', N'U') IS NOT NULL",
            f"        THROW 50001, 'La tabla dbo.{nombre} ya existe. No se modificaron los datos.', 1;",
        ])
    for nombre, columnas, filas in tablas:
        definiciones = ",\n".join(f"        [{col}] {tipo} NULL" for col, tipo in columnas)
        esquema_json = ",\n".join(
            f"        [{col}] {tipo} '$.{col}'" for col, tipo in columnas
        )
        nombres = ", ".join(f"[{col}]" for col, _ in columnas)
        sql.extend([
            "",
            f"    CREATE TABLE dbo.[{nombre}] (\n{definiciones}\n    );",
            f"    INSERT INTO dbo.[{nombre}] ({nombres})",
            f"    SELECT {nombres}",
            f"    FROM OPENROWSET(BULK '/var/opt/mssql/import/{nombre}.json', SINGLE_CLOB) AS archivo",
            "    CROSS APPLY OPENJSON(archivo.BulkColumn)",
            f"    WITH (\n{esquema_json}\n    ) AS datos;",
            f"    IF (SELECT COUNT_BIG(*) FROM dbo.[{nombre}]) <> {filas}",
            f"        THROW 50002, 'Cantidad de filas incorrecta: {nombre}.', 1;",
        ])
    sql.extend([
        "    COMMIT TRANSACTION;",
        "END TRY",
        "BEGIN CATCH",
        "    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;",
        "    THROW;",
        "END CATCH;",
        "GO",
    ])
    sql.append("\nUNION ALL\n".join(
        f"SELECT '{nombre}' AS tabla, COUNT_BIG(*) AS filas FROM dbo.[{nombre}]"
        for nombre, _, _ in tablas
    ) + ";")
    (BASE / "import.sql").write_text("\n".join(sql) + "\n", encoding="utf-8")


if __name__ == "__main__":
    preparar()
