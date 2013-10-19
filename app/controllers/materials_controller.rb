class MaterialsController < ApplicationController
  load_and_authorize_resource :course
  #load_and_authorize_resource :material, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:index, :edit, :new]

  def index
    @folder = if params["id"] then
                MaterialFolder.find_by_id(params["id"])
              else
                MaterialFolder.find_by_course_id_and_parent_folder_id(@course.id, nil)
              end
    @is_new = {}
    @is_subfolder_new = {}
  end

  def show

  end

  def new
    
  end

  def new_subfolder
    
  end
end
