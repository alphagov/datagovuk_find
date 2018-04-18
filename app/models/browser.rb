class Browser
  attr_reader :user_agent

  def initialize(user_agent)
    @user_agent = user_agent.to_s
  end

  def ie?(options = {})
    return ie_version.to_i == options[:version].to_i if options[:version].present?
    msie? || modern_ie? || edge?
  end

  private

  TRIDENT_MAPPING = {
    "4.0" => "8",
    "5.0" => "9",
    "6.0" => "10",
    "7.0" => "11",
    "8.0" => "12"
  }.freeze

  def ie_version
    TRIDENT_MAPPING[trident_version] || msie_version
  end

  def msie_version
    ie_full_version.split(".").first
  end

  def trident_version
    user_agent.match(%r[Trident/([0-9.]+)]) && $1
  end

  def ie_full_version
    (user_agent.match(%r{MSIE ([\d.]+)|Trident/.*?; rv:([\d.]+)}) && ($1 || $2)) ||
      "0.0"
  end

  def msie?
    /MSIE/.match?(user_agent) && user_agent !~ /Opera/
  end

  def modern_ie?
    %r{Trident/.*?; rv:(.*?)}.match?(user_agent)
  end

  def edge?
    /Edge/.match?(user_agent)
  end
end
