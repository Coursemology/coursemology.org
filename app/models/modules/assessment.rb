module Assessment

  def self.included(base)
    base.class_eval do
    end
  end

  def get_title(n)
    title && !title.empty? ? title : "Question #{n}"
  end
end
