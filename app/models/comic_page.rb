class ComicPage < ActiveRecord::Base
  belongs_to :comic

  attr_accessible :page

  has_one :file, as: :owner, class_name: "FileUpload", dependent: :destroy

end
