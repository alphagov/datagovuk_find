$(function() {
  // This container needs to have an HTML ID (even if you're not using it here)
  // in order for the visualiser library to work.
  var $organogramContainer = $("#organogram");
  var csvURL = $organogramContainer.data("csv-url");

  if (csvURL) {
    if ($.browser.msie && parseInt($.browser.version, 10) < 9) {
      $organogramContainer.css("background", "none");
      $organogramContainer.css("border", "1px solid #eee");
      $organogramContainer.css("min-height", "0");
      $organogramContainer.height(70);
      var message = 'Unsupported browser. Requires Internet Explorer 9 or newer, or Chrome, Firefox, etc';
      $organogramContainer.append('<div class="alert alert-block alert-danger"><a class="close" data-dismiss="alert" href="#">×</a><h4 class="element-invisible">Error message</h4>'
          + message +'</div>');
    } else {
      $organogramContainer.append("<div class='infobox' />");

      OrgDataLoader.load(csvURL, $organogramContainer);
    }
  }
});
