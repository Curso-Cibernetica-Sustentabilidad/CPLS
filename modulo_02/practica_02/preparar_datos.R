library(tidyverse)

## Datos descargados del Sistema de Información Energética (SIE) https://sie.energia.gob.mx/inicio/#/
data_consumo <- read_csv(
    "Consumo de energía eléctrica por entidad federativa-2026_06_09-06_18_05-pm.csv",
    skip = 12,
    col_names = c("entidad", 2013:2023),
    n_max = 32) |>
    pivot_longer(-entidad, names_to = "ano", values_to = "consumo_GWh")

## Datos descargados del Sistema de Información Energética (SIE) https://sie.energia.gob.mx/inicio/#/
## No hay datos para Aguascalientes, Tabasco ni Tlaxcala
data_generacion <- read_csv(
    "Generación bruta de energía eléctrica por entidad federativa-2026_06_09-06_19_38-pm.csv",
    skip = 10,
    col_names = c("entidad", "unidades_1", "unidades_2", "agregacion",  2013:2023),
    n_max = 28) |>
    select( -unidades_1, -unidades_2, -agregacion) |>
    pivot_longer(-entidad, names_to = "ano", values_to = "generacion_GWh")

data_energia <- data_consumo |> full_join(data_generacion) |> mutate(ano = as.numeric(ano))

## Datos descargados de la Plataforma Nacional de Datos Abiertos
## https://www.datos.gob.mx/dataset/proyecciones-de-poblacion/resource/3c3092be-583e-4490-8c23-67ef9a64b198
data_poblacion <- read_csv(
    "data-2026-06-10.csv",
    col_select = c("CLAVE_ENT", "NOM_ENT", "SEXO", "ANO", "POB_TOTAL")
  ) |>
  group_by(CLAVE_ENT, NOM_ENT, ANO) |>
  summarise(
    poblacion = sum(POB_TOTAL)
  ) |>
  rename(
    entidad = NOM_ENT,
    clave_entidad = CLAVE_ENT,
    ano = ANO
  ) |>
  filter(ano >= 2013 & ano <= 2023) |>
  mutate(
    entidad = entidad |>
      recode_values(
        "Coahuila de Zaragoza" ~ "Coahuila",
        "México" ~ "Estado de México",
        "Michoacán de Ocampo" ~ "Michoacán",
        "Veracruz de Ignacio de la Llave" ~ "Veracruz",
        default = entidad
      )
  )
  
data <- data_energia |> 
  full_join(data_poblacion)

write_csv(data, "data_energia_mexico_2013_2023.csv")
