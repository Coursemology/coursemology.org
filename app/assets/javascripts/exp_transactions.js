// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
    $('.update-exp-transaction').on('click',function(e) {
        e.preventDefault();
        var exp_row = $(this).parents('tr');
        var $reason = exp_row.find('.exp-input-reason');
        var $exp = exp_row.find('.exp-input-mini');
        var url = exp_row.find('.et-update-path').val();

        //a hack, to validate only on current row, and not affect other elements.
        var rule_dic = {};
        rule_dic[$exp.attr('name')] = {required: true, min: 0 };
        $("#exp-transactions-form").validate({
                rules:rule_dic
            });
        if(!$exp.valid()){
            return
        }
        if($reason.length > 0 && !$reason.valid()) {
            return;
        }


        var notice = $('.alert');

        var exp_t =  {exp: $exp.val()};

        if($reason.length > 0) {
            exp_t["reason"] = $reason.val();
        }

        $.ajax({
            url: url,
            type: 'PUT',
            data: {
                exp_transaction: exp_t
            },
            dataType: 'json',
            success: function(r){
                console.log(r);
                $("#exp-sum").html(r.sum);
                notice.fadeIn();
                notice._removeClass('hidden');
                notice.fadeIn(function(){
                    setTimeout(function(){
                        notice.fadeOut()
                    },1500);
                });
            }
        });
    });
});
