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
    item[field] = parseFloat cells[fieldIndex]
    if fieldIndex > 6
      item[field + "_r"] = item[field] / item["count_all"]
container = d3.select ig.containers.base
map = new ig.Map ig.containers.base, binData
  # ..setView fields.1

infoBar = new ig.InfoBar container, fields
