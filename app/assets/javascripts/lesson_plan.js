function LessonPlanEntryForm(pickers) {
  pickers.forEach(function(picker) {
    picker.onSelectionCompleted = this.doneCallback;
  });
}

LessonPlanEntryForm.prototype.doneCallback = function(idTypePairList) {
  
};

var pickers = [new MaterialsFilePicker()];
var LessonPlanForm = new LessonPlanEntryForm(pickers);