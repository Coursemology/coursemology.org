$(document).ready(function() {

    $(document).on('click', '.remove-stuff', function(e) {
        e.preventDefault();
        if(confirm('Are you sure you want to delete this staff?')) {
            var stuff_row = $(this).parents('tr');
            var url = stuff_row.find('.uc-url').attr('href');
            $.ajax({
                url: url,
                type: 'DELETE',
                success: function() {
                    stuff_row.remove();
                }
            });
        }
    });

//    $(document).on('change','.change-role',function(e){
//        e.preventDefault();
//        var stuff_row = $(this).parents('tr');
//        var btn = stuff_row.find('.update-stuff');
//        var old_val = stuff_row.find('.old-role').val();
//        var curr_val = stuff_row.find('.change-role').val();
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

    $('.update-stuff').on('click',function(e) {
        e.preventDefault();
        var stuff_row = $(this).parents('tr');
        var curr_role_val = stuff_row.find('.change-role').val();
        var name_field = stuff_row.find('.change-name');
        var old_name  = stuff_row.find('.old-name');
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
        var url = stuff_row.find('.uc-url').attr('href');
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
