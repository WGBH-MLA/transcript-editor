Rails.application.routes.draw do

  resources :flags, only: [:index, :show, :create]
  resources :transcript_speaker_edits, only: [:create]
  resources :transcript_edits, only: [:index, :show, :create]
  resources :transcript_files, only: [:index, :show]
  resources :transcripts, only: [:index, :show, :update]
  resources :collections, only: [:index, :show]

  mount_devise_token_auth_for 'User', at: 'auth', controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  match 'page/:id' => 'default#index', :via => [:get]
  match 'dashboard' => 'default#index', :via => [:get]
  match 'transcript_lines/:id/resolve' => 'transcript_lines#resolve', :via => [:post]
  match 'search' => 'transcripts#search', :via => [:get]

  # Adds route for AAPB JSON transcript
  match 'transcripts/aapb/:id' => 'transcripts#aapb', :via => [:get], :as => :aapb_transcript

  # route for releases
  match 'release_count' => 'transcripts#release_count', via: [:get]
  match 'all_uids' => 'transcripts#all_uids', via: [:get]

  # admin
  namespace :admin do
    resources :users, only: [:index, :update]
    resources :transcripts, only: [:index]
    resources :flags, only: [:index]
  end
  match 'stats.json' => 'admin/stats#index', :via => [:get]

  # load layouts
  match 'admin' => 'default#admin', :via => [:get]
  match 'admin/users' => 'default#admin', :via => [:get]
  match 'moderator/flags' => 'default#admin', :via => [:get]
  match 'transcripts/:id' => 'default#index', :via => [:get]
  match 'admin/transcripts' => 'default#admin', :via => [:get]

  # mediacontroller
  match 'media/:id' => 'media#show', :via => [:get]

  match 'api/ingest' => 'api#ingest', :via => [:post]

  root :to => 'default#index'
end