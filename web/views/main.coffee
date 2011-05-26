$ ->
  update = (param) ->
    $dat = $('.moviesList .movie')
    $dat = $dat.filter("[#{param}='#{param}']") if param

    # Too much quicksand makes the browser unhappy
    if $dat.length < 30
      $('.moviesDisplay').quicksand $dat,
        adjustHeight: 'auto'
        duration: 600
        easing: 'swing'
        useScaling: false
    else
      $('.moviesDisplay').css('height', 'auto').empty().append $dat.clone()

  $catLinks = $('.catLinks .catLink')
  $catLinks.click (event) ->
    event.preventDefault
    $catLinks.removeClass('active')
    $(event.target).addClass('active')
    update('data-' + $(event.target).attr 'data-param')

  $('.controlLinks .toggleThumbs').click (event) ->
    event.preventDefault
    $('.moviesDisplay .poster').toggle


  # Use css to show/hide the info box
  $('.moviesDisplay').delegate '.movie.withPoster', 'hover', (e) ->
    $t = $(this)
    $poster = $t.find('.poster')
    if $poster.length > 0
      $t.find('.details').width($poster.width())
        .height($poster.height())
    $t.toggleClass('hover')
