module Assignment
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
