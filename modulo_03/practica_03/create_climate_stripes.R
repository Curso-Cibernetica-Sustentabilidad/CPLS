library(tidyverse)

clima_mx <- read_csv("clima_mx.csv")

clima_mx |>
  group_by(anio) |>
  summarise(
    mean_temp = mean(temp_prom)
  ) |>
  ggplot(aes(x = anio, y = 1, fill = mean_temp)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = mean(clima_mx$temp_prom, na.rm = TRUE)
  ) +
  theme_void() +
  theme(
    legend.position = "none"
  )
