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
    .byte "\r\nEVERLAND MAIN MENU:\r\n(Where memory and magic entwine)\r\n1. Play Everland\r\n2. Inventory\r\n3. High Scores\r\n4. Message Board\r\n5. Async PvP\r\n6. Save Game\r\n7. Load Game\r\n8. Portal Travel\r\n9. Quit\r\nL. Library\r\nU. User Customization\r\n\r\nLore: The portal shimmers with fractured memories. Quests shape the fate of Everland.\r\n> ",0

get_menu_input:
    ; Get a key from modem
    JSR modem_in
    CMP #'U'
    BEQ user_customization_menu
    RTS
; --- User Customization ---
user_avatar: .byte 0
user_nickname: .res 16,0 ; PETSCII nickname
user_color: .byte 0
user_settings: .byte 0

user_customization_menu:

    ; Display current selections
    LDX #0
show_current_customization:
        LDA show_current_customization_msg,X
        BEQ show_current_customization_done
        JSR modem_out
        INX
        BNE show_current_customization
show_current_customization_done:
    LDA user_avatar
    JSR print_avatar_name
    LDX #0
show_nickname_loop:
        LDA user_nickname,X
        BEQ show_nickname_done
        JSR modem_out
        INX
        CPX #16
        BNE show_nickname_loop
show_nickname_done:
    LDA user_color
    JSR print_color_name
    LDA user_settings
    JSR print_settings_name
    LDX #0
user_customization_menu_msg_loop:
        LDA user_customization_menu_msg,X
        BEQ user_customization_menu_msg_done
        JSR modem_out
        INX
        BNE user_customization_menu_msg_loop
user_customization_menu_msg_done:
    JSR get_user_customization_input
    JMP main_loop

; --- Customization Help Routine ---
customization_help:
    LDX #0
customization_help_msg_loop:
        LDA customization_help_msg,X
        BEQ customization_help_msg_done
        JSR modem_out
        INX
        BNE customization_help_msg_loop
customization_help_msg_done:
    JSR wait_for_key
    RTS

customization_help_msg:
    .byte "\r\nCUSTOMIZATION HELP:\r\nUse 1-9, A, B to select options.\r\nSet your avatar, color, nickname, and more.\r\n'B' is a temporary session override.\r\n'6' previews color.\r\n'0' returns to main menu.\r\nPress any key to return.\r\n",0

show_current_customization_msg:
    .byte "\r\nCURRENT CUSTOMIZATION:\r\nAvatar: ",0
    .byte "Nickname: ",0

print_avatar_name:
    CMP #0
    BEQ avatar_knight
    CMP #1
    BEQ avatar_wizard
    CMP #2
    BEQ avatar_elf
    CMP #3
    BEQ avatar_dragon
    RTS
avatar_knight:
    LDX #0
    .byte "Knight\r\nA brave defender, excels at melee combat.\r\n",0
    RTS
avatar_wizard:
    LDX #0
    .byte "Wizard\r\nA master of arcane arts, wise and clever.\r\n",0
    RTS
avatar_elf:
    LDX #0
    .byte "Elf\r\nSwift and agile, attuned to nature.\r\n",0
    RTS
avatar_dragon:
    LDX #0
    .byte "Dragon\r\nMysterious and powerful, breathes fire.\r\n",0
    RTS
avatar_knight:
    LDX #0
    .byte "Knight\r\n",0
    RTS
avatar_wizard:
    LDX #0
    .byte "Wizard\r\n",0
    RTS
avatar_elf:
    LDX #0
    .byte "Elf\r\n",0
    RTS
avatar_dragon:
    LDX #0
    .byte "Dragon\r\n",0
    RTS

print_color_name:
    LDX #0
    .byte "Color: ",0
    LDA user_color
    CMP #0
    BEQ color_blue
    CMP #1
    BEQ color_green
    CMP #2
    BEQ color_red
    CMP #3
    BEQ color_gold
    RTS
color_blue:
    LDX #0
    .byte "Blue\r\n",0
    RTS
color_green:
    LDX #0
    .byte "Green\r\n",0
    RTS
color_red:
    LDX #0
    .byte "Red\r\n",0
    RTS
color_gold:
    LDX #0
    .byte "Gold\r\n",0
    RTS

print_settings_name:
    LDX #0
    .byte "Settings: ",0
    LDA user_settings
    CMP #0
    BEQ settings_normal
    CMP #1
    BEQ settings_hardcore
    CMP #2
    BEQ settings_relaxed
    RTS
settings_normal:
    LDX #0
    .byte "Normal\r\n",0
    RTS
settings_hardcore:
    LDX #0
    .byte "Hardcore\r\n",0
    RTS
settings_relaxed:
    LDX #0
    .byte "Relaxed\r\n",0
    RTS

user_customization_menu_msg:
    .byte "\r\nUSER CUSTOMIZATION:\r\n1. Choose Avatar\r\n2. Choose Color Scheme\r\n3. Game Settings\r\n4. Set Nickname\r\n5. Randomize Avatar/Color\r\n6. Color Test Mode\r\n7. Save Customization\r\n8. Load Customization\r\n9. Reset to Defaults\r\nA. Copy Customization to Another Slot\r\nB. Temporary Session Override\r\n0. Back to Main Menu\r\n> ",0

get_user_customization_input:
get_user_customization_input_loop:
    JSR modem_in
    CMP #'1'
    BEQ choose_avatar
    CMP #'2'
    BEQ choose_color
    CMP #'3'
    BEQ choose_settings
    CMP #'4'
    BEQ set_nickname
    CMP #'5'
    BEQ randomize_avatar_color
    CMP #'6'
    BEQ color_test_mode
    CMP #'7'
    BEQ save_user_customization
    CMP #'8'
    BEQ load_user_customization
    CMP #'9'
    BEQ reset_customization
    CMP #'A'
    BEQ copy_customization_to_slot
    CMP #'B'
    BEQ session_override
    CMP #'0'
    BEQ main_loop
    CMP #'?'
    BEQ customization_help_call
    ; Invalid key: beep and loop
    LDA #$07 ; PETSCII bell
    JSR modem_out
    JMP get_user_customization_input_loop
customization_help_call:
    JSR customization_help
    JMP get_user_customization_input_loop
    RTS
color_test_mode:
    LDA user_color
    JSR apply_color_to_ui
    LDX #0
color_test_msg_loop:
        LDA color_test_msg,X
        BEQ color_test_msg_done
        JSR modem_out
        INX
        BNE color_test_msg_loop
color_test_msg_done:
    RTS
color_test_msg:
    .byte "\r\nColor test mode: UI color applied!\r\n",0
apply_color_to_ui:
    ; Simulate by outputting PETSCII color code (real UI would set color RAM)
    CMP #0
    BEQ ui_blue
    CMP #1
    BEQ ui_green
    CMP #2
    BEQ ui_red
    CMP #3
    BEQ ui_gold
    RTS
ui_blue:
    LDA #$1F ; PETSCII blue
    JSR modem_out
    RTS
ui_green:
    LDA #$05 ; PETSCII green
    JSR modem_out
    RTS
ui_red:
    LDA #$1C ; PETSCII red
    JSR modem_out
    RTS
ui_gold:
    LDA #$1D ; PETSCII yellow/gold
    JSR modem_out
    RTS

session_override:
    LDX #0
session_override_msg_loop:
        LDA session_override_msg,X
        BEQ session_override_msg_done
        JSR modem_out
        INX
        BNE session_override_msg_loop
session_override_msg_done:
    ; Prompt for temp avatar
    JSR choose_avatar
    ; Prompt for temp color
    JSR choose_color
    ; Prompt for temp settings
    JSR choose_settings
    LDX #0
session_override_done_msg_loop:
        LDA session_override_done_msg,X
        BEQ session_override_done_msg_done
        JSR modem_out
        INX
        BNE session_override_done_msg_loop
session_override_done_msg_done:
    RTS
session_override_msg:
    .byte "\r\nTemporary session override: choose avatar, color, and settings. These will not be saved.\r\n",0
session_override_done_msg:
    .byte "\r\nSession override applied!\r\n",0
randomize_avatar_color:
    JSR random
    AND #3
    STA user_avatar
    JSR random
    AND #3
    STA user_color
    LDX #0
randomize_msg_loop:
        LDA randomize_msg,X
        BEQ randomize_msg_done
        JSR modem_out
        INX
        BNE randomize_msg_loop
randomize_msg_done:
    ; Show preview after randomization
    LDA user_avatar
    JSR print_avatar_name
    LDA user_color
    JSR print_color_name
    RTS
randomize_msg:
    .byte "\r\nAvatar and color randomized!\r\n",0
random:
    LDA $D012 ; use raster as a simple random seed
    RTS
set_nickname:
    LDX #0
set_nickname_msg_loop:
        LDA set_nickname_msg,X
        BEQ set_nickname_msg_done
        JSR modem_out
        INX
        BNE set_nickname_msg_loop
set_nickname_msg_done:
    LDX #0
set_nickname_input_loop:
        JSR modem_in
        CMP #13 ; Enter
        BEQ set_nickname_input_done
        STA user_nickname,X
        INX
        CPX #16
        BNE set_nickname_input_loop
set_nickname_input_done:
    RTS
set_nickname_msg:
    .byte "\r\nEnter your nickname (max 16 chars, Enter to finish): ",0

choose_avatar:
    LDX #0
choose_avatar_preview:
        LDA choose_avatar_msg,X
        BEQ choose_avatar_preview_done
        JSR modem_out
        INX
        BNE choose_avatar_preview
choose_avatar_preview_done:
    LDA user_avatar
    JSR show_avatar_art
    JSR modem_out
    LDX #0
choose_avatar_input_msg_loop:
        LDA choose_avatar_input_msg,X
        BEQ choose_avatar_input_msg_done
        JSR modem_out
        INX
        BNE choose_avatar_input_msg_loop
choose_avatar_input_msg_done:
    JSR modem_in
    CMP #'N'
    BEQ avatar_next
    CMP #'P'
    BEQ avatar_prev
    CMP #'S'
    BEQ avatar_select
    RTS
avatar_next:
    INC user_avatar
    LDA user_avatar
    CMP #4
    BNE choose_avatar
    LDA #0
    STA user_avatar
    JMP choose_avatar
avatar_prev:
    LDA user_avatar
    BEQ avatar_prev_wrap
    DEC user_avatar
    JMP choose_avatar
avatar_prev_wrap:
    LDA #3
    STA user_avatar
    JMP choose_avatar
avatar_select:
    RTS
choose_avatar_msg:
    .byte "\r\nChoose Avatar (N=Next, P=Prev, S=Select):\r\n",0
choose_avatar_input_msg:
    .byte "N=Next, P=Prev, S=Select\r\n",0
show_avatar_art:
    CMP #0
    BEQ avatar_art_knight
    CMP #1
    BEQ avatar_art_wizard
    CMP #2
    BEQ avatar_art_elf
    CMP #3
    BEQ avatar_art_dragon
    RTS
avatar_art_knight:
    LDX #0
    .byte "[K]  o>\r\n    /|\r\n   / \\ Knight\r\n",0
    RTS
avatar_art_wizard:
    LDX #0
    .byte "[W]  /\\\r\n    ( )\r\n    /_\\ Wizard\r\n",0
    RTS
avatar_art_elf:
    LDX #0
    .byte "[E]  /\\\r\n    |o|\r\n    / \\ Elf\r\n",0
    RTS
avatar_art_dragon:
    LDX #0
    .byte "[D]  /\\_/\\\r\n   ( o.o )\r\n    > ^ < Dragon\r\n",0
    RTS
set_avatar_knight:
    LDA #0
    STA user_avatar
    RTS
set_avatar_wizard:
    LDA #1
    STA user_avatar
    RTS
set_avatar_elf:
    LDA #2
    STA user_avatar
    RTS
set_avatar_dragon:
    LDA #3
    STA user_avatar
    RTS
choose_avatar_msg:
    .byte "\r\nChoose Avatar (0=Knight, 1=Wizard, 2=Elf, 3=Dragon): ",0

choose_color:
    LDX #0
choose_color_preview:
        LDA choose_color_msg,X
        BEQ choose_color_preview_done
        JSR modem_out
        INX
        BNE choose_color_preview
choose_color_preview_done:
    LDA user_color
    JSR show_color_preview
    JSR show_color_petscii
    JSR modem_out
    LDX #0
choose_color_input_msg_loop:
        LDA choose_color_input_msg,X
        BEQ choose_color_input_msg_done
        JSR modem_out
        INX
        BNE choose_color_input_msg_loop
choose_color_input_msg_done:
    JSR modem_in
    CMP #'N'
    BEQ color_next
    CMP #'P'
    BEQ color_prev
    CMP #'S'
    BEQ color_select
    RTS
show_color_petscii:
    LDA user_color
    CMP #0
    BEQ petscii_blue
    CMP #1
    BEQ petscii_green
    CMP #2
    BEQ petscii_red
    CMP #3
    BEQ petscii_gold
    RTS
petscii_blue:
    LDX #0
    .byte "\x9e\x9e\x9e\x9e\x9e\x9e\x9e\x9e\x9e\x9e\r\n",0
    RTS
petscii_green:
    LDX #0
    .byte "\x1e\x1e\x1e\x1e\x1e\x1e\x1e\x1e\x1e\x1e\r\n",0
    RTS
petscii_red:
    LDX #0
    .byte "\x1c\x1c\x1c\x1c\x1c\x1c\x1c\x1c\x1c\x1c\r\n",0
    RTS
petscii_gold:
    LDX #0
    .byte "\x1d\x1d\x1d\x1d\x1d\x1d\x1d\x1d\x1d\x1d\r\n",0
    RTS
color_next:
    INC user_color
    LDA user_color
    CMP #4
    BNE choose_color
    LDA #0
    STA user_color
    JMP choose_color
color_prev:
    LDA user_color
    BEQ color_prev_wrap
    DEC user_color
    JMP choose_color
color_prev_wrap:
    LDA #3
    STA user_color
    JMP choose_color
color_select:
    LDX #0
set_nickname_msg_loop:
        LDA set_nickname_msg,X
        BEQ set_nickname_msg_done
        JSR modem_out
        INX
        BNE set_nickname_msg_loop
set_nickname_msg_done:
    LDX #0
    LDY #0
set_nickname_input_loop:
        JSR modem_in
        CMP #13 ; Enter
        BEQ set_nickname_input_done
        STA user_nickname,Y
        INY
        CPY #16
        BNE set_nickname_input_loop
set_nickname_input_done:
    ; Validate nickname is not empty
    LDY #0
    LDA user_nickname,Y
    BEQ nickname_empty
    RTS
nickname_empty:
    LDX #0
nickname_empty_msg_loop:
        LDA nickname_empty_msg,X
        BEQ nickname_empty_msg_done
        JSR modem_out
        INX
        BNE nickname_empty_msg_loop
nickname_empty_msg_done:
    JMP set_nickname
nickname_empty_msg:
    .byte "\r\nNickname cannot be empty!\r\n",0
copy_customization_to_slot:
    LDX #0
copy_slot_msg_loop:
        LDA copy_slot_msg,X
        BEQ copy_slot_msg_done
        JSR modem_out
        INX
        BNE copy_slot_msg_loop
copy_slot_msg_done:
    JSR modem_in
    SEC
    SBC #'0'
    TAX
    ; Save current customization to selected slot (simulate by writing to profile file for slot)
    ; Update user_profile_filename for slot
    LDA #'0'
    CLC
    ADC X
    STA user_profile_filename+7
    JSR save_user_customization
    LDX #0
copy_slot_done_msg_loop:
        LDA copy_slot_done_msg,X
        BEQ copy_slot_done_msg_done
        JSR modem_out
        INX
        BNE copy_slot_done_msg_loop
copy_slot_done_msg_done:
    RTS
copy_slot_msg:
    .byte "\r\nCopy customization to which slot (0-7)? ",0
copy_slot_done_msg:
    .byte "\r\nCustomization copied to slot!\r\n",0
color_preview_green:
    LDX #0
    .byte "[Green] \x1e\x05\x1f\r\n",0 ; PETSCII green
    RTS
color_preview_red:
    LDX #0
    .byte "[Red] \x1c\x05\x1f\r\n",0 ; PETSCII red
    RTS
color_preview_gold:
    LDX #0
    .byte "[Gold] \x1d\x05\x1f\r\n",0 ; PETSCII yellow/gold
    RTS
set_color_blue:
    LDA #0
    STA user_color
    RTS
set_color_green:
    LDA #1
    STA user_color
    RTS
set_color_red:
    LDA #2
    STA user_color
    RTS
set_color_gold:
    LDA #3
    STA user_color
    RTS
choose_color_msg:
    .byte "\r\nChoose Color Scheme (0=Blue, 1=Green, 2=Red, 3=Gold): ",0

choose_settings:
    LDX #0
choose_settings_msg_loop:
        LDA choose_settings_msg,X
        BEQ choose_settings_msg_done
        JSR modem_out
        INX
        BNE choose_settings_msg_loop
choose_settings_msg_done:
    JSR modem_in
    CMP #'0'
    BEQ set_settings_normal
    CMP #'1'
    BEQ set_settings_hardcore
    CMP #'2'
    BEQ set_settings_relaxed
    RTS
reset_customization:
    LDA #0
    STA user_avatar
    STA user_color
    STA user_settings
    LDX #0
reset_customization_msg_loop:
        LDA reset_customization_msg,X
        BEQ reset_customization_msg_done
        JSR modem_out
        INX
        BNE reset_customization_msg_loop
reset_customization_msg_done:
    RTS
reset_customization_msg:
    .byte "\r\nCustomization reset to defaults!\r\n",0
set_settings_normal:
    LDA #0
    STA user_settings
    RTS
set_settings_hardcore:
    LDA #1
    STA user_settings
    RTS
set_settings_relaxed:
    LDA #2
    STA user_settings
    RTS
choose_settings_msg:
    .byte "\r\nGame Settings (0=Normal, 1=Hardcore, 2=Relaxed): ",0

save_user_customization:
    JSR open_profile_file_write
    LDA user_avatar
    JSR $FFD2
    LDA user_color
    JSR $FFD2
    LDA user_settings
    JSR $FFD2
    LDY #0
save_nickname_loop:
        LDA user_nickname,Y
        JSR $FFD2
        INY
        CPY #16
        BNE save_nickname_loop
    JSR close_lore_file
    LDX #0
save_customization_msg_loop:
        LDA save_customization_msg,X
        BEQ save_customization_msg_done
        JSR modem_out
        INX
        BNE save_customization_msg_loop
save_customization_msg_done:
    RTS
save_customization_msg:
    .byte "\r\nCustomization saved!\r\n",0

load_user_customization:
    JSR open_profile_file_read
    JSR $FFD2
    STA user_avatar
    JSR $FFD2
    STA user_color
    JSR $FFD2
    STA user_settings
    LDY #0
load_nickname_loop:
        JSR $FFD2
        STA user_nickname,Y
        INY
        CPY #16
        BNE load_nickname_loop
    JSR close_lore_file
    LDX #0
load_customization_msg_loop:
        LDA load_customization_msg,X
        BEQ load_customization_msg_done
        JSR modem_out
        INX
        BNE load_customization_msg_loop
load_customization_msg_done:
    RTS
load_customization_msg:
    .byte "\r\nCustomization loaded!\r\n",0

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
