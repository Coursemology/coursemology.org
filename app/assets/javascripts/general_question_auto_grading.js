
$(function () {
    $('input[name=assessment_general_question\\[auto_grading_type\\]]').change(function () {
        $('.auto-grading').removeClass('in');
        var autoGradingType = $(this).val();
        $('#auto-grading-' + autoGradingType).addClass('in');
    });
});
