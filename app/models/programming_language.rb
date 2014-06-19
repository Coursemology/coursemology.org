class ProgrammingLanguage < ActiveRecord::Base
  attr_accessible :language, :version

  def name
    "#{language} #{version}"
  end
end