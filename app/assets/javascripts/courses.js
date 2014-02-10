$(document).ready(function(){
    $('#delete-course-btn').click(function(evt) {
        evt.preventDefault();

        var should_delete = confirm("Are you sure you want to delete this Course? You will not be able to recover its data!");

        if (should_delete) {
            $('#delete-course-link').click();
        }
    });

    $('.pending-actions .ignore').click(function(e){
        e.preventDefault();
        var row = $(this).parents('tr');
        var row_left = $(this).parents('tbody').children().length - 1;
        if (row_left == 0 ) {
            row = row.parents('div.pending-actions-block');
        }
        var url = $(this).attr('url');

        $.get(url, function(resp){
            row.animate(
                {height: '0px',
                    opacity: 0,
                    width: '0px'}, 500,
                function(){
                    row.remove();
                });
        })
    });
});
