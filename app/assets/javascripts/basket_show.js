document.addEventListener('client.ts_async.loaded', function() {
  if (yaMetrikaExists()) {
    window["yaCounter" + TS.vars.ymetrika].reachGoal('cart.Show')
  }
})
