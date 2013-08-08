class ChangeDateFormatInStdCodingAnswer < ActiveRecord::Migration
  def up
    change_column :std_coding_answers, :last_commented_at, :datetime
  end

  def down
    change_column :std_coding_answers, :last_commented_at, :time
  end
end
