// TODO
// - Disallow drawing when cursor moves outside canvas
// - Limit canvas to page height, esp for mobile phones.
// - Resize canvas on window resize

// HELPER FUNCITONS

function normaliseScribble(s, canvas, isDenormalise) {
  var STANDARD = 1000;
  var factor;

  if (isDenormalise) {
    factor = canvas.getWidth() / STANDARD;
  } else {
    factor = STANDARD / canvas.getWidth();
  }

  s.set({
    scaleX: s.scaleX * factor,
    scaleY: s.scaleY * factor,
    left: s.left  * factor,
    top: s.top  * factor
  });

  return s;
}

function getJSON(qid, canvas) {
  // remove all locked layers
  var layersList = $('#scribing-layers-' + qid);
  layersList.find('option').each(function (i, o) {
    $(o).data('toggleLayer')(false);
  });

  // Normalise scribbles for saving (cloning is more expensive)
  $.each(canvas._objects, function (i, o) {
    normaliseScribble(o, canvas, false);
  });

  // get json output for current user
  var output = JSON.stringify(canvas._objects);

  // Denormalise
  $.each(canvas._objects, function (i, o) {
    normaliseScribble(o, canvas, true);
  });

  // restore locked layers and return
  layersList.change();
  return '{"objects":'+ output +'}';
}

function updateScribble(qid, canvas) {
  var ajaxField = $('#scribing-ajax-' + qid);
  var newJSON = getJSON(qid, canvas);
  var oldJSON = ajaxField.data('content');
  if (newJSON !== oldJSON) {
    ajaxField.data('content', newJSON);
    $.ajax({
        type: 'POST',
        url: '/scribbles',
        data: {
          scribble: {
            'std_course_id': ajaxField.data('std-course-id'),
            'scribing_answer_id': ajaxField.data('scribing-answer-id'),
            'id': ajaxField.data('id'),
            'content': ajaxField.data('content'),
          },
        },
        // failure: function(msg) {
        //     console.log("Scribble update failed. " + msg);
        // }
    });
  }
}

function loadScribbles(c, qid) {
  var layersList = $('#scribing-layers-' + qid);
  layersList.empty();
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

  function addDenormalisedFabricObj(item) {
    normaliseScribble(item, c, true);
    fabricObjs.push(item);
  }

  for (var i = 0; i < objects.length; i++) {
    var klass = fabric.util.getKlass(objects[i].type);
    if (klass.async) {
      klass.fromObject(objects[i], addDenormalisedFabricObj);
    } else {
      var item = klass.fromObject(objects[i]);
      addDenormalisedFabricObj(item);
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

    var toggleLayer = function(showLayer) {
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

// Makes current user's scribbles (un)selectable
function toggleSelectable (qid, c, isSelectable) {
  var layersList = $('#scribing-layers-' + qid);
  // Hide scibbles by other users
  layersList.find('option').each(function (i, o) {
    $(o).data('toggleLayer')(false);
  });
  // Make own scribbles un/selectable
  $.each(c.getObjects(), function (i, obj) {
    obj.selectable = isSelectable;
  });
  // Restore scibbles by other users
  layersList.change();
  c.renderAll();
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
      toggleSelectable(qid, canvas, false);

      // Change to appropriate button config
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
      canvas.trigger('mouse:move', {'isForced': true});
    });

  $('#scribing-layers-' + qid)
    .change(function () {
      // ensures that layers are show/hid according to checklist
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
        canvas.selection = true;

        // Change to appropriate button config
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
        toggleSelectable(qid, canvas, true);

        // Change to appropriate button config
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
        } else {
          var ansField = $('#answers_' + qid);
          ansField.val(getJSON(qid,canvas));
        }
      });
  }
}

function renderCanvas(c, scribingImage, isEditMode, qid) {
  c.clear();
  c.setWidth(Math.min(
    $('#scribing-container-' + qid).width(),
    scribingImage.width
  ));

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
  loadScribbles(c, qid);

  if (!isEditMode) {
    $.each(c.getObjects(), function (i, obj) {
      obj.selectable = false;
    });
  }
  c.renderAll();
}

// INITIALISE CANVASES

$(document).ready(function () {
  var isEditMode;

  //use the imagesLoaded library to invoke a callback when images are loaded
  imagesLoaded('.scribing-images', function() {
    //array of LoadingImages objects
    var loadedImages = this.images;

    $.each(loadedImages, function(index, loadingImage) {
      var scribingImage = loadingImage.img;
      var qid = $(scribingImage).data('qid');
      isEditMode = $('#scribing-mode-' + qid).length !== 0;

      // get appropriate canvas by qid
      var c = new fabric.Canvas('scribing-canvas-' + qid); // js object
      hookButtonsToCanvas(qid, c);
      renderCanvas(c, scribingImage, isEditMode, qid);

      // Ensures that canvas shows correctly in tabbed mission view
      // Otherwise, canvas is size zero.
      $('a[data-toggle="tab"][data-qid="'+ qid +'"]')
        .on('shown', function (e) {
          renderCanvas(c, scribingImage, isEditMode, qid);
        });

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

        var tryPan = function (finalLeft, finalTop) {
          // limit panning
          finalLeft = Math.min(finalLeft, 0);
          finalLeft = Math.max(finalLeft, (c.getZoom()-1) * c.getWidth() * -1 );
          finalTop = Math.min(finalTop, 0);
          finalTop = Math.max(finalTop, (c.getZoom()-1) * c.getHeight() * -1 );

          // apply calculated pan transforms
          c.viewportTransform[4] = finalLeft;
          c.viewportTransform[5] = finalTop;
          c.renderAll();
        };

        if (c.isGrabMode && isDown) {
          var currentMouseLeft = options.e.clientX;
          var currentMouseTop = options.e.clientY;
          var deltaLeft = currentMouseLeft - mouseLeft;
          var deltaTop = currentMouseTop - mouseTop;
          var newLeft = viewportLeft + deltaLeft;
          var newTop = viewportTop + deltaTop;
          tryPan(newLeft, newTop);
        } else if (options['isForced']) {
          tryPan(c.viewportTransform[4], c.viewportTransform[5]);
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

  //event handlers to hide iris color pickers when they lose focus
  //adapted from
  //http://stackoverflow.com/questions/19682706/how-do-you-close-the-iris-colour-picker-when-you-click-away-from-it
  $(document).click(function(e) {
    if (!$(e.target).is('.scribing-color-val .iris-picker .iris-picker-inner')) {
      if (isEditMode) {
        $('.scribing-color-val').iris('hide');
      }
    }
  });

  //this bit is needed so iris will come up and stay upwhen the textbox is clicked
  $('.scribing-color-val').click(function(event) {
    $('.scribing-color-val').iris('hide');
    $(this).iris('show');
    return false;
  });
});
