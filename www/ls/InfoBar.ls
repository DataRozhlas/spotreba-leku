class ig.InfoBar
  (@baseElement, fields) ->
    ig.Events @
    @fields = fields.slice 7 .map (name) -> {name}
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
      ..on \click ->
        self.items.classed \active no
        @className += " active"
        self.emit \clicked it


