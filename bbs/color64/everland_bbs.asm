main_menu_msg:
    .byte "\r\nEVERLAND MAIN MENU:\r\n(Where memory and magic entwine)\r\n1. Play Everland\r\n2. Inventory\r\n3. High Scores\r\n4. Message Board\r\n5. Async PvP\r\n6. Save Game\r\n7. Load Game\r\n8. Portal Travel\r\n9. Library\r\nA. Explore Special Locations\r\n0. Quit\r\n\r\nLore: The portal shimmers with fractured memories. Quests shape the fate of Everland.\r\n> ",0

main_menu:
    JSR print_main_menu
    JSR get_menu_input ; get key from user
    CMP #'1'
    BEQ menu_play
    CMP #'2'
    BEQ menu_inventory
    CMP #'3'
    BEQ menu_highscores
    CMP #'4'
    BEQ menu_message_board
    CMP #'5'
    BEQ menu_pvp
    CMP #'6'
    BEQ menu_save
    CMP #'7'
    BEQ menu_load
    CMP #'8'
    BEQ menu_portal
    CMP #'9'
    BEQ menu_library
    CMP #'A'
    BEQ menu_special_locations
    CMP #'0'
    BEQ menu_quit
    JMP main_menu ; invalid input, show menu again
menu_special_locations:
    JSR print_special_locations_menu
    JSR get_menu_input
    CMP #'1'
    BEQ loc_cursed_garden
    CMP #'2'
    BEQ loc_enchanted_grove
    CMP #'3'
    BEQ loc_hunters_hovel
    CMP #'4'
    BEQ loc_trading_company
    CMP #'5'
    BEQ loc_wedding_grove
    CMP #'6'
    BEQ loc_pumpkin_king
    CMP #'7'
    BEQ loc_kasimere
    CMP #'8'
    BEQ loc_alpha_wulfric
    CMP #'9'
    BEQ loc_lyra
    CMP #'B'
    BEQ loc_van_bueler
    CMP #'C'
    BEQ loc_cedric
    CMP #'D'
    BEQ loc_gwen
    CMP #'E'
    BEQ loc_grim
    CMP #'F'
    BEQ loc_artifacts
    CMP #'0'
    BEQ main_menu
    JMP menu_special_locations

print_special_locations_menu:
    LDX #0
print_special_locations_menu_loop:
        LDA special_locations_menu_msg,X
        BEQ print_special_locations_menu_done
        JSR modem_out
        INX
        BNE print_special_locations_menu_loop
print_special_locations_menu_done:
    RTS

special_locations_menu_msg:
    .byte "\r\nSpecial Locations & NPCs:\r\n1. Cursed Garden\r\n2. Enchanted Grove\r\n3. Hunter's Hovel\r\n4. Van Bueler's Trading Company\r\n5. Wedding Grove\r\n6. Pumpkin King\r\n7. Kasimere\r\n8. Alpha Wulfric\r\n9. Lyra\r\nB. Van Bueler\r\nC. Cedric\r\nD. Gwen\r\nE. Grim\r\nF. Artifacts\r\n0. Back to Main Menu\r\n> ",0

; Location and NPC stubs
loc_cursed_garden:
    LDX #0
    loc_cursed_garden_msg_loop:
        LDA cursed_garden_msg,X
        BEQ loc_cursed_garden_msg_done
        JSR modem_out
        INX
        BNE loc_cursed_garden_msg_loop
    loc_cursed_garden_msg_done:
    ; Multi-stage quest: Swear the green thorn oath, search for Pumpkin King, battle minions, choose to save or sacrifice Grim
    LDA quest_stage_cursed_garden
    BEQ garden_oath
    CMP #1
    BEQ garden_battle
    CMP #2
    BEQ garden_grim_choice
    JMP menu_special_locations
garden_oath:
    LDX #0
garden_oath_msg_loop:
        LDA garden_oath_msg,X
        BEQ garden_oath_msg_done
        JSR modem_out
        INX
        BNE garden_oath_msg_loop
garden_oath_msg_done:
    LDA #1
    STA quest_stage_cursed_garden
    JMP menu_special_locations
garden_battle:
    LDX #0
garden_battle_msg_loop:
        LDA garden_battle_msg,X
        BEQ garden_battle_msg_done
        JSR modem_out
        INX
        BNE garden_battle_msg_loop
garden_battle_msg_done:
    LDA #2
    STA quest_stage_cursed_garden
    JMP menu_special_locations
garden_grim_choice:
    LDX #0
garden_grim_choice_msg_loop:
        LDA garden_grim_choice_msg,X
        BEQ garden_grim_choice_msg_done
        JSR modem_out
        INX
        BNE garden_grim_choice_msg_loop
garden_grim_choice_msg_done:
    ; Branch: Save Grim or let him sacrifice himself
    JMP menu_special_locations
quest_stage_cursed_garden: .byte 0
garden_oath_msg:
    .byte "\r\nYou swear the green thorn oath. The cursed garden awakens.\r\n",0
garden_battle_msg:
    .byte "\r\nBattle the Pumpkin King's minions! Use spells or artifacts.\r\n(Choose: Cast spell, use enchanted spear, call spiders.)\r\n",0
garden_grim_choice_msg:
    .byte "\r\nGrim prepares to strike the Pumpkin King. Do you save him or let him sacrifice himself?\r\n(Choose: Save Grim, let Grim sacrifice.)\r\n",0
cursed_garden_msg:
    .byte "\r\nYou enter the cursed garden. Poisonous green thorns and deadly plants surround you. Oaths and quests are sworn here.\r\n(Interact: Take oath, search for Pumpkin King, quest triggers.)\r\n",0

loc_enchanted_grove:
    LDX #0
    loc_enchanted_grove_msg_loop:
        LDA enchanted_grove_msg,X
        BEQ loc_enchanted_grove_msg_done
        JSR modem_out
        INX
        BNE loc_enchanted_grove_msg_loop
    loc_enchanted_grove_msg_done:
    ; Multi-stage quest: Attend wedding, choose gifts, receive blessing, unlock new quest
    LDA quest_stage_grove
    BEQ grove_wedding
    CMP #1
    BEQ grove_gift
    CMP #2
    BEQ grove_blessing
    JMP menu_special_locations
grove_wedding:
    LDX #0
grove_wedding_msg_loop:
        LDA grove_wedding_msg,X
        BEQ grove_wedding_msg_done
        JSR modem_out
        INX
        BNE grove_wedding_msg_loop
grove_wedding_msg_done:
    LDA #1
    STA quest_stage_grove
    JMP menu_special_locations
grove_gift:
    LDX #0
grove_gift_msg_loop:
        LDA grove_gift_msg,X
        BEQ grove_gift_msg_done
        JSR modem_out
        INX
        BNE grove_gift_msg_loop
grove_gift_msg_done:
    LDA #2
    STA quest_stage_grove
    JMP menu_special_locations
grove_blessing:
    LDX #0
grove_blessing_msg_loop:
        LDA grove_blessing_msg,X
        BEQ grove_blessing_msg_done
        JSR modem_out
        INX
        BNE grove_blessing_msg_loop
grove_blessing_msg_done:
    ; Unlock new quest/event
    JMP menu_special_locations
quest_stage_grove: .byte 0
grove_wedding_msg:
    .byte "\r\nAttend the wedding of Damien and Delphi.\r\n",0
grove_gift_msg:
    .byte "\r\nChoose a wedding gift: enchanted crystal or spider tapestry.\r\n",0
grove_blessing_msg:
    .byte "\r\nReceive magical blessing from Bishop Cordelia. New quest unlocked!\r\n",0
enchanted_grove_msg:
    .byte "\r\nYou arrive at the enchanted grove, site of ancient weddings and magical blessings.\r\n(Interact: Attend wedding, receive blessing, quest triggers.)\r\n",0

loc_hunters_hovel:
    LDX #0
    loc_hunters_hovel_msg_loop:
        LDA hunters_hovel_msg,X
        BEQ loc_hunters_hovel_msg_done
        JSR modem_out
        INX
        BNE loc_hunters_hovel_msg_loop
    loc_hunters_hovel_msg_done:
    ; Multi-stage quest: Negotiate pact, choose provisions, defend hovel, unlock wolf ally
    LDA quest_stage_hovel
    BEQ hovel_pact
    CMP #1
    BEQ hovel_provisions
    CMP #2
    BEQ hovel_defend
    JMP menu_special_locations
hovel_pact:
    LDX #0
hovel_pact_msg_loop:
        LDA hovel_pact_msg,X
        BEQ hovel_pact_msg_done
        JSR modem_out
        INX
        BNE hovel_pact_msg_loop
hovel_pact_msg_done:
    LDA #1
    STA quest_stage_hovel
    JMP menu_special_locations
hovel_provisions:
    LDX #0
hovel_provisions_msg_loop:
        LDA hovel_provisions_msg,X
        BEQ hovel_provisions_msg_done
        JSR modem_out
        INX
        BNE hovel_provisions_msg_loop
hovel_provisions_msg_done:
    LDA #2
    STA quest_stage_hovel
    JMP menu_special_locations
hovel_defend:
    LDX #0
hovel_defend_msg_loop:
        LDA hovel_defend_msg,X
        BEQ hovel_defend_msg_done
        JSR modem_out
        INX
        BNE hovel_defend_msg_loop
hovel_defend_msg_done:
    ; Unlock wolf ally
    JMP menu_special_locations
quest_stage_hovel: .byte 0
hovel_pact_msg:
    .byte "\r\nNegotiate the Pact of Winter's Howl with Alpha Wulfric.\r\n",0
hovel_provisions_msg:
    .byte "\r\nChoose provisions for the Wolves: food, supplies, magic.\r\n",0
hovel_defend_msg:
    .byte "\r\nDefend Hunter's Hovel from threats. Wolf ally joins your party!\r\n",0
hunters_hovel_msg:
    .byte "\r\nHunter's Hovel: The Wolves of Winter gather here. Alpha Wulfric and Lyra await.\r\n(Interact: Pact of Winter's Howl, quest triggers.)\r\n",0

loc_trading_company:
    LDX #0
    loc_trading_company_msg_loop:
        LDA trading_company_msg,X
        BEQ loc_trading_company_msg_done
        JSR modem_out
        INX
        BNE loc_trading_company_msg_loop
    loc_trading_company_msg_done:
    ; Multi-stage quest: Negotiate trade, choose bargains, unlock special item
    LDA quest_stage_trading
    BEQ trading_negotiation
    CMP #1
    BEQ trading_bargain
    CMP #2
    BEQ trading_unlock
    JMP menu_special_locations
trading_negotiation:
    LDX #0
trading_negotiation_msg_loop:
        LDA trading_negotiation_msg,X
        BEQ trading_negotiation_msg_done
        JSR modem_out
        INX
        BNE trading_negotiation_msg_loop
trading_negotiation_msg_done:
    LDA #1
    STA quest_stage_trading
    JMP menu_special_locations
trading_bargain:
    LDX #0
trading_bargain_msg_loop:
        LDA trading_bargain_msg,X
        BEQ trading_bargain_msg_done
        JSR modem_out
        INX
        BNE trading_bargain_msg_loop
trading_bargain_msg_done:
    LDA #2
    STA quest_stage_trading
    JMP menu_special_locations
trading_unlock:
    LDX #0
trading_unlock_msg_loop:
        LDA trading_unlock_msg,X
        BEQ trading_unlock_msg_done
        JSR modem_out
        INX
        BNE trading_unlock_msg_loop
trading_unlock_msg_done:
    ; Unlock special item
    JMP menu_special_locations
quest_stage_trading: .byte 0
trading_negotiation_msg:
    .byte "\r\nNegotiate with Van Bueler for winter provisions.\r\n",0
trading_bargain_msg:
    .byte "\r\nChoose a bargain: rare artifact, magic scroll, food supply.\r\n",0
trading_unlock_msg:
    .byte "\r\nUnlock special item from the trading company!\r\n",0
trading_company_msg:
    .byte "\r\nVan Bueler's Trading Company: Provisions and bargains for the winter.\r\n(Interact: Trade, quest triggers.)\r\n",0

loc_wedding_grove:
    LDX #0
loc_wedding_grove_msg_loop:
        LDA wedding_grove_msg,X
        BEQ loc_wedding_grove_msg_done
        JSR modem_out
        INX
        BNE loc_wedding_grove_msg_loop
loc_wedding_grove_msg_done:
    JMP menu_special_locations
wedding_grove_msg:
    .byte "\r\nWedding Grove: Attend the union of Damien and Delphi, receive gifts, and witness ancient traditions.\r\n(Interact: Blessing, quest triggers.)\r\n",0

loc_pumpkin_king:
    LDX #0
loc_pumpkin_king_msg_loop:
        LDA pumpkin_king_msg,X
        BEQ loc_pumpkin_king_msg_done
        JSR modem_out
        INX
        BNE loc_pumpkin_king_msg_loop
loc_pumpkin_king_msg_done:
    JMP menu_special_locations
pumpkin_king_msg:
    .byte "\r\nYou confront the Pumpkin King on his throne. His eyes glow orange, and sinister laughter fills the air.\r\n(Interact: Battle, quest triggers.)\r\n",0

loc_kasimere:
    LDX #0
loc_kasimere_msg_loop:
        LDA kasimere_msg,X
        BEQ loc_kasimere_msg_done
        JSR modem_out
        INX
        BNE loc_kasimere_msg_loop
loc_kasimere_msg_done:
    JMP menu_special_locations
kasimere_msg:
    .byte "\r\nArch Magus Kasimere: Vampire lord, master of plots.\r\n(Interact: Dialogue, battle, quest triggers.)\r\n",0

loc_alpha_wulfric:
    LDX #0
loc_alpha_wulfric_msg_loop:
        LDA alpha_wulfric_msg,X
        BEQ loc_alpha_wulfric_msg_done
        JSR modem_out
        INX
        BNE loc_alpha_wulfric_msg_loop
loc_alpha_wulfric_msg_done:
    JMP menu_special_locations
alpha_wulfric_msg:
    .byte "\r\nAlpha Wulfric: Leader of the Wolves of Winter.\r\n(Interact: Pact, dialogue, quest triggers.)\r\n",0

loc_lyra:
    LDX #0
loc_lyra_msg_loop:
        LDA lyra_msg,X
        BEQ loc_lyra_msg_done
        JSR modem_out
        INX
        BNE loc_lyra_msg_loop
loc_lyra_msg_done:
    JMP menu_special_locations
lyra_msg:
    .byte "\r\nLyra: Beta of the Wolves of Winter.\r\n(Interact: Dialogue, quest triggers.)\r\n",0

loc_van_bueler:
    LDX #0
loc_van_bueler_msg_loop:
        LDA van_bueler_msg,X
        BEQ loc_van_bueler_msg_done
        JSR modem_out
        INX
        BNE loc_van_bueler_msg_loop
loc_van_bueler_msg_done:
    JMP menu_special_locations
van_bueler_msg:
    .byte "\r\nVan Bueler: Trading company owner, negotiator for the Wolves' pact.\r\n(Interact: Dialogue, trade, quest triggers.)\r\n",0

loc_cedric:
    LDX #0
loc_cedric_msg_loop:
        LDA cedric_msg,X
        BEQ loc_cedric_msg_done
        JSR modem_out
        INX
        BNE loc_cedric_msg_loop
loc_cedric_msg_done:
    JMP menu_special_locations
cedric_msg:
    .byte "\r\nCedric: Knight tempted by darkness, protected by Mage Damon.\r\n(Interact: Redemption, dialogue, quest triggers.)\r\n",0

loc_gwen:
    LDX #0
loc_gwen_msg_loop:
        LDA gwen_msg,X
        BEQ loc_gwen_msg_done
        JSR modem_out
        INX
        BNE loc_gwen_msg_loop
loc_gwen_msg_done:
    JMP menu_special_locations
gwen_msg:
    .byte "\r\nGwen: Stoic knight, mourns Grim's sacrifice.\r\n(Interact: Dialogue, quest triggers.)\r\n",0

loc_grim:
    LDX #0
loc_grim_msg_loop:
        LDA grim_msg,X
        BEQ loc_grim_msg_done
        JSR modem_out
        INX
        BNE loc_grim_msg_loop
loc_grim_msg_done:
    JMP menu_special_locations
grim_msg:
    .byte "\r\nGrim: Blackheart knight, delivers final blow to Pumpkin King.\r\n(Interact: Dialogue, quest triggers.)\r\n",0

loc_artifacts:
    LDX #0
loc_artifacts_msg_loop:
        LDA artifacts_msg,X
        BEQ loc_artifacts_msg_done
        JSR modem_out
        INX
        BNE loc_artifacts_msg_loop
loc_artifacts_msg_done:
    JMP menu_special_locations
artifacts_msg:
    .byte "\r\nArtifacts: Sun/Moon crystals, spider princess headpiece, enchanted spear.\r\n(Interact: Examine, use in quests/events.)\r\n",0
menu_library:
    JSR print_library_menu
    JSR get_menu_input
    CMP #'1'
    BEQ library_book_list
    CMP #'2'
    BEQ library_checkout
    CMP #'3'
    BEQ library_browse_pages
    CMP #'4'
    BEQ library_jump_page
    CMP #'5'
    BEQ library_leave
    JMP menu_library

print_library_menu:
    LDX #0
print_library_menu_loop:
        LDA library_menu_msg,X
        BEQ print_library_menu_done
        JSR modem_out
        INX
        BNE print_library_menu_loop
print_library_menu_done:
    RTS

library_menu_msg:
    .byte "\r\nEVERLAND LIBRARY:\r\n1. List Books\r\n2. Checkout/Focus on Book\r\n3. Browse Pages\r\n4. Jump to Page\r\n5. Leave Library\r\n> ",0

library_book_list:
    LDX #0
library_book_list_loop:
        LDA library_book_list_msg,X
        BEQ library_book_list_done
        JSR modem_out
        INX
        BNE library_book_list_loop
library_book_list_done:
    JMP menu_library

library_book_list_msg:
    .byte "\r\nAvailable Books:\r\n1. The Story of Mage Damon\r\n(More books coming soon)\r\n",0

library_checkout:
    LDX #0
library_checkout_msg_loop:
        LDA library_checkout_msg,X
        BEQ library_checkout_msg_done
        JSR modem_out
        INX
        BNE library_checkout_msg_loop
library_checkout_msg_done:
    JMP menu_library

library_checkout_msg:
    .byte "\r\nYou have checked out: The Story of Mage Damon\r\nYou may browse or jump to pages while in the library.\r\n",0

library_browse_pages:
    LDA current_page
    JSR load_library_page
    JMP menu_library
current_page: .byte 1 ; default to page 1

load_library_page:
    ; Loads and displays the current page from EVLIB1-PAGE file (device 8)
    LDX #<evlib1_filename
    LDY #>evlib1_filename
    LDA #8
    JSR open_library_file
    LDA current_page
    JSR seek_library_page
    JSR read_library_page
    JSR close_library_file
    LDX #0
load_page_msg_loop:
        LDA library_page_buf,X
        BEQ load_page_msg_done
        JSR modem_out
        INX
        CPX #255
        BNE load_page_msg_loop
load_page_msg_done:
    RTS
evlib1_filename:
    .byte "EVLIB1-PAGE",0

open_library_file:
    ; Open EVLIB1-PAGE as SEQ file for reading
    ; (Replace with actual KERNAL file open logic)
    RTS

close_library_file:
    ; Close file
    RTS

seek_library_page:
    ; Seek to the start of the requested page
    ; Each page is 255 bytes, so seek (page-1)*255
    RTS

read_library_page:
    ; Read 255 bytes into library_page_buf
    LDX #0
read_page_loop:
        ; Replace with actual file read
        LDA #32 ; space (stub)
        STA library_page_buf,X
        INX
        CPX #255
        BNE read_page_loop
    RTS

library_page_buf: .res 255,0 ; buffer for one page

; Stub: Simulate loading page from disk (replace with actual file I/O)
simulate_load_page:
    LDX #0
simulate_load_loop:
        LDA library_simulated_page,X
        STA library_page_buf,X
        INX
        BEQ simulate_load_done
        CPX #255
        BNE simulate_load_loop
simulate_load_done:
    RTS

library_simulated_page:
    .byte "Page 1: The Story of Mage Damon\r\n[Page content here]\r\n---\r\n",0

library_browse_pages_msg:
    .byte "\r\nBrowsing page 1 of 'The Story of Mage Damon'...\r\n(Page content here)\r\n",0

library_jump_page:
    JSR prompt_page_number
    JSR load_library_page
    JMP menu_library
prompt_page_number:
    ; Stub: Set current_page to 1 (replace with input logic)
    LDA #1
    STA current_page
    RTS

library_jump_page_msg:
    .byte "\r\nJump to a specific page in 'The Story of Mage Damon'.\r\n(Page content here)\r\n",0

library_leave:
    LDX #0
library_leave_msg_loop:
        LDA library_leave_msg,X
        BEQ library_leave_msg_done
        JSR modem_out
        INX
        BNE library_leave_msg_loop
library_leave_msg_done:
    JMP main_menu

library_leave_msg:
    .byte "\r\nYou return your book and leave the library.\r\n",0
; --- Portal Travel System ---
portal_menu_msg:
    .byte "\r\nPORTAL TRAVEL:\r\nChoose a destination:\r\n1. Aurora (Land of Frost and Light)\r\n2. Lore (Kingdom of Knights and Memory)\r\n3. Mythos (Realm of Jungles and Secrets)\r\n4. Return to Everland\r\n\r\nEach region holds multi-stage quests and alternate lore events.\r\n> ",0

menu_portal:
    JSR print_portal_menu
    JSR get_menu_input
    CMP #'1'
    BEQ portal_aurora
    CMP #'2'
    BEQ portal_lore
    CMP #'3'
    BEQ portal_mythos
    CMP #'4'
    BEQ portal_everland
    JMP menu_portal ; invalid input, show menu again

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

portal_aurora:
    ; Aurora region logic, NPCs, quest stubs
    LDX #0
portal_aurora_msg_loop:
        LDA portal_aurora_msg,X
        BEQ portal_aurora_msg_done
        JSR modem_out
        INX
        BNE portal_aurora_msg_loop
portal_aurora_msg_done:
    JSR aurora_npc_menu
    JMP menu_portal
portal_aurora_msg:
    .byte "\r\nYou step through the portal and arrive in Aurora, land of frost and light. The Frost Weaver Queen awaits.\r\n\r\nMARKET: Merchants trade tales, trinkets, and legends. A coin glints near a stall, and bargains whisper through the crowd. Sometimes, the air shimmers with the memory of ancient deals and lost fortunes.\r\n",0

aurora_npc_menu:
    LDX #0
aurora_npc_menu_msg_loop:
        LDA aurora_npc_menu_msg,X
        BEQ aurora_npc_menu_msg_done
        JSR modem_out
        INX
        BNE aurora_npc_menu_msg_loop
aurora_npc_menu_msg_done:
    JSR get_menu_input
    CMP #'1'
    BEQ aurora_frost_queen
    CMP #'2'
    BEQ aurora_winter_wolf
    CMP #'3'
    BEQ aurora_back
    JMP aurora_npc_menu
aurora_npc_menu_msg:
    .byte "\r\nAURORA NPCs:\r\n1. Speak to the Frost Weaver Queen\r\n2. Visit the Winter Wolf\r\n3. Back to Portal\r\n\r\nLore: The Queen's magic is woven from ice and light. The Winter Wolf guards the pact of Everland.\r\n> ",0

aurora_frost_queen:
    LDX #0
aurora_frost_queen_msg_loop:
        LDA aurora_frost_queen_msg,X
        BEQ aurora_frost_queen_msg_done
        JSR modem_out
        INX
        BNE aurora_frost_queen_msg_loop
aurora_frost_queen_msg_done:
    ; Quest logic: if not started, start quest
    LDA aurora_quest_frost_spell
    BEQ aurora_start_frost_spell
    CMP #2
    BEQ aurora_frost_spell_complete
    JMP aurora_npc_menu
aurora_start_frost_spell:
    LDA #1
    STA aurora_quest_frost_spell
    LDX #0
aurora_frost_spell_start_msg_loop:
        LDA aurora_frost_spell_start_msg,X
        BEQ aurora_frost_spell_start_msg_done
        JSR modem_out
        INX
        BNE aurora_frost_spell_start_msg_loop
aurora_frost_spell_start_msg_done:
    JMP aurora_npc_menu
aurora_frost_spell_complete:
    LDX #0
aurora_frost_spell_complete_msg_loop:
        LDA aurora_frost_spell_complete_msg,X
        BEQ aurora_frost_spell_complete_msg_done
        JSR modem_out
        INX
        BNE aurora_frost_spell_complete_msg_loop
aurora_frost_spell_complete_msg_done:
    JMP aurora_npc_menu
aurora_frost_queen_msg:
    .byte "\r\nThe Frost Weaver Queen intones: 'Welcome to Aurora. Only those who master the elements may join the guild.'\r\n(Quest: Learn the first frost spell.)\r\n",0
aurora_quest_frost_spell: .byte 0 ; 0=not started, 1=started, 2=complete
aurora_frost_spell_start_msg:
    .byte "\r\nQuest started: Learn the first frost spell! Seek the Winter Wolf for guidance.\r\nStage 1: Survive the wolf's challenge.\r\nStage 2: Return to the Queen for your reward.\r\n",0
aurora_frost_spell_complete_msg:
    .byte "\r\nQuest complete: You have mastered the first frost spell! The Queen welcomes you to the guild.\r\n(Reward: Frost Spell added to inventory.)\r\nLore Event: The air shimmers with the memory of ancient deals and lost fortunes.\r\n",0

aurora_winter_wolf:
    LDX #0
aurora_winter_wolf_msg_loop:
        LDA aurora_winter_wolf_msg,X
        BEQ aurora_winter_wolf_msg_done
        JSR modem_out
        INX
        BNE aurora_winter_wolf_msg_loop
aurora_winter_wolf_msg_done:
    ; Quest logic: if frost spell quest started and not complete, complete it
    LDA aurora_quest_frost_spell
    CMP #1
    BNE aurora_npc_menu
    LDA #2
    STA aurora_quest_frost_spell
    LDX #0
aurora_wolf_challenge_msg_loop:
        LDA aurora_wolf_challenge_msg,X
        BEQ aurora_wolf_challenge_msg_done
        JSR modem_out
        INX
        BNE aurora_wolf_challenge_msg_loop
aurora_wolf_challenge_msg_done:
    JMP aurora_npc_menu
aurora_winter_wolf_msg:
    .byte "\r\nThe Winter Wolf howls: 'Survive the trials of winter, and you may earn the Pact of Winter’s Howl.'\r\n(Quest: Endure the wolf’s challenge.)\r\n",0
aurora_wolf_challenge_msg:
    .byte "\r\nYou endure the wolf’s challenge and learn the frost spell! Return to the Queen for your reward.\r\n",0

aurora_back:
    JMP menu_portal

portal_lore:
    ; Lore region logic, NPCs, quest stubs
    LDX #0
portal_lore_msg_loop:
        LDA portal_lore_msg,X
        BEQ portal_lore_msg_done
        JSR modem_out
        INX
        BNE portal_lore_msg_loop
portal_lore_msg_done:
    JSR lore_npc_menu
    JMP menu_portal
portal_lore_msg:
    .byte "\r\nYou step through the portal and arrive in Lore, kingdom of knights and memory. Lady Cordelia and the Order of the Black Rose stand ready.\r\n\r\nPLAZA: The heart of the park, where stones hold the memory of ancient gatherings, secret pacts, and the courage of Everland's guardians. Sometimes, the air thrums with the presence of past heroes and the choice to unite or divide.\r\n",0

lore_npc_menu:
    LDX #0
lore_npc_menu_msg_loop:
        LDA lore_npc_menu_msg,X
        BEQ lore_npc_menu_msg_done
        JSR modem_out
        INX
        BNE lore_npc_menu_msg_loop
lore_npc_menu_msg_done:
    JSR get_menu_input
    CMP #'1'
    BEQ lore_cordelia
    CMP #'2'
    BEQ lore_grim
    CMP #'3'
    BEQ lore_back
    JMP lore_npc_menu
lore_npc_menu_msg:
    .byte "\r\nLORE NPCs:\r\n1. Speak to Lady Cordelia\r\n2. Visit Grim the Blackheart\r\n3. Back to Portal\r\n> ",0

lore_cordelia:
    LDX #0
lore_cordelia_msg_loop:
        LDA lore_cordelia_msg,X
        BEQ lore_cordelia_msg_done
        JSR modem_out
        INX
        BNE lore_cordelia_msg_loop
lore_cordelia_msg_done:
    JMP lore_npc_menu
; Lore quest flags: 0=not started, 1=started, 2=complete
lore_quest_knight_oath: .byte 0

    JMP lore_npc_menu
    LDX #0
lore_cordelia_msg_loop:
        LDA lore_cordelia_msg,X
        BEQ lore_cordelia_msg_done
        JSR modem_out
        INX
        BNE lore_cordelia_msg_loop
lore_cordelia_msg_done:
    ; Quest logic: if not started, start quest
    LDA lore_quest_knight_oath
    BEQ lore_start_knight_oath
    CMP #2
    BEQ lore_knight_oath_complete
    JMP lore_npc_menu
lore_start_knight_oath:
    LDA #1
    STA lore_quest_knight_oath
    LDX #0
lore_knight_oath_start_msg_loop:
        LDA lore_knight_oath_start_msg,X
        BEQ lore_knight_oath_start_msg_done
        JSR modem_out
        INX
        BNE lore_knight_oath_start_msg_loop
lore_knight_oath_start_msg_done:
    JMP lore_npc_menu
lore_knight_oath_complete:
    LDX #0
lore_knight_oath_complete_msg_loop:
        LDA lore_knight_oath_complete_msg,X
        BEQ lore_knight_oath_complete_msg_done
        JSR modem_out
        INX
        BNE lore_knight_oath_complete_msg_loop
lore_knight_oath_complete_msg_done:
    JMP lore_npc_menu
lore_cordelia_msg:
    .byte "\r\nLady Cordelia proclaims: 'The Order of the Black Rose stands for honor and memory. Will you take the knight's oath?'\r\n(Quest: Swear the green thorn oath.)\r\n\r\nQuest Multi-Path: 1) Uphold or break the knight's oath, 2) Duel for honor or peace, 3) Choose to protect or challenge Lore, 4) Experience alternate knight lore events based on your choice.\r\n",0
lore_knight_oath_start_msg:
    .byte "\r\nQuest started: Swear the green thorn oath! Seek Grim the Blackheart for your trial.\r\n",0
lore_knight_oath_complete_msg:
    .byte "\r\nQuest complete: You have sworn the knight's oath! Lady Cordelia welcomes you to the Order.\r\n(Reward: Black Rose Emblem added to inventory.)\r\nLore Event: Stones hold the memory of ancient gatherings, and you glimpse Everland's defenders from centuries past.\r\n",0
lore_grim:
    LDX #0
lore_grim_msg_loop:
        LDA lore_grim_msg,X
        BEQ lore_grim_msg_done
        JSR modem_out
        INX
        BNE lore_grim_msg_loop
lore_grim_msg_done:
    ; Quest logic: if knight oath quest started and not complete, complete it
    LDA lore_quest_knight_oath
    CMP #1
    BNE lore_npc_menu
    LDA #2
    STA lore_quest_knight_oath
    LDX #0
lore_grim_trial_msg_loop:
        LDA lore_grim_trial_msg,X
        BEQ lore_grim_trial_msg_done
        JSR modem_out
        INX
        BNE lore_grim_trial_msg_loop
lore_grim_trial_msg_done:
    JMP lore_npc_menu
lore_grim_msg:
    .byte "\r\nGrim the Blackheart speaks: 'Few words, but deep loyalty. Sacrifice is the price of hope.'\r\n(Quest: Prove your loyalty in battle.)\r\n\r\nLore: The plaza stones shift, revealing a hidden passage. You glimpse Everland's defenders, their courage echoing in the heart of the park.\r\n",0
lore_grim_trial_msg:
    .byte "\r\nYou have proven your loyalty in battle! Return to Lady Cordelia for your reward.\r\n",0
        JSR modem_out
        INX
        BNE portal_mythos_msg_loop
portal_mythos_msg_done:
    JSR mythos_npc_menu
    JMP menu_portal
portal_mythos_msg:
    .byte "\r\nYou step through the portal and arrive in Mythos, realm of jungles and secrets. The Dragon Queen and ancient mysteries await.\r\n\r\nMYSTICWOOD: Dark trees crowd together, paper charms sway from branches. Herbs and moss blanket the ground, and the air is thick with whispered lore. Rituals are sometimes performed here, and spirits are said to watch from the shadows. If you listen closely, you may feel the presence of ancient magic and glimpse a vision of the wood's past.\r\n",0

mythos_npc_menu:
    LDX #0
mythos_npc_menu_msg_loop:
        LDA mythos_npc_menu_msg,X
        BEQ mythos_npc_menu_msg_done
        JSR modem_out
        INX
        BNE mythos_npc_menu_msg_loop
mythos_npc_menu_msg_done:
    JSR get_menu_input
    CMP #'1'
    BEQ mythos_dragon_queen
    CMP #'2'
    BEQ mythos_ancient_mystic
    CMP #'3'
    BEQ mythos_back
    JMP mythos_npc_menu
mythos_npc_menu_msg:
    .byte "\r\nMYTHOS NPCs:\r\n1. Speak to the Dragon Queen\r\n2. Visit the Ancient Mystic\r\n3. Back to Portal\r\n> ",0

; Mythos quest flags: 0=not started, 1=started, 2=complete
mythos_quest_dragon_scale: .byte 0

mythos_dragon_queen:
    LDX #0
mythos_dragon_queen_msg_loop:
        LDA mythos_dragon_queen_msg,X
        BEQ mythos_dragon_queen_msg_done
        JSR modem_out
        INX
        BNE mythos_dragon_queen_msg_loop
mythos_dragon_queen_msg_done:
    ; Quest logic: if not started, start quest
    LDA mythos_quest_dragon_scale
    BEQ mythos_start_dragon_scale
    CMP #2
    BEQ mythos_dragon_scale_complete
    JMP mythos_npc_menu
mythos_start_dragon_scale:
    LDA #1
    STA mythos_quest_dragon_scale
    LDX #0
mythos_dragon_scale_start_msg_loop:
        LDA mythos_dragon_scale_start_msg,X
        BEQ mythos_dragon_scale_start_msg_done
        JSR modem_out
        INX
        BNE mythos_dragon_scale_start_msg_loop
mythos_dragon_scale_start_msg_done:
    JMP mythos_npc_menu
mythos_dragon_scale_complete:
    LDX #0
mythos_dragon_scale_complete_msg_loop:
        LDA mythos_dragon_scale_complete_msg,X
        BEQ mythos_dragon_scale_complete_msg_done
        JSR modem_out
        INX
        BNE mythos_dragon_scale_complete_msg_loop
mythos_dragon_scale_complete_msg_done:
    JMP mythos_npc_menu
mythos_dragon_queen_msg:
    .byte "\r\nThe Dragon Queen greets you: 'Welcome, traveler. Seek wisdom, and you may unlock the secrets of Mythos.'\r\n(Quest: Find the lost dragon scale.)\r\n\r\nQuest Multi-Path: 1) Join the dragon trainers or seek the hidden treasure, 2) Decide the fate of the loot, 3) Experience alternate dragon lore events based on your choice.\r\n",0
mythos_dragon_scale_start_msg:
    .byte "\r\nQuest started: Find the lost dragon scale! Seek the Ancient Mystic for clues.\r\n",0
mythos_dragon_scale_complete_msg:
    .byte "\r\nQuest complete: You have found the lost dragon scale! The Queen rewards you with her blessing.\r\n(Reward: Dragon Scale added to inventory.)\r\nLore Event: Dragons soar through fire and sky, and you feel the ancient bond between trainer and dragon.\r\n",0

mythos_ancient_mystic:
    LDX #0
mythos_ancient_mystic_msg_loop:
        LDA mythos_ancient_mystic_msg,X
        BEQ mythos_ancient_mystic_msg_done
        JSR modem_out
        INX
        BNE mythos_ancient_mystic_msg_loop
mythos_ancient_mystic_msg_done:
    ; Quest logic: if dragon scale quest started and not complete, complete it
    LDA mythos_quest_dragon_scale
    CMP #1
    BNE mythos_npc_menu
    LDA #2
    STA mythos_quest_dragon_scale
    LDX #0
mythos_mystic_riddle_msg_loop:
        LDA mythos_mystic_riddle_msg,X
        BEQ mythos_mystic_riddle_msg_done
        JSR modem_out
        INX
        BNE mythos_mystic_riddle_msg_loop
mythos_mystic_riddle_msg_done:
    JMP mythos_npc_menu
mythos_ancient_mystic_msg:
    .byte "\r\nThe Ancient Mystic whispers: 'The jungle hides many secrets. Only those who remember Everland’s lore will succeed.'\r\n(Quest: Solve the riddle of the jungle spirits.)\r\n",0
mythos_mystic_riddle_msg:
    .byte "\r\nYou have solved the riddle of the jungle spirits and found the dragon scale! Return to the Queen for your reward.\r\n",0

mythos_back:
    JMP menu_portal

portal_everland:
    LDX #0
portal_everland_msg_loop:
        LDA portal_everland_msg,X
        BEQ portal_everland_msg_done
        JSR modem_out
        INX
        BNE portal_everland_msg_loop
portal_everland_msg_done:
    JMP main_menu
portal_everland_msg:
    .byte "\r\nYou return through the portal to Everland, where your journey began.\r\n",0

menu_play:
    JSR start_game
    JMP main_menu
menu_inventory:
    JSR print_inventory
    JMP main_menu
menu_highscores:
    JSR print_highscores
    JMP main_menu
menu_message_board:
    JSR msg_board_menu
    JMP main_menu
menu_pvp:
    JSR pvp_menu
    JMP main_menu
menu_save:
    JSR save_game
    JMP main_menu
menu_load:
    JSR load_game
    JMP main_menu
menu_quit:
    JSR print_goodbye
    RTS
get_menu_input:
    ; Stub: get a key from modem
    LDA #'1' ; default to Play for demo
    RTS
msg_board_menu:
    JSR print_msg_board_menu
msg_board_menu_input:
    JSR get_menu_input
    CMP #'1'
    BEQ msg_board_read
    CMP #'2'
    BEQ msg_board_post
    CMP #'3'
    BEQ msg_board_back
    JMP msg_board_menu_input
msg_board_read:
    JSR read_messages
    JMP msg_board_menu
msg_board_post:
    JSR post_message
    JMP msg_board_menu
msg_board_back:
    RTS
print_msg_board_menu:
    LDX #0
print_msg_board_menu_loop:
        LDA msg_board_menu_msg,X
        BEQ print_msg_board_menu_done
        JSR modem_out
        INX
        BNE print_msg_board_menu_loop
print_msg_board_menu_done:
    RTS
pvp_menu:
    JSR print_pvp_menu
pvp_menu_input:
    JSR get_menu_input
    CMP #'1'
    BEQ pvp_challenge
    CMP #'2'
    BEQ pvp_view
    CMP #'3'
    BEQ pvp_back
    JMP pvp_menu_input
pvp_challenge:
    JSR challenge_player
    JMP pvp_menu
pvp_view:
    JSR view_pvp_results
    JMP pvp_menu
pvp_back:
    RTS
print_pvp_menu:
    LDX #0
print_pvp_menu_loop:
        LDA pvp_menu_msg,X
        BEQ print_pvp_menu_done
        JSR modem_out
        INX
        BNE print_pvp_menu_loop
print_pvp_menu_done:
    RTS
print_goodbye:
    LDX #0
print_goodbye_loop:
        LDA goodbye_msg,X
        BEQ print_goodbye_done
        JSR modem_out
        INX
        BNE print_goodbye_loop
print_goodbye_done:
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
; --- High Score System ---
.segment "BSS"
player_score: .byte 0
player_name: .res 8,0 ; 8-char name
highscore_table: .res 10,0 ; 10 scores max
highscore_names: .res 80,0 ; 10 names x 8 chars

; Insert player_score and player_name in sorted order
insert_highscore:
    LDY #0
find_spot:
        LDA player_score
        CMP highscore_table,Y
        BCC found_spot
        INY
        CPY #10
        BNE find_spot
found_spot:
    ; Shift scores/names down
    LDX #9
shift_loop:
        LDA highscore_table,X
        STA highscore_table+1,X
        LDA highscore_names+(X*8)
        STA highscore_names+8+(X*8)
        INX
        CPX Y
        BNE shift_loop
    ; Insert new score/name
    LDA player_score
    STA highscore_table,Y
    LDX #0
insert_name_loop:
        LDA player_name,X
        STA highscore_names+(Y*8),X
        INX
        CPX #8
        BNE insert_name_loop
    RTS

; Print high score table (names and scores)
print_highscores:
    LDX #0
print_highscore_msg_loop:
    LDA highscore_msg,X
    BEQ print_highscore_msg_done
    JSR modem_out
    INX
    BNE print_highscore_msg_loop
print_highscore_msg_done:
    LDY #0
print_hs_loop:
        LDX #0
print_hs_name_loop:
            LDA highscore_names+(Y*8),X
            BEQ print_hs_name_done
            JSR modem_out
            INX
            CPX #8
            BNE print_hs_name_loop
print_hs_name_done:
        LDA ' '
        JSR modem_out
        LDA highscore_table,Y
        JSR print_decimal ; stub: print as decimal
        LDA 13
        JSR modem_out
        INY
        CPY #10
        BNE print_hs_loop
    RTS
.segment "RODATA"
pvp_filename:
    .byte "EV1PVP",0
.segment "RODATA"
msg_board_filename:
    .byte "EV1MSG",0
.segment "RODATA"
highscore_filename:
    .byte "EV1HS",0
.segment "BSS"
pvp_result_buf: .res 32,0 ; 32 bytes for async PvP results
pvp_menu_msg:
    .byte "Async PvP Arena:\r\nBattle echoes of Grim and the knights—where oaths and memory shape fate.\r\n1. Challenge Player\r\n2. View Results\r\n3. Back\r\n> ",0
pvp_challenge_ok_msg:
    .byte "Challenge sent.",13,0
pvp_results_msg:
    .byte "PvP Results:",13,0
challenge_player:
    ; Save highscore_table to disk (device 8)
    LDX #<highscore_filename
    LDY #>highscore_filename
    LDA #8
    JSR open_save_write
    LDX #0
save_hs_write_loop:
        LDA highscore_table,X
        JSR save_write_byte
        INX
        CPX #10
        BNE save_hs_write_loop
    JSR close_save
    ; Post a message (append to buffer, save to disk)
    ; For demo: just write a fixed message to buffer
    LDX #0
    LDA #'H'
    STA msg_board_buf,X
    INX
    LDA #'i'
    STA msg_board_buf,X
    INX
    LDA #13
    STA msg_board_buf,X
    INX
    LDA #0
    STA msg_board_buf,X
    ; Save buffer to disk
    LDX #<msg_board_filename
    LDY #>msg_board_filename
    LDA #8
    JSR open_save_write
    LDX #0
post_msg_write_loop:
        LDA msg_board_buf,X
        JSR save_write_byte
        INX
        CPX #256
        BNE post_msg_write_loop
    JSR close_save
    JSR print_post_ok
    ; Challenge a player (append result, save to disk)
    ; For demo: write a fixed result to buffer
    LDX #0
    LDA #'W'
    STA pvp_result_buf,X
    INX
    LDA #'i'
    STA pvp_result_buf,X
    INX
    LDA #'n'
    STA pvp_result_buf,X
    INX
    LDA #13
    STA pvp_result_buf,X
    INX
    LDA #0
    STA pvp_result_buf,X
    ; Save buffer to disk
    LDX #<pvp_filename
    LDY #>pvp_filename
    LDA #8
    JSR open_save_write
    LDX #0
challenge_write_loop:
        LDA pvp_result_buf,X
        JSR save_write_byte
        INX
        CPX #32
        BNE challenge_write_loop
    JSR close_save
    JSR print_pvp_challenge_ok
    RTS
view_pvp_results:
    ; Load highscore_table from disk (device 8)
    LDX #<highscore_filename
    LDY #>highscore_filename
    LDA #8
    JSR open_save_read
    LDX #0
load_hs_read_loop:
        JSR save_read_byte
        STA highscore_table,X
        INX
        CPX #10
        BNE load_hs_read_loop
    JSR close_save
    ; Load buffer from disk and print
    LDX #<msg_board_filename
    LDY #>msg_board_filename
    LDA #8
    JSR open_save_read
    LDX #0
read_msg_read_loop:
        JSR save_read_byte
        STA msg_board_buf,X
        INX
        CPX #256
        BNE read_msg_read_loop
    JSR close_save
    LDX #0
read_msg_print_loop:
        LDA msg_board_buf,X
        BEQ read_msg_print_done
        JSR modem_out
        INX
        BNE read_msg_print_loop
read_msg_print_done:
    JSR print_read_ok
    ; Load buffer from disk and print
    LDX #<pvp_filename
    LDY #>pvp_filename
    LDA #8
    JSR open_save_read
    LDX #0
view_pvp_read_loop:
        JSR save_read_byte
        STA pvp_result_buf,X
        INX
        CPX #32
        BNE view_pvp_read_loop
    JSR close_save
    LDX #0
view_pvp_print_loop:
        LDA pvp_result_buf,X
        BEQ view_pvp_print_done
        JSR modem_out
        INX
        BNE view_pvp_print_loop
view_pvp_print_done:
    JSR print_pvp_results
    RTS
print_pvp_challenge_ok:
    LDX #0
print_pvp_challenge_ok_loop:
        LDA pvp_challenge_ok_msg,X
        BEQ print_pvp_challenge_ok_done
        JSR modem_out
        INX
        BNE print_pvp_challenge_ok_loop
print_pvp_challenge_ok_done:
    RTS
print_pvp_results:
    LDX #0
print_pvp_results_msg_loop:
        LDA pvp_results_msg,X
        BEQ print_pvp_results_msg_done
        JSR modem_out
        INX
        BNE print_pvp_results_msg_loop
print_pvp_results_msg_done:
    RTS
print_post_ok:
    LDX #0
print_post_ok_loop:
        LDA msg_post_ok_msg,X
        BEQ print_post_ok_done
        JSR modem_out
        INX
        BNE print_post_ok_loop
print_post_ok_done:
    RTS
print_read_ok:
    LDX #0
print_read_ok_loop:
        LDA msg_read_ok_msg,X
        BEQ print_read_ok_done
        JSR modem_out
        INX
        BNE print_read_ok_loop
print_read_ok_done:
    RTS
.segment "BSS"
msg_board_buf: .res 256,0 ; 256 bytes for messages
msg_board_menu_msg:
    .byte "Everland Message Board:\r\nShare tales of the portal, the cursed garden, and the Order of the Black Rose.\r\n1. Read Messages\r\n2. Post Message\r\n3. Back\r\n> ",0
msg_post_ok_msg:
    .byte "Message posted.",13,0

take_item:
    LDA cur_loc
    CMP #0
    BEQ take_from_0
    CMP #1
    BEQ take_from_1
    CMP #2
    BEQ take_from_2
    CMP #3
    BEQ take_from_3
    CMP #4
    BEQ take_from_4
    CMP #5
    BEQ take_from_5
    JMP nothing_to_take

take_from_0:
    ; Start: nothing to take
    JMP nothing_to_take

take_from_1:
    ; Clearing: KEY
    LDA inv_has_key
    BNE already_have_item
    LDA #1
    STA inv_has_key
    JSR update_score
    LDX #0
take_key_msg_loop:
        LDA take_key_msg,X
        BEQ take_key_msg_done
        JSR modem_out
        INX
        BNE take_key_msg_loop
take_key_msg_done:
    RTS

take_from_2:
    ; Cave: LAMP
    LDA inv_has_lamp
    BNE already_have_item
    LDA #1
    STA inv_has_lamp
    JSR update_score
    LDX #0
take_lamp_msg_loop:
        LDA take_lamp_msg,X
        BEQ take_lamp_msg_done
        JSR modem_out
        INX
        BNE take_lamp_msg_loop
take_lamp_msg_done:
    RTS

take_from_3:
    ; Forest Path: ROPE
    LDA inv_has_rope
    BNE already_have_item
    LDA #1
    STA inv_has_rope
    JSR update_score
    LDX #0
take_rope_msg_loop:
        LDA take_rope_msg,X
        BEQ take_rope_msg_done
        JSR modem_out
        INX
        BNE take_rope_msg_loop
take_rope_msg_done:
    RTS

take_from_4:
    ; Riverbank: FISHING ROD
    LDA inv_has_rod
    BNE already_have_item
    LDA #1
    STA inv_has_rod
    JSR update_score
    LDX #0
take_rod_msg_loop:
        LDA take_rod_msg,X
        BEQ take_rod_msg_done
        JSR modem_out
        INX
        BNE take_rod_msg_loop
take_rod_msg_done:
    RTS

take_from_5:
    ; Meadow: COINS
    LDA inv_has_coins
    BNE already_have_item
    LDA #1
    STA inv_has_coins
    JSR update_score
    LDX #0
take_coins_msg_loop:
        LDA take_coins_msg,X
        BEQ take_coins_msg_done
        JSR modem_out
        INX
        BNE take_coins_msg_loop
take_coins_msg_done:
    RTS
        LDA gate_unlocked_msg,X
        BEQ print_gate_unlocked_done
        JSR modem_out
        INX
        BNE print_gate_unlocked_msg
print_gate_unlocked_done:
gate_is_unlocked:
    LDA #6
    STA cur_loc
    JSR print_location
    RTS
gate_locked:
    LDX #0
print_gate_locked_msg:
        LDA gate_locked_msg,X
        BEQ print_gate_locked_done
        JSR modem_out
        INX
        BNE print_gate_locked_msg
print_gate_locked_done:
    RTS
move_east_from_6:
    ; Can't go east from gate
    JMP invalid_move
    JSR open_save_read
    LDX #0
load_read_loop:
    JSR save_read_byte
    STA savebuf,X
    INX
    CPX #6
    BNE load_read_loop
    JSR close_save
    LDX #0
    LDA savebuf,X
    STA cur_loc
    INX
    LDA savebuf,X
    STA inv_has_key
    INX
    LDA savebuf,X
    STA inv_has_rope
    INX
    LDA savebuf,X
    STA inv_has_lamp
    INX
    LDA savebuf,X
    STA inv_has_rod
    INX
    LDA savebuf,X
    STA inv_has_coins
    JSR print_load_ok
    RTS

.segment "BSS"
savebuf: .res 6,0

.segment "RODATA"
save_filename:
    .byte "EV1SAVE",0

; --- Save/Load I/O stubs (to be implemented with KERNAL or BBS routines) ---
open_save_write:
    RTS
open_save_read:
    RTS
save_write_byte:
    RTS
save_read_byte:
    LDA #0
    RTS
close_save:
    RTS

print_save_ok:
    LDX #0
print_save_ok_loop:
    LDA save_ok_msg,X
    BEQ print_save_ok_done
    JSR modem_out
    INX
    BNE print_save_ok_loop
print_save_ok_done:
    RTS
print_load_ok:
    LDX #0
print_load_ok_loop:
    LDA load_ok_msg,X
    BEQ print_load_ok_done
    JSR modem_out
    INX
    BNE print_load_ok_loop
print_load_ok_done:
    RTS

save_ok_msg:
    .byte "Game saved.",13,0
load_ok_msg:
    .byte "Game loaded.",13,0

menu_msg_ext:
    .text "\r\nMAIN MENU:\r\n1. Play Everland\r\n2. Inventory\r\n3. Save Game\r\n4. Load Game\r\n5. Quit\r\n> "
    .byte 0
inv_has_rod: .byte 0
inv_has_coins: .byte 0
loc4_msg:
    .text "\r\nYou are at a peaceful riverbank. A FISHING ROD leans against a tree.\r\nExits: W,E\r\n"
    .byte 0
loc5_msg:
    .text "\r\nYou are in a wildflower meadow. Some COINS glint in the grass.\r\nExits: W\r\n"
    .byte 0
inv_has_lamp: .byte 0
loc3_msg:
    .text "\r\nYou stand before a dark cave entrance. A battered LAMP sits on a rock.\r\nExits: S\r\n"
    .byte 0
inv_has_rope: .byte 0
inv_has_frost_spell: .byte 0
inv_has_black_rose: .byte 0
inv_has_dragon_scale: .byte 0
loc2_msg:
    .text "\r\nYou are at the edge of an old well. A length of ROPE lies coiled nearby.\r\nExits: S\r\n"
    .byte 0

move_east:
            LDX #0
            LDA inv_has_key
            BEQ skip_key
        inv_key_msg_loop:
                LDA inv_key_msg,X
                BEQ inv_key_msg_done
                JSR modem_out
                INX
                BNE inv_key_msg_loop
        inv_key_msg_done:
            LDX #0
        skip_key:
            LDA inv_has_lamp
            BEQ skip_lamp
        inv_lamp_msg_loop:
                LDA inv_lamp_msg,X
                BEQ inv_lamp_msg_done
                JSR modem_out
                INX
                BNE inv_lamp_msg_loop
        inv_lamp_msg_done:
            LDX #0
        skip_lamp:
            LDA inv_has_rope
            BEQ skip_rope
        inv_rope_msg_loop:
                LDA inv_rope_msg,X
                BEQ inv_rope_msg_done
                JSR modem_out
                INX
                BNE inv_rope_msg_loop
        inv_rope_msg_done:
            LDX #0
        skip_rope:
            LDA inv_has_rod
            BEQ skip_rod
        inv_rod_msg_loop:
                LDA inv_rod_msg,X
                BEQ inv_rod_msg_done
                JSR modem_out
                INX
                BNE inv_rod_msg_loop
        inv_rod_msg_done:
            LDX #0
        skip_rod:
            LDA inv_has_coins
            BEQ skip_coins
        inv_coins_msg_loop:
                LDA inv_coins_msg,X
                BEQ inv_coins_msg_done
                JSR modem_out
                INX
                BNE inv_coins_msg_loop
        inv_coins_msg_done:
            LDX #0
        skip_coins:
            LDA inv_has_frost_spell
            BEQ skip_frost_spell
        inv_frost_spell_msg_loop:
                LDA inv_frost_spell_msg,X
                BEQ inv_frost_spell_msg_done
                JSR modem_out
                INX
                BNE inv_frost_spell_msg_loop
        inv_frost_spell_msg_done:
            LDX #0
        skip_frost_spell:
            LDA inv_has_black_rose
            BEQ skip_black_rose
        inv_black_rose_msg_loop:
                LDA inv_black_rose_msg,X
                BEQ inv_black_rose_msg_done
                JSR modem_out
                INX
                BNE inv_black_rose_msg_loop
        inv_black_rose_msg_done:
            LDX #0
        skip_black_rose:
            LDA inv_has_dragon_scale
            BEQ skip_dragon_scale
        inv_dragon_scale_msg_loop:
                LDA inv_dragon_scale_msg,X
                BEQ inv_dragon_scale_msg_done
                JSR modem_out
                INX
                BNE inv_dragon_scale_msg_loop
        inv_dragon_scale_msg_done:
            LDX #0
        skip_dragon_scale:
            RTS
    inv_frost_spell_msg:
        .byte "\r\nFrost Spell (Aurora)\r\n",0
    inv_black_rose_msg:
        .byte "\r\nBlack Rose Emblem (Lore)\r\n",0
    inv_dragon_scale_msg:
        .byte "\r\nDragon Scale (Mythos)\r\n",0
            JSR modem_out
            INX
            BNE take_key_msg_loop
    take_key_msg_done:
        RTS
    take_from_2:
        ; Cave: LAMP
        LDA inv_has_lamp
        BNE already_have_item
        LDA #1
        STA inv_has_lamp
        LDX #0
    take_lamp_msg_loop:
            LDA take_lamp_msg,X
            BEQ take_lamp_msg_done
            JSR modem_out
            INX
            BNE take_lamp_msg_loop
    take_lamp_msg_done:
        RTS
    take_from_3:
        ; Forest Path: ROPE
        LDA inv_has_rope
        BNE already_have_item
        LDA #1
        STA inv_has_rope
        LDX #0
    take_rope_msg_loop:
            LDA take_rope_msg,X
            BEQ take_rope_msg_done
            JSR modem_out
            INX
            BNE take_rope_msg_loop
    take_rope_msg_done:
        RTS
    take_from_4:
        ; Riverbank: FISHING ROD
        LDA inv_has_rod
        BNE already_have_item
        LDA #1
        STA inv_has_rod
        LDX #0
    take_rod_msg_loop:
            LDA take_rod_msg,X
            BEQ take_rod_msg_done
            JSR modem_out
            INX
            BNE take_rod_msg_loop
    take_rod_msg_done:
        RTS
    take_from_5:
        ; Meadow: COINS
        LDA inv_has_coins
        BNE already_have_item
        LDA #1
        STA inv_has_coins
        LDX #0
    take_coins_msg_loop:
            LDA take_coins_msg,X
            BEQ take_coins_msg_done
            JSR modem_out
            INX
            BNE take_coins_msg_loop
    take_coins_msg_done:
        RTS
take_rod_msg_done:
    RTS
    loc2_msg_done:
        RTS
    loc3:
        LDX #0
    loc3_msg_loop:
            LDA loc3_msg,X
            BEQ loc3_msg_done
            JSR modem_out
            INX
            BNE loc3_msg_loop
    loc3_msg_done:
        RTS
    loc4:
        LDX #0
    loc4_msg_loop:
            LDA loc4_msg,X
            BEQ loc4_msg_done
            JSR modem_out
            INX
            BNE loc4_msg_loop
    loc4_msg_done:
        RTS
    LDX #0
print_location:
    LDA cur_loc
    CMP #0
    BEQ loc0
    CMP #1
    BEQ loc1
    CMP #2
    BEQ loc2
    CMP #3
    BEQ loc3
    CMP #4
    BEQ loc4
    CMP #5
    BEQ loc5
    RTS
        BEQ inv_key_msg_done
        JSR modem_out
        INX
        BNE inv_key_msg_loop
inv_key_msg_done:
    LDX #0
skip_key:
    LDA inv_has_lamp
    BEQ skip_lamp
inv_lamp_msg_loop:
        LDA inv_lamp_msg,X
        BEQ inv_lamp_msg_done
        JSR modem_out
        INX
        BNE inv_lamp_msg_loop
inv_lamp_msg_done:
    LDX #0
skip_lamp:
    LDA inv_has_rope
    BEQ skip_rope
inv_rope_msg_loop:
        LDA inv_rope_msg,X
        BEQ inv_rope_msg_done
        JSR modem_out
        INX
        BNE inv_rope_msg_loop
inv_rope_msg_done:
    LDX #0
skip_rope:
    LDA inv_has_rod
    BEQ skip_rod
inv_rod_msg_loop:
        LDA inv_rod_msg,X
        BEQ inv_rod_msg_done
        JSR modem_out
        INX
        BNE inv_rod_msg_loop
inv_rod_msg_done:
    LDX #0
skip_rod:
    RTS
    LDA #0
    STA cur_loc ; Start at location 0


move_west:
    LDA cur_loc
    CMP #0
    BEQ move_west_from_0
    CMP #1
    BEQ move_west_from_1
    CMP #2
    BEQ move_west_from_2
    CMP #3
    BEQ move_west_from_3
    CMP #4
    BEQ move_west_from_4
    CMP #5
    BEQ move_west_from_5
    JMP invalid_move
move_west_from_0:
    ; Can't go west from start
    JMP invalid_move
move_west_from_1:
    ; Can't go west from clearing
    JMP invalid_move
move_west_from_2:
    ; Can't go west from cave
    JMP invalid_move
move_west_from_3:
    ; Can't go west from forest path
    JMP invalid_move
move_west_from_4:
    ; Riverbank west to Forest Path
    LDA #3
    STA cur_loc
    JSR print_location
    RTS
move_west_from_5:
    ; Meadow west to Riverbank
    LDA #4
    STA cur_loc
    JSR print_location
    RTS
    LDA cur_loc
    CMP #1
    BEQ move1to0
    JMP move_south_blocked
move1to0:
    LDA #0
    STA cur_loc
    JSR move_south
    JMP adv_loop
move_south_blocked:
    JSR move_blocked
    JMP adv_loop

adv_look:
    JSR look_action
    JMP adv_loop

adv_talk:


    take_action:
        LDA cur_loc
        CMP #1
        BEQ try_take_key
        CMP #2
        BEQ try_take_rope
        CMP #3
        BEQ try_take_lamp
        LDX #0
    take_msg_loop:
        LDA take_msg,X
        BEQ take_msg_done
        JSR modem_out
        INX
        BNE take_msg_loop
    take_msg_done:
        RTS
    try_take_key:
        LDA inv_has_key
        BNE already_have_key
        LDA #1
        STA inv_has_key
        JSR take_key_success
        RTS
    already_have_key:
        JSR take_key_already
        RTS
    try_take_rope:
        LDA inv_has_rope
        BNE already_have_rope
        LDA #1
        STA inv_has_rope
        JSR take_rope_success
        RTS
    already_have_rope:
        JSR take_rope_already
        RTS
    try_take_lamp:
        LDA inv_has_lamp
        BNE already_have_lamp
        LDA #1
        STA inv_has_lamp
        JSR take_lamp_success
        RTS
    already_have_lamp:
        JSR take_lamp_already
        RTS
        take_lamp_success:
            LDX #0
        take_lamp_success_loop:
            LDA take_lamp_success_msg,X
            BEQ take_lamp_success_done
            JSR modem_out
            INX
            BNE take_lamp_success_loop
        take_lamp_success_done:
            RTS

        take_lamp_already:
            LDX #0
        take_lamp_already_loop:
            LDA take_lamp_already_msg,X
            BEQ take_lamp_already_done
            JSR modem_out
            INX
            BNE take_lamp_already_loop
        take_lamp_already_done:
            RTS
        take_lamp_success_msg:
            .text "\r\nYou pick up the LAMP.\r\n"
            .byte 0
        take_lamp_already_msg:
            .text "\r\nYou already have the LAMP.\r\n"
            .byte 0
        take_rope_success:
            LDX #0
        take_rope_success_loop:
            LDA take_rope_success_msg,X
            BEQ take_rope_success_done
            JSR modem_out
            INX
            BNE take_rope_success_loop
        take_rope_success_done:
            RTS

        take_rope_already:
            LDX #0
        take_rope_already_loop:
            LDA take_rope_already_msg,X
            BEQ take_rope_already_done
            JSR modem_out
            INX
            BNE take_rope_already_loop
        take_rope_already_done:
            RTS
        take_rope_success_msg:
            .text "\r\nYou pick up the ROPE.\r\n"
            .byte 0
        take_rope_already_msg:
            .text "\r\nYou already have the ROPE.\r\n"
            .byte 0
        JSR modem_out
        INX
        BNE loc0_msg_loop
loc0_msg_done:
    RTS
    loc4:
        LDX #0
    loc4_msg_loop:
            LDA loc4_msg,X
            BEQ loc4_msg_done
            JSR modem_out
            INX
            BNE loc4_msg_loop
    loc4_msg_done:
        RTS
    loc5:
        LDX #0
    loc5_msg_loop:
            LDA loc5_msg,X
            BEQ loc5_msg_done
            JSR modem_out
            INX
            BNE loc5_msg_loop
    loc5_msg_done:
        RTS
loc2:
    LDX #0
loc2_msg_loop:
        LDA loc2_msg,X
        BEQ loc2_msg_done
        JSR modem_out
        INX
        BNE loc2_msg_loop
loc2_msg_done:
    RTS
move_blocked:
    LDX #0
move_blocked_loop:
    LDA move_blocked_msg,X
    BEQ move_blocked_done
    JSR modem_out
    INX
    BNE move_blocked_loop
move_blocked_done:
    RTS


print_cmd_prompt:
    LDX #0
cmd_prompt_loop:
    LDA cmd_prompt_msg,X
    BEQ cmd_prompt_done
    JSR modem_out
    INX
    BNE cmd_prompt_loop
cmd_prompt_done:
    RTS

get_cmd_input:
    JSR modem_in
    RTS



adv_move_north:
    LDA cur_loc
    CMP #0
    BEQ move0to1
    CMP #1
    BEQ move1to2
    CMP #2
    BEQ move2to3
    JMP move_north_blocked
move0to1:
    LDA #1
    STA cur_loc
    JSR move_north
    JMP adv_loop
move1to2:
    LDA #2
    STA cur_loc
    JSR move_north
    JMP adv_loop
move2to3:
    LDA #3
    STA cur_loc
    JSR move_north
    JMP adv_loop
move_north_blocked:
    JSR move_blocked
    JMP adv_loop


adv_move_south:
    LDA cur_loc
    CMP #3
    BEQ move3to2
    CMP #2
    BEQ move2to1
    CMP #1
    BEQ move1to0
    JMP move_south_blocked
move3to2:
    LDA #2
    STA cur_loc
    JSR move_south
    JMP adv_loop
move2to1:
    LDA #1
    STA cur_loc
    JSR move_south
    JMP adv_loop
move1to0:
    LDA #0
    STA cur_loc
    JSR move_south
    JMP adv_loop
move_south_blocked:
    JSR move_blocked
    JMP adv_loop
    BNE move_south_loop
move_south_done:
    RTS




show_inventory:
    LDA inv_has_key
    BEQ check_rope
    LDA inv_has_rope
    BEQ check_lamp
    LDA inv_has_lamp
    BEQ only_key_rope
    LDX #0
inv_all_msg_loop:
    LDA inv_all_msg,X
    BEQ inv_all_msg_done
    JSR modem_out
    INX
    BNE inv_all_msg_loop
inv_all_msg_done:
    RTS
only_key_rope:
    LDA inv_has_key
    BEQ only_rope_lamp
    LDA inv_has_lamp
    BEQ only_key_rope2
    LDX #0
inv_key_rope_msg_loop:
    LDA inv_key_rope_msg,X
    BEQ inv_key_rope_msg_done
    JSR modem_out
    INX
    BNE inv_key_rope_msg_loop
inv_key_rope_msg_done:
    RTS
only_key_rope2:
    LDX #0
inv_rope_lamp_msg_loop:
    LDA inv_rope_lamp_msg,X
    BEQ inv_rope_lamp_msg_done
    JSR modem_out
    INX
    BNE inv_rope_lamp_msg_loop
inv_rope_lamp_msg_done:
    RTS
only_rope_lamp:
    LDA inv_has_rope
    BEQ only_lamp
    LDA inv_has_lamp
    BEQ only_rope
    LDX #0
inv_rope_lamp_msg_loop2:
    LDA inv_rope_lamp_msg,X
    BEQ inv_rope_lamp_msg_done2
    JSR modem_out
    INX
    BNE inv_rope_lamp_msg_loop2
inv_rope_lamp_msg_done2:
    RTS
only_key:
    LDX #0
inv1_msg_loop:
    LDA inv1_msg,X
    BEQ inv1_msg_done
    JSR modem_out
    INX
    BNE inv1_msg_loop
inv1_msg_done:
    RTS
only_rope:
    LDX #0
inv2_msg_loop:
    LDA inv2_msg,X
    BEQ inv2_msg_done
    JSR modem_out
    INX
    BNE inv2_msg_loop
inv2_msg_done:
    RTS
only_lamp:
    LDX #0
inv3_msg_loop:
    LDA inv3_msg,X
    BEQ inv3_msg_done
    JSR modem_out
    INX
    BNE inv3_msg_loop
inv3_msg_done:
    RTS
no_items:
    LDX #0
inv_msg_loop:
    LDA inv_msg,X
    BEQ inv_msg_done
    JSR modem_out
    INX
    BNE inv_msg_loop
inv_msg_done:
    RTS


; --- Data ---


cur_loc: .byte 0
inv_has_key: .byte 0

banner_msg:
    .text "\r\n*** WELCOME TO EVERLAND BBS! ***\r\n"
    .byte 0
login_msg:
    .text "\r\nUSERNAME: "
    .byte 0
menu_msg:
    .text "\r\nMAIN MENU:\r\n1. Play Everland\r\n2. Inventory\r\n3. Quit\r\n> "
    .byte 0
goodbye_msg:
    .text "\r\nTHANK YOU FOR PLAYING EVERLAND!\r\n"
    .byte 0


inv_msg:
    .text "\r\nYou carry no items, but the weight of Everland’s lore is heavy upon you.\r\n"
    .byte 0


inv1_msg:
    .text "\r\nYou are carrying: KEY (a symbol of lost kingdoms and ancient vows)\r\n"
    .byte 0
inv2_msg:
    .text "\r\nYou are carrying: ROPE (perhaps once used to bind oaths in the cursed garden)\r\n"
    .byte 0
inv3_msg:
    .text "\r\nYou are carrying: LAMP (its light a memory of Mage Damon’s Divination)\r\n"
    .byte 0
inv_key_rope_msg:
    .text "\r\nYou are carrying: KEY, ROPE (relics of Everland’s trials and oaths)\r\n"
    .byte 0
inv_rope_lamp_msg:
    .text "\r\nYou are carrying: ROPE, LAMP (tools for unraveling the mysteries of the cursed garden)\r\n"
    .byte 0
inv_all_msg:
    .text "\r\nYou are carrying: KEY, ROPE, LAMP (the legacy of Everland’s heroes and their quests)\r\n"
    .byte 0

loc0_msg:
    .text "\r\nYou stand in the clearing where the portal once shimmered, its magic lingering in the air. Echoes of lost memories and ancient oaths haunt this place.\r\nExits: N\r\n"
    .byte 0

loc1_msg:
    .text "\r\nYou walk the forest path, where green thorns once marked solemn oaths. A shiny KEY lies here, perhaps a relic of the Order of the Black Rose.\r\nExits: S\r\n"
    .byte 0

cmd_prompt_msg:
    .text "\r\nCommand (N/S/L/T/K/I/Q): "
    .byte 0

look_action:
    LDX #0
look_msg_loop:
    LDA look_msg,X
    BEQ look_msg_done
    JSR modem_out
    INX
    BNE look_msg_loop
look_msg_done:
    RTS

talk_action:
    LDX #0
talk_msg_loop:
    LDA talk_msg,X
    BEQ talk_msg_done
    JSR modem_out
    INX
    BNE talk_msg_loop
talk_msg_done:
    RTS


take_action:
    LDA cur_loc
    CMP #1
    BEQ try_take_key
    LDX #0
take_msg_loop:
    LDA take_msg,X
    BEQ take_msg_done
    JSR modem_out
    INX
    BNE take_msg_loop
take_msg_done:
    RTS
try_take_key:
    LDA inv_has_key
    BNE already_have_key
    LDA #1
    STA inv_has_key
    JSR take_success
    RTS
already_have_key:
    JSR take_already
    RTS
take_success:
    LDX #0
take_success_loop:
    LDA take_success_msg,X
    BEQ take_success_done
    JSR modem_out
    INX
    BNE take_success_loop
take_success_done:
    RTS

take_already:
    LDX #0
take_already_loop:
    LDA take_already_msg,X
    BEQ take_already_done
    JSR modem_out
    INX
    BNE take_already_loop
take_already_done:
    RTS
take_success_msg:
    .text "\r\nYou pick up the KEY.\r\n"
    .byte 0
take_already_msg:
    .text "\r\nYou already have the KEY.\r\n"
    .byte 0

look_msg:
    .text "\r\nYou look around. The clearing is peaceful, but you sense the lingering magic of Everland’s fractured memories.\r\n"
    .byte 0
talk_msg:
    .text "\r\nYou try to speak, but only the whispers of Grim’s sacrifice and Cordelia’s loyalty answer you.\r\n"
    .byte 0
take_msg:
    .text "\r\nThere is nothing to take, save the stories left behind by those who crossed the portal.\r\n"
    .byte 0
move_north_msg:
    .text "\r\nYou walk north, retracing the steps of Everland’s heroes.\r\n"
    .byte 0
move_south_msg:
    .text "\r\nYou walk south, the wind carrying faint echoes of ancient oaths.\r\n"
    .byte 0
move_blocked_msg:
    .text "\r\nA magical barrier blocks your path, as if the land itself remembers the boundaries set by the Order of the Black Rose.\r\n"
    .byte 0
