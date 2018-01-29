class SearchController < LoggedAreaController
  before_action :search_for_dataset, only: [:search]
  before_action :toggle_beta_message

  def search
    @query = params['q'] || ''
    @sort = params['sort']
    @organisation = params.dig(:filters, :publisher)
    @location = params.dig(:filters, :location)
    @format = params.dig(:filters, :format)
    @topic = params.dig(:filters, :topic)
    @licence = params.dig(:filters, :licence)
    @datasets = @search.page(page_number)
  end

  def accept_and_redirect
    session[:beta_message] = true
    redirect_to search_path(q: params[:q])
  end

  private

  def toggle_beta_message
    flash[:beta_message] =
      beta_message_unseen? ? 'show' : 'hide'
  end

  def search_for_dataset
    query = Search::Query.search(params)
    @search = Dataset.search(query)
    @num_results = @search.results.total_count
  end

  def page_number
    page = params['page']
    page && page.to_i.positive? ? page.to_i : 1
  end
end
