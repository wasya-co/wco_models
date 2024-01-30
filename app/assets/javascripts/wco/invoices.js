
const AppRouter = {
  product_path: (id) => `/wco/products/${id}.json`,
}

$(document).ready(function () {

  // const jwt_token = $("#Config").data('jwt-token')
  // logg(jwt_token, 'jwt_token')
  // path = `/api/products/${productId}.json?jwt_token=${jwt_token}`

  if ($(".invoices-new").length) {

    $("select[name='invoice[items][][product_id]']").on('change', function(ev) {
      var productId = ev.target.value
      logg(productId, 'productId')

      $.get(AppRouter.product_path(productId), function(_data) {
        logg(_data, '_data')

        $('select[name="invoice[items][][price_id]"]').empty();
        // $('select[name="invoice[items][][price_id]"]').append($("<option disabled=true selected=true></option>").attr("value", '').text('Choose a price...')
        $.each(_data.prices, function(_, item) {
          $('select[name="invoice[items][][price_id]"]').append($("<option></option>").attr("value", item.id).text(item.name));
        })
      })
    })

  }


})

