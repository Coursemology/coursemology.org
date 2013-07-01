// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
  $('.repeat-exp-link').click(function(evt) {
    evt.preventDefault();
    var exp = $(this).parent().children('input').val();
    $('.exp-input').val(exp);
  });
});
