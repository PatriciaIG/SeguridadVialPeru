library(spatstat)
library(here)
library(sp)
library(rgeos)
library(maptools)
library(GISTools)
library(tmap)
library(sf)
library(geojson)
library(geojsonio)
library(tmaptools)
library(stringr)
library(fs)
library(tidyverse)
library(stringr)
library(raster)
library(janitor)
library(wesanderson)
library(lsa)
library(igraph)
library(reshape2)
library(dplyr)
library(plyr)
library(rgdal)
library(rgeos)
library(Polychrome)
library(deldir)
library(interp)
library(dendextend)
library(cluster)

tmap_mode("view")

#Loading geographical information
bond_dep <- st_read(here::here("Data", "Boundaries","Departamental","DEPARTAMENTOS.shp"))
bond_prov <- st_read(here::here("Data", "Boundaries","Provincial","PROVINCIAS.shp"))
bond_dist <- st_read(here::here("Data", "Boundaries","Distrital","DISTRITOS.shp"))

bond_dep <- bond_dep%>%
  st_transform(.,32717)

bond_prov <- bond_prov%>%
  st_transform(.,32717)

bond_dist <- bond_dist%>%
  st_transform(.,32717)

qtm(bond_dep)
qtm(bond_prov)
qtm(bond_dist)

#--------------
#Loading Red Nacional 2018 - Estadísticas MTC
rn2018 <- st_read(here::here("Data", "red_vial_nacional_dic18.shp"))

#Project the map
tmap_mode("view")
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 10) +
  tm_shape(rn2018) + 
  tm_lines(col="#3F888F", lwd=5)
#--------------


#--------------
#Loading Red Departamental 2018
rd2018 <- st_read(here::here("Data", "red_vial_departamental_dic18.shp"))

#Project the map
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 10) +
  tm_shape(rd2018) + 
  tm_lines(col="#3F888F", lwd=5)
#--------------

#--------------
#Loading Red Vecinal 2018
rv2018 <- st_read(here::here("Data", "red_vial_vecinal_dic18.shp"))

#Project the map
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 10) +
  tm_shape(rv2018) + 
  tm_lines(col="#3F888F", lwd=5)
#--------------

#--------------
#Loading Red Nacional 2019 - Caminos MTC
rn2019 <- st_read(here::here("Data", "RVN_Eje.shp"))
#Project the map
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 3) +
  tm_shape(rn2019) + 
  tm_lines(col="#00C5CD" ,lwd=5)

#--------------

#--------------
#Loading Red Nacional 2019 - Caminos MTC
rnprov <- st_read(here::here("Data", "Descarga Red Vial Nacional.shp"))
#Project the map
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 3) +
  tm_shape(rnprov) + 
  tm_lines(col="#015D52")

#--------------

#--------------
#Loading Puntos de Trayectoria Red NAcional 2019 - Caminos MTC
ptrn2019 <- st_read(here::here("Data", "RVN_Pt.shp"))
#Project the map
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 3) +
  tm_shape(ptrn2019) + 
  tm_dots(col="#E83845")

#--------------
#--------------


#Comparativo 2018 - 2019

pe5ni2019t <- ptrn2019%>%
  #dplyr::filter(str_detect(TRAYECTO, "^Emp. PE-1S"))%>%
  dplyr::filter(str_detect(COD_RUTA, "PE-5NI"))

pe5ni2019 <- rn2019%>%
  #dplyr::filter(str_detect(TRAYECTO, "^Emp. PE-1S"))%>%
  dplyr::filter(str_detect(cCodRuta, "PE-5NI"))

pe5ni2018 <- rn2018%>%
  #dplyr::filter(str_detect(TRAYECTO, "^Emp. PE-1S"))%>%
  dplyr::filter(str_detect(CODRUTA, "PE-5NI"))

pe5niprov <- rnprov%>%
  #dplyr::filter(str_detect(TRAYECTO, "^Emp. PE-1S"))%>%
  dplyr::filter(str_detect(cCodRuta, "PE-5NI"))

tmap_mode("view")
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 3) +
  tm_shape(pe5niprov) + #verde
  tm_lines(col="#009B7D",lwd = 8)+
  tm_shape(pe5ni2019) + #turquesa
  tm_lines(col="#00C5CD",lwd = 8)+
  tm_shape(pe5ni2018) + #rojo
  tm_lines(col="#E83845",lwd = 8)+
  tm_shape(pe5ni2019t) + #negro
  tm_dots(col="#222244", size = 0.5)+
  tm_layout(legend.show = TRUE)

#--------------

#--------------
#Loading Red Concesionada - Provias
rnconc <- st_read(here::here("Data", "Concesiones", "Concesiones.shp"))%>%
  st_transform(.,32717)

#Project the map
tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rnconc) + 
  tm_lines(col="ADMINISTRA", lwd=4)




#--------------


#-------------- LEER DATA DE SINIESTROS 2021 - 2022 al 08FEBRERO22

#Puntos creados

crash <- read.csv(here::here("Data", "siniestros2021-2022.csv"), na="NA",
                  header=TRUE,sep=";", encoding = "utf-8")

class(crash)


#Nombre y clase de columnas

crash <- crash %>%
  #here the ., means all data
  clean_names(., case="big_camel")

col_class_crash <- crash %>% 
  summarise_all(class) %>%
  pivot_longer(everything(), 
               names_to="All_variables", 
               values_to="Variable_class")

summary(crash)

crash%>%
  colnames()%>%
  # just look at the head, top5
  head(10)

crash <- st_as_sf(crash,coords =c("CoordenadasUtmEsteLongitud","CoordenadasNorteLatitud"), crs=4326)


crash <- crash %>%
  mutate(x=unlist(map(crash$geometry,1)),
         y=unlist(map(crash$geometry,2)))

crash <- crash %>%
  st_transform(.,32717)

crash_sp <- as(crash,Class = "Spatial")

tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 3) +
  tm_shape(crash) + 
  tm_dots(col="#b91655",size = 0.02)

#-------------- LEER DATA DE SINIESTROS 2021 - 2022 al 08FEBRERO2

#-------------- CAPA DE SINIESTROS FATALES

crash_fat <- crash %>%
  dplyr::filter(str_detect(Tipo, "^FATAL"))

crash_fat_sp <- as(crash_fat,Class = "Spatial")

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rn2019) + 
  tm_lines(col="#222244",lwd = 1) +
  tm_shape(crash_fat) + 
  tm_dots(col="#b91655",size = 0.01)

#-------------- CAPA DE SINIESTROS FATALES



#-------------- CAPA DE SINIESTROS FATALES EN RED NACIONAL

crash_rn <- crash_fat %>%
  dplyr::filter(str_detect(EstaEnRn, "red nacional"))


#mapa Red vial nacional + siniestros en esa red vial
tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rn2018) + 
  tm_lines(col="#222244",lwd = 1) +
  tm_shape(crash_rn) + 
  tm_dots(col="red",size = 0.01)


##----modificar los que están fuera
CodigoAccidente <- c("A-2021-05-172","A-2021-05-325","A-2021-12-79","A-2021-05-325","A-2021-06-299","A-2021-06-203","A-2021-05-277","A-2021-04-175","A-2021-07-259","A-2021-06-251","A-2021-03-299","A-2021-12-224","A-2021-09-156","A-2021-08-54","A-2021-04-161","A-2021-04-195","A-2021-05-211","A-2021-06-179","A-2021-06-312","A-2021-04-116","A-2021-04-145","A-2021-04-202","A-2021-06-214","A-2021-06-131","A-2021-02-156","A-2021-05-37","A-2021-09-45","A-2021-06-163","A-2021-06-312","A-2021-06-229","A-2021-01-60","A-2021-02-104","A-2021-05-41","A-2021-06-222","A-2021-04-182","A-2021-06-23","A-2021-06-13","A-2021-09-45","A-2021-06-163","A-2021-05-92","A-2021-04-145","A-2021-04-202","A-2021-06-214","A-2021-06-131","A-2021-05-122")

crash_ver <- crash[crash$CodigoAccidente %in% CodigoAccidente,]

filtro <- unique(crash_ver$Provincia)
rd2018_opt <- rd2018%>%
  dplyr::filter(str_detect(PROVINCIA, paste(filtro, collapse = "|")))

rv2018_opt <- rv2018%>%
  dplyr::filter(str_detect(PROVINCIA, paste(filtro, collapse = "|")))
##----modificar los que están fuera

#-------------- CAPA DE SINIESTROS EN RED NACIONAL


#-------------- CAPA DE SINIESTROS EN RED DEPARTAMENTAL, VECINAL Y LOCAL
crash_urbano <- crash_fat %>%
  dplyr::filter(str_detect(EstaEnRn, "red departamental|red vecinal|otro tipo de vía"))

crash_urbano <- st_join(crash_urbano,bond_dist, left=F)

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(bond_prov) + 
  tm_borders(col="gray", lwd=1) +
  tm_shape(crash_urbano) + 
  tm_dots(col="red",size = 0.01)



tm_shape(bond_prov) + 
  tm_borders(col="black", lwd=2)+
  tm_shape(bond_prov) + 
  tm_fill(col="gray", alpha = 0.2)+
  tm_shape(crash_fat) + 
  tm_dots(col="red",size = 0.04)


write.table(crash_distritos, "siniestros_distrito.csv",sep = ";")

#-------------- APA DE SINIESTROS EN RED DEPARTAMENTAL, VECINAL Y LOCAL



#-------------- CAPA DE SINIESTROS FATALES EN RED NACIONAL

crash_rn <- crash_fat %>%
  dplyr::filter(str_detect(EstaEnRn, "red nacional"))

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rn2019) + 
  tm_lines(col="#222244",lwd = 1) +
  tm_shape(crash_rn) + 
  tm_dots(col="red",size = 0.01)

tm_shape(bond_prov) + 
  tm_borders(col="black", lwd=2)+
  tm_shape(bond_prov) + 
  tm_fill(col="gray", alpha = 0.2)+
  tm_shape(crash_fat) + 
  tm_dots(col="red",size = 0.04)


##----modificar los que están fuera
CodigoAccidente <- c("A-2021-05-172","A-2021-05-325","A-2021-12-79","A-2021-05-325","A-2021-06-299","A-2021-06-203","A-2021-05-277","A-2021-04-175","A-2021-07-259","A-2021-06-251","A-2021-03-299","A-2021-12-224","A-2021-09-156","A-2021-08-54","A-2021-04-161","A-2021-04-195","A-2021-05-211","A-2021-06-179","A-2021-06-312","A-2021-04-116","A-2021-04-145","A-2021-04-202","A-2021-06-214","A-2021-06-131","A-2021-02-156","A-2021-05-37","A-2021-09-45","A-2021-06-163","A-2021-06-312","A-2021-06-229","A-2021-01-60","A-2021-02-104","A-2021-05-41","A-2021-06-222","A-2021-04-182","A-2021-06-23","A-2021-06-13","A-2021-09-45","A-2021-06-163","A-2021-05-92","A-2021-04-145","A-2021-04-202","A-2021-06-214","A-2021-06-131","A-2021-05-122")

crash_ver <- crash[crash$CodigoAccidente %in% CodigoAccidente,]
  
filtro <- unique(crash_ver$Provincia)
rd2018_opt <- rd2018%>%
  dplyr::filter(str_detect(PROVINCIA, paste(filtro, collapse = "|")))

rv2018_opt <- rv2018%>%
  dplyr::filter(str_detect(PROVINCIA, paste(filtro, collapse = "|")))
##----modificar los que están fuera

#-------------- CAPA DE SINIESTROS EN RED NACIONAL

#-------------- CAPA DE SINIESTROS EN RED VECINAL Y LOCAL
crash_distritos <- crash %>%
  dplyr::filter(str_detect(EstaEnRn, "red vecinal|otro tipo de vía"))

crash_distritos <- st_join(crash_distritos,bond_dist, left=F)

tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(rn2018) + 
  #tm_lines(col="#222244",lwd = 1) +
  tm_shape(crash_distritos) + 
  tm_dots(col="red")

write.table(crash_distritos, "siniestros_distrito.csv",sep = ";")

#-------------- CAPA DE SINIESTROS EN RED VECINAL Y LOCAL

#-------------- LEER DATA DE SINIESTROS PARA IDENTIFICAR CODRUTA

#Puntos creados

crash_val <- read.csv(here::here("Data", "nuria-validacion.csv"), na="NA",
                  header=TRUE,sep=";", encoding = "utf-8")

class(crash_val)



#Nombre y clase de columnas

crash_val <- crash_val %>%
  #here the ., means all data
  clean_names(., case="big_camel")

crash_val %>% 
  summarise_all(class) %>%
  pivot_longer(everything(), 
               names_to="All_variables", 
               values_to="Variable_class")

summary(crash_val)

crash_val%>%
  colnames()%>%
  # just look at the head, top5
  head(10)

crash_val <- st_as_sf(crash_val,coords =c("CoordenadasUtmEsteLongitud","CoordenadasNorteLatitud"), crs=4326)

crash_val_sp <- crash_val%>%
  st_transform(.,32717)
crash_val_sp <- as(crash_val_sp,Class = "Spatial")

#-------------- LEER DATA DE SINIESTROS PARA IDENTIFICAR CODRUTA


#-------------- CONVERTIR TIPO ESPACIAL REGIóN, RN y SINIESTROS PARA TESTEAR ANáLISIS

#Red Nacional
rn2019_sp <- rn2019 %>%
  st_transform(.,32717)
rn2019_sp <- st_zm(rn2019_sp, drop=T, what='ZM')
rn2019_sp <- as(rn2019_sp, Class="Spatial")

#Red Departamental
rd2018_sp <- rd2018 %>%
  st_transform(.,32717)
rd2018_sp <- as(rd2018_sp, Class="Spatial")

#Red Vecinal
rv2018_sp <- rv2018 %>%
  st_transform(.,32717)
rv2018_sp <- as(rv2018_sp, Class="Spatial")


#Siniestros 
crash_sp <- crash%>%
  st_transform(.,32717)
crash_sp <- as(crash_sp,Class = "Spatial")

#-------------- CONVERTIR TIPO ESPACIAL REGIóN, RN y SINIESTROS PARA TESTEAR ANáLISIS

#-------------- CALCULAR DISTANCIAS DE PROXIMIDAD A RN

##Buscar la intersección

filtro <- unique(crash_val_sp$Provincia)
rn2019_opt <- rn2019%>%
  dplyr::filter(str_detect(NOMBPROV, paste(filtro, collapse = "|")))

rn2019_opt_sp <- rn2019_opt %>%
  st_transform(.,32717)
rn2019_opt_sp <- st_zm(rn2019_opt_sp, drop=T, what='ZM')
rn2019_opt_sp <- as(rn2019_opt_sp, Class="Spatial")

## Set up containers for results
n <- nrow(crash_val_sp)
nearestCODRUTA <- character(n)
distToNearestCODRUTA <- numeric(n)

## For each crash, find name of nearest route (CODRUTA)  
for (i in seq_along(nearestCODRUTA)) {
  gDists <- gDistance(crash_val_sp[i,], rn2019_opt_sp[rn2019_opt_sp$NOMBPROV==crash_val_sp[i,]$Provincia,], byid=TRUE)
  if (length(gDists)==0) {
    nearestCODRUTA[i] <- ""
    distToNearestCODRUTA[i] <- 99999999999999999
  }else{
    nearestCODRUTA[i] <- rn2019_opt_sp[rn2019_opt_sp$NOMBPROV==crash_val_sp[i,]$Provincia,]$cCodRuta[which.min(gDists)]
    distToNearestCODRUTA[i] <- min(gDists)
  }
}

## Build array of results
results_rn <- list(nearestCODRUTA,distToNearestCODRUTA)
results_rn <- as.data.frame(results_rn, col.names= c("CODRUTA", "dist"))
summary(results_rn)

results_rn %>%
  count("dist")

##Unir con data de siniestros
crash_val <- cbind(crash_val, results_rn)


##Verificar distancias críticas 1. 40-50m correcto 2. 50-60m correcto 3. 30-40m incorrecto 4. 20-30m 
limite <- crash_val%>%
  dplyr::filter(dist>30 & dist<40)

##Plotear para definir la distancia límite o crítica

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rn2019_opt) + 
  tm_lines(col="black",lwd = 1)+
  tm_shape(limite) + 
  tm_dots(,
          size = 0.3,
          col = "red")

##Definir la distancia límite - actual 56 metros (el que cubra mayor parte de casos)

crash_val <- crash_val %>%
  mutate(CODRUTA=case_when(dist<=73~CODRUTA,
                              dist>73~""))%>%
  mutate(esta_en_rn=case_when(dist<=73~"red nacional",
                              dist>73~"otra red"))

##Modificar manualmente los que no cumplan con código de siniestros (procesar cuantas veces sea necesario)
modif <- c("A-2022-09-7","A-2022-07-126","A-2022-05-208","A-2022-08-184")

crash_val <- crash_val%>%
  mutate(CODRUTA=ifelse(ICaDigoAccidente %in% modif,"",CODRUTA))%>%
  mutate(esta_en_rn=ifelse(ICaDigoAccidente %in% modif,"otra red",esta_en_rn))
           
modif <- c("A-2022-03-122","A-2022-07-199")

crash_val <- crash_val%>%
  mutate(CODRUTA=ifelse(ICaDigoAccidente %in% modif,"PE-1N",CODRUTA))%>%
  mutate(esta_en_rn=ifelse(ICaDigoAccidente %in% modif,"red nacional",esta_en_rn))


crash_val_rn <- crash_val%>%
  dplyr::filter(str_detect(esta_en_rn, "red nacional"))

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rn2019_opt) + 
  tm_lines(col="black",lwd = 1)+
  tm_shape(crash_val_rn) + 
  tm_dots(,
          size = 0.1,
          col = "red")

#-------------- CALCULAR DISTANCIAS DE PROXIMIDAD A RN


#-------------- CALCULAR DISTANCIAS DE PROXIMIDAD A RDepartamental 

##Seleccionar siniestros que no estén en red nacional

crash_val_rd <- crash_val%>%
  dplyr::filter(str_detect(esta_en_rn, "otra red"))

crash_val_rd <-crash_val_rd[ , !names(crash_val_rd) %in% c("CODRUTA","dist","esta_en_rn")]

filtro <- unique(crash_val_rd$Provincia)
rd2018_opt <- rd2018%>%
  dplyr::filter(str_detect(PROVINCIA, paste(filtro, collapse = "|")))

#Siniestros 
crash_val_rd_sp <- crash_val_rd%>%
  st_transform(.,32717)
crash_val_rd_sp <- as(crash_val_rd_sp,Class = "Spatial")

#Red vial optimizada
rd2018_opt_sp <- rd2018_opt %>%
  st_transform(.,32717)
rd2018_opt_sp <- as(rd2018_opt_sp, Class="Spatial")


##Buscar la intersección

## Set up containers for results
n <- nrow(crash_val_rd_sp)
nearestCODRUTA <- character(n)
distToNearestCODRUTA <- numeric(n)

## For each crash, find name of nearest route (CODRUTA) 14:18 - 14:25
for (i in seq_along(nearestCODRUTA)) {
  gDists <- gDistance(crash_val_rd_sp[i,], rd2018_opt_sp[rd2018_opt_sp$PROVINCIA==crash_val_rd_sp[i,]$Provincia,], byid=TRUE)
  if (length(gDists)==0) {
    nearestCODRUTA[i] <- ""
    distToNearestCODRUTA[i] <- 99999999999999999
  }else{
    nearestCODRUTA[i] <- rd2018_opt_sp[rd2018_opt_sp$PROVINCIA==crash_val_rd_sp[i,]$Provincia,]$CODRUTA[which.min(gDists)]
    distToNearestCODRUTA[i] <- min(gDists)
  }
}


## Build array of results
results_rd <- list(nearestCODRUTA,distToNearestCODRUTA)
results_rd <- as.data.frame(results_rd, col.names= c("CODRUTA", "dist"))
summary(results_rd)

results_rd %>%
  count("dist")

##Unir con data de siniestros
crash_val_rd <- cbind(crash_val_rd, results_rd)


##Verificar distancias críticas 1. 30-400m 
limite <- crash_val_rd%>%
  dplyr::filter(dist>0 & dist<70)


##Plotear para definir la distancia límite o crítica

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rd2018_opt) + 
  tm_lines(col="black",lwd = 1)+
  tm_shape(limite) + 
  tm_dots(,
          size = 0.05,
          col = "red")

##Definir la distancia límite - actual 30 metros
crash_val_rd <- crash_val_rd %>%
  mutate(CODRUTA=case_when(dist<=70~CODRUTA,
                              dist>70~""))%>%
  mutate(esta_en_rn=case_when(dist<=70~"red departamental",
                              dist>70~"otra red"))

##Modificar manualmente los que no cumplan con código de siniestros (procesar cuantas veces sea necesario)
modif <- c("A-2022-11-30")

crash_val_rd <- crash_val_rd%>%
  mutate(CODRUTA=ifelse(ICaDigoAccidente %in% modif,"",CODRUTA))%>%
  mutate(esta_en_rn=ifelse(ICaDigoAccidente %in% modif,"otra red",esta_en_rn))


#VERIFICAR 1: EL ANáLISIS CONSIDERO TODA LA RED VIAL OPTIMIZADA
tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rd2018_opt) + 
  tm_lines(col="black",lwd = 2)+
  tm_shape(crash_val_rd) + 
  tm_dots(,
          size = 0.03,
          col = "red")

#SI VERIFICAR 1 ESTA OK:

crash1 <- crash_val_rd
  
crash_val_rd <- crash_val_rd%>%
  dplyr::filter(str_detect(esta_en_rn, "red departamental"))

#VERIFICAR 2:VISUALIZACION FINAL
tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rd2018_opt) + 
  tm_lines(col="black",lwd = 2)+
  tm_shape(crash_val_rd) + 
  tm_dots(,
          size = 0.1,
          col = "red")

#-------------- CALCULAR DISTANCIAS DE PROXIMIDAD A Red departamental

#-------------- CALCULAR DISTANCIAS DE PROXIMIDAD A RVecinal

##Seleccionar siniestros que no estén en red nacional

crash_val_rv <- crash1%>%
  dplyr::filter(str_detect(esta_en_rn, "otra red"))

crash_val_rv <-crash_val_rv[ , !names(crash_val_rv) %in% c("CODRUTA","dist","esta_en_rn")]

filtro <- unique(crash_val_rv$Provincia)
rv2018_opt <- rv2018%>%
  dplyr::filter(str_detect(PROVINCIA, paste(filtro, collapse = "|")))

#Siniestros 
crash_val_rv_sp <- crash_val_rv%>%
  st_transform(.,32717)
crash_val_rv_sp <- as(crash_val_rv_sp,Class = "Spatial")

#Red vial optimizada
rv2018_opt_sp <- rv2018_opt %>%
  st_transform(.,32717)
rv2018_opt_sp <- as(rv2018_opt_sp, Class="Spatial")


##Buscar la intersección

## Set up containers for results
n <- nrow(crash_val_rv_sp)
nearestCODRUTA <- character(n)
distToNearestCODRUTA <- numeric(n)

## For each crash, find name of nearest route (CODRUTA) 22:36

for (i in seq_along(nearestCODRUTA)) {
  gDists <- gDistance(crash_val_rv_sp[i,], rv2018_opt_sp[rv2018_opt_sp$PROVINCIA==crash_val_rv_sp[i,]$Provincia,], byid=TRUE)
  if (length(gDists)==0) {
    nearestCODRUTA[i] <- ""
    distToNearestCODRUTA[i] <- 99999999999999999
  }else{
    nearestCODRUTA[i] <- rv2018_opt_sp[rv2018_opt_sp$PROVINCIA==crash_val_rv_sp[i,]$Provincia,]$CODRUTA[which.min(gDists)]
    distToNearestCODRUTA[i] <- min(gDists)
  }
}

## Build array of results
results_rv <- list(nearestCODRUTA,distToNearestCODRUTA)
results_rv <- as.data.frame(results_rv, col.names= c("CODRUTA", "dist"))
summary(results_rv)

results_rv %>%
  count("dist")

##Unir con data de siniestros
crash_val_rv <- cbind(crash_val_rv, results_rv)


##aqui
##Verificar distancias críticas 1. 50-100m
limite <- crash_val_rv%>%
  dplyr::filter(dist>0 & dist<74)


##Plotear para definir la distancia límite o crítica

tm_basemap(leaflet::providers$OpenStreetMap)+
 tm_shape(rv2018_opt) + 
 tm_lines(col="black",lwd = 1)+
  tm_shape(limite) + 
  tm_dots(,
          size = 0.3,
          col = "red")

##Definir la distancia límite - actual 30 metros
crash_val_rv <- crash_val_rv %>%
  mutate(CODRUTA=case_when(dist<=74~CODRUTA,
                           dist>74~""))%>%
  mutate(esta_en_rn=case_when(dist<=74~"red vecinal",
                              dist>74~"otro tipo de vía"))

##OPCIONAL
##Modificar manualmente los que no cumplan con código de siniestros (procesar cuantas veces sea necesario)
modif <- c("A-2022-04-14")

crash_val_rv <- crash_val_rv%>%
  mutate(CODRUTA=ifelse(CodigoAccidente %in% modif,"PE-30B",CODRUTA))%>%
  mutate(esta_en_rn=ifelse(CodigoAccidente %in% modif,"red nacional",esta_en_rn))

modif <- c("A-2022-05-26","A-2022-08-30")

crash_val_rv <- crash_val_rv%>%
  mutate(CODRUTA=ifelse(CodigoAccidente %in% modif,"PE-1N",CODRUTA))%>%
  mutate(esta_en_rn=ifelse(CodigoAccidente %in% modif,"red nacional",esta_en_rn))

modif <- c("A-2022-01-35")

crash_val_rv <- crash_val_rv%>%
  mutate(CODRUTA=ifelse(CodigoAccidente %in% modif,"PE-5N",CODRUTA))%>%
  mutate(esta_en_rn=ifelse(CodigoAccidente %in% modif,"red nacional",esta_en_rn))


#Verificar

verificar <- crash_val_rv%>%
  dplyr::filter(str_detect(CodCarretera, "PE"))

tm_basemap(leaflet::providers$OpenStreetMap)+
  #se cuelga si se plotea la rvv
  #tm_shape(rv2018) + 
  #tm_lines(col="black",lwd = 5)+
  tm_shape(rn2019) + 
  tm_lines(col="black",lwd = 5)+
  tm_shape(verificar) + 
  tm_dots(,
          size = 0.1,
          col = "red")

#-------------- CALCULAR DISTANCIAS DE PROXIMIDAD A Red Vecinal

#-------------- SELECCIONAR UN SINIESTRO ESPECIFICO
roi <- rv2018%>%
  dplyr::filter(str_detect(DEPARTAMEN, "LA LIBERTAD"))

poi <- crash_val%>%
  dplyr::filter(str_detect(ICaDigoAccidente, "A-2022-11-67"))

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rd2018_opt) + 
  tm_lines(col="blue",lwd = 1.5, legend.col.is.portrait = TRUE)+
  tm_shape(poi) + 
  tm_dots(
    size = 0.25,
    col = "red",
  )
#-------------- SELECCIONAR UN SINIESTRO ESPECIFICO
##PENDIENTE: REETIQUETAR LAS REDES VIALES SEGúN PROVINCIA ADECUADAMENTE
#MIENTRAS TANTO PLOTEAR QUE TODOS LOS PUNTOS ANTES DEL ANALISIS ESTEN DENTRO DEL TRAZO OPTIMIZADO

verificar <- crash_rv%>%
  dplyr::filter(str_detect(CODRUTA, "R$"))%>%
  dplyr::filter(str_detect(PROVINCIA, "PAUCARTAMBO|LA CONVENCION|CUSCO|QUISPICANCHI|CANCHIS|SAN ROMAN|CHUCUITO|PUNO"))

#-------------- JUNTAR LOS 3 DATASETS DETECTADOS POR RED NACIONAL, DEPARTAMENTAL Y VECINAL

crash_tipo_via <- rbind(crash_val_rn, crash_val_rd,crash_val_rv)

write.csv2(crash_tipo_via, "resultados_feb2023_2.csv")

#-------------- JUNTAR LOS 3 DATASETS DETECTADOS POR RED NACIONAL, DEPARTAMENTAL Y VECINAL



###-----------------------FIN




#------------------------------------------------------- CREAR PUNTOS DE INTERES



#Puntos creados

set_points  <-  data.frame(Ubicación = c("Anexo Uchupampa","Anexo San Jerónimo"))
sfc = st_sfc(st_point(c( -76.121686,-12.937398)), st_point(c( -76.165369,-13.007176)))
st_geometry(sfc)

st_geometry(set_points) <- sfc
st_crs(set_points) = 4326
class(set_points)

#Plot seggregated road and points
tmap_mode("view")

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(pe24) + 
  tm_lines(col="CODRUTA",palette="#0e2f44",lwd = 3, legend.col.is.portrait = TRUE)+
  tm_shape(set_points) + 
  tm_dots(
    size = 0.25,
    col = "Ubicación",
    palette = "Spectral",
    legend.show = TRUE)


#------------------------------------------------------- CREAR PUNTOS DE INTERES

#------------------------------------------------------- CARGAR COLEGIOS

#Loading Colegios de Minedu actualizado a 02/2020
coles <- st_read(here::here("Data", "IE_P.shp"))
coles <- coles %>%
  st_transform(.,32717)


##Definir provincias y distritos críticos

provincias <- bond_prov%>%
  dplyr::filter(str_detect(DEPARTAMEN, "CUSCO|PUNO"))%>%
  dplyr::filter(str_detect(PROVINCIA, "PAUCARTAMBO|LA CONVENCION|CUSCO|QUISPICANCHI|CANCHIS|SAN ROMAN|CHUCUITO|PUNO"))
 
distritos <- bond_dist%>%
  dplyr::filter(str_detect(DEPARTAMEN, "LIMA|CALLAO"))%>%
  dplyr::filter(str_detect(DISTRITO, "SAN MARTIN DE PORRES|COMAS|VILLA EL SALVADOR|SAN JUAN DE LURIGANCHO|LURIN|LOS OLIVOS|CALLAO|VENTANILLA"))


tm_shape(provincias) + 
  tm_borders(col="#222244",lwd = 3)+
  tm_shape(distritos) + 
  tm_borders(col="#222244",lwd = 3)
  
#------------------------------------------------------- CARGAR COLEGIOS
  
  

#------------------------------------------------------- ANALISIS ESTADISTICO POR RUTA


##Número de siniestros y fallecidos por código de ruta

rn_grupos <- validacion %>%
  group_by(CODRUTA.28.02) %>%
  summarise(siniestros=n(),
            fallecidos=sum(CantidadDeFallecidos),
            lesionados=sum(CantidadDeLesionados),
            peatones=sum(NumeroDePeatones))

## Ordenar según rutas más críticas

## Plotear las 15 rutas más críticas según total de siniestros,
#fallecidos, lesionados y peatones afectados

rn_grupos <- rn_grupos[order(-rn_grupos$siniestros),]

ggplot(rn_grupos[c(1:15),], aes(x = reorder(CODRUTA.28.02,-siniestros),y = siniestros, fill = CODRUTA.28.02,palette="RdBu")) +
  geom_bar(stat = "identity") +
  labs(title = "Distribución de las 15 RN con más siniestros 2021") +
  geom_text(aes(label = CODRUTA.28.02, y = siniestros),
            position = position_dodge(0.9), vjust = -1 )



rn_grupos <- rn_grupos[order(-rn_grupos$fallecidos),]

ggplot(rn_grupos[c(1:15),], aes(x = CODRUTA,y = fallecidos, fill = CODRUTA)) +
  geom_bar(stat = "identity") +
  labs(title = "Distribución de las 15 RN con más fallecidos 2021") +
  geom_text(aes(label = CODRUTA, y = fallecidos),
            position = position_dodge(0.9), vjust = -1 )



rn_grupos <- rn_grupos[order(-rn_grupos$lesionados),]

ggplot(rn_grupos[c(1:15),], aes(x = CODRUTA,y = lesionados, fill = CODRUTA)) +
  geom_bar(stat = "identity") +
  labs(title = "Distribución de las 15 RN con más lesionados 2021") +
  geom_text(aes(label = CODRUTA, y = lesionados),
            position = position_dodge(0.9), vjust = -1 )


rn_grupos <- rn_grupos[order(-rn_grupos$peatones),]

ggplot(rn_grupos[c(1:15),], aes(x = CODRUTA,y = peatones, fill = CODRUTA)) +
  geom_bar(stat = "identity") +
  labs(title = "Distribución de las 15 RN con más peatones 2021") +
  geom_text(aes(label = CODRUTA, y = peatones),
            position = position_dodge(0.9), vjust = -1 )


## Plotear las 15 rutas más críticas ponderando la longitud del tramo

##Calcular la longitud de cada RN. En total según el registro hay 28.856km

rn2018 <- st_as_sf(rn2018)

rn_long <- rn2018 %>%
  group_by(CODRUTA) %>%
  summarise(longitud=sum(LONGITUD))

##Cálculo de siniestros y fallecidos por km de vía
getPalette <- colorRampPalette(brewer.pal(9, "RdYlBu"))
colourCount <- 15

rn_grupos <- merge(as.data.frame(rn_grupos),as.data.frame(rn_long), by="CODRUTA")

rn_grupos <- rn_grupos %>%
  mutate(sinies_km=siniestros/longitud,
         fallec_km=fallecidos/longitud,
         lesion_km=lesionados/longitud,
         peaton_km=peatones/longitud)

## Ordenar según rutas más críticas de acuerdo a índice

rn_grupos <- rn_grupos[order(-rn_grupos$sinies_km),]

ggplot(rn_grupos[c(1:15),], aes(x = CODRUTA,y = sinies_km, fill = CODRUTA)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values=getPalette(colourCount))+
  labs(title = "Distribución de las 15 RN con mayor índice de siniestros por km 2021") +
  geom_text(aes(label = CODRUTA, y = sinies_km),
            position = position_dodge(0.9), vjust = -1 )



rn_grupos <- rn_grupos[order(-rn_grupos$fallec_km),]

ggplot(rn_grupos[c(1:15),], aes(x = CODRUTA,y = fallec_km, fill = CODRUTA)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values=getPalette(colourCount))+
  labs(title = "Distribución de las 15 RN con mayor índice de fallecidos por km 2021") +
  geom_text(aes(label = CODRUTA, y = fallec_km),
            position = position_dodge(0.9), vjust = -1 )



rn_grupos <- rn_grupos[order(-rn_grupos$lesion_km),]

ggplot(rn_grupos[c(1:15),], aes(x = CODRUTA,y = lesion_km, fill = CODRUTA,)) +
  geom_bar(stat = "identity") +
  #scale_fill_brewer(palette = "RdYlBu")+
  scale_fill_manual(values=getPalette(colourCount))+
  labs(title = "Distribución de las 15 RN con mayor índice de lesionados por km 2021") +
  geom_text(aes(label = CODRUTA, y = lesion_km),
            position = position_dodge(0.9), vjust = -1 )


rn_grupos <- rn_grupos[order(-rn_grupos$peaton_km),]

ggplot(rn_grupos[c(1:15),], aes(x = CODRUTA,y = peaton_km, fill = CODRUTA,)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values=getPalette(colourCount))+
  labs(title = "Distribución de las 15 RN con mayor índice de peatones afectados por km 2021") +
  geom_text(aes(label = CODRUTA, y = peaton_km),
            position = position_dodge(0.9), vjust = -1 )

#------------------------------------------------------- ANALISIS ESTADISTICO POR RUTA



pe22 <- rn2018%>%
  #dplyr::filter(str_detect(TRAYECTO, "^Emp. PE-1S"))%>%
  dplyr::filter(str_detect(CODRUTA, "PE-22$"))%>%
  dplyr::filter(INICIO>40)%>%
  dplyr::filter(FIN<160)

pe3s <- rn2018%>%
  #dplyr::filter(str_detect(TRAYECTO, "^Emp. PE-1S"))%>%
  dplyr::filter(str_detect(CODRUTA, "PE-3S$"))%>%
  dplyr::filter(INICIO>0)%>%
  dplyr::filter(FIN<32)

tmap_mode("view")

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(pe22) + 
  tm_lines(col="CODRUTA",palette="#0e2f44",lwd = 3, legend.col.is.portrait = TRUE)+
  tm_shape(crash) + 
  tm_dots(
    size = 0.25,
    col = "red",
    )

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(pe3s) + 
  tm_lines(col="CODRUTA",palette="blue",lwd = 3, legend.col.is.portrait = TRUE)+
  tm_shape(crash) + 
  tm_dots(
    size = 0.25,
    col = "red",
  )


##SELECCIONAR UN SINIESTRO ESPECIFICO
roi <- rv2018%>%
  dplyr::filter(str_detect(DEPARTAMEN, "LA LIBERTAD"))

poi <- crash_tipo_via%>%
  dplyr::filter(str_detect(CodigoAccidente, "A-2022-02-257"))

tm_basemap(leaflet::providers$OpenStreetMap)+
  tm_shape(rn2019) + 
  tm_lines(col="blue",lwd = 3, legend.col.is.portrait = TRUE)+
  tm_shape(poi) + 
  tm_dots(
    size = 0.25,
    col = "red",
  )



## RED VIAL NACIONAL SEGMENTADA POR CONCESION

#--------------
#Loading Mapa de PVN
pvn_webmap <- st_read(here::here("Data","PVN", "Asfaltado.shp"))

pvn_webmap[pvn_webmap[,14]=="RNT",]

#Project the map
tmap_mode("view")
tm_basemap(leaflet::providers$OpenStreetMap)+
  #tm_shape(bond_prov_prin) + 
  #tm_borders(col="#222244",lwd = 10) +
  tm_shape(pvn_webmap) + 
  tm_lines(col="#3F888F", lwd=5)
#--------------

##################   NUEVO PROYECTO ################## RED VIAL CONCESIONADA

# 1. Importar geopackage provisto por provías

library(httr)

url <-parse_url("https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/PROVIAS/MTC_CarreterasConcesiones")
request <- build_url(url)
rn_conc <- st_read(request)

##################   NUEVO PROYECTO ##################



##################   NUEVO ESTUDIO ################## CLUSTER SINIESTROS FATALES

#--------------TOTAL: TRAMOS DE CONCENTRACIóN DE SINIESTROS

library(RColorBrewer)
# Define the number of colors you want
nb.cols <- 40
mycolors <- colorRampPalette(brewer.pal(20, "Spectral"))(nb.cols)

duplicados <- c("A-2022-04-174","A-2022-05-177","A-2022-06-122","A-2022-07-117","A-2022-02-264","A-2022-02-266")




crash_rn <- crash_rn[!crash_rn$CodigoAccidente %in% duplicados,]
crash_rn_sp <- as(crash_rn,Class = "Spatial")
crash_urbano_sp <- as(crash_urbano,Class = "Spatial")

crash_rn <- crash_rn[!crash_rn$CodigoAccidente %in% c("A-2021-04-142","A-2021-03-167"),]

#aqui

tmap_style("white")

# 1. Open jpeg file
jpeg("rplot.jpg",quality = 100)

# 2. Develop plot

tm_shape(bond_dep)+
  tm_fill("gray",alpha=0.2)+
  tm_borders(alpha = 0.6,col = 'white', lwd = 2)+
  tm_shape(rn2018[!rn2018$SUPERFIC_L=="Proyectado",]) + 
  tm_lines(col="#636363", lwd=0.5, alpha=0.6) +
  tm_shape(crash_rn) + 
  tm_dots(col="#B90E0A",size = 0.1,alpha=0.5)+
  tm_compass(type="8star", size = 2,position = c("left", "bottom")) +
  tm_scale_bar(width = 0.35,position = c("left", "bottom")) 

# 3. Close the file
dev.off()

#first extract the points from the spatial points data frame
crashPoints <- crash_rn_sp %>%
  coordinates(.)%>%
  as.data.frame()

#k-distance-graph
crashPoints%>%
  dbscan::kNNdistplot(.,k=3)

#now run the dbscan analysis

dbclust <- crashPoints %>%
  fpc::dbscan(.,eps = 750, MinPts = 3)

#interactive
crash_rn<- crash_rn %>%
  mutate(cluster750=dbclust$cluster)

##Ver longitud de tramos de intervención
for (i in c(1:max(crash_rn$cluster750))) {
  print(max(st_distance(crash_rn[crash_rn$cluster750==i,])))
}

##Gráfico para definir el umbral
# Libraries
library(tidyverse)
library(hrbrthemes)
library(viridis)

# Dataset longitud de clusters por epsilon

data <- read.csv(here::here("Data", "longitud-clusters.csv"), na="NA",
                  header=TRUE,sep=";", encoding = "utf-8")

colnames(data) <- c("Epsilon","Longitud")

data$Epsilon <- as.character(data$Epsilon)
#ordenar etiquetas en gráfico
data$Epsilon <- factor(data$Epsilon , levels=c("50","100","150","200","250","300","350","400",
                                                 "450","500","550","600","650","700","750"))
#definir frecuencia de ejes verticales
breaks <- seq.int(0, 4000, 250)

# Plot
ggplot(data,aes(x=Epsilon, y=Longitud, fill=Epsilon)) +
  geom_boxplot() +
  geom_jitter(width=0.25, alpha=0.5)+
  scale_y_continuous(breaks = breaks  )+
  theme_ipsum()


data %>%
  ggplot( aes(x=Epsilon, y=Longitud, fill=Epsilon)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_jitter(color="black", size=0.6, alpha=0.9) +
  theme_ipsum() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle(expression(paste("Longitud de tramos de concentración de siniestros para cada umbral ", Epsilon))) +
  xlab("")

-----

pca <- crash_rn[crash_rn$cluster500!=0,]
pca$cluster500 <- as.character(pca$cluster500)

#puntos que concentran
count(pca$cluster100)

library(randomcoloR)
n <- 30
palette <- distinctColorPalette(17)
pie(rep(1, 17), col=palette)

palette <- c("#ff8c94","#f4d35e","#815799","#00a5e3","#71b578","#ff96c5","#006f60","#ff5768","#55cbcd","#ffbd00","#6c88c4","#c05780","#00B0BA","#ffa23a","#e63400","#0065a2","#4dd091","#ff60a8")

##Buscar un siniestro
#av_el_sol <- pca[pca$cluster==37,]

tm_shape(bond_dep)+
  tm_fill("gray",alpha=0.2)+
  tm_borders(alpha = 0.6,col = 'white', lwd = 2)+
  #tm_shape(rnconc) + 
  #tm_lines(col="ADMINISTRA", lwd=3,palette = "Paired")+
  tm_shape(rn2018[!rn2018$SUPERFIC_L=="Proyectado",]) + 
  tm_lines(col="#636363",lwd=0.5, alpha=0.6) +
  tm_shape(pca) + 
  tm_dots(col="cluster500", size = .1, palette=palette) +
  #tm_shape(tca_sutran) + 
  #tm_lines(col="blue",lwd=4)+
  tm_layout(legend.show=FALSE)+
  tm_compass(type="8star", size = 2,position = c("left", "bottom")) +
  tm_scale_bar(width = 0.35,position = c("left", "bottom")) 

  

#cargar detalles de clusters

  clusters <- read.csv(here::here("Data", "clusters_detalle.csv"), na="NA",
                         header=TRUE,sep=";", encoding = "UTF-8")
  
  class(clusters)
  colnames(clusters)[1] <- "cluster500"
  
#unirlo al archivo geográfico de clusters
  pca <- merge(pca,clusters, by="cluster500")

    # Create something in your range
  pca$variable <- pca$fallecidas/1000  
  
#plotear estático
#plotear según categorías
mapa_tramos_alta_densidad_fatalidades <-  tm_basemap(leaflet::providers$OpenStreetMap)+ #tm_shape(Bordes_departamentales)+
   #tm_fill("gray",alpha=0.1)+
    #tm_borders(alpha = 0.6,col = 'white', lwd = 0.5)+
  #  tm_shape(Red_Vial_Nacional_Pavimentada) + 
   # tm_lines(col="#636363",lwd=0.5) +
    tm_shape(Red_Vial_Nacional_Concesionada) + 
    tm_lines(col="ADMINISTRA", lwd=1.5,palette = palette)+
    tm_shape(Tramos_Alta_Densidad_Geográfica_Fatalidades) + 
    tm_dots(col="Personas fallecidas por clúster/tramo", size = 0.15, style="jenks",palette=c("#FED976","#FEB24C","#FD8D3C","#FC4E2A","#E31A1C","#BD0026"))

  rnconc$ADMINISTRA[is.na(rnconc$ADMINISTRA)] <- "Encargado a Proinversion"
  colnames(pca)[101] <- "Personas fallecidas por clúster/tramo"
  
  
  Bordes_departamentales <- bond_dep
  Red_Vial_Nacional_Pavimentada <- rn2018[!rn2018$SUPERFIC_L=="Proyectado",]
  Red_Vial_Nacional_Concesionada <- rnconc
  Tramos_Alta_Densidad_Geográfica_Fatalidades <- pca
  
  
  
  
  #plotear html5
  #plotear según categorías
  
mapa <- #tm_shape(bond_dep)+
    #tm_fill("gray",alpha=0.2)+
    #tm_borders(alpha = 0.6,col = 'gray', lwd = 1)+
    tm_shape(rnconc) + 
    tm_lines(col="ADMINISTRA", lwd=3,palette = "Paired")+
    #tm_shape(rn2018[!rn2018$SUPERFIC_L=="Proyectado",]) + 
   # tm_lines(col="#636363",lwd=1) +
    tm_shape(pca) + 
    tm_dots(col="fallecidas", size = 0.1, style="jenks",palette=c("#FED976","#FEB24C","#FD8D3C","#FC4E2A","#E31A1C","#BD0026"))
+    #tm_shape(tca_sutran) + 
    #tm_lines(col="blue",lwd=4)
  
tmap_save(mapa_tramos_alta_densidad_fatalidades , filename="mapa_tramos_alta_densidad_fatalidades.html")

write.table(pca, "clusters_detalle_final.csv",sep = ";")


tmap_mode("plot")


#AQUI

#mapa de corredores vs siniestralidad
tm_basemap(leaflet::providers$Esri.WorldGrayCanvas)+
  tm_shape(bond_dep) + 
  tm_borders(col="gray", lwd=0.5)+
  tm_shape(tramos_cs2) + 
  tm_lines(col="CODRUTA",lwd = 5,palette = c("#264653","#59c7eb","#2a9d8f","#3e5496","#e9c46a","#8cc43c","#8cc43c","#6454ac","#fc8c84","#8e2043","#d2691e")) +
  tm_shape(tca_sutran) + 
  tm_lines(col="red",lwd=4)+
  tm_shape(pca) + 
  tm_dots(col="red", size = .025)

tramos_cs2 <- tramos_cs2%>%
  mutate(ESTADO="Corredores Seguros")

##Eliminando Rutas de Lima
tramos_cs2 <- tramos_cs2%>%
  dplyr::filter(str_detect(OBJECTID, 
                           "^4053$|^1180$|^1176$|^21$|^28$|^1511$|^2898$|^4387$|^2885$|^2439$|^4388$|^2558$|^1187$|^1181$|^4063$|^4062$|^4054$|^1178$|^1179$|^4058$|^4057$|^1183$|^4056$|^1184$|^4060$|^1182$|^4061$|^4510$|^1186$|^4055$|^4059$|^4049$|^4051$|^4052$|^1174$|^1175$|^4047$|^4048$|^1173$|^4046$|^4050$|^1177$|^4045$|^1172$|^4044$|^4043$|^4042$|^2170$|^2170$|^2$|^924$|^564$|^806$|^808$|^3478$|^25$|^3477$|^2171$|^27$|^26$|^3714$|^3711$|^3476$|^3713$|^22$",negate = TRUE
  ))


rnconc$ESTADO[rnconc$ESTADO=="Otorgada"] <- "DGPPT"

#mapa de participación de la DGPPT
tm_basemap(leaflet::providers$Esri.WorldGrayCanvas)+
  tm_shape(bond_dep) + 
  tm_borders(col="gray", lwd=0.5)+
  tm_shape(tramos_cs2) + 
  tm_lines(col="ESTADO", palette = "#54b9c1",lwd = 10) +
  tm_shape(rnconc) + 
  tm_lines(col="ESTADO",lwd = 3,palette = c("#de8277","#f7c003"))

## 132 clusters "pca" que agrupan más de 3 siniestros fatales

#--------------TOTAL: TRAMOS DE CONCENTRACIóN DE SINIESTROS


##################   NUEVO ESTUDIO ################## CLUSTER SINIESTROS FATALES

pe1s <- rn2018%>%
  dplyr::filter(str_detect(CODRUTA, "^PE-1S$"))

crash_pe1s <- crash_fat%>%
  dplyr::filter(str_detect(Codruta, "^PE-1S$"))

tm_basemap(leaflet::providers$Esri.WorldGrayCanvas)+
  tm_shape(bond_dep) + 
  tm_borders(col="gray", lwd=0.5)+
  tm_shape(pe1s) + 
  tm_lines(col="black", ,lwd = 1.5) +
  tm_shape(crash_pe1s) + 
  tm_dots(col="red", size = .025)


##################   NUEVO ESTUDIO ################## PLAN DE INCENTIVOS - PRIORIZACIóN

#cargar municipalidaes provinciales
  munis_prov <- read.csv(here::here("Data", "munis-prov.csv"), na="NA",
                    header=TRUE,sep=";", encoding = "utf-8")
  
  class(munis_prov)
  
  munis_prov <- munis_prov %>%
    #here the ., means all data
    clean_names(., case="big_camel")
  
  
  #Nombre y clase de columnas
  munis_prov %>% 
    summarise_all(class) %>%
    pivot_longer(everything(), 
                 names_to="All_variables", 
                 values_to="Variable_class")
  
  summary(munis_prov)


#Editar lo del archivo
  
  bond_dist$IUbigeo <-  as.numeric(bond_dist$IDDIST)
  munis_prov <- merge(bond_dist,munis_prov, by="IUbigeo")
  
  tm_shape(munis_prov) + 
        tm_fill(col="Tipo",alpha = 0.9,palette="BrBG")+
    tm_shape(bond_dep) + 
    tm_borders(col="#222244",lwd = 2) 
  
  
#--------------TOTAL: DEFINICION DE ENTORNOS ESCOLARES 

coles_i <- coles[munis_prov,]
coles_i_sp <- as(coles_i,Class = "Spatial")

#first extract the points from the spatial points data frame
colesPoints <- coles_i_sp %>%
  coordinates(.)%>%
  as.data.frame()

#k-distance-graph
colesPoints%>%
  dbscan::kNNdistplot(.,k=5)

#now run the dbscan analysis inicio 15:20-15:22

dbclust <- colesPoints %>%
  fpc::dbscan(.,eps = 100, MinPts = 3)

#now plot the results
#plot(dbclust, colesPoints, main = "DBSCAN Output", frame = F)
#plot(provincia$geometry, add=T)

#interactive
coles_i<- coles_i %>%
  mutate(cluster=dbclust$cluster)

#cluster numeric
coles_i$cluster[coles_i$cluster == 0] <- NA
#cluster1 character
coles_i$cluster1 <- as.character(coles_i$cluster)

#ver analisis filtrando por regiones

coles_i_e <- coles_i[!is.na(coles_i$cluster1),]%>%
  dplyr::filter(str_detect(PROVINCIA, "HUALGAYOC"))


#VER MAPA
#tm_shape(provincia) + 
  #tm_borders(col="#222244",lwd = 3)+
mapa2 <-  tm_shape(munis_prov) + 
  tm_fill(col="Tipo",alpha = 0.2,palette="BrBG")+
  tm_shape(bond_dep) + 
  tm_borders(col="#222244",lwd =0.5) +
  tm_shape(coles_i_e) + 
  tm_dots(col="cluster1", size = .04, palette="Spectral")
  
coles_i <- st_join(coles_i,munis_prov, left=F)
write.table(coles_i, "entornos_incentivos_distrito.csv",sep = ";")

  
  tmap_save(mapa2, filename="mapa-callao-200.html")
  
  
  #--------------TOTAL: DEFINICION DE ENTORNOS ESCOLARES 
  
  #--------------TOTAL: DEFINICION DE ENTORNOS ESCOLARES - Prueba Lima MEtropolitana
  
  provincia <- bond_prov%>%
    dplyr::filter(str_detect(PROVINCIA, "LIMA"))
  
  distritos <- bond_dist%>%
    dplyr::filter(str_detect(PROVINCIA, "LIMA"))
  
  coles_i <- coles[provincia,]
  coles_i_sp <- as(coles_i,Class = "Spatial")
  
  #first extract the points from the spatial points data frame
  colesPoints <- coles_i_sp %>%
    coordinates(.)%>%
    as.data.frame()
  
  #k-distance-graph
  colesPoints%>%
    dbscan::kNNdistplot(.,k=5)
  
  #now run the dbscan analysis
  
  dbclust <- colesPoints %>%
    fpc::dbscan(.,eps = 100, MinPts = 5)
  
  #now plot the results
  #plot(dbclust, colesPoints, main = "DBSCAN Output", frame = F)
  #plot(provincia$geometry, add=T)
  
  #interactive
  coles_i<- coles_i %>%
    mutate(cluster=dbclust$cluster)
  
  #cluster numeric
  coles_i$cluster[coles_i$cluster == 0] <- NA
  #cluster1 character
  coles_i$cluster1 <- as.character(coles_i$cluster)
  
  #ver analisis
  #tm_shape(provincia) + 
  #tm_borders(col="#222244",lwd = 3)+
 mapa3 <-  tm_shape(distritos) + 
    tm_fill(col="#222244",alpha = 0.01,palette="Paired")+
  tm_shape(distritos) + 
    tm_borders(col="#222244",lwd = 1)+
    tm_shape(coles_i[!is.na(coles_i$cluster1),]) + 
    tm_dots(col="cluster1", size = .10, palette="Spectral")
  tmap_save(mapa3, filename="mapa-lima-100.html")
  

#aqui
clusters <- as.data.frame(count(coles_i$cluster)) %>% 
  filter(row_number() <= n()-1)

colnames(clusters)[1] <- "cluster"
#unir frecuencia
coles_i <- merge(coles_i,clusters, by="cluster")

#print by frequency
tm_shape(coles_i[!is.na(coles_i$cluster),]) + 
  tm_dots(col="freq", size = .03, palette="YlOrRd")


count(pca$cluster600)

##Ver longitud de tramos de intervención
for (i in c(1:max(crash_rn$cluster200))) {
  print(max(st_distance(crash_rn[crash_rn$cluster600==i,])))
}

##Buscar un siniestro
#av_el_sol <- pca[pca$cluster==37,]

tm_basemap(leaflet::providers$Esri.WorldGrayCanvas)+
  tm_shape(rn2018) + 
  tm_lines(col="black",lwd = 1,) +
  tm_shape(pca) + 
  tm_dots(col="cluster600", size = .10, palette="Dark2")+
  tm_shape(tca_sutran) + 
  tm_lines(col="blue",lwd=4)

#--------------TOTAL: DEFINICION DE ENTORNOS ESCOLARES


##################   NUEVO ESTUDIO ################## PLAN DE INCENTIVOS - PRIORIZACIóN

clusterfinal <- read.csv(here::here("clusters_detalle_final.csv"), na="NA",
                       header=TRUE,sep=";", encoding = "utf-8")
clusterfinal <- st_as_sf(clusterfinal,coords =c("Longitud","Latitud"), crs=4326)

st_write(clusterfinal, "clusters_detalle_final.shp")

a <- st_read(here::here("clusters_detalle_final.shp"))

st_write(clusterfinal, "clusters_detalle_final.shp", driver="ESRI Shapefile")  # create to a shapefile 
st_write(clusterfinal, "clusters_detalle_final.gpkg", driver="GPKG")  # Create a geopackage file
