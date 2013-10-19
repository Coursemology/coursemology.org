class MaterialsController < ApplicationController
  load_and_authorize_resource :course
  #load_and_authorize_resource :material, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:index, :edit, :new]

  def index
    @folder = if params[:id] then
                MaterialFolder.find_by_id(params[:id])
              else
                MaterialFolder.find_by_course_id_and_parent_folder_id(@course.id, nil)
              end
    @is_new = {}
    @is_subfolder_new = {}
  end

  def show

  end

  def new
    @folder = MaterialFolder.find_by_id(params[:parent])
  end

  def create
    #TODO Make sure that we get a valid folder ID to upload to
    @parent = MaterialFolder.find_by_id(params[:parent])
    if params[:files]
      @parent.attach_files(params[:files].values)
    end

    respond_to do |format|
      if @parent.save
        format.html { redirect_to course_material_folder_url(@course, @parent),
                                  notice: "The files were successfully uploaded." }
      else
        format.html { render action: "new", params: {parent: @parent} }
      end
    end
  end
  
  def new_subfolder
    
  end
end
