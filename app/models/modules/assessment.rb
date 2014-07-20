module Assessment

  def self.included(base)
    base.class_eval do
      before_update :clean_up_description, :if => :description_changed?
    end
  end

  def get_title(n)
    title && !title.empty? ? title : "Question #{n}"
  end

  #clean up messed html tags
  def clean_up_description
    self.description = description.
        gsub(/\[mc\](.+?)\[\/mc\]/m){"[mc]" << $1.gsub(/<div><\/div>/,'') << "[/mc]"}.
        gsub(/<div>(.+?)<\/div>/m) { "<br>" + $1 + "<br>"}.gsub(/<br>\s*\<br>/m, "<br><br>")
  end
end
