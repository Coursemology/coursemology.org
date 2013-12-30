class AddTestLeftToStdCodingAnswer < ActiveRecord::Migration
  def change
    add_column :std_coding_answers, :test_left, :integer
  end
end
