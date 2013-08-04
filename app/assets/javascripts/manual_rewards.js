// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
  $('.repeat-exp-link').click(function(evt) {
    evt.preventDefault();
    var exp = $(this).parent().children('input').val();
    $('.exp-input').val(exp);
  });

  $('.select-all-achs').click(function(evt) {
    evt.preventDefault();
    $('table.manual-awards-achievements input[type="checkbox"]').prop('checked', true);
  });

  $('.deselect-all-achs').click(function(evt) {
    evt.preventDefault();
    $('table.manual-awards-achievements input[type="checkbox"]').prop('checked', false);
  });

  $('.select-all-stds').click(function(evt) {
    evt.preventDefault();
    $('table.manual-awards-students input[type="checkbox"]').prop('checked', true);
  });

  $('.deselect-all-stds').click(function(evt) {
    evt.preventDefault();
    $('table.manual-awards-students input[type="checkbox"]').prop('checked', false);
  });

});
