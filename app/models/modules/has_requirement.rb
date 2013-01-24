module HasRequirement

  def self.included(base)
    base.class_eval do
      has_many :requirements, as: :obj, dependent: :destroy
    end
  end

  # it is an interface but ruby does not seems to have the 
  # concept of interface
  def get_req_short_desc
    raise NotImplementedError
  end
end
