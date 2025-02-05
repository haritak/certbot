require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CertPrintShop
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # (ych) 17/11/2022 
    # (source) https://guides.rubyonrails.org/i18n.html
    config.i18n.default_locale = :el

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #

    # https://guides.rubyonrails.org/active_storage_overview.html
    # Store files locally.
    config.active_storage.service = :local

    # (ych) 2022-11-23
    config.active_job.queue_adapter = :sidekiq

    # (ych) 17/11/2022
    # (sources)
    # https://guides.rubyonrails.org/action_mailer_basics.html
    # https://dev.to/morinoko/sending-emails-in-rails-with-action-mailer-and-gmail-35g4
    # Unlike controllers, the mailer instance doesn't have any context about the incoming request so you'll need to provide the :host parameter yourself.
    # As the :host usually is consistent across the application you can configure it globally in ...
    # config.action_mailer.logger = Logger.new(STDOUT)
    config.action_mailer.default_url_options = { host: ENV['CERTBOT_HOST'], protocol: ENV['CERTBOT_PROTOCOL'] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true # (ych) sch.gr raises Net::ReadTimeout as well as Net::WriteTimeout when sending attachments...
    config.action_mailer.smtp_timeout = 2 #5 is the default, 10 fails also ... # (ych) default is 5 but sch.gr may require a bit more.
    config.action_mailer.smtp_settings = {
      :address              => ENV['CERTBOT_SMTP_SERVER'],
      :port                 => ENV['CERTBOT_SMTP_PORT'],
      :user_name            => ENV['CERTBOT_SMTP_USERNAME'],
      :password             => ENV['CERTBOT_SMTP_PASSWORD'],
      :authentication       => "plain",
      :enable_starttls_auto => true,
    }
    config.action_mailer.deliver_later_queue_name = "critical" #emails shouldn't wait for other jobs

    config.hosts << ENV['CERTBOT_HOST']

  end
end
