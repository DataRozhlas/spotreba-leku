class ig.InfoBar
  (@baseElement, @geoJson, @fields) ->
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
    @drawMinimaps!
    @items
      .filter (d, i) -> i is 0
      .classed \active yes

  drawMinimaps: ->
    width = 60
    {features} = @geoJson
    {width, height, projection} = ig.utils.geo.getFittingProjection features, width
    point = features.0.geometry.coordinates.0.0
    projectedFeatures = for feature in features
      projectedPoints = for point in feature.geometry.coordinates.0
        projection point
      id = feature.properties.id
      styles = feature.styles
      {projectedPoints, id, styles}

    @canvases = @items.append \canvas
      ..attr \width width
      ..attr \height height
      ..each (d, i) ->
        field = d.code
        ctx = @getContext \2d
        for feature in projectedFeatures
          id = feature.id
          ctx.fillStyle = feature.styles[field].color
          ctx.beginPath!
          for point, index in feature.projectedPoints
            if index == 0
              ctx.moveTo point.0, point.1
            else
              ctx.lineTo point.0, point.1
          ctx.closePath!
          ctx.fill!
