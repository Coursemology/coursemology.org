class Material < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :creator, class_name: "User"
end
