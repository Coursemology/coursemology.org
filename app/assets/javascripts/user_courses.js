$(document).ready(function() {

    $(document).on('click', '.remove-staff', function(e) {
        e.preventDefault();
        var staff_row = $(this).parents('tr');
//        var url = staff_row.find('.uc-url').attr('href');
        var value = staff_row.find('.user-course-id').val();
        var url = staff_row.find('.remove-staff-url').val();
        console.log(value);
        console.log(url);
        $.ajax({
            url: url,
            type: 'POST',
            success: function() {
                staff_row.animate({'line-height':0}, 100).hide(1000);
            }
        });
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

    function showAlertNotice(str) {
        var notice = $('.alert');
        notice.slideDown();
        notice._removeClass('hidden');
        notice.removeClass("alert-success");
        notice.addClass("alert-error");
        notice.text(str);
        notice.slideDown(function(){
            setTimeout(function(){
                notice.slideUp()
            },1500);
        });

    }
    $('.update-staff').on('click',function(e) {
        e.preventDefault();
        var staff_row = $(this).parents('tr');
        var curr_role_val = staff_row.find('.change-role').val();
        var name_field = staff_row.find('.change-name');
        var email_field = staff_row.find('.change-email');
        var phantom = staff_row.find('.change-phantom');
        var old_name  = staff_row.find('.old-name');
        var notice = $('.alert');
        var name = name_field.val().trim();
        var email = email_field.val().trim();
        if(notice.size() > 1) {
            notice[0].parentNode.removeChild(notice[0]);
        }
        if(name.length == 0) {
            showAlertNotice("User name can't be empty!");
            name_field.val(old_name.val());
            return;
        }
        if((typeof email_field != 'undefined') && !email_field[0].validity.valid) {
            showAlertNotice("Please input valid email address!");
            return
        }
        old_name.val(name);
        name_field.val(name);
        email_field.val(email);
        var url = staff_row.find('.uc-url').attr('href');
        notice.addClass("alert-success");
        notice.removeClass("alert-error");
        notice.text("Update user info successful!");
//        console.log(notice);
        $.ajax({
            url: url,
            type: 'PUT',
            data: {
                role_id: curr_role_val,
                is_phantom: phantom[0].checked,
                name: name,
                email: email },
            dataType: 'json',
            success: function(e) {
//                json = JSON.parse(e);
                if (e.status != 'OK') {
                    notice.addClass("alert-error");
                    notice.text("Email entered is already taken!");
                    notice.slideDown();
                    notice._removeClass('hidden');
                    notice.slideDown(function(){
                        setTimeout(function(){
                            notice.slideUp()
                        },4400);
                    });
                } else {
                    notice.slideDown();
                    notice._removeClass('hidden');
                    notice.slideDown(function(){
                        setTimeout(function(){
                            notice.slideUp()
                        },1500);
                    });
                }
            }
        });
    });
});
