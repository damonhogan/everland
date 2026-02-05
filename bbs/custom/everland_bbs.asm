// Everland BBS Door Main Source (Custom BBS)
// All I/O via modem_io.inc routines
// Game logic to be ported from everland.asm

// KERNAL routine addresses
.label CHKIN = $FFC6
.label CHRIN = $FFCF
.label CHKOUT = $FFC9
.label CHROUT = $FFD2
.label CLRCHN = $FFCC

.pc = $C000 "BBS Door"

// Modem I/O routines
modem_in:
    ldx #2
    jsr CHKIN
    jsr CHRIN
    jsr CLRCHN
    rts

modem_out:
    ldx #2
    jsr CHKOUT
    jsr CHROUT
    jsr CLRCHN
    rts

user_slot: .byte 1 // default slot
user_profile_filename:
    .text "PROFILE0,S" // will be updated for slot
user_lore_filename:
    .text "LOREBK0,S" // will be updated for slot
user_name: .fill 16, 0 // PETSCII username
user_log_filename:
    .text "LOGSLOT0,S" // will be updated for slot

high_score_table: .fill 160, 0 // 10 entries, 16 bytes name + 1 byte score + 3 bytes timestamp each
high_score_filename:
    .text "HISCORES,S"

msg_board_filename:
    .text "MSGBRD,S"
msg_board_buffer: .fill 1024, 0 // 16 threads, 8 messages/thread, 8 bytes header + 56 bytes text each
msg_board_admin: .byte 0 // 1 if admin

admin_password:
    .text "C64ADMIN"
admin_logged_in: .byte 0
user_list: .fill 128, 0 // 8 slots x 16 bytes username
user_banned: .fill 8, 0 // 1 byte per slot

// --- Room Customization Data Structures ---
user_room_desc: .fill 64, 0       // Room description (64 chars max)
user_room_decor: .byte 0          // Decor theme (0-3)
user_room_color: .byte 0          // Color scheme (0-5)
user_room_ascii: .fill 128, 0     // ASCII art (4 lines x 32 chars)
user_room_privacy: .byte 0        // 0=Public, 1=Friends-Only, 2=Private
user_room_title: .fill 32, 0      // Room title/banner
user_room_music: .byte 0          // 0=None, 1-4=Theme
guestbook_entries: .fill 160, 0   // 5 entries x 32 bytes each
user_friends_list: .fill 16, 0    // 16 friend slots
user_friends_count: .byte 0
user_room_visitors: .fill 40, 0   // Last 5 visitors
user_room_visitor_count: .byte 0
user_room_rating_sum: .byte 0
user_room_rating_count: .byte 0
user_trinket_display: .fill 8, 0  // 8 trinket display slots
user_badge_display: .fill 4, 0    // 4 badge showcase slots

start:
    jsr select_user_slot
    jmp main_loop

main_loop:
    jsr print_main_menu
    jsr get_menu_input
    cmp #'1'
    beq play_everland
    cmp #'2'
    beq inventory
    cmp #'3'
    beq high_scores
    cmp #'4'
    beq go_message_board
    cmp #'5'
    beq go_async_pvp
    cmp #'6'
    beq go_save_game
    cmp #'7'
    beq go_load_game
    cmp #'8'
    beq go_portal_travel
    cmp #'9'
    beq go_quit_game
    cmp #'L'
    beq go_library_menu
    cmp #'R'
    beq go_room_menu
    jmp main_loop

go_message_board:
    jmp message_board
go_async_pvp:
    jmp async_pvp
go_save_game:
    jmp save_game
go_load_game:
    jmp load_game
go_portal_travel:
    jmp portal_travel
go_quit_game:
    jmp quit_game
go_library_menu:
    jmp library_menu
go_room_menu:
    jmp user_room_menu

play_everland:
    // ...existing code...
    jmp main_loop
inventory:
    // ...existing code...
    jmp main_loop
high_scores:
    jsr load_high_scores
    ldx #0
show_scores_entry:
        lda high_score_table,X
        beq show_scores_done
        jsr modem_out // username char
        inx
        cpx #16
        bne show_scores_entry
        lda high_score_table,X
        jsr modem_out // score
        inx
        cpx #17
        bne show_scores_entry
        // ...show timestamp (stub)...
        inx
        cpx #20
        bne show_scores_entry
        ldx #0
        jmp show_scores_entry
show_scores_done:
    rts

save_high_score:
    jsr open_high_score_file_write
    ldy #0
save_high_score_loop:
        lda high_score_table,Y
        jsr $FFD2 // CHROUT (write byte)
        iny
        cpy #160
        bne save_high_score_loop
    jsr close_high_score_file
    rts

load_high_scores:
    jsr open_high_score_file_read
    ldy #0
load_high_score_loop:
        jsr $FFD2 // CHRIN (read byte)
        sta high_score_table,Y
        iny
        cpy #160
        bne load_high_score_loop
    jsr close_high_score_file
    rts

open_high_score_file_write:
    lda #8 // device 8
    ldx #<high_score_filename
    ldy #>high_score_filename
    jsr $FFC0 // SETLFS
    lda #2 // write
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts
open_high_score_file_read:
    lda #8 // device 8
    ldx #<high_score_filename
    ldy #>high_score_filename
    jsr $FFC0 // SETLFS
    lda #1 // read
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts
close_high_score_file:
    lda #8 // device 8
    jsr $FFC3 // CLOSE
    rts

view_quest_log:
    jsr load_quest_log
    ldx #0
view_log_entry:
        lda quest_log_buffer,X
        beq view_log_done
        jsr modem_out
        inx
        cpx #256
        bne view_log_entry
view_log_done:
    rts

print_main_menu:
    ldx #0
print_menu_loop:
        lda main_menu_msg,X
        beq print_menu_done
        jsr modem_out
        inx
        bne print_menu_loop
print_menu_done:
    rts

main_menu_msg:
    .text "\r\nEVERLAND MAIN MENU:\r\n(Where memory and magic entwine)\r\n1. Play Everland\r\n2. Inventory\r\n3. High Scores\r\n4. Message Board\r\n5. Async PvP\r\n6. Save Game\r\n7. Load Game\r\n8. Portal Travel\r\n9. Quit\r\nL. Library\r\n\r\nLore: The portal shimmers with fractured memories. Quests shape the fate of Everland.\r\n> "

get_menu_input:
    // Get a key from modem
    jsr modem_in
    rts

library_menu:
    ldx #0
library_menu_msg_loop:
        lda library_menu_msg,X
        beq library_menu_msg_done
        jsr modem_out
        inx
        bne library_menu_msg_loop
library_menu_msg_done:
    jsr get_library_input
    jmp main_loop

library_menu_msg:
    .text "\r\nLIBRARY:\r\n1. Browse Your Lore Book\r\n2. Paste Your Own Lore Book\r\n3. Back to Main Menu\r\n> "

get_library_input:
    jsr modem_in
    cmp #'2'
    beq paste_lore_book
    cmp #'1'
    beq go_browse_lore
    cmp #'3'
    beq go_main_loop_lib
    rts

go_browse_lore:
    jmp browse_lore_book
go_main_loop_lib:
    jmp main_loop

paste_lore_book:
    jsr check_reu
    lda reu_present
    beq paste_lore_disk
    jmp paste_lore_reu

paste_lore_reu:
    ldx #0
    // Prompt user to paste text, end with CTRL-Z
paste_lore_prompt_loop:
        lda paste_lore_prompt,X
        beq paste_lore_prompt_done
        jsr modem_out
        inx
        bne paste_lore_prompt_loop
paste_lore_prompt_done:
    ldx #0
paste_lore_loop:
        jsr modem_in
        cmp #26 // CTRL-Z
        beq paste_lore_done
        sta reu_lore_pages,X
        inx
        cpx #2048
        bne paste_lore_loop
        jmp paste_lore_loop
paste_lore_done:
    jmp library_menu

paste_lore_disk:
    ldx #0
    // Prompt user to paste text, end with CTRL-Z
    // ...existing prompt code...
    ldx #0
paste_lore_disk_loop:
        jsr modem_in
        cmp #26 // CTRL-Z
        beq paste_lore_disk_done
        sta user_lore_buffer,X
        inx
        cpx #255
        bne paste_lore_disk_loop
        jmp paste_lore_disk_loop
paste_lore_disk_done:
    // Write buffer to disk as pages
    ldx #0
    ldy #0
    lda #0
    sta page_num
write_lore_pages:
        lda user_lore_buffer,X
        sta $C000,Y // page buffer
        inx
        iny
        cpy #128
        bne write_lore_pages_continue
        // Write page to disk
        jsr write_lore_page_disk
        inc page_num
        ldy #0
write_lore_pages_continue:
        cpx #255
        bne write_lore_pages
    jmp library_menu

// --- Disk I/O routines for lore books ---

open_lore_file_write:
    lda #8 // device 8
    ldx #<user_lore_filename
    ldy #>user_lore_filename
    jsr $FFC0 // SETLFS
    lda #2 // write
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts

open_lore_file_read:
    lda #8 // device 8
    ldx #<user_lore_filename
    ldy #>user_lore_filename
    jsr $FFC0 // SETLFS
    lda #1 // read
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts

open_profile_file_write:
    lda #8 // device 8
    ldx #<user_profile_filename
    ldy #>user_profile_filename
    jsr $FFC0 // SETLFS
    lda #2 // write
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts

open_profile_file_read:
    lda #8 // device 8
    ldx #<user_profile_filename
    ldy #>user_profile_filename
    jsr $FFC0 // SETLFS
    lda #1 // read
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts

close_lore_file:
    lda #8 // device 8
    jsr $FFC3 // CLOSE
    rts

write_lore_page_disk:
    jsr open_lore_file_write
    ldy #0
write_lore_page_loop:
        lda $C000,Y
        jsr $FFD2 // CHROUT (write byte)
        iny
        cpy #128
        bne write_lore_page_loop
    jsr close_lore_file
    rts

read_lore_page_disk:
    jsr open_lore_file_read
    ldy #0
read_lore_page_loop:
        jsr $FFD2 // CHRIN (read byte)
        sta $C000,Y
        iny
        cpy #128
        bne read_lore_page_loop
    jsr close_lore_file
    rts

check_reu:
    // Detect REU (simple test: write/read to $DF00)
    lda #$AA
    sta $DF00
    lda #$55
    sta $DF01
    lda $DF00
    cmp #$AA
    bne no_reu
    lda $DF01
    cmp #$55
    bne no_reu
    lda #1
    sta reu_present
    rts
no_reu:
    lda #0
    sta reu_present
    rts

reu_present: .byte 0 // 0 = not detected, 1 = detected
reu_lore_pages: .fill 2048, 0 // 16 pages of 128 bytes (if REU available)
lore_disk_filename:
    .text "USERLORE,S"

paste_lore_prompt:
    .text "\r\nPaste your lore book text now. End with CTRL-Z.\r\n"
user_lore_buffer: .fill 255, 0
user_lore_pages: .fill 512, 0 // 4 pages max
page_num: .byte 0

browse_next_prompt:
    .text "\r\nPress any key for next page...\r\n"

// Region stubs with enriched flavor
portal_aurora_msg:
    .text "\r\nYou step through the portal and arrive in Aurora, land of frost and light. The Frost Weaver Queen awaits.\r\n\r\nMARKET: Merchants trade tales, trinkets, and legends. A coin glints near a stall, and bargains whisper through the crowd. Sometimes, the air shimmers with the memory of ancient deals and lost fortunes.\r\n"
aurora_npc_menu_msg:
    .text "\r\nAURORA NPCs:\r\n1. Speak to the Frost Weaver Queen\r\n2. Visit the Winter Wolf\r\n3. Back to Portal\r\n\r\nLore: The Queen's magic is woven from ice and light. The Winter Wolf guards the pact of Everland.\r\n> "
aurora_frost_queen_msg:
    .text "\r\nThe Frost Weaver Queen intones: 'Welcome to Aurora. Only those who master the elements may join the guild.'\r\n(Quest: Learn the first frost spell.)\r\n\r\nQuest: 1) Survive the wolf's challenge. 2) Return to the Queen for your reward.\r\n"
aurora_frost_spell_complete_msg:
    .text "\r\nQuest complete: You have mastered the first frost spell! The Queen welcomes you to the guild.\r\n(Reward: Frost Spell added to inventory.)\r\nLore Event: The air shimmers with the memory of ancient deals and lost fortunes.\r\n"

portal_lore_msg:
    .text "\r\nYou step through the portal and arrive in Lore, kingdom of knights and memory. Lady Cordelia and the Order of the Black Rose stand ready.\r\n\r\nPLAZA: The heart of the park, where stones hold the memory of ancient gatherings, secret pacts, and the courage of Everland's guardians. Sometimes, the air thrums with the presence of past heroes and the choice to unite or divide.\r\n"
lore_npc_menu_msg:
    .text "\r\nLORE NPCs:\r\n1. Speak to Lady Cordelia\r\n2. Visit Grim the Blackheart\r\n3. Back to Portal\r\n> "
lore_cordelia_msg:
    .text "\r\nLady Cordelia proclaims: 'The Order of the Black Rose stands for honor and memory. Will you take the knight's oath?'\r\n(Quest: Swear the green thorn oath.)\r\n\r\nQuest Multi-Path: 1) Uphold or break the knight's oath, 2) Duel for honor or peace, 3) Choose to protect or challenge Lore, 4) Experience alternate knight lore events based on your choice.\r\n"
lore_knight_oath_complete_msg:
    .text "\r\nQuest complete: You have sworn the knight's oath! Lady Cordelia welcomes you to the Order.\r\n(Reward: Black Rose Emblem added to inventory.)\r\nLore Event: Stones hold the memory of ancient gatherings, and you glimpse Everland's defenders from centuries past.\r\n"
lore_grim_msg:
    .text "\r\nGrim the Blackheart speaks: 'Few words, but deep loyalty. Sacrifice is the price of hope.'\r\n(Quest: Prove your loyalty in battle.)\r\n\r\nLore: The plaza stones shift, revealing a hidden passage. You glimpse Everland's defenders, their courage echoing in the heart of the park.\r\n"

portal_mythos_msg:
    .text "\r\nYou step through the portal and arrive in Mythos, realm of jungles and secrets. The Dragon Queen and ancient mysteries await.\r\n\r\nMYSTICWOOD: Dark trees crowd together, paper charms sway from branches. Herbs and moss blanket the ground, and the air is thick with whispered lore. Rituals are sometimes performed here, and spirits are said to watch from the shadows. If you listen closely, you may feel the presence of ancient magic and glimpse a vision of the wood's past.\r\n"
mythos_npc_menu_msg:
    .text "\r\nMYTHOS NPCs:\r\n1. Speak to the Dragon Queen\r\n2. Visit the Ancient Mystic\r\n3. Back to Portal\r\n> "
mythos_dragon_queen_msg:
    .text "\r\nThe Dragon Queen greets you: 'Welcome, traveler. Seek wisdom, and you may unlock the secrets of Mythos.'\r\n(Quest: Find the lost dragon scale.)\r\n\r\nQuest Multi-Path: 1) Join the dragon trainers or seek the hidden treasure, 2) Decide the fate of the loot, 3) Experience alternate dragon lore events based on your choice.\r\n"
mythos_dragon_scale_complete_msg:
    .text "\r\nQuest complete: You have found the lost dragon scale! The Queen rewards you with her blessing.\r\n(Reward: Dragon Scale added to inventory.)\r\nLore Event: Dragons soar through fire and sky, and you feel the ancient bond between trainer and dragon.\r\n"

select_user_slot:
    ldx #0
select_slot_msg_loop:
        lda select_slot_msg,X
        beq select_slot_msg_done
        jsr modem_out
        inx
        bne select_slot_msg_loop
select_slot_msg_done:
    jsr modem_in
    sec
    sbc #'0'
    cmp #1
    bcc select_user_slot
    cmp #9
    bcs select_user_slot
    sta user_slot
    // Update filenames
    ldx #7 // PROFILE0,S
    lda user_slot
    clc
    adc #'0'
    sta user_profile_filename,X
    ldx #6 // LOREBK0,S
    lda user_slot
    clc
    adc #'0'
    sta user_lore_filename,X
    ldx #7 // LOGSLOT0,S
    lda user_slot
    clc
    adc #'0'
    sta user_log_filename,X
    jsr prompt_username
    rts

prompt_username:
    ldx #0
prompt_username_msg_loop:
        lda prompt_username_msg,X
        beq prompt_username_msg_done
        jsr modem_out
        inx
        bne prompt_username_msg_loop
prompt_username_msg_done:
    ldx #0
prompt_username_input_loop:
        jsr modem_in
        cmp #13 // Return
        beq prompt_username_input_done
        sta user_name,X
        inx
        cpx #16
        bne prompt_username_input_loop
        jmp prompt_username_input_loop
prompt_username_input_done:
    rts
prompt_username_msg:
    .text "\r\nEnter your username (max 16 chars, press RETURN): "

// Quest/event log routines
quest_log_buffer: .fill 256, 0

save_quest_log:
    jsr open_log_file_write
    ldy #0
save_quest_log_loop:
        lda quest_log_buffer,Y
        jsr $FFD2 // CHROUT (write byte)
        iny
        cpy #256
        bne save_quest_log_loop
    jsr close_log_file
    rts

load_quest_log:
    jsr open_log_file_read
    ldy #0
load_quest_log_loop:
        jsr $FFD2 // CHRIN (read byte)
        sta quest_log_buffer,Y
        iny
        cpy #256
        bne load_quest_log_loop
    jsr close_log_file
    rts

open_log_file_write:
    lda #8 // device 8
    ldx #<user_log_filename
    ldy #>user_log_filename
    jsr $FFC0 // SETLFS
    lda #2 // write
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts
open_log_file_read:
    lda #8 // device 8
    ldx #<user_log_filename
    ldy #>user_log_filename
    jsr $FFC0 // SETLFS
    lda #1 // read
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts
close_log_file:
    lda #8 // device 8
    jsr $FFC3 // CLOSE
    rts

save_msg_board:
    jsr open_msg_board_file_write
    ldy #0
save_msg_board_loop:
        lda msg_board_buffer,Y
        jsr $FFD2 // CHROUT (write byte)
        iny
        cpy #1024
        bne save_msg_board_loop
    jsr close_msg_board_file
    rts

load_msg_board:
    jsr open_msg_board_file_read
    ldy #0
load_msg_board_loop:
        jsr $FFD2 // CHRIN (read byte)
        sta msg_board_buffer,Y
        iny
        cpy #1024
        bne load_msg_board_loop
    jsr close_msg_board_file
    rts

open_msg_board_file_write:
    lda #8 // device 8
    ldx #<msg_board_filename
    ldy #>msg_board_filename
    jsr $FFC0 // SETLFS
    lda #2 // write
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts
open_msg_board_file_read:
    lda #8 // device 8
    ldx #<msg_board_filename
    ldy #>msg_board_filename
    jsr $FFC0 // SETLFS
    lda #1 // read
    jsr $FFC3 // SETNAM
    jsr $FFC6 // OPEN
    rts
close_msg_board_file:
    lda #8 // device 8
    jsr $FFC3 // CLOSE
    rts

msg_board_prompt:
    .text "\r\n(R)eply, (N)ext thread, (A)dmin menu: "
admin_prompt_msg:
    .text "\r\n(D)elete message, (M)oderate message: "

admin_login:
    ldx #0
admin_login_msg_loop:
        lda admin_login_msg,X
        beq admin_login_msg_done
        jsr modem_out
        inx
        bne admin_login_msg_loop
admin_login_msg_done:
    ldx #0
admin_pw_input_loop:
        jsr modem_in
        cmp #13 // Return
        beq admin_pw_input_done
        sta admin_pw_buffer,X
        inx
        cpx #8
        bne admin_pw_input_loop
        jmp admin_pw_input_loop
admin_pw_input_done:
    ldx #0
admin_pw_check_loop:
        lda admin_pw_buffer,X
        cmp admin_password,X
        bne admin_login_fail
        inx
        cpx #8
        bne admin_pw_check_loop
    lda #1
    sta admin_logged_in
    jmp admin_menu
admin_login_fail:
    lda #0
    sta admin_logged_in
    jmp main_loop
admin_login_msg:
    .text "\r\nEnter admin password: "
admin_pw_buffer: .fill 8, 0

admin_menu:
    ldx #0
admin_menu_msg_loop:
        lda admin_menu_msg,X
        beq admin_menu_msg_done
        jsr modem_out
        inx
        bne admin_menu_msg_loop
admin_menu_msg_done:
    jsr modem_in
    cmp #'U'
    beq admin_user_list
    cmp #'B'
    beq go_admin_ban
    cmp #'R'
    beq go_admin_unban
    cmp #'M'
    beq go_admin_review
    cmp #'Q'
    beq go_admin_logout
    jmp admin_menu

go_admin_ban:
    jmp admin_ban_user
go_admin_unban:
    jmp admin_unban_user
go_admin_review:
    jmp admin_review_msgs
go_admin_logout:
    jmp admin_logout

admin_menu_msg:
    .text "\r\nADMIN MENU:\r\n(U)ser list, (B)an user, (R)estore user, (M)essage review, (Q)uit\r\n> "

admin_user_list:
    ldx #0
admin_user_list_loop:
        lda user_list,X
        beq admin_user_list_done
        jsr modem_out
        inx
        cpx #128
        bne admin_user_list_loop
admin_user_list_done:
    jmp admin_menu

admin_ban_user:
    // Prompt for slot, set user_banned
    ldx #0
admin_ban_msg_loop:
        lda admin_ban_msg,X
        beq admin_ban_msg_done
        jsr modem_out
        inx
        bne admin_ban_msg_loop
admin_ban_msg_done:
    jsr modem_in
    sec
    sbc #'0'
    cmp #1
    bcc go_admin_menu_ban1
    cmp #9
    bcs go_admin_menu_ban2
    tax
    lda #1
    sta user_banned,X
    jmp admin_menu
go_admin_menu_ban1:
    jmp admin_menu
go_admin_menu_ban2:
    jmp admin_menu
admin_ban_msg:
    .text "\r\nEnter user slot to ban (1-8): "

admin_unban_user:
    // Prompt for slot, clear user_banned
    ldx #0
admin_unban_msg_loop:
        lda admin_unban_msg,X
        beq admin_unban_msg_done
        jsr modem_out
        inx
        bne admin_unban_msg_loop
admin_unban_msg_done:
    jsr modem_in
    sec
    sbc #'0'
    cmp #1
    bcc go_admin_menu_unban1
    cmp #9
    bcs go_admin_menu_unban2
    tax
    lda #0
    sta user_banned,X
    jmp admin_menu
go_admin_menu_unban1:
    jmp admin_menu
go_admin_menu_unban2:
    jmp admin_menu
admin_unban_msg:
    .text "\r\nEnter user slot to restore (1-8): "

admin_review_msgs:
    // Show all message board threads/messages for review
    jsr load_msg_board
    ldx #0
admin_review_loop:
        lda msg_board_buffer,X
        beq admin_review_done
        jsr modem_out
        inx
        cpx #1024
        bne admin_review_loop
admin_review_done:
    jmp admin_menu

admin_logout:
    lda #0
    sta admin_logged_in
    jmp main_loop

// --- Expanded NPC/Quest Logic ---
custom_npc_table: .fill 128, 0 // 8 custom NPCs, 16 bytes each
quest_state: .fill 16, 0 // 8 quests, 2 bytes each (stage, outcome)

npc_menu:
    ldx #0
npc_menu_msg_loop:
        lda npc_menu_msg,X
        beq npc_menu_msg_done
        jsr modem_out
        inx
        bne npc_menu_msg_loop
npc_menu_msg_done:
    jsr get_npc_input
    jmp main_loop
npc_menu_msg:
    .text "\r\nNPC MENU:\r\n1. Speak to Kasimere\r\n2. Speak to Pumpkin King\r\n3. Speak to Alpha Wulfric\r\n4. Speak to Lyra\r\n5. Speak to Van Bueler\r\n6. Speak to Cedric\r\n7. Speak to Gwen\r\n8. Speak to Grim\r\n9. Back to Main Menu\r\n> "

get_npc_input:
    jsr modem_in
    cmp #'1'
    beq go_npc_kasimere
    cmp #'2'
    beq go_npc_pumpkin
    cmp #'3'
    beq go_npc_wulfric
    cmp #'4'
    beq go_npc_lyra
    cmp #'5'
    beq go_npc_bueler
    cmp #'6'
    beq go_npc_cedric
    cmp #'7'
    beq go_npc_gwen
    cmp #'8'
    beq go_npc_grim
    cmp #'9'
    beq go_main_loop_npc
    rts

go_npc_kasimere:
    jmp npc_kasimere
go_npc_pumpkin:
    jmp npc_pumpkin_king
go_npc_wulfric:
    jmp npc_wulfric
go_npc_lyra:
    jmp npc_lyra
go_npc_bueler:
    jmp npc_bueler
go_npc_cedric:
    jmp npc_cedric
go_npc_gwen:
    jmp npc_gwen
go_npc_grim:
    jmp npc_grim
go_main_loop_npc:
    jmp main_loop

npc_kasimere:
    // Multi-path quest: choose to help or betray Kasimere
    ldx #0
npc_kasimere_msg_loop:
        lda npc_kasimere_msg,X
        beq npc_kasimere_msg_done
        jsr modem_out
        inx
        bne npc_kasimere_msg_loop
npc_kasimere_msg_done:
    jsr modem_in
    cmp #'H'
    beq kasimere_help
    cmp #'B'
    beq kasimere_betray
    jmp npc_menu
kasimere_help:
    lda #1
    sta quest_state
    jmp npc_menu
kasimere_betray:
    lda #2
    sta quest_state
    jmp npc_menu
npc_kasimere_msg:
    .text "\r\nKasimere: Will you (H)elp or (B)etray me? "

npc_pumpkin_king:
    // Branching event: battle or negotiate
    ldx #0
npc_pumpkin_king_msg_loop:
        lda npc_pumpkin_king_msg,X
        beq npc_pumpkin_king_msg_done
        jsr modem_out
        inx
        bne npc_pumpkin_king_msg_loop
npc_pumpkin_king_msg_done:
    jsr modem_in
    cmp #'F'
    beq pumpkin_fight
    cmp #'N'
    beq pumpkin_negotiate
    jmp npc_menu
pumpkin_fight:
    lda #1
    sta quest_state+1
    jmp npc_menu
pumpkin_negotiate:
    lda #2
    sta quest_state+1
    jmp npc_menu
npc_pumpkin_king_msg:
    .text "\r\nPumpkin King: (F)ight or (N)egotiate? "

npc_wulfric:
    // Wolf pact: join or refuse
    ldx #0
npc_wulfric_msg_loop:
        lda npc_wulfric_msg,X
        beq npc_wulfric_msg_done
        jsr modem_out
        inx
        bne npc_wulfric_msg_loop
npc_wulfric_msg_done:
    jsr modem_in
    cmp #'J'
    beq wulfric_join
    cmp #'R'
    beq wulfric_refuse
    jmp npc_menu
wulfric_join:
    lda #1
    sta quest_state+2
    jmp npc_menu
wulfric_refuse:
    lda #2
    sta quest_state+2
    jmp npc_menu
npc_wulfric_msg:
    .text "\r\nAlpha Wulfric: (J)oin the pact or (R)efuse? "

// --- Missing Menu Stubs ---
message_board:
    ldx #0
message_board_loop:
        lda message_board_stub_msg,X
        beq message_board_done
        jsr modem_out
        inx
        bne message_board_loop
message_board_done:
    jmp main_loop
message_board_stub_msg:
    .text "\r\nMessage Board coming soon!\r\n"

async_pvp:
    ldx #0
async_pvp_loop:
        lda async_pvp_stub_msg,X
        beq async_pvp_done
        jsr modem_out
        inx
        bne async_pvp_loop
async_pvp_done:
    jmp main_loop
async_pvp_stub_msg:
    .text "\r\nAsync PvP coming soon!\r\n"

save_game:
    ldx #0
save_game_loop:
        lda save_game_stub_msg,X
        beq save_game_done
        jsr modem_out
        inx
        bne save_game_loop
save_game_done:
    jmp main_loop
save_game_stub_msg:
    .text "\r\nSave Game coming soon!\r\n"

load_game:
    ldx #0
load_game_loop:
        lda load_game_stub_msg,X
        beq load_game_done
        jsr modem_out
        inx
        bne load_game_loop
load_game_done:
    jmp main_loop
load_game_stub_msg:
    .text "\r\nLoad Game coming soon!\r\n"

portal_travel:
    ldx #0
portal_travel_loop:
        lda portal_travel_stub_msg,X
        beq portal_travel_done
        jsr modem_out
        inx
        bne portal_travel_loop
portal_travel_done:
    jmp main_loop
portal_travel_stub_msg:
    .text "\r\nPortal Travel coming soon!\r\n"

quit_game:
    ldx #0
quit_game_loop:
        lda quit_game_msg,X
        beq quit_game_done
        jsr modem_out
        inx
        bne quit_game_loop
quit_game_done:
    rts
quit_game_msg:
    .text "\r\nGoodbye! Thanks for playing Everland!\r\n"

browse_lore_book:
    ldx #0
browse_lore_loop:
        lda browse_lore_msg,X
        beq browse_lore_done
        jsr modem_out
        inx
        bne browse_lore_loop
browse_lore_done:
    jmp library_menu
browse_lore_msg:
    .text "\r\nBrowse Lore Book coming soon!\r\n"

select_slot_msg:
    .text "\r\nSelect slot (1-8): "

npc_lyra:
    ldx #0
npc_lyra_loop:
        lda npc_lyra_msg,X
        beq npc_lyra_done
        jsr modem_out
        inx
        bne npc_lyra_loop
npc_lyra_done:
    jmp npc_menu
npc_lyra_msg:
    .text "\r\nLyra: The echoes of magic call to you...\r\n"

npc_bueler:
    ldx #0
npc_bueler_loop:
        lda npc_bueler_msg,X
        beq npc_bueler_done
        jsr modem_out
        inx
        bne npc_bueler_loop
npc_bueler_done:
    jmp npc_menu
npc_bueler_msg:
    .text "\r\nVan Bueler: Care to make a trade?\r\n"

npc_cedric:
    ldx #0
npc_cedric_loop:
        lda npc_cedric_msg,X
        beq npc_cedric_done
        jsr modem_out
        inx
        bne npc_cedric_loop
npc_cedric_done:
    jmp npc_menu
npc_cedric_msg:
    .text "\r\nCedric: The forge awaits your request.\r\n"

npc_gwen:
    ldx #0
npc_gwen_loop:
        lda npc_gwen_msg,X
        beq npc_gwen_done
        jsr modem_out
        inx
        bne npc_gwen_loop
npc_gwen_done:
    jmp npc_menu
npc_gwen_msg:
    .text "\r\nGwen: What mysteries do you seek?\r\n"

npc_grim:
    ldx #0
npc_grim_loop:
        lda npc_grim_msg,X
        beq npc_grim_done
        jsr modem_out
        inx
        bne npc_grim_loop
npc_grim_done:
    jmp npc_menu
npc_grim_msg:
    .text "\r\nGrim: The shadows grow long...\r\n"

npc_artifacts:
    ldx #0
npc_artifacts_loop:
        lda npc_artifacts_msg,X
        beq npc_artifacts_done
        jsr modem_out
        inx
        bne npc_artifacts_loop
npc_artifacts_done:
    jmp npc_menu
npc_artifacts_msg:
    .text "\r\nArtifacts of power shimmer before you...\r\n"

// --- Room Customization Menu ---
user_room_menu:
    ldx #0
user_room_menu_header_loop:
        lda user_room_menu_msg,X
        beq user_room_menu_header_done
        jsr modem_out
        inx
        bne user_room_menu_header_loop
user_room_menu_header_done:
    jsr modem_in
    cmp #'1'
    beq go_edit_desc
    cmp #'2'
    beq go_choose_decor
    cmp #'3'
    beq go_choose_color
    cmp #'4'
    beq go_edit_ascii
    cmp #'5'
    beq go_view_ascii
    cmp #'6'
    beq go_view_guestbook
    cmp #'7'
    beq go_leave_guestbook
    cmp #'8'
    beq go_room_privacy
    cmp #'9'
    beq go_friends_list
    cmp #'0'
    beq go_main_from_room
    jmp user_room_menu

go_edit_desc:
    jmp edit_room_description
go_choose_decor:
    jmp choose_room_decor
go_choose_color:
    jmp choose_room_color
go_edit_ascii:
    jmp edit_room_ascii
go_view_ascii:
    jmp view_room_ascii
go_view_guestbook:
    jmp view_guestbook
go_leave_guestbook:
    jmp leave_guestbook
go_room_privacy:
    jmp room_privacy_menu
go_friends_list:
    jmp friends_list_menu
go_main_from_room:
    jmp main_loop

user_room_menu_msg:
    .text "\r\nMY ROOM:\r\n1. Edit Description\r\n2. Choose Decor\r\n3. Choose Color\r\n4. Edit ASCII Art\r\n5. View ASCII Art\r\n6. View Guestbook\r\n7. Leave Guestbook Entry\r\n8. Privacy Settings\r\n9. Friends List\r\n0. Back to Main\r\n> "

edit_room_description:
    ldx #0
edit_desc_prompt_loop:
        lda edit_desc_prompt_msg,X
        beq edit_desc_prompt_done
        jsr modem_out
        inx
        bne edit_desc_prompt_loop
edit_desc_prompt_done:
    ldx #0
edit_desc_input:
        jsr modem_in
        cmp #13
        beq edit_desc_done
        sta user_room_desc,X
        inx
        cpx #64
        bne edit_desc_input
edit_desc_done:
    lda #0
    sta user_room_desc,X
    ldx #0
desc_saved_loop:
        lda desc_saved_msg,X
        beq desc_saved_done
        jsr modem_out
        inx
        bne desc_saved_loop
desc_saved_done:
    jmp user_room_menu
edit_desc_prompt_msg:
    .text "\r\nEnter room description (64 chars max):\r\n> "
desc_saved_msg:
    .text "\r\nDescription saved!\r\n"

choose_room_decor:
    ldx #0
choose_decor_prompt_loop:
        lda choose_decor_msg,X
        beq choose_decor_prompt_done
        jsr modem_out
        inx
        bne choose_decor_prompt_loop
choose_decor_prompt_done:
    jsr modem_in
    sec
    sbc #'0'
    cmp #4
    bcs choose_room_decor
    sta user_room_decor
    ldx #0
decor_saved_loop:
        lda decor_saved_msg,X
        beq decor_saved_done
        jsr modem_out
        inx
        bne decor_saved_loop
decor_saved_done:
    jmp user_room_menu
choose_decor_msg:
    .text "\r\nChoose Decor:\r\n0. Castle\r\n1. Forest\r\n2. Dungeon\r\n3. Garden\r\n> "
decor_saved_msg:
    .text "\r\nDecor saved!\r\n"

choose_room_color:
    ldx #0
choose_color_prompt_loop:
        lda choose_color_msg,X
        beq choose_color_prompt_done
        jsr modem_out
        inx
        bne choose_color_prompt_loop
choose_color_prompt_done:
    jsr modem_in
    sec
    sbc #'0'
    cmp #6
    bcs choose_room_color
    sta user_room_color
    ldx #0
color_saved_loop:
        lda color_saved_msg,X
        beq color_saved_done
        jsr modem_out
        inx
        bne color_saved_loop
color_saved_done:
    jmp user_room_menu
choose_color_msg:
    .text "\r\nChoose Color:\r\n0. Blue\r\n1. Green\r\n2. Red\r\n3. Gold\r\n4. Purple\r\n5. White\r\n> "
color_saved_msg:
    .text "\r\nColor saved!\r\n"

edit_room_ascii:
    ldx #0
edit_ascii_prompt_loop:
        lda edit_ascii_prompt_msg,X
        beq edit_ascii_prompt_done
        jsr modem_out
        inx
        bne edit_ascii_prompt_loop
edit_ascii_prompt_done:
    ldy #0
ascii_line_loop:
        ldx #0
ascii_char_loop:
            jsr modem_in
            cmp #13
            beq ascii_line_done
            sta user_room_ascii,X
            inx
            cpx #32
            bne ascii_char_loop
ascii_line_done:
        // Pad rest of line with spaces
ascii_pad_loop:
            cpx #32
            beq ascii_next_line
            lda #' '
            sta user_room_ascii,X
            inx
            jmp ascii_pad_loop
ascii_next_line:
        iny
        cpy #4
        bne ascii_line_loop
    ldx #0
ascii_saved_loop:
        lda ascii_saved_msg,X
        beq ascii_saved_done
        jsr modem_out
        inx
        bne ascii_saved_loop
ascii_saved_done:
    jmp user_room_menu
edit_ascii_prompt_msg:
    .text "\r\nEnter ASCII art (4 lines, 32 chars each):\r\n"
ascii_saved_msg:
    .text "\r\nASCII art saved!\r\n"

view_room_ascii:
    ldx #0
view_ascii_header_loop:
        lda view_ascii_header_msg,X
        beq view_ascii_header_done
        jsr modem_out
        inx
        bne view_ascii_header_loop
view_ascii_header_done:
    ldy #0
view_ascii_line:
        ldx #0
view_ascii_char:
            lda user_room_ascii,X
            beq view_ascii_next_line
            jsr modem_out
            inx
            cpx #32
            bne view_ascii_char
view_ascii_next_line:
        lda #13
        jsr modem_out
        iny
        cpy #4
        bne view_ascii_line
    jsr modem_in // wait for key
    jmp user_room_menu
view_ascii_header_msg:
    .text "\r\nYour Room ASCII Art:\r\n"

view_guestbook:
    ldx #0
view_guestbook_header_loop:
        lda view_guestbook_header_msg,X
        beq view_guestbook_header_done
        jsr modem_out
        inx
        bne view_guestbook_header_loop
view_guestbook_header_done:
    ldx #0
view_guestbook_entries:
        lda guestbook_entries,X
        beq view_guestbook_done
        jsr modem_out
        inx
        cpx #160
        bne view_guestbook_entries
view_guestbook_done:
    jsr modem_in // wait for key
    jmp user_room_menu
view_guestbook_header_msg:
    .text "\r\nGUESTBOOK:\r\n"

leave_guestbook:
    ldx #0
leave_guestbook_prompt_loop:
        lda leave_guestbook_prompt_msg,X
        beq leave_guestbook_prompt_done
        jsr modem_out
        inx
        bne leave_guestbook_prompt_loop
leave_guestbook_prompt_done:
    // Shift existing entries down, add new at top
    ldx #127
shift_guestbook_loop:
        lda guestbook_entries,X
        sta guestbook_entries+32,X
        dex
        bpl shift_guestbook_loop
    ldx #0
leave_guestbook_input:
        jsr modem_in
        cmp #13
        beq leave_guestbook_done
        sta guestbook_entries,X
        inx
        cpx #32
        bne leave_guestbook_input
leave_guestbook_done:
    lda #0
    sta guestbook_entries,X
    ldx #0
guestbook_saved_loop:
        lda guestbook_saved_msg,X
        beq guestbook_saved_done
        jsr modem_out
        inx
        bne guestbook_saved_loop
guestbook_saved_done:
    jmp user_room_menu
leave_guestbook_prompt_msg:
    .text "\r\nLeave a message (32 chars max):\r\n> "
guestbook_saved_msg:
    .text "\r\nMessage added to guestbook!\r\n"

room_privacy_menu:
    ldx #0
room_privacy_prompt_loop:
        lda room_privacy_prompt_msg,X
        beq room_privacy_prompt_done
        jsr modem_out
        inx
        bne room_privacy_prompt_loop
room_privacy_prompt_done:
    jsr modem_in
    sec
    sbc #'0'
    cmp #3
    bcs room_privacy_menu
    sta user_room_privacy
    ldx #0
privacy_saved_loop:
        lda privacy_saved_msg,X
        beq privacy_saved_done
        jsr modem_out
        inx
        bne privacy_saved_loop
privacy_saved_done:
    jmp user_room_menu
room_privacy_prompt_msg:
    .text "\r\nPrivacy:\r\n0. Public\r\n1. Friends-Only\r\n2. Private\r\n> "
privacy_saved_msg:
    .text "\r\nPrivacy setting saved!\r\n"

friends_list_menu:
    ldx #0
friends_list_header_loop:
        lda friends_list_header_msg,X
        beq friends_list_header_done
        jsr modem_out
        inx
        bne friends_list_header_loop
friends_list_header_done:
    // Show friends list
    ldy #0
show_friends_loop:
        lda user_friends_list,Y
        beq show_friends_next
        jsr modem_out
        lda #13
        jsr modem_out
show_friends_next:
        iny
        cpy #16
        bne show_friends_loop
    // Show menu options
    ldx #0
friends_menu_options_loop:
        lda friends_menu_options_msg,X
        beq friends_menu_options_done
        jsr modem_out
        inx
        bne friends_menu_options_loop
friends_menu_options_done:
    jsr modem_in
    cmp #'A'
    beq go_add_friend
    cmp #'R'
    beq go_remove_friend
    cmp #'0'
    beq go_room_from_friends
    jmp friends_list_menu
go_add_friend:
    jmp add_friend
go_remove_friend:
    jmp remove_friend
go_room_from_friends:
    jmp user_room_menu
friends_list_header_msg:
    .text "\r\nFRIENDS LIST:\r\n"
friends_menu_options_msg:
    .text "\r\n(A)dd, (R)emove, (0) Back\r\n> "

add_friend:
    ldx #0
add_friend_prompt_loop:
        lda add_friend_prompt_msg,X
        beq add_friend_prompt_done
        jsr modem_out
        inx
        bne add_friend_prompt_loop
add_friend_prompt_done:
    jsr modem_in
    ldy #0
find_friend_slot:
        lda user_friends_list,Y
        beq store_friend
        iny
        cpy #16
        bne find_friend_slot
        jmp friends_list_menu // Full
store_friend:
    sta user_friends_list,Y
    inc user_friends_count
    ldx #0
friend_added_loop:
        lda friend_added_msg,X
        beq friend_added_done
        jsr modem_out
        inx
        bne friend_added_loop
friend_added_done:
    jmp friends_list_menu
add_friend_prompt_msg:
    .text "\r\nEnter friend ID: "
friend_added_msg:
    .text "\r\nFriend added!\r\n"

remove_friend:
    ldx #0
remove_friend_prompt_loop:
        lda remove_friend_prompt_msg,X
        beq remove_friend_prompt_done
        jsr modem_out
        inx
        bne remove_friend_prompt_loop
remove_friend_prompt_done:
    jsr modem_in
    sec
    sbc #'1'
    cmp #16
    bcs go_friends_invalid
    tay
    lda #0
    sta user_friends_list,Y
    dec user_friends_count
    ldx #0
friend_removed_loop:
        lda friend_removed_msg,X
        beq friend_removed_done
        jsr modem_out
        inx
        bne friend_removed_loop
friend_removed_done:
    jmp friends_list_menu
go_friends_invalid:
    jmp friends_list_menu
remove_friend_prompt_msg:
    .text "\r\nEnter # to remove: "
friend_removed_msg:
    .text "\r\nFriend removed.\r\n"

// End of file
