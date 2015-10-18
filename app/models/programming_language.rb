class ProgrammingLanguage < ActiveRecord::Base
  attr_accessible :name, :version, :codemirror_mode, :cmd

  def title
    "#{name} #{version}"
  end
end