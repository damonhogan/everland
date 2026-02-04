; Everland BBS Door Main Source (Custom BBS)
; All I/O via modem_io.inc routines
; Game logic to be ported from everland.asm

* = $C000

#include "modem_io.inc"

user_slot: .byte 1 ; default slot
user_profile_filename:
    .byte "PROFILE0,S",0 ; will be updated for slot
user_lore_filename:
    .byte "LOREBK0,S",0 ; will be updated for slot
user_name: .res 16,0 ; PETSCII username
user_log_filename:
    .byte "LOGSLOT0,S",0 ; will be updated for slot

high_score_table: .res 160,0 ; 10 entries, 16 bytes name + 1 byte score + 3 bytes timestamp each
high_score_filename:
    .byte "HISCORES,S",0

msg_board_filename:
    .byte "MSGBRD,S",0
msg_board_buffer: .res 1024,0 ; 16 threads, 8 messages/thread, 8 bytes header + 56 bytes text each
msg_board_admin: .byte 0 ; 1 if admin

admin_password:
    .byte "C64ADMIN",0
admin_logged_in: .byte 0
user_list: .res 128,0 ; 8 slots x 16 bytes username
user_banned: .res 8,0 ; 1 byte per slot

start:
    JSR select_user_slot
    JMP main_loop

main_loop:
    JSR print_main_menu
    JSR get_menu_input
    CMP #'1'
    BEQ play_everland
    CMP #'2'
    BEQ inventory
    CMP #'3'
    BEQ high_scores
    CMP #'4'
    BEQ message_board
    CMP #'5'
    BEQ async_pvp
    CMP #'6'
    BEQ save_game
    CMP #'7'
    BEQ load_game
    CMP #'8'
    BEQ portal_travel
    CMP #'9'
    BEQ quit_game
    CMP #'L'
    BEQ library_menu
    JMP main_loop

play_everland:
    ; ...existing code...
    JMP main_loop
inventory:
    ; ...existing code...
    JMP main_loop
high_scores:
    JSR load_high_scores
    LDX #0
show_scores_entry:
        LDA high_score_table,X
        BEQ show_scores_done
        JSR modem_out ; username char
        INX
        CPX #16
        BNE show_scores_entry
        LDA high_score_table,X
        JSR modem_out ; score
        INX
        CPX #17
        BNE show_scores_entry
        ; ...show timestamp (stub)...
        INX
        CPX #20
        BNE show_scores_entry
        LDX #0
        JMP show_scores_entry
show_scores_done:
    RTS

save_high_score:
    JSR open_high_score_file_write
    LDY #0
save_high_score_loop:
        LDA high_score_table,Y
        JSR $FFD2 ; CHROUT (write byte)
        INY
        CPY #160
        BNE save_high_score_loop
    JSR close_high_score_file
    RTS

load_high_scores:
    JSR open_high_score_file_read
    LDY #0
load_high_score_loop:
        JSR $FFD2 ; CHRIN (read byte)
        STA high_score_table,Y
        INY
        CPY #160
        BNE load_high_score_loop
    JSR close_high_score_file
    RTS

open_high_score_file_write:
    LDA #8 ; device 8
    LDX #<high_score_filename
    LDY #>high_score_filename
    JSR $FFC0 ; SETLFS
    LDA #2 ; write
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS
open_high_score_file_read:
    LDA #8 ; device 8
    LDX #<high_score_filename
    LDY #>high_score_filename
    JSR $FFC0 ; SETLFS
    LDA #1 ; read
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS
close_high_score_file:
    LDA #8 ; device 8
    JSR $FFC3 ; CLOSE
    RTS

view_quest_log:
    JSR load_quest_log
    LDX #0
view_log_entry:
        LDA quest_log_buffer,X
        BEQ view_log_done
        JSR modem_out
        INX
        CPX #256
        BNE view_log_entry
view_log_done:
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
    .byte "\r\nEVERLAND MAIN MENU:\r\n(Where memory and magic entwine)\r\n1. Play Everland\r\n2. Inventory\r\n3. High Scores\r\n4. Message Board\r\n5. Async PvP\r\n6. Save Game\r\n7. Load Game\r\n8. Portal Travel\r\n9. Quit\r\nL. Library\r\n\r\nLore: The portal shimmers with fractured memories. Quests shape the fate of Everland.\r\n> ",0

get_menu_input:
    ; Get a key from modem
    JSR modem_in
    RTS

library_menu:
    LDX #0
library_menu_msg_loop:
        LDA library_menu_msg,X
        BEQ library_menu_msg_done
        JSR modem_out
        INX
        BNE library_menu_msg_loop
library_menu_msg_done:
    JSR get_library_input
    JMP main_loop

library_menu_msg:
    .byte "\r\nLIBRARY:\r\n1. Browse Your Lore Book\r\n2. Paste Your Own Lore Book\r\n3. Back to Main Menu\r\n> ",0

get_library_input:
    JSR modem_in
    CMP #'2'
    BEQ paste_lore_book
    CMP #'1'
    BEQ browse_lore_book
    CMP #'3'
    BEQ main_loop
    RTS

paste_lore_book:
    JSR check_reu
    LDA reu_present
    BEQ paste_lore_disk
    JMP paste_lore_reu

paste_lore_reu:
    LDX #0
    ; Prompt user to paste text, end with CTRL-Z
paste_lore_prompt_loop:
        LDA paste_lore_prompt,X
        BEQ paste_lore_prompt_done
        JSR modem_out
        INX
        BNE paste_lore_prompt_loop
paste_lore_prompt_done:
    LDX #0
paste_lore_loop:
        JSR modem_in
        CMP #26 ; CTRL-Z
        BEQ paste_lore_done
        STA reu_lore_pages,X
        INX
        CPX #2048
        BNE paste_lore_loop
        JMP paste_lore_loop
paste_lore_done:
    JMP library_menu

paste_lore_disk:
    LDX #0
    ; Prompt user to paste text, end with CTRL-Z
    ; ...existing prompt code...
    LDX #0
paste_lore_disk_loop:
        JSR modem_in
        CMP #26 ; CTRL-Z
        BEQ paste_lore_disk_done
        STA user_lore_buffer,X
        INX
        CPX #255
        BNE paste_lore_disk_loop
        JMP paste_lore_disk_loop
paste_lore_disk_done:
    ; Write buffer to disk as pages
    LDX #0
    LDY #0
    LDA #0
    STA page_num
write_lore_pages:
        LDA user_lore_buffer,X
        STA $C000,Y ; page buffer
        INX
        INY
        CPY #128
        BNE write_lore_pages_continue
        ; Write page to disk
        JSR write_lore_page_disk
        INC page_num
        LDY #0
write_lore_pages_continue:
        CPX #255
        BNE write_lore_pages
    JMP library_menu

write_lore_page_disk:
    ; Write 128 bytes from $C000 to disk file
    ; Set up filename, open file, write, close
    ; --- Disk I/O routines for lore books ---
lore_disk_filename:
    .byte "USERLORE,S",0

open_lore_file_write:
    LDA #8 ; device 8
    LDX #<user_lore_filename
    LDY #>user_lore_filename
    JSR $FFC0 ; SETLFS
    LDA #2 ; write
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS

open_lore_file_read:
    LDA #8 ; device 8
    LDX #<user_lore_filename
    LDY #>user_lore_filename
    JSR $FFC0 ; SETLFS
    LDA #1 ; read
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS

open_profile_file_write:
    LDA #8 ; device 8
    LDX #<user_profile_filename
    LDY #>user_profile_filename
    JSR $FFC0 ; SETLFS
    LDA #2 ; write
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS

open_profile_file_read:
    LDA #8 ; device 8
    LDX #<user_profile_filename
    LDY #>user_profile_filename
    JSR $FFC0 ; SETLFS
    LDA #1 ; read
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS

close_lore_file:
    LDA #8 ; device 8
    JSR $FFC3 ; CLOSE
    RTS

write_lore_page_disk:
    JSR open_lore_file_write
    LDY #0
write_lore_page_loop:
        LDA $C000,Y
        JSR $FFD2 ; CHROUT (write byte)
        INY
        CPY #128
        BNE write_lore_page_loop
    JSR close_lore_file
    RTS

read_lore_page_disk:
    JSR open_lore_file_read
    LDY #0
read_lore_page_loop:
        JSR $FFD2 ; CHRIN (read byte)
        STA $C000,Y
        INY
        CPY #128
        BNE read_lore_page_loop
    JSR close_lore_file
    RTS

check_reu:
    ; Detect REU (simple test: write/read to $DF00)
    LDA #$AA
    STA $DF00
    LDA #$55
    STA $DF01
    LDA $DF00
    CMP #$AA
    BNE no_reu
    LDA $DF01
    CMP #$55
    BNE no_reu
    LDA #1
    STA reu_present
    RTS
no_reu:
    LDA #0
    STA reu_present
    RTS

reu_present: .byte 0 ; 0 = not detected, 1 = detected
reu_lore_pages: .res 2048,0 ; 16 pages of 128 bytes (if REU available)
lore_disk_filename:
    .byte "USERLORE,S",0

paste_lore_prompt:
    .byte "\r\nPaste your lore book text now. End with CTRL-Z.\r\n",0
user_lore_buffer: .res 255,0
user_lore_pages: .res 512,0 ; 4 pages max
page_num: .byte 0

browse_next_prompt:
    .byte "\r\nPress any key for next page...\r\n",0

; Region stubs with enriched flavor
portal_aurora_msg:
    .byte "\r\nYou step through the portal and arrive in Aurora, land of frost and light. The Frost Weaver Queen awaits.\r\n\r\nMARKET: Merchants trade tales, trinkets, and legends. A coin glints near a stall, and bargains whisper through the crowd. Sometimes, the air shimmers with the memory of ancient deals and lost fortunes.\r\n",0
aurora_npc_menu_msg:
    .byte "\r\nAURORA NPCs:\r\n1. Speak to the Frost Weaver Queen\r\n2. Visit the Winter Wolf\r\n3. Back to Portal\r\n\r\nLore: The Queen's magic is woven from ice and light. The Winter Wolf guards the pact of Everland.\r\n> ",0
aurora_frost_queen_msg:
    .byte "\r\nThe Frost Weaver Queen intones: 'Welcome to Aurora. Only those who master the elements may join the guild.'\r\n(Quest: Learn the first frost spell.)\r\n\r\nQuest: 1) Survive the wolf's challenge. 2) Return to the Queen for your reward.\r\n",0
aurora_frost_spell_complete_msg:
    .byte "\r\nQuest complete: You have mastered the first frost spell! The Queen welcomes you to the guild.\r\n(Reward: Frost Spell added to inventory.)\r\nLore Event: The air shimmers with the memory of ancient deals and lost fortunes.\r\n",0

portal_lore_msg:
    .byte "\r\nYou step through the portal and arrive in Lore, kingdom of knights and memory. Lady Cordelia and the Order of the Black Rose stand ready.\r\n\r\nPLAZA: The heart of the park, where stones hold the memory of ancient gatherings, secret pacts, and the courage of Everland's guardians. Sometimes, the air thrums with the presence of past heroes and the choice to unite or divide.\r\n",0
lore_npc_menu_msg:
    .byte "\r\nLORE NPCs:\r\n1. Speak to Lady Cordelia\r\n2. Visit Grim the Blackheart\r\n3. Back to Portal\r\n> ",0
lore_cordelia_msg:
    .byte "\r\nLady Cordelia proclaims: 'The Order of the Black Rose stands for honor and memory. Will you take the knight's oath?'\r\n(Quest: Swear the green thorn oath.)\r\n\r\nQuest Multi-Path: 1) Uphold or break the knight's oath, 2) Duel for honor or peace, 3) Choose to protect or challenge Lore, 4) Experience alternate knight lore events based on your choice.\r\n",0
lore_knight_oath_complete_msg:
    .byte "\r\nQuest complete: You have sworn the knight's oath! Lady Cordelia welcomes you to the Order.\r\n(Reward: Black Rose Emblem added to inventory.)\r\nLore Event: Stones hold the memory of ancient gatherings, and you glimpse Everland's defenders from centuries past.\r\n",0
lore_grim_msg:
    .byte "\r\nGrim the Blackheart speaks: 'Few words, but deep loyalty. Sacrifice is the price of hope.'\r\n(Quest: Prove your loyalty in battle.)\r\n\r\nLore: The plaza stones shift, revealing a hidden passage. You glimpse Everland's defenders, their courage echoing in the heart of the park.\r\n",0

portal_mythos_msg:
    .byte "\r\nYou step through the portal and arrive in Mythos, realm of jungles and secrets. The Dragon Queen and ancient mysteries await.\r\n\r\nMYSTICWOOD: Dark trees crowd together, paper charms sway from branches. Herbs and moss blanket the ground, and the air is thick with whispered lore. Rituals are sometimes performed here, and spirits are said to watch from the shadows. If you listen closely, you may feel the presence of ancient magic and glimpse a vision of the wood's past.\r\n",0
mythos_npc_menu_msg:
    .byte "\r\nMYTHOS NPCs:\r\n1. Speak to the Dragon Queen\r\n2. Visit the Ancient Mystic\r\n3. Back to Portal\r\n> ",0
mythos_dragon_queen_msg:
    .byte "\r\nThe Dragon Queen greets you: 'Welcome, traveler. Seek wisdom, and you may unlock the secrets of Mythos.'\r\n(Quest: Find the lost dragon scale.)\r\n\r\nQuest Multi-Path: 1) Join the dragon trainers or seek the hidden treasure, 2) Decide the fate of the loot, 3) Experience alternate dragon lore events based on your choice.\r\n",0
mythos_dragon_scale_complete_msg:
    .byte "\r\nQuest complete: You have found the lost dragon scale! The Queen rewards you with her blessing.\r\n(Reward: Dragon Scale added to inventory.)\r\nLore Event: Dragons soar through fire and sky, and you feel the ancient bond between trainer and dragon.\r\n",0

select_user_slot:
    LDX #0
select_slot_msg_loop:
        LDA select_slot_msg,X
        BEQ select_slot_msg_done
        JSR modem_out
        INX
        BNE select_slot_msg_loop
select_slot_msg_done:
    JSR modem_in
    SEC
    SBC #'0'
    CMP #1
    BCC select_user_slot
    CMP #9
    BCS select_user_slot
    STA user_slot
    ; Update filenames
    LDX #7 ; PROFILE0,S
    LDA user_slot
    CLC
    ADC #'0'
    STA user_profile_filename,X
    LDX #6 ; LOREBK0,S
    LDA user_slot
    CLC
    ADC #'0'
    STA user_lore_filename,X
    LDX #7 ; LOGSLOT0,S
    LDA user_slot
    CLC
    ADC #'0'
    STA user_log_filename,X
    JSR prompt_username
    RTS

prompt_username:
    LDX #0
prompt_username_msg_loop:
        LDA prompt_username_msg,X
        BEQ prompt_username_msg_done
        JSR modem_out
        INX
        BNE prompt_username_msg_loop
prompt_username_msg_done:
    LDX #0
prompt_username_input_loop:
        JSR modem_in
        CMP #13 ; Return
        BEQ prompt_username_input_done
        STA user_name,X
        INX
        CPX #16
        BNE prompt_username_input_loop
        JMP prompt_username_input_loop
prompt_username_input_done:
    RTS
prompt_username_msg:
    .byte "\r\nEnter your username (max 16 chars, press RETURN): ",0

; Quest/event log routines
quest_log_buffer: .res 256,0

save_quest_log:
    JSR open_log_file_write
    LDY #0
save_quest_log_loop:
        LDA quest_log_buffer,Y
        JSR $FFD2 ; CHROUT (write byte)
        INY
        CPY #256
        BNE save_quest_log_loop
    JSR close_log_file
    RTS

load_quest_log:
    JSR open_log_file_read
    LDY #0
load_quest_log_loop:
        JSR $FFD2 ; CHRIN (read byte)
        STA quest_log_buffer,Y
        INY
        CPY #256
        BNE load_quest_log_loop
    JSR close_log_file
    RTS

open_log_file_write:
    LDA #8 ; device 8
    LDX #<user_log_filename
    LDY #>user_log_filename
    JSR $FFC0 ; SETLFS
    LDA #2 ; write
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS
open_log_file_read:
    LDA #8 ; device 8
    LDX #<user_log_filename
    LDY #>user_log_filename
    JSR $FFC0 ; SETLFS
    LDA #1 ; read
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS
close_log_file:
    LDA #8 ; device 8
    JSR $FFC3 ; CLOSE
    RTS

save_msg_board:
    JSR open_msg_board_file_write
    LDY #0
save_msg_board_loop:
        LDA msg_board_buffer,Y
        JSR $FFD2 ; CHROUT (write byte)
        INY
        CPY #1024
        BNE save_msg_board_loop
    JSR close_msg_board_file
    RTS

load_msg_board:
    JSR open_msg_board_file_read
    LDY #0
load_msg_board_loop:
        JSR $FFD2 ; CHRIN (read byte)
        STA msg_board_buffer,Y
        INY
        CPY #1024
        BNE load_msg_board_loop
    JSR close_msg_board_file
    RTS

open_msg_board_file_write:
    LDA #8 ; device 8
    LDX #<msg_board_filename
    LDY #>msg_board_filename
    JSR $FFC0 ; SETLFS
    LDA #2 ; write
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS
open_msg_board_file_read:
    LDA #8 ; device 8
    LDX #<msg_board_filename
    LDY #>msg_board_filename
    JSR $FFC0 ; SETLFS
    LDA #1 ; read
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS
close_msg_board_file:
    LDA #8 ; device 8
    JSR $FFC3 ; CLOSE
    RTS

msg_board_prompt:
    .byte "\r\n(R)eply, (N)ext thread, (A)dmin menu: ",0
admin_prompt_msg:
    .byte "\r\n(D)elete message, (M)oderate message: ",0

admin_login:
    LDX #0
admin_login_msg_loop:
        LDA admin_login_msg,X
        BEQ admin_login_msg_done
        JSR modem_out
        INX
        BNE admin_login_msg_loop
admin_login_msg_done:
    LDX #0
admin_pw_input_loop:
        JSR modem_in
        CMP #13 ; Return
        BEQ admin_pw_input_done
        STA admin_pw_buffer,X
        INX
        CPX #8
        BNE admin_pw_input_loop
        JMP admin_pw_input_loop
admin_pw_input_done:
    LDX #0
admin_pw_check_loop:
        LDA admin_pw_buffer,X
        CMP admin_password,X
        BNE admin_login_fail
        INX
        CPX #8
        BNE admin_pw_check_loop
    LDA #1
    STA admin_logged_in
    JMP admin_menu
admin_login_fail:
    LDA #0
    STA admin_logged_in
    JMP main_loop
admin_login_msg:
    .byte "\r\nEnter admin password: ",0
admin_pw_buffer: .res 8,0

admin_menu:
    LDX #0
admin_menu_msg_loop:
        LDA admin_menu_msg,X
        BEQ admin_menu_msg_done
        JSR modem_out
        INX
        BNE admin_menu_msg_loop
admin_menu_msg_done:
    JSR modem_in
    CMP #'U'
    BEQ admin_user_list
    CMP #'B'
    BEQ admin_ban_user
    CMP #'R'
    BEQ admin_unban_user
    CMP #'M'
    BEQ admin_review_msgs
    CMP #'Q'
    BEQ admin_logout
    JMP admin_menu
admin_menu_msg:
    .byte "\r\nADMIN MENU:\r\n(U)ser list, (B)an user, (R)estore user, (M)essage review, (Q)uit\r\n> ",0

admin_user_list:
    LDX #0
admin_user_list_loop:
        LDA user_list,X
        BEQ admin_user_list_done
        JSR modem_out
        INX
        CPX #128
        BNE admin_user_list_loop
admin_user_list_done:
    JMP admin_menu

admin_ban_user:
    ; Prompt for slot, set user_banned
    LDX #0
admin_ban_msg_loop:
        LDA admin_ban_msg,X
        BEQ admin_ban_msg_done
        JSR modem_out
        INX
        BNE admin_ban_msg_loop
admin_ban_msg_done:
    JSR modem_in
    SEC
    SBC #'0'
    CMP #1
    BCC admin_menu
    CMP #9
    BCS admin_menu
    TAX
    LDA #1
    STA user_banned,X
    JMP admin_menu
admin_ban_msg:
    .byte "\r\nEnter user slot to ban (1-8): ",0

admin_unban_user:
    ; Prompt for slot, clear user_banned
    LDX #0
admin_unban_msg_loop:
        LDA admin_unban_msg,X
        BEQ admin_unban_msg_done
        JSR modem_out
        INX
        BNE admin_unban_msg_loop
admin_unban_msg_done:
    JSR modem_in
    SEC
    SBC #'0'
    CMP #1
    BCC admin_menu
    CMP #9
    BCS admin_menu
    TAX
    LDA #0
    STA user_banned,X
    JMP admin_menu
admin_unban_msg:
    .byte "\r\nEnter user slot to restore (1-8): ",0

admin_review_msgs:
    ; Show all message board threads/messages for review
    JSR load_msg_board
    LDX #0
admin_review_loop:
        LDA msg_board_buffer,X
        BEQ admin_review_done
        JSR modem_out
        INX
        CPX #1024
        BNE admin_review_loop
admin_review_done:
    JMP admin_menu

admin_logout:
    LDA #0
    STA admin_logged_in
    JMP main_loop

; --- Expanded NPC/Quest Logic ---
custom_npc_table: .res 128,0 ; 8 custom NPCs, 16 bytes each
quest_state: .res 16,0 ; 8 quests, 2 bytes each (stage, outcome)

npc_menu:
    LDX #0
npc_menu_msg_loop:
        LDA npc_menu_msg,X
        BEQ npc_menu_msg_done
        JSR modem_out
        INX
        BNE npc_menu_msg_loop
npc_menu_msg_done:
    JSR get_npc_input
    JMP main_loop
npc_menu_msg:
    .byte "\r\nNPC MENU:\r\n1. Speak to Kasimere\r\n2. Speak to Pumpkin King\r\n3. Speak to Alpha Wulfric\r\n4. Speak to Lyra\r\n5. Speak to Van Bueler\r\n6. Speak to Cedric\r\n7. Speak to Gwen\r\n8. Speak to Grim\r\n9. Back to Main Menu\r\n> ",0

get_npc_input:
    JSR modem_in
    CMP #'1'
    BEQ npc_kasimere
    CMP #'2'
    BEQ npc_pumpkin_king
    CMP #'3'
    BEQ npc_wulfric
    CMP #'4'
    BEQ npc_lyra
    CMP #'5'
    BEQ npc_bueler
    CMP #'6'
    BEQ npc_cedric
    CMP #'7'
    BEQ npc_gwen
    CMP #'8'
    BEQ npc_grim
    CMP #'9'
    BEQ main_loop
    RTS

npc_kasimere:
    ; Multi-path quest: choose to help or betray Kasimere
    LDX #0
npc_kasimere_msg_loop:
        LDA npc_kasimere_msg,X
        BEQ npc_kasimere_msg_done
        JSR modem_out
        INX
        BNE npc_kasimere_msg_loop
npc_kasimere_msg_done:
    JSR modem_in
    CMP #'H'
    BEQ kasimere_help
    CMP #'B'
    BEQ kasimere_betray
    JMP npc_menu
kasimere_help:
    LDA #1
    STA quest_state
    JMP npc_menu
kasimere_betray:
    LDA #2
    STA quest_state
    JMP npc_menu
npc_kasimere_msg:
    .byte "\r\nKasimere: Will you (H)elp or (B)etray me? ",0

npc_pumpkin_king:
    ; Branching event: battle or negotiate
    LDX #0
npc_pumpkin_king_msg_loop:
        LDA npc_pumpkin_king_msg,X
        BEQ npc_pumpkin_king_msg_done
        JSR modem_out
        INX
        BNE npc_pumpkin_king_msg_loop
npc_pumpkin_king_msg_done:
    JSR modem_in
    CMP #'F'
    BEQ pumpkin_fight
    CMP #'N'
    BEQ pumpkin_negotiate
    JMP npc_menu
pumpkin_fight:
    LDA #1
    STA quest_state+1
    JMP npc_menu
pumpkin_negotiate:
    LDA #2
    STA quest_state+1
    JMP npc_menu
npc_pumpkin_king_msg:
    .byte "\r\nPumpkin King: (F)ight or (N)egotiate? ",0

npc_wulfric:
    ; Wolf pact: join or refuse
    LDX #0
npc_wulfric_msg_loop:
        LDA npc_wulfric_msg,X
        BEQ npc_wulfric_msg_done
        JSR modem_out
        INX
        BNE npc_wulfric_msg_loop
npc_wulfric_msg_done:
    JSR modem_in
    CMP #'J'
    BEQ wulfric_join
    CMP #'R'
    BEQ wulfric_refuse
    JMP npc_menu
wulfric_join:
    LDA #1
    STA quest_state+2
    JMP npc_menu
wulfric_refuse:
    LDA #2
    STA quest_state+2
    JMP npc_menu
npc_wulfric_msg:
    .byte "\r\nAlpha Wulfric: (J)oin the pact or (R)efuse? ",0

; ...similar stubs for Lyra, Van Bueler, Cedric, Gwen, Grim...
