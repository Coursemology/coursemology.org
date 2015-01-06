// TODO
// - Add limit to panning


// HELPER FUNCITONS

function getJSON(qid, canvas) {
  // remove all locked layers
  var layersList = $('#scribing-layers-' + qid);
  layersList.find('option').each(function (i, o) {
    $(o).data('toggleLayer')(false);
  });

  // get json output for current user
  var output = JSON.stringify(canvas._objects);

  // restore locked layers and return
  layersList.change();
  return '{"objects":'+ output +'}';
}

function updateScribble(qid, canvas) {
  var ajaxField = $('#scribing-ajax-' + qid + ' .scribble-content');
  ajaxField.val(getJSON(qid, canvas));
  $('#scribing-ajax-' + qid).submit();
}

function loadScribbles(c, qid) {
  var layersList = $('#scribing-layers-' + qid);
  layersList.selectpicker('hide'); // remains hidden if there are no layers

  // load answer scribbling
  var answerScribble = $('#answers_' + qid);
  loadScribble(c, answerScribble, layersList);

  //load other scribblings
  $('.scribble-' + qid).each(function (i, scribble) {
    loadScribble(c, $(scribble), layersList);
  });
}

//load a single scribble
function loadScribble(c, scribble, layersList) {
  if (scribble.val() === '') {
    return;
  }

  // Convert javascript objects to fabricjs objects
  var objects = JSON.parse(scribble.val()).objects;
  var fabricObjs = [];

  // Declare this helper function here so it can access fabricObjs
  // and remain outside the loop where it is used.
  // Keeping function declarations outside loops helps with performance
  // and stops HoundCI from complaining
  function pushFabricObjs(img) {
    fabricObjs.push(img);
  }

  for (var i = 0; i < objects.length; i++) {
    var klass = fabric.util.getKlass(objects[i].type);
    if (klass.async) {
      klass.fromObject(objects[i], pushFabricObjs);
    } else {
      var item = klass.fromObject(objects[i]);
      fabricObjs.push(item);
    }
  }

  // Case when scribble should be read-only
  if (scribble.data('locked') && fabricObjs.length > 0) {
    var scribbleGroup = new fabric.Group(fabricObjs);
    c.add(scribbleGroup);
    scribbleGroup.selectable = false;

    // Populate drop-down box
    var newLayerEntry = $('<option>')
      .text(scribble.data('scribe'))
      .attr('selected','selected');
    layersList.append(newLayerEntry);

    var toggleLayer = function (showLayer) {
      var thisGroup = scribbleGroup;
      if (showLayer && !c.contains(thisGroup)) {
        c.add(thisGroup);
      } else if (!showLayer && c.contains(thisGroup)) {
        c.remove(thisGroup);
      }
      c.renderAll();
    };
    newLayerEntry.data({toggleLayer: toggleLayer});

    layersList.selectpicker('show');
    layersList.selectpicker('refresh');

  } else if (!scribble.data('locked')) {

    // Case when scribble is to be editable
    fabricObjs.map( function(o){ c.add(o); } );
  }
}

// INITIALISE CANVASES

$(document).ready(function () {
  //select all canvases and scribing images
  var allCanvases = $('.scribing-canvas');

  //init associative arrays so canvases can be found by qid
  var fabricCanvases = {};

  //init and collect all canvas elements
  $.each(allCanvases, function(i, htmlCanvas) {
    var qid = $(htmlCanvas).data('qid');
    var buttons = $('#scribing-buttons-' + qid + ' a');
    var c = new fabric.Canvas('scribing-canvas-' + qid); // js object
    c.clear();
    fabricCanvases[qid] = c;

    //set brush width to value declared in scribing canvas view
    c.freeDrawingBrush.width = $('#scribing-width-' + qid).val();

    $('#scribing-mode-' + qid)
      .click({ canvas: c, buttons: buttons }, function (event) {
        var canvas = event.data.canvas;
        var buttons = event.data.buttons;

        canvas.isDrawingMode = true;
        canvas.isGrabMode = false;
        $(this).addClass('active');
        buttons.not(this).removeClass('active');
        $('#scribing-edit-tools-' + qid).addClass('hidden');
        $('#scribing-drawing-tools-' + qid).removeClass('hidden');
      });

    $('#edit-mode-' + qid)
      .click({ canvas: c, buttons: buttons }, function (event) {
        var canvas = event.data.canvas;
        var buttons = event.data.buttons;

        canvas.isDrawingMode = false;
        canvas.isGrabMode = false;
        canvas.selection = false;
        $(this).addClass('active');
        buttons.not(this).removeClass('active');
        $('#scribing-edit-tools-' + qid).removeClass('hidden');
        $('#scribing-drawing-tools-' + qid).addClass('hidden');
      });

    $('#scribing-color-' + qid)
      .change({ canvas: c }, function(event) {
        event.data.canvas.freeDrawingBrush.color = this.value;
      });

    $('#scribing-width-' + qid)
      .change({ canvas: c }, function(event) {
        event.data.canvas.freeDrawingBrush.width = this.value;
      });

    $('#grab-mode-' + qid)
      .click({ canvas: c, buttons: buttons }, function (event) {
        var canvas = event.data.canvas;
        var buttons = event.data.buttons;

        canvas.isDrawingMode = false;
        canvas.isGrabMode = true;
        canvas.selection = false;
        $(this).addClass('active');
        buttons.not(this).removeClass('active');
        $('#scribing-edit-tools-' + qid).addClass('hidden');
        $('#scribing-drawing-tools-' + qid).addClass('hidden');
      });

    $('#scribing-delete-' + qid)
      .click({
        canvas: c,
        ajaxSave: $('#answers_' + qid).data('locked'),
        qid: qid
      }, function (event) {
        var canvas = event.data.canvas;
        var ajaxSave = event.data.ajaxSave;
        var qid = event.data.qid;

        if(canvas.getActiveGroup()) {
          canvas.getActiveGroup().forEachObject(function(o) {
            canvas.remove(o);
          });
          canvas.discardActiveGroup().renderAll();
        }
        else {
          canvas.remove(canvas.getActiveObject());
        }

        if (ajaxSave) {
          updateScribble(qid,c);
        }
      });

    $('#scribing-zoom-in-' + qid)
      .click({ canvas: c }, function (event) {
          var canvas = event.data.canvas;

          var newZoom = canvas.getZoom() + 0.1;
          canvas.zoomToPoint({
            x: canvas.height/2,
            y: canvas.width/2
          },newZoom);
      });

    $('#scribing-zoom-out-' + qid)
      .click({ canvas: c }, function(event) {
        var canvas = event.data.canvas;

        var newZoom = Math.max(canvas.getZoom() - 0.1, 1);
        canvas.zoomToPoint({
          x: canvas.height/2,
          y: canvas.width/2
        }, newZoom);
      });

    $('#scribing-layers-' + qid)
      .change(function () {
          $(this).find('option').each(function (i, o) {
            var showLayer = $(o).attr('selected') == 'selected';
            $(o).data('toggleLayer')(showLayer);
          });
      });
  });

  //use the imagesLoaded library to invoke a callback when images are loaded
  imagesLoaded('.scribing-images', function() {
    //array of LoadingImages objects
    var loadedImages = this.images;

    $.each(loadedImages, function(index, loadingImage) {
      var scribingImage = loadingImage.img;
      var qid = $(scribingImage).data('qid');

      //get appropriate canvas by qid
      var c = fabricCanvases[qid];

      //calculate scaleX and scaleY to fit image into canvas
      //before creating fabric.Image object
      var scale = Math.min(
        c.width / scribingImage.width,
        c.height / scribingImage.height,
        1);

      //create fabric.Image object with the right scaling and
      // set as canvas background
      var fabricImage = new fabric.Image(
        scribingImage,
        {opacity: 1, scaleX: scale, scaleY: scale}
      );
      c.setBackgroundImage(fabricImage, c.renderAll.bind(c));
      c.renderAll();

      loadScribbles(c, qid);

      // Initialize zoom/scrolling variable
      var viewportLeft = 0,
          viewportTop = 0,
          mouseLeft,
          mouseTop,
          _drawSelection = c._drawSelection,
          isDown = false;

      c.on('mouse:down', function(options) {
        if (c.isGrabMode) {
          isDown = true;

          viewportLeft = c.viewportTransform[4];
          viewportTop = c.viewportTransform[5];

          mouseLeft = options.e.clientX;
          mouseTop = options.e.clientY;

          _drawSelection = c._drawSelection;
          c._drawSelection = function(){ };
        }
      });

      c.on('mouse:move', function(options) {
        if (c.isGrabMode && isDown) {
          var currentMouseLeft = options.e.clientX;
          var currentMouseTop = options.e.clientY;

          var deltaLeft = currentMouseLeft - mouseLeft,
              deltaTop = currentMouseTop - mouseTop;

          c.viewportTransform[4] = viewportLeft + deltaLeft;
          c.viewportTransform[5] = viewportTop + deltaTop;

          c.renderAll();
        }
      });

      c.on('mouse:up', function() {
        // Handle panning
        if (c.isGrabMode && isDown) {
          c._drawSelection = _drawSelection;
          isDown = false;
        }

        if (!c.isGrabMode) {
          // Either keep answer ready for saving
          var ansField = $('#answers_' + qid);
          if (ansField.data('locked')){
            updateScribble(qid,c);
          } else {
          // Or save scribbles continuously
            ansField.val(getJSON(qid,c));
          }
        }
      });
    });
  });
});
