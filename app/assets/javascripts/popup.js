$(document).ready(function() {
  $('#popups .modal').modal('show');
  $('#popups .popup-btn-close').click(function() {
    console.log(this)
    $(this).parents('.modal').modal('hide');
  })
});
