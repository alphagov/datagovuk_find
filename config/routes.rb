Rails.application.routes.draw do
  root to: 'pages#home'

  get 'dataset/:uuid', to: 'datasets#show', uuid: /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  scope module: 'legacy' do
    get 'dataset/:legacy_name',
        to: 'datasets#available_soon',
        constraints: lambda { |req| Rails.logger.debug "## REFERRER ##: #{req.referrer}"; req.referrer.present? && URI.parse(req.referrer).path == '/dataset/new' }

    get 'dataset/:legacy_name',                                 to: 'datasets#redirect'
    get 'dataset/:legacy_dataset_name/resource/:datafile_uuid', to: 'datafiles#redirect'

    get 'data/search',                     to: 'search#redirect'

    get 'contact',                         to: redirect('support')
    get 'cookies-policy',                  to: redirect('cookies')
    get 'accessibility-statement',         to: redirect('accessibility')
    get 'technical-details',               to: redirect('about')
    get 'terms-and-conditions',            to: redirect('terms')
    get 'faq',                             to: redirect('about')

    get 'apps',                            to: redirect('site-changes')
    get 'apps/*_app',                      to: redirect('site-changes')
    get 'node/*_node',                     to: redirect('site-changes')
    get 'reply/*_reply',                   to: redirect('site-changes')
    get 'comments/*_comment',              to: redirect('site-changes')
    get 'forum',                           to: redirect('site-changes')
    get 'forum/*_forum',                   to: redirect('site-changes')
    get 'dataset/*_slug/issues/*_issue',   to: redirect('site-changes')
  end

  scope module: 'pages' do
    get 'about'
    get 'accessibility'
    get 'cookies'
    get 'dashboard'
    get 'privacy'
    get 'publishers'
    get 'site-changes', to: :site_changes
    get 'support'
    get 'terms'
  end

  match "404", to: "errors#not_found", via: :all
  match "500", to: "errors#internal_server_error", via: :all

  get 'search/', to: 'search#search'

  get 'search/tips', to: 'search#tips'

  resources :tickets, only: [:new, :create]
  get 'tickets/confirmation', to: 'tickets#confirmation'

  get 'dataset/:uuid/:name', to: 'datasets#show', as: 'dataset'
  get 'dataset/:dataset_uuid/:name/datafile/:datafile_uuid/preview', to: 'previews#show', as: 'datafile_preview'

  get 'acknowledge', to: 'messages#acknowledge'
end
