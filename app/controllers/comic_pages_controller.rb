class ComicPagesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :comic, through: :course
  load_and_authorize_resource :comic_page, through: :comic

  def destroy
    @comic_page.destroy

    respond_to do |format|
      format.html { redirect_to edit_course_comic_url(@course, @comic),
                                notice: "One page has been removed." }
    end
  end
end
