// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require cookie-settings
//= require analytics
//= require govuk_toolkit
//= require accessible-autocomplete/dist/accessible-autocomplete.min
//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/modules
//= require govuk_publishing_components/all_components
//= require_tree ./organograms/lib
//= require_tree ./organograms
//= require_tree .
//= stub map-preview

window.GOVUK.modules.start()
window.GOVUK.analyticsInit()
