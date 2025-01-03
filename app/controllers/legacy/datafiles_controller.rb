class Legacy::DatafilesController < ApplicationController
  def redirect
    dataset = SolrDataset.get_by_legacy_name(legacy_name: params[:legacy_dataset_name])
    datafile = dataset.datafiles.find { |f| f.uuid == params[:datafile_uuid] }

    raise SolrDatafile::NotFound if datafile.nil?

    redirect_path = datafile_preview_path(dataset.uuid, dataset.name, datafile.uuid)

    redirect_to redirect_path, status: :moved_permanently
  end
end
