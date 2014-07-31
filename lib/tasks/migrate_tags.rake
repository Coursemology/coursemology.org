namespace :db do

  task migrate_tags: :environment do
    def prepare_values_for_db(a)
      a.map{|x| x.is_a?(Time) ? x.strftime("%Y-%m-%d %H:%M:%S") : x }.map(&:inspect).map{|x| x == "nil" ? 'NULL' : x }
    end

    def m_tags
      result = ActiveRecord::Base.connection.exec_query("Select * from old_tags")
      result.each do |r|
        r.delete("max_exp")
        r.delete("icon_url")
        sql = "INSERT INTO tags (#{r.keys.join(",")}) VALUES (#{prepare_values_for_db(r.values).join(",")})"
        ActiveRecord::Base.connection.insert(sql)
      end
    end

    def taggable
      result = ActiveRecord::Base.connection.exec_query("Select * from taggable_tags")
      result.each do |r|
        r.delete("id")
        r.delete("deleted_at")
        r.delete("updated_at")
        r["context"] = "tags"
        sql = "INSERT INTO taggings (#{r.keys.join(",")}) VALUES (#{prepare_values_for_db(r.values).join(",")})"
        ActiveRecord::Base.connection.insert(sql)
      end
    end

    m_tags
    taggable
  end
end