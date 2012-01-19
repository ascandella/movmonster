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

  hookupHover = ($movies) ->
    $movies.hover (e) ->
      clearTimeout(hoverTimer) if hoverTimer
      $m = $(e.target)
      $m = $m.closest('.movie') unless $m.is('.movie')
      hoverTimer = setTimeout (-> showHoverDetails $m), 100
    , (e) ->
      clearTimeout hoverTimer
      $showing.removeClass('active').fadeOut()
    
  update =  ->
    $data = getFilteredData()
    cb = ->
      updateMargins() unless _margins_set
      hookupHover($('.moviesDisplay .movie'))
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
    group = $filt.data('filter_type')
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
    filters.category[$t.data('param')] = $t.is(':checked')
    updateFilterStyles()
    update()

  hoveringOn = null
  hoverTimer = null
  $showing = null
  $detailsList = $('.detailsList')
  showHoverDetails = ($movie) ->
    $showing.fadeOut().removeClass('active') if $showing
    id = $movie.data('id')
    klass = if $movie.offset().left > ($(window).width() / 2) then 'left' else 'right'
    # See if we've already fetched the large image
    $showing = $detailsList.find(".detailBox[data-id='#{id}']")
    if $showing.length > 0
      $showing.removeClass('left right')
        .hide()
        .addClass("active #{klass}").fadeIn()
      return

    [best, width] = [null, 0]
    for poster in JSON.parse $movie.data('posters')
      [best, width] = [poster, poster.width] if poster.width > width
    # hacky
    if best
      $showing = $("<div class='detailBox' data-id='#{id}'/>")
        .append($("<img src='#{best.web_location}'/>").load ->
          $showing.hide().addClass("active #{klass}").fadeIn())
        .append($movie.find('.details').clone()
          .height("#{best.height}px")
          .width("#{best.width}px"))
        .appendTo $detailsList

  updateFilterStyles = ->
    $filterTypes.each ->
      $filter = $(this)
      ftype = $filter.data('filter_type')
      $filter.find('.styledFilter').removeClass('active').each ->
        $t = $(this)
        $t.addClass 'active' if filters[ftype][$t.data('param')]
 
  $preview = $('.intro .status .preview')
  lazyLoadPoster = ($movie) ->
    if !$movie.hasClass('loading')
      $movie.addClass('loading')
        .find('.poster')
          .attr('src', $movie.data('thumb-src'))
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

  $yearSlider = $('.filterType.year .yearSlider')
  # todo...

  # *** Fire off document init events ***
  $filterTypes.find('input:checkbox').uniform()

  $thumbsLoading.each -> lazyLoadPoster $(this)

  $progress.progressbar()
  $yearSlider.slider min: $yearSlider.data('min'), max: $yearSlider.data('max')

  $filterTypes.each -> filters[$(this).data('filter_type')] = {}

  # *** End document init events ***
