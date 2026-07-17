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

  getConsentCookie() {
    var consentCookie = window.GOVUK.cookie('cookies_policy')
    if (!consentCookie) return null
    try {
      return JSON.parse(consentCookie)
    } catch (e) {
      return null
    }
  }

  hasSettingsConsent() {
    var consent = this.getConsentCookie()
    return consent && consent.settings === true
  }

  getDismissedCookie() {
    return document.cookie.split(';').some(c => c.trim() === 'survey_banner_dismissed_2026_07=true')
  }

  setDismissedCookie() {
    if (!this.hasSettingsConsent()) return
    var maxAge = 60 * 24 * 60 * 60 // 60 days in seconds
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
