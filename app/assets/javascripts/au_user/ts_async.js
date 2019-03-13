$('.js__login').click(function() {
  $.ajax({
    url: '/login',
    dataType: 'script'
  })
})

$('.js__reg').click(function() {
  $.ajax({
    url: '/registration',
    dataType: 'script'
  })
})
