# Frontend development guide for v2

Templates folder

```
app/views/v2
```

Assets folders

```
app/assets/images/v2
app/assets/javascripts/v2
app/assets/stylesheets/v2
```

## Stylesheets

We are using [GOV.UK Frontend](https://frontend.design-system.service.gov.uk/) as a base.

Use the [BEM notation](https://github.com/alphagov/govuk-frontend/blob/main/docs/contributing/coding-standards/css.md#block-element-modifier-bem) approach to CSS.

Use classes, never style the element directly.

Use the prefix `datagovuk-` for classes.

If you need to override anything, add a `datagovuk-[name]` class and put in the `stylesheets/v2/overrides` folder.

For example to change `govuk-link`

```
.datagovuk-link {
    // override styles here
}

<a class="govuk-link datagovuk-link">Link text</a>
```

Style everything mobile first, with media queries for larger screens.

Use [progressive enhancement](https://www.gov.uk/service-manual/technology/using-progressive-enhancement).
