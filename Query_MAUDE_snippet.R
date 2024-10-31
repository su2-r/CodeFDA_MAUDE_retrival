# Code snippet
# Query MAUDE
maude <- data.frame()
my_api_key <- Sys.getenv("FDAapiKey")
start_date <- 20170101
end_date <- 20171231
search_string <- "knee+prosthesis"  # Or "bone+cement"

while (start_date <= end_date) {
  query_url <- paste0(
    "https://api.fda.gov/device/event.json?",
    "api_key=", my_api_key,
    "&search=device.generic_name:\"",
    search_string,
    "\"+AND+date_received:[", start_date, "+TO+", end_date, "]",
    "&limit=100"
  )
  
  current_data <- jsonlite::fromJSON(query_url)$results
  maude <- plyr::rbind.fill(maude, current_data)
  
  start_date <- as.numeric(max(current_data$date_received)) + 1
}

# Select relevant columns
selected_columns <- c(
  "report_number", "event_type", "date_received", "product_problem_flag",
  "adverse_event_flag", "report_source_code"
)
maude <- maude[, selected_columns]

# Extract device information
device_columns <- c(
  "lot_number", "model_number", "manufacturer_d_name",
  "manufacturer_d_country", "brand_name",
  "device_name", "medical_specialty_description",
  "device_class"
)

for (column in device_columns) {
  maude[[column]] <- sapply(maude$device, function(x) x[[column]][1])
}

# Simulate a reporting geographical region
maude$region <- as.character(
  factor(
    as.numeric(cut(runif(nrow(maude)), 3)),
    labels = c("West", "Central", "East")
  )
)

# Convert to ASCII format
for (i in 1:ncol(maude)) {
  maude[, i] <- iconv(maude[, i], "UTF-8", "ASCII")
}

# Save the data
usethis::use_data(maude, overwrite = TRUE)


