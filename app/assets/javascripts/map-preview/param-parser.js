function ParamParser() {
  this.urls = new Array();
  this.eastBndLon = null;
  this.westBndLon = null;
  this.northBndLat = null;
  this.southBndLat = null;
  this.infoFormat = null;
  this.exceptions = null;

  pairs = location.search.split("\?")[1].split("&");

  for (i in pairs) {
    // No idea where this came from....
    if (i == "remove") continue;

    keyval = pairs[i].split("=");
    if (keyval[0] == "easting" || keyval[0] == "e")
      this.eastBndLon = parseFloat(keyval[1]);
    if (keyval[0] == "westing" || keyval[0] == "w")
      this.westBndLon = parseFloat(keyval[1]);
    if (keyval[0] == "northing" || keyval[0] == "n")
      this.northBndLat = parseFloat(keyval[1]);
    if (keyval[0] == "southing" || keyval[0] == "s")
      this.southBndLat = parseFloat(keyval[1]);
    if (keyval[0] == "url" || keyval[0] == "u")
      this.urls.push(decodeURIComponent(keyval[1]));
    if ((keyval[0] == "cbxInfoFormat") && (keyval[1].length > 0))
      this.infoFormat = decodeURIComponent(keyval[1]);
    if ((keyval[0] == "cbxExceptions") && (keyval[1].length > 0))
      this.exceptions = decodeURIComponent(keyval[1]);
  }

  // delete any repeated URLs
  var j;
  var len = this.urls.length;
  var out = [];
  var obj = {};

  for (j = 0; j < len; j++) {
    if (!obj[this.urls[j]]) {
      obj[this.urls[j]] = {};
      out.push(this.urls[j]);
    }
  }
  this.urls = out;

  this.getBBox = function () {
    return {
      "eastBndLon": this.eastBndLon,
      "westBndLon": this.westBndLon,
      "northBndLat": this.northBndLat,
      "southBndLat": this.southBndLat
    }
  };
  this.getUrls = function () {
    return this.urls
  };
  this.getInfoFormat = function () {
    return this.infoFormat;
  };
  this.getExceptions = function () {
    return this.exceptions;
  };
}

var paramParser = new ParamParser();
