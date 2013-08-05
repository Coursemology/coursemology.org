/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 19/7/13
 * Time: 7:13 PM
 * To change this template use File | Settings | File Templates.
 */
$(document).ready(function(){

    $("#assignment_update").click(function(e){
        start = date_from_string($("#open_at").val());
        end = date_from_string($("#close_at").val());

        if((typeof start != 'undefined') && (typeof end != 'undefined')) {
            if(start >= end) {
                e.preventDefault();
                alert("Close time should be after open time!");
            }
        }
    });
    function date_from_string(str) {
        if (typeof str == 'undefined')
            return null;
        date_time = str.split(' ');
        date = date_time[0];
        time = date_time[1];
        dmy = date.split('-');
        day = dmy[0];
        month = dmy[1] - 1;
        year = dmy[2];
        hms = time.split(':');
        hour = hms[0];
        min = hms[1];
        sec = hms[2];
        return new Date(year, month, day, hour, min, sec);
    }
});