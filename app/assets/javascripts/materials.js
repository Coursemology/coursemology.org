// Auto-magically referenced. Yay.

$(document).ready(function() {
  $('#file-tree').tree({
    data: [{
      label: 'Root',
      children: [
        { label: 'Slides (5)' },
        { label: 'Assignments (22)' }
      ]
    }],
    autoOpen: 0
  });
});