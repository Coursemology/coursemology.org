
$(function () {
    $('input[name=assessment_general_question\\[auto_grading_type\\]]:radio').change(function () {
        $('.auto-grading').removeClass('in');
        var index = $(this).val();
        $('#auto-grading-' + index).addClass('in');
    });
});
