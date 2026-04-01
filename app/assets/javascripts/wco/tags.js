
// console.log('Loaded wco/tags.js')

$(function() {

  $(".add-tag-many-btn").click(function(e) {
    logg('here?')

    if ( !confirm('Are you sure?') ) { return; }

    const jwt_token = $("#Config").data('jwt-token')
    const action_path = $(this).data('url')
    const a_tag = $("select[name='a_tag']").val()
    const out = []

    $( $("input[type='checkbox'].i-sel:checked") ).each( idx => {
      let val = $($("input[type='checkbox'].i-sel:checked")[idx]).val()
      out.push(val)
    })

    let data = {
      resource_ids: out,
      jwt_token: jwt_token,
      id: a_tag,
    }
    $.ajax({
      url: action_path,
      type: 'POST',
      data: data,
      success: e => {
        logg((e||{}).responseText, 'Ok')
        location.reload()
      },
      error: e => {
        logg((e||{}).responseText, 'Err')
        location.reload()
      },
    })

  })


  $(".remove-tag-btn").click(function(e) {
    if ( !confirm('Are you sure?') ) { return; }

    const jwt_token = $("#Config").data('jwt-token')
    const action_path = $(this).data('url')
    const emailtag = $("select[name='emailtag']").val()
    const out = []

    $( $(".conversations-list input[type='checkbox'].i-sel:checked") ).each( idx => {
      let val = $($("input[type='checkbox'].i-sel:checked")[idx]).val()
      out.push(val)
    })

    $.ajax({
      url: action_path,
      type: 'POST',
      data: {
        ids: out,
        jwt_token: jwt_token,
        slug: emailtag,
      },
      success: e => {
        logg((e||{}).responseText, 'Ok')
        location.reload()
      },
      error: e => {
        logg((e||{}).responseText, 'Err')
        location.reload()
      },
    })

  })

})