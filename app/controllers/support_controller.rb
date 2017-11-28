class SupportController < LoggedAreaController

  #TODO remove this before action
  skip_before_action :verify_authenticity_token

  def submit
    @support_queue = params['support']
  end

  def ticket
    redirect_to support_confirmation_path
  end

end
