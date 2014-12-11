class ig.Map
  (@baseElement, @data) ->
    @scale = d3.scale.linear!
    @dataArray = for binId, datum of @data
      datum
    @createMap!

  setView: (field) ->
    @updateScale field
    @currentStyle = (feature) ~>
      id = feature.properties.id
      bin = @data[id]
      if bin
        value = bin[field]
        color = @scale value
        fillOpacity = 0.7
      else
        color = '#d0d1e6'
        fillOpacity = 0.6
      weight = 1
      {color, weight, fillOpacity}
    if @grid
      @grid.setStyle @currentStyle
    else
      @createGrid!

  updateScale: (field) ->
    if "dojezdy" is field.substr 0, 7
      [min, max] = d3.extent @dataArray.map -> it[field]
      range = ['rgb(255,245,240)','rgb(254,224,210)','rgb(252,187,161)','rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(165,15,21)','rgb(103,0,13)']
      length = range.length
      domain = for i in [0 til length]
        min + (max - min) * i / (length - 1)
      @scale.domain domain
      @scale.range range
    else
      values = for id, datum of @data
        datum[field]


  createGrid: ->
    @geoJson = topojson.feature ig.data.grid, ig.data.grid.objects."data"
    @grid = L.geoJson @geoJson, style: @currentStyle
    @map.addLayer @grid

  createMap: ->
    @mapElement =  document.createElement \div
      ..id = "map"
    @baseElement.appendChild @mapElement
    maxBounds = [[49.94,14.24], [50.18,14.7]]
    center = [50.0845, 14.436]
    zoom = 12
    @map = L.map do
      * @mapElement
      * minZoom: 12,
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
