library(tidyverse)

### Año de los datos
data_year <- 2023

### Cargar datos
owid_regions <- read_csv("https://ourworldindata.org/grapher/continents-according-to-our-world-in-data.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)
gdp_percapita <- read_csv("https://ourworldindata.org/grapher/gdp-per-capita-worldbank.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)
co2_emissions_percapita <- read_csv("https://ourworldindata.org/grapher/co-emissions-per-capita.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)
population <- read_csv("https://ourworldindata.org/grapher/population.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)
schooling <- read_csv("https://ourworldindata.org/grapher/years-of-schooling.csv?v=1&csvType=full&useColumnShortNames=true&metric_type=average_years_schooling&level=all&sex=both") |> filter(year ==data_year)
life_expectancy <- read_csv("https://ourworldindata.org/grapher/life-expectancy.csv?v=1&csvType=full&useColumnShortNames=true") |> filter(year == data_year)
world_bank_income <- read_csv("https://ourworldindata.org/grapher/world-bank-income-groups.csv?v=1&csvType=full&useColumnShortNames=true") |> 
  filter(year == data_year) |>
  mutate(income_group = str_remove(classification, " countries")) |> 
  select(entity, code, year, income_group)


### Ensuciar datos
samp_co2 <- co2_emissions_percapita |> sample_n(30)
co2_emissions_percapita <-co2_emissions_percapita |> 
  anti_join(samp_co2) |> 
  mutate(
    emissions_total_per_capita = as.character(emissions_total_per_capita)
  ) |> 
  bind_rows(
    samp_co2 |>
      mutate(
        emissions_total_per_capita = paste0(emissions_total_per_capita, " @")
      )
  ) |>
  arrange(entity)

samp_schooling <- schooling |> sample_n(50)
schooling <-schooling |> 
  anti_join(samp_schooling) |> 
  mutate(
    mys__sex_total = as.character(mys__sex_total)
  ) |> 
  bind_rows(
    samp_schooling |>
      mutate(
        mys__sex_total = paste0(mys__sex_total, " yr")
      )
  ) |>
  arrange(entity)

### Juntar datos
data <- owid_regions |>
  left_join(gdp_percapita) |>
  left_join(co2_emissions_percapita) |>
  left_join(population) |>
  left_join(world_bank_income) |>
  left_join(schooling) |>
  left_join(life_expectancy) |>
  drop_na() |>
  rename(
    region = owid_region,
    gdp_percapita = ny_gdp_pcap_pp_kd,
    co2_emissions_percapita = emissions_total_per_capita,
    population = population_historical,
    mean_year_schooling = mys__sex_total,
    life_expectancy = life_expectancy_0
  ) 

### Agregar duplicados
data <- data|> messy::duplicate_rows(shuffle = TRUE)

### Exportar
write_csv(data, "datos_tutorial.csv")