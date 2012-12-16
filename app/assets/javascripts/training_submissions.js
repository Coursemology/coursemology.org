$(document).ready(function(){
  $('#submit-btn').click(function(evt){
    var form = $("#training-step-form");
    var update_url = form.children("input[name=update_url]").val();
    var qid = form.children("input[name=qid]").val();
    var checkboxes = form.find("input:radio");
    var choices = [];
    var aid = -1;

    $.each(checkboxes, function(i, cb) {
      choices.push($(cb).val());
      if ($(cb).is(":checked")) {
        aid = $(cb).val();
      }
    });

    if (aid > 0) {
      var data = {
        'qid': qid,
        'aid': aid,
        'choices': choices
      }
      // send ajax request to get result
      // update result form
      // change submit to continue if the answer is correct
      $.post(update_url, data, function(resp) {
        console.log(resp);
        $('#explanation .result').html(resp.result);
        $('#explanation .reason').html(resp.explanation);

        if (resp.is_correct) {
          $('#continue-btn').removeClass('disabled');
          $('#continue-btn').addClass('btn-primary');
          $('#submit-btn').removeClass('btn-primary');
        }
      }, 'json');
    }

    return false; // prevent default
  });

  $('#continue-btn').click(function(evt) {
    if ($(this).hasClass('disabled')) {
      evt.preventDefault();
    }
  });
});
