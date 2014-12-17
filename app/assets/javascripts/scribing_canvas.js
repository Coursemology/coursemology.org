
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

var reload_bg = function (canvas, underlayUrl) {
  var handler = function () {
    console.log(canvas);
    if (underlayUrl != "") {
      fabric.Image.fromURL(underlayUrl, function(image){ 
          canvas.setBackgroundImage(image, canvas.renderAll.bind(canvas));
          canvas.setHeight(image.height * image.scaleX);
          canvas.setWidth(image.width * image.scaleY);
       }, {
         opacity: 1,
         scaleX: 1.0,
         scaleY: 1.0
       });
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
    $('#scribing-delete-' + qid).click(delete_selection(c));
    $('#scribing-reload-' + qid).click(reload_bg(c, underlayUrl));
      
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

/*

  (function() {

    if (document.location.hash !== '#zoom') return;

    function renderVieportBorders() {
      var ctx = canvas.getContext();

      ctx.save();

      ctx.fillStyle = 'rgba(0,0,0,0.1)';

      ctx.fillRect(
        canvas.viewportTransform[4],
        canvas.viewportTransform[5],
        canvas.getWidth() * canvas.getZoom(),
        canvas.getHeight() * canvas.getZoom());

      ctx.setLineDash([5, 5]);

      ctx.strokeRect(
        canvas.viewportTransform[4],
        canvas.viewportTransform[5],
        canvas.getWidth() * canvas.getZoom(),
        canvas.getHeight() * canvas.getZoom());

      ctx.restore();
    }

    $(canvas.getElement().parentNode).on('mousewheel', function(e) {

      var newZoom = canvas.getZoom() + e.deltaY / 300;
      canvas.zoomToPoint({ x: e.offsetX, y: e.offsetY }, newZoom);

      renderVieportBorders();

      return false;
    });

    var viewportLeft = 0,
        viewportTop = 0,
        mouseLeft,
        mouseTop,
        _drawSelection = canvas._drawSelection,
        isDown = false;

    canvas.on('mouse:down', function(options) {
      isDown = true;

      viewportLeft = canvas.viewportTransform[4];
      viewportTop = canvas.viewportTransform[5];

      mouseLeft = options.e.x;
      mouseTop = options.e.y;

      if (options.e.altKey) {
        _drawSelection = canvas._drawSelection;
        canvas._drawSelection = function(){ };
      }

      renderVieportBorders();
    });

    canvas.on('mouse:move', function(options) {
      if (options.e.altKey && isDown) {
        var currentMouseLeft = options.e.x;
        var currentMouseTop = options.e.y;

        var deltaLeft = currentMouseLeft - mouseLeft,
            deltaTop = currentMouseTop - mouseTop;

        canvas.viewportTransform[4] = viewportLeft + deltaLeft;
        canvas.viewportTransform[5] = viewportTop + deltaTop;

        canvas.renderAll();
        renderVieportBorders();
      }
    });

    canvas.on('mouse:up', function() {
      canvas._drawSelection = _drawSelection;
      isDown = false;
    });

  })();
*/
