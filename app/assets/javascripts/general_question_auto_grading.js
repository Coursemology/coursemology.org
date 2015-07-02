
function setAutoGradingKeywordMaxScore() {
    var maxValue = $('#assessment_general_question_max_grade').val();
    $('input[id^=assessment_general_question_auto_grading_keyword_options_attributes][id$=score]')
        .attr({ 'max' : maxValue });
}

$(function () {
    $('input[name=assessment_general_question\\[auto_grading_type\\]]').change(function () {
        $('.auto-grading').removeClass('in');
        var autoGradingType = $(this).val();
        $('#auto-grading-' + autoGradingType).addClass('in');
    });

    $('#assessment_general_question_max_grade')
        .change(setAutoGradingKeywordMaxScore);
});
