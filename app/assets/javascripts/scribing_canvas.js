// TODO
// - Add limit to panning


// BUTTON EVENT HANDLERS

var edit_mode = function (canvas, buttons) {
  var handler = function () {
    canvas.isDrawingMode = false;
    canvas.isGrabMode = false;
    canvas.selection = false;
    $(this).addClass("active");
    buttons.not(this).removeClass("active");
  };
  return handler;
};

var grab_mode = function (canvas, buttons) {
  var handler = function () {
    canvas.isDrawingMode = false;
    canvas.isGrabMode = true;
    canvas.selection = false;
    $(this).addClass("active");
    buttons.not(this).removeClass("active");
  };
  return handler;
};

var drawing_mode = function (canvas, buttons) {
  var handler = function () {
    canvas.isDrawingMode = true;
    canvas.isGrabMode = false;
    $(this).addClass("active");
    buttons.not(this).removeClass("active");
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
    var newZoom = canvas.getZoom() + 0.1;
    canvas.zoomToPoint({ x: canvas.height/2, y: canvas.width/2 }, newZoom);
  };
  return handler;
};


var zoom_out = function (canvas) {
  var handler = function (e) {
    var newZoom = Math.max(canvas.getZoom() - 0.1, 1);
    canvas.zoomToPoint({ x: canvas.height/2, y: canvas.width/2 }, newZoom);
  };
  return handler;
};

var update_layers = function () {
  $(this).find('option').each(function (i, o) {
    var show_layer = $(o).attr('selected') == 'selected';
    $(o).data('toggle_layer')(show_layer);
  });
};

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
  return output;
};


var save_canvas = function (qid, canvas) {
  // Make AJAX call to save scribbles.
  var handler = function (e) {
    var c = $('#scribing-ajax-' + qid + ' .scribble-content');
    var output = {"objects": get_json(qid, canvas)};
    console.log(output); /////// TODO
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
    var buttons = $('#scribing-buttons-' + qid + ' a')
    var c = new fabric.Canvas('scribing-canvas-' + qid); // js object 
    fabricCanvases[qid] = c;


    $('#scribing-mode-' + qid).click(drawing_mode(c, buttons));
    $('#edit-mode-' + qid).click(edit_mode(c, buttons));
    $('#grab-mode-' + qid).click(grab_mode(c, buttons));
    $('#scribing-delete-' + qid).click(delete_selection(c));
    $('#scribing-zoom-in-' + qid).click(zoom_in(c));
    $('#scribing-zoom-out-' + qid).click(zoom_out(c));
    $('#scribing-save-' + qid).click(save_canvas(qid, c));
    $('#scribing-layers-' + qid).change(update_layers);

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
    layers_list.selectpicker('hide');

    var load_scribble = function (scribble) {
      // from http://jsfiddle.net/Kienz/sFGGV/6/ via https://github.com/kangax/fabric.js/issues/704
      if (scribble.val() == '') {
        return;
      }
      var objects = JSON.parse(scribble.val()).objects;
      var drawn_items = [];
      for (var i = 0; i < objects.length; i++) {
        var klass = fabric.util.getKlass(objects[i].type);
        if (klass.async) {
          klass.fromObject(objects[i], function (img) {
            c.add(img);
            drawn_items.push(img);
          });
        } else {
          var item = klass.fromObject(objects[i]);
          c.add(item);
          drawn_items.push(item);
        }
      }      
      
      // Case when scribble should be read-only    
      if (scribble.data('locked') && drawn_items.length > 0) {

        // Group scribbles and make the group unselectable
        if (drawn_items.length > 1) {
          scribble_group = new fabric.Group(drawn_items);
        } else {
          scribble_group = drawn_items[0];
        }
        scribble_group.selectable = false;

        // Populate drop-down box
        var new_layer_entry = $('<option>').text(scribble.data('scribe')).attr('selected','selected');
        layers_list.append(new_layer_entry)

        var toggle_layer = function (show_layer) {
          var this_group = scribble_group;
          if (show_layer && !c.contains(this_group)) {
            c.add(this_group);
          } else if (!show_layer && c.contains(this_group)) {
            c.remove(scribble_group);
          }
          c.renderAll();
        };
        new_layer_entry.data({toggle_layer: toggle_layer});
          
        layers_list.selectpicker('show');
        layers_list.selectpicker('refresh');
      }

      c.renderAll();
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

      // Handle 
      if (c.isDrawingMode) {
        //add event handler to save changes in scribbles
        $('#answers_' + qid).val(JSON.stringify(c));
      }

      // Handle panning
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
      if (c.isGrabMode && isDown) {
        c._drawSelection = _drawSelection;
        isDown = false;
      }
    });

  });

});
