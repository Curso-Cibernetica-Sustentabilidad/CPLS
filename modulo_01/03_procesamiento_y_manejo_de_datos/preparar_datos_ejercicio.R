library(tidyverse)

### Año de los datos
data_year <- 2022

### Cargar datos
owid_regions <- read_csv("https://ourworldindata.org/grapher/continents-according-to-our-world-in-data.csv?v=1&csvType=full&useColumnShortNames=true")
trigo <- read_csv("https://ourworldindata.org/explorers/crop-yields.csv?v=1&csvType=full&useColumnShortNames=true&Crop=Wheat&Metric=Actual+yield&hideControls=false") |> filter(year == data_year)
maiz <- read_csv("https://ourworldindata.org/explorers/crop-yields.csv?v=1&csvType=full&useColumnShortNames=true&Crop=Corn+%28maize%29&Metric=Actual+yield") |> filter(year == data_year)
fertilizante <- read_csv("https://ourworldindata.org/explorers/fertilizers.csv?v=1&csvType=full&useColumnShortNames=true&Input=Synthetic+fertilizer&Nutrient=All+nutrients&Metric=Applied+%28per+hectare%29&Share+of+world+total=false") |> filter(year == data_year)
pesticida <- read_csv("https://ourworldindata.org/grapher/pesticide-use-tonnes.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)
obesidad <- read_csv("https://ourworldindata.org/grapher/share-of-adults-defined-as-obese.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)
malnutricion <- read_csv("https://ourworldindata.org/grapher/prevalence-of-undernourishment.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)

### Juntar datos
data <- owid_regions |>
  select(entity, code, owid_region) |>
  left_join(trigo) |>
  left_join(maiz) |>
  left_join(fertilizante) |>
  left_join(pesticida) |>
  left_join(obesidad)|>
  left_join(malnutricion) |>
  drop_na() |>
  rename(
    region = owid_region,
    fertilizer_per_ha = all_fertilizers_per_cropland,
    pesticide_tonnes = pesticides__total__00001357__agricultural_use__005157__tonnes,
    obesity_percent = prevalence_of_obesity_among_adults__bmi__gt__30__crude_estimate__pct__sex_both_sexes__age_group_18plus__years_of_age,
    undernourishment_percent = "_2_1_1_prevalence_of_undernourishment__000000000024000__value__006121__percent"
  )

### Ensuciar datos
samp01 <- data |>
  sample_n(30)
data <- data |>
  anti_join(samp01) |>
  mutate(
    wheat_yield = as.character(wheat_yield)
  ) |>
  bind_rows(
    samp01 |>
      mutate(
        wheat_yield = paste0(wheat_yield, " t")
      )
  ) 

samp02 <- data |>
  sample_n(27)
data <- data |> 
  anti_join(samp02) |>
  mutate(
    undernourishment_percent = as.character(undernourishment_percent)
  ) |>
  bind_rows(
    samp02 |>
      mutate(
        undernourishment_percent = paste0(undernourishment_percent,"%")
      )
  )

### Agregar duplicados
data <- data|> messy::duplicate_rows(shuffle = TRUE)

### Exportar
write_csv(data, "datos_ejercicio.csv")