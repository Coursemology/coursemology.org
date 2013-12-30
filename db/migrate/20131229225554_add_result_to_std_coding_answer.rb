class AddResultToStdCodingAnswer < ActiveRecord::Migration
  def change
    add_column :std_coding_answers, :result, :text
  end
end
