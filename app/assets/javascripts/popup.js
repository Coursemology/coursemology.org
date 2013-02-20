$(document).ready(function() {
  $('#popups .modal').modal('show');
  $('#popups .popup-btn-close').click(function() {
    $(this).parents('.modal').modal('hide');
  })
});
