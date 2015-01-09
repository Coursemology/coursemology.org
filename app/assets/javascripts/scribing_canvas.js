// TODO
// - Add limit to panning
// - Disallow drawing when cursor moves outside canvas
// - Limit canvas to page height, esp for mobile phones.
// - Resize canvas on window resize


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

function hookButtonsToCanvas(qid, c) {
  var buttons = $('#scribing-buttons-' + qid + ' a');
  var isEditMode = $('#scribing-mode-' + qid).length !== 0;

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

  if (isEditMode) {

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

    //use iris colorpicker
    //see documentation at http://automattic.github.io/Iris/
    $('#scribing-color-' + qid).iris({
        change: function(event, ui) {
                  c.freeDrawingBrush.color = ui.color.toString();
                  // make input textbox change colour accordingly
                  $(event.target).css('background-color', ui.color.toString());
                  $(event.target).css('color', ui.color.toString());
                }
      });

    $('#scribing-width-' + qid)
      .change(function(event) {
        c.freeDrawingBrush.width = this.value;
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
  }
}

// INITIALISE CANVASES

$(document).ready(function () {

  //use the imagesLoaded library to invoke a callback when images are loaded
  imagesLoaded('.scribing-images', function() {
    //array of LoadingImages objects
    var loadedImages = this.images;

    $.each(loadedImages, function(index, loadingImage) {
      var scribingImage = loadingImage.img;
      var qid = $(scribingImage).data('qid');
      var isEditMode = $('#scribing-mode-' + qid).length !== 0;

      // get appropriate canvas by qid
      var c = new fabric.Canvas('scribing-canvas-' + qid); // js object
      c.clear();
      hookButtonsToCanvas(qid, c);

      //event handlers to hide iris color pickers when they lose focus
      //adapted from
      //http://stackoverflow.com/questions/19682706/how-do-you-close-the-iris-colour-picker-when-you-click-away-from-it
      $(document).click(function(e) {
        if (!$(e.target).is(".scribing-color-val .iris-picker .iris-picker-inner")) {
          $('.scribing-color-val').iris('hide');
        }
      });
      //this bit is needed so iris will come up and stay upwhen the textbox is clicked
      $('.scribing-color-val').click(function(event) {
        $('.scribing-color-val').iris('hide');
        $(this).iris('show');
        return false;
      });

      c.setWidth(Math.min($('#scribing-container-' + qid).width(), scribingImage.width));

      //calculate scaleX and scaleY to fit image into canvas
      //before creating fabric.Image object
      var scale = Math.min(
        c.width / scribingImage.width,
        1);

      //work out the correct height after getting the right scale from the width
      c.setHeight(scale * scribingImage.height);

      //create fabric.Image object with the right scaling and
      // set as canvas background
      var fabricImage = new fabric.Image(
        scribingImage,
        {opacity: 1, scaleX: scale, scaleY: scale}
      );
      c.setBackgroundImage(fabricImage, c.renderAll.bind(c));
      c.renderAll();

      loadScribbles(c, qid);

      if (!isEditMode) {
        $.each(c.getObjects(), function (i, obj) {
          obj.selectable = false;
        });
      }

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

        if (!c.isGrabMode && isEditMode) {
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
