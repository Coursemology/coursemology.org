class CourseNotificationsController < ApplicationController
  load_and_authorize_resource :course

  def get
    counts = {}
    if curr_user_course.id
      all_trainings = @course.assessments.training.accessible_by(current_ability)
      unseen_trainings = all_trainings - curr_user_course.seen_assessments
      counts[:trainings] = unseen_trainings.count

      all_announcements = @course.announcements.accessible_by(current_ability)
      unseen_anns = all_announcements - curr_user_course.seen_announcements
      counts[:announcements] = unseen_anns.count

      all_missions = @course.assessments.mission.accessible_by(current_ability)
      unseen_missions = all_missions - curr_user_course.seen_assessments
      counts[:missions] = unseen_missions.count
      counts[:surveys]  = @course.pending_surveys(curr_user_course).count

      all_materials = Material.where(folder_id: (curr_user_course.is_student? ?
          @course.material_folders.opened_folder :
          @course.material_folders)).accessible_by(current_ability)
      unseen_materials = all_materials - curr_user_course.seen_materials
      counts[:materials] = unseen_materials.count

      all_comics = @course.accessible_comics(curr_user_course)
      unseen_comics = all_comics - curr_user_course.seen_comics
      counts[:comics] = unseen_comics.count

      #if can? :see_all, Submission
      #  # lecturers see number of new submissions of all students in the course
      #  all_sbms = @course.submissions.accessible_by(current_ability) +
      #      @course.training_submissions.accessible_by(current_ability)
      #  unseen_sbms = all_sbms - curr_user_course.get_seen_sbms
      #  counts[:submissions] = unseen_sbms.count
      #end
      if can? :see, :pending_grading
        counts[:pending_gradings] = @course.get_pending_gradings(curr_user_course).count
      end
      if can? :see, :pending_comments
        counts[:comments] = @course.count_pending_comments
      end
      counts[:pending_enrol] = @course.enroll_requests.count
      # TODO students see the number of new gradings

      counts[:forums] = ForumTopic.unread(curr_user_course).
          where(forum_id: @course.forums.accessible_by(current_ability)).count
    end

    respond_to do |format|
      format.json {render json: counts }
    end
  end
end


