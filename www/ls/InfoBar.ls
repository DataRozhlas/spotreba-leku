class ig.InfoBar
  (@baseElement, @geoJson, @fields) ->
    ig.Events @
    @element = @baseElement.append \div
      ..attr \id \infoBar
    itemsContainer = @element.append \div
      ..attr \class \items
    itemHeight = 104
    self = @
    @items = itemsContainer.selectAll \.item .data @fields .enter!append \div
      ..attr \class "item"
      ..style \top (d, i) ~> "#{i * itemHeight}px"
      ..append \h2 .html (.name)
      ..append \div
        ..attr \class \stats
        ..append \div
          ..attr \class "stat count"
          ..append \h3 .html "Případů"
          ..append \span

        ..append \div
          ..attr \class "stat share"
          ..append \h3 .html "Podíl"
          ..append \span
        ..append \div
          ..attr \class "stat time"
          ..append \h3 .html "Prům. dojezd"
          ..append \span

      ..on \mousedown -> d3.event.preventDefault!
      ..on \click ->
        self.items.classed \active no
        @className += " active"
        self.emit \clicked it
    @items
      .filter (d, i) -> i is 0
      .classed \active yes

    @itmCount = @items.selectAll ".stats .stat.count span"
    @itmShare = @items.selectAll ".stats .stat.share span"
    @itmTime = @items.selectAll ".stats .stat.time span"
    @drawGeneral!

  drawGeneral: ->
    @itmCount.html -> ig.utils.formatNumber it.sum
    @itmShare.html ~>
      toPercent it.sum / @fields[0].sum

    @itmTime.html ~>
      toTime it.avgTime

  drawCell: (feature) ->
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
