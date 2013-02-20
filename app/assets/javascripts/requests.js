$(document).ready(function() {

  $('.request-del').click(function(e){
    var tr = $(this).parents('tr');
    var url = tr.find('.destroy-url').val();
    $.ajax({
      url: url,
      type: 'DELETE',
      success: function(resp) {
        $(tr).remove();
      }
    });
    return false;
  });

  $('.request-approve').click(function(e){
    var tr = $(this).parents('tr');
    var url = tr.find('.destroy-url').val();
    $.ajax({
      url: url,
      type: 'DELETE',
      data: { approved: true },
      success: function(resp) {
        $(tr).remove();
      }
    });
    return false;
  });

});
