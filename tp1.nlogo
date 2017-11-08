;alterações que fiz até agora: criei mais monitores, adicionei mais duas vars globais e modifiquei o checken, mas é só para fazer os testes de código.

breed [gens gen]
breed [sols sol]
breed [forts  fort]
globals [finish rprom gprom anygg anyrg rfb gfb fr fcrit rdprom gdprom agent] ;rfb Red Forts Built gfb Green Forts built fr Fort Recovers
gens-own[en ex nder]
sols-own[en ex nvic]
forts-own[en ex]

;------------SETUP---------------SETUP-------------SETUP-----------

to setup

  setup-campo
  setup-patches
  setup-exer
  reset-ticks

end

to setup-campo

  clear-all
  set-patch-size 15

end

to setup-patches
 let i 0
  while [i < gxcampsize]
  [
    let j 0
    while [j < gycampsize]
    [
      ask patches with [pxcor = max-pxcor - i - 3 and pycor = max-pycor - j - 3]
      [set pcolor blue]
      set j j + 1
    ]
    set i i + 1
  ]

  set i 0
  while [i < rxcampsize]
  [
    let j 0
    while [j < rycampsize]
    [

      ask patches with [pxcor = min-pxcor + i + 3 and pycor = min-pxcor + j + 3]
      [set pcolor yellow]
      set j j + 1
    ]
    set i i + 1
  ]
end

to setup-exer
  set finish 0
  set rprom 0
  set gprom 0
  set anyrg 1
  set anygg 1
  create-sols ngsol
  [
    set en maxe
    set shape "person"
    set color green
    set ex yellow
    let x one-of patches with [pcolor = yellow]
    ;set heading one-of [0 90 180 270]
    setxy [pxcor] of x [pycor] of x

  ]

  create-gens nggen
  [
    set en maxe
    set shape "person soldier"
    set color green
    set ex yellow
    let x one-of patches with [pcolor = yellow]
    ;set heading one-of [0 90 180 270]
    setxy [pxcor] of x [pycor] of x
  ]

  create-sols nrsol
  [
    set en maxe
    set shape "person"
    set color red
    set ex blue
    let x one-of patches with [pcolor = blue]
    ;set heading one-of [0 90 180 270]
    setxy [pxcor] of x [pycor] of x
  ]

  create-gens nrgen
  [
    set en maxe
    set shape "person soldier"
    set color red
    set ex blue
    let x one-of patches with [pcolor = blue]
    ;set heading one-of [0 90 180 270]
    setxy [pxcor] of x [pycor] of x
  ]
end

to go
;  if ticks = 0
;  [
;    output-print "Inicio"
;  ]
  checken
  checkfinish
  movegen
  movesol
  if extra
  [
    forte
    forte-check
    forte-recover
  ]
  promote
  if finish = 1
  [
     output-print "Fim"

    let x count patches with [pcolor = yellow]
    let y count patches with [pcolor = blue]

    if x < y
    [output-print "Reds win!"]
    if x > y
    [output-print "Greens win!"]
    if x = y
    [output-print "It's a Tie!"]

    stop
  ]
  tick

end

;-----------------MOVES--------------------------MOVES--------------------MOVES------------------------

to movesol
ask sols[
    set label round en
    let counter (count (gens-on patch-ahead 1) with [ex != [ex] of myself] + count (gens-on patch-right-and-ahead 90 1) with [ex != [ex] of myself])
    ifelse counter = 1 and (not (any? (sols-on patch-ahead 1) with [ex != [ex] of myself] or any? (sols-on patch-right-and-ahead 90 1) with [ex != [ex] of myself]))
    [
      rt 180
      fd 2
      set en en - 1
    ]
    [
      ifelse any? (sols-on patch-ahead 1) with [ex != [ex] of myself] or any? (gens-on patch-ahead 1) with [ex != [ex] of myself]
      [
       BattleS
      ]
      [
        ifelse any? (sols-on patch-right-and-ahead 90 1) with [ex != [ex] of myself] or any? (gens-on patch-right-and-ahead 90 1) with [ex != [ex] of myself]
        [
          rt 90
          BattleS
          rt -90
        ]
        [
          ifelse [pcolor] of patch-ahead 1 != ex
          [
            fd 1
            set en en - 1
            ifelse ex = yellow
            [
              set pcolor yellow
            ]
            [
              set pcolor blue
            ]
          ]
          [
            ifelse [pcolor] of patch-right-and-ahead 90 1 != ex
            [
              fd 1
              set en en - 1
              set pcolor ex
            ]
            [
              fd 1
            ]
          ]
        ]
      ]
    ]
  set en en - 1
     if en <= 0
    [
      die
    ]
    set label round en
]
end

to movegen
  ask gens[
    set label round en

    recover ;recupera vida

    ;---------------------Verificar Vizinhança

    ifelse any? (turtles-on neighbors4) with [ex != [ex] of myself and breed != forts]  ;verifica se há inimigos
      [
        ifelse any? (gens-on neighbors4) with [ex != ([ex] of myself)]
        [
          BattleGG
        ]
        [
          ;um soldado
          ifelse count (sols-on neighbors4) with [ex != ([ex] of myself)] < 2
          [
            rt 180
            fd 2
            set en (en - 1)
          ]
          ;vários soldados
          [
            BattleGS
          ]
        ]
      ]
    [
      let z black
      ifelse ex = blue
      [
        set z blue
      ]
      [
        set z yellow
      ]
      ifelse any? neighbors4 with ([pcolor != z])
      [
        move-to one-of neighbors4 with ([pcolor != z])
        set pcolor ex
        set en (en - 1)
      ]
      [
        move-to one-of neighbors4
      ]
    ]
    set en en - 1

    if ticks > 50000
    [
      set en en - (en * 5000)
    ]

    if en <= 0
    [
      die
    ]
    set label round en
  ]

end

;-------------BATTLES-------------BATTLES---------BATTLES-----------BATTLES-------------------

to BattleS ;verificar qual procedure a chamar
   set agent one-of (turtles-on patch-ahead 1) with [ex != [ex] of myself and breed != forts] ;guardar no agente uma turtle inimiga
        let check 0 ;variavel de verificação
        ask agent
        [
          if breed = sols
          [
            set check 1
          ]
          if breed = gens
          [
            set check 2
          ]
        ]
  if check = 0
  [
    output-print "Há aqui um forte? :o"
  ]
  if check = 1
  [
    BattleSS
  ]
  if check = 2
  [
    BattleSG
  ]
end


to BattleGG
  let entmp en ;variavel temporária para poder manipular a energia da turtle que está a perguntar
  ask one-of (turtles-on neighbors4) with [(ex != [ex] of myself) and (breed = [breed] of myself)]
  [
    ifelse random 2 < 1 ;50 50
    [
      ;Ganhou
      set en en / 2 ;corta para metade a energia da tartaruga que está a ser interrogada
      set entmp entmp + en ;guarda na temporaria a nova energia
    ]
    [
      ;Perdeu
      set entmp entmp / 2 ;corta para metade a energia da tartaruga que está a interrogar
      set en en + entmp ;atualiza a energia da interrogada
    ]
    ;verifica se a tartaruga está morta e mata-a, pois podes correr o risco de ela ainda chamar a batalha antes de chamar o procedure que verifica se ela morreu (aka evitar uma morte à alentejano)

    forte-effect

    if en <= 0
    [
      print en
      die
    ]
  ]
  set en entmp ;atualiza a energia da tartaruga a interrogar

  forte-effect

  ;verificas se ela morreu ou não também
  if en <= 0
  [
    print en
    die
  ]
end

to BattleGS
  let entmp en
  ask one-of (turtles-on neighbors4) with [(ex != [ex] of myself) and (breed != [breed] of myself) and (breed != forts)]
  [
    ifelse random 4 < 3
    [
      ;Ganhou
      set en en / 2
      if (ex = yellow and anyrg = 0) or (ex = blue and anygg = 0) or en > llimit
      [
        set entmp entmp + en
      ]
    ]
    [
      ;Perdeu
      set entmp entmp / 2
      set en en + entmp
      set nvic nvic + 1
    ]

    forte-effect

    if en <= 0
    [
      print en
      die
    ]
  ]

  set en entmp

  forte-effect

  if en <= 0
  [
    print en
    die
  ]

end

to BattleSG
  let entmp en
  let vic 0
  ask agent
  [
    ifelse random 4 = 3
    [
      ;Ganhou
      set en en / 2
      set entmp entmp + en
      set vic 1
    ]
    [
      ;Perdeu
      set entmp entmp / 2
      if (ex = yellow and anyrg = 0) or (ex = blue and anygg = 0) or entmp > llimit
      [
          set en en + entmp
      ]
    ]

    forte-effect

    if en <= 0
    [
      print en
      die
    ]
  ]
  set en entmp

  forte-effect

  if en <= 0
  [
    print en
    die
  ]
  if vic = 1
  [
    set nvic nvic + 1
  ]
end

to BattleSS
  let entmp en
  let vic 0
  ask agent
  [
    ifelse random 2 < 1
    [
      ;Ganhou
      set en en / 2

      if (ex = yellow and anyrg = 0) or (ex = blue and anygg = 0) or en > llimit
      [
          set entmp entmp + en
      ]

      set vic 1
    ]
    [
      ;Perdeu
      set entmp entmp / 2

      if (ex = yellow and anyrg = 0) or (ex = blue and anygg = 0) or entmp > llimit
      [
          set en en + entmp
      ]

      set nvic nvic + 1
    ]

    forte-effect

    if en <= 0
    [
      print en
      die
    ]
  ]
  set en entmp

  forte-effect

  if en <= 0
  [
    print en
    die
  ]
  if vic = 1
  [
    set nvic nvic + 1
  ]
end

;---------------Extras--------Extras------------------

to promote
  ask sols
  [
    if nvic >= promotionvics
    [
      set breed gens
      set shape "person soldier"
      set nder 0
      ifelse ex = yellow
      [ set gprom gprom + 1]
      [ set rprom rprom + 1]
    ]
  ]

  if extra
  [
    ask gens
    [
      if nder >= 50
      [
        set breed sols
        set shape "person"
        set nvic 0
        ifelse ex = yellow
      [ set gdprom gdprom + 1]
      [ set rdprom rdprom + 1]
      ]
    ]
  ]
end

to recover
  let x 0
  if any? (sols-on neighbors4) with [ex = [ex] of self]
  [
    set x 0
    ask (sols-on neighbors4) with [ex = [ex] of self]
    [
      set x (x + (en * .05))
    ]
  ]
  set en (en + x)
end

;-------------------------------verificar fim

to checken
  ask turtles
  [
    if en <= 0
    [
      die
    ]
  ]

  ifelse (count gens with [ex = yellow]) = 0 and anygg = 0
  [
    ;output-print "Morreu o último General Verde!"
    set anygg 1
  ]
  [
    if (count gens with [ex = yellow]) > 0
    [
      set anygg 0
    ]
  ]

  ifelse (count gens with [ex = blue]) = 0 and anyrg = 0
  [
    ;output-print "Morreu o último General Vermelho!"
    set anyrg 1
  ]
  [
    if (count gens with [ex = blue]) > 0
    [
      set anyrg 0
    ]
  ]

  if (not any? sols and not any? gens)
  [
    set finish 1
  ]
end

to checkfinish
  let x count patches with [pcolor != yellow]
  let y count patches with [pcolor != blue]
  if x <= 0 or y <= 0
  [
    set finish 1
  ]
end

to go_case
  let i 0
  while [i < 30]
  [
    setup
    set finish 0

    while [finish = 0]
    [
      checken
      checkfinish
      movegen
      movesol
      promote
      tick
    ]

    let tcg count patches with [pcolor = yellow]
    let tcr count patches with [pcolor = blue]
    let s ";"
    output-write ticks
    type s
    output-write tcg
    type s
    output-write tcr
    type s
    output-write gprom
    type s
    output-write rprom
    type s
    set i i + 1
  ]

  stop
end

;-----------------------EXTRA---------------EXTRA--------------------EXTRA

to forte
  ask patches[
    let x count (sols-here with [ex = blue])
    let y count (sols-here with [ex = yellow])
    ifelse x > 4 and not any? forts-here
    [
      sprout-forts 1
      [
        set en 1
        set ex blue
        set shape "chess rook"
        set color red
        set rfb rfb + 1
      ]
    ]
    [
      if y > 4 and not any? forts-here
      [
        sprout-forts 1
        [
          set en 1
          set ex yellow
          set shape "chess rook"
          set color green
          set gfb gfb + 1
        ]
      ]
    ]
  ]
end

to forte-check
ask forts
  [
    if pcolor != [ex] of self
    [
      ifelse random 100 < 30
      [
        output-print "Forte mudou de lealdade"
        ifelse ex = blue
        [
          set ex yellow
          set color green
        ]
        [
          set ex blue
          set color red
        ]
      ]
      [
        output-print "Forte abatido"
        die
      ]
    ]
  ]
end

to forte-recover
  ask turtles
  [
    if any? (forts-on neighbors) with [ex = [ex] of myself] and ticks < 10000
    [
        set en en * 1.01
        set fr fr + 1
    ]
  ]
end

to forte-effect
  if extra and any? (forts-on neighbors) with [ex != [ex] of myself]
    [
      ifelse random 100 < 5 ; Ataque Critico
      [
        set en en - (maxe * 0.05)
        set fcrit fcrit + 1
      ]
      [
        set en en * .90
      ]
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
195
10
698
514
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
719
522
783
555
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

SLIDER
6
59
178
92
ngsol
ngsol
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
6
102
178
135
nggen
nggen
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
6
149
178
182
nrsol
nrsol
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
8
196
180
229
nrgen
nrgen
0
20
20.0
1
1
NIL
HORIZONTAL

BUTTON
793
522
856
555
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
707
25
879
58
Rxcampsize
Rxcampsize
1
max-pxcor - 3
13.0
1
1
Largura
HORIZONTAL

SLIDER
882
24
1054
57
Gxcampsize
Gxcampsize
1
max-pxcor - 3
13.0
1
1
Largura
HORIZONTAL

SLIDER
6
237
178
270
maxe
maxe
llimit
200
200.0
1
1
Energia
HORIZONTAL

MONITOR
805
355
888
400
Green Soldiers
count sols with [ex = yellow]
17
1
11

MONITOR
708
354
800
399
Red Soldiers
count sols with [ex = blue]
17
1
11

MONITOR
805
460
913
505
Green's Dominion
count patches with [pcolor = yellow]
17
1
11

MONITOR
705
460
801
505
Red's Dominion
count patches with [pcolor = blue]
17
1
11

PLOT
708
108
1025
341
Dominions
ticks
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Red's" 1.0 0 -5298144 true "" "plot count patches with [pcolor = blue]"
"Green's" 1.0 0 -14439633 true "" "plot count patches with [pcolor = yellow]"
"Rogue" 1.0 0 -16777216 true "" "plot count patches with [pcolor = black]"

SLIDER
6
278
178
311
llimit
llimit
0
maxe
20.0
1
1
Energia
HORIZONTAL

TEXTBOX
1085
40
1326
152
Falta fazer:\ngenerais (falar com o stor)\nTestes
11
0.0
1

PLOT
1033
107
1233
257
Army Size
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Greens" 1.0 0 -14439633 true "" "plot count sols with [ex = yellow] + count gens with [ex = yellow]"
"Reds" 1.0 0 -5298144 true "" "plot count sols with [ex = blue] + count gens with [ex = blue]"

MONITOR
705
408
802
453
Red Generals
count gens with [ex = blue]
17
1
11

MONITOR
805
408
895
453
Green Generals
count gens with [ex = yellow]
17
1
11

MONITOR
895
354
995
399
Red Promotions
rprom
17
1
11

MONITOR
906
409
1017
454
Green Promotions
gprom
17
1
11

PLOT
1033
263
1233
413
General Promotions
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Reds" 1.0 0 -5298144 true "" "plot rprom"
"Greens" 1.0 0 -14439633 true "" "plot gprom"

SLIDER
708
65
880
98
Rycampsize
Rycampsize
1
max-pycor - 3
13.0
1
1
Altura
HORIZONTAL

SLIDER
882
65
1054
98
Gycampsize
Gycampsize
1
max-pycor - 3
13.0
1
1
Altura
HORIZONTAL

PLOT
1030
576
1230
726
Red Army
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Generals" 1.0 0 -16777216 true "" "plot count gens with [ex = blue]"
"Soldiers" 1.0 0 -7500403 true "" "plot count sols with [ex = blue]"

PLOT
1031
417
1231
567
Green Army
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Generals" 1.0 0 -16777216 true "" "plot count gens with [ex = yellow]"
"Soldiers" 1.0 0 -7500403 true "" "plot count sols with [ex = yellow]"

SLIDER
7
322
179
355
promotionvics
promotionvics
5
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
915
460
1000
505
Rogue Lands
count patches with [pcolor = black]
17
1
11

SWITCH
36
369
126
402
extra
extra
0
1
-1000

BUTTON
887
521
965
554
Go Case
go_case
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
24
439
91
484
Red Forts
count forts with [ex = blue]
17
1
11

MONITOR
95
440
174
485
Green Forts
count forts with [ex = yellow]
17
1
11

MONITOR
30
489
87
534
NIL
rfb
17
1
11

MONITOR
95
489
152
534
NIL
gfb
17
1
11

MONITOR
64
597
121
642
NIL
fr
17
1
11

MONITOR
29
542
86
587
NIL
rdprom
17
1
11

MONITOR
95
544
152
589
NIL
gdprom
17
1
11

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

chess rook
false
0
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 90 255 105 105 195 105 210 255
Polygon -16777216 false false 90 255 105 105 195 105 210 255
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 75 84 225 105
Rectangle -7500403 true true 135 90 165 60
Rectangle -7500403 true true 180 90 225 60
Polygon -16777216 false false 90 105 75 105 75 60 120 60 120 84 135 84 135 60 165 60 165 84 179 84 180 60 225 60 225 105

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

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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
NetLogo 6.0.2
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
