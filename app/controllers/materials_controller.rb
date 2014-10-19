class MaterialsController < ApplicationController
  require 'zip/zipfilesystem'

  include MaterialsHelper
  load_and_authorize_resource :course
  # These resources are not authorised through course because this controller is heterogenous, dealing with both folders and files
  check_authorization
  load_and_authorize_resource :material_folder, :parent => false, :only => [:edit_folder, :update_folder, :destroy_folder]
  load_and_authorize_resource :material, :parent => false, :only => [:show, :edit, :update, :destroy]
  
  before_filter :load_general_course_data, except: [:destroy, :destroy_folder]

  def index
    @folder = if params[:id] then
                MaterialFolder.find_by_id(params[:id])
              else
                MaterialFolder.find_by_course_id_and_parent_folder_id(@course, nil)
              end
    authorize! :show, @folder

    # If we are the root directory, we need to include the virtual entries for
    # this course
    if @folder.parent_folder == nil then
      vfolders = virtual_folders
    else
      vfolders = []
    end
    
    # Get the directory structure to the front-end JS.
    respond_to do |format|
      format.html {
        # Compute the set of folders and files the user can see.
        @subfolders =
          MaterialFolder.accessible_by(current_ability).where(:parent_folder_id => @folder) +
          vfolders
        @files =
          Material.accessible_by(current_ability).where(:folder_id => @folder)

        # Compute the new files in this directory
        seen_material_ids = @curr_user_course.seen_materials.pluck(:id).to_a
        @is_new = {}
        @files.each {|file|
          unless seen_material_ids.include?(file.id)
            @is_new[file.id] = true
          end
        }

        # Then any subfolders with new materials (so users can drill down to see what's new)
        @is_subfolder_new = {}
        @subfolders.each { |subfolder|
          if subfolder.is_virtual? then
            next
          end

          subfolder.materials.each { |material|
            unless seen_material_ids.include?(material.id)
              @is_subfolder_new[subfolder.id] = true
              break
            end
          }
        }

        gon.currentFolder = @folder
        gon.folders = build_subtree(@course.root_folder)
      }
      format.json {
        render :json => build_subtree(@folder, true)
      }
      format.zip {
        filename = build_zip @folder, :recursive => false, :include => params['include']
        send_file(filename, {
            :type => "application/zip, application/octet-stream",
            :disposition => "attachment",
            :filename => @folder.name + ".zip"
          }
        )
      }
    end
  end

  def index_virtual
    # Find the virtual folder matching the specified ID
    @folder = (virtual_folders.select {
        |folder| folder.id == params[:id] })
    raise ActiveRecord::RecordNotFound if @folder.length == 0
    @folder = @folder[0]
    authorize! :read, MaterialFolder

    respond_to do |format|
      format.html {
        # Template variables defined by index.
        @is_subfolder_new = []
        @is_new = []

        @subfolders = @folder.subfolders

        # Select only the files which the student can see.
        @files = @folder.files.select { |file|
          can? :read, file.parent
        }

        gon.currentFolder = @folder
        gon.folders = build_subtree(@course.root_folder)
        render "materials/index"
      }

      format.zip {
        filename = build_zip @folder, :include => params[:include]
        send_file(filename, {
            :type => "application/zip, application/octet-stream",
            :disposition => "attachment",
            :filename => @folder.name + ".zip"
        }
        )
      }
    end
  end

  def mark_folder_read
    @material_folder = MaterialFolder.where(:id => params[:material_folder_id]).first
    if not @material_folder then
      redirect_to course_materials_path(@course)
      return
    end
    authorize! :read, @material_folder

    @material_folder.materials.each { |m|
      curr_user_course.mark_as_seen(m)
    }

    respond_to do |format|
      format.html { redirect_to course_material_folder_path(@course, @material_folder) }
      format.json { render json: {status: 'OK'} }
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

    redirect_to material.file.file_url
  end

  def show_by_name
    # Resolve the subfolder ID + file name to an ID
    folder = MaterialFolder.find_by_id!(params[:id])
    file = folder.find_material_by_filename!(params[:filename])
    authorize! :show, file
    params[:id] = file.id

    show
  end

  def new
    @folder = MaterialFolder.find_by_id!(params[:id])
    authorize! :upload, @folder
  end

  def create
    @parent = MaterialFolder.find_by_id!(params[:id])
    authorize! :upload, @parent

    notice = nil
    if params[:type] == "files" && params[:files] then
      @parent.attach_files(params[:files], params[:descriptions])
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
    gon.currentMaterial = {
        filename: @material.filename
    }
    gon.currentFolder = @material.folder
  end

  def edit_folder
    @folder = MaterialFolder.find_by_id(params[:id])
    if not @folder then
      redirect_to :action => "index"
      return
    end
  end

  def update
    # check if we have a new file version
    if params[:new_file_id] != '' then
      @material.attach(FileUpload.find_by_id(params[:new_file_id]))
    end

    @material.update_attributes(params[:material])
    
    respond_to do |format|
      if @material.save
        # mark all the seen entries as unseen.
        SeenByUser.delete_all(obj_id: @material, obj_type: @material.class)

        format.html { redirect_to course_material_folder_path(@course, @material.folder),
                                  notice: "The file #{@material.filename} was successfully updated." }
      else
        gon.currentMaterial = {
          filename: Material.find_by_id(@material.id).filename
        }
        gon.currentFolder = @material.folder
        format.html { render action: "edit", params: {id: @material.id} }
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
        if folder.parent_folder
          format.html { redirect_to course_material_folder_path(@course, folder.parent_folder),
                                    notice: "The subfolder #{folder.name} was successfully updated." }
        else
          format.html { redirect_to course_material_folder_path(@course, folder),
            notice: "#{folder.name} was successfully updated." }
        end
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
    folder_metadata['subfolders'] = (folder.is_virtual? ?
      folder.subfolders : MaterialFolder.accessible_by(current_ability).where(:parent_folder_id => folder))
      .map { |subfolder|
        build_subtree(subfolder, include_files)
      }
    if (folder.parent_folder == nil) and not (folder.is_virtual?) then
      folder_metadata['subfolders'] += virtual_folders.map { |subfolder|
        build_subtree(subfolder, include_files)
      }
    end

    folder_metadata['id'] = folder.id
    folder_metadata['name'] = folder.name
    folder_metadata['url'] = folder.is_virtual? ? course_material_virtual_folder_path(@course, folder) : course_material_folder_path(@course, folder)
    folder_metadata['parent_folder_id'] = folder.parent_folder_id
    folder_metadata['count'] = folder.files.length
    folder_metadata['is_virtual'] = folder.is_virtual?
    seen_material_ids = @curr_user_course.seen_materials.pluck(:id).to_a

    if include_files then
      folder_metadata['files'] = (folder.is_virtual? ?
        folder.files : Material.accessible_by(current_ability).where(:folder_id => folder).includes(:file))
        .map { |file|
          current_file = {}

          current_file['id'] = file.id
          current_file['name'] = file.filename
          current_file['description'] = file.description
          current_file['folder_id'] = file.folder_id
          current_file['url'] = course_material_file_path(@course, file)

          unless folder.is_virtual? || seen_material_ids.include?(file.id)
            current_file['is_new'] = true
            folder_metadata['contains_new'] = true
          end

          current_file
        }
    end

    folder_metadata
  end

  # Builds the list of virtual folders which are accessible
  def virtual_folders
    entries = @course.materials_virtual_entries
    entries.each { |entry|
      entry.files = entry.files.select { |file|
        file.file.is_public && (can?(:manage, file.parent) ||
        (
          file.parent.can_start?(curr_user_course) && # User has satisfied achievements
          file.parent.published? && # Staff has published
          can?(:read, file.parent) # Permissions allowed
        ))
      }
    }
  end

  def build_zip(folder, options = {})
    result = nil
    recursive = !(not(options[:recursive]))
    include = options[:include]
    include = include.map {|i| Integer(i)} if include

    Dir.mktmpdir("coursemology-mat-temp") { |dir|
      # Extract all the files from AWS
      files = if recursive then
                folder.materials
              else
                folder.files
              end

      files.each { |m|
        if not (m.is_virtual?) and cannot? :read, m then
          next
        elsif include then
          if not include.include?(m.id) then
            next
          end
        end

        temp_path = File.join(dir, m.filename.gsub(/[:\/\\]/, "_"))
        m.file.file.copy_to_local_file :original, temp_path
        curr_user_course.mark_as_seen(m) unless m.is_virtual?

        # Create the directory structure for this file.
        parent_traversal = lambda {|d|
          dname = d ? d.name : nil
          if d && d.parent_folder && d.id != folder.id then
            prefix = parent_traversal.call(d.parent_folder)
          else
            # Root should not require a separate folder.
            prefix = 'root'
            dname = ''
          end

          prefix = File.join(prefix, dname)
          dir_path = File.join(dir, prefix)
          Dir.mkdir(dir_path) unless Dir.exists?(dir_path)

          prefix
        }
        prefix = parent_traversal.call(m.folder)

        File.rename(temp_path, File.join(dir, prefix, File.basename(temp_path)))
      }

      # Generate a file name to store the zip while we build it.
      prefix = File.join(dir, 'root')
      zip_name = File.join(File.dirname(dir),
        Dir::Tmpname.make_tmpname(["coursemology-mat-temp-zip", ".zip"], nil))
      Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) { |zipfile|
        # Add every file in the directory to the zip file, preserving structure.
        Dir[File.join(prefix, '**', '**')].each {|file|
          zipfile.add(file.sub(File.join(prefix + '/'), ''), file)
        }
      }

      result = zip_name
    }

    result
  end
end
