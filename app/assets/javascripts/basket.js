//= require cart_add_goods_anim
//
var update = function(event) {
  $.spinner.remove();
  $.spinner.create($(event.target).closest('.js__basket-item').find('.js__basket-item-sum'));
  $.spinner.create('.js__basket-update');
  $.spinner.show();

  $.ajax({
    method: "PUT",
    url: location.protocol + '//' + location.host + "/basket_items/" + $(this).closest('.js__basket-item').data('basket-item'),
    data: {
      basket_item_count: $(this).val() * 1
    }
  }).success(function() {
    $.spinner.remove();
  })
};
$('.js__basket-item-count').change(update);
$('.js__basket-item-count').keyup(update);


function basketAddInit() {
  $('.js__basket-add').click(function() {
    var button = this;
    $('body').addClass('baractive');
    $.spinner.remove();
    $.spinner.create('.js__cart');
    $.spinner.show();
    $.ajax({
      method: "POST",
      url: location.protocol + '//' + location.host + '/basket_items',
      data: {
        basket_item_count: $(this).parent().find('.js__basket-count').val(),
        tovar_model: this.getAttribute('data-id') || $('.js__goods-wrap').data('m')
      }
    }).success(
      function() {
        $.spinner.remove();
        $(button).trigger("basketAdd");
        if (yaMetrikaExists()) {
          window["yaCounter" + TS.vars.ymetrika].reachGoal('cart.Add')
        }
      }
    )
  })
};

basketAddInit();
