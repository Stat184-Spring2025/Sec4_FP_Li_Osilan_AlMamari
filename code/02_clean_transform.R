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
  select(date, deaths, vaccines, people_vaccinated, people_fully_vaccinated) %>%
  mutate(
    across(
      c(deaths, vaccines, people_vaccinated, people_fully_vaccinated),
      ~ replace_na(as.numeric(.), 0)
    )
  )

# Save to a new file
write_csv(covid_us_filtered, "tidied_data/covid_datahub_USA_filtered.csv")

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

# Step 4: Save the cleaned, aggregated wide-format dataset
write_csv(jh_country_level, "tidied_data/jh_confirmed_cases_country_level.csv")