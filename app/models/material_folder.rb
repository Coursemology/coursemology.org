class MaterialFolder < ActiveRecord::Base
  acts_as_duplicable
  belongs_to :creator, class_name: "User"

  # Folder structure
  belongs_to :parent_folder, class_name: "MaterialFolder"
  belongs_to :course, class_name: "Course"
  has_many :subfolders, dependent: :destroy, class_name: "MaterialFolder", foreign_key: "parent_folder_id"
  has_many :files, dependent: :destroy, class_name: "Material", foreign_key: "folder_id"

  scope :opened_folder, where("(open_at IS NULL OR open_at <= ?) and (close_at is NULL or close_at >= ?)", DateTime.now, DateTime.now)

  attr_accessible :parent_folder, :course, :course_id, :name, :description, :can_student_upload, :open_at, :close_at

  amoeba do
    include_field [:subfolders, :files]
    #course_navbar_preferences
    # course_preferences
  end

  # Creates a virtual item of this class that is backed by some other data store.
  def self.create_virtual(id, parent_id)
    (Class.new do
      # Give the ID of this virtual folder. Should be the module name.
      def initialize(id, parent_id)
        @id = id
        @name = @description = nil
        @files = []
        @parent_folder = MaterialFolder.find_by_id(parent_id)
      end

      def id
        @id
      end
      def name
        @name
      end
      def name=(name)
        @name = name
      end
      def description
        @description
      end
      def description=(description)
        @description = description
      end
      def can_student_upload?
        false
      end
      def is_open?
        true
      end
      def files
        @files
      end
      def files=(files)
        @files = files
      end
      
      # For now virtual folders can't have subfolders, so we merge them
      def materials
        files
      end
      def parent_folder
        @parent_folder
      end
      def parent_folder_id
        @parent_folder.id
      end
      def subfolders
        []
      end
      def updated_at
        nil
      end

      def to_param
        id
      end
      def is_virtual?
        true
      end
    end).new(id, parent_id)
  end

  def find_material_by_filename(filename)
    f = files.select {|f|
      f.filename == filename
    }

    f.length == 0 ? nil : f[0]
  end

  def find_material_by_filename!(filename)
    f = find_material_by_filename(filename)

    raise ActiveRecord::RecordNotFound if not(f)
    f
  end

  def subfolders_recursive
    [self] + (subfolders.map{|subfolder|
      subfolder.subfolders_recursive
    }).reduce([]) {|e, accum|
      e + accum
    }
  end

  def materials
    subfolder_recursive_ids = subfolders_recursive
    Material.where(:folder_id => subfolder_recursive_ids)
  end

  def attach_files(files, descriptions)
    files.each do |key, id|
      # Create a material record
      material = Material.create(folder: self)

      # Associate the file upload with the record
      file = FileUpload.find_by_id(id)
      if not(file)
        next
      end
      material.attach(file)
      material.description = descriptions[key]
      material.save
    end
  end

  def is_open?
    (open_at == nil || open_at <= DateTime.now) &&
    (close_at == nil || close_at >= DateTime.now)
  end

  def new_subfolder(name, description = nil)
    subfolder = MaterialFolder.create(:parent_folder => self, :course_id => course_id, :name => name, :description => description)
    subfolder.save
  end

  def is_virtual?
    false
  end

  def dup_course(to_course, dic = nil, dup_files = true)
    clone = dup
    clone.course = to_course
    subfolders.each do |folder|
      clone_folder = folder.dup_course(to_course, dic, dup_files)
      clone_folder.parent_folder = clone
      clone_folder.save
    end

    if dup_files
      files.each do |material|
        clone_material = material.dup
        clone_material.folder = clone
        clone_material.save
        if dic
          dic[material] = clone_material
        end
      end
    end
    clone.save
    clone
  end

  def title
    name
  end
end
