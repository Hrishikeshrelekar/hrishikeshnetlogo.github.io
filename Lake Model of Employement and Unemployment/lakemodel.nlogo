;;turtle own property related to employement
turtles-own [ employed? living?]
;;patches own property related to region
patches-own [ region ]

globals [width_birth height_birth]

to setup
  ca

  ;; defining width and height of the birth and death region
  ;; note that birth region will be always at the top left corner while, death region will be at bottom left corner.
  set width_birth 5
  set height_birth 15

  crt no_of_agents [

    ;; separating the turtles spatially in unemployed region

    setxy (- 1 - random-float (max-pxcor - width_birth - 1)) (random-ycor)

    ;; adding a shape
    set shape "person"

    ;; setting color of all turtles to red
    set color red

    ;; setting employement status of all turtles to false
    set employed? false

    ;; set the living status as true
    set living? true

    ]

  ;; taking fraction of turtles and setting employment status to true
  ;; setting color of those fraction of turtles to blue
  ask n-of round(ini_employ_rt * no_of_agents) turtles [

    set color blue

    ;; Setting their x, y coordinates in employed region

    setxy (1 + random-float (max-pxcor - 1)) (random-ycor)

    set employed? true
  ]

  ;; Draw a boundary separating unemployed and employed region
  draw-region-division

  ;; Draw a boundary separating the birth region
  draw-region-birth-division width_birth height_birth

  ;; Draw a boundary separating the death region
  draw-region-death-division width_birth height_birth

  ;; classifying patches into four regions namely, birth, death, employed, unemployed
  ask patches [

    if(pxcor <  (- max-pxcor + width_birth) and pycor >  (max-pycor - height_birth))[set region "birth"]
    if(pxcor <  (- max-pxcor + width_birth) and pycor <  (- max-pycor + height_birth))[set region "death"]
    if (pxcor >  (- max-pxcor + width_birth) and pxcor <  0)[set region "unemployed"]
    if (pxcor >  0)[set region "employed"]

  ]

  ;; Adding labels to each region
  let birthxmean mean [pxcor] of patches with [ region = "birth" ]
  let birthymean mean [pycor] of patches with [ region = "birth" ]
  ask patch birthxmean birthymean [set plabel "Birth" set plabel-color green]


  let deathxmean mean [pxcor] of patches with [ region = "death" ]
  let deathymean mean [pycor] of patches with [ region = "death" ]

  ask patch deathxmean deathymean [set plabel "Death" set plabel-color white]


  let unemployxmean mean [pxcor] of patches with [ region = "unemployed" ]
  let unemployymean mean [pycor] of patches with [ region = "unemployed" ]

  ask patch unemployxmean unemployymean [set plabel "Unemployed" set plabel-color red]


  let employxmean mean [pxcor] of patches with [ region = "employed" ]
  let employymean mean [pycor] of patches with [ region = "employed" ]

  ask patch employxmean employymean [set plabel "Employed" set plabel-color blue]

  reset-ticks
end


to go

  ;; Initial employment rate for each iteration
  let ini_empl_rt count turtles with [employed?] / count turtles

  ;; Initial number of turtles at the begining of iteration
  let ini_turtles count turtles

  ;; death of turtles based on death_rate
  ask n-of round((count turtles with [employed?]) * death_rate) turtles [

    ;;pen-down
    ;; move them to death region
    move-to one-of patches with [region = "death"]

    ;; set the color of dead turtles to white
    set color white

    ;; change the living status to false
    set living? false


    ;;die

  ]

  ask n-of round((count turtles with [not employed?]) * death_rate) turtles [

    ;;pen-down
    ;; move them to death region
    move-to one-of patches with [region = "death"]

    ;; set the color of dead turtles to white
    set color white

    ;; change the living status to false
    set living? false

    ;;die

  ]

  ;; Employed workers will get fired as per dismissal rate
  ask n-of round((count turtles with [color = blue and living? = true]) * dismissal_rate) turtles [

    ;; setting employement status of these turtles to false
    set employed? false
  ]

  ;; Unemployed workers will get hired as per finding rate
  ask n-of round((count turtles with [color = red and living? = true]) * finding_rate) turtles [

    ;; setting employement status of these turtles to true
    set employed? true
  ]


  ;; birth of new turtles based on birth_rate

  crt round(ini_turtles * birth_rate) [
    ;; separating the turtles spatially

    ;;setxy (- 1 - random-float (max-pxcor - 1)) (random-ycor)
    setxy ((- max-pxcor) + random-float (width_birth - 1)) (max-pycor - random-float (height_birth - 1))
    ;; adding a shape
    set shape "person"

    ;; setting color of newly born turtles to green
    set color green

    ;; setting employement status of newly born turtles to false
    set employed? false

    set living? true
    ]

  ;; ask newly born turtles to go to unemployed region
  ask turtles with [ color = green and living? = true and region = "birth" ] [

    ;;pen-down
    ;; moving them to unemployed region
    move-to one-of patches with [region = "unemployed"]

    ;; setting color red
    set color red

  ]

  ;; set the color according to the turtles property

  ask turtles with [employed? and color = red and living? = true and region = "unemployed"] [

    ;;pen-down
    ;; move them to employed region

    move-to one-of patches with [region = "employed"]

    set color blue


  ]

  ask turtles with [not employed? and color = blue and living? = true and region = "employed"] [

    ;;pen-down
    ;; move them to unemployed region

    move-to one-of patches with [region = "unemployed"]

    set color red

  ]

  ;; ask dead turtles to vanish from environment
  ask turtles with [living? = false and region = "death"][

    die

  ]

  ;; For convergence of model
  let fin_empl_rt count turtles with [employed?] / count turtles

  if (abs(fin_empl_rt - ini_empl_rt) < convergence_tolerance) and convergence  [stop]

  tick
end


to draw-region-division
  ; This procedure makes the division patches grey
  ; and draw a vertical line in the middle. This is
  ; arbitrary and could be modified to your liking.

  create-turtles 1 [
    ; use a temporary turtle to draw a line in the middle of our division
    setxy 0 (- max-pycor)
    set heading 0
    set color grey - 3
    pen-down
    forward world-height
    set xcor xcor + 0.01 / patch-size
    right 180
    set color grey + 3
    forward world-height
    die ; our turtle has done its job and is no longer needed
  ]
end


to draw-region-birth-division [w h]
  ; This procedure makes the division patches grey
  ; and draw a vertical line in the middle. This is
  ; arbitrary and could be modified to your liking.

  create-turtles 1 [
    ; use a temporary turtle to draw a line in the middle of our division
    setxy (- max-pxcor + w) (max-pycor)
    set heading 180
    set color grey + 3
    pen-down
    forward h
    right 90
    forward w

    die ; our turtle has done its job and is no longer needed
  ]
end

to draw-region-death-division [w h]
  ; This procedure makes the division patches grey
  ; and draw a vertical line in the middle. This is
  ; arbitrary and could be modified to your liking.

  create-turtles 1 [
    ; use a temporary turtle to draw a line in the middle of our division
    setxy (- max-pxcor + w) (- max-pycor)
    set heading 0
    set color grey + 3
    pen-down
    forward h
    left 90
    forward w

    die ; our turtle has done its job and is no longer needed
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
436
10
1024
599
-1
-1
17.6
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
8
10
180
43
no_of_agents
no_of_agents
0
200
150.0
1
1
NIL
HORIZONTAL

BUTTON
91
233
186
284
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
208
233
302
284
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
194
11
366
44
ini_employ_rt
ini_employ_rt
0
1
0.92
0.01
1
NIL
HORIZONTAL

PLOT
0
297
211
442
Employment Rate vs Time
Time
Et
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"Employment Rate" 1.0 0 -16777216 true "" "plot (count turtles with [employed?] / count turtles)"

PLOT
220
297
420
443
Unmployment Rate vs Time
Time
Ut
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"Unemployement Rate" 1.0 0 -16777216 true "" "plot (count turtles with [not employed?] / count turtles)"

SLIDER
8
56
180
89
birth_rate
birth_rate
0
1
0.0124
0.01
1
NIL
HORIZONTAL

SLIDER
193
56
365
89
death_rate
death_rate
0
1
0.00822
0.01
1
NIL
HORIZONTAL

SLIDER
9
104
181
137
dismissal_rate
dismissal_rate
0
1
0.013
0.01
1
NIL
HORIZONTAL

SLIDER
192
105
364
138
finding_rate
finding_rate
0
1
0.283
0.01
1
NIL
HORIZONTAL

MONITOR
1
459
211
504
Employment Rate
count turtles with [employed?] / count turtles
4
1
11

MONITOR
221
460
423
505
Unemployment Rate
count turtles with [not employed?] / count turtles
4
1
11

INPUTBOX
28
156
183
216
convergence_tolerance
1.0E-7
1
0
Number

SWITCH
197
170
326
203
Convergence
Convergence
1
1
-1000

TEXTBOX
1033
14
1170
32
Unemployed workers
11
15.0
1

TEXTBOX
1034
38
1171
56
Employed workers
11
105.0
1

TEXTBOX
1041
61
1191
79
Birth
11
65.0
1

TEXTBOX
1038
85
1188
103
Death
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

A lake model of employment and unemployment is a trivial model used for modeling employment / unemployment in an economy. 


## HOW IT WORKS

The economy is inhabited by a very large number of ex-ante identical workers.

Their rates of transition between employment and unemployment are governed by the following parameters:

* the job finding rate for currently unemployed workers

* the dismissal rate for currently employed workers

* the entry rate into the labor force

* the exit rate from the labor force


## HOW TO USE IT

The no_of_agents slider in interface tab determines number of agents considered at the start of the model.

The ini_employ_rt slider considers the initial rate of employment in the model. The employment rate is equal to fraction of agents employed at time t. 

The birth rate slider allows us to control birth rate/ entry rate of agents.

The death rate slider allows us to control death rate/ exit rate of agents.

The finding rate slider allows us to control job finding rate of unemployed pool of agents.

The dismissal rate slider allows us to control dismissal rate of employed pool of agents.

The convergence switch is a switch to automatically turn off the model if it reaches the convergence. The convergence tolerance is defined by convergence_tolerance input. 

## THINGS TO NOTICE

The model is divided in four regions:

* Birth region
* Death region
* Unemployed region
* Employed region

At every time step t, new agents are born according to the birth rate in birth region. 
Similarly, some of existing agents are picked up randomly and moved to death region based on death rate. At the end of step, they die. 
Randomly, few agents were moved from unemployed region to employed region based on finding rate and dismissal rate respectively. 

Theoretically, birth rate/death rate/finding rate/dismissal rate may create fractional agents. As it is not possible in netlogo, we are rounding off the number of agents after each step. 

## THINGS TO TRY

The user should try different parameters values to study conditions for convergence of employment rate. 

In case of birth rate = death rate = 0, the lake model attains the special case of Markov chains leading to convergence for all parameter (rest) values. 

## EXTENDING THE MODEL

An user can try to endogenize the job finding rate or dismissal rate based on existing model in literature. 

An use can refer to McCall Search model for this. 


## RELATED MODELS

* McCall Search Model by McCall
* Modelling Career Choices by Derek Neal

## CREDITS AND REFERENCES

Quant Econ - https://quantecon.org/
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
