
$(function() {

  $('select[name="office_action_template[from_type]"]').on('change', (ev) => {
    // logg(ev.target.value, 'changed')

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

}); // END