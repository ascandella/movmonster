$ ->
  filters = {}
  update =  ->
    $dat = $('.moviesList .movie')
    for key,value of filters
      $dat = $dat.filter("[data-#{key}='data-#{key}']")

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
    catname = $(event.target).attr 'data-param'
    $catLinks.removeClass('active')
    $(event.target).addClass('active')
    $catLinks.siblings('.catChecker')
      .prop('checked', false)
      .filter('.catNamed' + catname)
      .prop('checked', true)
    filters = {}
    filters[catname] = true
    update()

  $('.catLinks .catChecker').click (event) ->
    $t = $(event.target)
    if $t.is(':checked')
      filters[$(event.target).attr('data-param')] = true
    else
      delete filters[$(event.target).attr('data-param')]
    update()

  $('.controlLinks .toggleThumbs').click (event) ->
    event.preventDefault
    $('.moviesDisplay .poster').toggle


  # Use css to show/hide the info box
  $('.moviesDisplay').delegate '.movie.withPoster', 'hover', (e) ->
    $t = $(this)
    $poster = $t.find('.poster')
    $t.find('.details').width($poster.width())
      .height($poster.height())
    $t.toggleClass('hover')
