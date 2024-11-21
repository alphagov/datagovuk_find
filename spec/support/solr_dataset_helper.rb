def sorted_solr_search_for(sort_method)
  within ".dgu-sort" do
    select sort_method, from: "sort-datasets"
  end
  within "#main-content" do
    find(".gem-c-search__submit").click
  end
end

def modified_dataset_validated_data_dict_json(property, new_value)
  parsed_json = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s))
  first_doc = parsed_json["response"]["docs"].first
  validated_data = JSON.parse(first_doc["validated_data_dict"])

  validated_data[property] = new_value

  # Manually format the JSON string with one space after each colon
  first_doc["validated_data_dict"] = validated_data.to_json.gsub(/":\s?/, '": ')

  parsed_json
end
