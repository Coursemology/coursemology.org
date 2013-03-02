// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  $('.btn-select-nav').click(function(evt) {
    evt.preventDefault();
    var target = $(this).attr('data-target');
    var selected_url = $(target).find(":selected").val();
    location = selected_url;
  });
});
