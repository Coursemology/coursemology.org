/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 25/9/13
 * Time: 5:30 PM
 * To change this template use File | Settings | File Templates.
 */


$(document).ready(function() {
    function dump_code(type){
        $(".dump_sub").attr('disabled', 'disabled');
        params = "";
        switch(type){
            case 'mine':
                params = "?_type=mine";
                break;
            case 'phantom':
                params = "?_type=phantom";
                break;
        }
        downloadURL($("#dump_url").val() + params, "Code");
//        $.ajax({
//            url: $("#dump_url").val() + params,
//            type: 'GET',
//            dataType: 'json',
//            success: function(resp){
//                $(".dump_sub").removeAttr('disabled');
//                $(".dump_sub").val("Download Submissions");
//                downloadURL(resp["file_url"], resp["file_name"]);
//            }
//        });

    }
    $("#dump_sub_mine").click(function(){
        dump_code('mine');
        $("#dump_sub_mine").val("Processing...");
    });

    $("#dump_sub_all").click(function(){
        dump_code('all');
        $("#dump_sub_all").val("Processing...");
    });

    $("#dump_sub_phantom").click(function(){
        dump_code('phantom');
        $("#dump_sub_phantom").val("Processing...");
    });

    var downloadURL = function downloadURL(url, name) {
        var hiddenIFrameID = 'hiddenDownloader',
            iframe = document.getElementById(hiddenIFrameID);
        if (iframe === null) {
            iframe = document.createElement('a');
            iframe.id = hiddenIFrameID;
            iframe.style.display = 'none';
            iframe.download = name;
            document.body.appendChild(iframe);
        }
        iframe.href = url;
        iframe.click();
    };

});
