module Assessment

  def self.included(base)
    base.class_eval do

    end
  end

  def get_title

    if self.class ==  Mission
      "#{self.title}"
    else
      "#{self.class.name} : #{self.title}"
    end
  end
end
