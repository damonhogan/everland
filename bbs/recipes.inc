; recipes.inc - Generated starter recipe table
; Format per recipe (bytes):
; recipe_id, station_id, output_id, output_qty, output_dur, input1_id, input1_qty, input2_id, input2_qty, input3_id, input3_qty, time_ticks, success_rate, skill_req, discover_flag

RECIPE_STATION_FORGE = 1
RECIPE_STATION_SAW   = 2
RECIPE_STATION_TANN  = 3
RECIPE_STATION_APOTH = 4
RECIPE_STATION_MYST  = 5

recipe_count = 80

recipes_table:
    .byte 100,1,28,1,80,9,1,21,1,255,0,20,95,1,0
    .byte 101,1,29,1,90,9,2,22,1,255,0,30,90,1,0
    .byte 102,1,0,1,120,9,4,22,2,27,1,60,85,2,0
    .byte 103,1,1,1,110,21,4,27,2,9,2,50,88,2,0
    .byte 104,1,30,1,200,9,8,27,4,255,0,120,70,3,1
    .byte 105,1,31,1,150,9,3,21,1,255,0,40,92,1,0
    .byte 106,1,32,1,130,9,2,21,2,255,0,40,91,1,0
    .byte 107,1,14,1,100,9,3,22,2,27,1,60,88,1,0
    .byte 108,1,23,1,80,9,2,21,1,255,0,30,95,1,0
    .byte 109,2,22,1,0,21,2,255,0,255,0,10,99,0,0
    .byte 110,2,23,1,80,9,2,21,1,255,0,30,92,1,0
    .byte 111,3,27,1,0,26,2,255,0,255,0,15,98,0,0
    .byte 112,4,35,1,0,6,1,24,1,255,0,25,95,0,0
    .byte 113,4,36,1,0,25,1,24,1,255,0,25,90,0,0
    .byte 114,5,5,1,0,33,1,6,1,255,0,100,80,2,1
    .byte 115,5,34,1,0,33,1,6,1,11,1,120,65,3,1
    .byte 116,1,15,1,90,6,1,8,2,255,0,50,85,1,0
    .byte 117,1,2,1,0,24,2,255,0,255,0,20,99,0,0
    .byte 118,1,3,1,0,6,1,255,0,255,0,30,88,1,0
    .byte 119,1,4,1,0,11,1,255,0,255,0,40,88,1,0
    .byte 120,1,16,1,0,3,1,11,1,255,0,60,70,2,1
    .byte 121,1,17,1,0,3,1,12,1,255,0,60,70,2,1
    .byte 122,1,18,1,0,4,1,11,1,255,0,60,70,2,1
    .byte 123,1,19,1,0,4,1,12,1,255,0,60,70,2,1
    .byte 124,1,20,1,0,4,1,13,1,255,0,60,70,2,1
    .byte 125,1,21,2,0,8,1,255,0,255,0,10,99,0,0
    .byte 126,1,22,2,0,21,4,255,0,255,0,20,98,0,0
    .byte 127,1,0,1,140,10,3,22,2,27,2,80,75,2,0
    .byte 128,1,1,1,130,10,2,21,4,27,1,70,78,2,0
    .byte 129,3,27,2,0,26,5,255,0,255,0,40,97,1,0
    .byte 130,4,35,1,0,24,2,6,1,255,0,30,93,0,0
    .byte 131,4,36,1,0,6,1,25,1,255,0,30,85,0,0
    .byte 132,5,33,1,0,5,1,6,1,255,0,150,60,3,1
    .byte 133,1,28,1,100,10,2,22,1,255,0,50,90,1,0
    .byte 134,1,29,1,110,10,3,22,1,255,0,55,88,1,0
    .byte 135,1,31,1,160,9,4,21,1,27,1,80,80,2,0
    .byte 136,1,32,1,140,9,3,21,2,27,1,70,82,2,0
    .byte 137,1,14,1,120,9,4,22,2,255,0,90,80,2,0
    .byte 138,2,22,3,0,21,6,255,0,255,0,40,97,1,0
    .byte 139,1,30,1,220,10,10,27,6,255,0,200,60,4,1

; End of recipes.inc

; --- Additional crafted and cooking recipes (expanded set) ---
    .byte 140,4,37,1,0,24,2,8,1,255,0,20,98,0,0   ; Flour from berries+wood (simple)
    .byte 141,4,38,1,0,37,2,255,0,255,0,30,97,0,0  ; Dough from Flour
    .byte 142,4,39,1,0,38,1,10,1,255,0,60,93,1,0   ; Bread from Dough + Silver? (placeholder)
    .byte 143,4,40,1,0,24,3,11,1,255,0,90,88,2,0   ; Cake from Berry+Ruby (tasty)
    .byte 144,4,41,1,0,25,2,24,1,255,0,40,95,0,0   ; Stew from Meat+Berry
    .byte 145,4,42,1,0,25,1,31,1,255,0,50,92,1,0   ; GrilledMeat from Meat+Hammer (tool use)
    .byte 146,4,43,1,0,24,1,6,1,255,0,30,94,0,0    ; Soup from Berry+Gem (food)
    .byte 147,4,44,1,0,24,2,26,1,255,0,70,88,2,0   ; Pie from Berry+Hide
    .byte 148,4,45,1,0,37,1,33,1,255,0,120,80,2,1  ; Spell Flour (mystic)
    .byte 149,5,46,1,0,6,2,33,1,255,0,160,65,3,1   ; Enchanted Scroll from Gems+SpellTm
    .byte 150,2,47,2,0,21,3,22,1,255,0,30,98,0,0   ; Plank Bundle from Wood
    .byte 151,3,48,1,0,26,2,27,1,255,0,40,96,0,0   ; Reinforced Leather from Hide+Leather
    .byte 152,1,49,1,100,9,6,27,2,255,0,140,72,3,1 ; Heavy Armor from Iron+Leather
    .byte 153,1,50,1,80,9,4,21,2,27,1,110,78,2,0    ; Tower Shield
    .byte 154,2,51,1,0,21,1,22,2,255,0,40,95,0,0   ; Small Cart from Wood+Plank
    .byte 155,3,52,1,0,26,3,9,1,255,0,70,88,1,0    ; Tanned Straps from Hide+Iron
    .byte 156,4,53,1,0,6,1,24,1,255,0,30,96,0,0    ; Healing Salve from Gem+Berry
    .byte 157,4,54,1,0,24,2,11,1,255,0,80,90,1,0   ; Honey Jam from Berries+Ruby
    .byte 158,4,55,1,0,24,2,25,1,255,0,70,88,1,0   ; Meat Stew Deluxe
    .byte 159,4,56,1,0,37,1,24,2,255,0,30,95,0,0   ; Flatbread from Flour+Berry
    .byte 160,4,57,1,0,37,1,10,1,255,0,50,92,1,0   ; Pancake from Flour+Silver
    .byte 161,4,58,1,0,37,2,35,1,255,0,120,75,2,1  ; Sweet Bread from Flour+HealPot
    .byte 162,4,59,1,0,24,1,26,1,255,0,50,90,1,0   ; Roast Veg from Berry+Hide
    .byte 163,4,60,1,0,25,1,31,1,255,0,50,88,1,0   ; Fry Meat with Hammer (tool)
    .byte 164,4,61,1,0,24,1,6,1,255,0,40,94,1,1    ; Herbal Tea from Berry+Gem
    .byte 165,4,62,1,0,24,2,33,1,255,0,140,70,3,1   ; Mystic Pie (mystic ingredients)
    .byte 166,5,63,1,0,33,1,34,1,255,0,220,62,4,1  ; Grand Grimoire from SpellTm+MagItm
    .byte 167,1,64,1,0,9,2,10,1,255,0,80,86,1,0    ; Silver-edged Dagger
    .byte 168,2,65,1,0,21,4,22,2,255,0,140,80,2,1  ; Reinforced Beam
    .byte 169,3,66,1,0,26,4,27,2,255,0,120,78,2,0   ; Heavy Hide Armor
    .byte 170,4,67,1,0,24,1,37,1,255,0,25,97,0,0   ; Simple Flour Mix
    .byte 171,4,68,1,0,37,1,24,1,11,1,80,90,1,0    ; Fruit Tart
    .byte 172,4,69,1,0,25,2,31,1,255,0,80,88,1,0   ; Bacon & Meat Skewer
    .byte 173,4,70,1,0,24,3,25,1,255,0,160,72,2,1  ; Village Feast (large)
    .byte 174,4,71,1,0,37,2,24,2,35,1,160,70,3,1   ; Enchanted Loaf
    .byte 175,4,72,1,0,24,1,11,1,6,1,50,90,1,0     ; Herb Omelette
    .byte 176,4,73,1,0,24,1,26,1,27,1,70,88,1,0    ; Leather-wrapped Roast
    .byte 177,5,74,1,0,34,1,6,2,255,0,200,66,3,1   ; Magic Tonic
    .byte 178,4,75,1,0,24,2,37,1,11,1,140,74,2,1   ; Fruit-Filled Pie
    .byte 179,4,76,1,0,24,1,37,1,35,1,110,76,2,1   ; Sweet Pancake Stack
    .byte 180,2,77,1,0,21,1,22,1,23,1,50,95,0,0    ; Toolbox (wood components)
    .byte 181,3,78,1,0,26,2,9,1,255,0,90,86,1,0    ; Reinforced Tanned Hide
    .byte 182,4,79,1,0,24,2,11,1,33,1,120,82,2,1   ; Honeyed Cake
    .byte 183,4,80,1,0,37,1,24,1,25,1,120,80,2,1   ; Farmer's Breakfast

; End of added recipes
