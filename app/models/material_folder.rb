class MaterialFolder < ActiveRecord::Base
  belongs_to :creator, class_name: "User"

  # Folder structure
  belongs_to :parent_folder, class_name: "MaterialFolder"
  has_many :subfolders, dependent: :destroy, class_name: "MaterialFolder", foreign_key: "parent_folder_id"
  has_many :files, dependent: :destroy, class_name: "Material", foreign_key: "folder_id"

  def materials
    result = []
    #self.subfolders.each { |f| result += f.materials }
    self.files.each { |f| result += [f] }
    
    result
  end
end
