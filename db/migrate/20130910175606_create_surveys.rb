class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer   :course_id
      t.integer   :creator_id
      t.string    :title
      t.text      :description
      t.datetime  :open_at
      t.datetime  :expire_at
      t.boolean   :anonymous    , default: false
      t.boolean   :publish      , default: true
      t.boolean   :allow_modify , default: true
      t.boolean   :has_section  , default: true


      t.time     :deleted_at

      t.timestamps
    end
  end
end
