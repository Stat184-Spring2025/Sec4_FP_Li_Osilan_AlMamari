
# Load required packages ----
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)

# Load tidied data ----
casesTidy <- read_csv("jh_confirmed_cases_country_level.csv")
covidUSA <- read_csv("covid_datahub_USA_filtered.csv")
covidTidy <- read_csv("owid_covid_data_filtered_final.csv")

# Calculate new daily cases ----
covidTidy <- covidTidy %>%
  mutate(
    date = as.Date(date),
    new_cases = total_cases - lag(total_cases),
    new_cases = ifelse(new_cases < 0, 0, new_cases),  # prevent negative values
    new_cases = new_cases / 1000  # To scale down values
  )
# How did daily COVID-19 case counts evolve across countries over time? ----
# Create a line plot to represent the cases for each of the 5 countries

ggplot(
  data = covidTidy,
  mapping = aes(
    x = date,
    y = new_cases,
    color = country,
    linetype = country
  )
) +
  geom_line(size = 0.5) +
  scale_color_manual(
    values = c("purple", "green","red", "blue","orange") 
  ) +
  labs(
    title = "Daily COVID-19 Case Counts Over Time (2020–2024)",
    x = "Date",
    y = "Daily Cases",
    color = "Country/Region",
    linetype = "Country/Region"
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "k")) +
  theme_minimal() +
  facet_wrap(~ country, scales = "free_y")


# What is the relationship between vaccination rates and death rates in the US? ----
# Create a scatter plot to represent the relationship between vaccination rates and death rates in the US.

# Reshape US data ----
# Calculate the percentages of the fully vaccinated individuals.
# Calculate the death rates per 100k people.

covidUSA <- covidUSA %>%
  mutate(
    date = as.Date(date), # Make sure date is formatted properly.
    pct_fully_vaccinated = (people_fully_vaccinated / 335000000) * 100,
    daily_deaths = deaths - lag(deaths), # To get the daily deaths count.
    death_rate_per_100k = (daily_deaths / 335000000) * 100000
  ) %>%
  filter(pct_fully_vaccinated > 0,
         daily_deaths > 0
         )

# Create scatterplot ----
# Using the tidy USA covid data

ggplot(
  data = covidUSA,
  mapping = aes(
    x = pct_fully_vaccinated, # x-axis: % fully vaccinated population.
    y = death_rate_per_100k,  # y-axis: death rate per 100,000 people.
    color = year(date))
) +
  geom_point(alpha = 0.5, size = 2) +
  geom_smooth(method = "loess", se = FALSE, color = "red") +
  labs(
    title = "Relationship Between Vaccination Rate and Death Rate in the U.S.",
    subtitle = "Each point represents a day in the U.S. from (2021–2023)",
    x = "% Fully Vaccinated Population",
    y = "Death Rate per 100,000 People",
    color = "Year"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 12),
    legend.position = "bottom"
  )

# How did ICU occupancy change during pandemic surges? ----
# Create a grouped bar chart showing ICU patients for each of the three countries.
# Highlight the delta and Omicron surges

# Load Data ----
covid_ICU_patients <- read_csv("owid_covid_data_filtered_final.csv")

# Define populations----
populations <- c(
  "United States" = 335000000,
  "United Kingdom" = 68000000,
  "Canada" = 40000000
)

# Data Wrangling ----
# Filter the three countries to focus on
# Change the date format to month and year

covid_ICU_patients <- covid_ICU_patients %>%
  mutate(
    date = as.Date(date),
    date = format(date, "%Y-%m")  
  ) %>%
  filter(country == "United States" |
           country == "United Kingdom" |
           country == "Canada") %>%
  group_by(country, date) %>%
  summarise(
    icu_patients = sum(icu_patients, na.rm = TRUE),  # To calculate monthly ICU occupancy
    .groups = "drop"
  ) %>%
  mutate(
    icu_patients = icu_patients / 1000  # To make the values shorter
  )

# Create the bar chart ----
ggplot(
  data = covid_ICU_patients,
  mapping = aes(x = date,
                y = icu_patients,
                fill = country)
) +
  geom_bar(stat = "identity", position = "dodge") +
  annotate(
    "rect", 
    xmin = "2021-06", xmax = "2021-11", # Highlight Delta surge (Jun2021-Nov2021)
    ymin = -Inf, ymax = Inf, 
    alpha = 0.2, 
    fill = "yellow"
    ) +
  annotate("rect",
           xmin = "2021-11", xmax = "2022-02", # Highlight Omicron surge (Nov2021-Feb2022)
           ymin = -Inf, ymax = Inf,
           alpha = 0.2,
           fill = "orange"
           ) +
  annotate("text",
           x = "2021-08",
           y = 900,
           label = "Delta",
           size = 3.5
           ) +
  annotate("text",
           x = "2022-01",
           y = 900,
           label = "Omicron",
           size = 3.5
           ) +
  scale_fill_manual(
    values = c("green","red", "blue") 
  ) +
  labs(
    title = "Monthly ICU Occupancy During COVID-19",
    x = "Month",
    y = "ICU Patients (Monthly)",
    fill = "Country"
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "k")) + # Adds a k to represent a thousand
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 12)
  )