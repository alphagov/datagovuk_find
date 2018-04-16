class Browser
  attr_reader :user_agent

  def initialize(user_agent)
    @user_agent = user_agent.to_s
  end

  def ie?(version:)
    ie_version.to_i == version.to_i
  end

  private

  def ie_version
    ie_full_version.split(".").first
  end

  def ie_full_version
    (user_agent.match(%r{MSIE ([\d.]+)}) && ($1)) ||
      "0.0"
  end
end
