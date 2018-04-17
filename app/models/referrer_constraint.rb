class ReferrerConstraint
  def matches?(request)
    return if request.referrer.blank?

    %r(/dataset/(new|edit)/).match?(URI.parse(request.referrer).path)
  end
end
