# Visualisation data

This document records where the visualisation data for each item in data directory was collected from and what, if 
any processing (manual) that was done to that data.


## Line and bar charts

### Air quality

The source webpage for the data is [https://www.gov.uk/government/statistics/air-quality-statistics/days-with-moderate-or-higher-air-pollution-includes-sulphur-dioxide](https://www.gov.uk/government/statistics/air-quality-statistics/days-with-moderate-or-higher-air-pollution-includes-sulphur-dioxide)

The visualisation data was downloaded from here [https://assets.publishing.service.gov.uk/media/685bb9e341d77db4f68eb18e/fig17_urban_days_above_moderate.csv](https://assets.publishing.service.gov.uk/media/685bb9e341d77db4f68eb18e/fig17_urban_days_above_moderate.csv)

And the "Location column" was removed to create [air-quality/air-quality.csv](air-quality/air-quality.csv)

The file [air-quality/air-quality.json](air-quality/air-quality.json) uses the data from the csv file as it's `series.data` object


### Average house prices

The source webpage for the data is [https://www.gov.uk/government/statistical-data-sets/uk-house-price-index-data-downloads-december-2025](https://www.gov.uk/government/statistical-data-sets/uk-house-price-index-data-downloads-december-2025)

The visualisation data was downloaded from here [https://publicdata.landregistry.gov.uk/market-trend-data/house-price-index-data/Average-prices-2025-12.csv](https://publicdata.landregistry.gov.uk/market-trend-data/house-price-index-data/Average-prices-2025-12.csv)

The download contains records for all UK regions and local authorities. Only the rows for England, Wales, Scotland, and United Kingdom were kept. The Area_Code, Monthly_Change, Annual_Change, and Average_Price_SA columns were also discarded, leaving just Date, Region_Name, and Average_Price to create [average-house-prices/average-house-prices.csv](average-house-prices/average-house-prices.csv)

The file [average-house-prices/average-house-prices.json](average-house-prices/average-house-prices.json) uses the data from the csv file as its `series.data` objects, with `Average_Price` divided by 1000 (`number_base`). Average_Price was used rather than Average_Price_SA (seasonally adjusted) because the SA data only starts from 1995 and over this long a time frame the difference is negligible.

### Births

The source webpage for the data is [https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/bulletins/birthsummarytablesenglandandwales/2024refreshedpopulations](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/bulletins/birthsummarytablesenglandandwales/2024refreshedpopulations)

The visualisation data was downloaded via a form on that page which triggers a download of [https://www.ons.gov.uk/visualisations/dvc3343/fig1wrapper/datadownload.xlsx](https://www.ons.gov.uk/visualisations/dvc3343/fig1wrapper/datadownload.xlsx)

The Year and Number of Live Births columns were extracted from the xlsx to create [births/live-births-england-and-wales-1938-2024.csv](births/live-births-england-and-wales-1938-2024.csv)

The file [births/live-births-england-and-wales-1938-2024.json](births/live-births-england-and-wales-1938-2024.json) uses the data from the csv file as its `series.data` object.

### Fuel and oil prices

The source webpage for the data is [https://www.gov.uk/government/statistical-data-sets/oil-and-petroleum-products-monthly-statistics](https://www.gov.uk/government/statistical-data-sets/oil-and-petroleum-products-monthly-statistics)

The visualisation data was downloaded from here [https://assets.publishing.service.gov.uk/media/699c5d8931713b50fd49c045/table_411_413__6_.xlsx](https://assets.publishing.service.gov.uk/media/699c5d8931713b50fd49c045/table_411_413__6_.xlsx)

Table 4.1.2 was extracted from the xlsx. The metadata pre-header rows were removed and all columns other than Year, Motor spirit (Premium unleaded / ULSP) and Derv (Diesel / ULSD) pence per litre were dropped to create [fuel-and-oil-prices/fuel-and-oil-prices.csv](fuel-and-oil-prices/fuel-and-oil-prices.csv)

The file [fuel-and-oil-prices/fuel-and-oil-prices.json](fuel-and-oil-prices/fuel-and-oil-prices.json) uses the data from the csv file as its `series.data` objects.


### Inflation

The source webpage for the data is [https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/l55o/mm23](https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/l55o/mm23)

The visualisation data was generated via [https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l55o/mm23](https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l55o/mm23)

The resulting CSV contains metadata header rows and three time series (annual, quarterly, and monthly rates). Only the quarterly rates were extracted to create [inflation/inflation-1989-2025.csv](inflation/inflation-1989-2025.csv)

The file [inflation/inflation.json](inflation/inflation.json) uses the data from the csv file as its `series.data` object.


### Storm overflows

> [!WARNING]
> The number of overflows being monitored increased dramatically over this period (from 862 in 2016 to 14,182 in 2024). The apparent rise in total spill events will be influenced by this expanded monitoring coverage, and not solely by an increase in spill frequency. This context isn't clear from visualisation data alone.

The source webpage for the data is [https://environment.data.gov.uk/dataset/21e15f12-0df8-4bfc-b763-45226c16a8ac](https://environment.data.gov.uk/dataset/21e15f12-0df8-4bfc-b763-45226c16a8ac)

The visualisation data was downloaded from that dataset. The `Total monitored spill events (thousands)` and `Overflows monitored` columns were kept for years 2016 to 2024 to create [storm-overflows/storm-overflows.csv](storm-overflows/storm-overflows.csv)

The file [storm-overflows/storm-overflows.json](storm-overflows/storm-overflows.json) uses the data from the csv file as its `series.data` object. Only the `Total monitored spill events (thousands)` column is used in the visualisation. The `Overflows monitored` column is retained in the CSV for context.


### UK mean temperature

The source webpage for the data is [https://www.metoffice.gov.uk/research/climate/maps-and-data/uk-and-regional-series](https://www.metoffice.gov.uk/research/climate/maps-and-data/uk-and-regional-series)

The visualisation data was downloaded from that page (UK mean temperature, annual series).

No processing was required — the Year and Annual mean temperature columns were extracted directly to create [weather/uk-mean-temperature.csv](weather/uk-mean-temperature.csv)

The file [weather/uk-mean-temperature.json](weather/uk-mean-temperature.json) uses the data from the csv file as its `series.data` object.

#### Alternative: UK monthly max temperature at 25-year intervals

An alternative multi-series visualisation is also available, using monthly maximum temperature data instead of annual mean.

The data was downloaded from [https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmax/date/UK.txt](https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Tmax/date/UK.txt)

The monthly Tmax values (Jan–Dec) were extracted for the years 1900, 1925, 1950, 1975, 2000, and 2025 to create [weather/uk-monthly-max-temperature.csv](weather/uk-monthly-max-temperature.csv)

The file [weather/uk-monthly-max-temperature.json](weather/uk-monthly-max-temperature.json) uses the data from the csv file, with each year as a separate series. This shows how the seasonal temperature profile has shifted over 125 years (the warming is particularly visible in spring and autumn months).

**Note:** Individual years can be anomalous, so a more robust approach would be to use decade averages (e.g. 1900s, 1920s, 1940s, etc.) rather than single-year snapshots. Worth exploring if there's interest.


### Woodland area

The source webpage for the data is [https://www.forestresearch.gov.uk/tools-and-resources/statistics/data-downloads/](https://www.forestresearch.gov.uk/tools-and-resources/statistics/data-downloads/)

The visualisation data was downloaded from there (woodland area statistics).

The `Year` and `UK total (thousand hectares)` columns were extracted for years 2005 to 2025 to create [forest-and-woodlands/woodland-area.csv](forest-and-woodlands/woodland-area.csv). 

Values represent the cumulative total woodland area in the UK at each year, **not new** woodland planted that year.

The file [forest-and-woodlands/woodland-area.json](forest-and-woodlands/woodland-area.json) uses the data from the csv file as its `series.data` object.


### UK Trade

The source webpage for the data is [https://www.gov.uk/government/statistics/uk-trade-in-numbers/uk-trade-in-numbers-web-version](https://www.gov.uk/government/statistics/uk-trade-in-numbers/uk-trade-in-numbers-web-version)

The visualisation data was extracted from an .ods download file on ONS date from that page.

[https://assets.publishing.service.gov.uk/media/698eec9975466636847f6ab9/uk-exports-and-imports-seasonally-adjusted-current-prices.ods](https://assets.publishing.service.gov.uk/media/698eec9975466636847f6ab9/uk-exports-and-imports-seasonally-adjusted-current-prices.ods)
 
The data was saved here as a csv file:

[uk-trade/total-uk-imports-exports.csv](uk-trade/total-uk-imports-exports.csv). Note the original source data contains the values in millions but in the saved download data and
the graph itself this was divided by the number base 1000 to give the number in billions.



The file [uk-trade/total-uk-imports-exports-2010-2025.json](uk-trade/total-uk-imports-exports-2010-2025.json) uses the data from the csv file as its two `series` objects. 

### Social mobility

The source webpage for the data is [https://social-mobility.data.gov.uk/intermediate_outcomes/work_in_early_adulthood_(25_to_29_years)/unemployment/latest](https://social-mobility.data.gov.uk/intermediate_outcomes/work_in_early_adulthood_(25_to_29_years)/unemployment/latest)

The visualisation data was from a CSV download file on the page above:

[https://social-mobility.data.gov.uk/intermediate_outcomes/work_in_early_adulthood_(25_to_29_years)/unemployment/3.0/IN32-3.0-unemployment--by-SEB--table-format.csv](https://social-mobility.data.gov.uk/intermediate_outcomes/work_in_early_adulthood_(25_to_29_years)/unemployment/3.0/IN32-3.0-unemployment--by-SEB--table-format.csv)
 
The data was save here as a csv file:

[social-mobility/unemployment-by-socio-ecomomic-background.csv](social-mobility/unemployment-by-socio-ecomomic-background.csv)


The file [social-mobility/unemployment-by-socio-ecomomic-background.json](social-mobility/unemployment-by-socio-ecomomic-background.json) uses the data from the csv file as its data object for a bar chart.

***


## Headline figures

## Get company information

The source webpage for the data is [https://www.gov.uk/government/statistics/companies-register-activities-statistical-release-april-2024-to-march-2025](https://www.gov.uk/government/statistics/companies-register-activities-statistical-release-april-2024-to-march-2025)


The actual data file used to create the headlines figures was: [https://assets.publishing.service.gov.uk/media/687f74b128f29c99778a744a/Companies_register_activities_April_2024_to_March_2025.xlsx](https://assets.publishing.service.gov.uk/media/687f74b128f29c99778a744a/Companies_register_activities_April_2024_to_March_2025.xlsx)

From that the following was extracted from table A8 of the spreadsheet: []()

Note that the original table has the columns:

`Year ending, Total register, Effective register, Incorporations, Dissolved, Liquidations notified2, Insolvencies notified3`

but for our purposes we only used `Incorporations` and `Dissolved`.

The resulting csv used is here: [get-company-information/companies-register-activities-april-2024-to-march-2025.csv](get-company-information/companies-register-activities-april-2024-to-march-2025.csv)

The file [get-company-information/companies-house-register-headlines.json](get-company-information/companies-house-register-headlines.json) uses the data from the csv file as its `items` object. Note % change was calculated using the figures in csv.


## Road traffic

The source webpage for the data is [https://roadtraffic.dft.gov.uk/downloads](https://roadtraffic.dft.gov.uk/downloads)

The visualisation data was downloaded from here [https://storage.googleapis.com/dft-statistics/road-traffic/downloads/data-gov-uk/region_traffic_by_vehicle_type.csv](https://storage.googleapis.com/dft-statistics/road-traffic/downloads/data-gov-uk/region_traffic_by_vehicle_type.csv)

The download contains traffic data for all UK regions and multiple vehicle types. Only the `cars_and_taxis` and `buses_and_coaches` columns were kept, and only the "All" region rows (which sum all regions) were retained to create [road-traffic/road-traffic-2023-2024.csv](road-traffic/road-traffic-2023-2024.csv)

The file [road-traffic/road-traffic-headline.json](road-traffic/road-traffic-headline.json) uses the data from the csv file as its `items` object. Values are expressed in billion vehicle miles (raw figures divided by 1,000,000,000). Percent change was calculated using the figures in the csv.
