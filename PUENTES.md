<a href="https://www.onsv.gob.pe/"><img align="right" height="100" src="index_images/logo-onsv.png" float="right" link> </a>


## Identificación de puentes peatonales y siniestralidad

### Exploración del Observatorio Nacional de Seguridad Vial (ONSV)

**Especialista responsable:** <br />
Patricia Illacanchi Guerra

## Introducción
En el presente documento, se ha identificado la localización de puentes peatonales a nivel nacional a partir de la exploración de mapas base de OpenStreetMap. Sobre esta base de datos, se han extraído las capas de interés y se ha realizado la verificación y limpieza de datos para obtener los puentes peatonales georreferenciados.

Asimismo, se han identificado los siniestros fatales que se han registrado en el radio de 400 metros próximos a los puentes peatonales identificados.

## Código desarrollado

- Extracción de información cruda de OpenStreetMap (OSM)

  Del catálogo de llaves, valores y atributos de OSM se han identificado las siguientes categorías de interés:
    
```
   (key = "bridge", value="yes")
  (key = "highway", value="footway")
  (key = "footway", value="!sidewalk")
  (key = "incline", value="!down")
  (key = "incline", value="!up")
  (key = "bicycle", value="!yes")
  (key = "crossing", value="!marked")
  (key = "crossing", value="!traffic_signals")
```

  Estas han sido extraídas considerando el área geográfica del territorio peruano
  
```
min_lon <- -81.237163; max_lon <- -68.616354
min_lat <- -18.333057; max_lat <- 0.081098

bbx <- rbind(x=c(min_lon,max_lon),y=c(min_lat,max_lat))
colnames(bbx) <- c("min","max")

#available tags
available_tags()

puentes <-opq(bbox = bbx ) %>%
  add_osm_feature(key = "bridge", value="yes")%>%
  add_osm_feature(key = "highway", value="footway")%>%
  add_osm_feature(key = "footway", value="!sidewalk")%>%
  add_osm_feature(key = "incline", value="!down")%>%
  add_osm_feature(key = "incline", value="!up")%>%
  add_osm_feature(key = "bicycle", value="!yes")%>%
  add_osm_feature(key = "crossing", value="!marked")%>%
  add_osm_feature(key = "crossing", value="!traffic_signals")%>%
  osmdata_sf()

```
  La visualización de los datos crudos de los puentes puede visualizarse en la siguiente imagen:
  
```
tm_shape(puentes$osm_lines) + 
  tm_lines(col="green",lwd=5)

```

- Exploración de información importada

  Se ha removido elementos de código fijo de OSM que escapan de los atributos que los puentes peatonales tienen. Asimismo, solo se ha seleccionado los puentes peatonales como líneas de trayectoría perpendicular a la vía mas no los componentes como rampas y escaleras. De este modo, se podrán definir las zonas de influencia de estos puentes de forma adecuada.

```
remover <- c(762115758,762115755,485696616,1191546450,1191546436,437359837,419809122,
  419809122,1151086064,907487941,758781462,315840124,315840126,1202939633,
  597140400,597140399,964042833,653486650,149300964,617462807,673974160,
  1148068678,674563158,126865902,126865908,392016588,653484336,439927976,
  126865908,1187727263,1187727264,1025080735,307750796,950238934,608506475,
  1155912489,788703190,239175097,420129862,420129866,420129870,420129873,
  992337975,992337973,1011612698,1010871483,949972237,192455900,195046261,
  293490029,1004594047,1204040904,1204040902,1204040903,1204040901,
  1201176905,1177161397,1152291907,1152291910,1152453996,437195689,
  437191063,1152248628,655265152,1152259005,1152259003,1152264370,1152264371,
  655113515,1152266473,435207754,655112675,435212483,435212487,397557518,
  440690617,655110325,655110322,397556543,1149004841,655109082,1150551121,
  39412326,655108636,1146112625,1146112622,440690617,449587870,1146112605,
  1146124184,35557441,1110169195,1110169202,770067803,438490974,1091993752,
  304549855,1093501430,299598925,651596659,1049714277,1049714278,1054796612,
  1197181727,1034697324,1034697322,1007426245,413475777,935228646,935228643,
  1190443814,1190443126,1190436478,1029895115,1190660416,1148324858,617257907,
  617257908,617257905,617277923,617257905,617257912,617257908,617257912)
  
df <- df[!(df$osm_id %in% remover),]
```

>  Nota: Los identificadores presentados anteriormente son estáticos e identificables a través de OpenStreetMat, a menos que sean actualizados. 
             
- Definición de Zonas de Influencia de los Puentes Peatonales

  A partir de la revisión de estudios, se ha identificado que los puentes peatonales pueden tener influencia en las personas en una proximidad de 400 metros. Por ello, se han definido buffers a una proximidad de 400 metros

```
df <- st_simplify(df,dTolerance =1000)
 
puentes_buffered <- st_buffer(df,dist = 400,endCapStyle = "FLAT")
```                              

- Identificación de siniestros fatales de clase atropello

  Los datos georreferenciados de siniestros fatales del año 2023 vienen siendo actualizados a través del Sistema de Registro de Siniestros de Tránsito (SRAT). Con fecha de cierre de julio de 2023, se dispone de 5548 siniestros fatales a nivel nacional como datos de entrada. Estos registro corresponden a la base de datos histórica del ONSV recopilada desde el 2021. 

Para fines de este análisis sobre puentes peatonales, se han seleccionado a los siniestros fatales de clase atropello y atropello/fuga porque involucran al peatón como víctima. Del mismo modo, los puentes peatonales tienen un rol crucial en la prevención de esta clase específica de siniestros fatales.

- Selección de atropellos en Zona de Influencia de Puentes Peatonales

  Como resultado de este análisis, se ha detectado que 119 de los 1570 atropellos registrados entre 2021 y julio de 2023, alrededor de 8%, han ocurrido en zonas de influencia de los puentes peatonales. Esta cifra no debería indicarnos que la causa principal del siniestro fue la imprudencia del peatón al no usar los puentes peatonales próximos. Por el contrario, esto debería motivar a estudiar a detalle las condiciones actuales en las que están implementados hoy los puentes peatonales y las razones por las que no son usados. De este modo, la recuperación y planificación de la infraestructura deben incorporar elementos de seguridad y accesibiliad universal para el cruce peatonal como prioridad de la movilidad sostenible.

  ```     
      crash_pp <- st_intersection(puentes_buffered,atropellos)
      
      crash_countpp <-  as.data.frame(count(crash_pp$osm_id))
      colnames(crash_countpp) <- c("osm_id","Atropellos en PP")
      
      df <- merge(df, crash_countpp, by="osm_id", all.x=TRUE)
      puentes_buffered <-  merge(puentes_buffered, crash_countpp, by="osm_id", all.x=TRUE)

      #marcar los siniestros en las zonas de puentes peatonales
      lista_atrop_pp <- crash_pp$XUFeffCodigoAccidente

      atropellos <- atropellos%>%
        mutate(EnPuentePeatonal=NA)

      atropellos[atropellos$XUFeffCodigoAccidente %in% lista_atrop_pp,]$EnPuentePeatonal <- "Sí"
  ```
  - Visualización de Puentes Peatonales en los que se registran víctimas fatales

```
##plotear los puentes peatonales que tienes 1 o + siniestros fatales
df$`Atropellos en PP`!=0
seleccion1 <- df[!is.na(df$`Atropellos en PP`),]
seleccion2 <- puentes_buffered[!is.na(puentes_buffered$`Atropellos en PP`),]

  tm_shape(seleccion2) + 
  tm_fill(col="lightblue",alpha = 0.7)+
  tm_shape(seleccion1) + 
  tm_lines(col="blue",lwd = 5)+
  tm_shape(crash_pp)+
  tm_dots(col="red",size=0.02)

```
