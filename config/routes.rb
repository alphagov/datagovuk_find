Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "pages#home"

  get "collections/:collection", to: "collections#show", as: "collection"
  get "collections/:collection/:topic", to: "collections#show", as: "collection_topic"

  get "healthz" => "rails/health#show", as: :rails_health_check

  get "/sites/default/files/*organogram_path", to: redirect("https://s3-eu-west-1.amazonaws.com/datagovuk-#{Rails.env}-ckan-organogram/legacy/%{organogram_path}"), format: false

  if ENV["CKAN_DOMAIN"].present?
    get "dataset/edit/:legacy_name", to: redirect(domain: ENV["CKAN_DOMAIN"], subdomain: "", path: "/dataset/edit/%{legacy_name}")
  end

  get "dataset/:uuid", to: "datasets#show", uuid: /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  scope module: "legacy" do
    get "dataset/:legacy_name",
        to: "datasets#available_soon",
        constraints: ReferrerConstraint.new

    get "dataset/:legacy_name",                                 to: "datasets#redirect"
    get "dataset/:legacy_dataset_name/resource/:datafile_uuid", to: "datafiles#redirect"

    get "data/search", to: "search#redirect"
  end

  scope module: "pages" do
    get "about"
    get "accessibility"
    get "cookies"
    get "dashboard" # 410 Gone
    get "privacy"
    get "publishers"
    get "site-changes"
    get "support"
    get "support/new", to: redirect("/support")
    get "terms"
    get "ckan_maintenance"
  end

  match "404", to: "errors#not_found", via: :all
  match "500", to: "errors#internal_server_error", via: :all

  get "search/", to: "search#search"

  get "dataset/:uuid/:name", to: "datasets#show", as: "dataset"
  get "dataset/:dataset_uuid/:name/datafile/:datafile_uuid/preview", to: "previews#show", as: "datafile_preview"

  get "acknowledge", to: "messages#acknowledge"

  # Route everything else to CKAN
  if ENV["CKAN_DOMAIN"].present?
    match "*path",
          to: redirect(domain: ENV["CKAN_DOMAIN"], subdomain: "", path: "/%{path}"),
          via: :all,
          constraints: { path: /(?!#{Regexp.quote(Rails.application.config.assets.prefix[1..])}).+/ }
  end
end
