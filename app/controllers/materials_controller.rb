class MaterialsController < ApplicationController
  include MaterialsHelper
  load_and_authorize_resource :course
  # These resources are not authorised through course because this controller is heterogenous, dealing with both folders and files
  load_and_authorize_resource :material_folder, :parent => false, :only => [:edit_folder, :update_folder, :destroy_folder]
  load_and_authorize_resource :material, :parent => false, :except => [:index, :edit_folder, :update_folder, :destroy_folder]
  
  before_filter :load_general_course_data, only: [:index, :index_virtual, :edit, :new]

  def index
    authorize! :index, Material
    @subfolder = MaterialFolder.new()
    @folder = if params[:id] then
                MaterialFolder.find_by_id(params[:id])
              else
                MaterialFolder.find_by_course_id_and_parent_folder_id(@course.id, nil)
              end

    # Compute the new files in this directory
    @is_new = {}
    @folder.files.each {|file|
      unless @curr_user_course.seen_materials.exists?(file)
        @is_new[file.id] = true
      end
    }

    # Then any subfolders with new materials (so users can drill down to see what's new)
    @is_subfolder_new = {}
    @folder.subfolders.each { |subfolder|
      subfolder.materials.each { |material|
        if not @curr_user_course.seen_materials.exists?(material.id) then
          @is_subfolder_new[subfolder.id] = true
          break
        end
        material.id
      }
    }

    # If we are the root directory, we need to include the virtual entries for
    # this course
    if @folder.parent_folder == nil then
      @virtual_folders = @course.workbin_virtual_entries
    else
      @virtual_folders = []
    end
    
    # Get the directory structure to the front-end JS.
    respond_to do |format|
      format.html {
        gon.currentFolder = @folder
        gon.folders = build_subtree(@course.material_folder)
      }
      format.json {
        render :json => build_subtree(@folder, true)
      }
    end
  end

  def index_virtual
    # Find the virtual folder matching the specified ID
    @folder = (@course.workbin_virtual_entries.select {
        |folder| folder.id == params[:virtual] })
    raise ActiveRecord::RecordNotFound if @folder.length == 0
    @folder = @folder[0]

    # Template variables defined by index.
    @virtual_folders = []
    @is_subfolder_new = []
    @is_new = []

    respond_to do |format|
      format.html {
        gon.currentFolder = @folder
        gon.folders = build_subtree(@course.material_folder)
        render "materials/index"
      }
    end
  end

  def show
    material = Material.find_by_id(params[:id])
    if not material then
      redirect_to :action => "index"
      return
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
      return
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
      @parent.new_subfolder(params[:material_folder][:name], params[:material_folder][:description])
      notice = "The subfolder #{params[:material_folder][:name]} was successfully created."
    end

    respond_to do |format|
      if @parent.save
        format.html { redirect_to course_material_folder_path(@course, @parent),
                                  notice: notice }
      else
        format.html { render action: "new", params: {parent: @parent} }
      end
    end
  end

  def edit
    @material = Material.find_by_id(params[:id])
    if not @material then
      redirect_to :action => "index"
      return
    end
  end

  def edit_folder
    @folder = MaterialFolder.find_by_id(params[:id])
    if not @folder then
      redirect_to :action => "index"
      return
    end
  end

  def update
    material = Material.find_by_id(params[:id])
    if not material then
      redirect_to :action => "index"
      return
    end

    # check if we have a new file version
    if params[:new_file_id] != '' then
      material.attach(FileUpload.find_by_id(params[:new_file_id]))
    end

    material.update_attributes(params[:material])
    
    respond_to do |format|
      if material.save
        # mark all the seen entries as unseen.
        SeenByUser.delete_all(obj_id: material, obj_type: material.class)

        format.html { redirect_to course_material_folder_path(@course, material.folder),
                                  notice: "The file #{material.filename} was successfully updated." }
      else
        format.html { render action: "edit", params: {id: material.id} }
      end
    end
  end

  def update_folder
    folder = MaterialFolder.find_by_id(params[:id])
    if not folder then
      redirect_to :action => "index"
      return
    end

    folder.update_attributes(params[:material_folder])
    respond_to do |format|
      if folder.save
        format.html { redirect_to course_material_folder_path(@course, folder.parent_folder),
                                  notice: "The subfolder #{folder.name} was successfully updated." }
      else
        format.html { render action: "edit_folder", params: {id: folder.id} }
      end
    end
  end
  
  def destroy
    file = Material.find_by_id(params[:id])
    if not file then
      redirect_to :action => "index"
      return
    end

    folder = file.folder
    filename = file.filename
    file.destroy
    respond_to do |format|
      format.html { redirect_to course_material_folder_path(@course, folder),
                                notice: "The file #{filename} was successfully deleted." }
    end
  end

  def destroy_folder
    folder = MaterialFolder.find_by_id(params[:id])
    if not folder then
      redirect_to :action => "index"
      return
    end

    parent = folder.parent_folder
    foldername = folder.name
    folder.destroy
    respond_to do |format|
      format.html { redirect_to course_material_folder_path(@course, parent),
                                notice: "The folder #{foldername} was successfully deleted." }
    end
  end

private
  # Builds a hash containing the given folder and all files in it, as a tree.
  def build_subtree(folder, include_files = true)
    folder_metadata = {}
    folder_metadata['subfolders'] = folder.subfolders.map { |subfolder|
      build_subtree(subfolder, include_files)
    }
    if (folder.parent_folder == nil) and not (folder.is_virtual) then
      folder_metadata['subfolders'] += @course.workbin_virtual_entries.map { |subfolder|
        build_subtree(subfolder, include_files)
    }
    end

    folder_metadata['id'] = folder.id
    folder_metadata['name'] = folder.name
    folder_metadata['url'] = folder.is_virtual ? course_material_virtual_folder_path(@course, folder.id) : course_material_folder_path(@course, folder)
    folder_metadata['parent_folder_id'] = folder.parent_folder_id
    folder_metadata['count'] = folder.materials.length
    if include_files then
      folder_metadata['files'] = folder.files.map { |file|
        current_file = {}
        
        current_file['id'] = file.id
        current_file['name'] = file.filename
        current_file['description'] = file.description
        current_file['folder_id'] = file.folder_id
        current_file['url'] = course_material_path(@course, file)
        current_file
      }
    end

    folder_metadata
  end
end
