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
    "Scotland" => "rgb(82, 90, 144)",
  }

  point_styles = %w[circle triangle rect rectRot]

  final_data = dataset.map do |region_name, data|
    data_count = data.keys.size
    size = data.values.max
    point_style_icon = point_styles.pop
    point_radius = Array.new(data_count - 1, 0) << 4
    point_style  = Array.new(data_count - 1, point_style_icon) << point_style_icon

    {
      name: region_name,
      color: region_colors[region_name] || "#CCCCCC",
      dataset: {
        pointRadius: point_radius,
        pointStyle: point_style,
      },
      number_base: number_base.to_i,
      size: size,
      data: data.sort.to_h,
    }
  end

  File.write(output_file, JSON.pretty_generate(final_data))
end
convert_csv_to_regional_json(File.expand_path("./app/data/Average-prices-68to25.csv"), File.expand_path("./app/data/regional_prices.json"))
