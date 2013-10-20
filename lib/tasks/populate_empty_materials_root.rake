namespace :db do
  desc "Populate with root Materials folder"

  task populate_empty_materials_root: :environment do
    Course.all.each do |course|
      Rails.logger.info(course)
      unless @course.material_folder
        MaterialFolder.create(:course => course, :name => "Root")
      end
    end
  end
end
