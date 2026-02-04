; Everland BBS Door Main Source (C*Base)
; All I/O via modem_io.inc routines
; Game logic to be ported from everland.asm

* = $C000

#include "modem_io.inc"

start:
    ; Main Everland BBS loop (C*Base)
    JSR print_main_menu
    JSR get_menu_input
    ; ...existing code for menu selection and region logic...
    RTS

print_main_menu:
    LDX #0
print_menu_loop:
        LDA main_menu_msg,X
        BEQ print_menu_done
        JSR modem_out
        INX
        BNE print_menu_loop
print_menu_done:
    RTS

main_menu_msg:
    .byte "\r\nEVERLAND MAIN MENU:\r\n(Where memory and magic entwine)\r\n1. Play Everland\r\n2. Inventory\r\n3. High Scores\r\n4. Message Board\r\n5. Async PvP\r\n6. Save Game\r\n7. Load Game\r\n8. Portal Travel\r\n9. Quit\r\n\r\nLore: The portal shimmers with fractured memories. Quests shape the fate of Everland.\r\n> ",0

get_menu_input:
    ; Stub: get a key from modem
    LDA #'1' ; default to Play for demo
    RTS

portal_menu_msg:
    .byte "\r\nPORTAL TRAVEL:\r\nChoose a destination:\r\n1. Aurora (Land of Frost and Light)\r\n2. Lore (Kingdom of Knights and Memory)\r\n3. Mythos (Realm of Jungles and Secrets)\r\n4. Return to Everland\r\n\r\nEach region holds multi-stage quests and alternate lore events.\r\n> ",0

print_portal_menu:
    LDX #0
print_portal_menu_loop:
        LDA portal_menu_msg,X
        BEQ print_portal_menu_done
        JSR modem_out
        INX
        BNE print_portal_menu_loop
print_portal_menu_done:
    RTS

; Region stubs with enriched flavor
; --- Aurora NPCs and Quest ---
aurora_npc_menu_msg:
    .byte "\r\nAURORA NPCs:\r\n1. Speak to the Frost Weaver Queen\r\n2. Visit the Winter Wolf\r\n3. Back to Portal\r\n\r\nLore: The Queen's magic is woven from ice and light. The Winter Wolf guards the pact of Everland.\r\n> ",0
aurora_frost_queen_msg:
    .byte "\r\nThe Frost Weaver Queen intones: 'Welcome to Aurora. Only those who master the elements may join the guild.'\r\n(Quest: Learn the first frost spell.)\r\n\r\nQuest: 1) Survive the wolf's challenge. 2) Return to the Queen for your reward.\r\n",0
aurora_frost_spell_complete_msg:
    .byte "\r\nQuest complete: You have mastered the first frost spell! The Queen welcomes you to the guild.\r\n(Reward: Frost Spell added to inventory.)\r\nLore Event: The air shimmers with the memory of ancient deals and lost fortunes.\r\n",0
; --- Lore NPCs and Quest ---
lore_npc_menu_msg:
    .byte "\r\nLORE NPCs:\r\n1. Speak to Lady Cordelia\r\n2. Visit Grim the Blackheart\r\n3. Back to Portal\r\n> ",0
lore_cordelia_msg:
    .byte "\r\nLady Cordelia proclaims: 'The Order of the Black Rose stands for honor and memory. Will you take the knight's oath?'\r\n(Quest: Swear the green thorn oath.)\r\n\r\nQuest Multi-Path: 1) Uphold or break the knight's oath, 2) Duel for honor or peace, 3) Choose to protect or challenge Lore, 4) Experience alternate knight lore events based on your choice.\r\n",0
lore_knight_oath_complete_msg:
    .byte "\r\nQuest complete: You have sworn the knight's oath! Lady Cordelia welcomes you to the Order.\r\n(Reward: Black Rose Emblem added to inventory.)\r\nLore Event: Stones hold the memory of ancient gatherings, and you glimpse Everland's defenders from centuries past.\r\n",0
lore_grim_msg:
    .byte "\r\nGrim the Blackheart speaks: 'Few words, but deep loyalty. Sacrifice is the price of hope.'\r\n(Quest: Prove your loyalty in battle.)\r\n\r\nLore: The plaza stones shift, revealing a hidden passage. You glimpse Everland's defenders, their courage echoing in the heart of the park.\r\n",0
; --- Mythos NPCs and Quest ---
mythos_npc_menu_msg:
    .byte "\r\nMYTHOS NPCs:\r\n1. Speak to the Dragon Queen\r\n2. Visit the Ancient Mystic\r\n3. Back to Portal\r\n> ",0
mythos_dragon_queen_msg:
    .byte "\r\nThe Dragon Queen greets you: 'Welcome, traveler. Seek wisdom, and you may unlock the secrets of Mythos.'\r\n(Quest: Find the lost dragon scale.)\r\n\r\nQuest Multi-Path: 1) Join the dragon trainers or seek the hidden treasure, 2) Decide the fate of the loot, 3) Experience alternate dragon lore events based on your choice.\r\n",0
mythos_dragon_scale_complete_msg:
    .byte "\r\nQuest complete: You have found the lost dragon scale! The Queen rewards you with her blessing.\r\n(Reward: Dragon Scale added to inventory.)\r\nLore Event: Dragons soar through fire and sky, and you feel the ancient bond between trainer and dragon.\r\n",0
portal_aurora_msg:
    .byte "\r\nYou step through the portal and arrive in Aurora, land of frost and light. The Frost Weaver Queen awaits.\r\n\r\nMARKET: Merchants trade tales, trinkets, and legends. A coin glints near a stall, and bargains whisper through the crowd. Sometimes, the air shimmers with the memory of ancient deals and lost fortunes.\r\n",0
portal_lore_msg:
    .byte "\r\nYou step through the portal and arrive in Lore, kingdom of knights and memory. Lady Cordelia and the Order of the Black Rose stand ready.\r\n\r\nPLAZA: The heart of the park, where stones hold the memory of ancient gatherings, secret pacts, and the courage of Everland's guardians. Sometimes, the air thrums with the presence of past heroes and the choice to unite or divide.\r\n",0
portal_mythos_msg:
    .byte "\r\nYou step through the portal and arrive in Mythos, realm of jungles and secrets. The Dragon Queen and ancient mysteries await.\r\n\r\nMYSTICWOOD: Dark trees crowd together, paper charms sway from branches. Herbs and moss blanket the ground, and the air is thick with whispered lore. Rituals are sometimes performed here, and spirits are said to watch from the shadows. If you listen closely, you may feel the presence of ancient magic and glimpse a vision of the wood's past.\r\n",0
