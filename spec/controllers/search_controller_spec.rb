require 'rails_helper'

describe SearchController, type: :controller do
  context 'Filtering by location' do
    render_views
    it 'return results matching location' do
      first_slug = 'a-nice-dataset'

      first_dataset = DatasetBuilder.new
                        .with_name(first_slug)
                        .with_title('A nice dataset')
                        .with_location('Auckland')
                        .build

      second_slug = 'another-nice-dataset'

      second_dataset = DatasetBuilder.new
                         .with_name(second_slug)
                         .with_title('Another nice dataset')
                         .with_location('Auckland')
                         .build

      third_slug = 'another-nice-dataset'

      third_dataset = DatasetBuilder.new
                         .with_name(third_slug)
                         .with_title('Yet another nice dataset')
                         .with_location('Wellington')
                         .build


      index([first_dataset, second_dataset, third_dataset])

      authenticate

      get :search, params: {location: 'Auckland'}

      expect(response.body).to have_css('dd', text: 'Auckland')
      expect(response.body).to_not have_css('dd', text: 'Wellington')
    end
  end
end
