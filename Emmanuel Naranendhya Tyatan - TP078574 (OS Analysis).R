# Emmanuel Naranendhya Tyatan (TP078574)

# Load required libraries
install.packages("ggforce")
library(dplyr)
library(tidyverse)
library(ggplot2)
library(tools)
library(ggforce)

setwd("C:/Users/LENOVO/Downloads")
os_data <- read.csv("Clean_Loss_Data.csv")


#1. DATA CHECKING
#1.1 #Checking unique values
str(os_data$OS)
unique(os_data$OS)

#1.2 Check NA values 
na_count <- sum(is.na(os_data$OS))
cat("\nNumber of NA values before:", na_count)

missing_percentage <- round(((na_count / length(os_data$OS)) * 100),4)
cat("\nMissing Percentage : ", missing_percentage,"%\n")

#1.3 Checking for Whitespaces
# 1. Check for leading whitespace (spaces at the start)
leading_space <- sum(grepl("^\\s+",os_data$OS))
cat("\nEntries with leading whitespace:", leading_space, "\n")

# 2. Check for trailing whitespace (spaces at the end)
trailing_space <- sum(grepl("\\s+$",os_data$OS))
cat("Entries with trailing whitespace:", trailing_space, "\n")

# 3. Check for multiple spaces between words
middle_space <- sum(grepl("\\s{2,}",os_data$OS))
cat("Entries with extra spaces between words:", middle_space, "\n")

cat("Summary of whitespaces checking: 
Entries with leading whitespace:", leading_space,
    "\nEntries with trailing whitespace:", trailing_space,
    "\nEntries with extra spaces between words:", middle_space)


#2. DATA CLEANING
#2.1 Imputation Using MODE
#2.1.1 Imput Mode to the missing value 
getMode <- function(x) {
  uniqx <- unique(x)
  uniqx[which.max(tabulate(match(x, uniqx)))]
}

#2.1.2 Get mode of OS
os_mode <- getMode(os_data$OS)
cat("\nMode value:", os_mode)

#2.1.3 Replace NA with mode
os_data$OS[is.na(os_data$OS)] <- os_mode

#2.1.4 Check if imputation worked
cat("\nMissing values after:", sum(is.na(os_data$OS)))

#2.2 Standardize mispellings names
cat("Initial unique values:", length(unique(os_data$OS)))
os_data$OS <- trimws(os_data$OS)  # Remove extra spaces

os_data$OS <- case_when(
  os_data$OS %in% c("Unknown", "unknown", "Unkno") ~ "Unknown",
  
  # Windows Family
  os_data$OS %in% c("windows", "WINDOWS", "Windows", "win") ~ "Windows",
  os_data$OS %in% c("Win 2003", "Windows 2003", "Microsoft Windows Server 2003", "Microsoft Windows Server 2003 Enterprise Edition","Win .NET" ) ~ "Windows Server 2003",
  os_data$OS %in% c("Win XP", "Windows XP") ~ "Windows XP",
  os_data$OS %in% c("Win 2000", "Windows 2000") ~ "Windows 2000",
  os_data$OS %in% c("Win 2008", "Windows 2008") ~ "Windows Server 2008",
  os_data$OS %in% c("Win 2012", "Windows 2012") ~ "Windows Server 2012",
  os_data$OS %in% c("Win NT9x", "NT4Windows 98") ~ "Windows NT",
  os_data$OS %in% c("Windows 2", "Windows N") ~ "Windows",
  os_data$OS =="Windows X" ~ "Windows 10",
  grepl("Server 2003.*SP", os_data$OS) ~ "Windows Server 2003",
  grepl("Server 2008.*R2.*Windows 8", os_data$OS) ~ "Windows Server 2008",
  grepl("Vista SP2.*Windows 7", os_data$OS) ~ "Windows Vista",
  grepl("Microsoft Windows.*7|Phone|Vista|2008", os_data$OS) ~ "Windows 7",
  grepl("Microsoft Windows Phone", os_data$OS) ~ "Windows Phone",
  grepl("Windows.*PocketPC|Windows.*CE", os_data$OS) ~ "Windows CE",
  
  # Linux Family
  os_data$OS %in% c("linux", "LINUX") ~ "Linux",
  
  # Unix Family
  os_data$OS %in% c("Unix", "UNIX") ~ "Unix",
  os_data$OS %in% c("SCO Unix", "SCO UNIX") ~ "SCO UNIX",
  os_data$OS %in% c("Digital Unix", "Digital UNIX") ~ "Digital UNIX",
  os_data$OS %in% c("Tru64", "Compaq Tru64") ~ "Tru64 UNIX",
  os_data$OS == "SolarisSunOS" ~ "SunOS",
  os_data$OS %in% c("Solaris", "Solar") ~ "Solaris",
  os_data$OS %in% c("Solaris 9/10", "Solaris 8") ~ "Solaris",
  
  # BSD Family
  os_data$OS %in% c("BSDI", "BSDi", "BSDOS") ~ "BSD",
  os_data$OS %in% c("FreeBSD", "FreeBsd", "FreeBsD", "FreeB") ~ "FreeBSD",
  os_data$OS %in% c("OpenBSD", "OpenBsd") ~ "OpenBSD",
  os_data$OS %in% c("NetBSD", "NetBs", "NetBS") ~ "NetBSD",
  os_data$OS == "NetBSD and OpenBSD" ~ "BSD",
  
  # Mac Family
  os_data$OS %in% c("MacOS", "MacOSX") ~ "MacOS",
  
  # Other Systems
  os_data$OS == "IRIX" ~ "IRIX",
  os_data$OS %in% c("AIX", "Aix", "IBM AIX") ~ "AIX",
  os_data$OS == "HP-UX" ~ "HP-UX",
  os_data$OS == "NovellNetware" ~ "Novell Netware",
  os_data$OS == "OS2" ~ "OS/2",
  os_data$OS == "VM" ~ "Virtual Machine",
  os_data$OS == "Citri" ~ "Citrix",
  
  #Network/Security Devices - remove version numbers
  grepl("Cisco PIX", os_data$OS) ~ "Cisco PIX OS",
  grepl("Cisco IOS", os_data$OS) ~ "Cisco IOS",
  grepl("Juniper.*JUNOS", os_data$OS) ~ "Juniper JUNOS",
  grepl("Juniper.*IVE", os_data$OS) ~ "Juniper IVE",
  grepl("BlueC Coat", os_data$OS) ~ "Blue Coat SG0S",
  grepl("Android", os_data$OS) ~ "Android",
  grepl("iPXE", os_data$OS) ~ "IPXE",
  grepl("FreeNAS", os_data$OS) ~ "FreeBSD",
  os_data$OS %in% c("F5 Bi", "F5 Big-IP", "F5 BIG-IP") ~ "F5 BIG-IP",
  
  
  # Embedded/Network Devices
  grepl("embedded|LaserJet|NAS device|adapter|gateway", os_data$OS, ignore.case = TRUE) ~ "Embedded System",
  grepl("Creston|Dish Network|device|system", os_data$OS) ~ "Embedded System",
  grepl("router|WAP|switch|modem|adapter", os_data$OS, ignore.case = TRUE) ~ "Network Device",
  
  # Keep original if no match
  TRUE ~ os_data$OS
)

# 4. Check results
cat("\nFinal unique values:", length(unique(os_data$OS)))
print(sort(unique(os_data$OS)))


##ANALYSIS TEST
#Objective 2: To examine the relationship between operating system and Loss
analysis_data <- data.frame(
  Loss = os_data$Loss,
  OS_Groups1 = os_data$OS,  
  Date = os_data$Date
)

# Analysis 2.1: Which operating system are associated with highest losses?
os_loss_summary <- analysis_data %>%   #Group by OS
  group_by(OS_Groups1) %>%
  summarise(
    total_loss = sum(Loss, na.rm = TRUE),
    avg_loss = mean(Loss, na.rm = TRUE),
    attack_count = n(),
    sd_loss = sd(Loss, na.rm = TRUE)
  ) %>%
  arrange(desc(total_loss))

#Visualize the total loss using bar chart
ggplot(head(os_loss_summary, 10), aes(x = reorder(OS_Groups1, -total_loss), y = total_loss)) + 
  geom_bar(stat = "Identity", fill = "steelblue") +
  theme_minimal() + 
  labs(
  title = "Top 10 Operating System by Total Loss",
  x = "Operating System",
  y = "Total Loss ($)") +
  
  scale_y_continuous(labels = scales::comma) +
  geom_text(aes(label = scales::comma(round(total_loss))),
            vjust = -0.5,
            size = 3) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.margin = margin(t = 20,r=20,b=20,l=20),
        plot.background = element_rect(fill = "white", color = NA))
                       

# Analysis 2.2: Has OS vulnerability changed over time
os_data$Date <- as.Date(os_data$Date)
  
date_check <- os_data %>%
  summarise(
    missing_dates = sum(is.na(Date)),
    unique_dates = n_distinct(Date),
    earliest_dates = min(Date),
    latest_dates = max(Date)
  )
print(date_check)

yearly_os_losses <- analysis_data %>%
  mutate(Date = as.Date(Date),Year = format(Date, "%Y")) %>%
  group_by(Year, OS_Groups1) %>%
  summarise(
    total_loss = sum(Loss, na.rm = TRUE),
    avg_loss = mean(Loss, na.rm = TRUE),
    attack_count = n(),
    .groups = "drop"
  ) %>%
  arrange(Year, desc(total_loss))

#Visualization Using Line Chart
ggplot(yearly_os_losses, 
       aes(x = Year, 
           y = total_loss, 
           color = OS_Groups1, 
           group = OS_Groups1)) +
  geom_line(linewidth = 1) +  
  geom_point(size = 3) +    
  theme_minimal() +
  labs(
    title = "Financial Impact by Operating System Over Time (1998-2015)",
    x = "Year",
    y = "Total Loss ($)",
    color = "Operating System"
  ) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_discrete(breaks = seq(1998, 2016, 2)) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 8),
    legend.key.size = unit(0.8, "lines"),
    legend.box = "vertical",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    plot.margin = margin(t = 20, r = 120, b = 20, l = 20),
    legend.spacing.y = unit(0.5, "lines"),
    
    guides(color = guide_legend(ncol = 2))
  )

# Track changes in OS vulnerability pattern
#Group the data
os_data$OS_Group <- case_when(
  # Windows Family
  grepl("Win", os_data$OS) ~ "Windows",
  
  # Unix/Linux Family (including Solaris)
  grepl("Linux", os_data$OS) ~ "Linux",
  
  os_data$OS %in% c("Unix", "AIX", "HP-UX", 
                    "SCO UNIX", "Digital UNIX", "Tru64 UNIX") ~ "Unix",
  
  os_data$OS %in% c("Solaris", "SunOS") ~ "Solaris",
  
  # BSD Family
  grepl("BSD", os_data$OS) ~ "BSD",
  
  # Embedded/Network
  grepl("Cisco|Juniper|F5|Blue Coat", os_data$OS) ~ "Network Devices", 
  
  grepl("Embedded|Creston|IPXE", os_data$OS) ~ "Embedded System",
  
  grepl("MacOS", os_data$OS) ~ "Mac",
  
  #Unknown Value
  grepl("Unknown", os_data$OS) ~ "Unknown",
  
  # Any remaining
  TRUE ~ "Others"
)

table(os_data$OS_Group)

analysis_data <- data.frame(
  Loss = os_data$Loss,
  OS_Groups1 = os_data$OS,
  OS_Groups2 = os_data$OS_Group,
  Date = os_data$Date
)

yoy_changes <- analysis_data %>%
  mutate(Year = format(Date, "%Y")) %>%  # Extract year from date
  group_by(Year, OS_Groups2) %>%         # Group by Year and OS
  summarise(
    TotalLoss = sum(Loss, na.rm = TRUE)  # Calculate total loss per year/OS
  ) %>%
  group_by(OS_Groups2) %>%               # Group by OS for YoY calculation
  arrange(Year) %>%
  mutate(
    YoYChange = (TotalLoss - lag(TotalLoss)) / lag(TotalLoss) * 100
  ) %>%
  ungroup()

# Create heatmap
p2 <- ggplot(yoy_changes, aes(x = Year, y = OS_Groups2, fill = YoYChange)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0,
    name = "Year-over-Year\nChange in Losses (%)",
    limits = c(-100, 100),
    oob = scales::squish
  ) +
  theme_minimal() +
  labs(
    title = "Year-over-Year Changes in OS Vulnerabilities",
    subtitle = "Red indicates increase in losses, blue indicates decrease",
    x = "Year",
    y = "Operating System"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right",
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )
p2


# Analysis 2.3: Is there a relationship between OS popularity and loss severity?
# Compare OS market share with loss pattern 
os_market_share <- analysis_data %>%
  filter(!is.na(OS_Groups1))%>%
  group_by(OS_Groups1) %>%
  summarise(
    attack_count= n(),
    market_share = n() / nrow(analysis_data) * 100,
    total_loss = sum(Loss, na.rm = TRUE),
    avg_loss = mean(Loss, na.rm = TRUE),
    .groups = "drop"
    ) %>%
  arrange(desc(market_share))

# Analyze if popular OS face higher Losses
popularity_loss <- os_market_share %>%
  mutate(
    loss_per_share = total_loss / market_share,
    popularity_category = case_when(
      market_share > mean(market_share) + sd(market_share) ~ "Very Popular",
      market_share > mean(market_share) ~ "Popular",
      market_share < mean(market_share) - sd(market_share) ~ "Rare",
      TRUE ~ "Less Popular"
    )
  )

#Visualization
ggplot(popularity_loss, aes(x = market_share, y = total_loss)) +
  geom_point(aes(size = attack_count, color = popularity_category), alpha = 0.7) +
  scale_size_continuous(range = c(4,15)) +
  scale_y_continuous(
    labels = scales::comma_format(),
    breaks = seq(0, 3e8, by = 5e7)
  ) +
  theme_minimal() +
  labs(
    title = "OS Market Share vs Losses Analysis",
    subtitle = "Bubble Size: Attack Count",
    x = "Market Share (%)",
    y = "Total Loss",
    size = "Attack Count",
    color = "Popularity Category"
  )


# Analysis 4: How does OS patch level affect financial losses
# Identify version numbers and patch status
os_version_analysis <- analysis_data %>%
  mutate(
    version_number = str_extract(OS_Groups1, "\\d+(\\.\\d+)*"),
    patch_status = case_when(
      grepl("SP|update|patch|current", OS_Groups1, ignore.case = TRUE) ~ "Patched",
      grepl("\\d+(\\.\\d+)*", OS_Groups1) &
        !grepl("unpatched|vulnerable|old", OS_Groups1, ignore.case = TRUE) ~ "Patched",
      TRUE ~ "Unpatched"
    )
  ) %>%
  group_by(OS_Groups1, patch_status) %>%
  summarise(
    total_loss = sum(Loss,na.rm = TRUE),
    avg_loss = mean(Loss, na.rm = TRUE),
    attack_count = n(),
    .groups = "drop"
  )

# Compare Losses between patched and unpatched system
patch_comparison <- os_version_analysis %>%
  group_by(patch_status) %>%
  summarise(
    total_loss = sum(total_loss),
    avg_loss = mean(avg_loss),
    attack_count = sum(attack_count)
  )

#Visualization
ggplot(os_version_analysis, 
       aes(x = OS_Groups1, y = avg_loss, fill = patch_status)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(
    title = "Average Losses: Patched vs Unpatched Systems",
    x = "Operating System Group",
    y = "Average Loss ($)",
    fill = "Patch Status"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
