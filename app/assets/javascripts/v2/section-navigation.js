class DatagovukSectionNavigation {
  constructor($sectionNavigation) {

    this.$sectionNavigation = $sectionNavigation
    this.$button = $sectionNavigation.querySelector('#datagovuk-section-navigation-button-all')
    this.$navigationItems = $sectionNavigation.querySelector('.datagovuk-section-navigation__items-mobile')
    this.$button.setAttribute('aria-expanded', 'false')
    this.$button.addEventListener('click', () => this.toggleNavigationItems())
    this.close()

    document.addEventListener('keydown', (event) => this.handleKeydown(event))
    this.$sectionNavigation.addEventListener('focusout', (event) => {
      // events bubble up so we need to check that focus has left header entirely
      if (this.$sectionNavigation.contains(event.relatedTarget) === false) this.close()
    })
  }

  toggleNavigationItems() {

    const shouldOpen = this.$button.getAttribute('aria-expanded') === 'false'

    // Always start from a clean state
    this.close()
    
    if (shouldOpen) {
      this.$button.setAttribute('aria-expanded', 'true')
      
      this.$navigationItems.hidden = false;
    }
  }

  close() {
    this.$navigationItems.hidden = true;
    this.$button.setAttribute('aria-expanded', 'false')
  }

  handleKeydown(event) {
    if (event.key === 'Escape') {
      // Find the button for the open menu
      const $openButton = [this.$button].find(
        $button => $button.getAttribute('aria-expanded') === 'true'
      )

      if ($openButton) {
        this.close()
        $openButton.focus()
      }
    }
  }

}

// Initialize
const $sectionNavigation = document.querySelector('.datagovuk-section-navigation')
if ($sectionNavigation) {
  new DatagovukSectionNavigation($sectionNavigation)
}
