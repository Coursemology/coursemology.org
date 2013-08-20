$(document).ready(function() {
  $('.lvl-add-more').click(function(evt) {
    evt.preventDefault();

    var num_lvl = $(this).parents('tbody').children().length;
    format = ['<tr>',
              '  <td>' + num_lvl + '</td>',
              '  <td><input type="number" maxlength="15" name="exps[]"></td>',
              '</tr>'].join('');
    $(this).parents('tr').before(format);

  });
});
