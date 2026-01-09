# Title: Download Daily Temperature Data from NOAA CDO API
# Description: This script downloads daily air temperature data (TMAX, TMIN, TAVG)
#              for Santa Barbara Municipal Airport from 2024-01-01 to 2025-12-31,
#              saves it as a CSV, and plots the average temperature.
# Author: Gemini
# Date: 2026-01-09

# 1. Install and load necessary packages
# ----------------------------------------------------
# If you don't have these packages installed, uncomment the lines below
# install.packages("httr")
# install.packages("jsonlite")
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("ggplot2")

library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(ggplot2)


# 2. Set up your API request parameters
# ----------------------------------------------------
# !!! IMPORTANT !!!
# Replace "YOUR_NOAA_API_TOKEN" with your actual token obtained from:
# https://www.ncdc.noaa.gov/cdo-web/token
api_token <- "YOUR_NOAA_API_TOKEN"

# API endpoint for data requests
base_url <- "https://www.ncdc.noaa.gov/cdo-web/api/v2/data"

# Parameters for the request
start_date <- "2024-01-01"
end_date <- "2025-12-31"
dataset_id <- "GHCND" # Daily Summaries
station_id <- "GHCND:USW00023190" # Santa Barbara Municipal Airport
data_types <- "TMAX,TMIN,TAVG" # Max, Min, and Average Temperature
api_limit <- 1000 # The API returns a max of 1000 records per request


# 3. Make the API request
# ----------------------------------------------------
cat("Requesting data from NOAA...\n")

response <- GET(
  url = base_url,
  add_headers(token = api_token),
  query = list(
    datasetid = dataset_id,
    stationid = station_id,
    startdate = start_date,
    enddate = end_date,
    datatypeid = data_types,
    limit = api_limit,
    units = "metric" # Use 'standard' for Fahrenheit
  )
)


# 4. Process the response
# ----------------------------------------------------
# Check for a successful request (status code 200)
if (http_status(response)$category != "Success") {
  stop(
    "API request failed with status: ", http_status(response)$reason, "\n",
    "Response content:\n", content(response, "text", encoding = "UTF-8")
  )
}

cat("Data received successfully. Processing...\n")

# Extract content and parse from JSON
json_content <- content(response, "text", encoding = "UTF-8")
data_list <- fromJSON(json_content)

# The actual data is in the 'results' element of the list
if (is.null(data_list$results)) {
  stop("No 'results' found in the API response. Check your parameters.")
}

raw_data <- data_list$results


# 5. Clean and format the data
# ----------------------------------------------------
# The data is in a 'long' format, let's make it 'wide' and clean it up.
# Note: Temperature values from the API are in tenths of a degree.
# We need to divide by 10 to get the actual temperature.

if (nrow(raw_data) > 0) {
  temp_data <- raw_data %>%
    # Keep only the columns we need
    select(date, datatype, value) %>%
    # Convert date string to a proper Date object
    mutate(date = as.Date(substr(date, 1, 10))) %>%
    # Convert value to numeric and scale it (tenths of degrees)
    mutate(value = as.numeric(value) / 10) %>%
    # Pivot the data from long to wide format
    pivot_wider(
      names_from = datatype,
      values_from = value
    ) %>%
    # Rename columns for clarity
    rename(
      avg_temp_c = TAVG,
      max_temp_c = TMAX,
      min_temp_c = TMIN
    ) %>%
    # Arrange by date
    arrange(date)

  cat("Data processing complete.\n\n")

  # 6. Save the data to a CSV file
  # ----------------------------------------------------
  output_filename <- "santa_barbara_temp_2024-2025.csv"
  write.csv(temp_data, output_filename, row.names = FALSE)
  cat(paste("Data successfully saved to:", output_filename, "\n\n"))

  # 7. Plot the time series for daily average temperature
  # ----------------------------------------------------
  temp_plot <- ggplot(temp_data, aes(x = date, y = avg_temp_c)) + 
    geom_line(color = "steelblue") + 
    geom_smooth(method = "loess", se = FALSE, color = "red", linetype = "dashed") + 
    labs(
      title = "Daily Average Temperature in Santa Barbara (2024-2025)",
      subtitle = "Data source: NOAA GHCND",
      x = "Date",
      y = "Average Temperature (°C)"
    ) + 
    theme_minimal() + 
    theme(
      plot.title = element_text(hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5)
    )

  # Print the plot to the plot viewer
  print(temp_plot)
  
  # Optionally, save the plot to a file
  ggsave("santa_barbara_avg_temp_plot.png", plot = temp_plot, width = 10, height = 6)
  # cat("Plot saved as santa_barbara_avg_temp_plot.png\n")


} else {
  cat("The API returned no data for the specified parameters.\n")
}
