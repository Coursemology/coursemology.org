// add new mcq answer in the form
//
// button on click
//    extract information
//    append before the new form
$(document).ready(function() {
  $('#mcq-answers .add-mcq-answer').on('click', function(e) {
    e.preventDefault();
    var num_ans = $(this).parents('tbody').children().length;
    format = ['<tr>',
              '<td><input name="answers[' + num_ans + '][is_correct]" type="checkbox" /></td>',
              '  <td>',
              '    <textarea name="answers[' + num_ans + '][text]" placeholder="Answer..." /></textarea>',
              '    <textarea name="answers[' + num_ans + '][explanation]" placeholder="Explanation..." /></textarea>',
              '  </td>',
              '</tr>'].join('');
    $(this).parents('tr').before(format);
  });
});
