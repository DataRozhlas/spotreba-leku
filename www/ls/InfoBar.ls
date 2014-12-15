class ig.InfoBar
  itemHeight: 104
  (@baseElement, @geoJson, @fields) ->
    ig.Events @
    @element = @baseElement.append \div
      ..attr \id \infoBar
    @height = @element.node!offsetHeight
    @optimalOffset = Math.round @height / 2 - @itemHeight / 2
    @header = @element.append \h2
      ..html ""
    itemsContainer = @element.append \div
      ..attr \class \items
      ..style \height "#{@fields.length * @itemHeight}px"
    self = @
    @items = itemsContainer.selectAll \.item .data @fields .enter!append \div
      ..attr \class "item"
      ..append \h3
        ..append \span
          ..attr \class \order
        ..append \span
          ..attr \class \content
          ..html (.name)
      ..append \div
        ..attr \class \stats
        ..append \div
          ..attr \class "stat count"
          ..append \h4 .html "Případů"
          ..append \span

        ..append \div
          ..attr \class "stat share"
          ..append \h4 .html "Podíl"
          ..append \span
        ..append \div
          ..attr \class "stat time"
          ..append \h4 .html "Prům. dojezd"
          ..append \span

      ..on \mousedown -> d3.event.preventDefault!
      ..on \click ->
        self.items.classed \active no
        @className += " active"
        self.emit \clicked it
        self.selectedFieldIndex = it.defaultIndex
    @selectedFieldIndex = 0
    @items
      .filter (d, i) ~> i is @selectedFieldIndex
      .classed \active yes
    for field, index in @fields
      field.index = field.defaultIndex = index



    @itmCount = @items.selectAll ".stats .stat.count span"
    @itmShare = @items.selectAll ".stats .stat.share span"
    @itmTime = @items.selectAll ".stats .stat.time span"
    @itmOrder = @items
      .filter (d, i) -> i >= 2
      .selectAll "span.order"
    @drawGeneral!

  drawGeneral: ->
    @element.classed \detail no
    @items.style \top ~> "#{it.defaultIndex * @itemHeight}px"
    @itmCount.html -> ig.utils.formatNumber it.sum
    @itmShare.html ~>
      toPercent it.sum / @fields[0].sum

    @itmTime.html ~>
      toTime it.avgTime
    @itmOrder.html -> "#{it.defaultIndex - 1}. "

  drawCell: (feature) ->
    paddingTop = 30
    @element.classed \detail yes
    @header.html "Oblast <b>#{feature.properties.NAZ_ZSJ}</b>"
    @fields.sort (a, b) ->
      d = (feature.data?[b.codeToField] || 0) - (feature.data?[a.codeToField] || 0)
      return d if d
      if b.codeToField > a.codeToField
        return 1
      else
        return -1

    index = 2
    selectedIndex = null
    for field in @fields
      if !field.isDojezd
        field.index = index++
      if field.defaultIndex is @selectedFieldIndex
        selectedIndex = field.index
    if @selectedFieldIndex >= 2
      futureTop = paddingTop + selectedIndex * @itemHeight
      scroll = @element.node!scrollTop
      futureOffset = futureTop - scroll
      centering = @optimalOffset - futureOffset
    else
      centering = 0
    @items.style \top ~> "#{paddingTop + centering + it.index * @itemHeight}px"
    @itmCount.html ~>
      return "&ndash;" if not feature.data
      ig.utils.formatNumber feature.data[it.codeToField]
    @itmShare.html ~>
      return "&ndash;" if not feature.data
      toPercent feature.data[it.codeToField] / feature.data['count_all']
    @itmTime.html ~>
      return "&ndash;" if not feature.data
      fieldId =
        | !it.isDojezd => it.codeToField + "_time"
        | otherwise => it.code
      toTime feature.data[fieldId]
    @itmOrder.html -> "#{it.index - 1}. "

toPercent = (perc) ->
  perc *= 100
  decimals =
    | perc == 100 => 0
    | perc >= 10 => 1
    | otherwise => 2
  "#{ig.utils.formatNumber perc, decimals} %"

toTime = (minutesFloat) ->
  minutes = Math.floor(minutesFloat).toString!
  seconds = Math.round(minutesFloat % 1 * 60).toString!
  if minutes.length == 1 then minutes = "0#minutes"
  if seconds.length == 1 then seconds = "0#seconds"
  "#minutes:#seconds"
