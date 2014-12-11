class ig.Map
  (@baseElement, @data) ->
    @createMap!

  setView: (field) ->
    @updateScale field
    @currentStyle = (feature) ~>
      id = feature.properties.id
      bin = @data[id]
      color = null
      if bin
        value = bin[field]
        if value
          color = @scale value
        fillOpacity = 0.7
        fill = yes
      if !color
        color = '#ddd'
        fill = no
      weight = 1
      opacity = 1
      {color, weight, fillOpacity, fill, opacity}
    if @grid
      @grid.setStyle @currentStyle
    else
      @createGrid!

  updateScale: (field) ->
    if "dojezdy" is field.substr 0, 7
      @scale = d3.scale.quantize!
      @scale.range ['rgb(255,245,240)','rgb(254,224,210)','rgb(252,187,161)','rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(165,15,21)','rgb(103,0,13)']
      values = for id, datum of @data
        datum[field]
      @scale.domain d3.extent values
    else
      colors = ['rgb(215,48,39)','rgb(244,109,67)','rgb(253,174,97)','rgb(254,224,144)','rgb(224,243,248)','rgb(171,217,233)','rgb(116,173,209)','rgb(69,117,180)']
      colors.reverse!
      colors = ['rgb(255,245,240)','rgb(254,224,210)','rgb(252,187,161)','rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(165,15,21)','rgb(103,0,13)']
      values = for id, datum of @data
        datum[field]
      values .= filter -> it > 0
      values.sort (a, b) -> a - b
      colorsLength = colors.length
      valuesLength = values.length - 1
      thresholds = for i in [1 til colorsLength]
        values[Math.round valuesLength * i / colorsLength]

      @scale = d3.scale.threshold!
        ..domain thresholds
        ..range colors


  createGrid: ->
    @geoJson = topojson.feature ig.data.grid, ig.data.grid.objects."data"
    @grid = L.geoJson @geoJson, style: @currentStyle
    @map.addLayer @grid

  createMap: ->
    @mapElement =  document.createElement \div
      ..id = "map"
    @baseElement.appendChild @mapElement
    maxBounds = [[49.94,14.24], [50.18,14.7]]
    center = [50.0845, 14.496]
    zoom = 12
    @map = L.map do
      * @mapElement
      * minZoom: 11,
        maxZoom: 18,
        zoom: zoom,
        center: center
        maxBounds: maxBounds

    baseLayer = L.tileLayer do
      * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
      * zIndex: 1
        opacity: 1
        attribution: 'mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

    labelLayer = L.tileLayer do
      * "https://samizdat.cz/tiles/ton_l1/{z}/{x}/{y}.png"
      * zIndex: 3
        opacity: 0.75
    @map.addLayer baseLayer
    @map.addLayer labelLayer
