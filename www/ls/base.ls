fields =
  "binId"
  "dojezdy_all"
  "dojezdy_urgent"
  "dojezdy_very_urgent"
  "count_all"
  "count_urgent"
  "count_very_urgent"
  "DUŠNOST"
  "ÚRAZ"
  "BOLEST BŘICHA"
  "PÁD"
  "NESP.NEURO. PŘÍZ."
  "JINÉ POT.AK."
  "STENOKARDIE"
  "JINÉ POT./ZH.STAVU"
  "PO KOLAPSU"
  "BEZVĚDOMÍ"
  "NEVOLNOST"
  "BOLEST ZAD "
  "PSYCHÓZA"
  "NAPADENÍ"
  "INTOXIKACE"
  "SOMNOLENCE"
  "KRVÁCENÍ"
  "DN"
  "HYPERT."
  "ARYTMIE"
  "BOLEST DK"
  "TEPLOTA"
  "KŘEČE/PO KŘEČI"
  "K PORODU"
  "BOLEST JINÁ"
colors = ['rgb(255,245,240)','rgb(254,224,210)','rgb(252,187,161)','rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(165,15,21)','rgb(103,0,13)']
getScale = (field, data) ->
  if "dojezdy" is field.substr 0, 7
    scale = d3.scale.quantize!
    scale.range colors
    values = for id, datum of data
      datum[field]
    scale.domain d3.extent values
  else
    values = for id, datum of data
      datum[field]
    values .= filter -> it > 0
    values.sort (a, b) -> a - b
    colorsLength = colors.length
    valuesLength = values.length - 1
    thresholds = for i in [1 til colorsLength]
      values[Math.round valuesLength * i / colorsLength]

    scale = d3.scale.threshold!
      ..domain thresholds
      ..range colors
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
    color = colors.1
    fillOpacity = 0
    fill = no
  weight = 1
  opacity = 1
  {color, weight, fillOpacity, fill, opacity}

binData = {}
for line, lineIndex in ig.data.binData.split "\n"
  continue unless lineIndex
  cells = line.split "\t"
  item = binData[cells.0] = {}
  for field, fieldIndex in fields
    item[field] = parseFloat cells[fieldIndex]
    if fieldIndex > 6
      item[field + "_r"] = item[field] / item["count_all"]
container = d3.select ig.containers.base
geoJson = topojson.feature ig.data.grid, ig.data.grid.objects."data"
{features} = geoJson
infobarFields = (fields[1, 3] ++ fields.slice 7).map (code) ->
  ig.fieldCodesToNames[code]

for feature in features
  feature.styles ?= {}

for field in infobarFields
  {code} = field
  scale = getScale code, binData
  for feature in features
    feature.styles[code] = getStyle feature, binData, scale, code


map = new ig.Map ig.containers.base, geoJson, binData
  ..setView fields.1

infoBar = new ig.InfoBar container, geoJson, infobarFields
  ..on \clicked (field) ~>
    if "dojezdy" == field.code.substr 0, 7
      map.setView field.code
    else
      map.setView field.code
