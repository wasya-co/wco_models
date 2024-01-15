//
//
// // this was loaded twice causing issues - disabled for now.
// require vendor/jquery-3.3.1.min
// require vendor/popper-1.14.0.min
// require vendor/bootstrap-4.6.2.min
// require vendor/fontawesome-5.15.4.min
//
//= require rails-ujs
//= require vendor/jquery.iframe-transport
//= require vendor/jquery.ui.widget
//= require vendor/jquery.fileupload
//= require vendor/jquery-ui.min
//
// require select2
//
//= require ./alerts-notices
//= require ./collapse-expand
//= require ./file_upload
//= require ./shared
//

$(function() {


if ('function' === typeof $('body').DataTable) {
  const _props = {
    dom: 'lpftrip',
    lengthChange: true,
    lengthMenu: [[10, 25, 100, -1], [10, 25, 100, 'All']],
    pageLength: 25,
    aoColumnDefs: [ {
      bSortable: false,
      aTargets: [ "nosort" ],
    } ],
    order: [ 4, 'desc' ],
  }
  $('.data-table').DataTable(_props)
}

if ('function' === typeof $('body').datepicker) {
  $(".datepicker").datepicker({ dateFormat: 'yy-mm-dd' })
}


if (!!$('body').select2) {
  $('.select2').each(function() {
    $( this ).select2({
      width: '100%',
    })
  })
}

$('select[name="office_action_template[from_type]"]').on('change', (ev) => {
  logg(ev.target.value, 'changed')

  // let url = window.location.href;
  // if (url.indexOf('?') > -1){
  //   url += `&from_type=${ev.target.value}`
  // } else {
  //   url += `?from_type=${ev.target.value}`
  // }
  // window.location.href = url;

  const parser = new URL(window.location);
  parser.searchParams.set('from_type', ev.target.value);
  window.location = parser.href;
})

console.log('Loaded wco/application.js')
}); // END
