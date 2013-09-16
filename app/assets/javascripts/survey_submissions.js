$(document).ready(function() {
    $(".checked").change(function(){
        console.log("here");
        var vote = $(".vote-count");
        if($(this).attr("checked")) {
            $(this).parent().parent().addClass("rune-voted");
            vote.text((vote.text() - 0) + 1);
        } else {
            $(this).parent().parent().removeClass("rune-voted");
            vote.text((vote.text() - 0) - 1);
        }
    });

    $(".survey-submit").click(function(evt){
        var max = $("#max-allowed").val() - 0;
        var selected = $(".vote-count").text() - 0;

        if (selected > max) {
            alert("Exceeded max voting entries!")
            evt.preventDefault();
        }
        if (selected < max) {
            if(!confirm("You voted less than allowed entries, are you sure?")) {
                evt.preventDefault();
            }
        }
    });
});