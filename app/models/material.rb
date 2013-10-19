class Material < ActiveRecord::Base
  belongs_to :creator, class_name: "User"
  belongs_to :folder, class_name: "MaterialFolder"
end
