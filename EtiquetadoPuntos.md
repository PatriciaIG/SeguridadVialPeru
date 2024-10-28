<a href="https://www.onsv.gob.pe/"><img align="right" height="100" src="index_images/logo-onsv.png" float="right" link> </a>


## ¿Cómo caracterizar bases de datos geográficas de puntos según la jerarquización vial en Perú? 

**Guía de código en R:** <br />
Ver documento digital para reproducción en <a href="https://patriciaig.github.io/SeguridadVialPeru/EtiquetadoPuntos">https://patriciaig.github.io/SeguridadVialPeru/EtiquetadoPuntos</a>.

**Especialista responsable:** <br />
Patricia Illacanchi Guerra

## Introducción
Este documento tiene como objetivo proporcionar una guía para la caracterización de bases de datos geográficas de puntos, centrando la atención en la jerarquización vial en Perú. La jerarquización vial es un sistema de clasificación que organiza las rutas de acuerdo a su importancia y función en la red de transporte. En este contexto, se identifican tres jerarquías de red vial: la Red Vial Nacional (RNV), la Red Vial Departamental (RVD) y la Red Vial Vecinal (RVV). Cada una de estas redes se distingue por su código de ruta, que facilita la gestión y planificación del transporte en el país.

## 1. Definición de Jerarquías Viales

- **Red Vial Nacional (RNV)**: Comprende las carreteras principales que conectan regiones importantes y suelen ser de mayor tamaño y mantenimiento.
- **Red Vial Departamental (RVD)**: Incluye las carreteras que conectan provincias dentro de un departamento y son esenciales para la conectividad regional.
- **Red Vial Vecinal (RVV)**: Consiste en caminos y carreteras que sirven a áreas locales, proporcionando acceso a zonas rurales y /o vecinales.

## 2. Importación y Preparación de Datos

Para caracterizar bases de datos geográficas de puntos según la jerarquización vial en Perú, se pueden seguir varios pasos que permiten analizar la relación entre los eventos o puntos de interés y las diferentes categorías de la red vial.

### 2.1 Cargar las Librerías Necesarias

```r
library(data.table)
library(sf)
library(tidyverse)
library(tmap)
library(here)
```
### 2.2 Cargar el Archivo de Puntos
Se requiere importar las bases de datos de puntos geográficos (por ejemplo, siniestro de tránsito, eventos naturales, reportes de riesgo y otros) y las capas de la red vial (RNV, RVD, RVV) y procesarlos en `R` como `spatial feature object` o base de datos espacial. Asimismo, debe asegurarse de que todas las bases de datos tengan el mismo sistema de referencia espacial (CRS) para facilitar la integración y análisis.

```r
# Cargar el Archivo de Puntos
puntos_raw <- fread(here::here("Data", "ETIQUETADO_PUNTOS", "ReportePeligros2019_2023.CSV"), 
                    sep = ";", encoding = "UTF-8")
# Procesar las Fechas
puntos_raw$Fecha <- as.Date(puntos_raw$Fecha,"%d/%m/%Y")

# Transformar a Formato sf
puntos_raw <- st_as_sf(puntos_raw, coords = c("longitud", "latitud"), crs = 4326)

puntos_raw <- puntos_raw %>%
  mutate(longitud = unlist(map(puntos_raw$geometry, 1)),
         latitud = unlist(map(puntos_raw$geometry, 2)))

puntos_raw <- puntos_raw %>%
  st_transform(., 32717)
```

### 2.3 Etiquetado de jerarquía de red vial y código de ruta

#### Buffering
Crear zonas de influencia (buffers) alrededor de cada tipo de red vial para determinar qué puntos caen dentro de estas áreas. Por ejemplo, una sección promedio de ancho de vía en la RVN puede ser de 50 a 60 metros. Por ello se considera una distancia de 20 a 30 metros alrededor de cada eje vial.

#### Intersección
Utilizar funciones de análisis espacial (como `st_join` en R) para clasificar los puntos en función de su proximidad a las jerarquías viales con un Código de Ruta específico. Esto implica identificar qué puntos están dentro del buffer de cada red vial identificada por un Código de Ruta (por ejemplo: PE-1N, PE-20, etc.).

#### Clasificación por Proximidad a la Red Vial Nacional
Se emplean ambas funciones de buffering e intersección para asociar los puntos a un Código de Ruta, de corresponder. La distancia para generar el buffer (`dist` = 30) puede variar de acuerdo a las particularidades de la carretera, derechos de vía y la naturaleza del evento en sí (es puntual, longitudinal o superficial).

```r
rn2018_buffer <- st_buffer(rn2018, dist = 30, endCapStyle = "FLAT")
rn2018_buffer <- rn2018_buffer %>%
  st_transform(., 32717)

puntos_classified <- st_join(puntos_raw, rn2018_buffer, join = st_within) %>%
  filter(!is.na(CODRUTA))

length(unique(puntos_classified$id_sinpad))

tm_basemap(leaflet::providers$OpenStreetMap) +
  tm_shape(rn2018_buffer[rn2018_buffer$CODRUTA %in% unique(puntos_classified$CODRUTA),]) + 
  tm_fill(col = "blue", size = 0.05, alpha = 0.3) +
  tm_shape(puntos_classified) + 
  tm_dots(col = "#b91655", size = 0.05)

write.table(st_drop_geometry(puntos_classified), "puntos_classified_rvn.csv", sep = ";")
```

#### Clasificación por Proximidad a la Red Vial Departamental
Para este análisis, se han removido a los puntos que ya ocurren sobre la RVN para evitar sobreescribir el campo de Código de Ruta por uno de menor jerarquía y menor flujo vehicular. La distancia para generar el buffer (`dist` = 20) puede ser ajustada como en el caso anterior.

```r
puntos_raw <- puntos_raw[!puntos_raw$id_sinpad %in% puntos_classified$id_sinpad, ]

rd2018_buffer <- rd2018 %>%
  st_transform(., 32717)
rd2018_buffer <- st_buffer(rd2018_buffer, dist = 20, endCapStyle = "FLAT")

puntos_classified <- st_join(puntos_raw, rd2018_buffer, join = st_within) %>%
  filter(!is.na(CODRUTA))

length(unique(puntos_classified$id_sinpad))

tm_basemap(leaflet::providers$OpenStreetMap) +
  tm_shape(rd2018_buffer[rd2018_buffer$CODRUTA %in% unique(puntos_classified$CODRUTA),]) + 
  tm_fill(col = "blue", size = 0.05, alpha = 0.3) +
  tm_shape(puntos_classified) + 
  tm_dots(col = "#b91655", size = 0.05)

write.table(st_drop_geometry(puntos_classified), "puntos_classified_rvd.csv", sep = ";")
```
#### Clasificación por Proximidad a la Red Vial Vecinal
Para este análisis, se han removido a los puntos que ya ocurren sobre la RVN y RVD para evitar sobreescribir el campo de Código de Ruta por uno de menor jerarquía y menor flujo vehicular. La distancia para generar el buffer (`dist` = 20) puede ser ajustada como en los casos anteriores.

```r
puntos_raw <- puntos_raw[!puntos_raw$id_sinpad %in% puntos_classified$id_sinpad, ]

rv2018_buffer <- rv2018 %>%
  st_transform(., 32717)
rv2018_buffer <- st_buffer(rv2018_buffer, dist = 20, endCapStyle = "FLAT")

puntos_classified <- st_join(puntos_raw, rv2018_buffer, join = st_within) %>%
  filter(!is.na(CODRUTA))

length(unique(puntos_classified$id_sinpad))

tm_basemap(leaflet::providers$OpenStreetMap) +
  tm_shape(rv2018_buffer[rv2018_buffer$CODRUTA %in% unique(puntos_classified$CODRUTA),]) + 
  tm_fill(col = "blue", size = 0.05, alpha = 0.3) +
  tm_shape(puntos_classified) + 
  tm_dots(col = "#b91655", size = 0.05)

write.table(st_drop_geometry(puntos_classified), "puntos_classified_rvv.csv", sep = ";")
```
### 2.4 Etiquetado de hito kilométrico de RVN
Esta sección describe el proceso para calcular la progresiva (kilómetro) en la que ocurren los puntos de siniestros de tránsito (u otro tipo de puntos) dentro de la Red Vial Nacional (RVN) en Perú. Se utiliza la librería `FNN` para encontrar los hitos más cercanos y realizar la interpolación.

#### Preparación de Datos

Primero, se cargan las librerías necesarias y se prepara un dataframe para almacenar los resultados.

```r
library(FNN)

# Almacenar resultados
results <- data.frame(matrix(ncol = 2, nrow = 0))
colnames(results) <- c("CodigoAccidente","Progresiva")

# Transformar el sistema de referencia espacial de los datos de accidentes
crash_rn <- crash_rn %>%
  st_transform(., 4326)
```
#### Función para Interpolar Progresivas
Se define una función `interpolate_km` que calcula el valor de la progresiva a partir de las coordenadas de los accidentes y los hitos más cercanos.
```r
# Función para interpolar valores de kilómetros
interpolate_km <- function(indices, crash_rn_coords, hitos_coords, km_values) {
  # Obtener las coordenadas y valores de kilómetro de los dos hitos más cercanos
  coords1 <- hitos_coords[indices[1], ]
  coords2 <- hitos_coords[indices[2], ]
  km1 <- km_values[indices[1]]
  km2 <- km_values[indices[2]]
  
  # Calcular distancias
  d1 <- sqrt((crash_rn_coords[1] - coords1[1])^2 + (crash_rn_coords[2] - coords1[2])^2)
  d2 <- sqrt((crash_rn_coords[1] - coords2[1])^2 + (crash_rn_coords[2] - coords2[2])^2)
  
  # Interpolar valor de kilómetro
  interpolated_km <- round((d2 * km1 + d1 * km2) / (d1 + d2), 1)
  return(interpolated_km)
}
```
#### Cálculo de Progresivas para Cada Punto
Se itera sobre cada código de ruta para calcular las progresivas de los puntos de siniestros de tránsito. Dentro de este proceso, se identifican los dos hitos kilométricos más próximos y se itera el valor de la progresiva para cada punto.

```r
# Calcular para cada ruta
for (i in codruta[1:124]) {
  if (i %in% unique(crash_rn$CodigoCarretera)) {
    
    crash_points <- crash_rn[crash_rn$CodigoCarretera == i, ]
    hitos_points <- hitos[hitos$CodRuta == i, ]
    
    # Reiniciar índices para la identificación y etiquetado
    crash_points <- crash_points %>%
      dplyr::mutate(row_id = row_number())
    crash_points <- as.data.frame(crash_points)
    rownames(crash_points) <- seq_len(nrow(crash_points))
    crash_points <- st_as_sf(crash_points)
    
    # Reiniciar índices para los hitos
    hitos_points <- hitos_points %>%
      dplyr::mutate(row_id = row_number())
    hitos_points <- as.data.frame(hitos_points)
    rownames(hitos_points) <- seq_len(nrow(hitos_points))
    hitos_points <- st_as_sf(hitos_points)
    
    # Extraer coordenadas
    hitos_coords <- st_coordinates(hitos_points)
    crash_rn_coords <- st_coordinates(crash_points)
    
    # Elegir hitos más cercanos
    nn <- get.knnx(hitos_coords, crash_rn_coords, k = 2) 
    
    # Obtener los IDs de los dos hitos más cercanos
    nn_indices <- nn$nn.index
    
    # Extraer valores de kilómetros de los hitos
    km_values <- hitos_points$Km  # Reemplazar 'Km' con el nombre real de la columna
    
    # Aplicar la función de interpolación a cada punto de accidente
    interpolated_km_values <- mapply(interpolate_km, 
                                      split(nn_indices, 1:nrow(nn_indices)), 
                                      split(crash_rn_coords, 1:nrow(crash_rn_coords)), 
                                      MoreArgs = list(hitos_coords, km_values))
    
    # Añadir los valores de kilómetros interpolados al conjunto de datos de puntos de accidentes
    crash_points <- crash_points %>%
      mutate(interpolated_km = interpolated_km_values)
    
    # Visualizar en mapa
    tm_shape(rn2018[rn2018$CODRUTA == i, ]) +
      tm_lines(col = "black", lwd = 2, alpha = 0.5) +
      tm_shape(hitos_points) +
      tm_dots(col = "blue", size = 0.1) +
      tm_text("Km", just = "left", xmod = 0.01, size = 1.5, col = "blue") +
      tm_shape(crash_points) +
      tm_dots(col = "#B90E0A", size = 0.1, alpha = 0.5) +
      tm_text("interpolated_km", just = "left", xmod = 0.01, size = 1.5, col = "red")
   
    # Almacenar resultados
    a <- data.frame(CodigoAccidente = crash_points$CodigoAccidente,
                     Progresiva = crash_points$interpolated_km)
    results <- rbind(results, a)
  }
}
```
#### Edición de Valores de Progresivas
A partir de la visualización en el mapa, se identifican y editan manualmente los valores de progresivas atípicos o que no correspondan al valor calculado por tener trazos particulares o no existir hitos próximos a partir de los cuales se pueda iterar correctamente.

```r
# Editar valores de progresivas: falta identificar atípicos en todo el results
results[results$CodigoAccidente == "A-2023-03-79", ] <- 406.0
results[results$CodigoAccidente == "A-2023-03-171", ] <- 115.7
results[results$CodigoAccidente == "A-2023-06-186", ] <- 109.3
results[results$CodigoAccidente == "A-2022-07-229", ] <- 7.2
```
### 2.5 Etiquetado de Concesionarias (DGPPT) a la Cual Pertenecen
En este paso, se asignan etiquetas a las concesionarias correspondientes a los puntos de siniestros utilizando un buffer espacial.
```r
# Transformar a CRS 32717
crash_rn <- crash_rn %>%
  st_transform(., 32717)

# Crear un buffer alrededor de las líneas de concesionarias (100 metros)
buffer_sf <- st_buffer(rnconc, dist = 100)

# Realizar una unión espacial para encontrar qué línea está cerca de cada punto
points_with_buffer <- st_join(crash_rn, buffer_sf, join = st_within)

# Identificar duplicados
duplicates <- points_with_buffer %>%
  group_by(CodigoAccidente) %>%
  filter(n() > 1)

# Mostrar duplicados únicos
unique(duplicates$CodigoAccidente) 
points_with_buffer[points_with_buffer$CodigoAccidente == "A-2021-04-148", ]

# Graficar
tm_shape(rnconc) +
  tm_lines("ADMINISTRA") +
  tm_shape(duplicates) +
  tm_dots("CodigoAccidente")

# Eliminar puntos que coinciden con dos concesiones
remove <- c(2021, 2107.1, 1163.1, 916.1, 2783, 333, 1405.1)
points_with_buffer <- points_with_buffer[!row.names(points_with_buffer) %in% remove, ]

# Actualizar crash_rn
crash_rn <- points_with_buffer
crash_rn[is.na(crash_rn$ESTADO), ]$ESTADO <- "Por evaluar"
crash_rn[crash_rn$ESTADO == "Otorgada", ]$ESTADO <- "Otorgada-DGPPT"

# Obtener cifras de víctimas en DGPPT
sum(crash_rn[crash_rn$ESTADO == "Otorgada-DGPPT", ]$CantidadDeFallecidos)
sum(crash_rn[crash_rn$ESTADO == "Otorgada-DGPPT", ]$CantidadDeLesionados)

# Obtener cifras de víctimas en Preinversión
sum(crash_rn[crash_rn$ESTADO == "Encargado a Proinversion", ]$CantidadDeFallecidos)
sum(crash_rn[crash_rn$ESTADO == "Encargado a Proinversion", ]$CantidadDeLesionados)
```
### 2.6 Etiquetado de Concesionarias (MML) a la Cual Pertenecen
En este paso, se etiquetan las concesionarias correspondientes a los puntos de siniestros de tránsito en el área de Lima Metropolitana. Estas concesionarias están administradas por EMAPE - MML. Primero, filtramos los datos de los siniestros que ocurren en Lima y Callao.

```r
# Filtrar Lima Metropolitana
lima_metro <- bond_prov %>%
  dplyr::filter(str_detect(PROVINCIA, "LIMA|CALLAO"))

lima_metro_dist <- bond_dist %>%
  dplyr::filter(str_detect(PROVINCIA, "LIMA|CALLAO"))
```
A continuación, se etiqueta cada siniestro con la información de concesionaria correspondiente.
```r
#A-Vía Evitamiento - Lima Expresa - progresivas: PE-1N 0-12 PE-1S 0-3.6 

crash_rn <- crash_rn %>%
  mutate(ADMINISTRA=ifelse(CodigoCarretera=="PE-1N"&Progresiva>=0&Progresiva<=12,"Lima Expresa - Evitamiento",ADMINISTRA))
crash_rn <- crash_rn %>%
  mutate(ESTADO=ifelse(CodigoCarretera=="PE-1N"&Progresiva>=0&Progresiva<=12,"Otorgada-EMAPE-MML",ESTADO))

crash_rn <- crash_rn %>%
  mutate(ADMINISTRA=ifelse(CodigoCarretera=="PE-1S"&Progresiva>=0&Progresiva<=3.6,"Lima Expresa - Evitamiento",ADMINISTRA))
crash_rn <- crash_rn %>%
  mutate(ESTADO=ifelse(CodigoCarretera=="PE-1S"&Progresiva>=0&Progresiva<=3.6,"Otorgada-EMAPE-MML",ESTADO))


#B-Panamericana Sur - Rutas de Lima - progresivas: PE-1S 3.6 - 57

crash_rn <- crash_rn %>%
  mutate(ADMINISTRA=ifelse(CodigoCarretera=="PE-1S"&Progresiva>=3.6&Progresiva<=57,"Rutas de Lima - Panamericana Sur",ADMINISTRA))
crash_rn <- crash_rn %>%
  mutate(ESTADO=ifelse(CodigoCarretera=="PE-1S"&Progresiva>=3.6&Progresiva<=57,"Otorgada-EMAPE-MML",ESTADO))


#C-Ramiro Prialé - Rutas de Lima - progresivas: PE-22 0-29

crash_rn <- crash_rn %>%
  mutate(ADMINISTRA=ifelse(CodigoCarretera=="PE-22"&Progresiva>=0&Progresiva<=29,"Rutas de Lima - Ramiro Prialé",ADMINISTRA))
crash_rn <- crash_rn %>%
  mutate(ESTADO=ifelse(CodigoCarretera=="PE-22"&Progresiva>=0&Progresiva<=29,"Otorgada-EMAPE-MML",ESTADO))

#D-Panamericana Norte - Rutas de Lima - progresivas: PE-1N 12 - 43.8

crash_rn <- crash_rn %>%
  mutate(ADMINISTRA=ifelse(CodigoCarretera=="PE-1N"&Progresiva>=12&Progresiva<=43.8,"Rutas de Lima - Panamericana Norte",ADMINISTRA))
crash_rn <- crash_rn %>%
  mutate(ESTADO=ifelse(CodigoCarretera=="PE-1N"&Progresiva>=12&Progresiva<=43.8,"Otorgada-EMAPE-MML",ESTADO))

tm_shape(crash_rn[crash_rn$LM=="Sí",])+
  tm_dots(col="ADMINISTRA")

#NO CONCESIONADA EN LIMA METROPOLITANA
crash_rn[crash_rn$ADMINISTRA=="Por evaluar"&crash_rn$LM=="Sí",]$ADMINISTRA <- "No Concesionada - PVN"
```

## 3. Conclusión
Esta guía proporciona una orientación paso a paso para identificar si un punto geográfico (por ejemplo, siniestro de tránsito, eventos naturales, reportes de riesgo y otros) tiene ocurrencia sobre la RVN, RVD o RVV y un Código de Ruta específico. Asimismo, se brinda descripción detallada del etiquetado de progresiva y concesionaria a la cual corresponde. Es importante realizar una validación de los datos a través de la visualización y ajustar las etiquetas de acuerdo a criterios específicos que se determinen a partir del análisis y la realidad.
