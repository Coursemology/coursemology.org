$(document).ready(function(){ 
  $('#delete-course-btn').click(function(evt) {
    evt.preventDefault();

    var should_delete = confirm("Are you sure you want to delete this Course? You will not be able to recover its data!");

    if (should_delete) {
      $('#delete-course-link').click();
    }
  });
});
