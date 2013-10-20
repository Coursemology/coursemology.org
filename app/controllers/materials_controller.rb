class MaterialsController < ApplicationController
  include MaterialsHelper
  load_and_authorize_resource :course
  #load_and_authorize_resource :material, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:index, :edit, :new]

  def index
    @subfolder = MaterialFolder.new()
    @folder = if params[:id] then
                MaterialFolder.find_by_id(params[:id])
              else
                MaterialFolder.find_by_course_id_and_parent_folder_id(@course.id, nil)
              end
    @is_new = {}
    @is_subfolder_new = {}
  end

  def show
    material = Material.find_by_id(params[:id])
    if not material then
      redirect_to :action => "index"
    end

    if curr_user_course then
      curr_user_course.mark_as_seen(material)
    end

    redirect_to material.file.file.url
  end

  def new
    @folder = MaterialFolder.find_by_id(params[:parent])
    if not @folder then
      redirect_to :action => "index"
    end
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
      notice = "The subfolder #{params[:material_folder][:name]} was successfully created."
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
end
