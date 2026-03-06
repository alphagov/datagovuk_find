require "csv"
require "json"
require "date"

def convert_csv_to_regional_json(input_file, output_file)
  dataset = Hash.new { |hash, key| hash[key] = {} }
  number_base = 1000.0

  CSV.foreach(input_file, headers: true) do |row|
    next unless row["Date"] && row["Region_Name"]

    date_obj = Date.parse(row["Date"])
    formatted_date = date_obj.strftime("%Y-%m-%d")

    average_price = row["Average_Price"].to_f
    dataset[row["Region_Name"]][formatted_date] = average_price / number_base
  end

  region_colors = {
    "England" => "#4D303D",
    "Wales" => "#00890B",
    "Scotland" => "#525a90",
  }

  point_styles = %w[circle triangle rect rectRot]

  average_house_prices = {
    number_base: number_base.to_i,
    max_value: 0,
    y_title: "Average house price (£#{number_base.to_i})",
    data: [],
  }

  formatted_dataset = dataset.map do |region_name, data|
    data_count = data.keys.size
    max_value = data.values.max / number_base

    if max_value > average_house_prices[:max_value]
      average_house_prices[:max_value] = max_value
    end

    point_style_icon = point_styles.pop
    size_of_point = 10
    point_radius = Array.new(data_count - 1, 0) << size_of_point
    point_style  = Array.new(data_count - 1, point_style_icon) << point_style_icon

    {
      name: region_name,
      color: region_colors[region_name] || "#4D303D",
      dataset: {
        pointRadius: point_radius,
        pointStyle: point_style,
      },
      data: data.sort.to_h,
    }
  end

  average_house_prices[:data] = formatted_dataset

  File.write(output_file, JSON.pretty_generate(average_house_prices))
end
convert_csv_to_regional_json(File.expand_path("./app/data/average_house_prices/Average-prices-68to25.csv"), File.expand_path("./app/data/average_house_prices/regional_prices.json"))
