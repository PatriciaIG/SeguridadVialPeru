<a href="https://www.onsv.gob.pe/"><img align="right" height="100" src="index_images/logo-onsv.png" float="right" link> </a>


## DBSCAN: Explorando la densidad espacial de siniestros fatales para la identificación y priorización de intervenciones en la Red Vial Nacional

### Documento de Trabajo 001 del Observatorio Nacional de Seguridad Vial (ONSV)

**Especialista responsable del desarrollo del estudio:** <br />
Patricia Illacanchi Guerra

**Equipo responsable de la revisión del estudio:** <br />
Alex Sigüenza Alvarez <br />
Freddy Castañeda Rios <br />
Gabriel Legua Landeo

**Personal técnico responsable de diseño gráfico:** <br />
Ademir Neyra Meza

## Resumen
En Perú, se han registrado alrededor de 29 mil siniestros de tránsito fatales desde el año 2010 al 2021. Cada uno de estos siniestros está vinculando en cierta medida a las condiciones del entorno en el que ocurrió, dado que estas pueden propiciar o agravar el siniestro. En ese sentido, es importante que puedan tomarse acciones que permitan reducir significativamente las muertes y lesiones graves como consecuencia de la alta siniestralidad vial.

El presente estudio es realizado para la Dirección de Seguridad Vial del Ministerio de Transportes y Comunicaciones del Perú y pretende establecer un algoritmo sistematizado y reproducible para la identificación y priorización de clústeres o tramos de alta densidad de siniestros viales. La técnica empleada se basa en el análisis geográfico de algoritmos de Machine Learning como el Agrupamiento Espacial Basado en Densidad de Aplicaciones con Ruido (DBSCAN en inglés).

Como resultado de esta metodología desarrollada por el ONSV, se identificaron clústeres o tramos de alta densidad de siniestros fatales en la Red Vial Nacional, administrados por concesionarias y entidades estatales . A partir de ello, se impulsa la inspección especializada y particular de cada clúster o tramo como base para el desarrollo de propuestas de mitigación de riesgos viales en el marco de una gestión pública basada en evidencias.

En específico, esta exploración geográfica desarrollada en el presente estudio pretende dar respuesta a la pregunta siguiente:

> ***¿Cuáles son los tramos viales en los que los administradores de la vía pueden implementar medidas que tengan alto impacto en la reducción de la siniestralidad vial?***

## Resultados 

La metodología ha sido desarrollada en código R, de modo que pueda ser reproducible a medida que los datos de sinestros del ONSV son robustecidos. A la fecha, se han realizados dos etapas de análisis:

**- Procesamiento con datos del ONSV desde enero 2021 a diciembre de 2022:**
Los datos georreferenciados de siniestros fatales del 2021 al 2022 se encuentran publicados en la sección Datos Abiertos de la web del ONSV y pueden descargarse [aquí](https://www.onsv.gob.pe/datosabiertos). A partir del procesamiento de 2,246 siniestros fatales en la Red Vial Nacional como datos de entrada, se identificaron 83 clústeres o tramos de alta densidad de siniestros.

**- Procesamiento con datos del ONSV desde enero 2021 a julio de 2023:**
Los datos georreferenciados de siniestros fatales del año 2023 vienen siendo actualizados a través del Sistema de Registro de Siniestros de Tránsito (SRAT). Con fecha de cierre de julio de 2023, se han incorporado 903 nuevos registros, lo cual suma 3,149 siniestros fatales en la Red Vial Nacional como datos de entrada. Se identificaron 155 clústeres o tramos de alta densidad de siniestros, de los cuales 76 son resultado de la actualización de los datos. 

Este instrumento se difunde como diagnóstico sobre el que los administradores deben iniciar la investigación particular de las condiciones de riesgo de la infraestructura y vial y, tomar acciones para garantizar la seguridad vial desde una perspectiva de Visión Cero y personas usuarias vulnerables.

## Mapa Interactivo de clústeres o tramos de alta densidad de siniestros fatales

**Datos ONSV 2021 - 2022**
Los detalles de los 83 clústeres o tramos de alta siniestralidad identificados con datos de este período de datos pueden ser explorados en el [siguiente mapa interactivo](https://patriciaig.github.io/SeguridadVialPeru/mapa_tramos_alta_densidad_fatalidades.html).

**Datos ONSV 2021 - julio 2023**
Los detalles de los 155 clústeres o tramos de alta siniestralidad identificados con datos actualizados a julio del 2023 pueden ser explorados en el [siguiente mapa](https://patriciaig.github.io/SeguridadVialPeru/mapa_prueba.html).
