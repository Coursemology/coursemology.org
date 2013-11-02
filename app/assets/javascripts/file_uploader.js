$(document).ready(function(){
    // setup the drag drop zone
    var target_el = '';

    $('.file-uploader-trigger').click(function() {
        target_el = $(this).attr('data-target');
        $('#file-upload-form').fileupload({
            acceptFileTypes: new RegExp(
                $(this).attr('data-accepts-filetypes') || '.*', 'i')
        });
        var modal = $(this).attr('href');
        $(modal).modal('show');
        return false;
    });

    // setup fileuploader
    $('#file-upload-form').fileupload({
        maxFileSize: 5000000,
        autoUpload: true,
        dropZone: $('#dropzone'),
        dataType: 'json',
        url: $('#file-upload-form').attr('action'),
        formData: [
            {
                name: '_method',
                value: 'POST '
            },
            {
                name: '_page_name',
                value: $('#page_name').val()
            }],
        done: function(e, data) {
            $(target_el + '-input').attr('value',
                typeof data.result.id === undefined ?
                    data.result.url : data.result.id);
            $(target_el + '-done').css('display', 'block');
            $('.file-uploader-insert-btn').click();
        }
    });

    // animation on the drop zone
    $(document).bind('dragover', function (e) {
        var dropZone = $('#dropzone'),
            timeout = window.dropZoneTimeout;
        if (!timeout) {
            dropZone.addClass('in');
        } else {
            clearTimeout(timeout);
        }
        if (e.target === dropZone[0]) {
            dropZone.addClass('hover');
        } else {
            dropZone.removeClass('hover');
        }
        window.dropZoneTimeout = setTimeout(function () {
            window.dropZoneTimeout = null;
            dropZone.removeClass('in hover');
        }, 100);
    });

    $(document).bind('drop dragover', function (e) {
        e.preventDefault();
    });

});

