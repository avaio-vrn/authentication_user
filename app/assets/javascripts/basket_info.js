window.ClientSideValidations.callbacks.form.fail = function(form, eventData) {
  scrollToY(eventData.currentTarget.offsetTop, 1500, 'easeInOutQuint');
  if (yaMetrikaExists()) {
    window["yaCounter" + TS.vars.ymetrika].reachGoal('cart.NotValidData')
  }
}

document.addEventListener('client.ts_async.loaded', function() {
console.log('basket info')
  if (yaMetrikaExists()) {
    window["yaCounter" + TS.vars.ymetrika].reachGoal('cart.Info')
  }
})

$('.js__pay').on('change', function(e) {
  if (e.target.value == 2) {
    $('.js__pay-btn').removeClass('hidden');
    $('.js__send-btn').addClass('hidden');
  } else {
    $('.js__pay-btn').addClass('hidden');
    $('.js__send-btn').removeClass('hidden');
  }

  $.map($(this).parent().find('.js__right-panel').children(), function(elem) {
    $(elem).addClass('hidden');
  })
  if (e.target.value == 3) {
    $('.js__pay-org').removeClass('hidden')
  }
  if (e.target.value == 99) {
    $('.js__pay-other').removeClass('hidden')
  }
})

$('.js__delivery-type').on('change', function(e) {
  $.map($(this).parent().find('.js__right-panel').children(), function(elem) {
    $(elem).addClass('hidden');
  })
  if (e.target.value == 1) {
    $(this).parent().find('.js__pickup').removeClass('hidden')
  }
  if (e.target.value == 2 || e.target.value == 3) {
    $(this).parent().find('.js__delivery-address').removeClass('hidden')
  }
  if (e.target.value == 99) {
    $(this).parent().find('.js__delivery-other').removeClass('hidden')
  }
});
