//
//
//= require ../vendor/jquery-3.3.1.min
//= require ../vendor/popper-1.14.0.min
//= require ../vendor/bootstrap-4.6.2.min
//= require ../vendor/select2-4.0.0
//= require ../vendor/jquery.dataTables-1.10.16
//
// Skip for now b/c I need to move fonts, too:
// require ../vendor/summernote-0.8.18
//
// require ../vendor/fontawesome-5.15.4.min
//
//= require rails-ujs
//= require ../vendor/jquery.iframe-transport
//= require ../vendor/jquery.ui.widget
//= require ../vendor/jquery.fileupload
//= require ../vendor/jquery-ui.min
//
// require ./alerts-notices
// require ./collapse-expand
// require ./file_upload
// require ./office_action_templates
//
//= require ./shared
//= require_tree .
//

$(function() {

/* DataTable */
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
    order: [], // [ 3, 'desc' ],
  }
  $('.data-table').DataTable(_props)
}

/* datepicker */
if ('function' === typeof $('body').datepicker) {
  $(".datepicker").datepicker({ dateFormat: 'yy-mm-dd' })
}

/* select2 */
if (!!$('body').select2) {
  $('.select2').each(function() {
    $( this ).select2({
      width: '100%',
    })
  })
}

/* tinymce */
if ($(".tinymce").length > 0) {
  $(".tinymce").summernote()
}

/*
 * select_all
 * _vp_ 2023-02-28
**/
$("input[type='checkbox'].i-sel").change((ev) => {
  $( $(".n-selected")[0] ).html( $("input[type='checkbox'].i-sel:checked").length )
})
$("input#select_all[type='checkbox']").change((e) => {
  const count = $("input[type='checkbox'].i-sel:checked").length
  const new_state = count ? false : true // all will be checked?

  $(".select-all input[type='checkbox']").prop('checked', new_state)

  $( $("input[type='checkbox'].i-sel") ).each( i => {
    $( $("input[type='checkbox'].i-sel")[i] ).prop('checked', new_state)
  })

  $( $(".n-selected")[0] ).html( $("input[type='checkbox'].i-sel:checked").length )
})



console.log('Loaded wco/application.js')
}); // END
