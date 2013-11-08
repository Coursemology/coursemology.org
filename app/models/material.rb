class Material < ActiveRecord::Base
  belongs_to :creator, class_name: "User"
  belongs_to :folder, class_name: "MaterialFolder"
  has_one :file, as: :owner, class_name: "FileUpload", dependent: :destroy
  has_many :lesson_plan_resources, as: :obj, dependent: :destroy

  attr_accessible :folder, :description, :filename
  after_save :save_file

  validate :material_filename_unique

  def save_file
    if self.file then
      self.file.save
    end
  end

  # Creates a virtual item of this class that is backed by some other data store.
  def self.create_virtual(parent, obj)
    (Class.new do
      # Give the ID of this virtual folder. Should be the module name.
      def initialize(parent, obj)
        @parent = parent
        @obj = obj
        @name = @file = @description = @updated_at = @url = nil
      end

      def id
        -1
      end
      def obj
        @obj
      end
      def parent
        @parent
      end
      def filename
        @filename
      end
      def filename=(name)
        @filename = name
      end
      def filesize
        @filesize
      end
      def filesize=(size)
        @filesize = size
      end
      def file
        @file
      end
      def file=(file)
        @file = file
      end
      def description
        @description
      end
      def description=(description)
        @description = description
      end
      def updated_at
        @updated_at
      end
      def updated_at=(updated_at)
        @updated_at = updated_at
      end
      def url
        @url
      end
      def url=(url)
        @url = url
      end
      def folder
        nil
      end
      def folder_id
        -1
      end

      def is_virtual
        true
      end
    end).new(parent, obj)
  end

  def filename
    self.file.original_name || self.file.file_file_name
  end
  
  def filename=(filename)
    self.file.original_name = filename
  end
    
  def title
    self.filename
  end

  def filesize
    self.file.file_file_size
  end

  # Attaches the given file to this material; if an existing file is linked, the
  # link is broken.
  def attach(file)
    existing_file = self.file

    file.owner = self
    file.original_name = existing_file.original_name if existing_file
    if file.save and existing_file then
      existing_file.owner_type = nil
      existing_file.owner_id = nil
      existing_file.save
    end
  end

  def is_virtual
    false
  end

private
  def material_filename_unique
    if filename.length == 0 then
      errors.add(:filename, "cannot have empty filenames")
    end

    f = folder.find_material_by_filename(filename)
    if f && f.id != f then
      errors.add(:filename, "cannot have non-unique filenames")
    end
  end
end
