require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'nokogiri'
require 'csv'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test preview)))
  # If you want your assets lazily compiled in production, use this line
  #Bundler.require(:default, :assets, Rails.env)
end

module JfdiAcademy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths +=  Dir["#{config.root}/app/models/**/","#{config.root}/lib/**/"]
    config.autoload_paths += %W(#{config.root}/app/modules)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Singapore'
    config.active_record.default_timezone = :local

    config.i18n.enforce_available_locales = true
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Generate a Bootstrap-friendly field indicator. This is used to wrap the
    # *label* of the field which has validation errors.
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      #"<span class=\"field_with_errors\">#{html_tag}</span>".html_safe
      # Inspired by https://gist.github.com/t2/1464315
      html = %(<div class="field_with_errors">#{html_tag}</div>).html_safe
      # add nokogiri gem to Gemfile
      elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, input"
      elements.each do |e|
        if e.node_name.eql? 'label'
          e['class'] ||= ''
          e['class'] += ' error'
          html = e.to_s.html_safe
        elsif e.node_name.eql? 'input'
          if instance.error_message.kind_of?(Array)
            html = %(<div class="error">#{html_tag}<span class="help-inline">#{instance.error_message.join(',')}</span></div>).html_safe
          else
            html = %(<div class="error">#{html_tag}<span class="help-inline">#{instance.error_message}</span></div>).html_safe
          end
        end
      end
      html
    }
  end
end
