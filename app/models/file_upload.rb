class FileUpload < ActiveRecord::Base
  attr_accessible :owner_id, :owner_type, :creator_id, :owner, :file, :creator

  belongs_to :owner, :polymorphic => true
  belongs_to :creator, class_name: "User"

  has_attached_file :file

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
        "name" => read_attribute(:file_file_name),
        "size" => read_attribute(:file_file_size),
        "url" => file.url(:original),
        "delete_url" => file_upload_path(self),
        "delete_type" => "DELETE"
    }
  end
end
