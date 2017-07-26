class DatasetsController < ApplicationController

  def show
    @dataset = current_dataset
  end

  private

  def current_dataset
    Dataset.get({id: params[:id]})._source
  end
end
