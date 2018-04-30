$(document).ready(function () {
  var banner = document.getElementById('dgu-beta__banner');
  var beta_cancel = document.getElementById('dgu-survey-cancel')
  var phase = document.getElementById('dgu-phase-banner');

  // if the beta banner is served by the back end, reveal it with CSS (default state is hidden)
  // UNLESS user has dismissed it and has a cookie
  if(banner && GOVUK.cookie('dgu_beta_banner_dismissed') != 'true') {
    banner.classList.remove("dgu-beta__banner--hidden");
    var dgu_beta_banner = "visible";
  }

  // if the banner is revealed, hide the "beta" label
  if(phase && dgu_beta_banner == "visible") {
    phase.classList.add("phase-banner--hidden");
  }

  // when user dismisses banner, set cookie for 1 year, hide banner, and display label
  beta_cancel.addEventListener("click", function onclick(event) {
    GOVUK.cookie('dgu_beta_banner_dismissed', 'true', { days: 365 });
    banner.classList.add("dgu-beta__banner--hidden");
    phase.classList.remove("phase-banner--hidden");
    event.preventDefault();
  });

})
