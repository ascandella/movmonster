$ ->
  filters = {}
  $filterTypes = $('.filters .filterType')
  $filterTypes.each ->
    filters[$(this).attr('data-filterType')] = {}
  console.log(filters)

  update =  ->
    $dat = $('.moviesList .movie')
    for key,value of filters
      for fKey, fValue of filters[key]
        $dat = $dat.filter("[data-#{fKey}='data-#{fKey}']") if filters[key][fKey]

    # Too much quicksand makes the browser unhappy
    if $dat.length < 30
      $('.moviesDisplay').quicksand $dat,
        adjustHeight: 'auto'
        duration: 600
        easing: 'swing'
        useScaling: false
    else
      $('.moviesDisplay').css('height', 'auto').empty().append $dat.clone()
      if $dat.length == 0
        $('.moviesDisplay').append $('.noMovies').clone().removeClass('hide')

  $catLinks = $('.catLinks .catLink')
  $catLinks.click (event) ->
    event.preventDefault
    catname = $(event.target).attr 'data-param'
    $catLinks.siblings('.catChecker')
      .prop('checked', false)
      .filter('.catNamed' + catname)
      .prop('checked', true)
    filters.category = {}
    filters.category[catname] = true
    updateFilterStyles()
    update()

  $('.catLinks .catChecker').click (event) ->
    $t = $(event.target)
    filters.category[$t.attr('data-param')] = $t.is(':checked')
    updateFilterStyles()
    update()

  # $('.controlLinks .toggleThumbs').click (event) ->
  #   event.preventDefault
  #   $('.moviesDisplay .poster').toggle


  # Use css to show/hide the info box
  $('.moviesDisplay').delegate '.movie.withPoster', 'hover', (e) ->
    $t = $(this)
    $poster = $t.find('.poster')
    $t.find('.details').width($poster.width())
      .height($poster.height())
    $t.toggleClass('hover')

  updateFilterStyles = ->
    console.log(filters)
    $filterTypes.each ->
      $filter = $(this)
      ftype = $filter.attr('data-filterType')
      $filter.find('.styledFilter').removeClass('active').each ->
        $t = $(this)
        $t.addClass 'active' if filters[ftype][$t.attr('data-param')]
