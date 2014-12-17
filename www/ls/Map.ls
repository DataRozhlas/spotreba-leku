class ig.Map
  (@baseElement, @geoJson) ->
    ig.Events @
    @createMap!

  setView: (field) ->
    @currentStyle = (feature) ~>
      feature.styles[field]
    if @grid
      @grid.setStyle @currentStyle
    else
      @createGrid!

  createGrid: ->
    @grid = L.geoJson do
      * @geoJson
      * style: @currentStyle
        onEachFeature: (feature, layer) ~>
          layer.on \mouseover ~>
            @emit \mouseover feature
          layer.on \mouseout ~>
            @emit \mouseout
          layer.on \click ~>
            @emit \click feature
    @map.addLayer @grid
    @highlightPoly = L.polygon do
      * []
      * fill: no
        color: \black
        opacity: 1
    @map.addLayer @highlightPoly

  createMap: ->
    @mapElement =  document.createElement \div
      ..id = "map"
    @baseElement.appendChild @mapElement
    maxBounds = [[49.89,14.14], [50.23,15.04]]
    center = [50.0845, 14.496]
    zoom = 11
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
        attribution: 'data <a href="http://www.zzshmp.cz/" target="_blank">ZZS HMP</a>, mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

    labelLayer = L.tileLayer do
      * "https://samizdat.cz/tiles/ton_l1/{z}/{x}/{y}.png"
      * zIndex: 3
        opacity: 0.75
    @map.addLayer baseLayer
    @map.addLayer labelLayer

  setHighlight: (feature) ->
    if feature
      latLngs = feature.geometry.coordinates.0.map ([lng, lat]) ->
        new L.LatLng lat, lng
      @highlightPoly.setLatLngs latLngs
    else
      @highlightPoly.setLatLngs []
