require 'rails_helper'

describe DatasetsController, type: :controller do
  render_views

  it 'will be displayed if the referrer host is the application host' do
    request.env['HTTP_REFERER'] = 'http://test.host/search?q=fancypants'

    dataset = create_dataset("A nice dataset")
    index(dataset)

    get :show, params: { id: 1 }

    expect(response.body).to have_css("div.breadcrumbs")
  end

  it 'will not be displayed if the referrer host is not the application host' do
    request.env['HTTP_REFERER'] = 'http://unknown.host/search?q=fancypants'

    dataset = create_dataset("A nice dataset")
    index(dataset)

    get :show, params: { id: 1 }

    expect(response.body).to_not have_css("div.breadcrumbs")
  end
end
