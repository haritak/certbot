require 'sidekiq/web' # (ych) https://github.com/mperham/sidekiq/wiki/Monitoring#standalone

#
# Σημείωση:
#
# Κάποια URLs εξυπηρετούνται απευθείας από τον apache και δεν θα πρέπει να γίνονται 
# proxy από εμάς.
#
# Αυτά είναι :
# * /self_generated_files
# * /assets
# * /public/assets
# * /static_content
#
# Το τρέχων configuration του apache μας είναι :
#
# <Location /certbot>
# Require all granted
# ProxyPass http://127.0.0.1:12233/certbot
# ProxyPassReverse http://127.0.0.1:12233/certbot
# ProxyPassReverseCookieDomain 127.0.0.1 certbot.pdekritis.gr
# ProxyPreserveHost on
# # make sure Rails knows it was an SSL request (https://gist.github.com/abachman/851492)
# RequestHeader set X_FORWARDED_PROTO 'https'
# </Location>
# <Location /rails>
# Require all granted
# ProxyPass http://127.0.0.1:12233/rails
# ProxyPassReverse http://127.0.0.1:12233/rails
# ProxyPassReverseCookieDomain 127.0.0.1 server42.pdekritis.gr
# ProxyPreserveHost on
# # make sure Rails knows it was an SSL request (https://gist.github.com/abachman/851492)
# RequestHeader set X_FORWARDED_PROTO 'https'
# </Location>
# <Location /self_generated_files>
# Require all granted
# </Location>
# <Location /assets>
# RewriteEngine on
# Require all granted
# RewriteRule /assets/(.*)$ /public/assets/$1 [L]
# </Location>
# <Location /public/assets>
# Require all granted
# </Location>
# <Location /static_content>
# Require all granted
# </Location>

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  default_url_options protocol: :https

  scope '/certbot' do  # scope is used mainly due to Reverse Proxy setup of apache2
    # Defines the root path route ("/")
    # root "articles#index"
    #
    # should be first so that it is matched early.
    #
    root to: "home#index" 
    get  'prepare_my_certificate/:secret_url_part', to: 'self_service_print_job_specs#prepare_self_service_page', as: 'self_service_prepare'
    post 'prepare_my_certificate/:secret_url_part', to: 'self_service_print_job_specs#self_service_perform'
    get 'get_my_certificate/:secret_url_part/:user_specific_page', to: 'self_service_print_job_specs#self_service_download', as: 'self_service_download'


    devise_for :users, controllers: {
      sessions: 'users/sessions'
    }

    resources :users, controller: 'settings' do
      member do
        resources :smtp_accounts
      end
    end
    resources :generated_files
    resources :email_jobs do
      member do
        get :resend
      end
    end
    resources :print_jobs
    resources :odt_files
    get 'odt_files/download'
    resources :csv_files
    get 'csv_files/download'
    resources :fixed_attachments
    get 'fixed_attachments/download'
    resources :email_job_specs do
      get 'resend_failed'
      member do
        get 'generated_emails'
      end
    end
    resources :system_smtp_accounts
    resources :print_job_specs do
      member do
       get 'generated_files'
       get 'remove_odts'
       get 'remove_pdfs'
       get 'generated_emails'
       get 'new_email_job'
       get 'new_self_service'
       post 'backup'
       get 'download_backup'
      end
    end
    resources :self_service_print_job_specs do
      member do
        resources :self_service_generated_files
        get 'self_generated_emails/index', as: "self_generated_emails"
        get 'resend_emails'
      end
    end
    resources :self_service_generated_files do
      member do
        get :regenerate
        get :remove_all_odts
        get :remove_all_pdfs
      end
    end
    resources :self_generated_emails do
      member do
        get :resend
      end
    end

    get 'generated_files/download/:id', to: 'generated_files#download', as: 'download_generated_file'
    get 'self_service_generated_files/download/:id', to: 'self_service_generated_files#download', as: 'download_self_service_generated_file'
    get 'generated_files/send_email_for/:id', to: 'generated_files#send_as_email', as: 'send_generated_file'
    get 'settings/:id', to: 'settings#show', as: 'settings'
    get 'settings/edit/:id', to: 'settings#edit', as: 'edit_settings'
    post 'smtp_accounts/:id/test/:id', to: 'smtp_accounts#test_smtp_account'
    get 'system_smtp_accounts/test/:id', to: 'system_smtp_accounts#test_system_smtp_account'
    post 'settings/set_session_password_pin', to: 'settings#set_session_password_pin'

    #src: https://github.com/mperham/sidekiq/wiki/Monitoring#standalone
    authenticate :user, ->(user) { user.is_admin? } do
      mount Sidekiq::Web => '/jobs', as: 'sidekiq_jobs'
    end

    #match '*unmatched', to: 'home#index', status: 404, via: :all #XXX
  end
end
