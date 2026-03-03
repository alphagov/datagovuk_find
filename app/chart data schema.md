# Chart data schema


This is for a headlines chart with two sides, showing a comparison of two sets of data. The left and right keys are expected to have the same structure.
```
title: "UK Statistics Showing Companies Closed vs Companies Open per Month in 2025",
left: {
    subtitle: "Get company information",
    description_html: "Statistics showing companies closed this month",
    value: 581_768,
    comparison_html: "In 2023, up by 0.7% compared to 2022.",
    trend: :up,
    value_change: 100,
    percent_change: 10
}, right: {
    subtitle: "Get company information",
    description_html: "Statistics showing companies closed this month",
    value: 581_768,
    comparison_html: "In 2023, up by 0.7% compared to 2022.",
    trend: :down,
    value_change: 50,
    percent_change: 5
}
```

