if Rails.env == "development"
  Dir.foreach("#{Rails.root}/app/models") do |model_name|
    require_dependency model_name unless model_name.start_with?(".") || !File.exist?(model_name)
  end

  Dir.foreach("#{Rails.root}/app/models/modules") do |module_name|
    require_dependency module_name unless module_name.start_with?(".") || !File.exist?(module_name)
  end
end