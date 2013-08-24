module Commenting
    include ApplicationHelper
    include ActionView::Helpers::DateHelper

    def as_json
        uc = self.user_course
        name =  uc.user.name
        {
                c: style_format(self.text, false),
                o: self.text,
                s: self.attributes.has_key?('line_start') ? self.line_start : -1,
                e: self.attributes.has_key?('line_end') ? self.line_end : -1,
                id: self.id,
                t: datetime_no_seconds(self.created_at),
                u: '<span class="student-link"><a href="'+uc.get_path+'">'+name+'</a></span>',
                p: uc.user.get_profile_photo_url,
                name: name,
                edit: false
        }
    end

end
