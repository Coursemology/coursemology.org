class Comic < ActiveRecord::Base

  attr_accessible :visible, :chapter, :name, :episode, :dependent_mission_id, :next_mission_id

  scope :published, where(:visible => true)

  belongs_to :course
  belongs_to :dependent_mission, class_name: "Mission", foreign_key: "dependent_mission_id"
  belongs_to :next_mission, class_name: "Mission", foreign_key: "next_mission_id"

  has_many :comic_pages, dependent: :destroy

  def attach_files(files)
    last_page = self.comic_pages.order('page DESC').first
    page_no = last_page ? last_page.page : 0
    sorted = files.sort_by {|key, id| FileUpload.find_by_id(id).display_filename}
    sorted.each do |key, id|
      # Create a material record
      comic_page = ComicPage.create(comic: self)

      # Associate the file upload with the record
      file = FileUpload.find_by_id(id)
      if not(file)
        next
      end
      page_no += 1
      comic_page.attach(file)
      comic_page.page = page_no
      comic_page.save
    end
  end

  def can_view?(curr_user_course)
    if dependent_mission
      sbm = Submission.where(mission_id: dependent_mission, std_course_id: curr_user_course).first
      dependency = (sbm && !sbm.attempting?)
    else
      dependency = true
    end
    curr_user_course.is_staff? || visible && dependency
  end

  def tbc?(curr_user_course)
    ! next_episode(curr_user_course) || !next_episode.can_view?(curr_user_course)
  end

  def next_episode(curr_user_course)
    next_episode_helper(self, curr_user_course)
  end

  def prev_episode(curr_user_course)
    prev_episode_helper(self, curr_user_course)
  end

  private

  def next_episode_helper(comic, curr_user_course)
    candidate = Comic.where(course_id: comic.course.id).where('episode > ?', self.episode).order('episode').first
    if candidate.nil?
      nil
    elsif candidate.can_view?(curr_user_course)
      candidate
    else
      next_episode_helper(candidate, curr_user_course)
    end
  end

  def prev_episode_helper(comic, curr_user_course)
    candidate = Comic.where(course_id: comic.course.id).where('episode < ?', self.episode).order('episode desc').first
    if candidate.nil?
      nil
    elsif candidate.can_view?(curr_user_course)
      candidate
    else
      prev_episode_helper(candidate, curr_user_course)
    end
  end
end
