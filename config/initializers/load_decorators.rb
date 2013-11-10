Rails.application.config.to_prepare do
  Dir.glob(Rails.root.join("app/**/*_decorator*.rb")) do |c|
    Rails.configuration.cache_classes ? require(c) : load(c)
  end
end
