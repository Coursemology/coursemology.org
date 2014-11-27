
$(document).ready(function () {

  // TODO
  // Ensure this works when there are multiple canvases on a page

  var underlayUrl = $('#scribing-canvas').data('url');
  var qid = $('#scribing-canvas').data('qid');
  var canvas = new fabric.Canvas('scribing-canvas');

  var toggle_mode = function () {
    if (canvas.isDrawingMode) {
      canvas.isDrawingMode = false;
    } else {
      canvas.isDrawingMode = true;
    }
  };
  $('#scribing-mode').click(toggle_mode);

  // http://stackoverflow.com/questions/11829786/delete-multiple-objects-at-once-on-a-fabric-js-canvas-in-html5
  var delete_selection = function () {
    if(canvas.getActiveGroup()) {
        canvas.getActiveGroup().forEachObject(function(o){ canvas.remove(o) });
        canvas.discardActiveGroup().renderAll();
      } else {
        canvas.remove(canvas.getActiveObject());
      }
  };
  $('#scribing-delete').click(delete_selection);

  if (underlayUrl != "") {
    canvas.setBackgroundImage(underlayUrl, canvas.renderAll.bind(canvas));
  }

  latest_scribble = $('#answers_' + qid).val();
  canvas.loadFromJSON(latest_scribble);
  canvas.renderAll();

  canvas.on('mouse:move', function(options) {
    $('#answers_' + qid).val(JSON.stringify(canvas));
  });
});