require 'rails_helper'

describe DatasetsController, type: :controller do
  render_views

  describe 'Breadcrumb' do
    context 'Visiting search results from within the application' do
      it 'will not display the publisher name if the referrer host name is the application host name' do
        request.env['HTTP_REFERER'] = 'http://test.host/search?q=fancypants'

        authenticate
        create_dataset_and_visit

        expect(response.body).to have_css('div.datagov_breadcrumb')
        expect(response.body).to_not have_css('li', text: 'Ministry of Defence')
        expect(response.body).to have_css('li', text: 'Search')
      end
    end

    context 'Visiting search results from outside the application' do
      it 'will display the publisher name if the user has visited the search page from outside the application' do
        request.env['HTTP_REFERER'] = 'http://unknown.host/search?q=fancypants'

        authenticate
        create_dataset_and_visit

        expect(response.body).to have_css('div.datagov_breadcrumb')
        expect(response.body).to have_css('li', text: 'Ministry of Defence')
        expect(response.body).to_not have_css('li', text: 'Search')
      end
    end
  end
end
