/* global $ */

// ======== Autocomplete ===========
var Typeahead = {
  substringMatcher: function(strs) {
    return function findMatches(q, cb) {
      var matches, substringRegex

      // an array that will be populated with substring matches
      matches = []

      // regex used to determine if a string contains the substring `q`
      substrRegex = new RegExp(q, 'i')

      // iterate through the pool of strings and for any string that
      // contains the substring `q`, add it to the `matches` array
      $.each(strs, function(i, str) {
        if (substrRegex.test(str)) {
          matches.push(str)
        }
      })

      cb(matches)
    }
  },

  options: {
    hint: true,
    highlight: true,
    minLength: 2,
    classNames: {
      input: 'form-control tt-input',
      hint: 'form-control tt-hint'
    }
  },

  add: function (selector, name, values) {
    var specificOptions = {
      name: name,
      source: this.substringMatcher(values),
      limit: 10
    }
    $(selector).typeahead(this.options, specificOptions)
  }
}
