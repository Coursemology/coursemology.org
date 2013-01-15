$(document).ready(function() {
  // handle add tags in form
  $('.btn-add-tag').click(function(e) {
    e.preventDefault();
    var form_row = $(this).parents('tr');
    var selected = form_row.find('select :selected');
    var tag_id = selected.val();
    var create_url = $(this).attr('href');
    $.ajax({
      url: create_url,
      type: "POST",
      data: { tag_id: tag_id },
      dataType: "html",
      success: function(resp) {
        form_row.before(resp);
        // append selected to the last element
        selected.detach();
        selected.prop('selected', false);
        form_row.find('select').append(selected);
      }
    });
  });

  $(document).on('click', '.remove-tag', function(e) {
    e.preventDefault();
    $(this).parents('tr').remove();
  });
});
