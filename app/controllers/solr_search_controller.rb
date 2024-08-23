class SolrSearchController < ApplicationController
  before_action :search_for_dataset, only: [:search]

  def search
    @sort = params["sort"]
    @organisation = params.dig(:filters, :publisher)
    @format = params.dig(:filters, :format)
    @topic = params.dig(:filters, :topic)
    @licence_code = params.dig(:filters, :licence_code)

  # fl: id,name,title,organization,extras_dcat_publisher_name,note,metadata_modified,extras_theme-primary,extras_metadata-date,res_description,res_url,res_format,data_dict

    # search result listing:
    # title=dataset.title
    # id=dataset.uuid
    # name=dataset.name
    # extras_dcat_publisher_name=dataset.organisation['title']
    # note=dataset.summary
    # metadata_modified=dataset.public_updated_at

    # Individual result
    # extras_theme-primary=topic
    # res_description=data file title
    # res_url=data file url
    # res_format=file format
    # license_id=licence
  end

private

  def search_for_dataset
    query = Search::Solr::Query.search(params)

    @datasets = query["response"]["docs"]
    @num_results = query["response"]["numFound"]
    @total_pages = @datasets.total_pages

    @search = Kaminari.paginate_array(@datasets, total_count: @num_results).page(page_number)

    # offset = @datasets.per_page * params[:page].to_i
    # @datasets.page_start
    # @datasets.per_page
    # @datasets.total_pages
  end

  def page_number
    page = params["page"]
    page && page.to_i.positive? ? page.to_i : 1
  end
end
