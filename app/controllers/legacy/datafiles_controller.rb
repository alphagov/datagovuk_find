class Legacy::DatafilesController < ApplicationController
  def redirect
    dataset = Dataset.get_by_legacy_name(legacy_name: params[:legacy_dataset_name])
    datafile = dataset.datafiles.find { |f| f.uuid == params[:datafile_uuid] }

    redirect_path = datafile_preview_path(dataset.short_id, dataset.name, datafile.short_id)

    redirect_to redirect_path, status: :moved_permanently
  rescue => e
    handle_error(e)
  end

  private

  def handle_error(e)
    Rails.logger.debug 'ERROR! => ' + e.message
    e.backtrace.each { |line| logger.error line }
    render template: 'errors/not_found', status: 404
  end
end
