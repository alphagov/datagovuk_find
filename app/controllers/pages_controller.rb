class PagesController < ApplicationController
  before_action :check_consent, only: [:support]

  def terms
  end

  def privacy
  end

  def cookies
  end

  def support
  end

  def accessibility
  end

  def dashboard
    @datasets_count = Dataset.__elasticsearch__.client.count["count"]
    @publishers_count = Dataset.publishers.count
    @datafiles_count = Dataset.datafiles['doc_count']
    @published_datasets_count = Dataset.datafiles['datasets_with_datafiles']['doc_count']
    @unpublished_datasets_count = @datasets_count - @published_datasets_count
    @datafiles_count_by_format = Dataset.datafiles['formats']['buckets']
  end

  private

  def check_consent
    return if Rails.env.test?
    redirect_to new_consent_path if has_not_consented?
  end

  def has_not_consented?
    !session.key?('consent') || session[:consent] == false
  end
end
