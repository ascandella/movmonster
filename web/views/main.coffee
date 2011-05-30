$ ->
  filters = {}
  # Note: data- params get downcased
  filterActions =
    category:
      all: ->
        filters.category = {}

  $filterTypes = $('.filters .filterType')
  $filterTypes.each ->
    filters[$(this).attr('data-filterType')] = {}

  update =  ->
    $dat = $('.moviesList .movie')
    for key,value of filters
      for fKey, fValue of filters[key]
        $dat = $dat.filter("[data-#{fKey}='data-#{fKey}']") if filters[key][fKey]

    if $dat.length < 30
      $('.moviesDisplay').quicksand $dat,
        adjustHeight: 'auto'
        duration: 600
        easing: 'swing'
        useScaling: false
    else
      $('.moviesDisplay').css('height', 'auto').empty().append $dat.clone()
      if $dat.length == 0
        $('.moviesDisplay').append $('.noMovies').clone().fadeIn()

  $filterTypes.find('.actionFilter').click (event) ->
    event.preventDefault()
    $filt = $(this).closest('.filterType')
    group = $filt.attr('data-filter_type')
    item  = $(event.target).attr 'data-param'

    $filt.find('input:checkbox')
      .prop('checked', false)
      .filter("[data-param='#{item}']")
      .prop('checked', true)
    $.uniform.update()

    if filterActions[group][item]
      filterActions[group][item]()
    else
      filters[group] = {}
      filters[group][item] = true
    updateFilterStyles()
    update()

  $('.catLinks .catChecker').click (event) ->
    $t = $(event.target)
    filters.category[$t.attr('data-param')] = $t.is(':checked')
    updateFilterStyles()
    update()

  # Use css to show/hide the info box
  $('.moviesDisplay').delegate '.movie.withPoster', 'hover', (e) ->
    $t = $(this)
    $poster = $t.find('.poster')
    $t.find('.details').width($poster.width())
      .height($poster.height())
    $t.toggleClass('hover')

  updateFilterStyles = ->
    $filterTypes.each ->
      $filter = $(this)
      ftype = $filter.attr('data-filter_type')
      $filter.find('.styledFilter').removeClass('active').each ->
        $t = $(this)
        $t.addClass 'active' if filters[ftype][$t.attr('data-param')]

  $filterTypes.find('input:checkbox').uniform()

  lazyLoadPoster = ($movie) ->
    if !$movie.hasClass('loading')
      $movie.addClass('loading')
        .find('.poster')
          .attr('src', $movie.attr('data-thumb-src'))
          .load ->
            loaded++
            updateLoadText()
            $movie.removeClass('lazyLoadNeeded loading')

  $thumbsLoading = $('.moviesList .movie.lazyLoadNeeded')
  $progress = $('.status .progress')
  [toLoad, loaded] = [$thumbsLoading.length, 0]
  $progress.progressbar()

  updateLoadText = ->
    $progress.progressbar 'option', 'value', ((loaded / toLoad) * 100)
    if loaded == toLoad
      $progress.fadeOut()
      $('.filters').fadeIn()

  $thumbsLoading.each ->
    lazyLoadPoster $(this)

