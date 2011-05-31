$ ->
  filters = {}
  # Note: data- params get downcased
  filterActions =
    category:
      all: ->
        filters.category = {}

  $filterTypes = $('.filters .filterType')

  getFilteredData = ->
    $dat = $('.moviesList .movie')
    for key,value of filters
      for fKey, fValue of filters[key]
        $dat = $dat.filter("[data-#{fKey}='data-#{fKey}']") if filters[key][fKey]
    return $dat

  update =  ->
    $data = getFilteredData()
    cb = -> updateMargins() unless _margins_set
    if $data.length < 30
      $('.moviesDisplay').quicksand $data,
        adjustHeight: 'auto'
        duration: 600
        easing: 'swing'
        useScaling: false
      , cb
    else
      $('.moviesDisplay').css('height', 'auto')
        .empty().append $data.clone()
      cb()
      if $data.length == 0
        $('.moviesDisplay').append($('.noMovies'))
          .clone().fadeIn()

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

  lazyLoadPoster = ($movie) ->
    if !$movie.hasClass('loading')
      $movie.addClass('loading')
        .find('.poster')
          .attr('src', $movie.attr('data-thumb-src'))
          .load ->
            loaded++
            updateLoadProgress()
            $movie.removeClass('lazyLoadNeeded loading')

  $thumbsLoading = $('.moviesList .movie.lazyLoadNeeded')
  $progress = $('.status .progress')
  [toLoad, loaded] = [$thumbsLoading.length, 0]

  updateLoadProgress = ->
    $progress.progressbar 'option', 'value', ((loaded / toLoad) * 100)
    if loaded == toLoad
      $progress.fadeOut()
      # Temp
      filterActions.category.all() if filters.category == {}
      update()
      # $('.filters').fadeIn()

  # *** OCD margin management ***
  _margins_set = false
  [base_inner, base_outer] = [null, null]
  updateMargins = ->
    canvas = $('.moviesDisplay').innerWidth()
    $movies = $('.moviesDisplay .movie')
    return if $movies.length == 0
    $sample = $movies.first()
    base_inner ||= $sample.innerWidth()
    base_outer ||= $sample.outerWidth(true)

    ideal_per_row = Math.floor(canvas / base_outer)
    margin_sum = canvas - (base_inner * ideal_per_row)
    per_movie = Math.floor(margin_sum / ideal_per_row)
    # Grab the hidden ones too
    $('.movie').css('margin', per_movie / 2)
    _margins_set = true

  _resize_timer = null
  $(window).resize ->
    clearTimeout _resize_timer
    _resize_timer = setTimeout updateMargins, 50
  # *** End OCD margining ***

  # *** Fire off document init events ***
  $filterTypes.find('input:checkbox').uniform()
  $thumbsLoading.each -> lazyLoadPoster $(this)
  $progress.progressbar()
  $filterTypes.each -> filters[$(this).attr('data-filterType')] = {}

