// add new mcq answer in the form
//
// button on click
//    extract information
//    append before the new form
$(document).ready(function() {
  var row_template = [
          '<tr class="answer-row">',
          '  <input type="hidden" name="answers[][text]" value="<%= answer.text %>">',
          '  <td><input type="checkbox" name="answers[][is_correct]" value="true" /></td>',
          '  <td class="ans-text"></td>',
          '  <td>',
          '    <button class="btn btn-edit"><i class="icon-edit"></i></button>',
          '    <button class="btn btn-remove"><i class="icon-minus"></i></button>',
          '  </td>',
          '</tr>'].join('\n');

  $('#mcq-answers .btn-add').on('click', function(evt) {
    var form = $(this).parents('.answer-row');
    var cb = form.find('input[type=checkbox]');
    var tb = form.find('input[type=text]');
    // get value
    var is_correct = cb.is(':checked');
    var text = tb.attr('value');
    // reset
    cb.attr('checked', false);
    tb.attr('value', '');
    // construct the new row
    if (text) {
      var row = $(row_template);
      row.find('input[name="answers[][text]"]').attr('value', text);
      row.find('input[name="answers[][is_correct]"]').attr('checked', is_correct);
      row.find('.ans-text').html(text);
      row.insertBefore(form);
    }
    return false;
  });

  $(document).on('click', '#mcq-answers .btn-remove', function(evt) {
    $(this).parents('.answer-row').remove();
    return false;
  });
});
