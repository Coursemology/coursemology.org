module ActivityObject

  def self.included(base)
    base.class_eval do
      has_many :activities, as: :obj, dependent: :destroy
    end
  end

  def get_title
    raise NotImplementedError
  end

  def get_path
    raise NotImplementedError
  end
end
