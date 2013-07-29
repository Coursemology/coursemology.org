/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 23/7/13
 * Time: 2:22 PM
 * To change this template use File | Settings | File Templates.
 */


$(document).ready(function() {
    $('#mission_submit').click(function(e){
        if(!confirm("THIS ACTION IS IRREVERSIBLE\n\nAre you sure you want to submit? You will no longer be able to amend your submission!")){
            e.preventDefault();
        }
    });
});