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

binData = {}
for line, lineIndex in ig.data.binData.split "\n"
  continue unless lineIndex
  cells = line.split "\t"
  item = binData[cells.0] = {}
  for field, fieldIndex in fields
    item[field] = parseFloat cells[fieldIndex], 10
    if fieldIndex > 6
      ig.fieldCodesToNames[field].sum += item[field]
      time = parseFloat cells[fieldIndex + 25]
      item[field + "_time"] = time
      if time
        ig.fieldCodesToNames[field].timeSum += time
        ig.fieldCodesToNames[field].recordCount++
      item[field + "_r"] = item[field] / item["count_all"]
    else
      continue unless ig.fieldCodesToNames[field]
      count = parseInt cells[fieldIndex + 3], 10
      ig.fieldCodesToNames[field].sum += count
      if item[field]
        ig.fieldCodesToNames[field].timeSum += item[field]
        ig.fieldCodesToNames[field].recordCount++
container = d3.select ig.containers.base
for field, data of ig.fieldCodesToNames
  data.avgTime = data.timeSum / data.recordCount

infobarFields = (fields[1, 3] ++ fields.slice 7).map (code) ->
  ig.fieldCodesToNames[code]

fieldToDisplay = (parseInt (window.location.hash.substr 1), 10) || 0
infobarFields[fieldToDisplay].initiallyDisplayed = yes

geoJson = ig.getGeoJson infobarFields, binData

map = new ig.Map ig.containers.base, geoJson, binData
  ..setView infobarFields[fieldToDisplay].code

lockedFeature = null

infoBar = new ig.InfoBar container, geoJson, infobarFields
  ..on \clicked (field) ~>
    window.location.hash = infobarFields.indexOf field
    if "dojezdy" == field.code.substr 0, 7
      map.setView field.code
      legend.setCount no
    else
      map.setView field.code
      legend.setCount yes
  ..on \unlockRequested ->
    lockedFeature := null
    map.setHighlight null
    infoBar.drawGeneral!

map
  ..on \mouseover (feature) ~>
    return if feature.data is void
    infoBar.drawCell feature
  ..on \mouseout ~> infoBar.drawGeneral!
  ..on \click (feature) ~>
    return if feature.data is void
    if feature != lockedFeature
      map.setHighlight feature
      infoBar.drawCell feature, lock: yes
      lockedFeature := feature
    else
      map.setHighlight null
      infoBar.drawCell feature, lock: no
      lockedFeature := null

geocoder = new ig.Geocoder ig.containers.base
  ..on \latLng (latlng) ->
    map.map.setView latlng, 15

new ig.EmbedLogo ig.containers.base, {dark: yes}
legend = new ig.Legend container, geoJson.features
if fieldToDisplay > 1
  legend.setCount yes
new ig.ShareDialog ig.containers.base
