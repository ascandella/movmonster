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
    for ftype,value of filters
      for fKey, fValue of filters[ftype]
        $dat = $dat.filter("[data-#{ftype}-#{fKey}='data-#{ftype}-#{fKey}']") if filters[ftype][fKey]
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

  hoveringOn = null
  hoverTimer = null
  $showing = null
  $detailsList = $('.detailsList')
  showHoverDetails = ($movie) ->
    id = $movie.attr('data-id')
    # See if we've already fetched the large image
    $showing = $detailsList.find(".detailBox[data-id='#{id}']")
    if $showing.length > 0
      $showing.addClass('active')
      return

    [best, width] = [null, 0]
    for poster in JSON.parse $movie.attr('data-posters')
      [best, width] = [poster, poster.width] if poster.width > width
    # hacky
    location = best.location.replace('web/public/', '')
    $showing = $("<div class='detailBox' data-id='#{id}'/>")
      .append($("<img src='#{location}'/>").load ->
        $showing.addClass('active'))
      .append($movie.find('.details').clone()
        .height("#{best.height}px")
        .width("#{best.width}px"))
      .appendTo $detailsList


  # Use css to show/hide the info box
  $('.moviesDisplay').delegate '.movie.withPoster', 'hover', (e) ->
    $t = $(this)
    $poster = $t.find('.poster')
    id = $t.attr('data-id')
    # Hover out
    if hoveringOn == id
      hoveringOn = null
      $showing.removeClass('active') if $showing
      clearTimeout(hoverTimer)
    else
      hoverTimer = setTimeout (-> showHoverDetails $t), 350
    hoveringOn = $t.attr('data-id')
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
 
  $preview = $('.intro .status .preview')
  lazyLoadPoster = ($movie) ->
    if !$movie.hasClass('loading')
      $movie.addClass('loading')
        .find('.poster')
          .attr('src', $movie.attr('data-thumb-src'))
          .load ->
            loaded++
            updateLoadProgress()
            $preview.find('.poster').replaceWith $(this).clone()
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
    # Grab the hidden ones too
    $('.movie').css('margin', Math.floor(margin_sum / ideal_per_row) / 2)
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

