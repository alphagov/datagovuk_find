class ConsentsController < ApplicationController
  def confirm
    session[:consent] = true
    redirect_to root_path
  end
end
