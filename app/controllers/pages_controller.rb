class PagesController < ApplicationController
  def dashboard
    @datasets_count = get_datasets_count
    @publishers_count = Dataset.publishers.count
    @datafiles_count = Dataset.datafiles["doc_count"]
    @datasets_published_with_datafiles_count = Dataset.datafiles["datasets_with_datafiles"]["doc_count"]
    @datasets_published_with_no_datafiles_count = @datasets_count - @datasets_published_with_datafiles_count
    @datafiles_count_by_format = Dataset.datafiles["formats"]["buckets"]
  end

  def ckan_maintenance
    render "ckan_maintenance", status: :service_unavailable
  end

  def home
    expires_in 30.minutes, public: true
  end

private

  def get_datasets_count
    query = Search::Query.search(q: "", track_total_hits: true)
    Dataset.search(query).total_count
  end
end
