<a href="https://www.onsv.gob.pe/"><img align="right" height="100" src="index_images/logo-onsv.png" float="right" link> </a>


## Identificación de puentes peatonales y siniestralidad

### Exploración del Observatorio Nacional de Seguridad Vial (ONSV)

**Especialista responsable:** <br />
Patricia Illacanchi Guerra

## Introducción
En el presente documento, se ha identificado la localización de puentes peatonales a nivel nacional a partir de la exploración de mapas base de OpenStreetMap. Sobre esta base de datos, se han extraído las capas de interés y se ha realizado la verificación y limpieza de datos para obtener los puentes peatonales georreferenciados.

Asimismo, se han identificado los siniestros fatales que se han registrado en el radio de 400 metros próximos a los puentes peatonales identificados.

## código desarrollado

```
function test() {
  console.log("notice the blank line before this function?");
}
```

La metodología ha sido desarrollada en código R, de modo que pueda ser reproducible a medida que los datos de sinestros del ONSV son robustecidos. A la fecha, se han realizados dos etapas de análisis:

**- Procesamiento con datos del ONSV desde enero 2021 a diciembre de 2022:**

Los datos georreferenciados de siniestros fatales del 2021 al 2022 se encuentran publicados en la sección Datos Abiertos de la web del ONSV y pueden descargarse [aquí](https://www.onsv.gob.pe/datosabiertos). A partir del procesamiento de 2,246 siniestros fatales en la Red Vial Nacional como datos de entrada, se identificaron 83 clústeres o tramos de alta densidad de siniestros.

**- Procesamiento con datos del ONSV desde enero 2021 a julio de 2023:**

Los datos georreferenciados de siniestros fatales del año 2023 vienen siendo actualizados a través del Sistema de Registro de Siniestros de Tránsito (SRAT). Con fecha de cierre de julio de 2023, se han incorporado 903 nuevos registros, lo cual suma 3,149 siniestros fatales en la Red Vial Nacional como datos de entrada. Se identificaron 155 clústeres o tramos de alta densidad de siniestros, de los cuales 76 son resultado de la actualización de los datos. 

Este instrumento se difunde como diagnóstico sobre el que los administradores deben iniciar la investigación particular de las condiciones de riesgo de la infraestructura y vial y, tomar acciones para garantizar la seguridad vial desde una perspectiva de Visión Cero y personas usuarias vulnerables.

## Mapa Interactivo de clústeres o tramos de alta densidad de siniestros fatales

**Datos del ONSV de enero 2021 a diciembre de 2022:**

Los detalles de los 83 clústeres o tramos de alta siniestralidad identificados con datos de este período de datos pueden ser explorados en el [siguiente mapa interactivo](https://patriciaig.github.io/SeguridadVialPeru/mapa_tramos_alta_densidad_fatalidades.html).

**Datos del ONSV de enero 2021 a julio de 2023**

Los detalles de los 155 clústeres o tramos de alta siniestralidad identificados con datos actualizados a julio del 2023 pueden ser explorados en el [siguiente mapa interactivo](https://patriciaig.github.io/SeguridadVialPeru/mapa_prueba.html).
