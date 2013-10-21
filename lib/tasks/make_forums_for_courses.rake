namespace :db do
  desc 'Make forums for all existing courses'

  task make_forums: :environment do
    Course.all.each do |cs|
      puts 'Adding forums for ' + cs.title
      begin
        cat = Forem::Category.find(cs.id)
      rescue ActiveRecord::RecordNotFound
        cat = Forem::Category.create(:id => cs.id, :name => cs.title)
        Forem::Forum.create(:category_id => cat.id,
                            :name => 'General Discussion',
                            :description => 'For general discussion')
        Forem::Forum.create(:category_id => cat.id,
                            :name => 'Help',
                            :description => 'Ask your questions here')
      end
    end
  end
end