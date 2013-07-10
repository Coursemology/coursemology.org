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

    $(document).on('change','.change-role',function(e){
        e.preventDefault();
        var stuff_row = $(this).parents('tr');
        var btn = stuff_row.find('.update-stuff');
        var old_val = stuff_row.find('.old-role').val();
        var curr_val = stuff_row.find('.change-role').val();

        if(old_val != curr_val)
        {
            if(btn.hasClass("disabled")){
                btn._removeClass('disabled');
                btn._addClass("btn-success");
            }
        } else {
            btn._addClass('disabled');
            btn._removeClass('btn-success');
        }
    });

    $('.update-stuff').on('click',function(e) {
        e.preventDefault();
        var stuff_row = $(this).parents('tr');
        var curr_val = stuff_row.find('.change-role').val();
        stuff_row.find('.old-role').val(curr_val);
        var url = stuff_row.find('.uc-url').attr('href');
        var btn = stuff_row.find('.update-stuff');
        var notice = $('.alert');
        if(notice.size() > 1) {
            notice[0].parentNode.removeChild(notice[0]);
        }
        notice.text("Update role successful!");
        notice.slideDown();
        notice._removeClass('hidden');
//        console.log(notice);
        $.ajax({
            url: url,
            type: 'PUT',
            data: { role_id: curr_val },
            dataType: 'html',
            success: function() {
                btn._addClass('disabled');
                btn._removeClass('btn-success');
                notice.slideDown(function(){
                    setTimeout(function(){
                        notice.slideUp()
                    },1500);
                });
            }
        });
    });
});
