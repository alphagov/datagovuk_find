(function() {
  var renderChart = function() {
    var element = document.getElementById('datagovuk-line-chart');
    if (!element) return;

    var chartData = {
      "max_value": 177.66,
      "title": "Fuel price in pence per litre (yearly)",
      "series": [
        {
          "name": "Premium unleaded / ULSP",
          "color": "#C27A9A",
          "data": {"1977": null, "1978": null, "1979": null, "1980": null, "1981": null, "1982": null, "1983": null, "1984": null, "1985": null, "1986": null, "1987": null, "1988": null, "1989": 38.29, "1990": 42.03, "1991": 45.07, "1992": 46.07, "1993": 49.44, "1994": 51.58, "1995": 53.77, "1996": 56.52, "1997": 61.82, "1998": 64.8, "1999": 70.16, "2000": 79.93, "2001": 75.72, "2002": 73.24, "2003": 76.04, "2004": 80.22, "2005": 86.75, "2006": 91.32, "2007": 94.24, "2008": 107.08, "2009": 99.29, "2010": 116.9, "2011": 133.27, "2012": 135.39, "2013": 134.15, "2014": 127.5, "2015": 111.13, "2016": 108.85, "2017": 117.59, "2018": 125.2, "2019": 124.88, "2020": 113.95, "2021": 131.27, "2022": 164.73, "2023": 147.75, "2024": 141.48, "2025": 135.07}
        },
        {
          "name": "Diesel / ULSD",
          "color": "#00890B",
          "data": {"1977": 18.21, "1978": 18.46, "1979": 23.65, "1980": 29.67, "1981": 34.01, "1982": 35.86, "1983": 37.3, "1984": 38.33, "1985": 41.94, "1986": 35.6, "1987": 34.58, "1988": 34.0, "1989": 36.18, "1990": 40.48, "1991": 43.82, "1992": 45.01, "1993": 49.2, "1994": 51.53, "1995": 54.24, "1996": 57.71, "1997": 62.47, "1998": 65.5, "1999": 72.49, "2000": 81.34, "2001": 77.84, "2002": 75.46, "2003": 77.92, "2004": 81.91, "2005": 90.86, "2006": 95.21, "2007": 96.85, "2008": 117.51, "2009": 103.93, "2010": 119.26, "2011": 138.72, "2012": 141.83, "2013": 140.41, "2014": 133.46, "2015": 114.9, "2016": 110.13, "2017": 120.15, "2018": 129.98, "2019": 131.48, "2020": 119.14, "2021": 134.94, "2022": 177.66, "2023": 158.19, "2024": 148.33, "2025": 142.55}
        }
      ]
    };


    var categories = Object.keys(chartData.series[0].data);

    var formattedSeries = chartData.series.map(function(s) {
      return {
        name: s.name,
        color: s.color,
        data: Object.values(s.data)
      };
    });


    Highcharts.chart('datagovuk-line-chart', {
      credits: { enabled: false },
      chart: { type: 'line', borderWidth: 0, backgroundColor: 'transparent' },
      title: { text: chartData.title },
      xAxis: {
        categories: categories,
        tickInterval: 5
      },
      yAxis: {
        title: { text: 'Pence per litre' },
        max: chartData.max_value + 10
      },
      tooltip: {
        valueSuffix: 'p'
      },
      series: formattedSeries
    });
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", renderChart);
  } else {
    renderChart();
  }
})();