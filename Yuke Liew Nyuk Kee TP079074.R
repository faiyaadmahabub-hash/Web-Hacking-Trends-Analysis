install.packages(c("dplyr", "ggplot2", "corrplot", "maps", "reshape2"))
install.packages("ggcorrplot")
install.packages("tidyr")
install.packages("plotrix")

#Load Library
library(dplyr)
library(ggplot2)
library(corrplot)
library(maps)
library(reshape2)
library(ggcorrplot)
library(tidyr)
library(stringr)
library(scales)
library(lubridate)
library(plotrix)

getwd()
setwd("C:/Users/yukel/OneDrive/Documents/PFDA/assignment")
asm_data <- read.csv("Clean_Loss_Data.csv", encoding = "ISO-8859-1")


View(asm_data)
nrow(asm_data)
ncol(asm_data)
head(asm_data)
tail(asm_data)
str(asm_data)
colnames(asm_data)
class(asm_data)
summary(asm_data)

unique(asm_data$Date)
unique(asm_data$WebServer)

#Clean variable Date
asm_data$Date <- as.Date(asm_data$Date, format = "%Y-%m-%d")
asm_data<- asm_data %>%
  mutate(Year = lubridate::year(Date))

#View unique values of variables         
unique(asm_data$Date)
length(unique(asm_data$Date))
unique(asm_data$Year) 

#Clean variable WebServer
# Convert to lowercase
asm_data$WebServer <- str_to_lower(asm_data$WebServer)

# Remove version numbers (if not needed)
asm_data$WebServer <- str_replace(asm_data$WebServer, "/.*", "")

# Correct typos and inconsistencies
asm_data$WebServer <- str_replace(asm_data$WebServer, "ideawebse", "ideawebserver")

# Remove special characters
asm_data$WebServer <- str_replace_all(asm_data$WebServer, "[^[:alnum:]]", "")
asm_data <- asm_data %>% filter(WebServer!= "")

# Group generic names
asm_data$WebServer[asm_data$WebServer %in% c("webserver", "website")] <- "other"

# Group similar servers
asm_data <- asm_data %>%
  mutate(
    WebServer = case_when(
      str_detect(WebServer, "unknown")~ "unknown",
      str_detect(WebServer, "apache") ~ "apache",
      str_detect(WebServer, "lighttpd") ~ "lighttpd",
      str_detect(WebServer, "nginx") ~ "nginx",
      str_detect(WebServer, "iis") ~ "iis",
      TRUE ~ "other"  # Keep the original value if no match
    )
  )

#check for the unique values for correctness
unique(asm_data$WebServer)
length(unique(asm_data$WebServer))

#Remove duplicate rows from the dataset & check number of rows of the data
asm_data <- asm_data %>% distinct()
nrow(asm_data)

#Q1
# Step 1: Group losses by web server type
loss_by_server <- asm_data %>%
  group_by(WebServer) %>%
  summarize(
    total_loss = sum(Loss),
    avg_loss = mean(Loss),
    num_attacks = n()
  )
View(loss_by_server)
# Sort by total loss in descending order
most_vulnerable <- loss_by_server %>%
  arrange(desc(total_loss))
# Print the top 10 most vulnerable servers
webserver_loss<- head(most_vulnerable, 5)
webserver_loss

# Step 2: Visualize the top 10 using a bar chart with y-axis in millions
Q1_chart <- ggplot(webserver_loss, aes(x =total_loss / 1e6, y = reorder(WebServer, total_loss))) + 
  geom_col(fill = "pink") +
  geom_text(aes(label = sprintf("%.2f", total_loss/1e6)), hjust = -0.1, size = 3.0)+
  labs(title = "Top 5 Web Servers by Total Financial Loss (in Millions)",
    x = "Total Loss (Millions)", y = "Web Server" ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#Step 3: Print the chart
print(Q1_chart)

#Q2
# Step 1: Track web server losses across years
yearly_loss_by_server <- asm_data %>%
  group_by(Year, WebServer) %>%
  summarize(total_loss = sum(Loss))
yearly_loss_by_server

# Step 2: Analyze vulnerability trends by server version
most <- yearly_loss_by_server %>%
  arrange(desc(total_loss))
most
top_servers <- head(most$WebServer, 40)
top_servers

# Step 3: Plot total losses over time for top 5 servers
Q2_chart <- ggplot(most %>% filter(WebServer %in% top_servers), aes(x = Year, y = total_loss/1e6, color = WebServer)) +
  geom_line() +
  labs(title = "Total Losses Over Time for Top 5 Web Servers", x = "Year", y = "Total Loss(in Millions)", color = "Web Server")+
  scale_y_continuous(labels = label_number(suffix = "M")) 
print(Q2_chart)
# Print the chart
print(Q2_chart)

#Q3
# Step 1: Compare server market share with loss data
server_market_share <- asm_data %>%
  group_by(WebServer) %>%
  summarize(market_share = n() / nrow(asm_data))
server_market_share
#Step 2: Examine if popular servers face higher losses
loss_and_share <- left_join(loss_by_server, server_market_share, by = "WebServer")
loss_and_share

#Step 3: plot a 3D pie 
#Calculate percentages for labels
total <- sum(loss_and_share$market_share)
percentages <- round(100 * loss_and_share$market_share / total, 4)
#Create labels with line breaks and percentages
labels <- paste(loss_and_share$WebServer, "\n", percentages,"%")
#Define pastel colors for better visualization
colors <- c("#FFB3BA", "#FFDFBA", "#FFFFBA", "#BAFFC9", "#BAE1FF", "#E0BBE4", "#D5E8D4")
#  graphical parameters to make labels bold
par(font = 1)

#Create the 3D Pie Chart
Q3_chart <- pie3D(
  x = loss_and_share$market_share, 
  labels = labels, 
  explode = 0.1, 
  main = "3D Pie Chart: Market Share vs Total Loss of Web Servers",
  labelcex = 0.8,     # Adjust font size
  labelrad = 3.0,     # Move labels outward
  start = 0.3,  
  labelpos = NULL,    # Auto-adjust label positions
  arrow.length = 0.2, # Add arrows for clarity
  col = colors, 
  border = "black",
  shade = 0.7
)
#print the chart
print(Q3_chart)

#Q4
# Step 1: Ensure Date is in correct format
asm_data$Date <- as.Date(asm_data$Date)
# Extract month and season
asm_data <- asm_data %>%
  mutate(
    Month = month(Date, label = TRUE, abbr = TRUE),  # Extract month (Jan, Feb, etc.)
    Season = case_when(
      Month %in% c("Dec", "Jan", "Feb") ~ "Winter",
      Month %in% c("Mar", "Apr", "May") ~ "Spring",
      Month %in% c("Jun", "Jul", "Aug") ~ "Summer",
      Month %in% c("Sep", "Oct", "Nov") ~ "Autumn",
      TRUE ~ "Unknown"
    )
  )
# Check unique months and seasons
unique(asm_data$Month)
unique(asm_data$Season)

# Step 2: Summarize total losses by season
seasonal_loss <- asm_data %>%
  group_by(Season) %>%
  summarize(total_loss = sum(Loss, na.rm = TRUE)) %>%
  arrange(desc(total_loss))

print(seasonal_loss)
# Summarize loss per season & web server
seasonal_server_loss <- asm_data %>%
  group_by(Season, WebServer) %>%
  summarize(total_loss = sum(Loss, na.rm = TRUE)) %>%
  arrange(Season, desc(total_loss))

print(seasonal_server_loss)

ggplot(seasonal_loss, aes(x = Season, y = total_loss/ 1e6, fill = Season)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Financial Loss by Season", x = "Season", y = "Total Loss") +
  theme_minimal()+
  scale_y_continuous(labels = label_number(suffix = "M"))

#Step 3: Plot the chart
monthly_loss_trends <- asm_data %>%
  group_by(Month, WebServer) %>%
  summarize(total_loss = sum(Loss, na.rm = TRUE))
print(monthly_loss_trends, n= 69)

ggplot(monthly_loss_trends, aes(x = Month, y = total_loss/ 1e6, color = WebServer, group = WebServer)) +
  geom_line(size = 0.6) +
  labs(title = "Monthly Financial Loss Trends by Web Server",
       x = "Month", y = "Total Loss(In Millions)",
       color = "Web Server") +
  theme_minimal()+
  scale_y_continuous(labels = label_number(suffix = "M"))