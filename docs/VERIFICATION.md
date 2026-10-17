# Verification record

17 October 2026. Windows PowerShell; R 4.4.2 (ucrt), Python 3.10.9/PyMuPDF for report inspection. No packages installed, no external geolocation calls and no incident-data processing.

## Executed offline R check

```powershell
& 'C:/Program Files/R/R-4.4.2/bin/Rscript.exe' --vanilla docs/verify_sources.R
```

Expected current exit: **1**, for a real existing syntax failure. All three `.R` scripts parse: OS 51 expressions, downtime 51, web server 84. Loss Cleaning Rmd parses all 36 extracted chunks. Country Rmd fails on `country_clean$ <- as.Date(asm_data$Date)` at original source line 565 (extracted code line 349). The source remains unchanged; this failure stays visible.

The original OS `getMode` helper executes successfully on `c("Linux", "Windows", "Linux")`, returning `Linux`. This is explicitly a synthetic helper smoke check, not incident-analysis evidence. Full scripts are not sourced because they install packages, use machine-specific paths and require absent data.

All checked package namespaces are available: dplyr, ggplot2, tidyr, stringr, lubridate, scales, missForest, rgeolocate, corrplot, ggcorrplot and knitr. R emits existing startup locale warnings for LC_COLLATE/CTYPE/MONETARY/TIME=C.UTF-8; they do not prevent the checks.

Missing inputs: `hackingData.csv`, `Clean_Loss_Data.csv`, `GeoLite2-Country.mmdb`. End-to-end execution, cleaning outputs and numerical findings are blocked.

## Figure provenance

Opened the 80-page retained PDF with PyMuPDF and inspected report pages 32-36 and its group workload section. `assets/historical-country-analysis.png` is a scale-2 render of page 36's existing chart, crop coordinates (65,73,545,367). The historical chart was visually inspected. It contains only country aggregates, not individual incident URLs/IPs. Its counts and loss annotations are different units; the README qualifies this. No new data-driven chart or metric was invented.

The original long README remains in `PROJECT_GUIDE.md`, marked as an archive with inaccurate old structure/setup and unverified interpretations. Current README links match the actual source/report filenames. No data or original analysis code changed.
