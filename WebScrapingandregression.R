install.packages("httr")
install.packages("xml2")
install.packages("dplyr")
# Load necessary libraries
library(httr)
library(xml2)

# Specify the URL
url <- "https://www.dawn.com/trends/elections-2024"

# Send an HTTP GET request to the URL
response <- httr::GET(url)

# Check if the request was successful
if (httr::http_error(response)) {
  # Print error message
  print("Error: Unable to retrieve data from the website.")
} else {
  # Parse the HTML content of the page
  webpage <- xml2::read_html(httr::content(response, as = "text"))
  
  # Extract article titles and URLs
  articles <- xml2::xml_find_all(webpage, "//article//h2[contains(@class, 'story__title')]") %>%
    xml2::xml_text(trim = TRUE)
  
  urls <- xml2::xml_find_all(webpage, "//article//a[contains(@href, '/news')]") %>%
    xml2::xml_attr("href")
  
  # Combine article titles and URLs into a data frame
  article_data <- data.frame(Title = articles, URL = urls)
  
  # Write the extracted data to a table
  write.table(article_data, file = "article_data.csv", sep = ",", row.names = FALSE)
  
  # Print a message indicating successful data extraction and writing
  print("Data has been extracted and written to 'article_data.csv'.")
}

# Check the structure of the dataset
str(article_data)

# Check the column names
names(article_data)

# Example: Extract features from titles and URLs
# For demonstration purposes, we'll just create dummy features
article_data$Title_Length <- nchar(article_data$Title)
article_data$URL_Length <- nchar(article_data$URL)

# Fit linear regression model with extracted features
model <- lm(Title_Length ~ URL_Length, data = article_data)

# Print model summary
summary(model)
