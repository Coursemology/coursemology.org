
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

    var $editField = $('#assessment_general_question_sample_answer');

    var $highlightUI = $('#keyword-ui')
    var $highlightText = $('#keyword-ui-text');
    var $popoverContent = $('#keyword-ui-popover-content');

    // The popover proxy is a dummy element positioned next to highlightText.
    // It helps us dynamically open and close popovers.
    var $popoverProxy = $('#keyword-ui-popover-proxy');

    function currentPopover() {
        return $('.popover');
    }

    // Dynamically place the entire highlight UI, so it's aligned with
    // the existing fields
    $highlightUI.insertAfter($editField);

    var $pills = $('#auto-grading-tabs li');
    $pills.on('click', function(e) {
        e.preventDefault();
        $pills.removeClass('active');

        var $pill = $(this);

        $pill.addClass('active');
        switch ($pill.attr('id')) {
        case 'auto-grading-tab-edit':
            editTab();
            break;
        case 'auto-grading-tab-keywords':
            keywordsTab();
            break;
        }
    });

    function editTab() {
        $editField.show();
        $highlightUI.hide();
    }

    function keywordsTab() {
        $editField.hide();
        $highlightUI.show();
        $highlightText.html($editField.val());
    }

    // Tracks whether or not the popover was just hidden on mousedown;
    // in that case the next mouseup should not trigger it
    var justHidden = false;

    // Keeps track of the previous selection, even after it's cleared
    var previousSelection = '';

    // Insert the content of the popover into the popover proxy.
    // This is so we don't have to write it as a string inside the
    // data-content attribute.
    $popoverProxy.attr('data-content', $popoverContent.html());

    $highlightText.mousedown(function(e){
        if (currentPopover().is(":visible")) {
            $popoverProxy.popover('destroy');
            currentPopover().remove();
            justHidden = true;
        }
    });

    $highlightText.mouseup(function(e){
        var selection = getSelectedText();
        previousSelection = selection;

        if (justHidden) {
            justHidden = false;
            return;
        }

        if (selection && !currentPopover().is(":visible")) {
            $popoverProxy.popover('show');
            $('.popover h3.popover-title').html('Add Keyword: ' + selection);
        }
    });

    $(document).on("click", ".keyword-ui-cancel", function() {
        $popoverProxy.popover('hide');
    });

    $(document).on("click", ".keyword-ui-add", function() {
        $popoverProxy.popover('hide');
        $('[data-association="auto_grading_keyword_option"]').click();

        var $keywordField = $('#auto-grading-keyword > :nth-last-child(2) input[id$="keyword"]');
        var $scoreField = $('#auto-grading-keyword > :nth-last-child(2) input[id$="score"]');

        $keywordField.val(previousSelection);
        $scoreField.val($('.popover input.numeric').val());
    });

    function getSelectedText() {
        var sel = '';
        if (window.getSelection) {
            sel = window.getSelection();
        } else if (document.getSelection) {
            sel = document.getSelection();
        } else if (document.selection) {
            sel = document.selection.createRange();
        }
        return sel.toString();
    }
});
