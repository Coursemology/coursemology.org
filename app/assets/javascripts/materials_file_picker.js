function MaterialsFilePicker(callback) {
  this.doneCallback = callback;
  this.selectedMaterials = [];
}

MaterialsFilePicker.prototype.done = function() {
  this.doneCallback(this.selectedMaterials);
}