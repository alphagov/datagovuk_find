# Chart data schema


This is for a headlines chart with two sides, showing a comparison of two sets of data. The left and right keys are expected to have the same structure.
```
<%= render partial: "v2/collection/charts/split_chart/split_chart", locals: {
  title: "UK Statistics Showing Companies Closed vs Companies Open per Month in 2025",
  left: {
    subtitle: "Get company information",
    description_html: "Statistics showing companies closed this month",
    value: 581_768,
    comparison_html: "In 2023, up by 0.7% compared to 2022.",
    trend: :up,
    value_change: 100,
    percent_change: 10
  },
  right: {
    subtitle: "Get company information",
    description_html: "Statistics showing companies closed this month",
    value: 581_768,
    comparison_html: "In 2023, up by 0.7% compared to 2022.",
    trend: :down,
    value_change: 50,
    percent_change: 5
  }
} %>
```



## Line chart

Things to calculate: stepSize, maxTicksLimit, min, max, ytitle, suffix, pointRadius (0 to hide points)

```
<%= line_chart [
  {
    name: "Charity Information",
    data: {
    "Jan" => 10, "Feb" => 15, "Mar" => 20, "Apr" => 25, "May" => 30, "Jun" => 35, "Jul" => 40, "Aug" => 45, "Sep" => 50, "Oct" => 55, "Nov" => 60, "Dec" => 65
    },
    dataset: {
        pointRadius: [0,0,0,0,0,0,0,0,0,0,0,5],
        pointStyle: "rect",
        pointHoverRadius: 7
    }
}],
colors: ["#C27A9A"],
curve: true,
legend: "bottom",
suffix: "%",
min: 10,
max: 70,
ytitle: "Percentage",
library: {
    elements: {
        point: {
            radius: 0,
        }
    },
    scales: {
        y: {
            ticks: {
                stepSize: 10,
                maxTicksLimit: 7,
                font: {
                    size: 16
                }
            }
        },
        x: {
            ticks: {
                font: {
                    size: 16
                }
            }
        }
    },
    plugins: {
      legend: {
        labels: {
          font: { size: 20 }
        }
      }
    }
}
%>
```


