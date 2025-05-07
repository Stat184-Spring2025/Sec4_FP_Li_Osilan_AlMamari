
# Load required packages ----
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)

# How did daily COVID-19 case counts evolve across countries over time? ----
# Create a line plot to represent the cases for each of the 5 countries
# Calculate new Yearly cases ----
covidTidy <- read_csv("tidied_data/owid_covid_data_filtered_final.csv") %>%
  group_by(country) %>%
  mutate(
    date = as.Date(date),
    timepoint = row_number(),
    new_cases = case_when(
      timepoint == 1 ~ 0,
      .default =  total_cases - lag(total_cases)
    )
  ) %>%
  select(-timepoint)

ggplot(covidTidy, aes(x = date, y = new_cases, color = country)) +
  geom_line(size = 0.5) +
  scale_color_viridis_d(option = "plasma", begin = 0.1, end = 0.9) +
  labs(
    x = "Year",
    y = "Yearly Cases",
    color = "Country/Region",
  ) +
  scale_y_continuous(labels = scales::percent_format(
    scale = 0.001,
    suffix = "k"
  )) +
  theme_minimal() +
  theme(
    legend.position = "top"
  ) +
  facet_wrap(~ country, scales = "free_y", ncol = 2)
# What is the relationship between vaccination rates and death rates in the US? ----
# Create a scatter plot to represent the relationship between vaccination rates and death rates in the US.

# Reshape US data ----
# Calculate the percentages of the fully vaccinated individuals.
# Calculate the death rates per 100k people.

covidUSA <- read_csv("tidied_data/covid_datahub_USA_filtered.csv") %>%
  mutate(
    date = as.Date(date),
    pct_fully_vaccinated = (people_fully_vaccinated / 335000000) * 100,
    daily_deaths = deaths - lag(deaths),
    death_rate_per_100k = (daily_deaths / 335000000) * 100000,
    year_date = as.factor(year(date))
  ) %>%
  filter(pct_fully_vaccinated > 0, daily_deaths > 0)

ggplot(covidUSA, aes(x = pct_fully_vaccinated, y = death_rate_per_100k, color = year_date)) +
  geom_point(alpha = 0.5, size = 2) +
  scale_color_viridis_d(option = "plasma", begin = 0.1, end = 0.9) +
  geom_smooth(method = "loess", se = FALSE, color = "#0072B2") +
  labs(
    x = "% Fully Vaccinated",
    y = "Deaths per 100,000 People",
    color = "Year"
  ) +
  theme_bw() +
  theme(
    legend.position = "top"
  )


# How did ICU occupancy change during pandemic surges? ----
# Create a grouped bar chart showing ICU patients for each of the three countries.
# Highlight the delta and Omicron surges

# Data Wrangling ----
# Filter the three countries to focus on
# Change the date format to month and year

covid_ICU <- read_csv("tidied_data/owid_covid_data_filtered_final.csv") %>%
  mutate(
    date = as.Date(date),
    date_ym =  as.Date(format(date, "%Y-%m-01"))
  ) %>%
  filter(country %in% c("United States", "United Kingdom", "Canada")) %>%
  group_by(country, date_ym) %>%
  summarise(icu_patients = sum(icu_patients, na.rm = TRUE), .groups = "drop") %>%
  mutate(icu_patients = icu_patients / 1000)

ggplot(covid_ICU, aes(x = date_ym, y = icu_patients, fill = country)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_viridis_d(option = "plasma", begin = 0.1, end = 0.9) +
  annotate("rect", xmin = as.Date("2021-06-01"), xmax = as.Date("2021-11-01"), ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "#009E73") +
  annotate("rect", xmin = as.Date("2021-11-01"), xmax = as.Date("2022-02-01"), ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "#999999") +
  annotate("text", x = as.Date("2021-08-01"), y = 900, label = "Delta", size = 3.5) +
  annotate("text", x = as.Date("2022-01-01"), y = 900, label = "Omicron", size = 3.5) +
  labs(
    x = "Month",
    y = "ICU Patients (in thousands)",
    fill = "Country"
  ) +
  scale_x_date(
    breaks = seq(as.Date("2020-01-01"), as.Date("2024-08-01"), by = "3 months"),
    date_labels = "%Y-%m"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )
