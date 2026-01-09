# NOAA Weather Data Downloader (CLI_test)

This project contains R scripts designed to download, process, and visualize daily weather data from the NOAA National Centers for Environmental Information (NCEI). The scripts were developed to fetch data for the Santa Barbara Municipal Airport (GHCND:USW00023190).

## Features

- Downloads daily summary data (Max, Min, and Average Temperature).
- Processes the raw data and saves it into a clean CSV file.
- Generates a time-series plot of the daily maximum temperature.
- Includes two methods for data retrieval: a direct download (no API key required) and an API-based method.

## Generated Files

Running the primary script will produce two main files:

- `santa_barbara_temp_no_api_2024-2025.csv`: The downloaded and processed temperature data.
- `santa_barbara_max_temp_plot_no_api.png`: A plot showing the daily maximum temperature over the specified date range.

## Prerequisites

- [R](https://www.r-project.org/) must be installed on your system.

## Setup

Before running the scripts, you need to install the required R packages. You can do this by running the following command in your R console:

```R
install.packages(c("ggplot2", "dplyr", "tidyr", "httr", "jsonlite"))
```

## Usage

The primary script can be run from your terminal. It does not require an API key.

```sh
Rscript download_noaa_data_no_api.R
```

This will execute the script, download the data, and generate the CSV and plot files.

## File Descriptions

- `download_noaa_data_no_api.R`: **Primary script.** Downloads data using a direct URL from the NCEI service. Plots the maximum temperature.
- `download_and_plot_noaa_data.R`: An alternative script that uses the official NOAA CDO API. **Note:** This script requires a valid NOAA API token to be inserted into the script to function.
- `.gitignore`: Specifies files and directories for Git to ignore (e.g., generated data and plots).
