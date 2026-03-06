require "csv"
require "json"
require "date"

def convert_csv_to_regional_json(input_file, output_file)
  temp_grouped = Hash.new { |hash, key| hash[key] = {} }

  CSV.foreach(input_file, headers: true) do |row|
    date_obj = Date.parse(row["Date"])
    formatted_date = date_obj.strftime("%Y-%m-%d")

    temp_grouped[row["Region_Name"]][formatted_date] = row["Average_Price"].to_f
  end

  final_data = temp_grouped.map do |region, dates|
    {
      name: region,
      size: dates.values.compact.size,
      maxValueRoundedUp: (dates.values.compact.max.ceil / 10_000.0).ceil * 10_000,
      minValueRoundedDown: (dates.values.compact.min.floor / 10_000.0).floor * 10_000,
      data: dates.transform_values { |price| price / 1000 },
    }
  end

  File.open(output_file, "w") do |f|
    f.write(JSON.pretty_generate(final_data))
  end
end

convert_csv_to_regional_json("/Users/ObsiyeA/Documents/ndl/datagovuk_find/app/data/Average-prices-68to25.csv", "regional_prices.json")
