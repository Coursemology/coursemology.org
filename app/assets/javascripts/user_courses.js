$(document).ready(function() {

    $(document).on('click', '.remove-staff', function(e) {
        e.preventDefault();
        if(confirm('Are you sure you want to delete this staff?')) {
            var staff_row = $(this).parents('tr');
            var url = staff_row.find('.uc-url').attr('href');
            $.ajax({
                url: url,
                type: 'DELETE',
                success: function() {
                    staff_row.remove();
                }
            });
        }
    });

//    $(document).on('change','.change-role',function(e){
//        e.preventDefault();
//        var staff_row = $(this).parents('tr');
//        var btn = staff_row.find('.update-staff');
//        var old_val = staff_row.find('.old-role').val();
//        var curr_val = staff_row.find('.change-role').val();
//
//        if(old_val != curr_val)
//        {
//            if(btn.hasClass("disabled")){
//                btn._removeClass('disabled');
//                btn._addClass("btn-success");
//            }
//        } else {
//            btn._addClass('disabled');
//            btn._removeClass('btn-success');
//        }
//    });
//
//    $('.change-name').keyup(function(){
//        if(btn.hasClass("disabled")){
//            btn._removeClass('disabled');
//            btn._addClass("btn-success");
//        }
//    });

    $('.update-staff').on('click',function(e) {
        e.preventDefault();
        var staff_row = $(this).parents('tr');
        var curr_role_val = staff_row.find('.change-role').val();
        var name_field = staff_row.find('.change-name');
        var old_name  = staff_row.find('.old-name');
        var notice = $('.alert');
        if(notice.size() > 1) {
            notice[0].parentNode.removeChild(notice[0]);
        }
        if(name_field.val().length == 0) {
            notice.slideDown();
            notice._removeClass('hidden');
            notice.removeClass("alert-success");
            notice.addClass("alert-error");
            notice.text("User name can't be empty!");
            notice.slideDown(function(){
                setTimeout(function(){
                    notice.slideUp()
                },1500);
            });
            name_field.val(old_name.val());
            return;
        }
        old_name.val(name_field.val());
        var url = staff_row.find('.uc-url').attr('href');
        notice.addClass("alert-success");
        notice.removeClass("alert-error");
        notice.text("Update user info successful!");
        notice.slideDown();
        notice._removeClass('hidden');
//        console.log(notice);
        $.ajax({
            url: url,
            type: 'PUT',
            data: { role_id: curr_role_val,
                name:name_field.val()},
            dataType: 'html',
            success: function() {
                notice.slideDown(function(){
                    setTimeout(function(){
                        notice.slideUp()
                    },1500);
                });
            }
        });
    });
});
