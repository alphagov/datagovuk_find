class PreviewsController < LoggedAreaController
  def show
    @dataset = Dataset.get_by(uuid: params[:dataset_uuid])
    @datafile = @dataset.timeseries_datafiles.find { |f| f.uuid == params[:datafile_uuid] }
  end
end
