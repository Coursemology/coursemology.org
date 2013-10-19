class MaterialsController < ApplicationController
  load_and_authorize_resource :course

  def show
    @folder = if params["id"] then
                MaterialFolder.find_by_id(params["id"])
              else
                MaterialFolder.find_by_course_id_and_parent_folder_id(@course.id, nil)
              end
  end

  def new
    
  end
end
