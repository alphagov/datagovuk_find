class Legacy::DatasetsController < ApplicationController
  def redirect
    dataset = Dataset.get_by_legacy_name(legacy_name: params[:legacy_name])
    redirect_to dataset_path(dataset.uuid, dataset.name), status: :moved_permanently
  end
end
