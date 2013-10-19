class MaterialsController < ApplicationController
  load_and_authorize_resource :course

  def index
    show nil
  end
  
  def show id
    @folder = if id then
                MaterialFolder.find_by_id(id)
              else
                MaterialFolder.find_by_course_id_and_parent_folder_id(@course.id, nil)
              end
  end

  def new(parent)
    
  end
end
