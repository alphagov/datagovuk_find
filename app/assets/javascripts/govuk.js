/* global $, GOVUK, Typeahead */

// Warn about using the kit in production
var publisherTitles = []

$.getJSON('https://publish-data-beta.herokuapp.com/api/organisations', function (data) {
  $.each(data, function (key, value) {
    publisherTitles.push(value['title'])
  })
})

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

  Typeahead.add('#publisher', 'publisher', publisherTitles)
  var locations = ['England', 'Wales', 'Scotland', 'Northern Ireland', 'Great Britain', 'British Isles', 'United Kingdom (UK)', 'Cheshire East', 'Mole Valley', 'Allerdale', 'Devon', 'Blaby', 'Gedling', 'Darlington', 'Stroud', 'Northampton', 'Ribble Valley', 'Bromley', 'Copeland', 'Torridge', 'Test Valley', 'Nottinghamshire', 'Eden', 'Maldon', 'Dover', 'Wealden', 'Stafford', 'Dacorum', 'Bexley', 'County Durham', 'Blackburn with Darwen', 'Daventry', 'Gosport', 'Sheffield', 'Hyndburn', 'Tonbridge and Malling', 'Arun', 'Stoke-on-Trent', 'Craven', 'East Hertfordshire', 'East Riding of Yorkshire', 'South Staffordshire', 'Stevenage', 'Chelmsford', 'Sefton', 'Colchester', 'Bournemouth', 'Surrey Heath', 'Worcestershire', 'Gravesham', 'Thanet', 'Gloucestershire', 'Herefordshire', 'South Gloucestershire', 'Tewkesbury', 'Buckinghamshire', 'West Somerset', 'Melton', 'Greenwich', 'Surrey', 'Tandridge', 'Leicestershire', 'Walsall', 'Sevenoaks', 'Derby', 'Cherwell', 'Selby', 'Fenland', 'Ashford', 'Broxbourne', 'Gateshead', 'Portsmouth', 'East Northamptonshire', 'Hertsmere', 'Essex', 'Oadby and Wigston', 'Rugby', 'Northamptonshire', 'Dudley', 'Kettering', 'Wakefield', 'Rotherham', 'Forest Heath', 'Haringey', 'Manchester', 'Amber Valley', 'Great Yarmouth', 'Harrow', 'Somerset', 'Preston', 'Chesterfield', 'Chiltern', 'Hounslow', 'South Cambridgeshire', 'Blackpool', 'Cumbria', 'Rutland', 'South Lakeland', 'Lincolnshire', 'Telford and Wrekin', 'Islington', 'Nottingham', 'Castle Point', 'East Lindsey', 'Bury', 'Ipswich', 'Reigate and Banstead', 'Wandsworth', 'Slough', 'Bassetlaw', 'Newark and Sherwood', 'Weymouth and Portland', 'Norfolk', 'Fylde', 'Vale of White Horse', 'Lewisham', 'Halton', 'Epping Forest', 'Cornwall', 'West Oxfordshire', 'Barnsley', 'Babergh', 'Taunton Deane', 'Hart', 'Richmond upon Thames', 'Leicester', 'Doncaster', 'Hampshire', 'Croydon', 'Lambeth', 'Solihull', 'Oldham', 'Luton', 'Knowsley', 'Pendle', 'Isle of Wight', 'South Holland', 'East Hampshire', 'Forest of Dean', 'Merton', 'Southampton', 'Kings Lynn and West Norfolk', 'Nuneaton and Bedworth', 'Bradford', 'Medway', 'Malvern Hills', 'Broxtowe', 'Lancashire', 'Uttlesford', 'Lancaster', 'Runnymede', 'Ashfield', 'Wyre', 'Mid Suffolk', 'Central Bedfordshire', 'Crawley', 'West Sussex', 'Hinckley and Bosworth', 'South Norfolk', 'Stockport', 'Chichester', 'Suffolk', 'West Dorset', 'Shepway', 'Tunbridge Wells', 'Ealing', 'Greater London', 'Barnet', 'Brighton and Hove', 'Cambridge', 'Waverley', 'Broadland', 'Newham', 'Boston', 'Maidstone', 'Sunderland', 'Salford', 'Eastbourne', 'Braintree', 'South Northamptonshire', 'Scarborough', 'Elmbridge', 'South Derbyshire', 'East Staffordshire', 'Winchester', 'Wokingham', 'Derbyshire', 'Fareham', 'Warwick', 'Guildford', 'Christchurch', 'Horsham', 'Welwyn Hatfield', 'Redditch', 'Brent', 'Mansfield', 'Hertfordshire', 'St Albans', 'Wyre Forest', 'Swale', 'Adur', 'Huntingdonshire', 'Hambleton', 'Ryedale', 'Bromsgrove', 'Harrogate', 'Wirral', 'South Bucks', 'Reading', 'Oxford', 'Havant', 'Eastleigh', 'South Ribble', 'East Cambridgeshire', 'Camden', 'Hillingdon', 'Leeds', 'St. Helens', 'New Forest', 'Cheltenham', 'Enfield', 'Bolton', 'East Devon', 'Northumberland', 'Shropshire', 'Thurrock', 'Aylesbury Vale', 'Charnwood', 'North Warwickshire', 'Southwark', 'Mendip', 'Havering', 'Lichfield', 'Poole', 'Breckland', 'Milton Keynes', 'Rossendale', 'Kensington and Chelsea', 'Waltham Forest', 'East Sussex', 'Barking and Dagenham', 'Warrington', 'Chorley', 'North East Lincolnshire', 'Oxfordshire', 'Liverpool', 'North Norfolk', 'West Lindsey', 'South Somerset', 'Norwich', 'Southend-on-Sea', 'West Lancashire', 'Cheshire West and Chester', 'City of Bristol', 'South Hams', 'Kent', 'Burnley', 'Wiltshire', 'Cambridgeshire', 'Stockton-on-Tees', 'Suffolk Coastal', 'North Somerset', 'Teignbridge', 'Sutton', 'Mid Devon', 'City of Lincoln', 'Bracknell Forest', 'Epsom and Ewell', 'North Yorkshire', 'Cotswold', 'Sedgemoor', 'Richmondshire', 'South Tyneside', 'Plymouth', 'Coventry', 'Tamworth', 'Redbridge', 'Warwickshire', 'South Oxfordshire', 'West Devon', 'Brentwood', 'Kingston upon Thames', 'Trafford', 'Purbeck', 'North Tyneside', 'East Dorset', 'Stratford-on-Avon', 'Hackney', 'Isles of Scilly', 'Cannock Chase', 'Newcastle upon Tyne', 'Wellingborough', 'Middlesbrough', 'Kingston upon Hull', 'Westminster', 'Rochford', 'York', 'Woking', 'Kirklees', 'Watford', 'Wycombe', 'Wychavon', 'Hammersmith and Fulham', 'Basildon', 'Wigan', 'Tendring', 'Redcar and Cleveland', 'Hastings', 'Harlow', 'Peterborough', 'Staffordshire', 'North Lincolnshire', 'Bedford', 'Derbyshire Dales', 'North Devon', 'West Berkshire', 'Windsor and Maidenhead', 'North Dorset', 'Erewash', 'Wolverhampton', 'Three Rivers', 'Worthing', 'Tameside', 'Newcastle-under-Lyme', 'Hartlepool', 'Rushmoor', 'North Kesteven', 'Carlisle', 'Worcester', 'Dartford', 'Harborough', 'Calderdale', 'Bolsover', 'Sandwell', 'Tower Hamlets', 'Canterbury', 'Swindon', 'Gloucester', 'Birmingham', 'Lewes', 'Rother', 'North East Derbyshire', 'North West Leicestershire', 'North Hertfordshire', 'Barrow-in-Furness', 'Torbay', 'South Kesteven', 'Dorset', 'Mid Sussex', 'Bath and North East Somerset', 'High Peak', 'Staffordshire Moorlands', 'Waveney', 'Spelthorne', 'Exeter', 'Rushcliffe', 'Rochdale', 'City of London', 'Basingstoke and Deane', 'St Edmundsbury', 'Corby', 'Ards', 'Coleraine', 'Newtownabbey', 'Antrim and Newtownabbey', 'Newry and Mourne', 'Fermanagh', 'Lisburn', 'Cookstown', 'Causeway Coast and Glens', 'Omagh', 'Dungannon and South Tyrone', 'Newry, Mourne and Down ', 'Banbridge', 'Ballymoney', 'Moyle', 'Fermanagh and Omagh', 'Craigavon', 'Castlereagh', 'Larne', 'Strabane', 'Ballymena', 'Mid Ulster', 'Down', 'Derry', 'Lisburn and Castlereagh', 'Limavady', 'Armagh City, Banbridge and Craigavon', 'Magherafelt', 'Mid and East Antrim', 'Antrim', 'North Down', 'Derry City and Strabane', 'Ards and North Down', 'Belfast', 'Armagh City', 'Carrickfergus', 'Newport', 'Monmouthshire', 'Isle of Anglesey', 'Wrexham', 'Caerphilly', 'Flintshire', 'The Vale of Glamorgan', 'Carmarthenshire', 'Swansea', 'Torfaen', 'Blaenau Gwent', 'Rhondda Cynon Taff', 'Gwynedd', 'Powys', 'Neath Port Talbot', 'Conwy', 'Denbighshire', 'Pembrokeshire', 'Cardiff', 'Merthyr Tydfil', 'Bridgend', 'Ceredigion', 'West Dunbartonshire', 'Dundee City', 'East Ayrshire', 'East Lothian', 'East Dunbartonshire', 'Inverclyde', 'Angus', 'Aberdeenshire', 'Perth and Kinross', 'Clackmannanshire', 'East Renfrewshire', 'North Lanarkshire', 'The Scottish Borders', 'Eilean Siar', 'North Ayrshire', 'City of Edinburgh', 'Aberdeen City', 'South Ayrshire', 'South Lanarkshire', 'Moray', 'Midlothian', 'Renfrewshire', 'Dumfries and Galloway', 'Orkney Islands', 'Argyll and Bute', 'Stirling', 'Shetland Islands', 'Highland', 'Falkirk', 'Fife', 'Glasgow City', 'West Lothian', 'Airedale, Wharfedale and Craven', 'Ashford', 'Aylesbury Vale', 'Barking and Dagenham', 'Barnet', 'Barnsley', 'Basildon and Brentwood', 'Bassetlaw', 'Bath and North East Somerset', 'Bedfordshire', 'Bexley', 'Birmingham CrossCity', 'Birmingham South and Central', 'Blackburn with Darwen', 'Blackpool', 'Bolton', 'Bracknell and Ascot', 'Bradford City', 'Bradford Districts', 'Brent', 'Brighton and Hove', 'Bristol', 'Bromley', 'Bury', 'Calderdale', 'Cambridgeshire and Peterborough', 'Camden', 'Cannock Chase', 'Canterbury and Coastal', 'Castle Point and Rochford', 'Central London (Westminster)', 'Central Manchester', 'Chiltern', 'Chorley and South Ribble', 'City and Hackney', 'Corby', 'Coventry and Rugby', 'Crawley', 'Croydon', 'Cumbria', 'Darlington', 'Dartford, Gravesham and Swanley', 'Doncaster', 'Halton', 'Dorset', 'Dudley', 'Durham Dales, Easington and Sedgefield', 'Ealing', 'East and North Hertfordshire', 'East Lancashire', 'East Leicestershire and Rutland', 'East Riding of Yorkshire', 'East Staffordshire', 'East Surrey', 'Eastbourne, Hailsham and Seaford', 'Eastern Cheshire', 'Enfield', 'Erewash', 'Fareham and Gosport', 'Fylde & Wyre', 'Gloucestershire', 'Great Yarmouth and Waveney', 'Greater Huddersfield', 'Greater Preston', 'Greenwich', 'Hambleton, Richmondshire and Whitby', 'Hammersmith and Fulham', 'Hardwick', 'Haringey', 'Harrogate and Rural District', 'Harrow', 'Hartlepool and Stockton-on-Tees', 'Hastings and Rother', 'Havering', 'Herefordshire', 'Herts Valleys', 'Heywood, Middleton and Rochdale', 'High Weald Lewes Havens', 'Hillingdon', 'Horsham and Mid Sussex', 'Hounslow', 'Hull', 'Ipswich and East Suffolk', 'Isle of Wight', 'Islington', 'Lincolnshire East', 'Lincolnshire West', 'Kernow', 'Kingston', 'Lambeth', 'Lancashire North', 'Leeds North', 'Leeds South and East', 'Leeds West', 'Leicester City', 'Lewisham', 'Mansfield and Ashfield', 'Medway', 'Merton', 'Mid Essex', 'Milton Keynes', 'Nene', 'Newark & Sherwood', 'Newbury and District', 'Newham', 'North & West Reading', 'North Derbyshire', 'North Tyneside', 'North Durham', 'North East Essex', 'North East Hampshire and Farnham', 'North East Lincolnshire', 'North Hampshire', 'North Kirklees', 'North Lincolnshire', 'North Manchester', 'North Norfolk', 'North Somerset', 'North Staffordshire', 'Wirral', 'North West Surrey', 'Northern, Eastern and Western Devon', 'Northumberland', 'Norwich', 'Nottingham City', 'Nottingham North and East', 'Nottingham West', 'Oldham', 'South Kent Coast', 'Oxfordshire', 'Portsmouth', 'Redbridge', 'Redditch and Bromsgrove', 'Richmond', 'Rotherham', 'Rushcliffe', 'Salford', 'Sandwell and West Birmingham', 'Scarborough and Ryedale', 'Sheffield', 'South Lincolnshire', 'South Manchester', 'St Helens', 'Shropshire', 'Slough', 'Solihull', 'Somerset', 'South Cheshire', 'South Devon and Torbay', 'South East Staffordshire and Seisdon Peninsula', 'South Eastern Hampshire', 'South Gloucestershire', 'South Norfolk', 'South Reading', 'South Sefton', 'South Tees', 'South Tyneside', 'South Warwickshire', 'South West Lincolnshire', 'South Worcestershire', 'Southampton', 'Southend', 'Southern Derbyshire', 'Southport and Formby', 'Southwark', 'Stafford and Surrounds', 'Stockport', 'Stoke on Trent', 'Sunderland', 'Surrey Downs', 'Surrey Heath', 'Sutton', 'Swale', 'Swindon', 'Tameside and Glossop', 'Telford and Wrekin', 'Thanet', 'Thurrock', 'Tower Hamlets', 'Trafford', 'Wokingham', 'Wolverhampton', 'Vale of York', 'Vale Royal', 'Wakefield', 'Walsall', 'Waltham Forest', 'Wandsworth', 'Warrington', 'Warwickshire North', 'West Cheshire', 'West Essex', 'Wiltshire', 'West Hampshire', 'West Kent', 'West Lancashire', 'West Leicestershire', 'West London', 'West Norfolk', 'West Suffolk', 'Wigan Borough', 'Windsor, Ascot and Maidenhead', 'Wyre Forest', 'Newcastle Gateshead', 'Coastal West Sussex', 'Guildford and Waverley']

  // Autocomplete is wired to elasticsearch rather than using location data above
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
