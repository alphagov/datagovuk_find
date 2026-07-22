class DatagovukSurveyBanner {
  constructor($module) {
    this.$module = $module
    this.$closeLink = $module.querySelector('.datagovuk-close')

    if (!this.$closeLink) return

    if (this.getDismissedCookie()) {
      this.$module.hidden = true
      return
    }

    this.$closeLink.addEventListener('click', (event) => this.dismiss(event))
  }

  getDismissedCookie() {
    return document.cookie.split(';').some(cookie => cookie.trim() === 'survey_banner_dismissed_2026_07=true')
  }

  setDismissedCookie() {
    var maxAge = 15 * 24 * 60 * 60 // 15 days in seconds
    document.cookie = 'survey_banner_dismissed_2026_07=true; max-age=' + maxAge + '; path=/'
  }

  dismiss(event) {
    event.preventDefault()
    this.$module.hidden = true
    this.setDismissedCookie()
  }
}

// Initialize
const $surveyBanner = document.querySelector('.datagovuk-notification-banner')
if ($surveyBanner) {
  new DatagovukSurveyBanner($surveyBanner)
}
