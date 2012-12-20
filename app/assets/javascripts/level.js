$(document).ready(function() {
  var tbody = $('table.exp-table tbody');
  var last_lvl = tbody.find('tr:last-child');
  last_lvl.find('.remove-lvl').removeClass('hidden');

  // remove level
  $(document).on('click', '.remove-lvl', function(e) {
    e.preventDefault();
    // grab the last level and delete, on return show the delete of
    // the prev level
    var lvl_row = $(this).parents('tr');
    var url = lvl_row.find('.lvl-url').attr('href');
    $.ajax({
      url: url,
      type: 'DELETE',
      success: function(resp) {
        lvl_row.remove();
        last_lvl = $('table.exp-table tbody tr:last-child');
        last_lvl.find('.remove-lvl').removeClass('hidden');
      }
    });
  });

  // create level
  $('.add-lvl').on('click', function(e) {
    e.preventDefault();
    var exp = $(this).parent().find('.new-lvl-exp').val();
    var url = $(this).attr('href');
    console.log(exp, url);
    $.ajax({
      url: url,
      type: 'POST',
      data: { exp: exp },
      dataType: 'html',
      success: function(resp) {
        last_lvl.find('.remove-lvl').addClass('hidden');
        last_lvl = $(resp);
        last_lvl.find('.remove-lvl').removeClass('hidden');
        tbody.append(last_lvl);
      }
    });
  });

  // edit level
  $(document).on('click', '.edit-lvl', function(e) {
    e.preventDefault();
    var lvl_row = $(this).parents('tr');
    var url = lvl_row.find('.lvl-url').attr('href');
    var text = lvl_row.find('.lvl-threshold');
    var input = lvl_row.find('.lvl-threshold-input');
    var ok_btn = lvl_row.find('.edit-lvl-done');
    var edit_btn = $(this);
    text.addClass('hidden');
    input.removeClass('hidden');
    edit_btn.addClass('hidden');
    ok_btn.removeClass('hidden');
    $(ok_btn).one('click', function() {
      var new_exp = input.val();
      console.log(new_exp);
      $.ajax({
        url: url,
        type: 'PUT',
        data: { exp: new_exp },
        success: function(resp) {
          text.html(new_exp);
          text.removeClass('hidden');
          input.addClass('hidden');
          ok_btn.addClass('hidden');
          edit_btn.removeClass('hidden');
        }
      });
    });
  });
});
