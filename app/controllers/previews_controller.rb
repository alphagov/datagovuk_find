class PreviewsController < LoggedAreaController
  def show
    @dataset = Dataset.get_by_short_id(short_id: params[:dataset_short_id])
    @datafile = @dataset.datafiles.find { |f| f.short_id == params[:datafile_short_id] }
  end
end
