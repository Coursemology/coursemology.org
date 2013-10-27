function MaterialsFilePicker(callback) {
  this.doneCallback = callback;
  this.selectedMaterials = [];
}

MaterialsFilePicker.prototype.onSelectionCompleted = function() {
  this.doneCallback(this.selectedMaterials);
}