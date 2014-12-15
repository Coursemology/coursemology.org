
// BUTTON EVENT HANDLERS

var toggle_mode = function (canvas) {
  var handler = function () {
    if (canvas.isDrawingMode) {
      canvas.isDrawingMode = false;
      $(this).removeClass("active");
    } else {
      canvas.isDrawingMode = true;
      $(this).addClass("active");
      //$(".buttons a").not(this).removeClass("active");
    }
  };
  return handler;
};

// http://stackoverflow.com/questions/11829786/delete-multiple-objects-at-once-on-a-fabric-js-canvas-in-html5
var delete_selection = function (canvas) {
  var handler = function () {
    if(canvas.getActiveGroup()) {
        canvas.getActiveGroup().forEachObject(function(o){ canvas.remove(o) });
        canvas.discardActiveGroup().renderAll();
      } else {
        canvas.remove(canvas.getActiveObject());
      }
    };
  return handler;
};

// INITIALISE CANVASES  

$(document).ready(function () {
  var allCanvases = $('.scribing-canvas');
  var numCanvases = allCanvases.length;
  for (var i = 0; i < numCanvases; i++) {
    var this_canvas = $(allCanvases[i]); // html node
    var underlayUrl = this_canvas.data('url');
    var qid = this_canvas.data('qid');
    var c = new fabric.Canvas('scribing-canvas-' + qid); // js object 

    $('#scribing-mode-' + qid).click(toggle_mode(c));
    $('#scribing-delete-'  + qid).click(delete_selection(c));
      
    if (underlayUrl != "") {
      fabric.Image.fromURL(underlayUrl, function(image){ 
          c.setBackgroundImage(image, c.renderAll.bind(c));
          c.setHeight(image.height * image.scaleX);
          c.setWidth(image.width * image.scaleY);
       }, {
         opacity: 1,
         scaleX: 1.0,
         scaleY: 1.0
       });
    }

    latest_scribble = $('#answers_' + qid).val();
    c.loadFromJSON(latest_scribble);
    c.renderAll();

    c.on('mouse:move', function(options) {
      $('#answers_' + qid).val(JSON.stringify(c));
    });
  }
});