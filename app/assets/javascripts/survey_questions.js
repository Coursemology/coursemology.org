$(document).ready(function() {
    $('#add-survey-option').on('click', function(e) {
        e.preventDefault();
        var num_options = $(this).parents('tbody').children().length;
        format = ['<tr>',
            '<td>'+num_options+'</td>',
            '  <td>',
            '<input type="hidden" name="options['+num_options+'][pos]" value="'+num_options+'">',
            '    <textarea id="<%= i %>" name="options['+num_options+'][description]" placeholder="Option..." class=" span6" rows="3"/></textarea>',
            '  </td>',
            '</tr>'].join('');
        $(this).parents('tr').before(format);
    });
});