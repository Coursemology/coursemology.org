class FileUpload < ActiveRecord::Base
  attr_accessible :owner_id, :owner_type, :creator_id, :owner, :file, :creator, :original_name, :copy_url

  belongs_to :owner, :polymorphic => true
  belongs_to :creator, class_name: "User"

  has_attached_file :file, :restricted_characters => /[:\/\\]/

  before_post_process :hash_filename
  after_save :sync_filename

  include Rails.application.routes.url_helpers
  require 'digest/md5'

  def to_jq_upload
    {
        "id"    =>  read_attribute(:id),
        "name"  => read_attribute(:file_file_name),
        "size"  => read_attribute(:file_file_size),
        "url"   => file_url,
        "original" => read_attribute(:original_name),
        "timestamp" => created_at.strftime("%d-%m-%Y %H:%M:%S"),
        "delete_url"  => file_upload_path(self),
        "delete_type" => "DELETE"
    }
  end

  # Whether the current save operation will preserve the filename
  def preserve_filename?
    not(@hash_filenames)
  end

  # Sets whether the filename will be preserved when this record is saved
  def preserve_filename=(preserve = true)
    @hash_filenames = not(preserve)
  end

  # Sets that the filename will be preserved when this record is saved
  def preserve_filename!
    self.preserve_filename = (true)
  end

  # Gets the display filename for the upload: It will give the original name if present, otherwise
  # it will be the (obfuscated) storage filename
  def display_filename
    original_name || file_file_name
  end

  # Sets the display filename for the upload.
  def display_filename=(filename)
    self.original_name = filename
  end

  # Sets the download filename for this upload. By default, this is obfuscated. This is the filename
  # that the users will see when they try to download this particular file.
  #
  # nil can be specified as the filename to remove the download filename.
  def download_filename=(filename)
    save_s3_filename(filename)
    nil
  end

  def dup_owner(new_owner)
    #FileUpload.skip_callback(:save, :after, :sync_filename)
    clone_file = FileUpload.new
    clone_file.copy_url = file_url
    clone_file.original_name = original_name
    clone_file.owner = new_owner
    clone_file.file_file_name = file_file_name
    clone_file.file_file_size = file_file_size
    clone_file.file_content_type = file_content_type
    clone_file.creator = creator
    clone_file.save
    #FileUpload.set_callback(:save, :after, :sync_filename)
  end

  def file_url
    if copy_url
      copy_url
    else
      file.url
    end
  end

  private
  # Stores on disk the hash of the file, for uniqueness as well as to obfuscate the file name, where necessary
  # for example, in surveys.
  def hash_filename
    self.original_name = self.file_file_name.to_s
    self.file.instance_write(:file_name, "#{Digest::MD5.hexdigest(self.file_file_name)}#{File.extname(self.file_file_name)}")
    false
  end

  # Callback after saving the record to sync the filename with AWS
  def sync_filename
    save_s3_filename(preserve_filename? ? original_name : nil)
  end

  # Sets the download filename of S3 if specified; otherwise removes the filename.
  def save_s3_filename(filename)
    unless self.file then
      return
    end

    if self.copy_url
      return
    end

    obj = file.s3_object
    unless obj then
      return
    end

    # Preserve the ACL of the file we are replacing
    acl = obj.acl

    # Copy the file in place -- this replaces the headers but retains content
    options = {
        content_disposition: (filename ? 'attachment; filename="' + filename + '"' : '')
    }
    new_obj = obj.copy_to(obj.key, options)

    # Restore ACL since copy_to does not preserve it
    new_obj.acl = acl
  end

end
