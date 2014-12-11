class ig.InfoBar
  (@baseElement, @fields) ->
    ig.Events @
    @element = @baseElement.append \div
      ..attr \id \infoBar
    itemsContainer = @element.append \div
      ..attr \class \items
    itemHeight = 60
    self = @
    @items = itemsContainer.selectAll \.item .data @fields .enter!append \div
      ..attr \class "item"
      ..style \top (d, i) ~> "#{i * itemHeight}px"
      ..append \h2 .html (.name)
      ..on \mousedown -> d3.event.preventDefault!
      ..on \click ->
        self.items.classed \active no
        @className += " active"
        self.emit \clicked it
    @items
      .filter (d, i) -> i is 0
      .classed \active yes


