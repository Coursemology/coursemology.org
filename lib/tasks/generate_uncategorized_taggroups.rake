namespace :db do

  task generate_uncategorized_taggroups: :environment do
    Course.all.each do |c|
      tg = c.tag_groups.create({name: "Uncategorized"})
      c.tags.where(tag_group_id: 0).each do |t|
        t.tag_group = tg
        t.save
      end
    end
  end
end