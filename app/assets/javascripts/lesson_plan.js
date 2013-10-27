function LessonPlanEntryFormType(pickers) {
  this.pickers = pickers;
  pickers.forEach(function(picker) {
    picker.onSelectionCompleted = this.doneCallback;
  });
}

LessonPlanEntryFormType.prototype.pick = function() {
  var $modal = $('<div class="modal hide fade" />');
  this.pickers[0].pick($modal[0]);
  $modal.modal();
}

LessonPlanEntryFormType.prototype.doneCallback = function(idTypePairList) {
  idTypePairList.forEach(function(x) {
    $("#uploaded_files_div").append(
      '<input type="hidden" name="resources[]" value="' + x[0] + ',' + x[1] + '" />');
  });
};

var LessonPlanEntryForm = new LessonPlanEntryFormType([]);

$(document).ready(function() {
  $('.addresource-button').click(function() {
    LessonPlanEntryForm.pick();
  });
});
