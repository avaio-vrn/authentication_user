$(window).on('cart.add.item', function (event, goodsWrap) {
  var cart = $('.js__cart-drop');
  var imgtodrag = $(goodsWrap).find('.js__goods-image');
  if (cart.length != 0 && imgtodrag.length != 0) {
    var imgclone = imgtodrag.clone()
      .addClass('imgtodrag')
      .offset({
        top: imgtodrag.offset().top,
        left: imgtodrag.offset().left
      })
      .css({
        'opacity': '0.5',
        'position': 'absolute',
        'height': imgtodrag.height(),
        'width': imgtodrag.width(),
        'z-index': '100'
      })
      .appendTo($('body'))
      .animate(
        {
          'top': cart.offset().top + 20,
          'left': cart.offset().left + 35,
          'width': 75,
          'height': 75
        }, 1000
      );

      imgclone.animate({
        'width': 0,
        'height': 0,
      }, 200, function () {
        $(this).detach()
      });
  }
});
