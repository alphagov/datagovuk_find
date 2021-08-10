class PreviewsController < ApplicationController
  def show
    append_content_security_policy_directives(
      connect_src: ["s3-eu-west-1.amazonaws.com", ENV["CKAN_DOMAIN"]].compact,
    )

    @dataset = Dataset.get_by_uuid(uuid: params[:dataset_uuid])
    @datafile = @dataset.datafiles.find { |f| f.uuid == params[:datafile_uuid] }

    raise Datafile::DatafileNotFound if @datafile.nil?
  end
end
