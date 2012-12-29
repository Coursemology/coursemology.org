module Assignment

  def self.included(base)
    base.class_eval do
      scope :closed, lambda { where("close_at < ?", Time.now) }
      scope :still_open, lambda { where("close_at >= ? ", Time.now) }
      scope :opened, lambda { where("open_at <= ? ", Time.now) }
      scope :future, lambda { where("open_at > ? ", Time.now) }

      # mission can have other assigments as requirement
      has_many :requirements, as: :obj
      has_many :asm_reqs, through: :requirements, source: :req, source_type: "AsmReq"

      has_many :as_asm_reqs, class_name: "AsmReq", as: :asm
      has_many :as_requirements, through: :as_asm_reqs, source: :requirements
    end
  end

  def get_title
    return "#{self.class.name}: #{self.title}"
  end

  def get_last_submission
    return self.sbms.order('created_at').last
  end

  def get_qn_pos(qn)
    puts '++', self.asm_qns.to_json
    self.asm_qns.each do |asm_qn|
      puts ' >>> ', asm_qn.to_json, qn.to_json
      if asm_qn.qn == qn
        return asm_qn.pos + 1
      end
    end
    return -1
  end
end
