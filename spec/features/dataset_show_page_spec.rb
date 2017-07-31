require 'rails_helper'

describe "Datasets are read from ES", elasticsearch: true do

  it "displays a dataset" do
    name = "Fancy pants dataset"
    dataset = create_dataset(name)
    index(dataset)

    visit "/dataset/1"

    expect(page).to have_content("Published by")
    expect(page).to have_content(name)
  end
end

describe "expected update metadata is displayed", elasticsearch: true do

  context "when a dataset has datafiles with end dates" do

    datafiles_w_enddate = [
      {"id" => 1,
       "name" => "I have no end date",
       "url" => "https://good_data.co.uk",
       "end_date" => nil,
       "updated_at"=> "2016-08-31T14:40:57.528Z"
     },
      {"id" => 2,
       "name" => "I have an end date",
       "url" => "https://good_data.co.uk",
       "end_date" => "24/03/2018",
       "updated_at"=> "2016-08-31T14:40:57.528Z"
     },
      {"id" => 3,
       "name" => "I have an end date",
       "url" => "https://good_data.co.uk",
       "end_date" => "01/12/2018",
       "updated_at"=> "2016-08-31T14:40:57.528Z"
      }
    ]

    it "annual" do
      dataset = create_dataset("Lovely data", "annual", datafiles_w_enddate)
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 24 March 2019")
    end

    it "quarterly" do
      dataset = create_dataset("Lovely data", "quarterly", datafiles_w_enddate)
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 24 July 2018")
    end

    it "monthly" do
      dataset = create_dataset("Lovely data", "monthly", datafiles_w_enddate)
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 24 April 2018")
    end

    it "daily" do
      dataset = create_dataset("Lovely data", "daily", datafiles_w_enddate)
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 25 March 2018")
    end

    it "never, one off" do
      ["never", "one off"].each do |freq|
        dataset = create_dataset("Lovely data", freq, datafiles_w_enddate)
        index_and_visit(dataset)
        expect(page).to have_content("No future updates")
      end
    end

    it "discontinued" do
      dataset = create_dataset("Lovely data", "discontinued", datafiles_w_enddate)
      index_and_visit(dataset)
      expect(page).to have_content("Dataset no longer updated")
    end
  end

  context "when a dataset has datafiles with no end dates" do

    datafiles_no_enddate = [
      {"id" => 1,
       "name" => "I have no end date",
       "url" => "https://good_data.co.uk",
       "end_date" => nil,
       "updated_at"=> "2016-08-31T14:40:57.528Z"
     },
      {"id" => 2,
       "name" => "I have an end date",
       "url" => "https://good_data.co.uk",
       "end_date" => nil,
       "updated_at"=> "2016-08-31T14:40:57.528Z"
     }]

     it "uses the updated_at field to calculate next update" do
       dataset = create_dataset("Lovely data", "annual", datafiles_no_enddate)
       index_and_visit(dataset)
       expect(page).to have_content("Expected update: 31 August 2017")
     end
  end

  context "when a dataset has no datafiles" do

    it "no expected updated" do
      dataset = create_dataset("Lovely data", "daily")
      index_and_visit(dataset)
      expect(page).to have_content("This dataset has no data yet")
    end
  end
end

describe "location metadata", elasticsearch: true do
  it 'displays a location if there is one' do
    dataset = create_dataset("Lovely data")
    index_and_visit(dataset)
    expect(page).to have_content("Geographical area: London Southwark")
  end
end
