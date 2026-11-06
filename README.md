# Prueba técnica SLC

Análisis de ventas e inventario del 1 al 21 de agosto de 2026. La revisión inicial y las partes A, B y C están desarrolladas. El resumen ejecutivo está pendiente.

## Ejecución

Con Python 3.12, instalar las dependencias desde `Respuestas`:

```powershell
python -m pip install -r requirements.txt
```

Abrir `analisis.ipynb` en VS Code con la extensión Jupyter, seleccionar el entorno donde se instalaron las dependencias y ejecutar las celdas en orden. Los datos se leen de `../datos`. Queda pendiente comprobar la ejecución en un entorno nuevo.

Para cargar los datos originales en SQL Server, desde `Respuestas`:

```powershell
python preparar_importacion.py
docker compose cp .sql-import sqlserver:/var/opt/mssql/import
```

En DBeaver, ejecutar `import.sql` completo como script (Alt+X) con la conexión de SQL Server. Crea `slc_prueba` y carga las once tablas sin limpieza ni claves foráneas. Se detiene si alguna tabla ya existe. Los JSON temporales quedan fuera de Git. Los campos flotantes se conservan como `FLOAT` en staging; el tratamiento monetario se explica en los notebooks.

## Observaciones iniciales

- Hay líneas de factura y notas de crédito sin producto, bodega o ubicación. Se mantienen mientras se investiga su tratamiento.
- 70 líneas de `rin1` referencian facturas que no aparecen en `oinv`. No se ha confirmado si son anteriores a agosto.
- `orin` no incluye moneda ni tipo de cambio.
- En `oitm` hay 10 códigos de producto repetidos. Los pares observados solo difieren en el segmento; se propone conservar el específico en lugar de `SIN SEGMENTO`.
- Hay SKUs y canales faltantes. Tres ubicaciones referencian bodegas ausentes de `owhs`.
- `GT1CEDI` no tiene registros del 15 al 17 de agosto. `GT2COMER` solo tiene una fila el 20 de agosto.
- Inventario tiene 246 repeticiones de la clave candidata, pero los ejemplos difieren en grupo, stock y costo. Todavía no se consideran filas sobrantes.

El detalle y los conteos están en [analisis.ipynb](Respuestas/analisis.ipynb).

## Criterios

- Usar `InvntryUom` como SKU y `obin.Canal` como canal de venta.
- Mantener los archivos originales sin cambios y no asumir stock cero cuando faltan registros.
- Reportar montos en GTQ, sin redondeos intermedios y con dos decimales para A2.
- Usar únicamente información disponible al cierre del 21 de agosto para el modelo.

## Actualización de las partes A y B

Abrir también analisis_a.ipynb y analisis_b.ipynb desde Respuestas. Cada notebook carga sus propios datos. Las tablas y gráficas de B se guardan en resultados/. B se ejecutó desde un kernel nuevo, pero falta comprobar la entrega en un entorno instalado desde cero.

### Otros hallazgos

- N/A aparece como texto en el SKU y no lo detecta isna(). Se separa de los productos identificados.
- Hay 447 observaciones de inventario sin costo. GT1COMER tiene 25 por día del 1 al 12 y 14 del 13 al 21. GT1SERV tiene una por día. Los valores quedan parciales, sin rellenar con cero.
- Tras separar N/A, hay 184 pares con ventas pero sin inventario al 21. Su stock queda desconocido.
- Hay 1,638 líneas de venta y crédito sin canal y 58 sin grupo. Estas 58 también tienen diferencias entre utilidad calculada y registrada.
- En USD, las comprobaciones apoyan que StockValue ya está en GTQ y GrssProfit está en moneda del documento. Se convierte ingreso y utilidad, sin convertir el costo otra vez.
- SERVICIOS tiene costos registrados en cero. Su margen de 100% no demuestra que prestar el servicio no tenga costos.

### Decisiones usadas

- Se excluyen los documentos cancelados. Los créditos se consideran GTQ. Para A7, las referencias ausentes se asumen anteriores a agosto, sin confirmar sus fechas.
- Se conserva el segmento específico en los pares repetidos del catálogo. No se eliminaron las repeticiones entre grupos distintos de inventario.
- B1 define pronto como siete días y compara ventas promedio de 7 y 21 días. Servicio se muestra aparte.
- B2 usa ABC por venta neta positiva, con límites aproximados de 80% y 95%.
- B3 identifica stock sin ventas en su bodega durante los 21 días. No demuestra obsolescencia.
- B4 calcula utilidad bruta como ventas menos costo, sin gastos operativos.
- B5 presenta tres acciones con montos del notebook. Reposición estimada, inventario a revisar y pérdida observada no se suman como ahorro.

Se usa el inventario observado al 21, sin arrastrar el último dato anterior. Los detalles y las limitaciones están en cada notebook.

## Actualización de la Parte C

Ejecutar analisis_c.ipynb desde Respuestas, con las celdas en orden. Carga sus propios datos y genera predicciones.csv. Las tablas de apoyo y la gráfica quedan en resultados/.

- Se usan ventas e inventario hasta el 21 de agosto. El objetivo es detectar si el stock baja a la mitad o menos durante la semana siguiente.
- Se comparan regresión logística y un árbol pequeño con ocho variables. Se separa por SKU en entrenamiento, validación y prueba.
- El árbol con umbral 0.10 tiene el menor costo en validación. En prueba detecta 11 de 14 eventos, con 32 falsas alertas y costo de Q9,300.
- Hay pocos casos positivos y solo un corte de datos. El resultado no demuestra que funcione igual en otras semanas.

El archivo de entrega tiene las 392 combinaciones, con id_combo, probabilidad y alerta. Los tres notebooks se ejecutaron por separado y los CSV se reprodujeron sin cambios. Sigue pendiente comprobar una instalación desde cero.
