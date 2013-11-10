// Auto-magically referenced. Yay.

function parseFileJsonForJqTree(rootNode, shouldIncludeFiles, shouldIncludeVirtualFolders) {
  var folders = {};
  
  var NEW_FILE_INDICATOR = "*";
    
  // Convert all the folders to tree nodes.
  var foldersToProcess = [rootNode];
  while (foldersToProcess.length) {
    var currentFolder = foldersToProcess.shift();
    
    for (var i = 0; i < currentFolder.subfolders.length; i++) {
      var currentSubfolder = currentFolder.subfolders[i];
      if (!shouldIncludeVirtualFolders && currentSubfolder.is_virtual) {
        continue;
      }
      foldersToProcess.push(currentSubfolder);
    }
    
    var files = [];
    if (shouldIncludeFiles) {
      for (var i = 0; i < currentFolder.files.length; i++) {
        var currentFile = currentFolder.files[i];
        var fileNewIndicator = currentFile.is_new ? NEW_FILE_INDICATOR : "";
        var fileTreeNode = {
          label: currentFile.name + fileNewIndicator,
          id: "file_" + currentFile.id,
          url: currentFile.url
        };
        files.push(fileTreeNode);
      }
    }
    
    var count = currentFolder.files.length;
    var newIndicator = currentFolder.contains_new ? NEW_FILE_INDICATOR : "";
    
    var nameAndCount = currentFolder.name + " (" + count + newIndicator +")";
    folders[currentFolder.id] = {
      id: currentFolder.id,
      label: nameAndCount,
      url: currentFolder.url,
      parentId: currentFolder.parent_folder_id,
      children: files,
      isNodeFolder: true,
      isVirtual: currentFolder.is_virtual
    }
  }  
  
  var rootFolder;
  
  // Generate the tree we need for jqTree.
  for (var id in folders) {
    var folder = folders[id];
    var parentId = folder.parentId;
    if (!parentId) {
      rootFolder = folder;
    } else {
      folders[parentId].children.push(folder);
    }
  }
  
  // Sort the entries within each folder.
  for (var id in folders) {
    var folder = folders[id];
    folder.children.sort(function(a, b) {
      // Prioritize folders.
      if (a.children && !b.children) {
        return -1;
      } else if (!a.children && b.children) {
        return 1;
      }
      
      // Prioritize virtual folders.
      if (a.isVirtual && !b.isVirtual) {
        return -1;
      } else if (!a.isVirtual && b.isVirtual) {
        return 1;
      } else {
        // Sort by name.
        return a.label.localeCompare(b.label);
      }
    });
  }
  
  return [rootFolder];
}

$(document).ready(function() {
  var rootNode = gon.folders;
  if (!rootNode) {
      return;
  }
  
  var treeData = parseFileJsonForJqTree(rootNode, false, true);
  
  // Set up the tree.
  var treeElement = $('#file-tree');
  treeElement.tree({
    data: treeData,
    autoOpen: true,
    keyboardSupport: false,
    onCreateLi: function(node, $li) {
      var iconHtml = '<i class="icon-folder-open"></i>';
      $li.find('.jqtree-element').prepend(iconHtml);
    }
  });
  
  // Select the folder we're currently in.
  var currentId = gon.currentFolder.id;
  var currentFolderNode = treeElement.tree('getNodeById', currentId);
  treeElement.tree('selectNode', currentFolderNode);
  
  // Set up bindings on the tree.
  treeElement.bind('tree.select', function(event) {
    var selectedNode = event.node;
    if (selectedNode) {
      var selectedFolderUrl = selectedNode.url;
      window.location.href = selectedFolderUrl;
    }
  });
  
  // Set up the disabled controls tooltip.
  $('.workbin-disabled-controls').tooltip();
});

$(document).ready(function() {
  function show_error($this, error) {
    var group = $this.parents('.control-group');
    group.addClass('error');
    $('.help-inline', group).text(error);
    has_errors = true;
  }
  function remove_error($this) {
    var group = $this.parents('.control-group');
    group.removeClass('error');
    $('.help-inline', group).text('');
  }

  var original_filename = $('input#material_filename').val();
  $('input#material_filename').change(function() {
    var $this = $(this);
    if (this.value === original_filename) {
      remove_error($this);
    } else {
      // Check against the server.
      $.post('/courses/' + gon.course.id + '/materials/subfolder/' + gon.currentFolder.id + '/' + this.value,
          {_method: 'HEAD'})
          .done(function() {
            //This is supposed to fail! There's a file already.
            show_error($this, 'Another file with the same name already exists.');
          })
          .fail(function(e) {
            if (e.status === 404) {
              remove_error($this);
            } else if (!e.status) {
              show_error($this, 'Another file with the same name already exists.');
            }
          });
    }
  });

  var handleValidation = function(e) {
    if ($('.error', this).length > 0) {
      e.preventDefault();
    }
  };
  $('.materials-edit-form').submit(handleValidation);
  $('.materials-edit-form input[type="submit"]').click(function() {
    handleValidation.apply($('.materials-edit-form')[0], arguments);
  });
});
