# install.packages("nasapower")
library(nasapower)
library(tidyverse)

## Tomar las coordenadas de las ciudades más pobladas de México
## https://es.wikipedia.org/wiki/%C3%81reas_metropolitanas_de_M%C3%A9xico
ciudades_mx <- tribble(
  ~ciudad, ~lat, ~lon,
  "Ciudad de México", 19.434621392375433, -99.1305143051531,
  "Monterrey", 25.682637594708087, -100.3162369603195,
  "Guadalajara", 20.67576684594507, -103.3415780324066,
  "Puebla", 19.04390854393722, -98.19939152014665,
  "Toluca", 19.28368872083081, -99.65660477412405,
  "Tijuana", 32.52820359869991, -117.02371779419556,
  "León", 21.124023266824118, -101.68364308005371,
  "Querétaro", 20.591873497460973, -100.39657114325912,
  "Juárez", 31.695627105743583, -106.42467635080202,
  "Torreón", 25.549401117544235, -103.41635608572297,
  "Mérida", 20.97038273018182, -89.62475361332808,
  "San Luis Potosí", 22.154440602790974, -100.97470019118023
)

# Función para descargar los datos
descargar_clima <- function(lat, lon, ciudad) {
  get_power(
    community = "ag",
    lonlat = c(lon, lat),
    pars = c("T2M", "T2M_MAX", "T2M_MIN", "PRECTOTCORR"),
    dates = c("1981-01-01", "2025-12-31"),
    temporal_api = "daily"
  ) |> 
    mutate(ciudad = ciudad)
}

# Descarga de los datos
clima_mx <- ciudades_mx |> 
  pmap_dfr(~ descargar_clima(..2, ..3, ..1))

# Renombrar las columnas
clima_mx_limpio <- clima_mx |>
  rename(
    anio = YEAR,
    mes = MM,
    dia = DD, 
    dia_del_anio = DOY,
    fecha = YYYYMMDD,
    temp_prom = T2M,
    temp_min = T2M_MIN,
    temp_max = T2M_MAX,
    precip = PRECTOTCORR
  ) |>
  select(-LON, -LAT)

write_csv(clima_mx_limpio, "clima_mx.csv")
