class DatagovukHeader {
  constructor($header) {

    this.$header = $header
    this.$mobileButton = $header.querySelector('#datagovuk-header-button-all')
    this.$desktopButtons = [
      $header.querySelector('#datagovuk-header-button-collections'),
      $header.querySelector('#datagovuk-header-button-data-manual')
    ]
    this.$menus = Array.from($header.querySelectorAll('.datagovuk-menu'))

    if (this.$menus.length === 0 || !this.$mobileButton) {
      console.error('Header - Elements not found')
      return
    }

    this.$menus.forEach($menu => {
      $menu.hidden = true
    })
  
    this.$mobileButton.setAttribute('aria-expanded', 'false')
    this.$mobileButton.addEventListener('click', () => this.toggleMobile())
    this.watchMediaQueryChange();

    this.$desktopButtons.forEach($button => {
      $button.setAttribute('aria-expanded', 'false')
      $button.addEventListener('click', () => this.toggleDesktop($button))
    })

    document.addEventListener('keydown', (event) => this.handleKeydown(event))
    this.$header.addEventListener('focusout', (event) => {
      // events bubble up so we need to check that focus has left header entirely
      if (this.$header.contains(event.relatedTarget) === false) this.closeAll()
    })
  }

  watchMediaQueryChange() {
    const style = getComputedStyle(document.documentElement)
    const desktopBreakpoint = style.getPropertyValue('--datagovuk-desktop-breakpoint').trim()
    const mediaQuery = window.matchMedia('(max-width: ' + desktopBreakpoint + ')')
    mediaQuery.addEventListener('change', (event) => this.handleMediaQueryChange(event))
  }
  
  handleMediaQueryChange(event) {
    this.closeAll()
  }

  getMenuFor($button) {
    const id = $button.getAttribute('aria-controls')
    const $menu = document.getElementById(id)
    if ($menu === null) {
      console.error('Header - Menu not found')
      return
    }
    return $menu
  }

  toggleMobile() {

    const shouldOpen = this.$mobileButton.getAttribute('aria-expanded') === 'false'

    // Always start from a clean state
    this.closeAll()
    
    if (shouldOpen) {
      this.$mobileButton.setAttribute('aria-expanded', 'true')
      
      this.$menus.forEach($menu => {
        $menu.hidden = false
      })
    }
  }

  toggleDesktop($clickedButton) {
    const shouldOpen = $clickedButton.getAttribute('aria-expanded') === 'false'
    
    // Close other open desktop menus or the mobile menu
    this.closeAll()

    if (shouldOpen) {
      $clickedButton.setAttribute('aria-expanded', 'true')
      const $menu = this.getMenuFor($clickedButton)
      $menu.hidden = false
    }
  }

  closeAll() {
    this.$menus.forEach($menu => {
      $menu.hidden = true
    })

    this.$mobileButton.setAttribute('aria-expanded', 'false')
    
    this.$desktopButtons.forEach($button => {
      $button.setAttribute('aria-expanded', 'false')
    })
  }

  handleKeydown(event) {
    if (event.key === 'Escape') {
      // Find the button for the open menu
      const $openButton = [this.$mobileButton, ...this.$desktopButtons].find(
        $button => $button.getAttribute('aria-expanded') === 'true'
      )

      if ($openButton) {
        this.closeAll()
        $openButton.focus()
      }
    }
  }

}

// Initialize
const $header = document.querySelector('.datagovuk-header')
if ($header) {
  new DatagovukHeader($header)
} else {
  console.error('Header - Element not found')
}
