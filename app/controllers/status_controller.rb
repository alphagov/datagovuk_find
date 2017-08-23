class StatusController < ApplicationController
  def status
    commit = `git rev-parse HEAD`.strip || ENV.get('HEROKU_SLUG_COMMIT')

    render json: {
      status: :ok,
      version: commit
    }
  end
end
