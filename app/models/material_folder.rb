class MaterialFolder < ActiveRecord::Base
  belongs_to :creator, class_name: "User"

  # Folder structure
  belongs_to :parent_folder, class_name: "MaterialFolder"
  has_many :subfolders, dependent: :destroy, class_name: "MaterialFolder", foreign_key: "parent_folder_id"
  has_many :files, dependent: :destroy, class_name: "Material", foreign_key: "folder_id"

  attr_accessible :parent_folder, :course_id, :name

  def materials
    result = []
    self.subfolders.each { |f| result += f.materials }
    self.files.each { |f| result += [f] }
    
    result
  end

  def attach_files(files)
    files.each do |id|
      # Create a material record
      material = Material.create(folder: self)

      # Associate the file upload with the record
      file = FileUpload.find_by_id(id)
      if file
        material.attach(file)
      end
      material.save
    end
  end

  def new_subfolder(name)
    subfolder = MaterialFolder.create(:parent_folder => self, :course_id => course_id, :name => name)
    subfolder.save
  end
end
