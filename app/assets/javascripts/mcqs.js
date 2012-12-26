// add new mcq answer in the form
//
// button on click
//    extract information
//    append before the new form
$(document).ready(function() {
  $('#mcq-answers .add-mcq-answer').on('click', function(e) {
    e.preventDefault();
    var form = $(this).parents('.answer-row');
    var cb = form.find('input[type=checkbox]');
    var tb = form.find('input.ans-text');
    var eb = form.find('input.ans-expl');
    // get value
    var create_url = $(this).attr('href');
    var is_correct = cb.is(':checked');
    var text = tb.attr('value');
    var expl = eb.attr('value');
    // reset
    cb.attr('checked', false);
    tb.attr('value', '');
    eb.attr('value', '');
    // construct the new row
    if (text) {
      data = {
        mcq_answer: {
          is_correct: is_correct,
          text: text,
          explanation: expl
        }
      };
      $.ajax({
        url: create_url,
        type: "POST",
        data: data,
        dataType: "html",
        success: function(resp) {
          form.before(resp);
        }
      });
    }
    return false;
  });

  $(document).on('click', '#mcq-answers .btn-remove', function(e) {
    e.preventDefault();
    var del_url = $(this).attr('href');
    var el = this;
    $.ajax({
      url: del_url,
      type: "DELETE",
      success: function() {
        $(el).parents('tr').remove();
      }
    });
  });
});
