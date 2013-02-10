// add new mcq answer in the form
//
// button on click
//    extract information
//    append before the new form
$(document).ready(function() {
  $('#mcq-answers .add-mcq-answer').on('click', function(e) {
    e.preventDefault();
    format = ['<tr>',
              '<td><input type="checkbox" /></td>',
              '  <td>',
              '    <textarea name="answers[]" placeholder="Answer..." /></textarea>',
              '    <textarea name="answers[][explanation]" placeholder="Explanation..." /></textarea>',
              '  </td>',
              '</tr>'].join('');
    $(this).parents('tr').before(format);
  });
});
