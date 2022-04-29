breed [nodes node]
breed [hubs hub]
breed[pecks peck]
pecks-own[ customers ]

breed[barters barter]
barters-own [ customers ]

breed [people person]
people-own [location p-home daily-moves p-visits eat?]  ;; holds a node

directed-link-breed [active-links active-link]

patches-own [visits p-type]

globals[
  running?
  flag?
]

;; ************************ PEOPLE BREED METHODS
to people-move
  ask people [
    let agent self
    ;; the person will only randomly move MOVE_PER_DAY per day the return home
    ifelse daily-moves < moves-per-day [
      ;; randomly move
      let targets [out-active-link-neighbors] of location
      if count targets > 0 [
        let new-location one-of targets
        face new-location  ;; not strictly necessary, but improves the visuals a bit
        set location new-location
        set daily-moves daily-moves + 1
     ]
    ][
      ;; go home
      set daily-moves 0
      set eat? false
      set location p-home
    ]  ;; end if
    ;; do the move
    move-to location

    ask patch-here [
      if p-type = "urban" [
        set visits visits + 1
      ]
    ]
    ;; check if there is a Pecks here
    ask pecks-here[
      ;; test if the person has been to outlet that day
      if [eat?] of agent = false [
        set customers customers + 1
        set label  word customers " "
        ask agent [
         set eat?  true
         set p-visits p-visits + 1
        ]
      ]
    ]
    ;; check if there is a Barter here
    ask barters-here[
      ;; test if the person has been to outlet that day
      if [eat?] of agent = false [
        set customers customers + 1
        set label  word customers " "
        ;; if the person ges to a Barer then the EAT is set but their exposure counter is not incremented
        ask agent [
         set eat?  true
        ]
      ]
    ]

    ;; set the lable of the persons home to be the total number of times they have visited a Pecks
    ask p-home [
      set label [p-visits ] of agent
    ]

  ]
end


to setup-people
  create-people number-of-people [
    ;; create a person
    set color yellow
    set shape "default"
    ;; set the DAILy_MOVES counter to 0
    set daily-moves 0
    ;; pick a random node for its home
    set eat? true
    set p-visits 0
    set location one-of nodes
    ask location [
      ;; set node  color to green to show it is a home
      set color green
      ;; make size larger so  it will show up
      set size 1
      show-turtle
      ask patch-here [
          set p-type "home" ;; used for display
      ]
    ]
    set p-home location
    ;; move our new person into their nice new shiney home
    move-to location
  ]
end


;; ************************ PECKS and BARTERS BREED METHODS
to build-outlet
if mouse-down? [
     ask nodes-on patch mouse-xcor mouse-ycor [
      ifelse outlet = "Pecks"[
        set breed pecks
        set shape "square"
        set color 87
        set label-color black
        set size 1
        set customers 0
        show-turtle
        set label customers
      ][
        set breed barters
        set shape "square"
        set color 45
        set label-color black
        set size 1
        set customers 0
        show-turtle
        set label customers
      ]
   ]
  ]
  reset-ticks
end

;; ************************ NODE BREED METHODS
to setup-nodes
  ;; create patches and add a node in each patch
  ;; a node is a position on the map that people can move to
  set-default-shape nodes "circle"
  ask patches [
    set visits 0
    set p-type "urban"
    sprout-nodes 1 [
      set color blue
      set size 0.3
    ]
  ]
end

to setup-link-nodes
  ;; note that this has to be done after all the nodes have been created
  ask nodes [
    ;; ask each node to link to the 4 von Numann neighbor patches to the patch that he node is on.  "node-on"
    let targets nodes-on neighbors4
    ;; the links are directonal ie onlt to the target not from the target back
    create-active-links-to turtle-set targets
    ask my-links[
      ;; dont show the local neighbour links
        hide-link
    ]
    ;; dont show the nodes
    hide-turtle
  ]
end

;; ************************ HUB BREED METHODS
to setup-hubs
  repeat number-of-hubs[
    ;;select a node at random
    ask one-of nodes [
      ask patch-here [
        set p-type "hub" ;set the patch p-type id to hub this is used in the display
      ]
      set breed hubs
      set shape "circle"
      set color 85
      set size 1
      show-turtle
    ]
  ]
end

to setup-link-hubs
  ask hubs[
    let target self
    ;; create links to the hub from  NUMBER-OF-LINKS random other nodes
    let links-to random ( max-number-of-links - min-number-of-links ) + min-number-of-links
    repeat links-to [
      ask one-of nodes [
        ;; tset that it is not linking to its's self
        if self != target [
          set color white
          show-turtle
          ;; This is a directional link from the random node to the hub
          create-active-link-to target[
            set shape "bus-link"
            set thickness 0.005
          ]
        ]
      ]
    ]
  ]
end


;; ************************ DISPLAY METHODS
to patch-display
  ;; color only the urban patches with a red color propotional to the number of visits
  ask patches [
    if p-type = "urban" [
      set pcolor scale-color red visits 0 ( max [visits] of patches )
    ]
  ]
end


to reset
clear-all
reset-ticks
  set flag? false
end


to setup
  clear-all
  setup-nodes
  setup-link-nodes
  setup-hubs
  setup-link-hubs
  setup-people
  reset-ticks
  set flag? true
  set running? false
end



to iterate
  people-move
  patch-display
  tick
end

to go
  ;; netlogo needs to be running and ticks updated for the mouse down to work
  ifelse flag? = true[
    ifelse running? = true [
      iterate
    ][
      build-outlet
    ]
  ][
    setup
  ]
end


to start-run
  set running? true
end

to stop-run
  set running? false
end

; Public Domain:
; To the extent possible under law, Uri Wilensky has waived all
; copyright and related or neighboring rights to this model.
@#$#@#$#@
GRAPHICS-WINDOW
340
25
1128
814
-1
-1
19.0244
1
10
1
1
1
0
0
0
1
-20
20
-20
20
1
1
1
ticks
30.0

SLIDER
25
310
210
343
number-of-people
number-of-people
1
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
25
350
210
383
number-of-hubs
number-of-hubs
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
24
389
301
422
max-number-of-links
max-number-of-links
min-number-of-links
60
20.0
1
1
bus-stops
HORIZONTAL

SLIDER
24
426
301
459
min-number-of-links
min-number-of-links
0
max-number-of-links
20.0
1
1
bus-stops
HORIZONTAL

SLIDER
25
465
160
498
moves-per-day
moves-per-day
1
40
10.0
1
1
NIL
HORIZONTAL

BUTTON
25
565
110
598
initilise
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
120
565
187
598
NIL
reset\n
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
25
605
117
638
NIL
start-run
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
120
605
212
638
NIL
stop-run
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
35
20
185
151
Pecks and Barter
38
0.0
1

TEXTBOX
345
835
1015
921
Green circles are agent home numbers show how many times agent has visited a Pecks\nBlue circles are travle hubs\nLight blue square are Pecks. The numbers are the number of customers. Yellow square are Barter's. The numbers are the number of customers ( a person will only visit maximum of one outlet per day )\nWhite dots are bus stops
12
0.0
1

TEXTBOX
25
650
300
775
Click initialise on ( goes black ) to place a Pecks or a Barter with your mouse.\nChoose  which with the outlet chooser above\nClick initialise off ( goes grey ) before redoing set up\n
12
0.0
1

CHOOSER
25
510
163
555
outlet
outlet
"Pecks" "Barter"
0

TEXTBOX
25
170
285
300
Can the effect of Pecks on the exposure of the population be offset by placing community run good food outlets?   \nThe agents will only go to one outlet per day.\n\"[In] 1940, working in exchange for food [Gregory Peck acted] at the Barter Theatre in Abingdon, Virginia, \" wikipedia
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

Can we do berrt tah a Pecks?
Where is the best place to build a Barter community good food outlet?
"[In] 1940, working in exchange for food [Gregory Peck acted] at the Barter Theatre in Abingdon, Virginia, " wikipedia

## HOW IT WORKS

Initilise (SETUP)
Set all patches to P-TYPE urban
Add 4 nearest neighbours to a patches CONNECTIONS

Create NUMBER-OF-PEOPLE people place them randomly in a patch and set that patch as the persons PERSON-HOME set that pac P-TYE as “home” set color green set the persons
Each person randomly moves MOVES-PER-DAY times and then goes HOME
A person will only visit a Pecks a maximum of onec pre day 

Select NUMBER-OF-HUBS patches as hubs set the P-TYPE of that patch as “hub” randomly choose between MIN-NUMBER-OF-LINKS and MAX-NUMBER-OF-LINKS and add the hub pach to their CONNECTIONS


Iterate (GO)
For each person move to one of the patches that are in its current patches CONNECTIONS. Add one to the VISITS of the patch that the personis moving to. Add one to the MOVES value of the person
If the MOVES value is greater than the MOVES-PER-DAY move back to the persons PERSON-HOME patch
If the person visits a PECKS and it has not visited a PECKS that day the CUSTOMES value of the PECKS wil be increased by one and the P-VIST value of the person will also be increased by one
if the person goes to a BARTER then the EAT is set but their exposure counter is not incremented

For all patches if the patch is P-TYPE urban the set color to be proporinata to number of visits.


## HOW TO USE IT

Click initialise on ( goes black ) to place a pecks with your mouse.
Click initialise off ( goes grey ) before redoing set up


## THINGS TO NOTICE

Green circles are agent home numbers show how many times agent has visited a Pecks
Blue circles are travle hubs
Light blue square are Pecks. The numbers are the number of customers ( a person will only visit maximum of one per day )
White dots are bus stops


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
NetLogo 6.2.2
@#$#@#$#@
random-seed 2
setup
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 2.0 2.0
0.2 0 0.0 1.0
link direction
false
13
Line -7500403 false -87 222 -147 252
Line -7500403 false 441 201 501 231
Line -7500403 false -170 146 -124 166

bus-link
0.0
-0.2 0 0.0 1.0
0.0 0 0.0 1.0
0.2 1 2.0 2.0
link direction
true
0
@#$#@#$#@
1
@#$#@#$#@
