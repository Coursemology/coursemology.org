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
    //Missions
    //badge_Missions

    //Trainings
    //badge_Trainings

    //Submissions
    //badge_Submissions

    //lesson plan
    //badge_LessonPlan

    //workbin
    //badge_Workbin

    //comics
    //badge_Comics

    //comments
    //badge_Comments

    //pending grading
    //badge_PendingGradings

    //achievements
    //badge_Achievements

    //leaderboard
    //badge_Leaderboard

    //students
    //badge_Students

    //Surveys
    //badge_Surveys

    //Forums
    //badge_Forums
});