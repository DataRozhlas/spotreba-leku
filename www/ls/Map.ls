class ig.Map
  (@baseElement, @geoJson, @data) ->
    @createMap!

  setView: (field) ->
    @currentStyle = (feature) ~>
      feature.styles[field]
    if @grid
      @grid.setStyle @currentStyle
    else
      @createGrid!

  createGrid: ->
    @grid = L.geoJson @geoJson, style: @currentStyle
    @map.addLayer @grid

  createMap: ->
    @mapElement =  document.createElement \div
      ..id = "map"
    @baseElement.appendChild @mapElement
    maxBounds = [[49.94,14.24], [50.18,14.94]]
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
