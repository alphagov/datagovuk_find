class StatusController < ApplicationController
  def status
    commit = ENV.fetch('HEROKU_SLUG_COMMIT', `git rev-parse HEAD`.strip)

    render json: {
      status: :ok,
      version: commit
    }
  end
end
