class DateValidator < ActiveModel::Validator
  def validate(record)
    if record.open_at > record.close_at
      record.errors[:base] << "End time should be after start time."
    end
  end
end