breed[leoes leao]
breed[hienas hiena]
breed[hipopotamos hipopotamo]
breed [oasis oasi]
hienas-own[energia
  nivel_agrupamento]
leoes-own[energia
  descanso]
hipopotamos-own[energia tempo]
oasis-own [ tempo num]
globals[tickhienas tickleoes]

to setup
  setup-patches
  setup-turtles
end

to test
  clear-all
  ask patches [ sprout 1 [
    set shape "square 2"
    set color blue
    stamp
    die
  ]]
end

;inicializar bichos
to setup-turtles
clear-turtles
   create-leoes Numero_Leoes [
    set shape "butterfly"
    set color yellow
    set size 1
    set xcor random 32
    set ycor random 32
    set heading random 4 * 90
    set energia energia_animais]

  create-hienas Numero_Hienas [
    set shape "wolf"
    set color orange
    set nivel_agrupamento 1
    set size 1.5
    set xcor random 32
    set ycor random 32
    set heading random 4 * 90
    set energia energia_animais]

  if Modelo = "Modelo_Melhorado"[
    create-oasis Numero_Oasis[
      set shape "square"
      set color green
      set size 1
      set xcor random 32
      set ycor random 32
      ask patch-here [set pcolor green]
    ]
    create-hipopotamos Numero_Hipopotamos[
      set shape "cow"
      set color grey
      set energia 30
      set size 1.6
      move-to one-of patches with [pcolor = green]
      set heading random 4 * 90
    ]

  ]

end

;inicializar o ambiente
to setup-patches
  clear-all
  set-patch-size 15
  repeat Celula_Azul [ask one-of patches with [pcolor = black][set pcolor Blue]]
  repeat Pequeno_Porte * (256 / 100) [ask one-of patches with [pcolor = black][set pcolor Brown]]
  repeat Grande_Porte * (256 / 100) [ask one-of patches with [pcolor = black][set pcolor red]]
  if Modelo = "Modelo_Melhorado"[ repeat Numero_Catos * (256 / 100) [ask one-of patches with [pcolor = black][set pcolor [8 80 0]]]]
  VerEnergia
 reset-ticks
end

to Go
  if count hienas = 0[ set tickhienas ticks]
  if count leoes = 0 [set tickleoes ticks]
  if count hienas + count leoes = 0 or ticks = 1000 [stop] ;nao há mais bichos, pára

  ;rotina dos leoes
  ask leoes[
     MoveLeoes
     eat
     death
     if Modelo = "Modelo_Melhorado"[Catos]
  ]

  ;rotina das hienas
  ask hienas [
    MoveHienas
    Agrupamento
    eat
    death
    if Modelo = "Modelo_Melhorado"[Catos]
  ]
  if Modelo = "Modelo_Melhorado"[

    ask hipopotamos[
      MoveHipopotamos
      Catos
      death
    ]
    ask oasis [
      if (ticks mod 20 = 0)[
        ask patches in-radius num [set pcolor brown]]
      if (num < 3)[set num num + 0.1]
  ]]

 tick
 VerEnergia
end

;esconder a energia ou mostrar a energia
to VerEnergia
  ask turtles [set label ""]
  if MostraEnergia[
  ask hienas [set label round energia]
    ask hienas[
      set label round energia
      set label-color white
    ]
    ask leoes [set label round energia]
    ask leoes [
      set label round energia
      set label-color white
    ]
  ]
end

;COMIDA
to eat

  if pcolor = brown[
    set pcolor black
    set energia energia + energia_castanha

  if Modelo = "Modelo_Base" [
    ask one-of patches with [pcolor = black]
    [set pcolor brown]] ;pequeno porte reaparece aleatoriamente dps de ser comido
  ]

  if pcolor = red[
    set pcolor brown
    set energia energia + energia_vermelho]

end

;Morre
to death
  if energia <= 0 [die]
end

;Movimento dos Leões
to MoveLeoes
   let primeiro 2
   let aqui patch-here
   let frente patch-ahead 1
   let direita patch-at-heading-and-distance 90 1
   let esquerda patch-at-heading-and-distance -90 1


  ifelse energia < energia_animais[
    (ifelse
      ([pcolor] of frente = red or [pcolor] of frente = brown or [pcolor] of frente = blue) [fd 1  set descanso ticks]
      ([pcolor] of direita = red or [pcolor] of direita = brown or [pcolor] of direita = blue)  [rt 90  set descanso ticks]
      ([pcolor] of esquerda = red or [pcolor] of esquerda = brown or [pcolor] of esquerda = blue) [rt -90  set descanso ticks]
      ([pcolor] of aqui = blue)[Descansar]
      ([pcolor] of frente != red and [pcolor] of frente != brown and [pcolor] of frente != blue ) and ([pcolor] of esquerda != red and [pcolor] of esquerda != brown and [pcolor] of esquerda != blue) and ([pcolor] of direita != red and [pcolor] of direita != brown and [pcolor] of direita != blue) [fd 1])]
  [
    (ifelse
      ;se n há hienas -> random
      count hienas-on direita + count hienas-on esquerda + count hienas-on frente = 0 [
        ifelse (primeiro = 1)
        [ rt one-of [90 -90 0] set primeiro 0]
        [fd 1 set primeiro 1]]

      ;se há 1 hiena -> mata
      count hienas-on direita + count hienas-on esquerda + count hienas-on frente = 1 [
        (ifelse
          any? hienas-on frente[
            ask hienas-on frente[die]
            fd 1
            set energia (energia * Energia_perdida_combate) + 1
            ask frente [set pcolor brown]]

          any? hienas-on direita[
            ask hienas-on direita[die]
            rt 90
            fd 1
            set energia (energia * Energia_perdida_combate) + 1
            ask frente [set pcolor brown]]

          any? hienas-on esquerda[
            ask hienas-on esquerda[die]
            rt -90
            fd 1
            set energia (energia * Energia_perdida_combate) + 1
            ask frente [set pcolor brown]])]

      ;se várias hienas -> movimentação especial
      count hienas-on direita + count hienas-on esquerda + count hienas-on frente > 1 [
        (ifelse
          count hienas-on esquerda > 2 [
            rt 90
            fd 1
            ; já perde um independentemente da acao
            set energia energia - 1 ]

          count hienas-on esquerda >= 2[
            rt -90
            fd 1
            set energia energia - 1]

          count hienas-on frente >= 2 and count hienas-on esquerda >= 1 and count hienas-on direita >= 1[
            fd -1
            set energia energia - 2]

          count hienas-on frente >= 1[
            (ifelse
               count hienas-on esquerda >= 1 [
                fd -1
                rt 90
                fd 1
                set energia energia - 4]

              count hienas-on direita >= 1 [
                fd -1
                rt -90
                fd 1
                set energia energia - 4]

             count hienas-on direita >= 1 and count hienas-on esquerda >= 1[
                fd -2
                set energia energia - 4]
        )])
    ])
  ]
  set energia energia - 1

end

to Descansar
  let tempo_saida  ticks - descanso
  set energia energia + 1

  if tempo_saida = descanso_duracao [fd 1]
end

;movimento hienas
to MoveHienas
   let frente patch-ahead 1
   let direita patch-right-and-ahead 90 1
   let esquerda patch-left-and-ahead 90 1
   let atual [pcolor] of patch-here

  ifelse nivel_agrupamento > 1 and (count leoes-on direita + count leoes-on esquerda + count leoes-on frente = 1)[
    ;rotina matar leoes
    (ifelse
      any? leoes-on frente[
        ask leoes-on frente[die]
        fd 1
        set energia  energia * Energia_perdida_combate
        ask frente [set pcolor red]
      ]
      any? leoes-on direita[
        ask leoes-on direita [die]
        rt 90
        fd 1
        set energia  energia * Energia_perdida_combate
        ask frente [set pcolor red]
      ]
      any? leoes-on esquerda[
        ask leoes-on esquerda[die]
        rt -90
        fd 1
        set energia  energia * Energia_perdida_combate
        ask frente [set pcolor red]
      ])]
  [
    ; rotina normal de andar
    (ifelse
      ([pcolor] of frente = red or [pcolor] of frente = brown)  [fd 1]
      ([pcolor] of direita = red or [pcolor] of direita = brown)  [rt 90]
      ([pcolor] of esquerda = red or [pcolor] of esquerda = brown) [rt -90]
      ([pcolor] of frente != red or [pcolor] of frente != brown) and ([pcolor] of esquerda != red or [pcolor] of esquerda != brown) and ([pcolor] of direita != red or [pcolor] of direita != brown) [fd 1])
    set energia energia - 1
  ]
end

;calcula e deteta nivel de agrupamento
to Agrupamento
   let frente patch-ahead 1
   let direita patch-right-and-ahead 90 1
   let esquerda patch-left-and-ahead 90 1
   let aqui patch-here


  set nivel_agrupamento 1
  set color orange

  (ifelse
    any? hienas-on frente[
      set nivel_agrupamento 1 + count hienas-on frente + count hienas-on esquerda + count hienas-on direita
     ask hienas-on frente[
        set color violet
        set heading [heading] of myself
        set nivel_agrupamento [nivel_agrupamento] of myself]]


   any? hienas-on direita[
    set nivel_agrupamento 1 + count hienas-on frente + count hienas-on esquerda + count hienas-on direita
    ask hienas-on direita[
        set color violet
        set heading [heading] of myself
        set nivel_agrupamento [nivel_agrupamento] of myself]]

   any? hienas-on esquerda[
     set nivel_agrupamento 1 + count hienas-on frente + count hienas-on esquerda + count hienas-on direita
     ask hienas-on esquerda[
        set color violet
        set heading [heading] of myself
        set nivel_agrupamento [nivel_agrupamento] of myself]])

  ifelse (nivel_agrupamento > 1)[set color violet ][set color orange]

end

to MoveHipopotamos
   let frente patch-ahead 1
   let direita patch-right-and-ahead 90 1
   let esquerda patch-left-and-ahead 90 1

   let atual [pcolor] of patch-here

  ask oasis[set tempo ticks]

  if (any? hienas-on neighbors4  )[ask hienas-on neighbors4 [die]]
  if (count leoes-on neighbors4 > 1)[ask leoes-on neighbors4 [die]]

  (ifelse
    ([pcolor] of frente = red or [pcolor] of frente = brown )  [fd 1]
    ([pcolor] of direita = red or [pcolor] of direita = brown )  [rt 90]
    ([pcolor] of esquerda = red or [pcolor] of esquerda = brown) [rt -90]
  )
  rt -180
  if (atual = black) [set energia 0]

end

to Catos
  if pcolor = [8 80 0][
    ask turtles-here [set energia energia - 10]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
609
20
1112
524
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
0
32
0
32
1
1
1
ticks
30.0

BUTTON
1280
471
1411
526
Ambiente
Setup
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
1157
471
1265
527
Começar
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
1162
362
1411
407
Modelo
Modelo
"Modelo_Base" "Modelo_Melhorado"
1

MONITOR
68
471
118
524
Leões
count leoes
0
1
13

MONITOR
130
471
184
524
Hienas
count hienas
0
1
13

MONITOR
198
470
286
523
Hipopotamos
count hipopotamos
0
1
13

SLIDER
29
52
201
85
Pequeno_Porte
Pequeno_Porte
0
20
10.0
1
1
%
HORIZONTAL

SLIDER
226
52
398
85
Grande_Porte
Grande_Porte
0
10
5.0
1
1
%
HORIZONTAL

SLIDER
424
51
596
84
Celula_Azul
Celula_Azul
0
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
228
201
400
234
Numero_Hienas
Numero_Hienas
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
41
201
213
234
Numero_Leoes
Numero_Leoes
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
238
345
410
378
Numero_Catos
Numero_Catos
0
15
10.0
1
1
%
HORIZONTAL

SLIDER
40
346
212
379
Numero_Hipopotamos
Numero_Hipopotamos
0
3
2.0
1
1
NIL
HORIZONTAL

SLIDER
30
110
202
143
energia_castanha
energia_castanha
1
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
227
108
399
141
energia_vermelho
energia_vermelho
1
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
422
201
594
234
energia_animais
energia_animais
50
200
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
265
10
415
35
Ambiente
20
0.0
1

TEXTBOX
267
161
417
186
Animais
20
0.0
1

TEXTBOX
239
288
448
338
Modelo Melhorado
20
0.0
1

SWITCH
1301
424
1412
457
MostraEnergia
MostraEnergia
0
1
-1000

TEXTBOX
272
412
422
437
Contadores
20
0.0
1

SLIDER
422
110
594
143
descanso_duracao
descanso_duracao
0
10
5.0
5
1
NIL
HORIZONTAL

BUTTON
1299
218
1362
251
NIL
test\n
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
41
253
210
286
Energia_perdida_combate
Energia_perdida_combate
0
1
0.05
0.1
1
NIL
HORIZONTAL

MONITOR
313
473
448
518
Extinção Hienas
tickhienas
17
1
11

MONITOR
482
475
580
520
Extinção Leões
tickleoes
17
1
11

SLIDER
424
344
596
377
Numero_Oasis
Numero_Oasis
0
4
3.0
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

cactus
false
0
Polygon -7500403 true true 130 300 124 206 110 207 94 201 81 183 75 171 74 95 79 79 88 74 97 79 100 95 101 151 104 169 115 180 126 169 129 31 132 19 145 16 153 20 158 32 162 142 166 149 177 149 185 137 185 119 189 108 199 103 212 108 215 121 215 144 210 165 196 177 176 181 164 182 159 302
Line -16777216 false 142 32 146 143
Line -16777216 false 148 179 143 300
Line -16777216 false 123 191 114 197
Line -16777216 false 113 199 96 188
Line -16777216 false 95 188 84 168
Line -16777216 false 83 168 82 103
Line -16777216 false 201 147 202 123
Line -16777216 false 190 162 199 148
Line -16777216 false 174 164 189 163

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

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

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="73"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="34"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="75"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment3" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="75"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment4" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="75"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment5" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="75"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment6" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment7" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment8" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment9" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment10" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="120"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="default" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Base&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="110"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="60"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="defaultM" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hienas</metric>
    <metric>tickhienas</metric>
    <metric>count leoes</metric>
    <metric>tickleoes</metric>
    <enumeratedValueSet variable="energia_castanha">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hipopotamos">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Catos">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modelo">
      <value value="&quot;Modelo_Melhorado&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="descanso_duracao">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_animais">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Energia_perdida_combate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MostraEnergia">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Oasis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Celula_Azul">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energia_vermelho">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grande_Porte">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pequeno_Porte">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Leoes">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Numero_Hienas">
      <value value="60"/>
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
