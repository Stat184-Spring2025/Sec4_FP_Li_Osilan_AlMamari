# Load required libraries
library(readr)
library(dplyr)
library(tidyr)  # for replace_na()
library(lubridate)

#What is the relationship between vaccination rates and death rates in the US?
# Read dataset
covid_us <- read_csv("raw_data/covid_datahub_USA.csv")

# Clean and replace NA values with 0
covid_us_filtered <- covid_us %>%
  select(date, deaths, people_vaccinated, people_fully_vaccinated) %>%
  mutate(
    date = ymd(date),
    across(
      c(deaths, people_vaccinated, people_fully_vaccinated),
      ~ replace_na(as.numeric(.), 0)
    )
  ) %>%
  filter(date >= as.Date("2020-12-13") & date <= as.Date("2023-03-23"))
#Convert cumulative values to single change
new_us_data <- covid_us_filtered %>%
  mutate(
    timepoint = row_number(),
    people_vaccinated_change = case_when(
      timepoint == 1 ~ 0,
      .default =  people_vaccinated - lag(people_vaccinated, n = 1)
    ),
    deaths_change = case_when(
      timepoint == 1 ~ 0,
      .default =  deaths - lag(deaths, n = 1)
    ),
    people_fully_vaccinated_change = case_when(
      timepoint == 1 ~ 0,
      .default =  people_fully_vaccinated - lag(people_fully_vaccinated, n = 1)
    )
  )

# Save to a new file
write_csv(new_us_data, "tidied_data/covid_datahub_USA_filtered.csv")

# did daily case counts change across major countries over time?

# Read the Johns Hopkins dataset
jh_data <- read_csv("raw_data/jh_confirmed_cases.csv")

# Step 2: Filter to selected countries
target_countries <- c("Canada", "China", "United Kingdom", "US", "Singapore")

jh_filtered <- jh_data %>%
  filter(`Country/Region` %in% target_countries) %>%
  select(-`Province/State`, -Lat, -Long)  # Drop unnecessary columns

# Step 3: Group by Country and sum values for each date column
jh_country_level <- jh_filtered %>%
  group_by(`Country/Region`) %>%
  summarise(across(everything(), sum, na.rm = TRUE), .groups = "drop")

# Step 4: convert date to months
date_to_month <- jh_country_level %>%
  pivot_longer(
    cols = 2:ncol(jh_country_level),
    names_to = "date",
    values_to = "value"
  ) %>%
  mutate(
    year_month = format(as.Date(date, "%m/%d/%y"), format="%Y/%m/01")
  ) %>%
  group_by(`Country/Region`, year_month) %>%
  summarise(
    total_case = sum(value)
  )

# Step 5: Save the cleaned, aggregated wide-format dataset
write_csv(date_to_month, "tidied_data/jh_confirmed_cases_country_level.csv")


#How did ICU capacity respond to COVID-19 waves across countries?
owid_data <- read_csv("raw_data/owid_covid_data.csv")

# Clean and filter
owid_selected <- owid_data %>%
  select(location, date, total_cases, total_deaths, icu_patients) %>%
  filter(location %in% c("United States", "United Kingdom", "Canada", "China", "Singapore")) %>%
  mutate(
    icu_patients = replace_na(icu_patients, 0),  # Replace NA in icu_patients with 0
    country = location  # Create new column 'country' from 'location'
  ) %>%
  select(country, date, total_cases, total_deaths, icu_patients)  # Reorder and drop 'location'

# Save the cleaned dataset
write_csv(owid_selected, "tidied_data/owid_covid_data_filtered_final.csv")