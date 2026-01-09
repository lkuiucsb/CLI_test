# Title: Download Daily Temperature Data from NOAA NCEI (No API)
# Description: This script downloads, saves, and plots daily air temperature data
#              for Santa Barbara Municipal Airport directly as a CSV.
# Author: Gemini
# Date: 2026-01-09

# If you don't have ggplot2 installed, uncomment the line below
# install.packages("ggplot2")
library(ggplot2)

# 1. Set up the parameters for the download URL
# ----------------------------------------------------
base_url   <- "https://www.ncei.noaa.gov/access/services/data/v1"
dataset    <- "daily-summaries"
station_id <- "USW00023190"
start_date <- "2024-01-01"
end_date   <- "2025-12-31"
data_types <- "TAVG,TMAX,TMIN" # Average, Maximum, and Minimum Temperature
output_format <- "csv"

# 2. Construct the full download URL
# ----------------------------------------------------
# We use URLencode to ensure parameters are correctly formatted.
full_url <- paste0(
  base_url,
  "?dataset=", dataset,
  "&stations=", URLencode(station_id, reserved = TRUE),
  "&startDate=", start_date,
  "&endDate=", end_date,
  "&dataTypes=", data_types,
  "&format=", output_format
)

cat("Constructed Download URL:\n", full_url, "\n\n")


# 3. Download, process, and plot the data
# ----------------------------------------------------
output_filename <- "santa_barbara_temp_no_api_2024-2025.csv"

cat("Attempting to download data from NOAA...\n")

tryCatch({
  # Use read.csv to directly read the data from the URL into a data frame
  weather_data <- read.csv(full_url)
  
  # Check if data was actually downloaded
  if (nrow(weather_data) > 0) {
    
    cat("Data downloaded successfully. Processing and saving...\n")
    
    # The temperature values are in tenths of a degree Celsius.
    # We convert them to actual degrees Celsius.
    if ("TMAX" %in% names(weather_data)) {
      weather_data$TMAX <- weather_data$TMAX / 10
    }
    if ("TMIN" %in% names(weather_data)) {
      weather_data$TMIN <- weather_data$TMIN / 10
    }
    if ("TAVG" %in% names(weather_data)) {
      weather_data$TAVG <- weather_data$TAVG / 10
    }
    
    # Save the processed data frame to a local CSV file
    write.csv(weather_data, output_filename, row.names = FALSE)
    
    cat("\nSuccess! Data saved to:", output_filename, "\n")
    cat("Here are the first few rows of the data:\n\n")
    print(head(weather_data))
    
    # 4. Plot the time series for daily maximum temperature
    # ----------------------------------------------------
    cat("\nGenerating plot for Maximum Temperature (TMAX)...\n")
    
    # Ensure the DATE column is in Date format for plotting
    weather_data$DATE <- as.Date(weather_data$DATE)
    
    # Filter out NA values for TMAX before plotting
    plotting_data <- weather_data[!is.na(weather_data$TMAX), ]
    
    if(nrow(plotting_data) > 0) {
      temp_plot <- ggplot(plotting_data, aes(x = DATE, y = TMAX)) +
        geom_line(color = "firebrick") + # Changed color for distinction
        labs(
          title = "Daily Maximum Temperature - Santa Barbara Airport",
          subtitle = paste(start_date, "to", end_date, "(missing values removed)"),
          x = "Date",
          y = "Maximum Temperature (°C)"
        ) +
        theme_minimal()
        
      # Print the plot to the RStudio viewer
      print(temp_plot)
      
      # Save the plot to a file
      plot_filename <- "santa_barbara_max_temp_plot_no_api.png" # New filename
      ggsave(plot_filename, plot = temp_plot, width = 10, height = 6)
      cat("Plot saved as", plot_filename, "\n")
    } else {
      cat("No data available for Maximum Temperature (TMAX) to plot.\n")
    }
    
  } else {
    cat("Download was successful, but no data was returned for the given parameters.\n")
  }
  
}, error = function(e) {
  # This block will run if there's an error during the download
  cat("\nAn error occurred during the download process.\n")
  cat("Error message:", e$message, "\n")
  cat("Please check the URL and your internet connection.\n")
})