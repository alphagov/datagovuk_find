// https://github.com/alphagov/accessible-autocomplete#progressive-enhancement

$(document).ready(function() {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: document.querySelector('#format'),
    showAllValues: true,
    confirmOnBlur: false,
    autoselect: false
  })
});
