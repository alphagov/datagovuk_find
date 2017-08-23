class StatusController < ApplicationController
  def status
    commit = `git rev-parse HEAD`.strip
    commit_date = `git show -s --format=%ci #{commit}`.strip

    render json: {
      status: :ok,
      version: commit,
      date: commit_date
    }
  end
end
