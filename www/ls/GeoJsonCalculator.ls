colors = ['rgb(255,245,240)','rgb(254,224,210)','rgb(252,187,161)','rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(165,15,21)','rgb(103,0,13)']
colors2 = ['rgb(252,251,253)','rgb(239,237,245)','rgb(218,218,235)','rgb(188,189,220)','rgb(158,154,200)','rgb(128,125,186)','rgb(106,81,163)','rgb(84,39,143)','rgb(63,0,125)']
dojezdyScale = null
getScale = (field, data) ->
  if "dojezdy" is field.substr 0, 7
    if dojezdyScale
      scale = dojezdyScale
    else
      scale = d3.scale.quantize!
      scale.range colors
      values = for id, datum of data
        datum[field]
      scale.domain d3.extent values
      dojezdyScale := scale
  else
    values = for id, datum of data
      datum[field]
    values .= filter -> it > 0
    values.sort (a, b) -> a - b
    colorsLength = colors2.length
    valuesLength = values.length - 1
    thresholds = for i in [1 til colorsLength]
      values[Math.round valuesLength * i / colorsLength]

    scale = d3.scale.threshold!
      ..domain thresholds
      ..range colors2
  scale

getStyle = (feature, data, scale, field) ->
  id = feature.properties.id
  bin = data[id]
  color = null
  if bin
    value = bin[field]
    if value
      color = scale value
    fillOpacity = 0.7
    fill = yes
  if !color
    color = colors.0
    fillOpacity = 0
    fill = no
  weight = 1
  opacity = 1
  {color, weight, fillOpacity, fill, opacity}

ig.getGeoJson = (infobarFields, binData) ->
  geoJson = topojson.feature ig.data.grid, ig.data.grid.objects."data"
  {features} = geoJson
  for feature in features
    feature.styles ?= {}
  for field in infobarFields
    {code} = field
    scale = getScale code, binData
    for feature in features
      feature.styles[code] = getStyle feature, binData, scale, code
      feature.data = binData[feature.properties.id]
  geoJson
