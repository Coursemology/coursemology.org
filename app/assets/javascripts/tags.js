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
    $("[type='tag']").each(function(){
        $a = $(this);
        var url = $a.attr("url");
        var existing = [];
        var result = [];
        var allowFreeTagging = true;
        if ($a.attr("allowFreeTagging") == "false") {
            allowFreeTagging = false;
        }

        if($a.attr("value") != "")
            existing = JSON.parse($a.attr("value"));
        if(url != "") {
            $.ajax({
                type: 'GET',
                url: url,
                dataType: 'json',
                success: function(s){
                    console.log(s);
                    result = s;
                },
                async: false
            });
        }
        $a.tokenInput(result,
            {
                prePopulate: existing,
                tokenValue: "name",
                theme: "facebook",
                searchDelay: 0,
                allowFreeTagging: allowFreeTagging,
                preventDuplicates: true,
                hintText: "Type in a tag"});

    });
});
