\# Base de Datos: \[Nombre del Proyecto]



\## Descripción

Base de datos para \[propósito del sistema]



\## Esquema

\- \*\*Versión\*\*: 1.0.0

\- \*\*Compatibilidad\*\*: SQL Server 2016+

\- \*\*Collation\*\*: SQL\_Latin1\_General\_CP1\_CI\_AS



\## Estructura de Tablas

\- `Usuarios` - Tabla de usuarios del sistema

\- `Productos` - Catálogo de productos

\- `Pedidos` - Registro de pedidos



\## Instalación

1\. Ejecutar `Scripts/01-Database-Creation/CreateDatabase.sql`

2\. Ejecutar `Scripts/02-Tables/\*.sql` en orden

3\. Ejecutar `Scripts/03-StoredProcedures/\*.sql`

4\. Ejecutar `Scripts/06-Data/SeedData.sql`



\## Diagrama ER

\[Incluir imagen o descripción del diagrama]

