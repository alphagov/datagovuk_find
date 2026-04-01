module OnsChartsHelper
  def ons_line_chart(config)
    content_tag(:div, data: { "highcharts-base-chart": true, "highcharts-type": "line" }) do
      concat content_tag(
        :script,
        config.to_json.html_safe,
        type: "application/json",
        data: { "highcharts-config--id": true },
        nonce: content_security_policy_nonce,
      )
    end
  end
end
