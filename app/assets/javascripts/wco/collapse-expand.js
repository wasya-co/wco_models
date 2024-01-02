

$(function () {

  console.log('Loaded wco/collapse-expand.js')

  $(".collapse-expand").each(function() {
    const thisId = $(this).attr('id')
    if (thisId) {
      const state = localStorage.getItem("collapse-expand#"+thisId)
      if (state === 'collapsed') {
        $(this).next().slideToggle()
        $(this).addClass('wco-collapse')
      }
    }
  })
  $(".collapse-expand").click(function (_e) {
    const thisId = $(this).attr('id')
    const state = localStorage.getItem("collapse-expand#"+thisId)
    if (state === 'collapsed') {
      localStorage.removeItem("collapse-expand#"+thisId)
      $(this).removeClass('wco-collapse')
    } else {
      localStorage.setItem("collapse-expand#"+thisId, "collapsed")
      $(this).addClass('wco-collapse')
    }
    $(this).next().slideToggle();
  }).children().click(function (e) {
    e.stopPropagation()
  })

}); // END