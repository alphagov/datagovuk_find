$(function() {
  var infovisId = 'infovis';
  var fid = 1;

  if (fid) {
    if ($.browser.msie && parseInt($.browser.version, 10) < 9) {
      $("#infovis").css("background", "none");
      $("#infovis").css("border", "1px solid #eee");
      $("#infovis").css("min-height", "0");
      $("#infovis").height(70);
      var message = 'Unsupported browser. Requires Internet Explorer 9 or newer, or Chrome, Firefox, etc';
      $("#infovis").append('<div class="alert alert-block alert-danger"><a class="close" data-dismiss="alert" href="#">×</a><h4 class="element-invisible">Error message</h4>'
          + message +'</div>');
    } else {
      OrgDataLoader.load(fid, infovisId);
    }
  }
});
