// TODO
// - Add limit to panning


// HELPER FUNCITONS

var get_json = function (qid, canvas) {
  // remove all locked layers
  var layers_list = $('#scribing-layers-' + qid);
  layers_list.find('option').each(function (i, o) {
    $(o).data('toggle_layer')(false);
  });

  // get json output for current user
  var output = JSON.stringify(canvas._objects);

  // restore locked layers and return
  layers_list.change();
  return '{"objects":'+ output +'}';
};

var update_scribble = function (qid, canvas) {
  var ajax_field = $('#scribing-ajax-' + qid + ' .scribble-content');
  ajax_field.val(get_json(qid, canvas));
  $('#scribing-ajax-' + qid).submit();
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
    var buttons = $('#scribing-buttons-' + qid + ' a')
    var c = new fabric.Canvas('scribing-canvas-' + qid); // js object 
    c.clear();
    fabricCanvases[qid] = c;

    //set brush width to value declared in scribing canvas view
    c.freeDrawingBrush.width = $('#scribing-width-' + qid).val();

    $('#scribing-mode-' + qid).click({ canvas: c, buttons: buttons }, function (event) {
      var canvas = event.data.canvas;
      var buttons = event.data.buttons;

      canvas.isDrawingMode = true;
      canvas.isGrabMode = false;
      $(this).addClass("active");
      buttons.not(this).removeClass("active");
    });

    $('#edit-mode-' + qid).click({ canvas: c, buttons: buttons }, function (event) {
      var canvas = event.data.canvas;
      var buttons = event.data.buttons;

      canvas.isDrawingMode = false;
      canvas.isGrabMode = false;
      canvas.selection = false;
      $(this).addClass("active");
      buttons.not(this).removeClass("active");
    });

    $('#scribing-color-' + qid).change({ canvas: c }, function(event) {
      event.data.canvas.freeDrawingBrush.color = this.value;
    });

    $('#scribing-width-' + qid).change({ canvas: c }, function(event) {
      event.data.canvas.freeDrawingBrush.width = this.value;
    });

    $('#grab-mode-' + qid).click({ canvas: c, buttons: buttons }, function (event) {
      var canvas = event.data.canvas;
      var buttons = event.data.buttons;

      canvas.isDrawingMode = false;
      canvas.isGrabMode = true;
      canvas.selection = false;
      $(this).addClass("active");
      buttons.not(this).removeClass("active");
    });

    // http://stackoverflow.com/questions/11829786/delete-multiple-objects-at-once-on-a-fabric-js-canvas-in-html5
    $('#scribing-delete-' + qid).click({ canvas: c }, function (event) {
      var canvas = event.data.canvas;

      if(canvas.getActiveGroup()) {
        canvas.getActiveGroup().forEachObject(function(o){ canvas.remove(o) });
        canvas.discardActiveGroup().renderAll();
      }
      else {
        canvas.remove(canvas.getActiveObject());
      }
    });

    $('#scribing-zoom-in-' + qid).click({ canvas: c }, function (event) {
        var canvas = event.data.canvas;

        var newZoom = canvas.getZoom() + 0.1;
        canvas.zoomToPoint({ x: canvas.height/2, y: canvas.width/2 }, newZoom);
    });

    $('#scribing-zoom-out-' + qid).click({ canvas: c }, function(event) {
      var canvas = event.data.canvas;

      var newZoom = Math.max(canvas.getZoom() - 0.1, 1);
      canvas.zoomToPoint({ x: canvas.height/2, y: canvas.width/2 }, newZoom);
    });

    $('#scribing-layers-' + qid).change(function () {
        $(this).find('option').each(function (i, o) {
          var show_layer = $(o).attr('selected') == 'selected';
          $(o).data('toggle_layer')(show_layer);
        });
    }); 

  });

  //assign each canvas its image
  $.each(scribingImages, function(qid, scribingImage) {
    //get appropriate canvas by qid
    var c = fabricCanvases[qid];

    //calculate scaleX and scaleY to fit image into canvas before creating fabric.Image object
    var scale = Math.min(c.width / scribingImage.width, c.height / scribingImage.height, 1);

    //create fabric.Image object with the right scaling and set as canvas background
    var fabricImage = new fabric.Image(scribingImage, {opacity: 1, scaleX: scale, scaleY: scale});
    c.setBackgroundImage(fabricImage, c.renderAll.bind(c));
    c.renderAll();

    var layers_list = $('#scribing-layers-' + qid);
    layers_list.selectpicker('hide'); // remains hidden if there are no layers

    var load_scribble = function (scribble) {
      // from http://jsfiddle.net/Kienz/sFGGV/6/ via https://github.com/kangax/fabric.js/issues/704
      if (scribble.val() == '') {
        return;
      }
 
      // Convert javascript objects to fabricjs objects
      var objects = JSON.parse(scribble.val()).objects;
      var drawn_items = [];
      for (var i = 0; i < objects.length; i++) {
        var klass = fabric.util.getKlass(objects[i].type);
        if (klass.async) {
          klass.fromObject(objects[i], function (img) {
            drawn_items.push(img);
          });
        } else {
          var item = klass.fromObject(objects[i]);
          drawn_items.push(item);
        }
      }      
      
      // Case when scribble should be read-only    
      if (scribble.data('locked') && drawn_items.length > 0) {
        var scribble_group = new fabric.Group(drawn_items);
        scribble_group.originX = 'center';
        scribble_group.originY = 'center';
        c.add(scribble_group);
        scribble_group.selectable = false;

        // Populate drop-down box
        var new_layer_entry = $('<option>').text(scribble.data('scribe')).attr('selected','selected');
        layers_list.append(new_layer_entry);

        var toggle_layer = function (show_layer) {
          var this_group = scribble_group;
          if (show_layer && !c.contains(this_group)) {
            c.add(this_group);
          } else if (!show_layer && c.contains(this_group)) {
            c.remove(this_group);
          }
          c.renderAll();
        };
        new_layer_entry.data({toggle_layer: toggle_layer});
          
        layers_list.selectpicker('show');
        layers_list.selectpicker('refresh');

      } else if (!scribble.data('locked')) {

        // Case when scribble is to be editable
        drawn_items.map( function(o){ c.add(o) } );
      }

    };

    // load saved scribblings
    answer_scribble = $('#answers_' + qid);
    load_scribble(answer_scribble);

    other_scribbles = $('.scribble-' + qid);
    $.each(other_scribbles, function (i, scribble) {
      load_scribble($(scribble));
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

      // The answer scribble is updated at all times, ready for form submmission.
      if (!c.isGrabMode) {
        $('#answers_' + qid).val(get_json(qid,c));
        update_scribble(qid,c);
      }
    });

  });

});
