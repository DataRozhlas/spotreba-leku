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
for line, index in ig.data.binData.split "\n"
  continue unless index
  cells = line.split "\t"
  item = binData[cells.0] = {}
  for field, index in fields
    item[field] = parseFloat cells[index]

map = new ig.Map ig.containers.base, binData
  ..setView fields.1
