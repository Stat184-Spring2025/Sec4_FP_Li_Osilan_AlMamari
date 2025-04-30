# Load Required Libraries ----
library(readr)
library(dplyr)
library(knitr)
library(kableExtra)


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
    Total_Cases = sum(total_case),
    Mean_Monthly_Cases = mean(total_case),
    Peak_Month = year_month[which.max(total_case)],
    Peak_Cases = max(total_case)
  ) %>%
  arrange(desc(Total_Cases))

# Vaccination vs Death Rates in the US
summary_stats_us <- us_data %>%
  summarise(
    Total_Deaths = sum(deaths),
    Max_People_Vaccinated = max(people_vaccinated),
    Max_Fully_Vaccinated = max(people_fully_vaccinated),
    Mean_Daily_Deaths = mean(deaths),
    Median_Daily_Deaths = median(deaths)
  )
correlation <- cor(us_data$people_fully_vaccinated, us_data$deaths, use = "complete.obs")
summary_stats_us$Correlation_FullyVaccinated_Deaths <- round(correlation, 3)

# Basic ICU stats per country
icu_summary <- icu_data %>%
  group_by(country) %>%
  summarise(
    Total_ICU_Patients = sum(icu_patients, na.rm = TRUE),
    Max_ICU_Patients = max(icu_patients, na.rm = TRUE),
    Mean_ICU_Patients = mean(icu_patients, na.rm = TRUE)
  ) %>%
  arrange(desc(Max_ICU_Patients))


# Display Summary Statistics Table ----

# Summary of Monthly COVID-19 Cases by Country
case_summary %>%
  kable(caption = "Summary of Monthly COVID-19 Cases by Country",
        digits = 2, 
        align = c("l", rep("c", 3))
  )%>%
  kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width = FALSE,
    font_size = 16
  )

# US COVID-19 Vaccination and Death Summary
summary_stats_us %>%
  kable(caption = "US COVID-19 Vaccination and Death Summary")%>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
    full_width = FALSE,
    font_size = 14
    )

# ICU Response to COVID-19 Waves by Country
icu_summary %>%
  kable(caption = "ICU Response to COVID-19 Waves by Country",
        digits = 2, 
        align = c("l", rep("c", 4))
        ) %>%
  kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width = FALSE,
    font_size = 16
  )
