/* global $, GOVUK, Typeahead */

// Warn about using the kit in production
$(document).ready(function () {
  // Use GOV.UK shim-links-with-button-role.js to trigger a link styled to look like a button,
  // with role="button" when the space key is pressed.
  GOVUK.shimLinksWithButtonRole.init()

  // Show and hide toggled content
  // Where .multiple-choice uses the data-target attribute
  // to toggle hidden content
  var showHideContent = new GOVUK.ShowHideContent()
  showHideContent.init()

  var showHide = new ShowHide()
  showHide.init()

  Typeahead.add('#publisher', 'publisher', Find.publishers)
  Typeahead.add('#location', 'location', Find.locations)

  new FoldableText('.summary', 200)
    .init()

  new LimitDatasets('.show-toggle')
    .init()
})

var ShowHide = function () {
  this.selector = '.showHide'
  this.controlSelector = '.showHide-control'
  this.contentSelector = '.showHide-content'
  this.openSelector = '.showHide-open-all'
  this.expandSelector = '.expand button'
  this.allOpen = false
}

ShowHide.prototype = {
  toggle: function (event) {
    var parentShowHide = $(event.target).parents(this.selector)
    var isOpen = parentShowHide.data('isOpen')
    parentShowHide.data('isOpen', !isOpen)
    parentShowHide.find(this.contentSelector).toggle()
    parentShowHide.find(this.expandSelector).html(isOpen ? '+' : '-')
  },
  toggleAll: function (event) {
    var showHideDataLinks = $(event.target).parents('.data-links')
    event.preventDefault()
    var allOpen = $(event.target).data('allOpen')
    if (allOpen) {
      showHideDataLinks.find(this.selector).data('isOpen', false)
      showHideDataLinks.find(this.contentSelector).hide()
      showHideDataLinks.find(this.expandSelector).html('+')
      $(event.target).data('allOpen', false)
      $(event.target).text('Open all')
    } else {
      showHideDataLinks.find(this.selector).data('isOpen', true)
      showHideDataLinks.find(this.contentSelector).show()
      showHideDataLinks.find(this.expandSelector).html('-')
      $(event.target).data('allOpen', true)
      $(event.target).text('Close all')
    }
  },

  init: function () {
    $(this.controlSelector).on('click', this.toggle.bind(this))
    $(this.controlSelector).first().trigger('click')
    $(this.openSelector).on('click', this.toggleAll.bind(this))
    $(this.selector).data('isOpen', false)
    $(this.openSelector).data('allOpen', false)
  }
}

// ==== Foldable text ======================

var FoldableText = function (selector, size) {
  this.selector = selector
  this.els = $(this.selector)
  this.minSize = size
  return this
}

FoldableText.prototype.toggle = function (event) {
  var $target = $(event.target)
  if ($target.data('folded') === 'folded') {
    $target.text('Hide full summary')
    $target.prev(this.selector).height($target.data('height'))
    $target.data('folded', 'unfolded')
  } else {
    $target.text('View full summary')
    $target.prev(this.selector).height(this.minSize)
    $target.data('folded', 'folded')
  }
}

FoldableText.prototype.init = function () {
  $.each(this.els, (idx, el) => {
    var $el = $(el)
    $el.css('max-height', '100000px')
    var originalHeight = $el.height()
    if (originalHeight > this.minSize) {
      $el
        .height(this.minSize)
        .css('overflow', 'hidden')
        .css('margin-bottom', 0)
        .wrap('<p class="fold-outer"></p>')

      $el.parent('p.fold-outer')
        .append('<div class="fold" data-folded="folded" data-height="' + originalHeight + '">View full summary</div>')

      $el.next('.fold').on('click', this.toggle.bind(this))
    }
  })
}

// Limit number of results for non-time series data

var LimitDatasets = function (selector) {
  this.selector = selector
  this.moreFiles = $(this.selector)
    .parent()
    .find('.js-show-more-datafiles')
  return this
}

LimitDatasets.prototype.toggle = function (event) {
  var $target = $(event.target)
  var folded = $target.data('folded')
  if (folded === 'folded') {
    $target.text('Show less')
    this.moreFiles.show()
    $target.data('folded', 'unfolded')
  } else {
    $target.text('Show more')
    this.moreFiles.hide()
    $target.data('folded', 'folded')
  }
}

LimitDatasets.prototype.init = function () {
  this.moreFiles.hide()
  $(this.selector).data('folded', 'folded')
  $(this.selector).on('click', this.toggle.bind(this))
}
