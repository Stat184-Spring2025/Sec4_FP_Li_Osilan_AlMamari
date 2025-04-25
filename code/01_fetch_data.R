# Load required packages
library(readr)     # For reading and writing CSV files
library(COVID19)   # For fetching data from the COVID-19 Data Hub API

# DATASET 1: Johns Hopkins CSSE - Time Series of Confirmed Cases (Global)
# ----------------------------------------------------------------------
# This dataset contains cumulative confirmed COVID-19 case counts 
# for every country (and some subnational regions), tracked daily.
# Useful for: Visualizing time-series trends in infections globally or by country.

jh_confirmed <- read_csv(
  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
)

# Save a local copy of the JHU confirmed cases dataset
write_csv(jh_confirmed, "jh_confirmed_cases.csv")


# DATASET 2: COVID-19 Data Hub - Country-Level COVID-19 Metrics (USA Only)
# ------------------------------------------------------------------------
# This dataset is pulled using the COVID19 R package and includes daily 
# case counts, deaths, testing rates, vaccination rates, government 
# stringency indexes, and more for the USA.
# Useful for: Broad national-level analysis of the U.S. COVID timeline.

covid_us <- covid19("USA")  # To unfilter, use covid19() with no arguments for global

# Save a local copy of the USA-specific dataset
write_csv(covid_us, "covid_datahub_USA.csv")


# DATASET 3: Our World in Data - Comprehensive Global COVID Dataset
# -----------------------------------------------------------------
# This dataset includes global COVID-19 metrics: daily new cases and deaths,
# vaccination rates, ICU usage, testing data, hospital admissions, and more.
# It is a single, rich source that can power all three research questions.
# Useful for: Global comparisons, vax vs. death rate analysis, ICU strain over time.

owid_data <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv")

# Save a local copy of the OWID dataset
write_csv(owid_data, "owid_covid_data.csv")
