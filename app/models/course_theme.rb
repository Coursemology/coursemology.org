class CourseTheme < ActiveRecord::Base
  require 'fileutils'
  COURSE_THEME_BASE_URL = '/course_themes/'
  COURSE_THEME_ROOT_PATH = 'public'

  attr_accessible :course_id, :theme_folder_url, :theme_id

  belongs_to :course

  def get_folder_url
    if !self.theme_folder_url
      self.theme_folder_url = "#{COURSE_THEME_BASE_URL}#{course.id}"
      theme_path = "#{COURSE_THEME_ROOT_PATH}#{self.theme_folder_url}"
      FileUtils.mkdir_p(File.dirname(theme_path))
    end
    self.save
    theme_path = "#{COURSE_THEME_ROOT_PATH}#{self.theme_folder_url}"
    return theme_path
  end
end
