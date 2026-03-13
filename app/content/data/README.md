# Visualisation data

This document records where the visualisation data for each item in data directory was collected from and what, if 
any processing (manual) that was done to that data.

## Air quality

The source webpage for the data is [https://www.gov.uk/government/statistics/air-quality-statistics/days-with-moderate-or-higher-air-pollution-includes-sulphur-dioxide](https://www.gov.uk/government/statistics/air-quality-statistics/days-with-moderate-or-higher-air-pollution-includes-sulphur-dioxide)

The visualisation data was downloaded from here [https://assets.publishing.service.gov.uk/media/685bb9e341d77db4f68eb18e/fig17_urban_days_above_moderate.csv](https://assets.publishing.service.gov.uk/media/685bb9e341d77db4f68eb18e/fig17_urban_days_above_moderate.csv)

And the "Location column" was removed to create [air-quality/air-quality.csv](air-quality/air-quality.csv)

The file [air-quality/air-quality.json](air-quality/air-quality.json) uses the data from the csv file as it's `series.data` object


## Average house prices

The source webpage for the data is [https://www.gov.uk/government/statistical-data-sets/uk-house-price-index-data-downloads-november-2025](https://www.gov.uk/government/statistical-data-sets/uk-house-price-index-data-downloads-november-2025)

The visualisation data was downloaded from here [https://publicdata.landregistry.gov.uk/market-trend-data/house-price-index-data/Average-prices-2025-11.csv](https://publicdata.landregistry.gov.uk/market-trend-data/house-price-index-data/Average-prices-2025-11.csv)

The download contains records for all UK regions and local authorities. Only the rows for England, Wales, Scotland, and United Kingdom were kept. The Area_Code, Monthly_Change, Annual_Change, and Average_Price_SA columns were also discarded, leaving just Date, Region_Name, and Average_Price to create [average-house-prices/average-house-prices.csv](average-house-prices/average-house-prices.csv)

The file [average-house-prices/average-house-prices.json](average-house-prices/average-house-prices.json) uses the data from the csv file as its `series.data` objects, with `Average_Price` divided by 1000 (`number_base`). Average_Price was used rather than Average_Price_SA (seasonally adjusted) because the SA data only starts from 1995 and over this long a time frame the difference is negligible.

## Births

The source webpage for the data is [https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/bulletins/birthsummarytablesenglandandwales/2024refreshedpopulations](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/bulletins/birthsummarytablesenglandandwales/2024refreshedpopulations)

The visualisation data was downloaded via a form on that page which triggers a download of [https://www.ons.gov.uk/visualisations/dvc3343/fig1wrapper/datadownload.xlsx](https://www.ons.gov.uk/visualisations/dvc3343/fig1wrapper/datadownload.xlsx)

The Year and Number of Live Births columns were extracted from the xlsx to create [births/live-births-england-and-wales-1938-2024.csv](births/live-births-england-and-wales-1938-2024.csv)

The file [births/live-births-england-and-wales-1938-2024.json](births/live-births-england-and-wales-1938-2024.json) uses the data from the csv file as its `series.data` object.

## Fuel and oil prices

The source webpage for the data is [https://www.gov.uk/government/statistical-data-sets/oil-and-petroleum-products-monthly-statistics](https://www.gov.uk/government/statistical-data-sets/oil-and-petroleum-products-monthly-statistics)

The visualisation data was downloaded from here [https://assets.publishing.service.gov.uk/media/699c5d8931713b50fd49c045/table_411_413__6_.xlsx](https://assets.publishing.service.gov.uk/media/699c5d8931713b50fd49c045/table_411_413__6_.xlsx)

Table 4.1.2 was extracted from the xlsx. The metadata pre-header rows were removed and all columns other than Year, Motor spirit (Premium unleaded / ULSP) and Derv (Diesel / ULSD) pence per litre were dropped to create [fuel-and-oil-prices/fuel-and-oil-prices.csv](fuel-and-oil-prices/fuel-and-oil-prices.csv)

The file [fuel-and-oil-prices/fuel-and-oil-prices.json](fuel-and-oil-prices/fuel-and-oil-prices.json) uses the data from the csv file as its `series.data` objects.

## Get company information

## Inflation

The source webpage for the data is [https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/l55o/mm23](https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/l55o/mm23)

The visualisation data was generated via [https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l55o/mm23](https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l55o/mm23)

The resulting CSV contains metadata header rows and three time series (annual, quarterly, and monthly rates). Only the annual rates were extracted to create [inflation/inflation-1989-2025.csv](inflation/inflation-1989-2025.csv)

The file [inflation/inflation.json](inflation/inflation.json) uses the data from the csv file as its `series.data` object.

## Road traffic

