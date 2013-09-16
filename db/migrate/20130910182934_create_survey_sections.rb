class CreateSurveySections < ActiveRecord::Migration
  def change
    create_table :survey_sections do |t|
      t.integer   :survey_id
      t.string    :title
      t.text      :description
      t.integer   :pos
      t.boolean   :publish, default: true

      t.time      :deleted_at
      t.timestamps
    end
  end
end
