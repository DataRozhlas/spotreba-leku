colors =
  ['rgb(255,245,240)','rgb(254,224,210)','rgb(252,187,161)','rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(165,15,21)','rgb(103,0,13)']
  ['rgb(252,251,253)','rgb(239,237,245)','rgb(218,218,235)','rgb(188,189,220)','rgb(158,154,200)','rgb(128,125,186)','rgb(106,81,163)','rgb(84,39,143)','rgb(63,0,125)']

assignments = [1 0 1 2 3 3 4 5 6 6 7 8]
class ig.Legend
  (@baseElement, features) ->
    features = features.filter ->
      it.properties.id in [1247 1248 1282 1283 1319 1320 1354 1355 1391 1392 1426 1427]
    @element = @baseElement.append \div
      ..attr \class \legend
    width = 80
    {width, height, projection} = ig.utils.geo.getFittingProjection features, width

    path = d3.geo.path!
      ..projection projection
    @svgs = @element.selectAll \div .data colors .enter!append \div
      ..attr \class \line
      ..append \div
        .html (d, i) ->
          if i == 0 then "Rychlejší" else "Méně<br>případů"
      ..append \svg
        ..attr \width width
        ..attr \height height
        ..selectAll \path .data features .enter!append \path
          ..attr \d path
          ..attr \fill (d, i, ii) ~> colors[ii][assignments[i]]

      ..append \div
        .html (d, i) ->
          if i == 0 then "Pomalejší" else "Více<br>případů"

  setCount: ->
    @element.classed \count it
