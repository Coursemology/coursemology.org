class MaterialsController < ApplicationController
  include MaterialsHelper
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
    
    notice = nil
    if params[:type] == "files" && params[:files] then
      @parent.attach_files(params[:files].values)
      notice = "The files were successfully uploaded."
    elsif params[:type] == "subfolder" && params[:material_folder][:name] then
      @parent.new_subfolder(params[:material_folder][:name])
      notice = "The subfolder was successfully created."
    end

    respond_to do |format|
      if @parent.save
        format.html { redirect_to course_material_folders_url(@course, @parent),
                                  notice: notice }
      else
        format.html { render action: "new", params: {parent: @parent} }
      end
    end
  end
  
  def new_subfolder
    @parent = MaterialFolder.find_by_id(params[:parent])

    @folder = MaterialFolder.new()
  end
end
