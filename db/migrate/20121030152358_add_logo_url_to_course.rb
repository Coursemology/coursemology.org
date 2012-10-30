class AddLogoUrlToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :logo_url, :string
    add_column :courses, :banner_url, :string
  end
end
