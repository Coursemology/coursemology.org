// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
    $('.update-user-role').on('click',function(e) {
        e.preventDefault();
        var user_row = $(this).parents('tr');
        var role_val = user_row.find('#select-role_').val();
        var user_id = user_row.find('.user-id').val();
        var url = user_row.find('.user-role-update-path').val();
        var notice = $('.alert');

        $.ajax({
            url: url,
            type: 'PUT',
            data: {
                id: user_id,
                user: {
                    system_role_id: role_val
                }
            },
            dataType: 'json',
            success: function(){
                notice.slideDown();
                notice._removeClass('hidden');
                notice.slideDown(function(){
                    setTimeout(function(){
                        notice.slideUp()
                    },1500);
                });
            }

        });
    });

});
