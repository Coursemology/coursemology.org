$(document).ready(function() {
    function load_json_data() {
        var summary = JSON.parse($('.json-data').val());

        if (summary.selected_tags) {
            var tags = summary.selected_tags;
            for (var i in tags) {
                $("input[value='" + tags[i] + "']").attr('checked', true);
            }
        }

        if (summary.actions) {
            var actions_map = summary.actions;
            var new_icon = '<img class="asm-new-icon" src="http://c.dryicons.com/images/icon_sets/colorful_stickers_part_3_icons_set/png/48x48/promotion_new.png"/>';
            var not_published_icon = '<i class="icon-ban-circle" rel="tooltip" title="Not Published"></i>';
            for (var mid in actions_map) {
                var $div = $("#"+mid);
                if ($div.length > 0 && actions_map[mid].action) {
                    var klass = "";
                    switch (actions_map[mid].action) {
                        case 'Review':
                            klass = 'btn-info';
                            break;
                        case 'Attempt':
                            klass = 'btn-success';
                            break;
                    }
                    $div.html('<a href="' + actions_map[mid].url + '" class="btn ' + klass + '" >' + actions_map[mid].action + '</a>')
                }
                var $title = $("#title-"+mid);
                if ($title.length > 0) {
                    var to_add = "";
                    if (actions_map[mid].new) to_add = new_icon;
                    if (!actions_map[mid].published) to_add += not_published_icon;
                    $title.html(to_add + $title.html());
                }


                var $title_link = $("#link-"+mid);
                if ($title_link.length > 0) {
                    if (actions_map[mid].action) {
                        $title_link.attr('href', actions_map[mid].title_link);
                    } else {
                        $title_link.parent().html($title_link.html());
                    }
                }
                var $row = $("#row-"+mid);
                if ($row.length > 0) {
                    !actions_map[mid].opened ? $row.addClass('future') : 1;
                }
            }
            $('*[rel~=tooltip]').tooltip();
        }
        console.log(summary);
    }

    if ($('.json-data').length > 0) {
        try {
            load_json_data();
        } catch (e){
            console.log(e);
        }
    }
});