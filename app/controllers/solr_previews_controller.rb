class SolrPreviewsController < ApplicationController
  rescue_from SolrDatafile::NotFound, with: :render_not_found

  def show
    append_content_security_policy_directives(
      connect_src: ["s3-eu-west-1.amazonaws.com", "ckan.publishing.service.gov.uk"].compact,
    )

    @dataset = SolrDataset.get_by_uuid(uuid: params[:dataset_uuid])
    @datafile = @dataset.datafiles.find { |f| f.uuid == params[:datafile_uuid] }

    raise SolrDatafile::NotFound if @datafile.nil?
  end

  def render_not_found
    render "errors/not_found", status: :not_found
  end
end
