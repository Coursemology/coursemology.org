$(document).ready(function() {
    //announcement
    //badge_Announcements

    var navbar = $("#navbar_tabs");

    if (navbar.length > 0 ) {
        var url = navbar.attr('url');
        $.get(url, function(objs){
            for (var key in objs) {
                if (objs[key] > 0) {
                    var tab = $("#badge_"+key);
                    if(tab.length > 0) {
                        tab.html(objs[key]);
                        tab.fadeIn('slow');
                    }
                }
            }
        });
    }
});