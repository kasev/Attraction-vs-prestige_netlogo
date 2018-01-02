breed [households household]
breed [prophets prophet]


turtles-own [  ]
patches-own [ 
  
  prestige
  
   ]

households-own [ 
  attraction
  
  openness
  
  probablity_of_innovation
  
  age
  
  conversion_count
]

prophets-own [ 
  ;;premistuje se nahodne mezi domacnostmi
  ;; v kazde domacnosti se zdrzi od 5-10 ticku
  ;; kdyz se zmena praxe potka s pritomnym prorotek > pak se prijme praxe proroka 
  
  attraction
  charisma
   
  weeks_spent_inhousehold
  weeks_planned_stay
  

  
  ]


globals [
  
  ;;prestige tickets
  p0 p1 p2 p3
  
  
 
]



to initialize-variables
  ;; initialize all the variables
  
  set p1 25 * ((count patches) / 100)
  set p2 12 * ((count patches) / 100)
  set p3 3 * ((count patches) / 100)

end


;;**************************SETUP*********************************
to setup
  clear-all
  initialize-variables
  ask patches [ 

    setup-prestige

    create-household 
    
    born-prophet

    ]
  reset-ticks
end



;;****************************GO*********************************
to go  
  ask households [
   update-household
  ]
  ask prophets [
    update-prophet
  ]
  tick
 
end





;;*************************************************************
to born-prophet  ;; patch procedure
  
  if (count prophets < prophets_limit)[
    sprout-prophets 1 [
      set shape "person"
      set attraction random 10
      set color attraction-color (attraction)
    ]
  ]
  
end

;;*************************************************************
to create-household  ;; patch procedure
  sprout-households 1 [    
    set shape "house"    
    set attraction random 10
    set color attraction-color (attraction)
    
    set label-color 67
    set label openness    
  ]
end


;;*************************************************************
to setup-prestige    ;; patch procedure
  
  let prestige_level 0;
  set prestige_level random 3
  set prestige_level prestige_level + 1
 
  if (prestige_level = 1 AND p1 > 0) [
    set p1 p1 - 1
    set prestige 1    
     ] 
  if (prestige_level = 2 AND p2 > 0) [ 
    set p2 p2 - 1
    set prestige 2   
    ] 
  if (prestige_level = 3 AND p3 > 0) [
    set p3 p3 - 1
    set prestige 3        
     ] 
  
  
  set pcolor prestige-color prestige
end



;;*************************************************************
to-report attraction-color [a]
  if (a = 0) [report 9.9]
  if (a = 1) [report 9]
  if (a = 2) [report 8]
  if (a = 3) [report 7]
  if (a = 4) [report 6]
  if (a = 5) [report 5]
  if (a = 6) [report 4]
  if (a = 7) [report 3]
  if (a = 8) [report 2]
  if (a = 9) [report 1]
  if (a = 10) [report 0]
end



;;*************************************************************
to-report prestige-color [p]
  if (p = 0) [report 12]
  if (p = 1) [report 13]
  if (p = 2) [report 14]
  if (p = 3) [report 45]
end



;;*************************************************************
to-report random-color
  report one-of [red blue yellow green]
end




;;***************************************************************
to update-household  
  
  update-age
  update-openness
  
  set label precision openness 3
  
  ;; kdy dojde k prijmuti inovace  
  set probablity_of_innovation openness / 10  
   
  ;; if prorok here, then make openness higher
  if (count prophets-here > 0) [
    
  ]
  
  ;; old way
  ;;if (openness > 1) [    
  ;;  change-practice
  ;;]
    
  
  ;;new way
  if (openness > 0)[
    let conversion_event  0
    set conversion_event random (1 / probablity_of_innovation)
    
    ;;type "Probability of innovation" show probablity_of_innovation
    
    if (conversion_event = 0) [
      change-practice
    ]
  ]
  
end



;;***************************************************************
to update-prophet  
;; weeks_spent_inhousehold
;; weeks_planned_stay

   initialize-prophet
    
   ;; napisu do deniku, ze dalsi den v houshold
   set weeks_spent_inhousehold weeks_spent_inhousehold + 1
   
   
   if (weeks_spent_inhousehold > weeks_planned_stay) [
     move-prophet
   ]
  
end


to initialize-prophet
  ;; pokud nemam plan, dam si plan (pocatek pobytu v household)
  if (weeks_planned_stay < 1) [
    set weeks_planned_stay random number_of_planned_weeks_for_stay 
    set weeks_planned_stay weeks_planned_stay + 5
  ]
end


to move-prophet   
 move-to one-of neighbors 
 set weeks_planned_stay 0
 set weeks_spent_inhousehold 0
end





;;***************************************************************
to-report get_openness[a] 
  let temp 0
  ask household a [
    set temp openness   
  ]  
  report temp
end



;;***************************************************************
to update-age
  
  set age age + 1
  
end



;;***************************************************************
to update-openness 
  
  if (attraction = 10 ) [ set openness openness + 0.1 ]
  if (attraction = 9 ) [ set openness openness + 0.09 ]
  if (attraction = 8 ) [ set openness openness + 0.08 ]
  if (attraction = 7 ) [ set openness openness + 0.07 ]
  if (attraction = 6 ) [ set openness openness + 0.06 ]
  if (attraction = 5 ) [ set openness openness + 0.05 ]
  if (attraction = 4 ) [ set openness openness + 0.04 ]
  if (attraction = 3 ) [ set openness openness + 0.03 ]
  if (attraction = 2 ) [ set openness openness + 0.02 ]
  if (attraction = 1 ) [ set openness openness + 0.01 ]
  
  ;; rigidity influence
  ;; changes openness
  if (age > 20) [set openness (openness - 0.05)] 
  
  ;; absolutni strop pro openess je 1
  if (openness > 1) [ set openness 1 ]
  ;; miniminalni hodnota  pro openess je 1
  if (openness < 0.01) [ set openness 0.01 ]
    
end 
  


;;***************************************************************
to change-practice
 set openness 0 
 set age 0
 
 set conversion_count conversion_count + 1
  
  ifelse (count prophets-here > 0) 
  [ set attraction dwelling-prophet-practice ]
  [ set attraction neighbour-practice ]
  
  
 set color attraction-color (attraction)
end



;;***************************************************************
to-report dwelling-prophet-practice
  type "Changing practice for prophet...a=" show attraction
  let foreign_attraction 0
  
  ask one-of prophets-here[
     set foreign_attraction attraction
  ]  
 
  report foreign_attraction
end  


;;***************************************************************
to-report neighbour-practice
  ;;type "Changing practice for neighbour FROM a=" type attraction
  let foreign_attraction 0
  
  let original_attraction attraction
  let giver_prestige 0
  
  
  ;; ctu globalni parametr prestige_influence a podle toho volim zpusob nalezeni souseda  
  
  if (prestige_influence = "none")[
  ;;PRESTIGE: NONE
  ask one-of neighbors [
    set giver_prestige prestige  
    ask one-of turtles-here[           
      set foreign_attraction attraction      
    ]
  ]]  
  
  if (prestige_influence = "parametrical")[
  ;;PRESTIGE: CONTINUOUS 
  ;;postupny narust vlivu prestize podle parametru prestige_parametrical
  let np0 0
  let np1 0
  let np2 0
  let np3 0
  let randomChoice random 99 + 1 ;; vzdy hazim stostennkou kostkou
  
  ask neighbors [  
    if (prestige = 0) [set np0 np0 + 1]
    if (prestige = 1) [set np1 np1 + 1]
    if (prestige = 2) [set np2 np2 + 1]
    if (prestige = 3) [set np3 np3 + 1]
  ]
  
  ;;standardni range, kde nehraje roli prestige
  let rangeTrashold1 0 let rangeTrashold2 0 let rangeTrashold3 0 let rangeTrashold4 0
  let range0 12.5 * np0 
  let range1 12.5 * np1 
  let range2 12.5 * np2 
  let range3 12.5 * np3
  
  ;; range0 + range1 +  range2 + range3 = 100
  
  ;;modifikace pravdepodobnosti
  set range0 range0 * (1 + (prestigeRecodeContinuous(0) / 10) * 1)
  set range1 range1 * (1 + (prestigeRecodeContinuous(1) / 10) * (1 + (prestige_parametrical / 100)))
  set range2 range2 * (1 + (prestigeRecodeContinuous(2) / 10) * (1 + (prestige_parametrical / 100)))
  set range3 range3 * (1 + (prestigeRecodeContinuous(3) / 10) * (1 + (prestige_parametrical / 100)))
  
  ;;hledam ze ktere skupiny budu vybirat a pak vyberu
  if (randomChoice < range3 AND foreign_attraction = 0)[ ask one-of neighbors with [prestige = 3] [  set giver_prestige prestige ask one-of households-here [ set foreign_attraction attraction ]    ]  show "Go 1"]
  if (randomChoice < (range3 + range2) AND foreign_attraction = 0 AND (count neighbors with [prestige = 2] > 0)) [ ask one-of neighbors with [prestige = 2] [  set giver_prestige prestige ask one-of households-here [ set foreign_attraction attraction ]    ] show "Go 2"]
  if (randomChoice < (range3 + range2 + range1)  AND foreign_attraction = 0 AND (count neighbors with [prestige = 1] > 0))[ ask one-of neighbors with [prestige = 1] [  set giver_prestige prestige ask one-of households-here [ set foreign_attraction attraction ]    ]show "Go 3"]
  if (randomChoice < (range3 + range2 + range1 + range0) AND foreign_attraction = 0)[ ask one-of neighbors with [prestige = 0] [  set giver_prestige prestige ask one-of households-here [ set foreign_attraction attraction ]    ]show "Go 4"]
  
  ] 
  
  if (prestige_influence = "fixed 1")[
  ;;PRESTIGE: FIXED 1
  let prestigeSum 0
  let prestigeCurrent 0
  let randomChoice 0
   
  ;;prvni cyklus sousedu, ziskam "kostku"
  ask neighbors [  
      set prestigeSum prestigeSum + prestigeRecodeFixed1(prestige)
  ]
  
  ;;hodim kostkou
  set randomChoice random prestigeSum
  
  ;;vyberu podle hodu okolni patch
  ask neighbors [   
    set prestigeCurrent prestigeCurrent + prestigeRecodeFixed1(prestige)    
    if (randomChoice < prestigeCurrent) [
      set giver_prestige prestige
      ask one-of households-here [
        set foreign_attraction attraction 
      ]
    ]
  ]  
  ] 
  
  if (prestige_influence = "fixed 2")[
  ;;PRESTIGE: FIXED 2 - kasle na prestige 0
  let prestigeSum 0
  let prestigeCurrent 0
  let randomChoice 0
   
  ;;prvni cyklus sousedu, ziskam "kostku"
  ask neighbors [  
      set prestigeSum prestigeSum + prestigeRecodeFixed2(prestige)
  ]
  
  ;;hodim kostkou
  set randomChoice random prestigeSum
  
  ;;vyberu podle hodu okolni patch
  ask neighbors with [prestige > 0] [
    set giver_prestige prestige   
    set prestigeCurrent prestigeCurrent + prestigeRecodeFixed1(prestige)    
    if (randomChoice < prestigeCurrent) [
      ask one-of households-here [
        set foreign_attraction attraction 
      ]
    ]
  ]  
  ] 
  
  if (prestige_influence = "absolute")[
  ;;PRESTIGE: ABSOLUTE  
  ask neighbors with-max [prestige][
     set giver_prestige prestige
     ask households-here with-max [attraction][           
        set foreign_attraction attraction          
     ]
  ]] 
  
  
  ;;type "to a=" show foreign_attraction
  
 ;; switch - take into account high_prestige_closeness 
 ifelse (high_prestige_closeness) 
    [
      ifelse (prestige < giver_prestige) 
      [ ;;show "Giving up to Higher Prestige" 
        report foreign_attraction ]
      [ ;;show "High Prestige In Action" 
        report original_attraction ]
      ] 
    [ ;;show "N" 
      report foreign_attraction ]
end  


to-report prestigeRecodeContinuous [p]
      if (p = 0) [report 0]
      if (p = 1) [report 1]
      if (p = 2) [report 2]
      if (p = 3) [report 4]
end



to-report prestigeRecodeFixed1 [p]
      if (p = 0) [report 1]
      if (p = 1) [report 2]
      if (p = 2) [report 4]
      if (p = 3) [report 8]
end


to-report prestigeRecodeFixed2 [p]
      if (p = 0) [report 0]
      if (p = 1) [report 2]
      if (p = 2) [report 4]
      if (p = 3) [report 8]
end


  
@#$#@#$#@
GRAPHICS-WINDOW
472
10
842
401
4
4
40.0
1
17
1
1
1
0
1
1
1
-4
4
-4
4
1
1
1
ticks
30.0

BUTTON
14
28
78
61
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
15
68
78
101
go
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
93
10
265
43
prophets_limit
prophets_limit
0
10
5
1
1
NIL
HORIZONTAL

PLOT
19
134
423
410
Number of households with given values of attraction
time
number of households
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"a=0" 1.0 0 -1264960 true "" "plot count households with [attraction = 0]"
"a=1" 1.0 0 -7500403 true "" "plot count households with [attraction = 1]"
"a=2" 1.0 0 -2674135 true "" "plot count households with [attraction = 2]"
"a=3" 1.0 0 -955883 true "" "plot count households with [attraction = 3]"
"a=4" 1.0 0 -6459832 true "" "plot count households with [attraction = 4]"
"a=5" 1.0 0 -1184463 true "" "plot count households with [attraction = 5]"
"a=6" 1.0 0 -10899396 true "" "plot count households with [attraction = 6]"
"a=7" 1.0 0 -13840069 true "" "plot count households with [attraction = 7]"
"a=8" 1.0 0 -14835848 true "" "plot count households with [attraction = 8]"
"a=9" 1.0 0 -11221820 true "" "plot count households with [attraction = 9]"
"a=10" 1.0 0 -16777216 true "" "plot count households with [attraction = 10]"

MONITOR
854
12
914
57
H(a = 0)
count households with [attraction = 0]
17
1
11

MONITOR
857
66
914
111
H(a=1)
count households with [attraction = 1]
17
1
11

MONITOR
858
121
915
166
H(a=2)
count households with [attraction = 2]
17
1
11

MONITOR
858
174
915
219
H
count households
17
1
11

SLIDER
91
50
347
83
number_of_planned_weeks_for_stay
number_of_planned_weeks_for_stay
0
100
10
1
1
NIL
HORIZONTAL

CHOOSER
94
88
232
133
prestige_influence
prestige_influence
"none" "parametrical" "fixed 1" "fixed 2" "absolute"
0

SWITCH
277
50
441
83
high_prestige_closeness
high_prestige_closeness
1
1
-1000

SLIDER
274
10
446
43
prestige_parametrical
prestige_parametrical
0
500
500
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment test" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count households with [attractivity = 0]</metric>
    <enumeratedValueSet variable="Prophets_limit">
      <value value="0"/>
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
