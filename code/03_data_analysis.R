# Load Required Libraries ----
library(readr)
library(dplyr)
library(knitr)
library(kableExtra)
library(tidyr)
library(tools)
library(scales)
# Load Cleaned Data ----

# Load the cleaned dataset prepared in the tided folder
jh_cases <- read_csv("tidied_data/jh_confirmed_cases_country_level.csv")
us_data <- read_csv("tidied_data/covid_datahub_USA_filtered.csv")
icu_data <- read_csv("tidied_data/owid_covid_data_filtered_final.csv")


# Create Summary Statistics Table ----

# Daily Case Trends Across Countries - Total cases per country
case_summary <- jh_cases %>%
  group_by(`Country/Region`) %>%
  summarise(
    `Total Cases` = sum(new_cases, na.rm = TRUE),
    `Peak Increase` = max(new_cases, na.rm = TRUE),
    `Peak Date` = year_month[which.max(new_cases)]
  ) %>%
  mutate(
    `Total Cases` = comma(`Total Cases`),
    `Peak Increase` = comma(`Peak Increase`)
  ) %>%
  arrange(desc(`Total Cases`))

# Vaccination vs Death Rates in the US
summary_stats_us <- us_data %>%
  summarise(
    Total_Deaths = sum(deaths_change, na.rm = TRUE),
    Total_Vaccinated = sum(people_vaccinated_change, na.rm = TRUE),
    Total_Fully_Vaccinated = sum(people_fully_vaccinated_change, na.rm = TRUE),
    Mean_Daily_Deaths = mean(deaths_change, na.rm = TRUE),
    Median_Daily_Deaths = median(deaths_change, na.rm = TRUE),
    Mean_Daily_Vaccinated = mean(people_vaccinated_change, na.rm = TRUE),
    Median_Daily_Vaccinated = median(people_vaccinated_change, na.rm = TRUE),
    Mean_Daily_Fully_Vaccinated = mean(people_fully_vaccinated_change, na.rm = TRUE),
    Median_Daily_Fully_Vaccinated = median(people_fully_vaccinated_change, na.rm = TRUE)
  )

# Correlation based on daily changes
correlation <- cor(us_data$people_fully_vaccinated_change, us_data$deaths_change, use = "complete.obs")
summary_stats_us$Correlation_FullyVaccinated_Deaths <- round(correlation, 3)

# Basic ICU stats per country
icu_summary <- icu_data %>%
  filter(!(country %in% c("China", "Singapore"))) %>% 
  arrange(country, date) %>%
  group_by(country) %>%
  mutate(
    prev_icu = lag(icu_patients),
    icu_increase = ifelse(!is.na(prev_icu) & icu_patients > prev_icu, icu_patients - prev_icu, 0)
  ) %>%
  summarise(
    Country = first(country),
    `Total ICU Patients` = format(sum(icu_increase, na.rm = TRUE), big.mark = ",", scientific = FALSE),
    `Max ICU Patients` = format(max(icu_patients, na.rm = TRUE), big.mark = ",", scientific = FALSE),
    `Peak Date` = date[which.max(icu_patients)] 
) %>%
  select(Country, `Total ICU Patients`, `Max ICU Patients`,`Peak Date` ) %>%
  arrange(desc(`Max ICU Patients`))


# Display Summary Statistics Table ----

# Summary of Monthly COVID-19 Cases by Country
kable(case_summary, 
      caption = "Summary of Total and Peak Monthly COVID-19 Cases by Country",
      align = c("l", "r", "r", "r")) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"),
                latex_options = "scale_down",
                full_width = FALSE)

# US COVID-19 Vaccination and Death Summary
# Convert to long format and clean labels
summary_stats_us_long <- summary_stats_us %>%
  pivot_longer(everything(), names_to = "Metric", values_to = "Value") %>%
  mutate(
    Metric = gsub("_", " ", Metric),
    Metric = gsub("(?<=[a-z])(?=[A-Z])", " ", Metric, perl = TRUE),
    Metric = toTitleCase(tolower(Metric)),
    Value = formatC(as.numeric(Value), format = "f", digits = 2, big.mark = ",", drop0trailing = TRUE)
  )

# Render formatted table
kable(summary_stats_us_long,
      caption = "US COVID-19 Vaccination and Death Summary (Using Daily Changes)",
      align = c("l", "r")) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"),
                latex_options = "scale_down",
                full_width = FALSE)

# ICU Response to COVID-19 Waves by Country
kable(icu_summary, caption = "ICU Response to COVID-19 Waves by Country",
      align = c("l", "r", "r","r")) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = FALSE)
