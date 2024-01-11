
$(function () {

  var fileuploadCount = 0
  $('#fileupload').fileupload({
    dataType: 'json',
    success: function(ev) {
      logg(ev, 'success')
      ev = ev[0]
      fileuploadCount += 1
      var el = $('<div class="item" />')
      var photosEl = $('#photos')
      $('<div/>').html(fileuploadCount).appendTo(el)
      $('<img/>').attr('src', ev.thumbnail_url).appendTo(el)
      $('<div/>').html(ev.name).appendTo(el)
      el.appendTo(photosEl)
    },
    error: function(err) {
      logg(err, 'error')
      err = err.responseJSON
      fileuploadCount += 1
      var el = $('<div class="item" />')
      var errorsEl = $('.photos--multinew .errors')
      $('<div/>').html(fileuploadCount).appendTo(el)
      $('<div />').html(err.filename).appendTo(el)
      $('<div />').html(err.message).appendTo(el)
      el.appendTo(errorsEl)
    },
  });

  console.log('Loaded wco/file_upload.js')
}); // END
