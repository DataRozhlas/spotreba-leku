require! {
  fs
}
sums =
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
zsj_assoc = {}
lines = fs.readFileSync "#__dirname/../data/points_binned_clean.tsv" .toString!split "\n"
# lines.length = 10
for line, index in lines
  continue unless index

  [..._, duvod_full, duvod, dojezd, zsjCode, nazZsj, binId] = line.split "\t"
  if zsj_assoc[binId] is void
    zsj_assoc[binId] = {binId, dojezdy_all: [], dojezdy_urgent:[], dojezdy_very_urgent: [], count_all: 0, count_urgent: 0, count_very_urgent: 0}
    for sum in sums
      zsj_assoc[binId][sum] = 0
    for sum in sums
      zsj_assoc[binId][sum + "_time"] = []
  zsj = zsj_assoc[binId]
  dojezd = parseFloat (dojezd || "").replace "," "."
  if zsj[duvod] != void
    zsj[duvod]++
    zsj[duvod + "_time"].push dojezd
  zsj.dojezdy_all.push dojezd
  zsj.count_all++
  if not duvod_full.match /-$/
    zsj.dojezdy_urgent.push dojezd
    zsj.count_urgent++
  if -1 != duvod_full.indexOf '+'
    zsj.dojezdy_very_urgent.push dojezd
    zsj.count_very_urgent++

out_rows = for zsj, data of zsj_assoc
  items = for item, value of data
    if 'Array' is typeof! value
      if value.length
        value.sort (a, b) -> a - b
        median = value[Math.floor value.length / 2]
        median
        # if median.toString!split "." ?1.length > 2
        #   median.toFixed 2
        # else
        #   median
      else
        0
    else
      value
  items.join "\t"

header = for key of zsj_assoc['1893']
  key
out_rows.unshift header.join "\t"
# console.log out_rows.join "\n"
fs.writeFile "#__dirname/../data/binned.tsv", out_rows.join "\n"
