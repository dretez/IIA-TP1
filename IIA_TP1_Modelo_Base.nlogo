globals [veneno msgx msgy nDeposito ]

turtles-own [
  energia cap recolhido objetivo counter rand
  chargex chargey depx depy targetx targety head dist
]

to setup
  clear-all
  reset-ticks
  setup-patches
  setup-turtles
  set nDeposito 0
end

to go
  if count turtles = 0 or ticks = 10000 or count patches with [pcolor = red] = 0
  [
    stop
  ]
  ask turtles
  [
    move
    comunicar
    check_energia
    morrer
  ]
  tick
end

to setup-patches
  set-patch-size 15
  let canto one-of patches with [pxcor < max-pxcor and pycor < max-pycor and pcolor = black]
  ask canto [
    set pcolor green
    ask patch-at 1 0 [set pcolor green]
    ask patch-at 0 1 [set pcolor green]
    ask patch-at 1 1 [set pcolor green]
  ]

  ask patches[
    if pcolor = black and random 100 < Lixo [set pcolor red]
  ]

  ask n-of Carregadores patches with [pcolor = black] [set pcolor blue]
  ask n-of Obstaculos patches with [pcolor = black] [set pcolor white]
end

to setup-turtles
  create-turtles n_agentes
  [
    set shape "face happy"
    setxy random-pxcor random-pycor
    while [pcolor != black] [setxy random-pxcor random-pycor]
    set color cyan
    set heading 0
    set energia energiaMax
    set cap capMax
    set objetivo "limpar"
    set recolhido 0
    set counter 0
    set chargex 1000
    set chargey 1000
    set depx 1000
    set depy 1000
    set targetx 0
    set targety 0
  ]
end

to turnRand
  ifelse random 1 = 1
  [left 90]
  [right 90]
end

to move
  if counter > 0
  [
    set counter counter - 1
    stop
  ]
  if objetivo = "limpar" [ move_limpar stop ]
  if objetivo = "despejar" [ move_despejar stop ]
  if objetivo = "carregar" [ move_carregar stop ]
end

to move_limpar
  ifelse any? ( neighbors4 with [ pcolor = red ] )
  [
    ask one-of ( neighbors4 with [ pcolor = red ] )
    [
      set msgx pxcor
      set msgy pycor
    ]
    set xcor msgx
    set ycor msgy
    set energia energia - 1
  ]
  [ move_random ]
  recolher
end

to move_despejar
  ifelse depx = 1000 and depy = 1000
  [ move_random ]
  [
    set targetx depx
    set targety depy
    move_to_target
  ]
  if pcolor = green
  [
    set nDeposito nDeposito + recolhido
    set recolhido 0
    set objetivo "limpar"
    set counter tempo_deposito
  ]
end

to move_carregar
  ifelse chargex = 1000 and chargey = 1000
  [ move_random ]
  [
    set targetx chargex
    set targety chargey
    move_to_target
  ]
  if pcolor = blue
  [
    set energia energiaMax
    set color cyan
    set objetivo "limpar"
    set counter tempo_carregar
  ]
end

to move_random
  ifelse random 100 < 10
  [ turnRand ]
  [ move_fd ]
end

to move_to_target
  set dist -1
  set head heading - 180
  calc_move_dist
  calc_move_dist
  calc_move_dist
  move_fd
end

to calc_move_dist
  set head head + 90
  let next-patch patch-at-heading-and-distance head 1


  if next-patch = nobody or [pcolor] of next-patch = white [stop]
  let nextx [pxcor] of next-patch
  let nexty [pycor] of next-patch
  if dist = -1
  [
    set dist (abs (targetx - nextx)) ^ 2 + (abs (targety - nexty)) ^ 2
    set heading head
    stop
  ]
  if ((abs (targetx - nextx)) ^ 2 + (abs (targety - nexty)) ^ 2) < dist
  [
    set dist (abs (targetx - nextx)) ^ 2 + (abs (targety - nexty)) ^ 2
    set heading head
  ]
end

to move_fd
  ; check for patch coordinates to store
  set msgx 1000
  set msgy 1000
  if depx = 1000 and depy = 1000 and any? ( neighbors4 with [ pcolor = green ] )
  [
    ask one-of ( neighbors4 with [ pcolor = green ] )
    [
      set msgx pxcor
      set msgy pycor
    ]
  ]
  if msgx != 1000 and msgy != 1000
  [
    set depx msgx
    set depy msgy
  ]
  set msgx 1000
  set msgy 1000
  if any? ( neighbors4 with [ pcolor = blue ] )
  [
    ask one-of ( neighbors4 with [ pcolor = blue ] )
    [
      set msgx pxcor
      set msgy pycor
    ]
  ]
  if msgx != 1000 and msgy != 1000
  [
    set chargex msgx
    set chargey msgy
  ]

  ; stop robots from crossing obstacles
  ifelse (not can-move? 1) or [pcolor] of patch-ahead 1 = white
  [
    turnRand
    ;move_fd
  ]
  [
    fd 1
    set energia energia - 1
  ]
end

to check_energia
  if objetivo = "carregar" [stop]
  if energia > energiaMin [stop]
  set color red
  set objetivo "carregar"
end

to recolher
  if pcolor = red and recolhido < cap
  [
    ask one-of (patch-set patch-here neighbors4 with [pcolor = red])
    [
      set pcolor black
    ]
    set recolhido recolhido + 1
  ]
  if recolhido = cap [ set objetivo "despejar" ]
end

to comunicar
  if chargex != 1000 and chargey != 1000
  [
    set msgx chargex
    set msgy chargey
    ask turtles-on neighbors4
    [
      set chargex msgx
      set chargey msgy
    ]
  ]
end

to morrer
  if energia < 0
  [
    set pcolor white
    die
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
413
14
886
488
-1
-1
15.0
1
10
1
1
1
0
0
0
1
-15
15
-15
15
0
0
1
ticks
30.0

BUTTON
20
20
90
60
NIL
Setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
20
65
90
105
NIL
Go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
110
20
220
53
Lixo
Lixo
0
60
40.0
1
1
%
HORIZONTAL

SLIDER
110
58
220
91
Obstaculos
Obstaculos
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
110
96
220
129
Carregadores
Carregadores
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
238
19
370
52
n_agentes
n_agentes
1
30
10.0
1
1
NIL
HORIZONTAL

SLIDER
239
59
370
92
energiaMax
energiaMax
0
200
100.0
1
1
NIL
HORIZONTAL

SLIDER
237
135
368
168
capMax
capMax
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
237
177
377
210
tempo_deposito
tempo_deposito
0
200
20.0
1
1
ticks
HORIZONTAL

SLIDER
239
220
378
253
tempo_carregar
tempo_carregar
0
200
20.0
1
1
ticks
HORIZONTAL

SLIDER
238
97
375
130
energiaMin
energiaMin
0
energiaMax
25.0
1
1
NIL
HORIZONTAL

MONITOR
21
142
110
187
Lixo recolhido
nDeposito
0
1
11

MONITOR
128
142
186
187
Lixo
count patches with [pcolor = red]
17
1
11

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Percentagem Lixo" repetitions="10" runMetricsEveryStep="false">
    <setup>Setup</setup>
    <go>Go</go>
    <metric>count turtles</metric>
    <metric>(count patches with [pcolor = red]) / (count patches) * 100</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="n_agentes">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Lixo">
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Capacidade" repetitions="10" runMetricsEveryStep="false">
    <setup>Setup</setup>
    <go>Go</go>
    <metric>count turtles</metric>
    <metric>(count patches with [pcolor = red]) / (count patches) * 100</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="n_agentes">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capMax">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Energia Inicial" repetitions="10" runMetricsEveryStep="false">
    <setup>Setup</setup>
    <go>Go</go>
    <metric>count turtles</metric>
    <metric>(count patches with [pcolor = red]) / (count patches) * 100</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="n_agentes">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaMax">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Energia Minima" repetitions="10" runMetricsEveryStep="false">
    <setup>Setup</setup>
    <go>Go</go>
    <metric>count turtles</metric>
    <metric>(count patches with [pcolor = red]) / (count patches) * 100</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="n_agentes">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaMin">
      <value value="15"/>
      <value value="25"/>
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Comparacao Modelo" repetitions="60" runMetricsEveryStep="false">
    <setup>Setup</setup>
    <go>Go</go>
    <metric>count turtles</metric>
    <metric>(count patches with [pcolor = red]) / (count patches) * 100</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="n_agentes">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Lixo">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
