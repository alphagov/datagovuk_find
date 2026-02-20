$(document).ready(function () {
    const link = document.querySelector(".datagovuk-nav-dropdown__toggle");
    const dropdown = document.querySelector(".collections-row");
    const banner = document.querySelector(".govuk-header");

    link.addEventListener("mouseenter", () => dropdown.classList.add("is-open"));
    link.addEventListener("mouseleave", () => dropdown.classList.remove("is-open"));

    dropdown.addEventListener("mouseenter", () => dropdown.classList.add("is-open"));
    banner.addEventListener("mouseleave", () => dropdown.classList.remove("is-open"));
});