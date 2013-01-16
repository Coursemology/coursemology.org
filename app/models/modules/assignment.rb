module Assignment

  def self.included(base)
    base.class_eval do
      scope :closed, lambda { where("close_at < ?", Time.now) }
      scope :still_open, lambda { where("close_at >= ? ", Time.now) }
      scope :opened, lambda { where("open_at <= ? ", Time.now) }
      scope :future, lambda { where("open_at > ? ", Time.now) }

      # mission can have other assigments as requirement
      has_many :requirements, as: :obj, dependent: :destroy
      has_many :asm_reqs, through: :requirements, source: :req, source_type: "AsmReq"

      has_many :as_asm_reqs, class_name: "AsmReq", as: :asm, dependent: :destroy
      has_many :as_requirements, through: :as_asm_reqs, source: :requirements

      has_many :asm_tags, as: :asm
      has_many :tags, through: :asm_tags

      after_save :after_save_asm
    end
  end

  def get_title
    return "#{self.class.name}: #{self.title}"
  end

  def get_final_sbm_by_std(std_course_id)
    return self.sbms.find_by_std_course_id(std_course_id)
  end

  def get_qn_pos(qn)
    self.asm_qns.each do |asm_qn|
      if asm_qn.qn == qn
        return asm_qn.pos + 1
      end
    end
    return -1
  end

  def add_tags(tags)
    tags ||= []
    tags.each do |tag_id|
      self.asm_tags.build(
        tag_id: tag_id,
        max_exp: exp
      )
    end
    self.save
  end

  def retain_asm_tags(asm_tags)
    asm_tags ||= []
    asm_tags = asm_tags.collect { |id| id.to_i }
    current_asm_tags = self.asm_tags.collect { |asm_tag| asm_tag.id }
    removed_ids = current_asm_tags - asm_tags
    AsmTag.delete(removed_ids)
  end

  def update_tags(remaining_asm_tags, new_tags)
    self.retain_asm_tags(remaining_asm_tags)
    self.add_tags(new_tags)
  end

  def after_save_asm
    self.tags.each { |tag| tag.update_max_exp }
  end
end
