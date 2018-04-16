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

  if (document.getElementById('publisher')) {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: document.querySelector('#publisher'),
      showAllValues: true,
      preserveNullOptions: true
    })
  }

  if (document.getElementById('format')) {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: document.querySelector('#format'),
      showAllValues: true,
      preserveNullOptions: true
    })
  }

  if(document.getElementById('topic')) {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: document.querySelector('#topic'),
      showAllValues: true,
      preserveNullOptions: true
    })
  }

  new FoldableText('.js-summary', 200)
    .init()

  new LimitDatasets('.show-toggle')
    .init()
})

var ShowHide = function () {
  this.selector = '.showHide'
  this.controlSelector = '.showHide-control'
  this.contentSelector = '.showHide-content'
  this.openSelector = '.showHide-open-all'
  this.expandSelector = '.js-expand'
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
    event.preventDefault()

    var openCloseAllControl = $(event.target)
    var dataLinks = $(this.selector);
    var dataLinkContent = dataLinks.find(this.contentSelector)
    var dataLinkExpand = dataLinks.find(this.expandSelector)
    var allOpen = openCloseAllControl.data('allOpen')

    if (allOpen) {
      dataLinks.data('isOpen', false)
      dataLinkContent.hide()
      dataLinkExpand.html('+')
      openCloseAllControl.data('allOpen', false)
      openCloseAllControl.text('Open all')
    } else {
      dataLinks.data('isOpen', true)
      dataLinkContent.show()
      dataLinkExpand.html('-')
      openCloseAllControl.data('allOpen', true)
      openCloseAllControl.text('Close all')
    }
  },

  init: function () {
    $(this.controlSelector).on('click', this.toggle.bind(this))
    $(this.openSelector).on('click', this.toggleAll.bind(this))
    $(this.selector).data('isOpen', false)
    $(this.openSelector).data('allOpen', false)
    $(this.controlSelector).first().trigger('click')
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
  var $summary = this.els
  $summary.find('pre').each(function(){
    $(this).css('white-space', 'pre-line')
  })
  var minSize = this.minSize
  var originalHeight =  $summary.height()
  $summary.css('max-height', originalHeight)
  if (originalHeight > minSize) {
    $summary
      .height(this.minSize)
      .css('overflow', 'hidden')
      .css('margin-bottom', 0)
      .wrap('<p class="fold-outer"></p>')
    $summary.parent('p.fold-outer')
      .append('<button class="fold button secondary" data-folded="folded" data-height="' + originalHeight + '">View full summary</div>')
  }
$('.fold').on('click', this.toggle.bind(this))
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
    $(this.moreFiles[0]).attr('tabindex', -1).focus();
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
