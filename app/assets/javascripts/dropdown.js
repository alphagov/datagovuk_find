$(document).ready(function () {
    const link = document.querySelector(".datagovuk-nav-dropdown__toggle");
    const dropdown = document.querySelector(".collections-row");
    const banner = document.querySelector(".collections-menu");

    const manualLink = document.querySelector(".datagovuk-manual-nav-dropdown__toggle");
    const manualDropdown = document.querySelector(".manual-row");
    const manualBanner = document.querySelector(".data-manual-menu");

    link.addEventListener("mouseenter", () => dropdown.classList.add("is-open"));
    link.addEventListener("mouseleave", () => dropdown.classList.remove("is-open"));

    dropdown.addEventListener("mouseenter", () => dropdown.classList.add("is-open"));
    banner.addEventListener("mouseleave", () => dropdown.classList.remove("is-open"));

    manualLink.addEventListener("mouseenter", () => manualDropdown.classList.add("is-open"));
    manualLink.addEventListener("mouseleave", () => manualDropdown.classList.remove("is-open"));

    manualDropdown.addEventListener("mouseenter", () => manualDropdown.classList.add("is-open"));
    manualBanner.addEventListener("mouseleave", () => manualDropdown.classList.remove("is-open"));
});