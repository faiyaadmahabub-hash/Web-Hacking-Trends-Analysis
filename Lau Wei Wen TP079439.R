#---------------Data Import--------------------
#Set Path
getwd()
setwd("/Users/weiwen/Documents/PFDA/assignment")
getwd()

#View File List 
list.files()

#Import Raw Dataset 
raw_df <- read.csv("Clean_Loss_Data.csv", header = TRUE)



#Show the dataset details
head(raw_df)
str(raw_df)
summary(raw_df)

#---------------Data Cleaning--------------------
#Install Packages
InstallPackages <- function(){
  install.packages("dplyr")
  install.packages("ggplot2")
  install.packages("tidyr")
  install.packages("stringr")
  install.packages("scales")
  install.packages("lubridate")
  
}
InstallPackages()

#Load Package
LoadPackages <- function(){
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  library(stringr)
  library(scales)
  library(lubridate)
  
}
LoadPackages()

#Initial data structure
glimpse(raw_df)

#removing unnecessary columns
cl_df_ <- raw_df %>% 
  select(-c(WebServer, Lang, Ransom))

# Replace empty strings, "NULL", "UNKNOWN", and 0 with NA
cl_df_[cl_df_ == ""] <- NA
cl_df_[cl_df_ == "NULL"] <- NA
cl_df_[cl_df_ == "UNKNOWN"] <- NA
cl_df_[cl_df_ == 0] <- NA
cl_df_[cl_df_ == "Unknown"] <- NA

# Convert DownTime to numeric
cl_df_$DownTime <- as.numeric(cl_df_$DownTime)

# Check for missing values
missing_values <- sum(is.na(cl_df_$DownTime))
print(missing_values)

# Check for negative or zero values
invalid_values <- cl_df_ %>% filter(DownTime <= 0)
print(invalid_values)

# Remove extreme outliers (e.g., using 1.5*IQR rule)
Q1 <- quantile(cl_df_$DownTime, 0.25)
Q3 <- quantile(cl_df_$DownTime, 0.75)
IQR_value <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR_value
upper_bound <- Q3 + 1.5 * IQR_value

# Filter out extreme outliers
df_clean <- cl_df_ %>% filter(DownTime >= lower_bound & DownTime <= upper_bound)

# Display cleaned summary
summary(df_clean$DownTime)

# Save cleaned data
write.csv(df_clean, "hackingData_cleaned.csv", row.names = FALSE)

#---------------Objective--------------------
#Analysis 3-1
#(a) Group losses by downtime ranges
df_clean <- df_clean %>%
  mutate(Downtime_Category = case_when(
    DownTime < 1 ~ "Short (<1 hour)",
    DownTime >= 1 & DownTime < 5 ~ "Moderate (1-5 hours)",
    DownTime >= 5 & DownTime < 24 ~ "Long (5-24 hours)",
    DownTime >= 24 ~ "Critical (24+ hours)"
  ))

# View downtime categories
table(df_clean$Downtime_Category)

#(b) Calculate average and total losses per downtime period
downtime_loss_summary <- df_clean %>%
  group_by(Downtime_Category) %>%
  summarise(
    Avg_Loss = mean(Loss, na.rm = TRUE),
    Total_Loss = sum(Loss, na.rm = TRUE),
    Count = n()
  ) %>%
  arrange(desc(Total_Loss))

print(downtime_loss_summary)

#(c) Identify critical downtime thresholds
ggplot(df_clean, aes(x = DownTime, y = Loss)) +
  geom_point(alpha = 0.5, color = "blue") +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Downtime vs. Financial Loss", x = "Downtime (hours)", y = "Loss ($)") +
  theme_minimal()

#Analysis 3-2
#(a) Analyze downtime-related losses across years
df_clean$Year <- year(df_clean$Date)

yearly_loss_summary <- df_clean %>%
  group_by(Year) %>%
  summarise(
    Avg_Downtime = mean(DownTime, na.rm = TRUE),
    Total_Loss = sum(Loss, na.rm = TRUE)
  )

print(yearly_loss_summary)

#(b) Track changes in downtime impact patterns
df_clean %>%
  group_by(Year) %>%
  summarise(Avg_Loss = mean(Loss, na.rm = TRUE)) %>%
  ggplot(aes(x = Year, y = Avg_Loss)) +
  geom_line(color = "blue", linewidth = 1) +
  labs(title = "Trend of Average Loss Over Time", x = "Year", y = "Average Loss") +
  theme_minimal()

#(c) Identify Trends in Downtime Severity
df_clean <- df_clean %>%
  mutate(Downtime_Severity = case_when(
    DownTime < 1 ~ "Low (<1 hr)",
    DownTime >= 1 & DownTime < 5 ~ "Medium (1-5 hrs)",
    DownTime >= 5 & DownTime < 24 ~ "High (5-24 hrs)",
    DownTime >= 24 ~ "Critical (24+ hrs)"
  ))

# Check distribution
table(df_clean$Downtime_Severity)

#Severity over time
downtime_severity_trends <- df_clean %>%
  group_by(Year, Downtime_Severity) %>%
  summarise(Count = n()) %>%
  ungroup()

print(downtime_severity_trends)

#Analysis 3-3
#(a) Categorize downtime into different ranges
df_clean <- df_clean %>%
  mutate(Downtime_Category = case_when(
    DownTime < 1 ~ "Short (<1 hour)",
    DownTime >= 1 & DownTime < 5 ~ "Moderate (1-5 hours)",
    DownTime >= 5 & DownTime < 24 ~ "Long (5-24 hours)",
    DownTime >= 24 ~ "Critical (24+ hours)"
  ))

#(b) Calculate the average and total loss per downtime range
df_loss_summary <- df_clean %>%
  group_by(Downtime_Category) %>%
  summarise(
    Avg_Loss = mean(Loss, na.rm = TRUE),
    Total_Loss = sum(Loss, na.rm = TRUE),
    Count = n()
  )

#(c) Identify which downtime category contributes the most to total losses
df_loss_summary %>%
  arrange(desc(Total_Loss))

#Analysis 3-4
#(a) Analyze the trend of downtime-related losses across years
df_yearly <- df_clean %>%
  mutate(Year = year(Date)) %>%
  group_by(Year) %>%
  summarise(
    Avg_Downtime = mean(DownTime, na.rm = TRUE),
    Avg_Loss = mean(Loss, na.rm = TRUE),
    Total_Loss = sum(Loss, na.rm = TRUE)
  )

#(b) Compare yearly downtime trends with financial impact
ggplot(df_yearly, aes(x = Year)) +
  geom_col(aes(y = Avg_Loss), fill = "blue", alpha = 0.6) + 
  geom_line(aes(y = Avg_Downtime * 10000), color = "red", size = 1) + 
  labs(
    title = "Yearly Trend of Downtime and Financial Loss",
    x = "Year",
    y = "Financial Loss ($)",
    caption = "Red line: Avg Downtime (scaled up for visibility)"
  ) +
  theme_minimal()

#(c) Identify years where downtime had the most significant financial impact
df_yearly %>%
  arrange(desc(Avg_Loss)) %>%
  head(5)  # Show the top 5 years with the highest average loss