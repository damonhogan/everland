; Send NPC lore mail on notification preference change
                                            LDA #0 ; NPC id (unused)
                                            LDX #0 ; user slot (unused)
                                            LDY #2 ; mail type: lore
                                            JSR send_npc_mail
                                            ; Send NPC hint mail on failed gift send
                                            LDA #0 ; NPC id (unused)
                                            LDX #0 ; user slot (unused)
                                            LDY #1 ; mail type: hint
                                            JSR send_npc_mail
                                            ; Send NPC hint mail on reaching message board post cap
                                            LDA #0 ; NPC id (unused)
                                            LDX #0 ; user slot (unused)
                                            LDY #1 ; mail type: hint
                                            JSR send_npc_mail
                                            ; Send NPC lore mail on group/guild invite
                                            LDA #0 ; NPC id (unused)
                                            LDX #0 ; user slot (unused)
                                            LDY #2 ; mail type: lore
                                            JSR send_npc_mail
                                            ; Send NPC lore mail on system maintenance/downtime notice
                                            LDA #0 ; NPC id (unused)
                                            LDX #0 ; user slot (unused)
                                            LDY #2 ; mail type: lore
                                            JSR send_npc_mail
                                        ; Send NPC lore mail on email/contact info change
                                        LDA #0 ; NPC id (unused)
                                        LDX #0 ; user slot (unused)
                                        LDY #2 ; mail type: lore
                                        JSR send_npc_mail
                                        ; Send NPC hint mail on failed group/guild join
                                        LDA #0 ; NPC id (unused)
                                        LDX #0 ; user slot (unused)
                                        LDY #1 ; mail type: hint
                                        JSR send_npc_mail
                                        ; Send NPC hint mail on reaching group/guild cap
                                        LDA #0 ; NPC id (unused)
                                        LDX #0 ; user slot (unused)
                                        LDY #1 ; mail type: hint
                                        JSR send_npc_mail
                                        ; Send NPC lore mail on system broadcast mention
                                        LDA #0 ; NPC id (unused)
                                        LDX #0 ; user slot (unused)
                                        LDY #2 ; mail type: lore
                                        JSR send_npc_mail
                                        ; Send NPC lore mail on moderation warning
                                        LDA #0 ; NPC id (unused)
                                        LDX #0 ; user slot (unused)
                                        LDY #2 ; mail type: lore
                                        JSR send_npc_mail
                                    ; Send NPC lore mail on avatar/profile change
                                    LDA #0 ; NPC id (unused)
                                    LDX #0 ; user slot (unused)
                                    LDY #2 ; mail type: lore
                                    JSR send_npc_mail
                                    ; Send NPC hint mail on failed gift claim
                                    LDA #0 ; NPC id (unused)
                                    LDX #0 ; user slot (unused)
                                    LDY #1 ; mail type: hint
                                    JSR send_npc_mail
                                    ; Send NPC hint mail on reaching friend cap
                                    LDA #0 ; NPC id (unused)
                                    LDX #0 ; user slot (unused)
                                    LDY #1 ; mail type: hint
                                    JSR send_npc_mail
                                    ; Send NPC lore mail on group/guild removal
                                    LDA #0 ; NPC id (unused)
                                    LDX #0 ; user slot (unused)
                                    LDY #2 ; mail type: lore
                                    JSR send_npc_mail
                                    ; Send NPC lore mail on system broadcast/announcement
                                    LDA #0 ; NPC id (unused)
                                    LDX #0 ; user slot (unused)
                                    LDY #2 ; mail type: lore
                                    JSR send_npc_mail
                                ; Send NPC lore mail on display name change
                                LDA #0 ; NPC id (unused)
                                LDX #0 ; user slot (unused)
                                LDY #2 ; mail type: lore
                                JSR send_npc_mail
                                ; Send NPC hint mail on failed save/load
                                LDA #0 ; NPC id (unused)
                                LDX #0 ; user slot (unused)
                                LDY #1 ; mail type: hint
                                JSR send_npc_mail
                                ; Send NPC hint mail on reaching daily/weekly quest cap
                                LDA #0 ; NPC id (unused)
                                LDX #0 ; user slot (unused)
                                LDY #1 ; mail type: hint
                                JSR send_npc_mail
                                ; Send NPC lore mail on friend add/remove
                                LDA #0 ; NPC id (unused)
                                LDX #0 ; user slot (unused)
                                LDY #2 ; mail type: lore
                                JSR send_npc_mail
                                ; Send NPC lore mail on receiving admin/mod message
                                LDA #0 ; NPC id (unused)
                                LDX #0 ; user slot (unused)
                                LDY #2 ; mail type: lore
                                JSR send_npc_mail
                            ; Send NPC lore mail on password change
                            LDA #0 ; NPC id (unused)
                            LDX #0 ; user slot (unused)
                            LDY #2 ; mail type: lore
                            JSR send_npc_mail
                            ; Send NPC hint mail on failed login
                            LDA #0 ; NPC id (unused)
                            LDX #0 ; user slot (unused)
                            LDY #1 ; mail type: hint
                            JSR send_npc_mail
                            ; Send NPC hint mail on reaching coin/inventory cap
                            LDA #0 ; NPC id (unused)
                            LDX #0 ; user slot (unused)
                            LDY #1 ; mail type: hint
                            JSR send_npc_mail
                            ; Send NPC lore mail on message board mention/tag
                            LDA #0 ; NPC id (unused)
                            LDX #0 ; user slot (unused)
                            LDY #2 ; mail type: lore
                            JSR send_npc_mail
                            ; Send NPC lore mail on completing a report or ban appeal
                            LDA #0 ; NPC id (unused)
                            LDX #0 ; user slot (unused)
                            LDY #2 ; mail type: lore
                            JSR send_npc_mail
                        ; Send NPC hint mail on failed marketplace trade
                        LDA #0 ; NPC id (unused)
                        LDX #0 ; user slot (unused)
                        LDY #1 ; mail type: hint
                        JSR send_npc_mail
                        ; Send NPC lore mail on admin/mod demotion
                        LDA #0 ; NPC id (unused)
                        LDX #0 ; user slot (unused)
                        LDY #2 ; mail type: lore
                        JSR send_npc_mail
                        ; Send NPC hint mail on failed seasonal event
                        LDA #0 ; NPC id (unused)
                        LDX #0 ; user slot (unused)
                        LDY #1 ; mail type: hint
                        JSR send_npc_mail
                        ; Send NPC hint mail on failed trivia/puzzle
                        LDA #0 ; NPC id (unused)
                        LDX #0 ; user slot (unused)
                        LDY #1 ; mail type: hint
                        JSR send_npc_mail
                        ; Send NPC lore mail on poll/vote rejection
                        LDA #0 ; NPC id (unused)
                        LDX #0 ; user slot (unused)
                        LDY #2 ; mail type: lore
                        JSR send_npc_mail
                    ; Send NPC lore mail on user customization change
                    LDA #0 ; NPC id (unused)
                    LDX #0 ; user slot (unused)
                    LDY #2 ; mail type: lore
                    JSR send_npc_mail
                    ; Send NPC hint mail on marketplace trade
                    LDA #0 ; NPC id (unused)
                    LDX #0 ; user slot (unused)
                    LDY #1 ; mail type: hint
                    JSR send_npc_mail
                    ; Send NPC lore mail on admin/mod promotion
                    LDA #0 ; NPC id (unused)
                    LDX #0 ; user slot (unused)
                    LDY #2 ; mail type: lore
                    JSR send_npc_mail
                    ; Send NPC hint mail on trivia/puzzle participation
                    LDA #0 ; NPC id (unused)
                    LDX #0 ; user slot (unused)
                    LDY #1 ; mail type: hint
                    JSR send_npc_mail
                    ; Send NPC lore mail on voting in a seasonal event poll
                    LDA #0 ; NPC id (unused)
                    LDX #0 ; user slot (unused)
                    LDY #2 ; mail type: lore
                    JSR send_npc_mail
                ; Send NPC hint mail on puzzle failure
                LDA #0 ; NPC id (unused)
                LDX #0 ; user slot (unused)
                LDY #1 ; mail type: hint
                JSR send_npc_mail
                ; Send NPC lore mail on ban/suspension
                LDA #0 ; NPC id (unused)
                LDX #0 ; user slot (unused)
                LDY #2 ; mail type: lore
                JSR send_npc_mail
                ; Send NPC quest mail on winning a seasonal event
                LDA #0 ; NPC id (unused)
                LDX #0 ; user slot (unused)
                LDY #0 ; mail type: quest
                JSR send_npc_mail
                ; Send NPC lore mail on completing a user poll
                LDA #0 ; NPC id (unused)
                LDX #0 ; user slot (unused)
                LDY #2 ; mail type: lore
                JSR send_npc_mail
                ; Send NPC lore mail on submitting a moderation report
                LDA #0 ; NPC id (unused)
                LDX #0 ; user slot (unused)
                LDY #2 ; mail type: lore
                JSR send_npc_mail
            ; Send NPC lore mail on login after long absence
            LDA #0 ; NPC id (unused)
            LDX #0 ; user slot (unused)
            LDY #2 ; mail type: lore
            JSR send_npc_mail
            ; Send NPC hint mail on receiving a user gift
            LDA #0 ; NPC id (unused)
            LDX #0 ; user slot (unused)
            LDY #1 ; mail type: hint
            JSR send_npc_mail
            ; Send NPC quest mail on completing a seasonal event
            LDA #0 ; NPC id (unused)
            LDX #0 ; user slot (unused)
            LDY #0 ; mail type: quest
            JSR send_npc_mail
            ; Send NPC lore mail when user is reported
            LDA #0 ; NPC id (unused)
            LDX #0 ; user slot (unused)
            LDY #2 ; mail type: lore
            JSR send_npc_mail
        ; Send NPC hint mail on quest failure
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #1 ; mail type: hint
        JSR send_npc_mail
        ; Send NPC hint mail on PvP defeat
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #1 ; mail type: hint
        JSR send_npc_mail
        ; Send NPC lore mail on completing all lore books
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #2 ; mail type: lore
        JSR send_npc_mail
        ; Send NPC quest mail on achieving a high score
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #0 ; mail type: quest
        JSR send_npc_mail
    ; Send NPC quest mail on level up
    LDA #0 ; NPC id (unused)
    LDX #0 ; user slot (unused)
    LDY #0 ; mail type: quest
    JSR send_npc_mail
    ; Send NPC hint mail on puzzle solve
    LDA #0 ; NPC id (unused)
    LDX #0 ; user slot (unused)
    LDY #1 ; mail type: hint
    JSR send_npc_mail
    ; Send NPC lore mail on secret area discovery
    LDA #0 ; NPC id (unused)
    LDX #0 ; user slot (unused)
    LDY #2 ; mail type: lore
    JSR send_npc_mail
; Everland BBS Door Main Source (Custom BBS)
; --- NPC Mail System ---
; Each user has an NPC mail inbox (8 messages max, 32 bytes each)
npc_mail_inbox: .res 256,0 ; 8 x 32 bytes
npc_mail_count: .byte 0
npc_mail_filename: .byte "MAILBOX0,S",0 ; will be updated for slot
; --- NPC Mail Save/Load ---
save_npc_mail:
    LDA #8 ; device 8
    LDX #<npc_mail_filename
    LDY #>npc_mail_filename
    JSR $FFC0 ; SETLFS
    LDA #2 ; write
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    ; Check for file open error (carry set if error)
    BCS save_npc_mail_fail
    LDY #0
save_npc_mail_loop:
        LDA npc_mail_inbox,Y
        JSR $FFD2 ; CHROUT (write byte)
        INY
        CPY #256
        BNE save_npc_mail_loop
    LDA npc_mail_count
    JSR $FFD2 ; write count as 257th byte
    JSR close_npc_mail_file
    RTS
save_npc_mail_fail:
    ; Notify user of disk error
    JSR print_mail_disk_error
    ; Optionally log error for admin
    JSR log_mail_disk_error
    RTS

load_npc_mail:
    LDA #8 ; device 8
    LDX #<npc_mail_filename
    LDY #>npc_mail_filename
    JSR $FFC0 ; SETLFS
    LDA #1 ; read
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    ; Check for file open error (carry set if error)
    BCS load_npc_mail_fail
    LDY #0
load_npc_mail_loop:
        JSR $FFD2 ; CHRIN (read byte)
        STA npc_mail_inbox,Y
        INY
        CPY #256
        BNE load_npc_mail_loop
    JSR $FFD2 ; CHRIN (read count)
    STA npc_mail_count
    JSR close_npc_mail_file
    RTS
load_npc_mail_fail:
    ; If file not found, clear inbox and notify user
    JSR print_mail_load_error
    JSR log_mail_disk_error
    LDY #0
clear_npc_mail_inbox:
        LDA #0
        STA npc_mail_inbox,Y
        INY
        CPY #256
        BNE clear_npc_mail_inbox
    LDA #0
    STA npc_mail_count
    RTS
;--------------------------------------
; Print disk error message for mailbox save
print_mail_disk_error:
    LDX #<mail_disk_error_msg
    LDY #>mail_disk_error_msg
    JSR print_string
    RTS

; Print disk error message for mailbox load
print_mail_load_error:
    LDX #<mail_load_error_msg
    LDY #>mail_load_error_msg
    JSR print_string
    RTS

; Log disk error for admin review (stub)
log_mail_disk_error:
    ; Optionally append to EVLOG or error log
    RTS

mail_disk_error_msg:
    .byte 13,13
    .text "*** DISK ERROR: COULD NOT SAVE MAILBOX! ***"
    .byte 13,0
mail_load_error_msg:
    .byte 13,13
    .text "*** DISK ERROR: COULD NOT LOAD MAILBOX! ***"
    .byte 13,0

close_npc_mail_file:
    LDA #8 ; device 8
    JSR $FFC3 ; CLOSE
    RTS
; Mailbox UI page (for paging support)
npc_mail_page: .byte 0
; --- User-to-User Gifting System ---
gift_log_filename: .byte "GIFTS,S",0
gift_buffer: .res 64,0 ; temp buffer for gift messages
; Each gift: 16 bytes (8 sender, 1 type, 2 value, 5 message)
user_gift_inbox: .res 128,0 ; 8 gifts x 16 bytes
user_gift_inbox_count: .byte 0

; Gifting menu entry
; --- Daily/Weekly Quest System ---
; Each user has a daily and weekly quest state (1 byte each: 0=pending, 1=complete, 2=claimed)
user_daily_quest: .byte 0
user_weekly_quest: .byte 0
daily_quest_type: .byte 0 ; 0-7, rotates each day
weekly_quest_type: .byte 0 ; 0-7, rotates each week
quest_types:
    .byte "Defeat 3 monsters",0
    .byte "Find a rare item",0
    .byte "Post on the message board",0
    .byte "Win a PvP match",0
    .byte "Read a lore book",0
    .byte "Gift another user",0
    .byte "Solve a puzzle",0
    .byte "Visit the library",0
    .byte 0

; --- Quest Completion Triggers (call these from main logic) ---
quest_trigger_monster:
    LDA daily_quest_type
    CMP #0
    BNE qt_monster_skip
    LDA user_daily_quest
    CMP #0
    BNE qt_monster_skip
    LDA #1
    STA user_daily_quest
qt_monster_skip:
    LDA weekly_quest_type
    CMP #0
    BNE qt_monster_done
    LDA user_weekly_quest
    CMP #0
    BNE qt_monster_done
    LDA #1
    STA user_weekly_quest
qt_monster_done:
    RTS
quest_trigger_rare:
    LDA daily_quest_type
    CMP #1
    BNE qt_rare_skip
    LDA user_daily_quest
    CMP #0
    BNE qt_rare_skip
    LDA #1
    STA user_daily_quest
qt_rare_skip:
    LDA weekly_quest_type
    CMP #1
    BNE qt_rare_done
    LDA user_weekly_quest
    CMP #0
    BNE qt_rare_done
    LDA #1
    STA user_weekly_quest
qt_rare_done:
    RTS
; (Repeat similar for other quest types...)

; --- Quest Reward Claiming ---
claim_daily_quest_reward:
    LDA user_daily_quest
    CMP #1
    BNE cdr_no_claim
    LDA #2
    STA user_daily_quest
    ; TODO: Add coins/items/XP here
    JSR quest_reward_notify
cdr_no_claim:
    RTS
claim_weekly_quest_reward:
    ; Send NPC quest mail on first quest completion
    LDA #0 ; NPC id (unused)
    LDX #0 ; user slot (unused)
    LDY #0 ; mail type: quest
    JSR send_npc_mail
    LDA user_weekly_quest
    CMP #1
        ; Send NPC hint mail when entering library
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #1 ; mail type: hint
        JSR send_npc_mail
        ; Send NPC lore mail after claiming lore badge
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #2 ; mail type: lore
        JSR send_npc_mail
    BNE cwr_no_claim
    LDA #2
    STA user_weekly_quest
    ; TODO: Add bigger reward here
    JSR quest_reward_notify
cwr_no_claim:
    RTS
quest_reward_notify:
    ; Send NPC quest mail on weekly quest completion
    LDA #0 ; NPC id (unused)
    LDX #0 ; user slot (unused)
    LDY #0 ; mail type: quest
    JSR send_npc_mail
    LDX #0
    .byte "\r\n*** QUEST REWARD CLAIMED! ***\r\n",0
        ; Send NPC hint mail on PvP win
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #1 ; mail type: hint
        JSR send_npc_mail
        ; Send NPC lore mail on first visit to a new location
        LDA #0 ; NPC id (unused)
        LDX #0 ; user slot (unused)
        LDY #2 ; mail type: lore
        JSR send_npc_mail
    RTS

; --- Quest Disk Persistence (stubs) ---
save_user_quests:
    ; TODO: Write user_daily_quest, user_weekly_quest to disk
    RTS
load_user_quests:
    ; TODO: Read user_daily_quest, user_weekly_quest from disk
    RTS

; Menu entry for daily/weekly quests
; --- Achievements & Badges System ---
; Each user has a badge bitmask array (4 bytes = 32 badges)
user_badges: .res 4,0 ; 32 badge slots per user
badge_names:
    .byte "First Quest",0
    .byte "Rare Find",0
    .byte "Message Board Post",0
    .byte "High Score",0
    .byte "Puzzle Master",0
    .byte "Gift Giver",0
    .byte "Event Winner",0
    .byte "Lore Seeker",0
    .byte "Friend Maker",0
    .byte "Seasonal Hero",0
    .byte 0
badge_descs:
    .byte "Complete your first quest.",0
    .byte "Find a rare item.",0
    .byte "Post on the message board.",0
    .byte "Achieve a high score.",0
    .byte "Solve a puzzle.",0
    .byte "Send a gift to another user.",0
    .byte "Win a special event.",0
    .byte "Read all lore books.",0
    .byte "Add a friend.",0
    .byte "Participate in a seasonal event.",0
    .byte 0

; Award a badge (A = badge index)
award_badge:
    TAX
    LDA user_badges,X
    CMP #1
    BEQ print_type_coin
    CMP #2
    BEQ print_type_item
    CMP #3
    BEQ print_type_msg
    .byte "?",0
    RTS
print_type_coin:
    .byte "Coin",0
    RTS
print_type_item:
    .byte "Item",0
    RTS
print_type_msg:
    .byte "Msg",0
    RTS
    RTS

; Check if user has badge (A = badge index, Z=1 if yes)
has_badge:
    TAX
    LDA user_badges,X
    LSR A
    AND #$01
    RTS

; Notify user of badge unlock (X = badge index)
badge_unlocked_notify:
    LDX #0
    .byte "\r\n*** BADGE UNLOCKED! ***\r\n",0
    LDA badge_names,X
    JSR modem_out
    LDA badge_descs,X
    JSR modem_out
    RTS

; Save/load badges to disk (stubs)
save_user_badges:
    ; TODO: Write user_badges to disk
    RTS
load_user_badges:
    ; TODO: Read user_badges from disk
    RTS

; Display badges in profile (shows only earned)
show_user_badges:
    LDX #0
show_badge_loop:
        LDA user_badges,X
        BEQ next_badge
        LDA badge_names,X
        JSR modem_out
        LDA badge_descs,X
        JSR modem_out
next_badge:
        INX
        CPX #10 ; number of badges
        BNE show_badge_loop
    RTS
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
user_email: .res 40,0 ; PETSCII email address (future use)
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
    ; Update mailbox filename for user slot (slot 0-7)
    LDA user_slot
    CLC
    ADC #'0'
    STA npc_mail_filename+7
    JSR load_npc_mail
    JSR notify_gift_inbox
    JSR notify_npc_mail_on_login
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
    JSR save_npc_mail
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
    .byte "\r\nEVERLAND MAIN MENU:\r\n(Where memory and magic entwine)\r\n1. Play Everland\r\n2. Inventory\r\n3. High Scores\r\n4. Message Board\r\n5. Async PvP\r\n6. Save Game\r\n7. Load Game\r\n8. Portal Travel\r\n9. Quit\r\nL. Library\r\nU. User Customization\r\nQ. Daily/Weekly Quests\r\nG. Gift to Another User\r\nV. View Received Gifts\r\nM. NPC Mailbox\r\nT. Debug: Test Gift\r\nD. Debug: Unlock All Badges\r\n\r\nLore: The portal shimmers with fractured memories. Quests shape the fate of Everland.\r\n> ",0

get_menu_input:
            CMP #'M'
            BEQ npc_mailbox_menu
        ; --- NPC Mailbox UI ---
        npc_mailbox_menu:
            LDA npc_mail_count
            BEQ no_npc_mail
            LDA npc_mail_page
            JSR print_npc_mail_list_paged
            ; Print NPC mail list for current page (5 per page)
            print_npc_mail_list_paged:
                ; A = page number
                STA tmp_page
                LDA tmp_page
                ASL A
                ASL A
                ADC tmp_page ; A = page*5
                TAX
                STX tmp_start
                LDA npc_mail_count
                SEC
                SBC tmp_start
                CMP #5
                BCC @lastpage
                LDA #5
            @lastpage:
                STA tmp_count
                JSR print_npc_mail_list_header
                LDX tmp_start
                LDY #0
            @loop:
                    CPY tmp_count
                    BCS @done
                    TXA
                    JSR print_npc_mail_entry
                    INX
                    INY
                    JMP @loop
            @done:
                RTS

            print_npc_mail_list_header:
                .byte "\r\n#  SENDER     SUBJECT    STATUS\r\n",0
                RTS
            .byte "\r\nEnter mail # to read, D to delete, A to mark all as read, X to delete all, N for next page, P for previous page, 0 to return.\r\n(Example: 1 to read, D then 2 to delete mail #2)\r\n> ",0
            JSR modem_in
            CMP #'0'
            BEQ main_loop
            CMP #'D'
            BEQ npc_mail_delete_prompt
            CMP #'A'
            BEQ npc_mail_mark_all_read
            CMP #'X'
            BEQ npc_mail_delete_all_prompt
                    npc_mail_delete_all_prompt:
                        .byte "\r\nAre you sure you want to delete ALL mail? (Y/N): ",0
                        JSR modem_in
                        CMP #'Y'
                        BNE npc_mailbox_menu
                        JSR npc_mail_delete_all
                        .byte "\r\nAll mail deleted.\r\n",0
                        JMP npc_mailbox_menu

                    ; Delete all NPC mail
                    npc_mail_delete_all:
                        LDX #0
                    npc_mail_delete_all_loop:
                            CPX npc_mail_count
                            BCS npc_mail_delete_all_done
                            LDA #0
                            STA npc_mail_inbox,X
                            INX
                            BNE npc_mail_delete_all_loop
                    npc_mail_delete_all_done:
                        LDA #0
                        STA npc_mail_count
                        RTS
            SEC
            SBC #'0'
            CMP npc_mail_count
            BCS npc_mail_invalid
            JSR read_npc_mail_by_index
            JMP npc_mailbox_menu
                npc_mail_mark_all_read:
                    LDX #0
                npc_mail_mark_all_read_loop:
                        CPX npc_mail_count
                        BCS npc_mail_mark_all_read_done
                        ; Set read bit (bit 0 of byte 31)
                        LDA #31
                        CLC
                        ADC #0
                        TXA
                        ASL A
                        ASL A
                        ASL A
                        ASL A
                        ASL A
                        CLC
                        ADC #31
                        TAX
                        LDA npc_mail_inbox,X
                        ORA #$01
                        STA npc_mail_inbox,X
                        LDX #0
                            .byte "\r\nEnter mail # to read, D to delete, A to mark all as read, X to delete all, N for next page, P for previous page, 0 to return.\r\n(Example: 1 to read, D then 2 to delete mail #2)\r\n> ",0
                        CPX npc_mail_count
                        BCC npc_mail_mark_all_read_loop
                npc_mail_mark_all_read_done:
                    .byte "\r\nAll mail marked as read.\r\n",0
                    JMP npc_mailbox_menu
        npc_mail_delete_prompt:
            .byte "\r\nEnter mail # to delete (or 0 to cancel): ",0
            JSR modem_in
            CMP #'0'
                            CMP #'N'
                            BEQ npc_mail_next_page
                            CMP #'P'
                            BEQ npc_mail_prev_page
            BEQ npc_mailbox_menu
            SEC
            SBC #'0'
            CMP npc_mail_count
            BCS npc_mail_invalid
            .byte "\r\nAre you sure you want to delete this mail? (Y/N): ",0

                        npc_mail_next_page:
                            INC npc_mail_page
                            JMP npc_mailbox_menu

                        npc_mail_prev_page:
                            LDA npc_mail_page
                            BEQ npc_mailbox_menu
                            DEC npc_mail_page
                            JMP npc_mailbox_menu
            JSR modem_in
            CMP #'Y'
            BNE npc_mailbox_menu
            JSR delete_npc_mail_by_index
            .byte "\r\nMail deleted.\r\n",0
            JMP npc_mailbox_menu
        npc_mail_invalid:
            .byte "\r\nInvalid selection. Please enter a valid mail number.\r\n",0
            JMP npc_mailbox_menu
        no_npc_mail:
            .byte "\r\nNo NPC mail.\r\n",0
            JMP main_loop

        ; Print NPC mail list with read/unread status
        print_npc_mail_list:
                .byte "\r\n#  SENDER     SUBJECT    STATUS\r\n",0
                LDX #0
            print_npc_mail_list_loop:
                TXA
                CLC
                ADC #'1'
                JSR modem_out
                ; Show ! for unread mail
                LDA npc_mail_inbox,X
                AND #$01
                BNE print_npc_mail_no_excl
                .byte "!",0
                JMP print_npc_mail_after_excl
            print_npc_mail_no_excl:
                .byte " ",0
            print_npc_mail_after_excl:
                .byte ". ",0
                ; Print sender (8 bytes, padded)
                LDY #0
            print_npc_sender_list_fmt:
                    LDA npc_mail_inbox,X
                    JSR modem_out
                    INX
                    INY
                    CPY #8
                    BNE print_npc_sender_list_fmt
                .byte " ",0
                ; Print subject (8 bytes, padded)
                LDY #0
            print_npc_subject_list_fmt:
                    LDA npc_mail_inbox,X
                    JSR modem_out
                    INX
                    INY
                    CPY #8
                    BNE print_npc_subject_list_fmt
                .byte " ",0
                ; Print read/unread status (bit 0 of byte 31)
                LDA npc_mail_inbox,X
                AND #$01
                BEQ print_npc_unread_fmt
                .byte "Read",0
                JMP print_npc_status_done_fmt
            print_npc_unread_fmt:
                .byte "Unread",0
            print_npc_status_done_fmt:
                .byte "\r\n",0
                INX
                CPX npc_mail_count
                BNE print_npc_mail_list_loop
                RTS

        ; Read NPC mail by index (A = index)
        read_npc_mail_by_index:
            ; Print sender, subject, message
            ASL A
            ASL A
            ASL A
            ASL A
            ASL A
            TAX
            .byte "\r\nFrom: ",0
            LDY #0
        read_npc_sender:
                LDA npc_mail_inbox,X
                JSR modem_out
                INX
                INY
                CPY #8
                BNE read_npc_sender
            .byte "\r\nSubject: ",0
            LDY #0
        read_npc_subject:
                LDA npc_mail_inbox,X
                JSR modem_out
                INX
                INY
                CPY #8
                BNE read_npc_subject
            .byte "\r\nMessage:\r\n",0
            LDY #0
        read_npc_msg:
                LDA npc_mail_inbox,X
                JSR modem_out
                INX
                INY
                CPY #16
                BNE read_npc_msg
            .byte "\r\n(Press any key to return to mailbox)\r\n",0
            JSR modem_in
            ; Mark as read (set bit 0 of byte 31)
            DEX
            LDA npc_mail_inbox,X
            ORA #$01
            STA npc_mail_inbox,X
            RTS

        ; Delete NPC mail by index (A = index)
        delete_npc_mail_by_index:
            ASL A
            ASL A
            ASL A
            ASL A
            ASL A
            TAX
            ; Shift later mails up
            LDX A
            INX
        delete_npc_mail_shift:
                CPX npc_mail_count
                BCS delete_npc_mail_done
                LDA npc_mail_inbox,X
                STA npc_mail_inbox-32,X
                INX
                BNE delete_npc_mail_shift
        delete_npc_mail_done:
            DEC npc_mail_count
            RTS

        ; Print NPC mail entry at X (32 bytes per mail)
        print_npc_mail_entry:
            TXA
            ASL A
            ASL A
            ASL A
            ASL A
            ASL A
            TAX
            ; Print sender (8 bytes)
            LDY #0
        print_npc_sender:
                LDA npc_mail_inbox,X
                JSR modem_out
                INX
                INY
                CPY #8
                BNE print_npc_sender
            .byte ": ",0
            ; Print subject (8 bytes)
            LDY #0
        print_npc_subject:
                LDA npc_mail_inbox,X
                JSR modem_out
                INX
                INY
                CPY #8
                BNE print_npc_subject
            .byte " - ",0
            ; Print message (16 bytes)
            LDY #0
        print_npc_msg:
                LDA npc_mail_inbox,X
                JSR modem_out
                INX
                INY
                CPY #16
                BNE print_npc_msg
            .byte "\r\n",0
            RTS

        ; --- NPC Mail Send Stub ---
        send_npc_mail:
            ; A = NPC id, X = user slot, Y = mail type
            ; Mail type: 0=quest, 1=hint, 2=lore
            LDY npc_mail_count
            CPY #8
            BCS send_npc_mail_full
            TYA
            ASL A
            ASL A
            ADC TYA ; A = Y*5 (5*32=160 max, but only 8*32=256)
            ASL A
            ASL A
            TAX
            ; Compose mail: 8 sender, 8 subject, 16 message, 1 status (unread)
            ; For demo, use fixed sender/subject/message per type
            LDA #"N"
            STA npc_mail_inbox,X
            LDA #"P"
            STA npc_mail_inbox+1,X
            LDA #"C"
            STA npc_mail_inbox+2,X
            LDA #" "
            STA npc_mail_inbox+3,X
            LDA #"S"
            STA npc_mail_inbox+4,X
            LDA #"Y"
            STA npc_mail_inbox+5,X
            LDA #"S"
            STA npc_mail_inbox+6,X
            LDA #"!"
            STA npc_mail_inbox+7,X
            ; Subject
            LDA Y
            CMP #0
            BNE @not_quest
            LDA #"Quest"
            STA npc_mail_inbox+8,X
            LDA #" "
            STA npc_mail_inbox+9,X
            LDA #"Hook"
            STA npc_mail_inbox+10,X
            LDA #0
            STA npc_mail_inbox+11,X
            LDA #0
            STA npc_mail_inbox+12,X
            LDA #0
            STA npc_mail_inbox+13,X
            LDA #0
            STA npc_mail_inbox+14,X
            LDA #0
            STA npc_mail_inbox+15,X
            ; Message
            LDA #"A quest awaits you!"
            STA npc_mail_inbox+16,X
            LDA #0
            STA npc_mail_inbox+31,X
            JMP @done
@not_quest:
            CPY #1
            BNE @not_hint
            LDA #"Hint"
            STA npc_mail_inbox+8,X
            LDA #" "
            STA npc_mail_inbox+9,X
            LDA #"Time"
            STA npc_mail_inbox+10,X
            LDA #0
            STA npc_mail_inbox+11,X
            LDA #0
            STA npc_mail_inbox+12,X
            LDA #0
            STA npc_mail_inbox+13,X
            LDA #0
            STA npc_mail_inbox+14,X
            LDA #0
            STA npc_mail_inbox+15,X
            LDA #"Try the library for secrets."
            STA npc_mail_inbox+16,X
            LDA #0
            STA npc_mail_inbox+31,X
            JMP @done
@not_hint:
            ; Lore mail
            LDA #"Lore"
            STA npc_mail_inbox+8,X
            LDA #" "
            STA npc_mail_inbox+9,X
            LDA #"Drop"
            STA npc_mail_inbox+10,X
            LDA #0
            STA npc_mail_inbox+11,X
            LDA #0
            STA npc_mail_inbox+12,X
            LDA #0
            STA npc_mail_inbox+13,X
            LDA #0
            STA npc_mail_inbox+14,X
            LDA #0
            STA npc_mail_inbox+15,X
            LDA #"Legends whisper in the dark."
            STA npc_mail_inbox+16,X
            LDA #0
            STA npc_mail_inbox+31,X
@done:
            INC npc_mail_count
            RTS
        send_npc_mail_full:
            ; Inbox full, do nothing (could notify user)
            RTS
        CMP #'V'
        BEQ view_gift_inbox
    ; --- Gift Inbox: View and Claim Gifts ---
    view_gift_inbox:
        CMP user_gift_inbox_count
        BCS invalid_gift_claim
        JSR claim_gift_by_index
        LDA user_gift_inbox_count
        BEQ all_gifts_claimed
        JMP view_gift_inbox
    invalid_gift_claim:
        .byte "\r\nInvalid selection. Please enter a valid gift number.\r\n",0
        JMP view_gift_inbox
    all_gifts_claimed:
        .byte "\r\nAll gifts claimed!\r\n",0
        JMP main_loop
    no_gifts:
        .byte "\r\nNo gifts or messages.\r\n",0
        JMP main_loop
        JSR modem_in
        SEC
        SBC #'0'
        CMP #0
        BEQ main_loop
        CMP user_gift_inbox_count
        BCS main_loop
        JSR claim_gift_by_index
        JMP view_gift_inbox
    no_gifts:
        .byte "\r\nNo gifts or messages.\r\n",0
        JMP main_loop

    ; Print gift entry at X (16 bytes per gift)
    print_gift_entry:
        TXA
        ASL A
        ASL A
        ASL A
        ASL A
        TAX
        ; Print gift number (1-based)
        TXA
        LSR A
        LSR A
        LSR A
        LSR A
        CLC
        ADC #'1'
        JSR modem_out
        .byte ". From: ",0
        ; Print sender (8 bytes)
        LDY #0
    print_gift_sender:
            LDA user_gift_inbox,X
            JSR modem_out
            INX
            INY
            CPY #8
            BNE print_gift_sender
        .byte " | Type: ",0
        LDA user_gift_inbox,X
        JSR print_gift_type
        INX
        .byte " | Value: ",0
        LDA user_gift_inbox,X
        JSR print_gift_value
        INX
        LDA user_gift_inbox,X
        JSR print_gift_value
        INX
        .byte " | Msg: ",0
        LDY #0
    print_gift_msg:
            LDA user_gift_inbox,X
            JSR modem_out
            INX
            INY
            CPY #5
            BNE print_gift_msg
        .byte "\r\n",0
        RTS

    ; Claim gift by index (A = index)
    claim_gift_by_index:
        ; Add coins/items/messages to user, remove from inbox
        TXA
        ASL A
        ASL A
        ASL A
        ASL A
        TAX
        LDA user_gift_inbox,X
        ; X now points to start of gift
        ; Y = type (X+8)
        LDY X
        INY #8
        LDA user_gift_inbox,Y
        CMP #1
        BNE not_coin_gift
        ; Coin gift: add value to user balance (stub)
        ; TODO: Add value to user coins
        JMP remove_gift_from_inbox
    not_coin_gift:
        CMP #2
        BNE not_item_gift
        ; Item gift: add item to inventory (stub)
        ; TODO: Add item to user inventory
        JMP remove_gift_from_inbox
    not_item_gift:
        CMP #3
        BNE not_msg_gift
        ; Message gift: show message (stub)
        ; TODO: Show message to user
        JMP remove_gift_from_inbox
    not_msg_gift:
        JMP remove_gift_from_inbox
    remove_gift_from_inbox:
        ; Shift later gifts up
        LDX A
        INX
claim_gift_shift:
            CPX user_gift_inbox_count
            BCS claim_gift_done
            LDA user_gift_inbox,X
            STA user_gift_inbox-16,X
            INX
            BNE claim_gift_shift
    claim_gift_done:
        DEC user_gift_inbox_count
        RTS
    ; Get a key from modem
    JSR modem_in
    CMP #'U'
    BEQ user_customization_menu
    CMP #'G'
    BEQ gifting_menu
    CMP #'T'
    BEQ gifting_test_menu
    ; --- Gifting Menu ---
    gifting_menu:
        LDX #0
        .byte "\r\nSEND A GIFT\r\nEnter recipient username: ",0
        JSR get_input_to_buffer ; stores to gift_buffer
        JSR validate_recipient
        BCC gifting_menu_fail
        .byte "\r\nGift type: 1=Coins 2=Item 3=Message\r\n> ",0
        JSR modem_in
        CMP #'1'
        BEQ gift_coins
        CMP #'2'
        BEQ gift_item
        CMP #'3'
        BEQ gift_message
        JMP main_loop
    gifting_menu_fail:
        .byte "\r\nRecipient not found.\r\n",0
        JMP main_loop
    ; --- Recipient Validation (stub, sets carry if found) ---
    validate_recipient:
        ; Search user_list for PETSCII match in gift_buffer
        LDY #0
    validate_recipient_loop:
            LDA user_list,Y
            BEQ validate_recipient_notfound
            LDX #0
    validate_recipient_cmp:
                LDA user_list,Y
                CMP gift_buffer,X
                BNE validate_recipient_next
                INX
                INY
                LDA gift_buffer,X
                BEQ validate_recipient_found
                JMP validate_recipient_cmp
    validate_recipient_next:
            INY
            CPY #128
            BNE validate_recipient_loop
    validate_recipient_notfound:
        CLC
        RTS
    validate_recipient_found:
        SEC
        RTS
    gift_coins:
        .byte "\r\nAmount to send: ",0
        JSR get_input_to_buffer ; stores amount
        JSR check_self_gift
        BCS gift_coins_self
        JSR check_sufficient_funds
        BCC gift_coins_insufficient
        JSR deduct_coins_from_sender
        JSR add_coins_to_recipient
        JSR log_gift
        .byte "\r\nCoins sent!\r\n",0
        JMP main_loop
    gift_coins_insufficient:
        .byte "\r\nInsufficient funds.\r\n",0
        JMP main_loop
    gift_coins_self:
        .byte "\r\nCannot gift to yourself.\r\n",0
        JMP main_loop
    ; --- Self-gift check (sets carry if self) ---
    check_self_gift:
        ; Compare gift_buffer to user_name
        LDX #0
    check_self_gift_loop:
            LDA gift_buffer,X
            CMP user_name,X
            BNE check_self_gift_notself
            INX
            LDA gift_buffer,X
            BEQ check_self_gift_self
            JMP check_self_gift_loop
    check_self_gift_notself:
        CLC
        RTS
    check_self_gift_self:
        SEC
        RTS

    ; --- Sufficient funds check (sets carry if enough) ---
    check_sufficient_funds:
        ; TODO: Compare amount in gift_buffer to sender's coin balance
        SEC ; always succeed for now
        RTS
    ; --- Coin Transfer (stubs) ---
    deduct_coins_from_sender:
        ; TODO: Subtract from sender's balance
        RTS
    add_coins_to_recipient:
        ; TODO: Add to recipient's balance
        RTS
    gift_item:
        .byte "\r\nItem ID to send: ",0
        JSR get_input_to_buffer ; stores item id
        JSR remove_item_from_sender
        JSR add_item_to_recipient
        JSR log_gift
        .byte "\r\nItem sent!\r\n",0
        JMP main_loop
    ; --- Item Transfer (stubs) ---
    remove_item_from_sender:
        ; TODO: Remove item from sender inventory
        RTS
    add_item_to_recipient:
        ; TODO: Add item to recipient inventory
        RTS
    ; --- Debug/Test: Send test gift to self ---
    gifting_test_menu:
        .byte "\r\nDEBUG: Sending 1 coin to self...\r\n",0
        ; Simulate coin gift to self
        JSR deduct_coins_from_sender
        JSR add_coins_to_recipient
        JSR log_gift
        .byte "\r\nTest gift complete.\r\n",0
        JMP main_loop
    gift_message:
        .byte "\r\nMessage: ",0
        JSR get_input_to_buffer ; stores message
        ; TODO: Store message for recipient, log
        JSR log_gift
        .byte "\r\nMessage sent!\r\n",0
        JMP main_loop

    ; --- Gift Logging & Moderation (stubs) ---
    log_gift:
        ; Write sender, recipient, type, amount/item/message, and timestamp to disk for moderation
        ; TODO: Implement actual disk write
        ; Add to recipient's inbox if space
        LDA user_gift_inbox_count
        CMP #8
        BCS log_gift_full
        LDX user_gift_inbox_count
        TXA
        ASL A
        ASL A
        ASL A
        ASL A
        TAX
        ; Store sender (first 8 bytes)
        LDY #0
log_gift_sender:
            LDA user_name,Y
            STA user_gift_inbox,X
            INX
            INY
            CPY #8
            BNE log_gift_sender
        ; Store type (1 byte)
        LDA gift_buffer
        STA user_gift_inbox,X
        INX
        ; Store value (2 bytes, stub)
        LDA #0
        STA user_gift_inbox,X
        INX
        STA user_gift_inbox,X
        INX
        ; Store message (5 bytes, stub)
        LDY #0
log_gift_msg:
            LDA gift_buffer,Y
            STA user_gift_inbox,X
            INX
            INY
            CPY #5
            BNE log_gift_msg
        INC user_gift_inbox_count
        .byte "\r\nGift delivered!\r\n",0
        RTS
    log_gift_full:
        .byte "\r\nRecipient's inbox is full. Gift not delivered.\r\n",0
        RTS
; --- Notify user of new gifts on login ---
notify_gift_inbox:
    LDA user_gift_inbox_count
    BEQ notify_gift_none
    .byte "\r\nYou have received gifts or messages! (V to view)\r\n",0
notify_gift_none:
    RTS

    ; --- Disk I/O for gifting (stubs) ---
    save_gifts:
        ; Write user_gift_inbox and user_gift_inbox_count to disk (stub)
        ; TODO: Implement actual disk write
        RTS
    load_gifts:
        ; Load user_gift_inbox and user_gift_inbox_count from disk (stub)
        ; TODO: Implement actual disk read
        RTS

    ; --- Input helper (stub) ---
    get_input_to_buffer:
        ; TODO: Read user input into gift_buffer
        RTS
    CMP #'Q'
    BEQ daily_weekly_quest_menu
    ; --- Daily/Weekly Quest Menu ---
    daily_weekly_quest_menu:
        LDX daily_quest_type
        LDA quest_types,X
        JSR modem_out
        LDA user_daily_quest
        CMP #0
        BEQ dq_pending
        CMP #1
        BEQ dq_complete
        CMP #2
        BEQ dq_claimed
    dq_pending:
        .byte "\r\nStatus: Pending\r\n",0
        JMP dq_menu_end
    dq_complete:
        .byte "\r\nStatus: Complete! Press C to claim reward.\r\n",0
        ; Wait for 'C' key to claim
        JSR modem_in
        CMP #'C'
        BNE dq_menu_end
        JSR claim_daily_quest_reward
        JMP dq_menu_end
    dq_claimed:
        .byte "\r\nStatus: Already claimed.\r\n",0
        JMP dq_menu_end
    dq_menu_end:
        LDX weekly_quest_type
        LDA quest_types,X
        JSR modem_out
        LDA user_weekly_quest
        CMP #0
        BEQ wq_pending
        CMP #1
        BEQ wq_complete
        CMP #2
        BEQ wq_claimed
    wq_pending:
        .byte "\r\nStatus: Pending\r\n",0
        JMP wq_menu_end
    wq_complete:
        .byte "\r\nStatus: Complete! Press C to claim reward.\r\n",0
        ; Wait for 'C' key to claim
        JSR modem_in
        CMP #'C'
        BNE wq_menu_end
        JSR claim_weekly_quest_reward
        JMP wq_menu_end
    wq_claimed:
        .byte "\r\nStatus: Already claimed.\r\n",0
        JMP wq_menu_end
    wq_menu_end:
        RTS
    CMP #'D'
    BEQ debug_unlock_all_badges
    ; Debug: Instantly unlock all badges for current user
    debug_unlock_all_badges:
        LDX #0
    debug_unlock_loop:
            LDA #$FF
            STA user_badges,X
            INX
            CPX #4
            BNE debug_unlock_loop
        JSR debug_print_all_badges
        JMP main_loop

    ; Print all badge states for verification
    debug_print_all_badges:
        LDX #0
    debug_print_badge_loop:
            LDA badge_names,X
            BEQ debug_print_badge_done
            JSR modem_out
            LDA user_badges,X
            AND #$01
            BEQ debug_print_next
            LDA #'*'
            JSR modem_out
    debug_print_next:
            INX
            BNE debug_print_badge_loop
    debug_print_badge_done:
        RTS
    RTS
; --- User Customization ---
user_avatar: .byte 0
user_nickname: .res 16,0 ; PETSCII nickname
user_color: .byte 0
user_settings: .byte 0

user_customization_menu:

    ; Display current selections
    JSR show_user_badges
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
    ; Show email address
    LDX #0
    LDA #13
    JSR modem_out
    LDX #0
show_email_loop:
        LDA user_email,X
        BEQ show_email_done
        JSR modem_out
        INX
        CPX #40
        BNE show_email_loop
show_email_done:
    LDA #13
    JSR modem_out
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
    BEQ customization_help_call
    CMP #'E'
    BEQ edit_email
    CMP #'0'
    BEQ main_loop
    JMP get_user_customization_input_loop
    ; Edit email address from customization menu
    edit_email:
        LDX #0
    edit_email_prompt_loop:
            LDA edit_email_prompt_msg,X
            BEQ edit_email_prompt_done
            JSR modem_out
            INX
            BNE edit_email_prompt_loop
    edit_email_prompt_done:
        LDX #0
    edit_email_input_loop:
            JSR modem_in
            CMP #13 ; Return
            BEQ edit_email_input_done
            STA user_email,X
            INX
            CPX #40
            BNE edit_email_input_loop
            JMP edit_email_input_loop
    edit_email_input_done:
        ; Validate email address (must contain '@' and '.')
        LDY #0
        LDA #0
        STA tmp_at
        STA tmp_dot
    edit_validate_email_loop:
            LDA user_email,Y
            BEQ edit_validate_email_end
            CMP #'@'
            BNE check_dot
            LDA #1
            STA tmp_at
    check_dot:
            LDA user_email,Y
            CMP #'.'
            BNE next_email_char
            LDA #1
            STA tmp_dot
    next_email_char:
            INY
            CPY #40
            BNE edit_validate_email_loop
    edit_validate_email_end:
        LDA tmp_at
        BEQ edit_invalid_email
        LDA tmp_dot
        BEQ edit_invalid_email
        JSR save_user_customization
        JMP user_customization_menu
    edit_invalid_email:
        LDX #0
    edit_invalid_email_msg_loop:
            LDA invalid_email_msg,X
            BEQ edit_invalid_email_msg_done
            JSR modem_out
            INX
            BNE edit_invalid_email_msg_loop
    edit_invalid_email_msg_done:
        JMP edit_email_prompt_loop
    edit_email_prompt_msg:
        .byte "\r\nEnter new email address (max 40 chars, press RETURN): ",0
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
    LDY #0
save_email_loop:
        LDA user_email,Y
        JSR $FFD2
        INY
        CPY #40
        BNE save_email_loop
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
    LDY #0
load_email_loop:
        JSR $FFD2
        STA user_email,Y
        INY
        CPY #40
        BNE load_email_loop
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
    ; Prompt for email address after username
    LDX #0
prompt_email_msg_loop:
        LDA prompt_email_msg,X
        BEQ prompt_email_msg_done
        JSR modem_out
        INX
        BNE prompt_email_msg_loop
prompt_email_msg_done:
    LDX #0
prompt_email_input_loop:
        JSR modem_in
        CMP #13 ; Return
        BEQ prompt_email_input_done
        STA user_email,X
        INX
        CPX #40
        BNE prompt_email_input_loop
        JMP prompt_email_input_loop
prompt_email_input_done:
    ; Validate email address (must contain '@' and '.')
    LDY #0
    LDA #0
    STA tmp_at
    STA tmp_dot
validate_email_loop:
        LDA user_email,Y
        BEQ validate_email_end
        CMP #'@'
        BNE check_dot
        LDA #1
        STA tmp_at
check_dot:
        LDA user_email,Y
        CMP #'.'
        BNE next_email_char
        LDA #1
        STA tmp_dot
next_email_char:
        INY
        CPY #40
        BNE validate_email_loop
validate_email_end:
    LDA tmp_at
    BEQ invalid_email
    LDA tmp_dot
    BEQ invalid_email
    RTS
invalid_email:
    LDX #0
    invalid_email_msg_loop:
        LDA invalid_email_msg,X
        BEQ invalid_email_msg_done
        JSR modem_out
        INX
        BNE invalid_email_msg_loop
    invalid_email_msg_done:
        JMP prompt_email_msg_loop
tmp_at: .byte 0
tmp_dot: .byte 0
invalid_email_msg:
    .byte "\r\nInvalid email address. Please enter a valid email (must contain '@' and '.'): ",0
prompt_email_msg:
    .byte "\r\nEnter your real-world email address (max 40 chars, press RETURN): ",0
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
    CMP #'E'
    BEQ admin_export_email_list
    CMP #'Q'
    BEQ admin_logout
    JMP admin_menu
admin_menu_msg:
    .byte "\r\nADMIN MENU:\r\n(U)ser list, (B)an user, (R)estore user, (M)essage review, (E)xport email list, (Q)uit\r\n> ",0

; Export all users' display names and emails to a CSV file
admin_export_email_list:
    JSR open_email_csv_file_write
    ; Write CSV header: "Display Name,Email\r\n"
    LDX #0
write_email_csv_header:
        LDA email_csv_header,X
        BEQ write_email_csv_header_done
        JSR $FFD2
        INX
        BNE write_email_csv_header
write_email_csv_header_done:
    LDY #0 ; user slot
export_email_user_loop:
        LDX #0
        ; Write display name (user_list, 16 bytes, stop at 0)
write_email_name_loop:
            LDA user_list,Y
            BEQ write_email_name_done
            JSR $FFD2
            INY
            CPY #16
            BNE write_email_name_loop
write_email_name_done:
        ; Write comma
        LDA #','
        JSR $FFD2
        ; Write email (user_email, 40 bytes, stop at 0)
        LDX #0
write_email_addr_loop:
            LDA user_email,X
            BEQ write_email_addr_done
            JSR $FFD2
            INX
            CPX #40
            BNE write_email_addr_loop
write_email_addr_done:
        ; Write CRLF
        LDA #13
        JSR $FFD2
        LDA #10
        JSR $FFD2
        INY
        CPY #8 ; max 8 users
        BNE export_email_user_loop
    JSR close_email_csv_file
    LDX #0
export_email_done_msg_loop:
        LDA export_email_done_msg,X
        BEQ export_email_done_msg_done
        JSR modem_out
        INX
        BNE export_email_done_msg_loop
export_email_done_msg_done:
    JMP admin_menu

email_csv_header:
    .byte "Display Name,Email\r\n",0
export_email_done_msg:
    .byte "\r\nEmail list exported to EMAILS.CSV\r\n",0

open_email_csv_file_write:
    LDA #8 ; device 8
    LDX #<email_csv_filename
    LDY #>email_csv_filename
    JSR $FFC0 ; SETLFS
    LDA #2 ; write
    JSR $FFC3 ; SETNAM
    JSR $FFC6 ; OPEN
    RTS
close_email_csv_file:
    LDA #8 ; device 8
    JSR $FFC3 ; CLOSE
    RTS
email_csv_filename:
    .byte "EMAILS.CSV,S",0

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
