/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 19/7/13
 * Time: 7:13 PM
 * To change this template use File | Settings | File Templates.
 */
$(document).ready(function(){

    $("#mission-update").click(function(e) {
        start = date_from_string($("#open_at").val());
        end = date_from_string($("#close_at").val());

        error_msg = [];
        if((typeof start != 'undefined') && (typeof end != 'undefined')) {
            if(start >= end) {
                error_msg.push('Close time should be after open time.');
            }
        }
        grade = $("#mission-max-grade");
        checked = $("#mission-format-checkbox").is(':checked');
        if (checked && (!(grade.val() - 0) || (grade.val() - 0 ) <= 0)) {
            error_msg.push('Please specify a proper grade.');
        }

        mission_exp = $("#mission-exp").val();
        if(!IsPositive(mission_exp)) {
            error_msg.push('Please specify a proper value for EXP.');
        }

        if (error_msg.length > 0) {
            $('html,body').scrollTop(0);
            e.preventDefault();
            showErrorNotice(error_msg)
        }
    });

    $("#training-update").click(function(e){
        start = date_from_string($("#open_at").val());
        bonus_cutoff = date_from_string($("#bonus-cutoff-time").val());

        error_msg = [];
        if((typeof start != 'undefined') && (typeof bonus_cutoff != 'undefined')) {
            if(start >= bonus_cutoff) {
                error_msg.push("Cutoff time should be after open time.");
            }
        }

        training_exp = $('#training-exp').val();
        if(!IsPositive(training_exp)) {
            error_msg.push('Please specify a proper value for EXP.')
        }

        bonus_exp = $('#bonus-exp').val();
        if(!IsPositive(bonus_exp) ) {
            error_msg.push('Please specify a proper value for bonus EXP.')
        }

        if (error_msg.length > 0) {
            e.preventDefault();
            $('html,body').scrollTop(0);
            showErrorNotice(error_msg)
        }

    });

    function showErrorNotice(error_msg) {
        if (error_msg.length == 0)
            return

        message = $('<ul style="margin: 0px 0px 0px 10px"></ul>');
        for (var i = 0; i < error_msg.length; ++i) {
            message.append('<li type="circle">'+error_msg[i]+'</li>')
        }

        var notice = $('.alert');
        notice.text("");
        notice._removeClass('hidden');
        notice.removeClass("alert-success");
        notice.addClass("alert-error");
        message.appendTo(notice);
        notice.slideDown();
    }
    function date_from_string(str) {
        if (typeof str == 'undefined')
            return;
        date_time = str.split(' ');
        date = date_time[0];
        time = date_time[1];
        dmy = date.split('-');
        day = dmy[0];
        month = dmy[1] - 1;
        year = dmy[2];
        hms = time.split(':');
        hour = hms[0];
        min = hms[1];
        sec = hms[2];
        return new Date(year, month, day, hour, min, sec);
    }

    // Make the table rows (the text_questions / asm-qns) sortable
    $(".sortable-table").sortable({
        update: function(event, ui){

            // create a list of asm_qns' id, based on the order in the DOM
            var asm_qns_positions = $(this).sortable('serialize');

            // send post request to the controller than can reorder asm_qns
            var asm_qns_reorder_url = $(this).attr('url');
            $.ajax({
                url: asm_qns_reorder_url,
                type: "POST",
                data: asm_qns_positions
            });

            // update question number in the view
            var question_headers = $(this).find(".asm-qn-index");
            $.each(question_headers, function(index, question_header){
                $(question_header).html(index + 1)
            });
        }
    });

});


