# Web Hacking Trends Analysis

A comprehensive data analytics project examining cybersecurity patterns and financial impacts of web defacement incidents over a 15-year period (1998-2015).

## Table of Contents

- [About the Project](#about-the-project)
- [Dataset](#dataset)
- [Research Objectives](#research-objectives)
- [Key Findings](#key-findings)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Analysis Methodology](#analysis-methodology)
- [Results](#results)
- [Contributors](#contributors)
- [License](#license)

## About the Project

This project leverages data analysis techniques to examine cyberattack trends spanning 15 years of web-based security incidents. Using R programming, we investigate relationships between attack vectors, system vulnerabilities, and financial losses to provide actionable insights for improving cybersecurity defenses.


## Dataset

The dataset comprises 212,093 observations across 12 variables documenting website defacement incidents:

| Variable | Type | Description |
|----------|------|-------------|
| Date | Date | Incident occurrence date |
| Notify | Character | Person/group reporting the incident |
| URL | Character | Compromised server URL |
| IP | Character | IP address of affected server |
| Country | Character | Server location |
| OS | Character | Operating system |
| WebServer | Character | Web server version |
| Encoding | Character | Character encoding used |
| Lang | Character | Website language |
| Ransom | Integer | Ransom amount paid (thousands) |
| DownTime | Integer | Downtime duration (days) |
| Loss | Numeric | Revenue loss incurred |

## Research Objectives

1. **Geographic Analysis**: Investigate relationships between country and financial losses
2. **Operating System Security**: Examine OS vulnerabilities and their correlation with losses
3. **Downtime Impact**: Analyze the correlation between downtime duration and financial damage
4. **Web Server Vulnerabilities**: Determine if web server versions affect attack outcomes

## Key Findings

### Geographic Distribution
- United States experienced highest total loss ($225.8M) with 82,052 attacks
- Linux systems most vulnerable with $358.7M in aggregate losses
- Attack frequency doesn't always correlate with loss severity

### Operating System Vulnerabilities
- Linux: $358.7M total losses (highest)
- Windows Server 2003: $57M losses
- Peak loss periods: 2010 ($110M) and 2013 ($130M)
- Most systems lack security patches

### Downtime-Loss Relationship
- Critical downtimes (24+ hours): $540.7M across 145,086 events
- Average loss per critical outage: $3,727
- Extended downtimes (5-24 hours): $45.2M across 67,007 events
- Positive correlation between downtime duration and financial loss

### Web Server Analysis
- Apache servers: 55.9% market share, $315.7M losses (highest)
- IIS servers: 14.5% market share, $82.5M losses
- Seasonal patterns observed with peaks in October
- Autumn season shows highest financial impact

## Technologies Used

- **R** (v4.0+)
- **Libraries**:
  - `dplyr` - Data manipulation
  - `ggplot2` - Data visualization
  - `tidyr` - Data tidying
  - `stringr` - String operations
  - `lubridate` - Date handling
  - `scales` - Visualization scaling
  - `missForest` - Missing data imputation
  - `rgeolocate` - IP geolocation
  - `corrplot` - Correlation matrices
  - `ggcorrplot` - Enhanced correlation plots

## Installation

### Prerequisites

```r
# Install required packages
install.packages(c(
  "dplyr", "ggplot2", "tidyr", "stringr", 
  "scales", "lubridate", "corrplot", 
  "ggcorrplot", "missForest", "rgeolocate"
))
```

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/web-hacking-trends-analysis.git
cd web-hacking-trends-analysis
```

2. Load the dataset:
```r
raw_data <- read.csv("hackingData.csv")
```

3. Run the analysis scripts in sequence:
```r
source("data_preparation.R")
source("analysis.R")
```

## Project Structure

```
web-hacking-trends-analysis/
│
├── data/
│   ├── hackingData.csv              # Raw dataset
│   └── Clean_Loss_Data.csv          # Processed dataset
│
├── scripts/
│   ├── data_preparation.R           # Data cleaning and preprocessing
│   ├── country_analysis.R           # Geographic analysis
│   ├── os_analysis.R                # Operating system analysis
│   ├── downtime_analysis.R          # Downtime correlation analysis
│   └── webserver_analysis.R         # Web server vulnerability analysis
│
├── outputs/
│   ├── figures/                     # Generated visualizations
│   └── results/                     # Statistical outputs
│
├── docs/
│   └── PFDA_Group_Assignment_Group15.pdf  # Full report
│
└── README.md
```

## Analysis Methodology

### Data Preparation

1. **Missing Value Treatment**:
   - Loss variable: 16% missing, imputed using Random Forest
   - MCAR testing performed (p < 0.05)
   - Correlation analysis with Date and Downtime

2. **Data Cleaning**:
   - Standardized country names
   - IP address formatting (IPv4/IPv6)
   - Geolocation imputation using MaxMind GeoLite2
   - OS and WebServer normalization
   - Outlier detection using IQR method

3. **Feature Engineering**:
   - Date parsing and temporal feature extraction
   - Categorical variable standardization
   - Duplicate removal

### Statistical Analysis

- **Generalized Linear Model (GLM)**: Testing relationships between Loss and independent variables
- **Correlation Analysis**: Spearman and Pearson methods
- **Temporal Analysis**: Year-over-year and seasonal trend analysis
- **Outlier Analysis**: IQR-based detection and impact assessment

## Results

### Hypothesis Testing (GLM)

**Null Hypothesis (H₀)**: No significant combined relationship between independent variables (Month, Year, Season, OS, WebServer, Country, Downtime) and Loss.

**Findings**:
- Month^8: p = 0.0101 (Significant)
- Creston XPanel Control System: p = 0.0046 (Significant)
- Host Install NginX: p = 0.0029 (Highly Significant)
- Specific web servers show significant impact on losses
- Year and Country show no strong influence

**Conclusion**: Reject null hypothesis. Seasonal trends, specific OS configurations, and web server setups significantly impact financial losses.

## Contributors

| Name | Student ID | Role |
|------|-----------|------|
| Faiyad Mahabub Tasin | TP077983 | Team Leader, Country Analysis |
| Emmanuel Naranendhya Tyatan | TP077873 | OS Analysis, Data Preparation |
| Lau Wei Wen | TP079439 | Downtime Analysis |
| Yuke Liew Nyuk Kee | TP079074 | Web Server Analysis, Introduction |

**Institution**: Asia Pacific University of Technology & Innovation

## License

This project is submitted as academic coursework for CT127-3-2-PFDA (Programming for Data Analysis). All rights reserved by the contributors and Asia Pacific University.

## Acknowledgments

- MaxMind for GeoLite2 geolocation database
- Asia Pacific University for academic guidance
- Open-source R community for package development

---
