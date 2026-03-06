require "csv"
require "json"
require "date"
require "fileutils"

def convert_csv_to_regional_json(input_file, output_file)
  temp_grouped = Hash.new { |hash, key| hash[key] = {} }

  CSV.foreach(input_file, headers: true) do |row|
    date_obj = Date.parse(row["Date"])
    formatted_date = date_obj.strftime("%Y-%m-%d")

    temp_grouped[row["Region_Name"]][formatted_date] = row["Average_Price"].to_f
  end

  number_base = 10_000

  final_data = temp_grouped.map do |region, dates|
    average_house_prices = dates.values.compact

    {
      name: region,
      size: average_house_prices.size,
      base: number_base,
      data: dates.transform_values { |price| price / 1000 },
    }
  end

  File.open(output_file, "w") do |f|
    f.write(JSON.pretty_generate(final_data))
  end
end

convert_csv_to_regional_json(File.expand_path("./app/data/Average-prices-68to25.csv"), File.expand_path("./app/data/regional_prices.json"))
