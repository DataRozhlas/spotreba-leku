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
          ..attr \class \stat
          ..append \h3 .html "Případů"
          ..append \span
            .html -> ig.utils.formatNumber it.sum
        ..append \div
          ..attr \class \stat
          ..append \h3 .html "Podíl"
          ..append \span
            ..html ~>
              perc = it.sum / @fields[0].sum * 100
              decimals =
                | perc == 100 => 0
                | perc >= 10 => 1
                | otherwise => 2
              "#{ig.utils.formatNumber perc, decimals} %"
        ..append \div
          ..attr \class \stat
          ..append \h3 .html "Prům. dojezd"
          ..append \span
            ..html ~>
              minutes = Math.floor(it.avgTime).toString!
              seconds = Math.round(it.avgTime % 1 * 60).toString!
              if minutes.length == 1 then minutes = "0#minutes"
              if seconds.length == 1 then seconds = "0#seconds"
              "#minutes:#seconds"

      ..on \mousedown -> d3.event.preventDefault!
      ..on \click ->
        self.items.classed \active no
        @className += " active"
        self.emit \clicked it
    @items
      .filter (d, i) -> i is 0
      .classed \active yes
