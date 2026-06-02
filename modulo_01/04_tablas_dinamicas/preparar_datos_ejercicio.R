library(tidyverse)

files <- list.files("data", pattern = "*.csv", full.names = TRUE)

data <- read_csv(files, id="archivo") |> janitor::clean_names()

data <- data |>
  mutate(
    fecha = lubridate::as_date(str_extract(archivo, "data/[0-9]{8}"))
  ) |>
  select(fecha, edo, clave, est, tmed)

write_csv(data, "datos_ejercicio.csv")