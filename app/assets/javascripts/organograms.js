(function($) {
    if (!Array.prototype.forEach) {
        Array.prototype.forEach = function (fn, scope) {
            var len = this.length;

            for (var i = 0; i < len; i++) {
                fn.call(scope || this, this[i], i, this);
            }
        };
    }

    if (!Array.prototype.indexOf) {
        Array.prototype.indexOf = function (searchElement /*, fromIndex */ ) {
            if (this === null || this === undefined) {
                throw new TypeError();
            }

            var t = new Object(this);
            var len = t.length >>> 0;

            if (len === 0) {
                return -1;
            }

            var n = 0;
            if (arguments.length > 0) {
                n = Number(arguments[1]);
                if (n != n) { // shortcut for verifying if it's NaN
                    n = 0;
                } else if (n !== 0 && n != Infinity && n != -Infinity) {
                    n = (n > 0 || -1) * Math.floor(Math.abs(n));
                }
            }

            if (n >= len) {
                return -1;
            }

            var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
            for (; k < len; k++) {
                if (k in t && t[k] === searchElement) {
                    return k;
                }
            }

        };
    }

    var junior = null;
    var senior = null;

    Drupal.behaviors.organogramView = {
        attach: function() {
            var infovisId = 'infovis';
            if (typeof Drupal.settings.dgu_organogram !== 'undefined' && typeof Drupal.settings.dgu_organogram.fid !== 'undefined') {
                if ($.browser.msie && parseInt($.browser.version, 10) < 9) {
                    $("#infovis").css("background", "none");
                    $("#infovis").css("border", "1px solid #eee");
                    $("#infovis").css("min-height", "0");
                    $("#infovis").height(70);
                    var message = 'Unsupported browser. Requires Internet Explorer 9 or newer, or Chrome, Firefox, etc';
                    $("#infovis").append('<div class="alert alert-block alert-danger"><a class="close" data-dismiss="alert" href="#">×</a><h4 class="element-invisible">Error message</h4>'
                        + message +'</div>');
                }
                else {
                    OrgDataLoader.load(Drupal.settings.dgu_organogram.fid, infovisId);
                }
            }
        }
    };
})(jQuery);
