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

  $('form.materials-edit-form').validatr([
    ['input#material_filename', function() {
      var $this = $(this);
      if (this.value === gon.currentMaterial.filename) {
        return null;
      } else {
        // Check against the server.
        var deferred = $.Deferred();
        $.post('/courses/' + gon.course.id + '/materials/subfolder/' + gon.currentFolder.id + '/' + this.value,
          {_method: 'HEAD'})
          .done(function() {
            //This is supposed to fail! There's a file already.
            deferred.resolve('Another file with the same name already exists.');
          })
          .fail(function(e) {
            if (e.status === 404) {
              deferred.resolve(null);
            } else if (!e.status) {
              deferred.resolve('Another file with the same name already exists.');
            }
          });

        return deferred.promise();
      }
    }]
  ]);
  
  function shadeSelectedFiles() {
    $('.materials-select-file-checkbox').each(function(index) {
      var parent = $(this).parents('.materials-file-row');
      if ($(this).prop('checked')) {
        parent.addClass('materials-file-selected');
      } else {
        parent.removeClass('materials-file-selected');
      }
    });
  }
  
  $('#materials-select-all-files').click(function() {
    var isChecked = $(this).prop('checked');
    $('.materials-select-file-checkbox').prop('checked', isChecked);
    shadeSelectedFiles();
  });
  
  $('#materials-download-zip-button').click(function(e) {
    var checkedFiles = [];
    $('.materials-select-file-checkbox').each(function(index) {
      var checkbox = $(this);
      var fileId = checkbox.data('fileid');
      
      var isChecked = checkbox.prop('checked');
      if (isChecked) {
        checkedFiles.push(fileId);
      }
    });

    e.preventDefault();
    location.href = this.href + "?" + jQuery.param({
      include: checkedFiles
    });
  });
  
  // Shade selected rows on load.
  shadeSelectedFiles();
  
  // Select a row by clicking on it.
  $('.materials-file-row').click(function(event) {
    if ($(event.target).parents('.btn').length > 0) {
      // Do not highlight this row since it was a button which was clicked.
      return;
    }

    $(this).toggleClass('materials-file-selected');
    var checkbox = $(this).find('.materials-select-file-checkbox');
    var isChecked = checkbox.prop('checked');
    checkbox.prop('checked', !isChecked);
  });
  
  $('.materials-select-file-checkbox').click(function(event) {
    // Don't bubble up to the div, or we'd never be able to check the box.
    event.stopPropagation();
    
    var parent = $(this).parents('.materials-file-row');
    parent.toggleClass('materials-file-selected');
    
    // Uncheck the master checkbox if we need to.
    var masterBox = $('#materials-select-all-files');
    if (masterBox.prop('checked')) {
      masterBox.prop('checked', false);
    }
  });
});
