require 'csv'
require 'json'
require 'date'

def convert_csv_to_regional_json(input_file, output_file)
  grouped_data = Hash.new { |hash, key| hash[key] = [] }

  puts(input_file)
  CSV.foreach(input_file, headers: true) do |row|
    date_obj = Date.parse(row['Date'])
    formatted_date = date_obj.strftime('%Y-%m-%d')

    record = [
      formatted_date,
      row['Average_Price'].to_f
    ]

    grouped_data[row['Region_Name']] << record
  end

  File.open(output_file, 'w') do |f|
    f.write(JSON.pretty_generate(grouped_data))
  end

  puts "Successfully converted #{input_file} to #{output_file}"
end

convert_csv_to_regional_json('/Users/ObsiyeA/Documents/ndl/datagovuk_find/app/data/Average-prices-68to25.csv', 'regional_prices.json')