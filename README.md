# Prueba técnica SLC

Análisis de ventas e inventario del 1 al 21 de agosto de 2026. Por ahora se realizó la revisión inicial de las tablas; la limpieza y las partes A, B y C están pendientes.

## Ejecución

Con Python 3.12, instalar las dependencias desde `Prueba_C.E/Respuestas`:

```powershell
python -m pip install -r requirements.txt
```

Abrir `analisis.ipynb` en VS Code con la extensión Jupyter, seleccionar el entorno donde se instalaron las dependencias y ejecutar las celdas en orden. Los datos se leen de `../datos`. Queda pendiente comprobar la ejecución en un entorno nuevo.

Para cargar los datos originales en SQL Server, desde `Prueba_C.E/Respuestas`:

```powershell
python preparar_importacion.py
docker compose cp .sql-import sqlserver:/var/opt/mssql/import
```

En DBeaver, ejecutar `import.sql` completo como script (Alt+X) con la conexión de SQL Server. Crea `slc_prueba` y carga las once tablas sin limpieza ni claves foráneas. Se detiene si alguna tabla ya existe. Los JSON temporales quedan fuera de Git. Los campos flotantes se conservan como `FLOAT` en staging; el tratamiento monetario se definirá en el análisis.

## Observaciones iniciales

- Hay líneas de factura y notas de crédito sin producto, bodega o ubicación. Se mantienen mientras se investiga su tratamiento.
- 70 líneas de `rin1` referencian facturas que no aparecen en `oinv`. No se ha confirmado si son anteriores a agosto.
- `orin` no incluye moneda ni tipo de cambio.
- En `oitm` hay 10 códigos de producto repetidos. Los pares observados solo difieren en el segmento; se propone conservar el específico en lugar de `SIN SEGMENTO`.
- Hay SKUs y canales faltantes. Tres ubicaciones referencian bodegas ausentes de `owhs`.
- `GT1CEDI` no tiene registros del 15 al 17 de agosto. `GT2COMER` solo tiene una fila el 20 de agosto.
- Inventario tiene 246 repeticiones de la clave candidata, pero los ejemplos difieren en grupo, stock y costo. Todavía no se consideran filas sobrantes.

El detalle y los conteos están en [analisis.ipynb](Prueba_C.E/Respuestas/analisis.ipynb).

## Criterios

- Usar `InvntryUom` como SKU y `obin.Canal` como canal de venta.
- Mantener los archivos originales sin cambios y no asumir stock cero cuando faltan registros.
- Reportar montos en GTQ, sin redondeos intermedios y con dos decimales para A2.
- Usar únicamente información disponible al cierre del 21 de agosto para el modelo.
