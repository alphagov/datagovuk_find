// https://github.com/alphagov/accessible-autocomplete#progressive-enhancement

$(document).ready(function() {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: document.querySelector('#js_format-filter'),
    showAllValues: true
  })
});
