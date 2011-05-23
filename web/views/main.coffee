$ ->
  update = (param) ->
    dat = $('.moviesList .movie')
    dat = dat.filter("[#{param}='#{param}']") if param

    $('.moviesDisplay').quicksand dat,
      adjustHeight: 'dynamic'
      duration: 600
      easing: 'swing'

  update

  $('.catLinks .catLink').click (event) ->
    event.preventDefault

    update('data-' + $(event.target).attr 'data-param')
