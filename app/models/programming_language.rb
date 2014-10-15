class ProgrammingLanguage < ActiveRecord::Base
  # attr_accessible :name, :version, :codemirror_mode

  def title
    "#{name} #{version}"
  end
end