
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

var zoom_in = function (canvas) {
  var handler = function (e) {
    if (canvas.isDrawingMode) return;

    var newZoom = canvas.getZoom() + 0.1;
    canvas.zoomToPoint({ x: canvas.height/2, y: canvas.width/2 }, newZoom);
    
  };
  return handler;
};


var zoom_out = function (canvas) {
  var handler = function (e) {
    if (canvas.isDrawingMode) return;

    var newZoom = Math.max(canvas.getZoom() - 0.1, 1);
    canvas.zoomToPoint({ x: canvas.height/2, y: canvas.width/2 }, newZoom);
    
  };
  return handler;
};

// INITIALISE CANVASES  

$(document).ready(function () {
  //select all canvases and scribing images
  var allCanvases = $('.scribing-canvas');
  var allImages = $('.scribing-images');

  //init associative arrays so canvases and images can be found by qid
  var fabricCanvases = {};
  var scribingImages = {};

  //collect all img elements
  $.each(allImages, function(i, image) {
    scribingImages[$(image).data('qid')] = image;
  });

  //init and collect all canvas elements
  $.each(allCanvases, function(i, c) {
    var qid = $(c).data('qid');
    var underlayUrl = $(c).data('url');
    var c = new fabric.Canvas('scribing-canvas-' + qid); // js object 
    fabricCanvases[qid] = c;

    $('#scribing-mode-' + qid).click(toggle_mode(c));
    $('#scribing-delete-' + qid).click(delete_selection(c));
    $('#scribing-zoom-in-' + qid).click(zoom_in(c));
    $('#scribing-zoom-out-' + qid).click(zoom_out(c));
  });

  //assign each canvas its image
  $.each(scribingImages, function(qid, scribingImage) {
    //get appropriate canvas by qid
    var c = fabricCanvases[qid];

    //calculate scaleX and scaleY to fit image into canvas before creating fabric.Image object
    scaleX = c.width / scribingImage.width;
    scaleY = c.height / scribingImage.height;

    //create fabric.Image object with the right scaling and set as canvas background
    var fabricImage = new fabric.Image(scribingImage, {opacity: 1, scaleX: scaleX, scaleY: scaleY});
    //c.setHeight(fabricImage.height);
    //c.setWidth(fabricImage.width);
    c.setBackgroundImage(fabricImage, c.renderAll.bind(c));

    // load saved scribblings
    latest_scribble = $('#answers_' + qid).val();
    c.loadFromJSON(latest_scribble);
    c.renderAll();

    //add event handler to save changes in scribbles
    c.on('mouse:move', function(options) {
      $('#answers_' + qid).val(JSON.stringify(c));
    });

    c.on('click')
  });

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
