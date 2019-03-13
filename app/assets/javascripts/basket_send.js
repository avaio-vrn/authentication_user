$(document).ready(function() {
  if (yaMetrikaExists()) {
    window["yaCounter" + TS.vars.ymetrika].reachGoal('cart.Send')
  }
})
