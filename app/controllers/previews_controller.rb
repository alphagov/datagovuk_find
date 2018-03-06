class PreviewsController < ApplicationController
  def show
    @dataset = Dataset.get_by_uuid(uuid: params[:dataset_uuid])
    @datafile = @dataset.datafiles.find { |f| f.uuid == params[:datafile_uuid] }
  end
end
