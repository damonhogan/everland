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
user_room_rating: .byte 3         // Current room rating (1-5, default 3)
user_trinket_display: .fill 8, 0  // 8 trinket display slots
user_badge_display: .fill 4, 0    // 4 badge showcase slots

// --- Messaging System Data ---
user_inbox: .fill 320, 0          // 5 messages x 64 bytes (16 from + 48 content)
user_inbox_count: .byte 0         // Number of messages
user_outbox_temp: .fill 64, 0     // Temp buffer for composing message

// --- Sample Rooms for Visiting ---
sample_rooms_count: .byte 5
sample_room_names:
    .text "Royal Chamber   "      // 16 chars each
    .text "Mystic Grove    "
    .text "Adventure Den   "
    .text "Peaceful Meadow "
    .text "Dark Dungeon    "
sample_room_owners:
    .text "King Arthur     "
    .text "Elara Sage      "
    .text "Bold Explorer   "
    .text "Tranquil Soul   "
    .text "Shadow Lord     "
sample_room_ratings: .byte 4, 5, 3, 5, 2  // 1-5 rating for each

// --- Player Profile Data ---
player_bio: .fill 64, 0              // Player biography (64 chars)
player_title: .fill 16, 0            // Custom title (16 chars)
player_games_played: .byte 0         // Games started
player_games_won: .byte 0            // Games completed
player_gold_earned: .word 0          // Total gold earned
player_monsters_slain: .word 0       // Monsters defeated
player_quests_done: .byte 0          // Quests completed
player_friends_made: .byte 0         // Friends added
player_rooms_visited: .byte 0        // Rooms visited
player_messages_sent: .byte 0        // Messages sent
// Achievements (bit flags)
player_achievements: .byte 0         // 8 achievement bits
//   Bit 0: First Login
//   Bit 1: Reached Level 5
visit_craft_menu:
    ; Print crafting header
    ldx #0
craft_menu_print:
    lda craft_menu_msg,X
    beq craft_menu_print_done
    jsr modem_out
    inx
    bne craft_menu_print
craft_menu_print_done:
    jsr modem_in
    ; List recipes: iterate recipes_table and print index + output item name
    lda #<recipes_table
    sta recipes_ptr_lo
    lda #>recipes_table
    sta recipes_ptr_hi
    ldx #0
    ldy #0
list_recipes_loop:
    ; compare X (entry counter) to recipe_count (assembler constant)
    ; use X as counter — if X >= recipe_count then done
    txa
    cmp #recipe_count
    bcs list_recipes_done
    ; print index (X may be 0..99)
    txa
    cmp #10
    bcc list_print_single_digit
    cmp #20
    bcc list_print_ten
    cmp #30
    bcc list_print_twenty
    ; 30-39
    lda #'3'
    jsr modem_out
    txa
    sec
    sbc #30
    clc
    adc #'0'
    jsr modem_out
    jmp list_print_after_index
list_print_ten:
    lda #'2'
    jsr modem_out
    txa
    sec
    sbc #20
    clc
    adc #'0'
    jsr modem_out
    jmp list_print_after_index
list_print_twenty:
    lda #'1'
    jsr modem_out
    txa
    sec
    sbc #10
    clc
    adc #'0'
    jsr modem_out
    jmp list_print_after_index
list_print_single_digit:
    txa
    clc
    adc #'0'
    jsr modem_out
list_print_after_index:
    lda #'.'
    jsr modem_out
    lda #' '
    jsr modem_out
    ; read output_id at offset +2
    ldy #2
    lda (recipes_ptr_lo),y
    sta craft_out_id
    ; compute name offset = craft_out_id * 8
    lda craft_out_id
    asl
    asl
    asl
    tax
print_recipe_name:
    lda item_names,X
    cmp #$20
    beq recipe_name_done
    jsr modem_out
    inx
    txa
    and #$07
    bne print_recipe_name
recipe_name_done:
    ; newline
\n
    lda #13
    jsr modem_out
    lda #10
    jsr modem_out
    ; advance pointer by 15 bytes to next recipe
    lda recipes_ptr_lo
    clc
    adc #15
    sta recipes_ptr_lo
    lda recipes_ptr_hi
    adc #0
    sta recipes_ptr_hi
    inx
    jmp list_recipes_loop
list_recipes_done:
    ; prompt: enter multi-digit index, terminated by Enter (CR)
    ldx #0
    ldy #0
    lda #0
    sta temp_amount   ; accumulator for index
read_index_loop:
    jsr modem_in
    ; check for CR (13)
    cmp #13
    beq read_index_done
    ; ignore non-digits
    cmp #'0'
    bcc read_index_loop
    cmp #'9'
    bcs read_index_loop
    ; convert digit
    sec
    sbc #'0'
    ; A = digit (0..9)
    ; multiply temp_amount by 10: temp_amount = temp_amount*10
    lda temp_amount
    tay
    lda temp_amount
    asl
    asl
    asl
    sta craft_tmp2    ; temp*8
    lda temp_amount
    asl
    clc
    adc craft_tmp2
    sta temp_amount   ; temp*10
    ; add digit
    clc
    adc A
    sta temp_amount
    jmp read_index_loop
read_index_done:
    lda temp_amount
    jsr craft_execute
    lda craft_last_result
    cmp #0
    beq craft_result_ok
    cmp #2
    beq craft_result_insuff
    cmp #3
    beq craft_result_fail
    cmp #1
    beq craft_result_notfound
    jmp craft_menu_done
craft_result_ok:
    ldx #0
craft_result_ok_print:
    lda craft_success_msg,X
    beq craft_result_ok_done
    jsr modem_out
    inx
    bne craft_result_ok_print
craft_result_ok_done:
    jmp craft_menu_done
craft_result_insuff:
    ldx #0
craft_result_insuff_print:
    lda craft_insuff_msg,X
    beq craft_result_insuff_done
    jsr modem_out
    inx
    bne craft_result_insuff_print
craft_result_insuff_done:
    jmp craft_menu_done
craft_result_fail:
    ldx #0
craft_result_fail_print:
    lda craft_fail_msg,X
    beq craft_result_fail_done
    jsr modem_out
    inx
    bne craft_result_fail_print
craft_result_fail_done:
    jmp craft_menu_done
craft_result_notfound:
    ldx #0
craft_result_notfound_print:
    lda craft_notfound_msg,X
    beq craft_result_notfound_done
    jsr modem_out
    inx
    bne craft_result_notfound_print
craft_result_notfound_done:
    jmp craft_menu_done
craft_menu_done:
    jsr modem_in
    rts

// --- Mini-Games Data ---
game_rng_seed: .byte $A7             // Random seed
player_high_score: .byte 0           // Best game score
player_games_total: .byte 0          // Total games played

// --- Daily Rewards Data ---
daily_claimed: .byte 0               // 0=not claimed, 1=claimed today
login_streak: .byte 1                // Current streak (1-7)
last_login_day: .byte 0              // Day of last login
streak_rewards: .byte 5, 10, 15, 20, 30, 40, 50  // Gold per streak day

// --- Train Ticket Data ---
has_train_ticket: .byte 0            // 0=no ticket, 1=has ticket
train_ticket_price: .byte 5          // Cost: 5 gold
season_pass_owned: .byte 0           // 0=no pass, 1=season pass owned
season_pass_price: .byte 50         // Cost: 50 gold for unlimited rides

// --- NPC Greetings ---
npc_greet_timer: .byte 0             // internal timer (ticks)
npc_greet_interval: .byte 12         // how often town checks for greetings
npc_greet_count: .byte 3
npc_greet_1:
    .text "\r\nA passerby tips their hat and says: 'Lovely weather for adventure.'\r\n"
    .byte 0
npc_greet_2:
    .text "\r\nA vendor calls: 'Fresh pies! Get them while they're warm!'\r\n"
    .byte 0
npc_greet_3:
    .text "\r\nAn old woman chuckles: 'You look like trouble — in the best way.'\r\n"
    .byte 0

circus_high_score: .byte 0

// Train dynamic timing
train_delay_factor: .byte 0    // 0=no extra delay, higher = more delay
temp_threshold: .byte 0

conductor_delay_msg:
    .text "\r\nConductor Bob: 'Expect a short delay at this stop.'\r\n"
    .byte 0

// Arena leaderboard (top 3 scores)
arena_leader_1: .byte 0
arena_leader_2: .byte 0
arena_leader_3: .byte 0

// Marketplace restock helper
shop_restock_counter: .byte 0

// Autosave / quick-save
autosave_counter: .byte 0
autosave_interval: .byte 120   // cycles before autosave (approx)
autosave_slot: .byte 0         // alternate slot toggle
// Detainment system: when placed in the Stocks or Jail the player
// cannot leave until `detain_timer` counts down to zero.
detain_timer: .byte 0          // remaining turns detained
detain_type: .byte 0           // 0=none,1=stocks,2=jail
// Crafting temps
craft_temp: .byte 0
craft_tmp2: .byte 0
craft_last_result: .byte 0    ; 0=ok,1=notfound,2=insufficient,3=failure,4=no-space
recipes_ptr_lo: .byte 0
recipes_ptr_hi: .byte 0
craft_in1_id: .byte 0
craft_in1_qty: .byte 0
craft_in2_id: .byte 0
craft_in2_qty: .byte 0
craft_in3_id: .byte 0
craft_in3_qty: .byte 0
craft_out_id: .byte 0
craft_out_qty: .byte 0
craft_out_dur: .byte 0
craft_success_rate: .byte 0
// Stamina support (pickaxes now tracked as inventory items with per-slot durability)
player_stamina: .byte 12       // player's available stamina for digging (max 12)

// maybe print an NPC greeting occasionally when in town
maybe_npc_greet:
    jsr get_random
    and #$07
    cmp #3
    bcs no_npc_greet
    ; choose greeting index
    jsr get_random
    and #$03
    cmp #0
    beq print_greet_1
    cmp #1
    beq print_greet_2
    jmp print_greet_3

print_greet_1:
    ldx #0
greet1_loop:
        lda npc_greet_1,X
        beq greet_done
        jsr modem_out
        inx
        bne greet1_loop
greet_done:
    jsr modem_in
    rts
print_greet_2:
    ldx #0
greet2_loop:
        lda npc_greet_2,X
        beq greet2_done
        jsr modem_out
        inx
        bne greet2_loop
greet2_done:
    jsr modem_in
    rts
print_greet_3:
    ldx #0
greet3_loop:
        lda npc_greet_3,X
        beq greet3_done
        jsr modem_out
        inx
        bne greet3_loop
greet3_done:
    jsr modem_in
    rts

no_npc_greet:
    rts

// --- Room Shop Data ---
shop_items_count: .byte 9
shop_item_names:
    .text "Fancy Rug       "  // 16 chars each
    .text "Crystal Lamp    "
    .text "Gold Frame      "
    .text "Magic Mirror    "
    .text "Royal Banner    "
    .text "Ancient Statue  "
    .text "Velvet Cushions "
    .text "Bronze Sundial  "
    .text "Silken Drapes   "
shop_item_prices: .byte 25, 40, 60, 80, 100, 150, 35, 45, 55
shop_item_owned: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0  // 0=not owned, 1=owned

// --- Quests Data ---
quest_count: .byte 4
quest_names:
    .text "Play 3 Games    "  // 16 chars each
    .text "Visit 2 Rooms   "
    .text "Send a Message  "
    .text "Win at Slots    "
quest_targets: .byte 3, 2, 1, 1       // Target to complete
quest_progress: .byte 0, 0, 0, 0      // Current progress
quest_rewards: .byte 15, 10, 5, 25    // Gold reward
quest_complete: .byte 0, 0, 0, 0      // 0=incomplete, 1=complete

// --- Hall of Fame Data ---
hof_gold_names:
    .text "GoldKing        "  // 16 chars each, top 3
    .text "RichQueen       "
    .text "WealthyOne      "
hof_gold_scores: .byte 255, 180, 120
hof_achieve_names:
    .text "MasterPlayer    "
    .text "ProGamer        "
    .text "SkillMaster     "
hof_achieve_scores: .byte 8, 6, 5
hof_games_names:
    .text "GameFanatic     "
    .text "PlayMaster      "
    .text "FunLover        "
hof_games_scores: .byte 99, 75, 50

// --- Pets Data ---
pet_owned: .byte 0                   // 0=no pet, 1-4=pet type
pet_name: .fill 12, 0                // Pet's name (12 chars)
pet_hunger: .byte 5                  // 0-10 (0=starving, 10=full)
pet_happiness: .byte 5               // 0-10 (0=sad, 10=happy)
pet_level: .byte 1                   // Pet level 1-10
pet_types_count: .byte 4
pet_type_names:
    .text "Dragon  "                // 8 chars each
    .text "Cat     "
    .text "Dog     "
    .text "Phoenix "
pet_adopt_cost: .byte 50, 20, 20, 75

// --- Badges Data ---
badges_earned: .byte 0               // Bit flags for earned badges
badge_displayed: .byte 0             // Currently displayed badge (0-7)
badge_count: .byte 8
badge_names:
    .text "Newcomer        "  // 16 chars each
    .text "Social Star     "
    .text "Game Master     "
    .text "Wealthy         "
    .text "Pet Lover       "
    .text "Collector       "
    .text "Event Host      "
    .text "Legend          "
badge_icons: .byte '@', '*', '#', '$', '&', '+', '!', '^'

// --- Lottery Data ---
lottery_tickets: .byte 0             // Tickets owned
lottery_ticket_cost: .byte 10        // Cost per ticket
lottery_jackpot: .byte 100           // Current jackpot
lottery_last_winner: .fill 12, 0     // Last winner name
lottery_prizes: .byte 5, 10, 25, 50, 100  // Prize tiers

// --- Bank Data ---
bank_balance: .byte 0                // Savings balance
bank_loan: .byte 0                   // Current loan amount
bank_interest_rate: .byte 5          // 5% interest on savings
bank_loan_rate: .byte 10             // 10% loan interest

// --- Auction Data ---
auction_active: .byte 0              // Is there an active auction?
auction_item: .byte 0                // Item being auctioned (1-6)
auction_min_bid: .byte 10            // Minimum bid
auction_current_bid: .byte 0         // Current highest bid
auction_seller: .byte 0              // 0=player, 1=NPC
auction_time_left: .byte 0           // Turns remaining

// --- Weather Data ---
current_weather: .byte 0             // 0=sunny,1=rainy,2=stormy,3=snowy,4=foggy
weather_bonus: .byte 0               // Current weather bonus
weather_turns: .byte 0               // Turns until weather changes

// --- Crafting Data ---
craft_wood: .byte 5                  // Wood materials
craft_stone: .byte 3                 // Stone materials
craft_gems: .byte 1                  // Gem materials
craft_cloth: .byte 4                 // Cloth materials

// --- Reputation Data ---
player_reputation: .byte 50          // 0-100 reputation
rep_title_index: .byte 0             // Current title (0-4)
rep_deeds_today: .byte 0             // Good deeds done today

// --- Achievements Data ---
achieve_flags: .byte 0               // Bit flags for achievements
achieve_count: .byte 0               // Total achievements unlocked
// Bit 0: First Visit, Bit 1: 100 Gold, Bit 2: 10 Friends
// Bit 3: Max Rep, Bit 4: Craft Master, Bit 5: Pet Owner
// Bit 6: Lottery Win, Bit 7: Trader

// --- Guild Data ---
player_guild: .byte 0                // 0=none, 1-4=guild ID
guild_rank: .byte 0                  // 0=member, 1=officer, 2=leader
guild_contrib: .byte 0               // Contribution points
guild_treasury: .fill 15, 0          // Treasury for each guild

// --- Honorific Titles Data ---
equipped_honorific: .byte 0          // Current equipped title (0-7)
unlocked_titles: .byte 1             // Bit flags for unlocked titles
// Bit 0: Newcomer (default), Bit 1: Adventurer, Bit 2: Wealthy
// Bit 3: Popular, Bit 4: Crafter, Bit 5: Champion
// Bit 6: Legend, Bit 7: Master

// --- Fortune Data ---
fortune_claimed: .byte 0             // Fortune claimed today?
last_fortune: .byte 0                // Last fortune index
lucky_number: .byte 7                // Today's lucky number

// --- Garden Data ---
garden_plot1: .byte 0                // 0=empty, 1-4=crop type, +10=ready
garden_plot2: .byte 0                // Same encoding
garden_plot3: .byte 0                // Same encoding
garden_water: .byte 0                // Watered today?
garden_seeds: .byte 3                // Seeds in inventory

// --- Fishing Data ---
fish_caught: .byte 0                 // Fish in bucket
fish_casts: .byte 5                  // Casts remaining today
bait_count: .byte 3                  // Bait in inventory
best_catch: .byte 0                  // Biggest fish caught

// --- Racing Data ---
race_wins: .byte 0                   // Total races won
race_losses: .byte 0                 // Total races lost
race_streak: .byte 0                 // Current win streak
race_entry: .byte 5                  // Entry fee in gold
race_today: .byte 3                  // Races left today

// --- Treasure Hunt Data ---
treasure_found: .byte 0              // Total treasures found
treasure_clue: .byte 0               // Current clue (0-3)
treasure_guess: .byte 0              // Current guess location
dig_attempts: .byte 5                // Digs remaining today
treasure_loc: .byte 2                // Secret treasure location (0-3)

// --- Cooking Data ---
meals_cooked: .byte 0                // Total meals cooked
recipe_known: .byte 1                // Recipes unlocked (bitmask)
buff_active: .byte 0                 // 0=none, 1=luck, 2=strength
buff_timer: .byte 0                  // Buff turns remaining

// --- Dueling Data ---
duel_wins: .byte 0                   // Total duels won
duel_losses: .byte 0                 // Total duels lost
player_hp: .byte 20                  // Player hit points
enemy_hp: .byte 0                    // Current enemy HP
duels_today: .byte 3                 // Duels remaining today

// --- Mailbox Data ---
mail_count: .byte 3                  // Unread messages
mail_reward: .byte 5                 // Gold in mailbox
mail_claimed: .byte 0                // Daily mail claimed?

// --- Riddles Data ---
riddles_solved: .byte 0              // Total riddles solved
current_riddle: .byte 0              // Current riddle index
riddle_attempts: .byte 3             // Attempts remaining today

// --- Cipher Data ---
ciphers_solved: .byte 0              // Total ciphers cracked
current_cipher: .byte 0              // Current cipher index
cipher_attempts: .byte 2             // Cipher attempts today
cipher_hint_used: .byte 0            // Hint used flag
cipher_answer_buffer: .fill 16, 0    // Buffer for cipher answer input

// --- Bounty Data ---
bounties_done: .byte 0               // Total bounties completed
active_bounty: .byte 255             // Current bounty (255=none)
bounty_target: .byte 0               // Target type
bounty_reward: .byte 20              // Reward amount

// --- Companions Data ---
companion_slot: .byte 255            // Active companion (255=none)
companion_bond: .byte 0              // Bond level 0-10
companion_bonus: .byte 0             // Current stat bonus

// --- Tavern Data ---
drinks_bought: .byte 0               // Total drinks purchased
tavern_buff: .byte 0                 // Current buff type
tavern_timer: .byte 0                // Buff duration

// --- Gambling Data ---
gamble_wins: .byte 0                 // Total gambling wins
gamble_losses: .byte 0               // Total gambling losses
last_roll: .byte 0                   // Last dice roll

// --- Scavenger Data ---
items_found: .byte 0                 // Total items found
hunt_progress: .byte 0               // Current hunt progress (bitmask)
hunt_complete: .byte 0               // Hunts completed

// --- Meditation Data ---
meditation_lvl: .byte 1              // Meditation level
wisdom_points: .byte 0               // Wisdom accumulated
meditate_today: .byte 3              // Meditations remaining

// --- Spy Network Data ---
intel_gathered: .byte 0              // Total intel reports
spy_missions: .byte 3                // Missions remaining today
spy_rank: .byte 1                    // Spy rank 1-5

// --- Arena Data ---
arena_wins: .byte 0                  // Total arena wins
arena_rank: .byte 1                  // Arena rank 1-10
arena_fights: .byte 3                // Fights remaining today

// --- Arena Ticketing ---
arena_ticket_owned: .byte 0          // 0=no ticket, 1=has arena session ticket
arena_ticket_price: .byte 5          // Cost: 5 gold for one session
arena_season_pass_owned: .byte 0     // 0=no arena pass, 1=season pass owned
arena_season_pass_price: .byte 30    // Cost: 30 gold for season pass
arena_prize_pool: .word 0            // Accumulated prize pool from lost bets
temp_amount: .byte 0

// --- Museum Data ---
artifacts_found: .byte 0             // Total artifacts discovered
museum_donations: .byte 0            // Items donated to museum
museum_pass: .byte 0                 // 0=none, 1=member, 2=patron

// --- Spell Casting Data ---
player_mana: .byte 20                // Current mana points (max 100)
player_max_mana: .byte 20            // Maximum mana
spells_known: .byte 0                // Bit flags: 0=GLACIOUS, 1=NIX, 2=ILLUMINA, 3=SPIDER, 4=DREAM, 5=MEMORY
spell_cooldown: .byte 0              // Turns until next spell
frost_weaver_rank: .byte 0           // 0=none, 1=initiate, 2=adept, 3=master
spell_power_bonus: .byte 0           // Bonus from equipment/rank
last_spell_cast: .byte 255           // Last spell index (255=none)
spell_combo_count: .byte 0           // Consecutive spell combo
mana_regen_rate: .byte 2             // Mana regen per action
third_eye_active: .byte 0            // Third eye meditation active?
pendulum_mastery: .byte 0            // Pendulum skill level 0-10

// --- Romance Data ---
romance_partner: .byte 255           // Current partner (255=none, 0=Kira, 1=Lyra, 2=Kendrick, 3=Bonny)
romance_level: .byte 0               // Relationship level 0-10
courtship_stage: .byte 0             // 0=none, 1=introduced, 2=courting, 3=engaged, 4=married
marriage_date: .byte 0               // In-game day of marriage
gifts_given: .byte 0                 // Total romantic gifts given
dates_completed: .byte 0             // Successful dates
wedding_witnesses: .byte 0           // How many attended wedding

// --- Dream System Data ---
dreams_had: .byte 0                  // Total dreams experienced
nightmares_survived: .byte 0         // Nightmares defeated
prophecies_received: .byte 0         // Prophetic visions seen
veylan_influence: .byte 0            // Veylan's corruption level 0-10
dream_protection: .byte 0            // Protection from nightmares
last_dream_type: .byte 255           // Last dream (255=none)
dream_cooldown: .byte 0              // Actions until next dream

// --- Ship Travel Data ---
voyages_completed: .byte 0           // Total voyages taken
current_port: .byte 0                // Current port (0=Everland, 1=Aurora, 2=Mythos, 3=England)
cargo_hold: .byte 0                  // Cargo type being carried
cargo_amount: .byte 0                // Cargo quantity
sea_encounters: .byte 0              // Random encounters had
trade_profit: .byte 0                // Gold earned from sea trade

// --- Faction Reputation Data ---
rep_frost_weavers: .byte 0           // Frost Weavers guild standing 0-100
rep_merchants: .byte 0               // Merchant guild standing
rep_forest_keepers: .byte 0          // Forest Keepers (druids)
rep_black_rose: .byte 0              // Order of Black Rose
rep_wolves: .byte 0                  // Wolves of Winter
rep_owls: .byte 0                    // Order of the Owls
rep_pirates: .byte 0                 // Pirate faction (Black Siren crew)
faction_rank: .byte 0                // 0=neutral, 1=ally, 2=honored, 3=exalted

// --- Dueling Arena Data ---
arena_rating: .byte 100              // PvP rating (100 base)
duels_won: .byte 0                   // Total duels won
duels_lost: .byte 0                  // Total duels lost
arena_title: .byte 0                 // 0=none, 1=contender, 2=gladiator, 3=champion
win_streak: .byte 0                  // Current winning streak

// --- Day/Night Cycle Data ---
time_of_day: .byte 0                 // 0=dawn, 1=morning, 2=midday, 3=afternoon, 4=evening, 5=night
actions_per_phase: .byte 10          // Actions before time advances
action_counter: .byte 0              // Current action count
night_vision: .byte 0                // Can see at night? 0=no, 1=yes
night_shops_open: .byte 0            // Bit flags: which shops open at night

// --- Player Trading Data ---
trade_active: .byte 0                // 0=no trade, 1=pending, 2=confirmed
trade_partner: .byte 0               // Slot of trade partner
trade_offer_gold: .byte 0            // Gold player is offering
trade_offer_item: .byte 255          // Item player is offering (255=none)
trade_receive_gold: .byte 0          // Gold player will receive
trade_receive_item: .byte 255        // Item player will receive
trade_pending: .fill 8, 0            // Pending trade requests per slot

// --- Dungeon Crawl Data ---
dungeon_level: .byte 0               // Current dungeon depth (0=not in dungeon)
dungeon_room: .byte 0                // Current room in level (0-9)
dungeon_hp: .byte 100                // Health during crawl
dungeon_keys: .byte 0                // Keys found this run
dungeon_gold_found: .byte 0          // Gold found this run
dungeon_boss_defeated: .byte 0       // Bit flags for bosses defeated
room_type: .byte 0                   // 0=empty, 1=monster, 2=treasure, 3=trap, 4=merchant, 5=boss
room_cleared: .fill 10, 0            // Cleared rooms on current level
dungeon_deepest: .byte 0             // Deepest level reached (achievement)

// --- Boss Encounter Data ---
boss_active: .byte 0                 // Which boss is active (0=none)
boss_hp: .word 0                     // Boss current HP (16-bit for big bosses)
boss_max_hp: .word 0                 // Boss max HP
boss_phase: .byte 0                  // Boss attack phase (0-3)
boss_defeated: .byte 0               // Bit flags: 0=Kasimere, 1=Veylan, 2=Dragon, 3=Unseely King
boss_attempts: .byte 0               // Attempts at current boss
boss_reward_claimed: .byte 0         // Claimed rewards for bosses

// --- Skill Tree Data ---
skill_points: .byte 5                // Unspent skill points
skill_combat: .byte 0                // Combat tree level (0-10)
skill_magic: .byte 0                 // Magic tree level (0-10)
skill_social: .byte 0                // Social tree level (0-10)
skill_survival: .byte 0              // Survival tree level (0-10)
combat_perks: .byte 0                // Bit flags for combat perks unlocked
magic_perks: .byte 0                 // Bit flags for magic perks unlocked
social_perks: .byte 0                // Bit flags for social perks unlocked
survival_perks: .byte 0              // Bit flags for survival perks unlocked
player_level: .byte 1                // Player level (gain SP on level up)
player_xp: .word 0                   // Experience points
xp_to_next: .word 100                // XP needed for next level

start:
    jsr select_user_slot
    jmp main_loop

main_loop:
    ; Autosave counter: increment and autosave when interval reached
    inc autosave_counter
    lda autosave_counter
    cmp autosave_interval
    bcc skip_autosave
    lda #0
    sta autosave_counter
    jsr quick_save
skip_autosave:
    ; Market event counter: trigger periodic restock and notify player
    dec market_event_counter
    lda market_event_counter
    bne skip_market_event
    ; trigger restock and reset counter
    jsr restock_shop
    ldx #0
market_event_notify_loop:
        lda market_event_msg,X
        beq market_event_notify_done
        jsr modem_out
        inx
        bne market_event_notify_loop
market_event_notify_done:
    lda market_event_interval
    sta market_event_counter
    jsr print_main_menu
    jsr get_menu_input
    cmp #'1'
    beq go_play_everland
    cmp #'7'
    beq visit_sawmill
    cmp #'2'
    beq go_inventory
    cmp #'3'
    beq go_high_scores
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
    cmp #'M'
    beq go_magic_menu
    cmp #'<'
    beq go_romance_menu
    cmp #'>'
    beq go_dream_menu
    cmp #'['
    beq go_ship_menu
    cmp #']'
    beq go_dungeon_menu
    cmp #'{'
    beq go_boss_menu
    cmp #'}'
    beq go_skills_menu
    cmp #'T'
    beq go_p2p_trade_menu
    cmp #'D'
    beq go_time_menu
    cmp #'V'
    beq quick_save
    cmp #'G'
    beq go_achievements
    cmp #'U'
    beq go_tutorial
    jmp main_loop

go_play_everland:
    jmp play_everland
go_inventory:
    jmp inventory
go_high_scores:
    jmp high_scores
go_dungeon_menu:
    jmp dungeon_menu
go_boss_menu:
    jmp boss_menu
go_skills_menu:
    jmp skills_menu
go_p2p_trade_menu:
    jmp player_trade_menu
go_time_menu:
    jmp time_menu
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
go_magic_menu:
    jmp magic_menu
go_romance_menu:
    jmp romance_menu
go_dream_menu:
    jmp dream_menu
go_ship_menu:
    jmp ship_menu

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
    .text "\r\nEVERLAND MAIN MENU:\r\n(Where memory and magic entwine)\r\n1. Play Everland\r\n2. Inventory\r\n3. High Scores\r\n4. Message Board\r\n5. Async PvP\r\n6. Save Game\r\n7. Load Game\r\n8. Portal Travel\r\n9. Quit\r\nL. Library\r\nM. Magic & Spells\r\n<. Romance\r\n>. Dreams\r\n[. Ship Travel\r\n]. Dungeon Crawl\r\n{. Boss Battles\r\n}. Skill Trees\r\nT. Player Trade\r\nD. Day/Night\r\nG. Achievements\r\nU. Tutorial\r\n\r\nLore: The portal shimmers with fractured memories.\r\n> "

get_menu_input:
    // Get a key from modem
    jsr modem_in
    rts

    ; Map extra main-menu keys
go_achievements:
    jmp view_achievements
go_tutorial:
    jmp tutorial_start

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
    .text "\r\nLIBRARY:\r\n1. Browse Songbooks\r\n2. Browse Your Lore Book\r\n3. Paste Your Own Lore Book\r\n4. Back to Main Menu\r\n> "

get_library_input:
    jsr modem_in
    cmp #'1'
    beq go_browse_songbooks
    cmp #'2'
    beq go_browse_lore
    cmp #'3'
    beq paste_lore_book
    cmp #'4'
    beq go_main_loop_lib
    rts

go_browse_songbooks:
    jmp browse_songbooks
go_browse_lore:
    jmp browse_lore_book
go_main_loop_lib:
    jmp main_loop

paste_lore_book:
    jsr check_reu
    lda expansion_ram
    beq paste_lore_disk   // 0 = no expansion, use disk
    cmp #1
    beq paste_lore_reu    // 1 = REU
    jmp paste_lore_georam // 2 = GeoRAM

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

// --- GeoRAM Lore Paste ---
paste_lore_georam:
    ldx #0
paste_georam_prompt_loop:
        lda paste_lore_prompt,X
        beq paste_georam_prompt_done
        jsr modem_out
        inx
        bne paste_georam_prompt_loop
paste_georam_prompt_done:
    ldy #0             // GeoRAM page
    ldx #0             // Offset within page
paste_georam_loop:
        jsr modem_in
        cmp #26        // CTRL-Z
        beq paste_georam_done
        // Store byte to GeoRAM
        pha
        lda #0
        sta $DFFE      // Block 0
        sty $DFFF      // Current page
        pla
        sta $DE00,X    // Store at offset
        inx
        bne paste_georam_loop
        // Page full, next page
        iny
        cpy #8         // Max 8 pages (2KB)
        bne paste_georam_loop
paste_georam_done:
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
    sta expansion_ram  // 1 = REU
    rts
no_reu:
    lda #0
    sta reu_present
    // Try GeoRAM detection
    jsr check_georam
    rts

check_georam:
    // GeoRAM uses $DFFE (block), $DFFF (page), $DE00-$DEFF (256-byte window)
    // Detect by writing pattern to page 0, switch to page 1, verify different,
    // switch back to page 0, verify original value
    lda #0
    sta $DFFE          // Block 0
    sta $DFFF          // Page 0
    lda #$A5           // Test pattern 1
    sta $DE00          // Write to window
    lda #1
    sta $DFFF          // Switch to page 1
    lda #$5A           // Test pattern 2
    sta $DE00          // Write different value
    lda #0
    sta $DFFF          // Switch back to page 0
    lda $DE00          // Read back
    cmp #$A5           // Should be original pattern
    bne no_georam
    lda #1
    sta $DFFF          // Check page 1
    lda $DE00
    cmp #$5A           // Should be second pattern
    bne no_georam
    // GeoRAM detected!
    lda #1
    sta georam_present
    lda #2
    sta expansion_ram  // 2 = GeoRAM
    rts
no_georam:
    lda #0
    sta georam_present
    sta expansion_ram  // 0 = no expansion RAM
    rts

// --- GeoRAM Access Routines ---
// A = byte to store, X = offset within page, Y = page number
georam_store_byte:
    pha
    lda #0
    sta $DFFE          // Block 0 for now
    sty $DFFF          // Set page
    pla
    sta $DE00,X        // Store at offset
    rts

// X = offset within page, Y = page number, returns A = byte
georam_load_byte:
    lda #0
    sta $DFFE          // Block 0
    sty $DFFF          // Set page
    lda $DE00,X        // Load from offset
    rts

// Store 256-byte block to GeoRAM page Y from address at ptr
georam_store_page:
    lda #0
    sta $DFFE
    sty $DFFF
    ldx #0
georam_store_page_loop:
    lda (georam_ptr),X
    sta $DE00,X
    inx
    bne georam_store_page_loop
    rts

// Load 256-byte block from GeoRAM page Y to address at ptr
georam_load_page:
    lda #0
    sta $DFFE
    sty $DFFF
    ldx #0
georam_load_page_loop:
    lda $DE00,X
    sta (georam_ptr),X
    inx
    bne georam_load_page_loop
    rts

georam_ptr: .word 0  // ZP pointer for page operations

reu_present: .byte 0 // 0 = not detected, 1 = detected
georam_present: .byte 0 // 0 = not detected, 1 = detected
expansion_ram: .byte 0 // 0 = none, 1 = REU, 2 = GeoRAM
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
    .text "\r\nLORE NPCs:\r\n1. Speak to Lady Cordelia\r\n2. Visit Grim the Blackheart\r\n3. Enter Cursed Garden\r\n4. Back to Portal\r\n> "
lore_cordelia_msg:
    .text "\r\nLady Cordelia, legendary knight and guardian of Lore, stands in full regalia. 'I trained a new generation of knights after we fled through the portal. Mage Damon, Damian, Barnabis, Princess Delphi - we all lost our memories in the crossing.'\r\n\r\n'The dark sun and moon crystals sustained us. May the green thorn pierce me if I fail in my quest!'\r\n\r\nQuest Chain:\r\n1. Recover memory fragments (speak to refugees)\r\n2. Retrieve the dark crystals from Kasimere\r\n3. Swear the green thorn oath\r\n4. Restore the Order of the Black Rose\r\n\r\n(Quest: Will you take the knight's oath?)\r\n"
lore_knight_oath_complete_msg:
    .text "\r\nQuest complete: You have sworn the knight's oath! Lady Cordelia welcomes you to the Order.\r\n(Reward: Black Rose Emblem added to inventory.)\r\nLore Event: Stones hold the memory of ancient gatherings, and you glimpse Everland's defenders from centuries past.\r\n"
lore_grim_msg:
    .text "\r\nGrim the Blackheart speaks: 'Few words, but deep loyalty. Sacrifice is the price of hope.'\r\n(Quest: Prove your loyalty in battle.)\r\n\r\nLore: The plaza stones shift, revealing a hidden passage. You glimpse Everland's defenders, their courage echoing in the heart of the park.\r\n"
cursed_garden_msg:
    .text "\r\nYou enter the CURSED GARDEN - green thorny plants reach with gnarled claws. The air grows dense. At the heart stands the Pumpkin King's throne.\r\n\r\nBattle Quest Chain:\r\n1. Parry thorny attacks (knight training)\r\n2. Summon spider allies (Spider Princess)\r\n3. Position Grim for the final strike\r\n4. Shatter the Pumpkin King's power\r\n\r\nWarning: Grim will sacrifice himself...\r\n[Press any key]\r\n"
    .byte 0

portal_mythos_msg:
    .text "\r\nYou step through the portal and arrive in Mythos, realm of jungles and secrets. The Dragon Queen and ancient mysteries await.\r\n\r\nMYSTICWOOD: Dark trees crowd together, paper charms sway from branches. Herbs and moss blanket the ground, and the air is thick with whispered lore. Rituals are sometimes performed here, and spirits are said to watch from the shadows. If you listen closely, you may feel the presence of ancient magic and glimpse a vision of the wood's past.\r\n"
mythos_npc_menu_msg:
    .text "\r\nMYTHOS NPCs:\r\n1. Speak to the Dragon Queen\r\n2. Visit the Ancient Mystic\r\n3. Back to Portal\r\n> "
mythos_dragon_queen_msg:
    .text "\r\nThe Dragon Queen greets you: 'Welcome, traveler. Seek wisdom, and you may unlock the secrets of Mythos.'\r\n(Quest: Find the lost dragon scale.)\r\n\r\nQuest Multi-Path: 1) Join the dragon trainers or seek the hidden treasure, 2) Decide the fate of the loot, 3) Experience alternate dragon lore events based on your choice.\r\n"
mythos_dragon_scale_complete_msg:
    .text "\r\nQuest complete: You have found the lost dragon scale! The Queen rewards you with her blessing.\r\n(Reward: Dragon Scale added to inventory.)\r\nLore Event: Dragons soar through fire and sky, and you feel the ancient bond between trainer and dragon.\r\n"

// Town of Everland
portal_town_msg:
    .text "\r\nYou arrive in the TOWN OF EVERLAND. Cobblestone streets wind between timber-framed shops. Merchants call out their wares, children play by the fountain, and the scent of fresh bread mingles with woodsmoke.\r\n\r\nThis is the heart of the realm - where all journeys begin and end.\r\n"
// --- Add to town menu ---
town_menu_msg:
    .text "\r\nTOWN OF EVERLAND:\r\n1. Train Station     A. Fairy Gardens\r\n2. Tipsy Maiden      B. Arena\r\n3. Kettle Cafe       C. Pirate Ship\r\n4. Copper Confection D. Tower\r\n5. Glass House       E. Church\r\n6. Dragon Haven      F. Catacombs\r\n7. Temple Ruins      G. Statue of Michael\r\n8. Louden's Rest     H. Marketplace\r\n9. The Moselem       I. Witch's Tent\r\nM. Moon Portal       J. Hunter's Hovel\r\nK. The Burrows       L. Mystic's Tent\r\nN. Central Plaza     O. The Bridge\r\nP. Kira's Apothecary R. Forge\r\nT. Hex Trove (cold witch treats)\r\nU. Food Court East   V. Food Court West\r\nQ. Circus Tent       S. The Stage\r\n0. Back to Portal\r\n> "
    .byte 0
    .text "\r\nTOWN OF EVERLAND:\r\n1. Train Station     A. Fairy Gardens\r\n2. Tipsy Maiden      B. Arena\r\n3. Kettle Cafe       C. Pirate Ship\r\n4. Copper Confection D. Tower\r\n5. Glass House       E. Church\r\n6. Dragon Haven      F. Catacombs\r\n7. Temple Ruins      G. Statue of Michael\r\n8. Louden's Rest     H. Marketplace\r\n9. The Moselem       I. Witch's Tent\r\nM. Moon Portal       J. Hunter's Hovel\r\nK. The Burrows       L. Mystic's Tent\r\nN. Central Plaza     O. The Bridge\r\nP. Kira's Apothecary R. Forge\r\nT. Hex Trove (cold witch treats)\r\nU. Food Court East   V. Food Court West\r\nQ. Circus Tent       S. The Stage\r\n0. Back to Portal\r\n> "
    .byte 0

town_menu_extra_msg:
    .text "W. Stocks  X. Archery  Y. Ax Throwing  Z. Jail\r\n"
    .byte 0

// Town location messages
train_station_msg:
    .text "\r\nThe TRAIN STATION stands proud with iron and steam. A grand clock tower marks the time. Travelers await the next departure to distant lands.\r\n\r\nAs the train rumbles by, a chorus of howls rises from Hunter's Hovel - the Wolves of Winter greeting the passengers in their ancient tradition.\r\n\r\n'All aboard! Next train leaves at the toll of the bell.'\r\n[Press any key]\r\n"
    .byte 0
tipsy_maiden_msg:
    .text "\r\nThe TIPSY MAIDEN TAVERN overflows with laughter and song. Barrels line the walls, and a roaring fire warms the room.\r\n\r\n'What'll it be, traveler? We've got tales and ale aplenty!'\r\n[Press any key]\r\n"
    .byte 0
kettle_cafe_msg:
    .text "\r\nThe KETTLE CAFE is cozy and warm. Steam rises from ornate teapots. Pastries fill glass cases, and the aroma of fresh-brewed tea fills the air.\r\n\r\n'Care for a cup? We have blends from every corner of the realm.'\r\n[Press any key]\r\n"
    .byte 0
copper_confection_msg:
    .text "\r\nCOPPER CONFECTION sparkles with jars of colorful candies and frozen treats. Children press their faces to the glass, eyes wide with wonder.\r\n\r\n'Try our moonberry ice cream - a local favorite!'\r\n[Press any key]\r\n"
    .byte 0
glass_house_msg:
    .text "\r\nThe GLASS HOUSE is a magnificent conservatory filled with exotic creatures. Colorful birds sing from gilded cages. A phoenix preens its feathers.\r\n\r\n'Careful now - some of these beauties bite!'\r\n[Press any key]\r\n"
    .byte 0
dragon_haven_msg:
    .text "\r\nDRAGON HAVEN rises with obsidian spires. Young dragons practice flight in the courtyard. Trainers guide hatchlings through their first flames.\r\n\r\n'The bond between dragon and rider is sacred here.'\r\n[Press any key]\r\n"
    .byte 0
temple_ruins_msg:
    .text "\r\nThe TEMPLE RUINS stand as remnants of an ancient faith. Crumbled pillars reach toward the sky. Moss covers carved inscriptions of forgotten prayers.\r\n\r\nAlister the Dragon Trainer stands among the stones, teaching initiates.\r\n"
    .byte 0
alister_msg:
    .text "\r\nAlister the Dragon Trainer speaks with passion: 'Long ago, Anderon the great dragon snagged a pine tree between his claws. His roar of pain reached a nearby village, and they banded together to free him!'\r\n\r\n'Through the Order of the Emerald Sky, we cultivate the bond between human and dragon.'\r\n\r\nDragon Trainer Oaths:\r\n1. 'I swear to protect dragons as long as my arms have strength.'\r\n2. 'I swear to aid dragons as long as my legs may carry me.'\r\n3. 'I swear to deepen my knowledge and share it with others.'\r\n\r\n*Two fingers intertwined* - the bond between dragon and trainer.\r\n'Fly on the dragon's wings!'\r\n\r\n(Quest: Take the Dragon Trainer's Oath.)\r\n[Press any key]\r\n"
    .byte 0
torin_msg:
    .text "\r\nTorin, leader of the Unseely Court, emerges from ancient ruins. Morris watches with eyes ablaze.\r\n\r\n'You have proven your loyalty. Now take part in the binding ritual that will bind your soul to us.'\r\n\r\n'Hold out your hand and kneel. Repeat: Goofice Goafice Alakda, orgawal, Goragawal.'\r\n\r\nBinding Quest Chain:\r\n1. Retrieve the heart of Loudon from the graveyard\r\n2. Complete the necromancy incantation challenge\r\n3. Undergo the binding ritual\r\n4. Serve Torin's dark plans for Everland\r\n\r\n(Warning: This binds your soul forever!)\r\n[Press any key]\r\n"
    .byte 0
loudens_rest_msg:
    .text "\r\nLOUDEN'S REST - the graveyard where the honored dead slumber. Iron gates creak in the wind. Tombstones tell tales of heroes and villains alike.\r\n"
    .byte 0
louden_tosh_msg:
    .text "\r\nTosh leans against a weathered mausoleum, serving dual roles - undertaker and explorer of the underground, retrieving trinkets from the sewers.\r\n\r\n'The dead have secrets, friend. I venture where few others dare to tread.'\r\n\r\nTosh Quest Chain:\r\n1. Help find a lost soul's final memento\r\n2. Explore the underground passages\r\n3. Retrieve a discarded trinket from the sewers\r\n4. Return a keepsake to a grieving family\r\n\r\n'Care to hear the secrets... for a price?'\r\n\r\n(Quest: Aid Tosh in his unusual work.)\r\n[Press any key]\r\n"
    .byte 0
moselem_msg:
    .text "\r\nThe MOSELEM rises with domed towers and intricate tilework. Incense drifts through arched doorways. Ancient wisdom echoes in hushed whispers.\r\n"
    .byte 0
moselem_kasimere_msg:
    .text "\r\nKasimere sits cross-legged on silk cushions: 'You seek answers. The Moselem holds many... but truth requires sacrifice.'\r\n\r\n(Quest: Prove your worth through the trials of the Moselem.)\r\n[Press any key]\r\n"
    .byte 0
moon_portal_msg:
    .text "\r\nThe MOON PORTAL glows with silver light. An archway of carved moonstone frames a shimmering gateway. The stars seem to bend toward it.\r\n\r\n'This portal awakens only when the moon is full.'\r\n[Press any key]\r\n"
    .byte 0
fairy_gardens_msg:
    .text "\r\nThe FAIRY GARDENS bloom with impossible flowers. A giant pumpkin husk glows warmly - home to the Pumpkin Fairies. Tiny lights flit between petals as fairies tend their magical grove.\r\n"
    .byte 0
forge_msg:
    .text "\r\nThe FORGE roars with heat. Sparks fly as blacksmiths hammer glowing metal. Weapons and trinkets are forged to order.\r\n\r\n'Need a blade or a horseshoe? We can craft it for a fee.'\r\n[Press any key]\r\n"
    .byte 0

forge_menu_msg:
    .text "\r\nFORGE - What would you like to craft?\r\n1) Ring (requires 2 Gems)\r\n2) Amulet (requires 3 Gems)\r\n3) Potion (requires 1 Gem)\r\n4) Make Pickaxe (requires 2 Iron + 1 Plank)\r\n5) Cut Gem (1 Gem -> Ruby/Sapphire/Emerald)\r\n6) Make Knife (1 Iron + 1 Leather)\r\n7) Make Dagger (2 Iron + 1 Leather)\r\n8) Make Hammer (2 Iron + 1 Plank)\r\n9) Make Axe (2 Iron + 1 Plank + 1 Leather)\r\na) Make Sword (4 Iron + 2 Plank + 1 Leather)\r\nb) Make Shield (3 Iron + 2 Plank + 1 Leather)\r\nc) Make Armor (6 Iron + 4 Leather)\r\n0) Leave\r\n> "
    .byte 0
craft_ring_success_msg:
    .text "\r\nYou fashion a simple ring from the gems. It feels lucky.\r\n[Press any key]\r\n"
    .byte 0
craft_ring_ruby_msg:
    .text "\r\nYou set the ruby into a warmed band — a fine ruby ring.\r\n[Press any key]\r\n"
    .byte 0
craft_ring_sapphire_msg:
    .text "\r\nA sapphire gleams in the ring you cut and polish.\r\n[Press any key]\r\n"
    .byte 0
craft_ring_emerald_msg:
    .text "\r\nYou craft a delicate ring and set the emerald within.\r\n[Press any key]\r\n"
    .byte 0
craft_amulet_success_msg:
    .text "\r\nYou craft a small amulet, its stone set in a humble setting.\r\n[Press any key]\r\n"
    .byte 0
craft_amulet_ruby_msg:
    .text "\r\nThe ruby amulet sings faintly — a sturdy charm.\r\n[Press any key]\r\n"
    .byte 0
craft_amulet_sapphire_msg:
    .text "\r\nA sapphire amulet, cool and deep, rests in your hands.\r\n[Press any key]\r\n"
    .byte 0
craft_amulet_emerald_msg:
    .text "\r\nAn emerald amulet glows with quiet life.\r\n[Press any key]\r\n"
    .byte 0
craft_potion_success_msg:
    .text "\r\nYou mix and bottle a crude potion. It bubbles faintly.\r\n[Press any key]\r\n"
    .byte 0
craft_insufficient_msg:
    .text "\r\nYou do not have the required materials to craft that.\r\n[Press any key]\r\n"
    .byte 0
craft_no_space_msg:
    .text "\r\nYour inventory is too full to hold what you craft. Clear a slot first.\r\n[Press any key]\r\n"
    .byte 0
hextrove_msg:
    .text "\r\nHEX TROVE - A curious shop of witchy cold treats. Candied frost and enchanted sorbets line the shelves, each labeled with whimsical warnings.\r\n\r\n'One lick and you'll forget your troubles... for an hour.'\r\n[Press any key]\r\n"
    .byte 0
foodcourt_east_msg:
    .text "\r\nFOOD COURT - EAST WING: Hearty full meals are served on wooden platters. Roasts, stews, and savory pies fill the air with mouthwatering aromas.\r\n\r\n'Come hungry, leave satisfied.'\r\n[Press any key]\r\n"
    .byte 0
foodcourt_west_msg:
    .text "\r\nFOOD COURT - WEST WING: Warm soups and fresh sandwiches are offered at a modest price. Perfect for a light meal between adventures.\r\n\r\n'Simple, wholesome, and quick.'\r\n[Press any key]\r\n"
    .byte 0
stocks_msg:
    .text "\r\nTHE STOCKS: A wooden frame stands in the square, its holes meant for hands and head. Townsfolk gather to point and laugh at those who have earned a public lesson.\r\n\r\n'Step too far and you'll find yourself bound in the stocks.'\r\n[Press any key]\r\n"
    .byte 0
archery_msg:
    .text "\r\nARCHERY RANGE: Targets line the field. Bowstrings twang as archers test their aim. A small contest awards prizes for accuracy.\r\n\r\n'Try your hand at the target and earn a token of skill.'\r\n[Press any key]\r\n"
    .byte 0
ax_throw_msg:
    .text "\r\nAX THROWING PIT: Stout logs wait as challengers toss axes for sport. Test your strength and precision—watch your footing.\r\n\r\n'Land your axe cleanly and the crowd will cheer.'\r\n[Press any key]\r\n"
    .byte 0
jail_msg:
    .text "\r\nTOWN JAIL: Rusted bars and a bored jailer. Some come here by accident, others by design. Keep your nose clean, traveller.\r\n\r\n'No tavern tales in here, just quiet and stone.'\r\n[Press any key]\r\n"
    .byte 0
detained_stocks_msg:
    .text "\r\nA guard clamps you into the stocks. You are held fast and cannot leave for a time.\r\nPress any key to wait.\r\n"
    .byte 0
detained_jail_msg:
    .text "\r\nThe jailer locks the iron door. You are confined in the town jail and cannot leave for a while.\r\nPress any key to wait.\r\n"
    .byte 0
post_office_msg:
    .text "\r\nPOST OFFICE: Stamps, letters, and parcels. Send a message to a distant friend or collect a waiting package.\r\n\r\n'Address it clearly, and it may find its way.'\r\n[Press any key]\r\n"
    .byte 0
mine_msg:
    .text "\r\nMINE ENTRANCE: A gaping shaft yawns here, the air cool and damp. Miners' tools lie scattered; the mine mouth promises ore and risk.\r\n\r\n'Descend and try your luck — but mind your footing.'\r\n[Press any key]\r\n"
    .byte 0
mine_menu_msg:
    .text "\r\nMINE: What do you want to do?\r\n1) Mine for ore\r\n0) Leave\r\n> "
    .byte 0
mine_no_ore_msg:
    .text "\r\nYou chip at the rock but find nothing of value.\r\n[Press any key]\r\n"
    .byte 0
mine_copper_msg:
    .text "\r\nYou pry free a vein of copper ore and stash it away.\r\n[Press any key]\r\n"
    .byte 0
mine_iron_msg:
    .text "\r\nYou strike iron and haul it back to the surface.\r\n[Press any key]\r\n"
    .byte 0
mine_silver_msg:
    .text "\r\nA flash of silver! You pocket the glinting ore carefully.\r\n[Press any key]\r\n"
    .byte 0
mine_gem_msg:
    .text "\r\nAmong the rocks you find a rough gem — a lucky find indeed.\r\n[Press any key]\r\n"
    .byte 0
food_east_menu_msg:
    .text "\r\nFood Court - Full Meal:\r\n1) Buy Meal (8 gold, restores 8 stamina)\r\n0) Leave\r\n> "
    .byte 0
food_east_thanks_msg:
    .text "\r\nYou eat a hearty meal and feel refreshed.\r\n[Press any key]\r\n"
    .byte 0
food_west_menu_msg:
    .text "\r\nFood Court - Light Meal:\r\n1) Buy Soup (4 gold, restores 4 stamina)\r\n0) Leave\r\n> "
    .byte 0
food_west_thanks_msg:
    .text "\r\nThe warm soup restores some of your energy.\r\n[Press any key]\r\n"
    .byte 0
foodcourt_no_gold_msg:
    .text "\r\nYou don't have enough gold for that meal.\r\n[Press any key]\r\n"
    .byte 0
mine_tired_msg:
    .text "\r\nYou are too tired to dig. Rest up before attempting more mining.\r\n[Press any key]\r\n"
    .byte 0
quarry_msg:
    .text "\r\nGEM QUARRY: The quarry yawns with rocky shelves and glittering veins. Miners tap at seams searching for rough gems to be cut and set.\r\n\r\n'Careful now — the quarry yields both common and rare stones.'\r\n[Press any key]\r\n"
    .byte 0
quarry_menu_msg:
    .text "\r\nGEM QUARRY: 1) Dig for gems\r\n0) Leave\r\n> "
    .byte 0
quarry_no_ore_msg:
    .text "\r\nYou search the seams but find only common rock.\r\n[Press any key]\r\n"
    .byte 0
quarry_common_gem_msg:
    .text "\r\nYou unearth a rough gem and carefully pocket it.\r\n[Press any key]\r\n"
    .byte 0
quarry_rare_gem_msg:
    .text "\r\nYou strike something that flashes with inner fire — a rare gem! Handle with care.\r\n[Press any key]\r\n"
    .byte 0
lezule_msg:
    .text "\r\nLezule the Fairy hovers before you, sweet and shy. 'Welcome, traveler. We guard the stolen names here... the Unseely Fae would have them all.'\r\n\r\n(Quest: Help Lezule protect a stolen name from the Unseely Fae.)\r\n"
    .byte 0
marmalade_msg:
    .text "\r\nMarmalade flits about in a frenzy, fiery orange hair blazing! 'Ha! Care to join our mischief? The Pumpkin King demands tribute!'\r\n\r\nPrank Quest Chain:\r\n1. Swap hats with the scarecrow in the field\r\n2. Dance a merry jig with a woodland fox\r\n3. Bow before the grand Pumpkin carving\r\n\r\n(Quest: Complete all three pranks for Marmalade's blessing.)\r\n"
    .byte 0
marigold_msg:
    .text "\r\nMarigold, adorned in shimmering gold, stirs her tiny cauldron. 'My potion of mischief needs ingredients!'\r\n\r\nPotion Quest Chain:\r\n1. Gather moonlit dewdrops from the garden\r\n2. Find caramel apple essence from the festival\r\n3. Collect a whispered secret from the wind\r\n\r\n(Quest: Gather ingredients - one sip makes you dance!)\r\n"
    .byte 0
butterscotch_msg:
    .text "\r\nButterscotch stands apart, kind eyes filled with concern. 'My name doesn't start with M, so I can't join my sisters. But I've found another path - befriending the humans.'\r\n\r\nAlliance Quest Chain:\r\n1. Help tend crops at the nearby farmstead\r\n2. Whisper encouragement to the harvest\r\n3. Earn the Pumpkin King's recognition\r\n\r\n(Quest: Bridge the divide between fairy and human.)\r\n[Press any key]\r\n"
    .byte 0
town_arena_msg:
    .text "\r\nThe ARENA thunders with the roar of the crowd. Sand stained with countless battles. Champions are forged here in blood and glory.\r\n\r\n'Step into the ring if you dare!'\r\n[Press any key]\r\n"
    .byte 0

circus_intro_msg:
    .text "\r\nThe CIRCUS TENT smells of sawdust and candy. Bright banners flap as performers practice in the ring.\r\n\r\n'Mind your step and mind your pockets!'\r\n[Press any key]\r\n"
    .byte 0
circus_play_msg:
    .text "\r\nWould you like to try the Juggler's Challenge?\r\n1. Play (small reward)\r\n0. Leave\r\n> "
    .byte 0
circus_win_msg:
    .text "\r\nYou catch every ball! The crowd showers you with applause and a handful of coins.\r\n[Press any key]\r\n"
    .byte 0
circus_lose_msg:
    .text "\r\nThe juggler sneers as you fumble — better practice!\r\n[Press any key]\r\n"
    .byte 0
pirate_ship_msg:
    .text "\r\nThe BLACK SIREN rocks at anchor, her dark sails furled. This is Captain Pit Plum's vessel - where rogues trade tales of plunder.\r\n"
    .byte 0
pit_plum_msg:
    .text "\r\nCaptain Pit Plum eyes you from the deck of the Black Siren. 'So ye want to be a part-time pirate, eh? Mage Damon himself trained under me!'\r\n\r\nPirate's Trials Quest Chain:\r\n1. Make a trade for gold at the nearby port\r\n2. Find hidden flags across distant islands\r\n3. Collect mysterious objects for the ship\r\n4. Learn combat from Captain Shadow Ford\r\n\r\n'Complete these tasks and ye'll earn a place among me crew!'\r\n\r\n(Quest: Prove yourself worthy of the Black Siren.)\r\n[Press any key]\r\n"
    .byte 0
bonny_boots_msg:
    .text "\r\nBonny Red Boots draws her fiddle, her vibrant red boots clacking on the deck. She was known as Dashing Daren's contact - the very composer of the pirate songs.\r\n\r\n'Fancy a song, sailor? The Last Shackle - a slaver ship turned to freedom! A prisoner poisoned the guards with fancy wine, and the captives left not a slaver alive!'\r\n\r\n'Come all ye pirates, ye bold and true... Come board the Last Shackle, she's waiting for you!'\r\n\r\nSong Quest Chain:\r\n1. Learn the full ballad of the Last Shackle\r\n2. Spread the song across taverns of Everland\r\n3. Find the legendary freed prisoners\r\n4. Join Bonny's fiddle performance\r\n\r\n(Quest: Master Bonny's song of freedom!)\r\n[Press any key]\r\n"
    .byte 0
shadow_ford_msg:
    .text "\r\nCaptain Shadow Ford emerges from the secluded cove, exuding prowess and mystery. He and Fletcher share a common love of archery.\r\n\r\n'You seek knowledge? First, shed your gear and outer clothing - to move freely, shed unnecessary weight.'\r\n\r\nCombat Training Quest:\r\n1. Master footwork - the dance of combat, precise and agile\r\n2. Learn parrying - your sword is an extension of will\r\n3. Practice until moonrise in the cleared cove\r\n4. Earn Shadow Ford's nod of approval\r\n\r\n'Perhaps one day you shall be a force to be reckoned with on the high seas.'\r\n\r\n(Quest: Train with the legendary combat master.)\r\n[Press any key]\r\n"
    .byte 0
tower_msg:
    .text "\r\nThe TOWER pierces the clouds, its peak lost in mist. Within, the Order of the Owls convenes - wise souls united by friendship.\r\n"
    .byte 0
owls_msg:
    .text "\r\nGarrett, in symbolic knight's attire, welcomes you. 'The Order of the Owls - wise and intrepid souls united! I proposed the owl as our emblem for collective wisdom.'\r\n\r\nFletcher practices archery nearby, sometimes mistaken for 'Archer' by absent-minded mages. Shadow Ford and Fletcher share a common love of the bow. Poppy, in lavish Victorian attire, offers to sponsor the feast at the Dining Hall.\r\n\r\nOwl Initiation Quest:\r\n1. Walk the circular path around town\r\n2. Prove your wisdom to Garrett\r\n3. Earn Fletcher's respect at archery\r\n4. Attend Poppy's inaugural feast\r\n\r\n(Quest: Join the Order of the Owls!)\r\n[Press any key]\r\n"
    .byte 0
church_msg:
    .text "\r\nThe CHURCH stands serene, stained glass casting rainbow light across wooden pews. A choir's distant hymn echoes from the bell tower.\r\n"
    .byte 0
cordelia_church_msg:
    .text "\r\nBishop Cordelia, legendary knight turned holy woman, tends the altar. 'I once wielded a blade for Lore. Now I wield faith.'\r\n\r\n'The Order of the Black Rose stands for honor and memory. Will you swear the green thorn oath?'\r\n\r\n(Quest: Receive Cordelia's blessing and take the knight's oath.)\r\n"
    .byte 0
cedric_msg:
    .text "\r\nCedric, the young knight, kneels in prayer. His eyes hold hard-won wisdom.\r\n\r\n'At the witching hour, Kasimere invaded my dreams. His crystal globe resonated with the dark sun crystal, whispering promises of power and glory.'\r\n\r\n'But Mage Damon wove a protective barrier around my mind. Lady Cordelia confronted me with the truth of Kasimere's treachery.'\r\n\r\nRedemption Quest Chain:\r\n1. Confess your moment of weakness\r\n2. Face Kasimere's lair with the defenders\r\n3. Sever the dark crystal's hold\r\n4. Swear renewed oath to the Order\r\n\r\n(Quest: Help Cedric complete his redemption.)\r\n[Press any key]\r\n"
    .byte 0
catacombs_msg:
    .text "\r\nThe CATACOMBS stretch beneath the Moselem - endless tunnels of bones and shadow. Torches flicker against walls lined with the ancient dead.\r\n"
    .byte 0
samuel_msg:
    .text "\r\nSamuel wheels his wooden cart through darkness. When the town vanished, only he and Mage Damon remained.\r\n\r\n'Mage Damon made me his apprentice. Want to learn to activate your THIRD EYE?'\r\n\r\nPendulum Ritual Quest:\r\n1. Find your focal point - between hairline and brow, back 2 inches\r\n2. Hold the pendulum still, observe your breathing\r\n3. Command it to spin with your mind, not your hand\r\n4. Master spinning it both directions - proving you control it\r\n\r\n'With experience, I can spin it nearly horizontal. You will get there!'\r\n\r\n(Quest: Learn the pendulum ritual from Samuel.)\r\n[Press any key]\r\n"
    .byte 0
statue_michael_msg:
    .text "\r\nThe STATUE OF MICHAEL towers over the plaza - a bronze figure with sword raised against the darkness. Flowers lay at its base.\r\n\r\n'He gave everything to protect Everland. We remember.'\r\n[Press any key]\r\n"
    .byte 0
marketplace_msg:
    .text "\r\nThe MARKETPLACE buzzes with commerce. Stalls overflow with goods from every realm. Merchants haggle, thieves lurk, and fortunes change hands.\r\n"
    .byte 0
bridge_troll_msg:
    .text "\r\nBridge the Troll lurks near a stall, twirling Kevin - his club with a menacing skull. 'Ah, friend! Care to swap some trinkets? Kevin here says you look absolutely revolting!' (He means it kindly.)\r\n\r\n(Quest: Trade a trinket with Bridge for something unexpected.)\r\n[Press any key]\r\n"
    .byte 0

// Witch's Tent (within Town of Everland)
portal_witch_msg:
    .text "\r\nAt the edge of town, you find the WITCH'S TENT. Smoke curls from a crooked chimney. Herbs hang drying from the ceiling, and cauldrons bubble with mysterious brews.\r\n\r\nThe air smells of sage, moonflower, and something... otherworldly.\r\n"
witch_npc_menu_msg:
    .text "\r\nWITCH'S TENT:\r\n1. Speak to Tammis\r\n2. Speak to Saga\r\n3. Browse Potions\r\n4. Back to Town\r\n5. Mystic Crafting\r\n6. Spell Research\r\n\r\nLore: Twin witches who see past and future, bound by sisterhood and ancient craft.\r\n> "
    .byte 0

// Hunter's Hovel (Winter Wolves territory)
hunters_hovel_msg:
    .text "\r\nHUNTER'S HOVEL lies at the edge of town. In warm months, noble knights gather here. In winter, the Wolves of Winter claim this territory.\r\n"
    .byte 0
wulfric_hovel_msg:
    .text "\r\nAlpha Wulfric Vassa stands before you, golden eyes gleaming. Beta Lyra negotiated with Van Bueler - provisions for protection.\r\n\r\n'The Pact of Winter's Howl binds wolf and human. Each frost-laden evening, we gather to renew our vows.'\r\n\r\nTrial Quest Chain:\r\n1. Endure the biting cold without shelter\r\n2. Outwit the cunning riddles of the pack\r\n3. Brave the harshest wilderness paths\r\n4. Join the moonlit howl when the train rumbles by\r\n\r\n(Quest: Complete all trials to earn the pack's trust.)\r\n[Press any key]\r\n"
    .byte 0

// The Burrows (Frost Weaver gathering place)
burrows_msg:
    .text "\r\nTHE BURROWS - ancient halls where the Frost Weavers convene. Ice crystals glitter on stone walls. The air crackles with elemental power.\r\n"
    .byte 0
frost_queen_msg:
    .text "\r\nThe Frost Weaver Queen beckons as the snowy storm rages outside. 'In the tradition of witches, wizards, and sages who protected Aurora for centuries, our duty falls onto you.'\r\n\r\n'Bring your fingers together...'\r\n\r\nInitiation Ritual:\r\n1. GLACIOUS - ice at your fingertips to fight enemies\r\n2. NIX - flowy drifts of snow to ensnare foes\r\n3. ILLUMINA - be a light in darkness, a beacon in storm\r\n\r\n'May all magic join with yours and yours with ours. Welcome to the Frost Weavers!'\r\n\r\n(Quest: Learn your first frost spell.)\r\n[Press any key]\r\n"
    .byte 0

// Mystic's Tent (Mela, Kal, Daemos - secretly vampires!)
mystics_tent_msg:
    .text "\r\nTHE MYSTIC'S TENT draws seekers of forbidden knowledge. Incense smoke swirls around crystal balls and ancient scrolls.\r\n"
    .byte 0

; --- Mystic crafting/research messages ---
mystic_craft_menu_msg:
    .text "\r\nMYSTIC CRAFTING:\r\n1) Craft Spell Scroll (1 Gem + 1 Leather)\r\n2) Craft Magic Trinket (2 Gems + 1 Leather)\r\n0) Back\r\n> "
    .byte 0

craft_scroll_success_msg:
    .text "\r\nYou inscribe arcane runes into a Spell Tome.\r\n[Press any key]\r\n"
    .byte 0

craft_trinket_success_msg:
    .text "\r\nYou assemble a small enchanted trinket.\r\n[Press any key]\r\n"
    .byte 0

mystic_insuf_msg:
    .text "\r\nYou lack the required materials.\r\n[Press any key]\r\n"
    .byte 0

research_menu_msg:
    .text "\r\nSPELL RESEARCH:\r\nCost: 20 gold. Chance to discover a Spell Tome.\r\n1) Research (20g)\r\n0) Back\r\n> "
    .byte 0

research_success_msg:
    .text "\r\nYour research yields a new fragment of power!\r\n[Press any key]\r\n"
    .byte 0

research_fail_msg:
    .text "\r\nThe ritual fails; the gold is spent.\r\n[Press any key]\r\n"
    .byte 0
mela_msg:
    .text "\r\nMela regards you with beguiling charisma and ethereal grace. Her enchanting presence promises transcendence beyond mortal existence.\r\n\r\n'I sent Mage Damon to seek Torin of the Unseely Fae... for forbidden knowledge.' Kal whispers promises of power. Daemos watches from shadows.\r\n\r\n(Warning: Experiments with Kasimere's ashes and necromancy transformed them into vampires!)\r\n\r\nTemptation Quest Chain:\r\n1. Resist their promises of immortality\r\n2. Uncover their vampiric nature\r\n3. Expose Daemos's schemes for the Spider Princess\r\n4. Choose: Join them or destroy them\r\n\r\n(Quest: Unravel the mystics' dark covenant.)\r\n[Press any key]\r\n"
    .byte 0

// Central Plaza with Spider Princess
central_plaza_msg:
    .text "\r\nThe CENTRAL PLAZA bustles with life. A grand fountain sparkles at the center. Merchants, performers, and travelers mingle beneath colorful awnings.\r\n\r\nThis is the heart of Everland, where all paths converge.\r\n"
    .byte 0
spider_princess_msg:
    .text "\r\nThe Spider Princess holds court near the fountain, her silken gown shimmering. Tiny spiders dance at her feet.\r\n\r\n'Mage Damon drew ambient magic into his third eye, but his body could not hold such power. He cast it into the headpiece I gave him - and was transformed!'\r\n\r\n'He became a conduit, a vessel overflowing with untapped power.'\r\n\r\nSpider Quest Chain:\r\n1. Befriend the dancing spiders\r\n2. Learn the way of the web\r\n3. Receive a magical artifact gift\r\n4. Channel power through the spider's blessing\r\n\r\nDamian shares our love of spiders. Perhaps you seek such a gift?\r\n\r\n(Quest: Win the Spider Princess's favor.)\r\n"
    .byte 0
kora_kendrick_msg:
    .text "\r\nKora and Kendrick, steadfast knights from Lore, stand vigilant guard. The fractures disoriented the Spider Princess, but their oath remains unbroken.\r\n\r\nKora speaks: 'The fractures brought chaos - the ground shifts like sand beneath our feet. But we swore to protect her.'\r\n\r\nKendrick nods grimly: 'Dante contains the rifts, but the Candy Witch tears his wards. The ghost pirates target our princess in their twisted games.'\r\n\r\nGuardian Quest Chain:\r\n1. Strengthen the protective perimeter\r\n2. Track ghost pirate movements\r\n3. Counter the Candy Witch's sabotage\r\n4. Escort the Spider Princess to safety\r\n\r\n(Quest: Aid the guardians against the fracture's chaos.)\r\n[Press any key]\r\n"
    .byte 0

// The Bridge - Bridge the Troll's home
the_bridge_msg:
    .text "\r\nYou descend to THE BRIDGE - an old stone arch spanning the river. Water gurgles below. Trinkets and oddities decorate a cozy hollow beneath the stones.\r\n"
    .byte 0
bridge_home_msg:
    .text "\r\nBridge lounges in his cozy hollow beneath the old stone bridge, twirling Kevin - his skull-tipped club and closest confidant.\r\n\r\n'Ah, you look absolutely revolting!' (He means it kindly.) 'What mischief shall we conjure today, Kevin?'\r\n\r\nThe townsfolk know his strange manners. 'I'm just terrible' means he's well.\r\n\r\nMischief Quest Chain:\r\n1. Swap trinkets at the marketplace\r\n2. Spread playful chaos in town\r\n3. Learn Bridge's hauntingly off-key tune\r\n4. Join Kevin's midnight tribunal of oddities\r\n\r\n(Quest: Trade trinkets or join the mischief!)\r\n[Press any key]\r\n"
    .byte 0

// Dante and Candy Witch - guardians of the fractures
dante_msg:
    .text "\r\nDante, wreathed in arcane sigils, maintains shimmering wards against the fractures. In his hand, a bottle swirls with spectral mist - cursed ghost pirates imprisoned within.\r\n\r\n'The Spider Princess arrived disoriented from her journey. Kora and Kendrick protect her, but the fractures expand. The ghost pirates delight in targeting her as part of their twisted games.'\r\n\r\nFracture Quest Chain:\r\n1. Gather ward components from the realms\r\n2. Confront the Candy Witch's sabotage\r\n3. Seal the ghost pirates' bottle permanently\r\n4. Restore balance between worlds\r\n\r\n(Quest: Help contain the ever-expanding fracture.)\r\n[Press any key]\r\n"
    .byte 0
candy_witch_msg:
    .text "\r\nThe CANDY WITCH lurks at reality's edge - gown of spun sugar, laughter sickeningly sweet. Her candy-coated claws tear at Dante's wards with gleeful destruction.\r\n\r\n'Why mend what can be broken? Chaos is so much sweeter! The ghost pirates adore me - together we'll unravel everything!'\r\n\r\nChaos Quest Chain:\r\n1. Track her through the fractures\r\n2. Resist her sweet temptations\r\n3. Sever her bond with the ghost pirates\r\n4. Seal her in crystallized sugar\r\n\r\n(Quest: Stop her relentless destruction of the wards!)\r\n[Press any key]\r\n"
    .byte 0

// The Damsel of the Mist - Hope of Light
damsel_mist_msg:
    .text "\r\nA mysterious DAMSEL emerges from the magic forest of mist, her gown woven from lion's fur and moonlit tapestry. A blue light dances at her fingertips.\r\n\r\n'On muddy roads to Everland, the blue glow held true - a beacon through the tangled veil. Forces pressed from every side, but love burns bright!'\r\n\r\n'The lion of the muddy road tore at my gown, but I lifted my sword with fearless grace and wove a radiant new garment from the wild omen.'\r\n\r\nDestiny Quest Chain:\r\n1. Follow the blue light through the mist\r\n2. Face the lion of the muddy road\r\n3. Weave your courage into a radiant garment\r\n4. Find the Damon of your Dreams\r\n\r\n(Quest: Help the Damsel fulfill her destiny.)\r\n[Press any key]\r\n"
    .byte 0

// Kira's Apothecary - First Love, First Light
kira_apothecary_msg:
    .text "\r\nKIRA'S APOTHECARY - The bell chimes as you enter. Shelves of powders, waters, and salves line the walls. The scent of lavender and citrus fills the air.\r\n"
    .byte 0
kira_msg:
    .text "\r\nKira stands behind the counter, hair like newly spun gold, hands dusted with dried petals. Her smile is warm - the kind that makes aches feel remote.\r\n\r\n'Welcome, Mr. Damon! Balm of Quick Mend for wounds, Oil of Orchid for massages... or perhaps just a moment of care?'\r\n\r\nShe whispers: 'I too am an aspiring magic-user - small charms, healing threads, sachets for restless spirits.'\r\n\r\nFirst Light Quest Chain:\r\n1. Accept healing for your wounds\r\n2. Experience the massage table with scented oils\r\n3. Share stories of magic and craft\r\n4. Return at dusk when the lamp is lit\r\n\r\n'We'll call it mutual craft - you mend quarrels, I mend weariness.'\r\n\r\n(Quest: Return at dusk to speak of other matters.)\r\n[Press any key]\r\n"
    .byte 0
apothecary_menu_msg:
    .text "\r\nKIRA'S APOTHECARY - Crafting Table:\r\n1) Healing Potion (1 Gem + 1 Berry)\r\n2) Poison (1 Meat + 1 Berry)\r\n0) Leave\r\n> "
    .byte 0
craft_heal_success_msg:
    .text "\r\nYou carefully distill the ingredients into a small vial. A warm light emanates from the liquid.\r\n[Press any key]\r\n"
    .byte 0
craft_poison_success_msg:
    .text "\r\nYou brew a foul tincture. The smell makes your head swim. Handle with care.\r\n[Press any key]\r\n"
    .byte 0
apothecary_insuf_msg:
    .text "\r\nKira shakes her head. 'You lack the proper ingredients.'\r\n[Press any key]\r\n"
    .byte 0

// === THE STAGE - GREG THE FIRE DANCER MESSAGES ===
the_stage_msg:
    .text "\r\nTHE STAGE - An open-air amphitheater at the edge of Everland. Torches ring the circular platform, their flames dancing in the evening breeze. Wooden benches fan outward, filled with mesmerized onlookers.\r\n\r\nThe scent of lamp oil and wood smoke mingles with the excitement of the crowd.\r\n"
    .byte 0
greg_dancer_msg:
    .text "\r\nAt center stage stands GREG THE FIRE DANCER - a lithe figure with sun-bronzed skin and eyes that reflect the flames he commands. His hands trace arcs of fire through the air, twin torches spinning in hypnotic patterns.\r\n\r\n'Welcome, traveler! Stay and witness the dance of the eternal flame!'\r\n\r\nHis movements are fluid as water yet fierce as the fire itself. Sparks trail behind each gesture like falling stars.\r\n"
    .byte 0
stage_menu_msg:
    .text "\r\nTHE STAGE:\r\n1. Watch the fire dance\r\n2. Talk to Greg\r\n3. Leave a tip\r\n0. Return to Town\r\n> "
    .byte 0
fire_dance_msg:
    .text "\r\nGreg steps to the center of the stage. The crowd falls silent.\r\n\r\n*WHOOOOSH* - Twin flames erupt as he ignites fresh torches!\r\n\r\nHe spins, trails of fire painting spirals in the darkness. The flames seem to dance with a life of their own - rising, falling, weaving between his fingers.\r\n\r\n*FWOOOMP* - A great arc of fire leaps overhead!\r\n\r\nThe crowd gasps as he catches a falling torch behind his back. His movements quicken - faster, brighter, until he becomes a blur of orange and gold.\r\n\r\n*CRACKLE* *POP* *HISSSSSS*\r\n\r\nWith a final flourish, he extinguishes both torches in his bare hands. Smoke curls upward as the crowd erupts in applause!\r\n\r\n'The fire is my partner - we dance together or not at all!'\r\n[Press any key]\r\n"
    .byte 0
greg_talk_msg:
    .text "\r\nGreg wipes sweat from his brow, torches momentarily at rest.\r\n\r\n'I learned the fire dance from the wandering performers of the Southern Isles. They say fire has a spirit - wild, hungry, beautiful. If you respect it, it becomes your ally.'\r\n\r\nHe smiles, flames reflecting in his eyes.\r\n\r\n'I've performed from Dragon Haven to the Fairy Gardens. The wolves at Hunter's Hovel even howl along with my drums! But here, at The Stage... this is home.'\r\n\r\n'Some say magic lives in spells and wands. I say it lives wherever passion burns bright.'\r\n[Press any key]\r\n"
    .byte 0
no_tip_msg:
    .text "\r\nYou reach for your coin purse, but find it empty. Greg notices and waves a hand.\r\n\r\n'No matter, friend! Your presence warms me more than any coin. Come back when fortune smiles upon you!'\r\n[Press any key]\r\n"
    .byte 0
tip_thanks_msg:
    .text "\r\nYou toss a coin toward the stage. Greg catches it with a flourish, making it disappear in a puff of flame!\r\n\r\n'Many thanks, generous soul! May your path be lit by friendly fires, and may the cold never find you!'\r\n\r\nHe bows deeply, flames dancing in appreciation.\r\n[Press any key]\r\n"
    .byte 0

tammis_msg:
    .text "\r\nTammis, the Nordic witch, stirs her cauldron with enchanting grace. She and her sister Saga blend earthy wisdom with otherworldly allure.\r\n\r\n'We see within you the flickering embers of magic. Your staff, your crystal, the energy around you - it speaks of destiny waiting to unfurl.'\r\n\r\nEnchantment Quest Chain:\r\n1. Learn ancient runes from the sisters\r\n2. Understand your staff's lineage and potential\r\n3. Weave magic into everyday artifacts\r\n4. Awaken the power slumbering within\r\n\r\n'Everland holds ancient secrets, and you are uniquely tied to them.'\r\n\r\n(Quest: Unlock your latent magical abilities.)\r\n[Press any key]\r\n"
    .byte 0
saga_msg:
    .text "\r\nSaga gazes into her crystal sphere, her voice resonant with ancient wisdom. Her Nordic lineage shows in every graceful movement.\r\n\r\n'The future is not fixed. I see many paths... In Tammis, you found an anchor. Together we unearthed secrets of your staff - how it chose you.'\r\n\r\nProphecy Quest Chain:\r\n1. Gather three prophecy fragments from the realms\r\n2. Spend endless nights crafting spells with Tammis\r\n3. Turn creations into vessels for arcane energy\r\n4. Complete your extraordinary journey into mysticism\r\n\r\n'The boundaries between mundane and arcane blur here.'\r\n\r\n(Quest: Reveal your destiny.)\r\n[Press any key]\r\n"
    .byte 0
witch_potions_msg:
    .text "\r\nPOTIONS FOR SALE:\r\n- Healing Draught (10g): Restore 20 HP\r\n- Fortune Elixir (25g): Double next gold find\r\n- Shadow Veil (50g): Escape any battle\r\n[Press any key]\r\n"
    .byte 0

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
    .text "\r\nArch Magus Kasimere, the oldest vampire, lurks in shadows. He followed through the portal as it closed, a snarled laugh on his lips.\r\n\r\n'Soon we will conquer this land also,' he rasps. His crystal globe resonates with the dark sun crystal, reaching into dreams with whispered promises of power.\r\n\r\nVampire Conflict Quest:\r\n(H)elp Kasimere - join his dark dominion\r\n(B)etray Kasimere - expose his treachery\r\n\r\nWarning: He corrupts refugees with foggy memories, turning them into servants. Will you resist or succumb?\r\n\r\nKasimere: Will you (H)elp or (B)etray me? "

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
    .text "\r\nThe PUMPKIN KING towers before you, eyes glowing unearthly orange. His sinister laughter echoes through the cursed garden.\r\n\r\n'Bow before me, mortal! My fairies spread chaos in my name. The thorny plants obey my will. Your knights cannot stand against me!'\r\n\r\nQuest Chain:\r\n1. Gather spider allies (speak to Spider Princess)\r\n2. Rally the knights of Lore\r\n3. Obtain the enchanted spear from Grim\r\n4. Launch coordinated attack\r\n\r\n(F)ight or (N)egotiate? "

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

// === MESSAGE BOARD SYSTEM ===
message_board:
    ldx #0
msg_board_hdr_loop:
        lda msg_board_hdr_msg,X
        beq msg_board_show_posts
        jsr modem_out
        inx
        bne msg_board_hdr_loop
msg_board_show_posts:
    // Display existing messages (from buffer)
    lda msg_board_count
    beq msg_board_empty
    // Show up to 5 messages
    ldx #0
    stx msg_display_idx
msg_show_next:
    ldx msg_display_idx
    cpx msg_board_count
    bcs msgb_show_prompt
    // Show message number
    txa
    clc
    adc #'1'
    jsr modem_out
    lda #'.'
    jsr modem_out
    lda #' '
    jsr modem_out
    // Show author (8 chars)
    lda msg_display_idx
    asl
    asl
    asl
    asl       // *16 = offset
    tax
    ldy #0
msg_author_loop:
        lda msg_board_data,X
        beq msg_author_done
        jsr modem_out
        inx
        iny
        cpy #8
        bcc msg_author_loop
msg_author_done:
    lda #':'
    jsr modem_out
    lda #' '
    jsr modem_out
    // Show message (8 chars)
    lda msg_display_idx
    asl
    asl
    asl
    asl
    clc
    adc #8
    tax
    ldy #0
msg_text_loop:
        lda msg_board_data,X
        beq msg_text_done
        jsr modem_out
        inx
        iny
        cpy #8
        bcc msg_text_loop
msg_text_done:
    lda #13
    jsr modem_out
    inc msg_display_idx
    jmp msg_show_next
msg_board_empty:
    ldx #0
msg_empty_loop:
        lda msg_empty_msg,X
        beq msgb_show_prompt
        jsr modem_out
        inx
        bne msg_empty_loop
msgb_show_prompt:
    ldx #0
msgb_prompt_loop:
        lda msg_prompt_msg,X
        beq msg_get_input
        jsr modem_out
        inx
        bne msgb_prompt_loop
msg_get_input:
    jsr modem_in
    cmp #'1'
    beq msg_post_new
    cmp #'2'
    beq msg_delete_own
    cmp #'0'
    bne msg_get_input
    jmp main_loop
msg_post_new:
    // Check if board full
    lda msg_board_count
    cmp #5
    bcc msg_can_post
    ldx #0
msg_full_loop:
        lda msg_full_msg,X
        beq msg_board_wait
        jsr modem_out
        inx
        bne msg_full_loop
msg_board_wait:
    jsr modem_in
    jmp message_board
msg_can_post:
    ldx #0
msg_compose_loop:
        lda msg_compose_msg,X
        beq msg_read_text
        jsr modem_out
        inx
        bne msg_compose_loop
msg_read_text:
    // Simple: read 8 chars
    lda msg_board_count
    asl
    asl
    asl
    asl
    clc
    adc #8       // Skip author field, go to text
    tax
    ldy #0
msg_input_loop:
    jsr modem_in
    cmp #13
    beq msg_input_done
    sta msg_board_data,X
    inx
    iny
    cpy #8
    bcc msg_input_loop
msg_input_done:
    // Store author from user_name
    lda msg_board_count
    asl
    asl
    asl
    asl
    tax
    ldy #0
msg_copy_author:
        lda user_name,Y
        sta msg_board_data,X
        inx
        iny
        cpy #8
        bcc msg_copy_author
    inc msg_board_count
    ldx #0
msg_posted_loop:
        lda msg_posted_msg,X
        beq msg_posted_done
        jsr modem_out
        inx
        bne msg_posted_loop
msg_posted_done:
    jsr modem_in
    jmp message_board
msg_delete_own:
    // Clear last message (simple delete)
    lda msg_board_count
    beq msg_board_wait
    dec msg_board_count
    ldx #0
msg_deleted_loop:
        lda msg_deleted_msg,X
        beq msg_board_wait
        jsr modem_out
        inx
        bne msg_deleted_loop

msg_board_count: .byte 2  // Start with 2 sample messages
msg_display_idx: .byte 0
msg_board_data:
    .text "ADMIN   "      // Author 1
    .text "WELCOME!"      // Message 1
    .text "SYSOP   "      // Author 2
    .text "HAVE FUN"      // Message 2
    .fill 48, 0           // Space for 3 more messages
msg_board_hdr_msg:
    .text "\r\n=== MESSAGE BOARD ===\r\n\r\n"
    .byte 0
msg_empty_msg:
    .text "(No messages yet)\r\n"
    .byte 0
msg_prompt_msg:
    .text "\r\n1. Post Message\r\n2. Delete Last\r\n0. Back\r\n> "
    .byte 0
msg_full_msg:
    .text "\r\nBoard full! Delete old messages first.\r\n[Press any key]\r\n"
    .byte 0
msg_compose_msg:
    .text "\r\nEnter message (8 chars max): "
    .byte 0
msg_posted_msg:
    .text "\r\nMessage posted!\r\n[Press any key]\r\n"
    .byte 0
msg_deleted_msg:
    .text "\r\nLast message deleted.\r\n[Press any key]\r\n"
    .byte 0

// === ASYNC PVP (GHOST BATTLES) ===
async_pvp:
    ldx #0
pvp_menu_loop:
        lda pvp_menu_msg,X
        beq pvp_show_stats
        jsr modem_out
        inx
        bne pvp_menu_loop
pvp_show_stats:
    // Show player rating
    ldx #0
pvp_rating_loop:
        lda pvp_rating_msg,X
        beq pvp_rating_num
        jsr modem_out
        inx
        bne pvp_rating_loop
pvp_rating_num:
    lda ghost_rating
    jsr print_byte_decimal
    // Show wins/losses
    ldx #0
pvp_record_loop:
        lda pvp_record_msg,X
        beq pvp_show_wins
        jsr modem_out
        inx
        bne pvp_record_loop
pvp_show_wins:
    lda ghost_wins
    jsr print_byte_decimal
    lda #'/'
    jsr modem_out
    lda ghost_losses
    jsr print_byte_decimal
    ldx #0
pvp_prompt_loop:
        lda pvp_prompt_msg,X
        beq pvp_get_input
        jsr modem_out
        inx
        bne pvp_prompt_loop
pvp_get_input:
    jsr modem_in
    cmp #'1'
    beq pvp_fight_ghost
    cmp #'2'
    beq go_pvp_upload
    cmp #'3'
    beq go_pvp_view
    cmp #'0'
    bne pvp_get_input
    jmp main_loop
go_pvp_upload:
    jmp pvp_upload_ghost
go_pvp_view:
    jmp pvp_view_ghosts
pvp_fight_ghost:
    // Check if ghosts available
    lda ghost_count
    beq go_pvp_no_ghosts
    jmp pvp_has_ghosts
go_pvp_no_ghosts:
    jmp pvp_no_ghosts
pvp_has_ghosts:
    // Pick random ghost to fight
    jsr get_random
    and #$03
    cmp ghost_count
    bcc pvp_ghost_ok
    lda #0
pvp_ghost_ok:
    sta current_ghost
    ldx #0
pvp_challenge_loop:
        lda pvp_challenge_msg,X
        beq pvp_do_battle
        jsr modem_out
        inx
        bne pvp_challenge_loop
pvp_do_battle:
    // Simple battle - compare ratings
    lda ghost_rating
    sta $02
    lda current_ghost
    tax
    lda ghost_ratings,X
    sta $03
    jsr get_random
    and #$1F
    clc
    adc $02      // Your rating + random
    sta $02
    jsr get_random
    and #$1F
    clc
    adc $03      // Ghost rating + random
    cmp $02
    bcs pvp_lost
    // Won!
    inc ghost_wins
    lda ghost_rating
    clc
    adc #5
    sta ghost_rating
    lda player_gold
    clc
    adc #25
    sta player_gold
    ldx #0
pvp_won_loop:
        lda pvp_won_msg,X
        beq pvp_battle_done
        jsr modem_out
        inx
        bne pvp_won_loop
pvp_lost:
    inc ghost_losses
    lda ghost_rating
    sec
    sbc #3
    bcs pvp_rating_ok
    lda #50
pvp_rating_ok:
    sta ghost_rating
    ldx #0
pvp_lost_loop:
        lda pvp_lost_msg,X
        beq pvp_battle_done
        jsr modem_out
        inx
        bne pvp_lost_loop
pvp_battle_done:
    jsr modem_in
    jmp async_pvp
pvp_no_ghosts:
    ldx #0
pvp_no_ghosts_loop:
        lda pvp_no_ghosts_msg,X
        beq pvp_battle_done
        jsr modem_out
        inx
        bne pvp_no_ghosts_loop
pvp_upload_ghost:
    ldx #0
pvp_upload_loop:
        lda pvp_upload_msg,X
        beq pvp_upload_done
        jsr modem_out
        inx
        bne pvp_upload_loop
pvp_upload_done:
    // Save current player as ghost
    lda ghost_count
    cmp #4
    bcs pvp_ghosts_full
    tax
    lda ghost_rating
    sta ghost_ratings,X
    inc ghost_count
    ldx #0
pvp_uploaded_loop:
        lda pvp_uploaded_msg,X
        beq pvp_battle_done
        jsr modem_out
        inx
        bne pvp_uploaded_loop
pvp_ghosts_full:
    ldx #0
pvp_full_loop:
        lda pvp_ghosts_full_msg,X
        beq pvp_battle_done
        jsr modem_out
        inx
        bne pvp_full_loop
pvp_view_ghosts:
    ldx #0
pvp_ghosts_hdr_loop:
        lda pvp_ghosts_hdr_msg,X
        beq pvp_list_ghosts
        jsr modem_out
        inx
        bne pvp_ghosts_hdr_loop
pvp_list_ghosts:
    lda ghost_count
    beq pvp_no_ghosts
    ldx #0
pvp_ghost_list_loop:
    cpx ghost_count
    bcs pvp_battle_done
    txa
    clc
    adc #'1'
    jsr modem_out
    lda #'.'
    jsr modem_out
    lda #' '
    jsr modem_out
    lda ghost_ratings,X
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    inx
    jmp pvp_ghost_list_loop

ghost_rating: .byte 100   // Player's ghost rating
ghost_wins: .byte 0
ghost_losses: .byte 0
ghost_count: .byte 2      // Sample ghosts
current_ghost: .byte 0
ghost_ratings: .byte 90, 110, 0, 0  // Ratings for up to 4 ghosts
pvp_menu_msg:
    .text "\r\n=== ASYNC PVP ===\r\nBattle other players' ghosts!\r\n"
    .byte 0
pvp_rating_msg:
    .text "\r\nYour Rating: "
    .byte 0
pvp_record_msg:
    .text "\r\nWin/Loss: "
    .byte 0
pvp_prompt_msg:
    .text "\r\n\r\n1. Fight Ghost\r\n2. Upload Ghost\r\n3. View Ghosts\r\n0. Back\r\n> "
    .byte 0
pvp_challenge_msg:
    .text "\r\nFighting a ghost challenger...\r\n"
    .byte 0
pvp_won_msg:
    .text "\r\nVICTORY! +25 gold, +5 rating\r\n[Press any key]\r\n"
    .byte 0
pvp_lost_msg:
    .text "\r\nDefeat! -3 rating\r\n[Press any key]\r\n"
    .byte 0
pvp_no_ghosts_msg:
    .text "\r\nNo ghosts available!\r\n[Press any key]\r\n"
    .byte 0
pvp_upload_msg:
    .text "\r\nUploading your ghost...\r\n"
    .byte 0
pvp_uploaded_msg:
    .text "\r\nGhost uploaded! Others can now challenge you.\r\n[Press any key]\r\n"
    .byte 0
pvp_ghosts_full_msg:
    .text "\r\nGhost slots full!\r\n[Press any key]\r\n"
    .byte 0
pvp_ghosts_hdr_msg:
    .text "\r\n=== GHOST LIST ===\r\n"
    .byte 0

// === SAVE GAME SYSTEM ===
save_game:
    ldx #0
save_hdr_loop:
        lda save_hdr_msg,X
        beq save_confirm
        jsr modem_out
        inx
        bne save_hdr_loop
save_confirm:
    jsr modem_in
    cmp #'Y'
    beq save_slot_browser
    cmp #'y'
    beq save_slot_browser
    jmp main_loop
save_do_save:
    // Save to disk - use KERNAL routines
    lda #1       // File number
    ldx #8       // Device 8
    ldy #1       // Secondary address (write)
    jsr $FFBA    // SETLFS
    lda #10      // Filename length
    ; Choose filename based on autosave slot (alternate backups)
    lda autosave_slot
    cmp #0
    beq use_save0
    ldx #<save_filename_alt
    ldy #>save_filename_alt
    jmp do_setnam
use_save0:
    ldx #<save_filename
    ldy #>save_filename
do_setnam:
    jsr $FFBD    // SETNAM
    jsr $FFC0    // OPEN
    bcs go_save_error
    jmp save_write_data
go_save_error:
    jmp save_error
save_write_data:
    ldx #1
    jsr $FFC9    // CHKOUT
    // Write player data
    lda player_gold
    jsr $FFD2    // CHROUT
    lda player_gold+1
    jsr $FFD2
    lda player_hp
    jsr $FFD2
    lda player_level
    jsr $FFD2
    lda player_xp
    jsr $FFD2
    lda ghost_rating
    jsr $FFD2
    lda ghost_wins
    jsr $FFD2
    lda ghost_losses
    jsr $FFD2
    lda arena_wins
    jsr $FFD2
    lda arena_rank
    jsr $FFD2
    lda skill_combat
    jsr $FFD2
    lda skill_magic
    jsr $FFD2
    lda skill_social
    jsr $FFD2
    lda skill_survival
    jsr $FFD2
    lda skill_points
    jsr $FFD2
    lda dungeon_deepest
    jsr $FFD2
    // Close file
    jsr $FFCC    // CLRCHN
    lda #1
    jsr $FFC3    // CLOSE
    ldx #0
save_ok_loop:
        lda save_ok_msg,X
        beq save_done
        jsr modem_out
        inx
        bne save_ok_loop
save_done:
    jsr modem_in
    jmp main_loop
save_error:
    ldx #0
save_err_loop:
        lda save_err_msg,X
        beq save_done
        jsr modem_out
        inx
        bne save_err_loop

quick_save:
    ldx #0
qs_loop:
    lda quick_save_msg,X
    beq qs_done
    jsr modem_out
    inx
    bne qs_loop
qs_done:
    jsr modem_in
    jmp save_do_save

save_filename:
    .text "@0:EVSAVE,S,W"
save_filename_alt:
    .text "@0:EVSAVE1,S,W"
// Market event scheduling
market_event_counter: .byte 0
market_event_interval: .byte 12  ; ticks between marketplace events
market_event_msg:
    .text "\r\nMarket vendors shout: 'New stock! Prices have shifted.'\r\n[Press any key]\r\n"
    .byte 0

// Save/load slot chooser
load_slot_choice: .byte 0
// Feature achievements: bitflags for new features
player_feature_achievements: .byte 0
; bit0: Circus completed at least once
; bit1: Arena victory recorded
; bit2: Train boarded at least once

pool_label_msg:
    .text "\r\nCurrent Arena Prize Pool: "
    .byte 0
bet_confirm_msg:
    .text "\r\nProceed with bet? (Y/N) "
    .byte 0

leaderboard_hdr_msg:
    .text "\r\n=== ARENA LEADERBOARD ===\r\n"
    .byte 0
leaderboard_entry_msg:
    .text "Place %d: Wins: "
    .byte 0
prize_pool_msg:
    .text "\r\nPrize Pool: "
    .byte 0
save_hdr_msg:
    .text "\r\n=== SAVE GAME ===\r\n\r\nSave progress? (Y/N) "
    .byte 0
save_ok_msg:
    .text "\r\nGame saved successfully!\r\n[Press any key]\r\n"
    .byte 0
quick_save_msg:
    .text "\r\nQuick saving...\r\n[Press any key]\r\n"
    .byte 0
save_err_msg:
    .text "\r\nError saving game!\r\n[Press any key]\r\n"
    .byte 0

// === LOAD GAME SYSTEM ===
load_game:
    ldx #0
load_hdr_loop:
        lda load_hdr_msg,X
        beq load_confirm
        jsr modem_out
        inx
        bne load_hdr_loop
load_confirm:
    jsr modem_in
    cmp #'Y'
    beq load_slot_browser
    cmp #'y'
    beq load_slot_browser
    jmp main_loop
load_do_load:
    // Load from disk
    lda #1       // File number
    ldx #8       // Device 8
    ldy #0       // Secondary address (read)
    jsr $FFBA    // SETLFS
    lda #10      // Filename length
    ; Allow choosing alternate load slot
    lda load_slot_choice
    cmp #0
    beq use_load0
    ldx #<save_filename_alt
    ldy #>save_filename_alt
    jmp do_setnam_load
use_load0:
    ldx #<load_filename
    ldy #>load_filename
do_setnam_load:
    jsr $FFBD    // SETNAM
    jsr $FFC0    // OPEN
    bcs go_load_error
    jmp load_read_data
go_load_error:
    jmp load_error
load_read_data:
    ldx #1
    jsr $FFC6    // CHKIN
    // Read player data
    jsr $FFCF    // CHRIN
    sta player_gold
    jsr $FFCF
    sta player_gold+1
    jsr $FFCF
    sta player_hp
    jsr $FFCF
    sta player_level
    jsr $FFCF
    sta player_xp
    jsr $FFCF
    sta ghost_rating
    jsr $FFCF
    sta ghost_wins
    jsr $FFCF
    sta ghost_losses
    jsr $FFCF
    sta arena_wins
    jsr $FFCF
    sta arena_rank
    jsr $FFCF
    sta skill_combat
    jsr $FFCF
    sta skill_magic
    jsr $FFCF
    sta skill_social
    jsr $FFCF
    sta skill_survival
    jsr $FFCF
    sta skill_points
    jsr $FFCF
    sta dungeon_deepest
    // Close file
    jsr $FFCC    // CLRCHN
    lda #1
    jsr $FFC3    // CLOSE
    ldx #0
load_ok_loop:
        lda load_ok_msg,X
        beq load_done
        jsr modem_out
        inx
        bne load_ok_loop
load_done:
    jsr modem_in
    jmp main_loop
load_error:
    ldx #0
load_err_loop:
        lda load_err_msg,X
        beq load_done
        jsr modem_out
        inx
        bne load_err_loop

load_filename:
    .text "0:EVSAVE,S,R"
load_hdr_msg:
    .text "\r\n=== LOAD GAME ===\r\n\r\nLoad saved game? (Y/N) "
    .byte 0
load_ok_msg:
    .text "\r\nGame loaded successfully!\r\n[Press any key]\r\n"
    .byte 0
load_err_msg:
    .text "\r\nNo save file found or error loading!\r\n[Press any key]\r\n"
    .byte 0

; Save slot browser used by Save/Load flows
save_slot_browser:
    ldx #0
save_slot_hdr_loop:
        lda save_slot_hdr_msg,X
        beq save_slot_hdr_done
        jsr modem_out
        inx
        bne save_slot_hdr_loop
save_slot_hdr_done:
    jsr modem_in
    cmp #'1'
    beq choose_slot_0
    cmp #'2'
    beq choose_slot_1
    jmp main_loop
choose_slot_0:
    lda #0
    sta autosave_slot
    lda #0
    sta load_slot_choice
    jmp save_do_save
choose_slot_1:
    lda #1
    sta autosave_slot
    lda #1
    sta load_slot_choice
    jmp save_do_save

load_slot_browser:
    ldx #0
load_slot_hdr_loop:
        lda load_slot_hdr_msg,X
        beq load_slot_hdr_done
        jsr modem_out
        inx
        bne load_slot_hdr_loop
load_slot_hdr_done:
    jsr modem_in
    cmp #'1'
    beq choose_load_0
    cmp #'2'
    beq choose_load_1
    jmp main_loop
choose_load_0:
    lda #0
    sta load_slot_choice
    jmp load_do_load
choose_load_1:
    lda #1
    sta load_slot_choice
    jmp load_do_load

save_slot_hdr_msg:
    .text "\r\nChoose save slot:\r\n1) Primary save\r\n2) Alternate save\r\n> "
    .byte 0
load_slot_hdr_msg:
    .text "\r\nChoose load slot:\r\n1) Primary save\r\n2) Alternate save\r\n> "
    .byte 0

portal_travel:
    ldx #0
portal_menu_loop:
        lda portal_menu_msg,X
        beq portal_menu_done
        jsr modem_out
        inx
        bne portal_menu_loop
portal_menu_done:
    jsr modem_in
    cmp #'1'
    bne not_go_aurora
    jmp visit_aurora
not_go_aurora:
    cmp #'2'
    bne not_go_lore
    jmp visit_lore
not_go_lore:
    cmp #'3'
    bne not_go_mythos
    jmp visit_mythos
not_go_mythos:
    cmp #'4'
    bne not_go_town
    jmp visit_town
not_go_town:
    cmp #'5'
    bne not_go_england
    jmp visit_england
not_go_england:
    cmp #'0'
    bne portal_menu_done
    jmp main_loop

visit_aurora:
    ldx #0
aurora_desc_loop:
        lda portal_aurora_msg,X
        beq aurora_desc_done
        jsr modem_out
        inx
        bne aurora_desc_loop
aurora_desc_done:
    ldx #0
aurora_menu_loop:
        lda aurora_npc_menu_msg,X
        beq aurora_menu_done
        jsr modem_out
        inx
        bne aurora_menu_loop
aurora_menu_done:
    jsr modem_in
    cmp #'3'
    bne aurora_stay
    jmp go_portal_back
aurora_stay:
    jsr modem_in
    jmp visit_aurora

visit_lore:
    ldx #0
lore_desc_loop:
        lda portal_lore_msg,X
        beq lore_desc_done
        jsr modem_out
        inx
        bne lore_desc_loop
lore_desc_done:
    ldx #0
lore_menu_loop:
        lda lore_npc_menu_msg,X
        beq lore_menu_done
        jsr modem_out
        inx
        bne lore_menu_loop
lore_menu_done:
    jsr modem_in
    cmp #'3'
    bne lore_stay
    jmp go_portal_back
lore_stay:
    jsr modem_in
    jmp visit_lore

visit_mythos:
    ldx #0
mythos_desc_loop:
        lda portal_mythos_msg,X
        beq mythos_desc_done
        jsr modem_out
        inx
        bne mythos_desc_loop
mythos_desc_done:
    ldx #0
mythos_menu_loop:
        lda mythos_npc_menu_msg,X
        beq mythos_menu_done
        jsr modem_out
        inx
        bne mythos_menu_loop
mythos_menu_done:
    jsr modem_in
    cmp #'3'
    bne mythos_stay
    jmp go_portal_back
mythos_stay:
    jsr modem_in
    jmp visit_mythos

visit_town:
    ldx #0
town_desc_loop:
        lda portal_town_msg,X
        beq town_desc_done
        jsr modem_out
        inx
        bne town_desc_loop
town_desc_done:
    ; Increment NPC greeting timer and trigger greeting occasionally
    inc npc_greet_timer
    lda npc_greet_timer
    cmp npc_greet_interval
    bcc skip_npc_greet
    lda #0
    sta npc_greet_timer
    jsr maybe_npc_greet
skip_npc_greet:
town_show_menu:
    ldx #0
town_menu_loop:
    lda town_menu_msg,X
        beq town_menu_done
        jsr modem_out
        inx
        bne town_menu_loop
    ; print extra town menu entries (W-X-Y-Z)
    ldx #0
town_menu_extra_loop:
        lda town_menu_extra_msg,X
        beq town_menu_extra_done
        jsr modem_out
        inx
        bne town_menu_extra_loop
town_menu_extra_done:
town_menu_done:
    jsr modem_in
    // Number keys 1-9
    cmp #'1'
    bne not_train
    jmp visit_train_station
not_train:
    cmp #'2'
    bne not_tipsy
    jmp visit_tipsy_maiden
not_tipsy:
    cmp #'3'
    bne not_kettle
    jmp visit_kettle_cafe
not_kettle:
    cmp #'4'
    bne not_copper
    jmp visit_copper_confection
not_copper:
    cmp #'5'
    bne not_glass
    jmp visit_glass_house
not_glass:
    cmp #'6'
    bne not_dragon_haven
    jmp visit_dragon_haven
not_dragon_haven:
    cmp #'7'
    bne not_temple
    jmp visit_temple_ruins
not_temple:
    cmp #'8'
    bne not_louden
    jmp visit_loudens_rest
not_louden:
    cmp #'9'
    bne not_moselem
    jmp visit_moselem
not_moselem:
    // Letter keys A-I, M
    cmp #'A'
    bne not_fairy
    jmp visit_fairy_gardens
not_fairy:
    cmp #'B'
    bne not_town_arena
    jmp visit_town_arena
not_town_arena:
    cmp #'C'
    bne not_pirate
    jmp visit_pirate_ship
not_pirate:
    cmp #'D'
    bne not_tower
    jmp visit_tower
not_tower:
    cmp #'E'
    bne not_church
    jmp visit_church
not_church:
    cmp #'F'
    bne not_catacombs
    jmp visit_catacombs
not_catacombs:
    cmp #'G'
    bne not_statue
    jmp visit_statue_michael
not_statue:
    cmp #'H'
    bne not_market
    jmp visit_marketplace
not_market:
    cmp #'I'
    bne not_goto_witch
    jmp visit_witch_tent
not_goto_witch:
    cmp #'M'
    bne not_moon
    jmp visit_moon_portal
not_moon:
    cmp #'J'
    bne not_hovel
    jmp visit_hunters_hovel
not_hovel:
    cmp #'K'
    bne not_burrows
    jmp visit_burrows
not_burrows:
    cmp #'L'
    bne not_mystics
    jmp visit_mystics_tent
not_mystics:
    cmp #'N'
    bne not_central_plaza
    jmp visit_central_plaza
not_central_plaza:
    cmp #'O'
    bne not_the_bridge
    jmp visit_the_bridge
not_the_bridge:
    cmp #'P'
    bne not_apothecary
    jmp visit_apothecary
not_apothecary:
    cmp #'R'
    bne not_forge
    jmp visit_forge
not_forge:
    cmp #'T'
    bne not_hextrove
    jmp visit_hex_trove
not_hextrove:
    cmp #'U'
    bne not_food_east
    jmp visit_foodcourt_east
not_food_east:
    cmp #'V'
    bne not_food_west
    jmp visit_foodcourt_west
not_food_west:
    cmp #'W'
    bne not_stocks
    jmp visit_stocks
not_stocks:
    cmp #'X'
    bne not_archery
    jmp visit_archery
not_archery:
    cmp #'Y'
    bne not_ax_throw
    jmp visit_ax_throwing
not_ax_throw:
    cmp #'Z'
    bne not_jail
    jmp visit_jail
not_jail:
    cmp #'Q'
    bne not_circus
    jmp visit_circus_tent
not_circus:
    cmp #'S'
    bne not_the_stage
    jmp visit_the_stage
not_the_stage:
    cmp #'0'
    bne back_to_town_menu
    jmp go_portal_back
back_to_town_menu:
    jmp town_show_menu

// === THE EVERLAND EXPRESS TRAIN SYSTEM ===
// Train stops (14 total):
// 0=Station, 1=Market, 2=Harbor, 3=Hunter's Hovel, 4=Library, 5=Dragon Haven
// 6=Temple Ruins, 7=Tipsy Maiden, 8=Kettle Cafe, 9=Louden's Rest
// 10=Fairy Gardens, 11=Glass House, 12=Copper Confection, 13=The Stage

train_current_stop: .byte 0          // Current stop (0-13)
train_wait_counter: .byte 0          // Counter for auto-advance
train_stop_count: .byte 14           // Number of stops

visit_train_station:
    // Show station description
    ldx #0
station_desc_loop:
        lda train_station_msg,X
        beq station_show_menu
        jsr modem_out
        inx
        bne station_desc_loop
station_show_menu:
    // Show ticket booth menu
    ldx #0
ticket_menu_loop:
        lda ticket_booth_msg,X
        beq ticket_menu_done
        jsr modem_out
        inx
        bne ticket_menu_loop
ticket_menu_done:
    jsr modem_in
    cmp #'1'
    beq buy_train_ticket
    cmp #'2'
    beq try_board_train
    cmp #'3'
    beq view_train_timetable
    cmp #'4'
    beq station_shop
    cmp #'0'
    beq town_show_menu
    jmp station_show_menu

buy_train_ticket:
    // Check for season pass or existing ticket
    lda season_pass_owned
    bne already_has_pass_display
    lda has_train_ticket
    bne already_has_ticket_display
    // Continue to purchase flow
    // Check if enough gold (5 gold)
    lda player_gold
    cmp train_ticket_price
    bcs enough_for_train_tkt
    lda player_gold+1
    bne enough_for_train_tkt
    // Not enough gold
    ldx #0
no_gold_train_loop:
        lda no_gold_ticket_msg,X
        beq no_gold_train_done
        jsr modem_out
        inx
        bne no_gold_train_loop
no_gold_train_done:
    jsr modem_in
    jmp station_show_menu
 
already_has_pass_display:
    ldx #0
already_has_pass_loop:
        lda already_has_pass_msg,X
        beq already_has_pass_done
        jsr modem_out
        inx
        bne already_has_pass_loop
already_has_pass_done:
    jsr modem_in
    jmp station_show_menu

already_has_ticket_display:
    ldx #0
already_ticket_loop:
        lda already_has_ticket_msg,X
        beq already_ticket_done
        jsr modem_out
        inx
        bne already_ticket_loop
already_ticket_done:
    jsr modem_in
    jmp station_show_menu
enough_for_train_tkt:
    // Subtract ticket price from gold
    lda player_gold
    sec
    sbc train_ticket_price
    sta player_gold
    lda player_gold+1
    sbc #0
    sta player_gold+1
    // Give ticket
    lda #1
    sta has_train_ticket
    ldx #0
bought_train_loop:
        lda bought_ticket_msg,X
        beq bought_train_done
        jsr modem_out
        inx
        bne bought_train_loop
bought_train_done:
    jsr modem_in
    jmp station_show_menu

try_board_train:
    // Check for ticket
    lda season_pass_owned
    bne has_ticket_board
    lda has_train_ticket
    bne has_ticket_board
    // No ticket!
    ldx #0
no_ticket_loop:
        lda no_ticket_msg,X
        beq no_ticket_done
        jsr modem_out
        inx
        bne no_ticket_loop
no_ticket_done:
    jsr modem_in
    jmp station_show_menu

has_ticket_board:
    // Consume the ticket if it was a single-use ticket (don't consume season pass)
    lda has_train_ticket
    beq has_board_with_pass
    lda #0
    sta has_train_ticket
has_board_with_pass:
    // Show boarding message
    ldx #0
train_board_loop:
        lda train_board_msg,X
        beq train_all_aboard
        jsr modem_out
        inx
        bne train_board_loop
train_all_aboard:
    // Engineer Bob: All aboard!
    ldx #0
bob_aboard_loop:
        lda bob_all_aboard_msg,X
        beq train_start_ride
        jsr modem_out
        inx
        bne bob_aboard_loop
train_start_ride:
    jsr modem_in
    lda #0
    sta train_current_stop
    jsr set_achievement_train
    jmp train_menu

// Station shop routine (buy Season Pass)
station_shop:
    ldx #0
shop_loop:
    lda station_shop_msg,X
    beq shop_menu_done
    jsr modem_out
    inx
    bne shop_loop
shop_menu_done:
    jsr modem_in
    cmp #'1'
    beq buy_season_pass
    cmp #'2'
    beq station_show_menu
    jmp station_shop

buy_season_pass:
    lda season_pass_owned
    bne shop_already_has
    lda player_gold
    cmp season_pass_price
    bcs enough_for_pass
    lda player_gold+1
    bne enough_for_pass
    ldx #0
no_gold_shop_loop:
    lda no_gold_shop_msg,X
    beq no_gold_shop_done
    jsr modem_out
    inx
    bne no_gold_shop_loop
no_gold_shop_done:
    jsr modem_in
    jmp station_shop

enough_for_pass:
    lda player_gold
    sec
    sbc season_pass_price
    sta player_gold
    lda player_gold+1
    sbc #0
    sta player_gold+1
    lda #1
    sta season_pass_owned
    ldx #0
bought_pass_loop:
    lda bought_pass_msg,X
    beq bought_pass_done
    jsr modem_out
    inx
    bne bought_pass_loop
bought_pass_done:
    jsr modem_in
    jmp station_show_menu

shop_already_has:
    ldx #0
shop_already_loop:
    lda already_has_pass_msg,X
    beq shop_already_done
    jsr modem_out
    inx
    bne shop_already_loop
shop_already_done:
    jsr modem_in
    jmp station_show_menu

train_menu:
    // Show current location info
    ldx #0
train_status_loop:
        lda train_status_msg,X
        beq train_show_stop_name
        jsr modem_out
        inx
        bne train_status_loop
train_show_stop_name:
    // Print current stop name
    lda train_current_stop
    jsr train_print_stop_name
    // Show menu options
    ldx #0
train_opt_loop:
        lda train_options_msg,X
        beq train_get_input
        jsr modem_out
        inx
        bne train_opt_loop
train_get_input:
    // Wait for input with timeout simulation
    lda #0
    sta train_wait_counter
train_input_wait:
    jsr modem_in_nowait
    bcc train_has_input
    // No input - increment wait counter
    inc train_wait_counter
    ; compute threshold = 60 + train_delay_factor*5
    lda train_delay_factor
    asl
    asl
    clc
    adc train_delay_factor
    clc
    adc #60
    sta temp_threshold
    lda train_wait_counter
    cmp temp_threshold
    bcc train_input_wait
    // Auto-advance!
    jmp train_next_stop
train_has_input:
    cmp #'1'
    beq train_exit_here
    cmp #'2'
    beq train_next_stop
    jmp train_get_input
train_exit_here:
    // Exit at current stop
    ldx #0
train_exit_loop:
        lda train_exit_msg,X
        beq train_do_exit
        jsr modem_out
        inx
        bne train_exit_loop
train_do_exit:
    jsr modem_in
    lda train_current_stop
    cmp #0
    bne not_exit_station
    jmp town_show_menu       // Station - back to town
not_exit_station:
    cmp #1
    bne not_exit_market
    jmp visit_marketplace    // Market
not_exit_market:
    cmp #2
    bne not_exit_harbor
    jmp ship_menu            // Harbor
not_exit_harbor:
    cmp #3
    bne not_exit_hovel
    jmp visit_hunters_hovel  // Hunter's Hovel
not_exit_hovel:
    cmp #4
    bne not_exit_library
    jmp library_menu         // Library
not_exit_library:
    cmp #5
    bne not_exit_dragon
    jmp visit_dragon_haven   // Dragon Haven
not_exit_dragon:
    cmp #6
    bne not_exit_temple
    jmp visit_temple_ruins   // Temple Ruins
not_exit_temple:
    cmp #7
    bne not_exit_tipsy
    jmp visit_tipsy_maiden   // Tipsy Maiden
not_exit_tipsy:
    cmp #8
    bne not_exit_kettle
    jmp visit_kettle_cafe    // Kettle Cafe
not_exit_kettle:
    cmp #9
    bne not_exit_louden
    jmp visit_loudens_rest   // Louden's Rest
not_exit_louden:
    cmp #10
    bne not_exit_fairy
    jmp visit_fairy_gardens  // Fairy Gardens
not_exit_fairy:
    cmp #11
    bne not_exit_glass
    jmp visit_glass_house    // Glass House
not_exit_glass:
    cmp #12
    bne not_exit_copper
    jmp visit_copper_confection // Copper Confection
not_exit_copper:
    jmp visit_the_stage      // The Stage

train_next_stop:
    // Moving to next stop!
    ldx #0
train_moving1_loop:
        lda train_moving1_msg,X
        beq train_delay1
        jsr modem_out
        inx
        bne train_moving1_loop
train_delay1:
    jsr train_short_delay
    // Check for approach sounds
    lda train_current_stop
    clc
    adc #1
    cmp train_stop_count
    bcc train_stop_ok
    lda #0
train_stop_ok:
    sta train_current_stop
    // Show approach sounds for this stop
    jsr train_approach_sounds
    // Conductor announces the next stop
    jsr train_conductor_announce
    ldx #0
train_moving2_loop:
        lda train_moving2_msg,X
        beq train_delay2
        jsr modem_out
        inx
        bne train_moving2_loop
train_delay2:
    jsr train_short_delay
    ldx #0
train_whistle_loop:
        lda train_whistle_msg,X
        beq train_delay3
        jsr modem_out
        inx
        bne train_whistle_loop
train_delay3:
    jsr train_short_delay
    ldx #0
train_stopping_loop:
        lda train_stopping_msg,X
        beq train_arrive
        jsr modem_out
        inx
        bne train_stopping_loop
train_arrive:
    jsr train_short_delay
    // Conductor Bob announces arrival
    ldx #0
bob_welcome_loop:
        lda bob_welcome_msg,X
        beq bob_say_place
        jsr modem_out
        inx
        bne bob_welcome_loop
bob_say_place:
    lda train_current_stop
    jsr train_print_stop_name
    jsr train_conductor_flavor
    lda #'!'
    jsr modem_out
    lda #13
    jsr modem_out
    lda #13
    jsr modem_out
    // NPCs react
    jsr train_npc_reaction
    // Conductor gives tour
    jsr train_conductor_tour
    jmp train_menu

// Print stop name based on A register (0-13)
train_print_stop_name:
    cmp #0
    bne not_stop_0
    ldx #0
stop_name_0_loop:
        lda stop_name_station,X
        beq go_stop_done_0
        jsr modem_out
        inx
        bne stop_name_0_loop
go_stop_done_0:
    jmp stop_name_done
not_stop_0:
    cmp #1
    bne not_stop_1
    ldx #0
stop_name_1_loop:
        lda stop_name_market,X
        beq go_stop_done_1
        jsr modem_out
        inx
        bne stop_name_1_loop
go_stop_done_1:
    jmp stop_name_done
not_stop_1:
    cmp #2
    bne not_stop_2
    ldx #0
stop_name_2_loop:
        lda stop_name_harbor,X
        beq go_stop_done_2
        jsr modem_out
        inx
        bne stop_name_2_loop
go_stop_done_2:
    jmp stop_name_done
not_stop_2:
    cmp #3
    bne not_stop_3
    ldx #0
stop_name_3_loop:
        lda stop_name_hovel,X
        beq go_stop_done_3
        jsr modem_out
        inx
        bne stop_name_3_loop
go_stop_done_3:
    jmp stop_name_done
not_stop_3:
    cmp #4
    bne not_stop_4

// Print conductor flavor line based on A register (0-13)
train_conductor_flavor:
    cmp #0
    bne tcf_not_0
    ldx #0
tcf_0_loop:
        lda conductor_flavor_0,X
        beq tcf_done
        jsr modem_out
        inx
        bne tcf_0_loop
tcf_done:
    rts
tcf_not_0:
    cmp #1
    bne tcf_not_1
    ldx #0
tcf_1_loop:
        lda conductor_flavor_1,X
        beq tcf_done1
        jsr modem_out
        inx
        bne tcf_1_loop
tcf_done1:
    rts
tcf_not_1:
    cmp #2
    bne tcf_not_2
    ldx #0
tcf_2_loop:
        lda conductor_flavor_2,X
        beq tcf_done2
        jsr modem_out
        inx
        bne tcf_2_loop
tcf_done2:
    rts
tcf_not_2:
    cmp #3
    bne tcf_not_3
    ldx #0
tcf_3_loop:
        lda conductor_flavor_3,X
        beq tcf_done3
        jsr modem_out
        inx
        bne tcf_3_loop
tcf_done3:
    rts
tcf_not_3:
    cmp #4
    bne tcf_not_4
    ldx #0
tcf_4_loop:
        lda conductor_flavor_4,X
        beq tcf_done4
        jsr modem_out
        inx
        bne tcf_4_loop
tcf_done4:
    rts
tcf_not_4:
    cmp #5
    bne tcf_not_5
    ldx #0
tcf_5_loop:
        lda conductor_flavor_5,X
        beq tcf_done5
        jsr modem_out
        inx
        bne tcf_5_loop
tcf_done5:
    rts
tcf_not_5:
    cmp #6
    bne tcf_not_6
    ldx #0
tcf_6_loop:
        lda conductor_flavor_6,X
        beq tcf_done6
        jsr modem_out
        inx
        bne tcf_6_loop
tcf_done6:
    rts
tcf_not_6:
    cmp #7
    bne tcf_not_7
    ldx #0
tcf_7_loop:
        lda conductor_flavor_7,X
        beq tcf_done7
        jsr modem_out
        inx
        bne tcf_7_loop
tcf_done7:
    rts
tcf_not_7:
    cmp #8
    bne tcf_not_8
    ldx #0
tcf_8_loop:
        lda conductor_flavor_8,X
        beq tcf_done8
        jsr modem_out
        inx
        bne tcf_8_loop
tcf_done8:
    rts
tcf_not_8:
    cmp #9
    bne tcf_not_9
    ldx #0
tcf_9_loop:
        lda conductor_flavor_9,X
        beq tcf_done9
        jsr modem_out
        inx
        bne tcf_9_loop
tcf_done9:
    rts
tcf_not_9:
    cmp #10
    bne tcf_not_10
    ldx #0
tcf_10_loop:
        lda conductor_flavor_10,X
        beq tcf_done10
        jsr modem_out
        inx
        bne tcf_10_loop
tcf_done10:
    rts
tcf_not_10:
    cmp #11
    bne tcf_not_11
    ldx #0
tcf_11_loop:
        lda conductor_flavor_11,X
        beq tcf_done11
        jsr modem_out
        inx
        bne tcf_11_loop
tcf_done11:
    rts
tcf_not_11:
    cmp #12
    bne tcf_not_12
    ldx #0
tcf_12_loop:
        lda conductor_flavor_12,X
        beq tcf_done12
        jsr modem_out
        inx
        bne tcf_12_loop
tcf_done12:
    rts
tcf_not_12:
    cmp #13
    bne tcf_done
    ldx #0
tcf_13_loop:
        lda conductor_flavor_13,X
        beq tcf_done
        jsr modem_out
        inx
        bne tcf_13_loop
tcf_done:
    rts
    ldx #0
stop_name_4_loop:
        lda stop_name_library,X
        beq go_stop_done_4
        jsr modem_out
        inx
        bne stop_name_4_loop
go_stop_done_4:
    jmp stop_name_done
not_stop_4:
    cmp #5
    bne not_stop_5
    ldx #0
stop_name_5_loop:
        lda stop_name_dragon,X
        beq go_stop_done_5
        jsr modem_out
        inx
        bne stop_name_5_loop
go_stop_done_5:
    jmp stop_name_done
not_stop_5:
    cmp #6
    bne not_stop_6
    ldx #0
stop_name_6_loop:
        lda stop_name_temple,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_6_loop
not_stop_6:
    cmp #7
    bne not_stop_7
    ldx #0
stop_name_7_loop:
        lda stop_name_tipsy,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_7_loop
not_stop_7:
    cmp #8
    bne not_stop_8
    ldx #0
stop_name_8_loop:
        lda stop_name_kettle,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_8_loop
not_stop_8:
    cmp #9
    bne not_stop_9
    ldx #0
stop_name_9_loop:
        lda stop_name_louden,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_9_loop
not_stop_9:
    cmp #10
    bne not_stop_10
    ldx #0
stop_name_10_loop:
        lda stop_name_fairy,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_10_loop
not_stop_10:
    cmp #11
    bne not_stop_11
    ldx #0
stop_name_11_loop:
        lda stop_name_glass,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_11_loop
not_stop_11:
    cmp #12
    bne not_stop_12
    ldx #0
stop_name_12_loop:
        lda stop_name_copper,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_12_loop
not_stop_12:
    ldx #0
stop_name_13_loop:
        lda stop_name_stage,X
        beq stop_name_done
        jsr modem_out
        inx
        bne stop_name_13_loop
stop_name_done:
    rts

// Show approach sounds based on current stop
train_approach_sounds:
    lda train_current_stop
    cmp #1
    bne not_approach_market
    ldx #0
sound_market_loop:
        lda sound_market_msg,X
        beq go_approach_done_1
        jsr modem_out
        inx
        bne sound_market_loop
go_approach_done_1:
    jmp approach_done
not_approach_market:
    cmp #2
    bne not_approach_harbor
    ldx #0
sound_harbor_loop:
        lda sound_harbor_msg,X
        beq go_approach_done_2
        jsr modem_out
        inx
        bne sound_harbor_loop
go_approach_done_2:
    jmp approach_done
not_approach_harbor:
    cmp #3
    bne not_approach_hovel
    ldx #0
sound_hovel_loop:
        lda sound_hovel_msg,X
        beq go_approach_done_3
        jsr modem_out
        inx
        bne sound_hovel_loop
go_approach_done_3:
    jmp approach_done
not_approach_hovel:
    cmp #4
    bne not_approach_library
    ldx #0
sound_library_loop:
        lda sound_library_msg,X
        beq go_approach_done_4
        jsr modem_out
        inx
        bne sound_library_loop
go_approach_done_4:
    jmp approach_done
not_approach_library:
    cmp #5
    bne not_approach_dragon
    ldx #0
sound_dragon_loop:
        lda sound_dragon_msg,X
        beq go_approach_done_5
        jsr modem_out
        inx
        bne sound_dragon_loop
go_approach_done_5:
    jmp approach_done
not_approach_dragon:
    cmp #6
    bne not_approach_temple
    ldx #0
sound_temple_loop:
        lda sound_temple_msg,X
        beq go_approach_done_6
        jsr modem_out
        inx
        bne sound_temple_loop
go_approach_done_6:
    jmp approach_done
not_approach_temple:
    cmp #7
    bne not_approach_tipsy
    ldx #0
sound_tipsy_loop:
        lda sound_tipsy_msg,X
        beq go_approach_done_7
        jsr modem_out
        inx
        bne sound_tipsy_loop
go_approach_done_7:
    jmp approach_done
not_approach_tipsy:
    cmp #8
    bne not_approach_kettle
    ldx #0
sound_kettle_loop:
        lda sound_kettle_msg,X
        beq approach_done
        jsr modem_out
        inx
        bne sound_kettle_loop
not_approach_kettle:
    cmp #9
    bne not_approach_louden
    ldx #0
sound_louden_loop:
        lda sound_louden_msg,X
        beq approach_done
        jsr modem_out
        inx
        bne sound_louden_loop
not_approach_louden:
    cmp #10
    bne not_approach_fairy
    ldx #0
sound_fairy_loop:
        lda sound_fairy_msg,X
        beq approach_done
        jsr modem_out
        inx
        bne sound_fairy_loop
not_approach_fairy:
    cmp #11
    bne not_approach_glass
    ldx #0
sound_glass_loop:
        lda sound_glass_msg,X
        beq approach_done
        jsr modem_out
        inx
        bne sound_glass_loop
not_approach_glass:
    cmp #12
    bne not_approach_copper
    ldx #0
sound_copper_loop:
        lda sound_copper_msg,X
        beq approach_done
        jsr modem_out
        inx
        bne sound_copper_loop
not_approach_copper:
    cmp #13
    bne not_approach_stage
    ldx #0
sound_stage_loop:
        lda sound_stage_msg,X
        beq approach_done
        jsr modem_out
        inx
        bne sound_stage_loop
not_approach_stage:
    // Station - church bells
    ldx #0
sound_station_loop:
        lda sound_station_msg,X
        beq approach_done
        jsr modem_out
        inx
        bne sound_station_loop
approach_done:
    rts

// Conductor announcement: announce next stop
train_conductor_announce:
    ldx #0
conductor_prefix_loop:
        lda conductor_prefix_msg,X
        beq conductor_prefix_done
        jsr modem_out
        inx
        bne conductor_prefix_loop
conductor_prefix_done:
    lda train_current_stop
    jsr train_print_stop_name
    ldx #0
conductor_suffix_loop:
        lda conductor_suffix_msg,X
        beq conductor_suffix_done
        jsr modem_out
        inx
        bne conductor_suffix_loop
conductor_suffix_done:
    ; If train has delay factor, mention short delay
    lda train_delay_factor
    beq conductor_no_delay
    ldx #0
delay_msg_loop:
        lda conductor_delay_msg,X
        beq delay_msg_done
        jsr modem_out
        inx
        bne delay_msg_loop
delay_msg_done:
    jsr modem_in
conductor_no_delay:
    rts

// View timetable routine (station menu)
view_train_timetable:
    ldx #0
timetable_loop:
        lda timetable_msg,X
        beq timetable_done
        jsr modem_out
        inx
        bne timetable_loop
timetable_done:
    jsr modem_in
    jmp station_show_menu


// NPC reactions at each stop
train_npc_reaction:
    lda train_current_stop
    cmp #3
    bne not_hovel_howl
    // Hunter's Hovel - wolves howl!
    ldx #0
wolves_howl_loop:
        lda wolves_howl_msg,X
        beq reaction_done
        jsr modem_out
        inx
        bne wolves_howl_loop
    jmp reaction_done
not_hovel_howl:
    cmp #13
    bne not_stage_fire
    // Stage - Greg performs fire!
    ldx #0
greg_fire_loop:
        lda greg_fire_msg,X
        beq reaction_done
        jsr modem_out
        inx
        bne greg_fire_loop
    jmp reaction_done
not_stage_fire:
    cmp #10
    bne not_fairy_sparkle
    // Fairy Gardens - fairies sparkle!
    ldx #0
fairy_sparkle_loop:
        lda fairy_sparkle_msg,X
        beq reaction_done
        jsr modem_out
        inx
        bne fairy_sparkle_loop
    jmp reaction_done
not_fairy_sparkle:
    // Other stops - NPCs wave
    ldx #0
npcs_wave_loop:
        lda npcs_wave_msg,X
        beq reaction_done
        jsr modem_out
        inx
        bne npcs_wave_loop
reaction_done:
    rts

// Conductor tour at each stop
train_conductor_tour:
    lda train_current_stop
    cmp #0
    bne not_tour_station
    ldx #0
tour_station_loop:
        lda tour_station_msg,X
        beq go_tour_done_0
        jsr modem_out
        inx
        bne tour_station_loop
go_tour_done_0:
    jmp tour_done
not_tour_station:
    cmp #1
    bne not_tour_market
    ldx #0
tour_market_loop:
        lda tour_market_msg,X
        beq go_tour_done_1
        jsr modem_out
        inx
        bne tour_market_loop
go_tour_done_1:
    jmp tour_done
not_tour_market:
    cmp #2
    bne not_tour_harbor
    ldx #0
tour_harbor_loop:
        lda tour_harbor_msg,X
        beq go_tour_done_2
        jsr modem_out
        inx
        bne tour_harbor_loop
go_tour_done_2:
    jmp tour_done
not_tour_harbor:
    cmp #3
    bne not_tour_hovel
    ldx #0
tour_hovel_loop:
        lda tour_hovel_msg,X
        beq go_tour_done_3
        jsr modem_out
        inx
        bne tour_hovel_loop
go_tour_done_3:
    jmp tour_done
not_tour_hovel:
    cmp #4
    bne not_tour_library
    ldx #0
tour_library_loop:
        lda tour_library_msg,X
        beq go_tour_done_4
        jsr modem_out
        inx
        bne tour_library_loop
go_tour_done_4:
    jmp tour_done
not_tour_library:
    cmp #5
    bne not_tour_dragon
    ldx #0
tour_dragon_loop:
        lda tour_dragon_msg,X
        beq go_tour_done_5
        jsr modem_out
        inx
        bne tour_dragon_loop
go_tour_done_5:
    jmp tour_done
not_tour_dragon:
    cmp #6
    bne not_tour_temple
    ldx #0
tour_temple_loop:
        lda tour_temple_msg,X
        beq go_tour_done_6
        jsr modem_out
        inx
        bne tour_temple_loop
go_tour_done_6:
    jmp tour_done
not_tour_temple:
    cmp #7
    bne not_tour_tipsy
    ldx #0
tour_tipsy_loop:
        lda tour_tipsy_msg,X
        beq go_tour_done_7
        jsr modem_out
        inx
        bne tour_tipsy_loop
go_tour_done_7:
    jmp tour_done
not_tour_tipsy:
    cmp #8
    bne not_tour_kettle
    ldx #0
tour_kettle_loop:
        lda tour_kettle_msg,X
        beq tour_done
        jsr modem_out
        inx
        bne tour_kettle_loop
    jmp tour_done
not_tour_kettle:
    cmp #9
    bne not_tour_louden
    ldx #0
tour_louden_loop:
        lda tour_louden_msg,X
        beq tour_done
        jsr modem_out
        inx
        bne tour_louden_loop
    jmp tour_done
not_tour_louden:
    cmp #10
    bne not_tour_fairy
    ldx #0
tour_fairy_loop:
        lda tour_fairy_msg,X
        beq tour_done
        jsr modem_out
        inx
        bne tour_fairy_loop
    jmp tour_done
not_tour_fairy:
    cmp #11
    bne not_tour_glass
    ldx #0
tour_glass_loop:
        lda tour_glass_msg,X
        beq tour_done
        jsr modem_out
        inx
        bne tour_glass_loop
    jmp tour_done
not_tour_glass:
    cmp #12
    bne not_tour_copper
    ldx #0
tour_copper_loop:
        lda tour_copper_msg,X
        beq tour_done
        jsr modem_out
        inx
        bne tour_copper_loop
    jmp tour_done
not_tour_copper:
    ldx #0
tour_stage_loop:
        lda tour_stage_msg,X
        beq tour_done
        jsr modem_out
        inx
        bne tour_stage_loop
tour_done:
    rts

// Simple delay routine (burn some cycles)
train_short_delay:
    ldx #$FF
delay_outer:
    ldy #$80
delay_inner:
        dey
        bne delay_inner
    dex
    bne delay_outer
    rts

// Non-blocking modem input (returns carry set if no input)
modem_in_nowait:
    lda $D012          // Check raster for pseudo-random timing
    and #$0F
    bne no_input_yet
    jsr modem_in       // Actually get input
    clc
    rts
no_input_yet:
    sec
    rts

// Train ticket booth messages
ticket_booth_msg:
    .text "\r\nTICKET BOOTH:\r\nThe ticket master nods at you from behind the brass counter.\r\n'Tickets for the Everland Express! 5 gold for unlimited travel! Or purchase a Season Pass for frequent riders.'\r\n\r\n1. Buy Ticket (5 gold)\r\n2. Board the Train\r\n3. View Timetable\r\n4. Station Shop (Season Pass)\r\n0. Leave Station\r\n> "
    .byte 0

no_ticket_msg:
    .text "\r\nThe conductor blocks your path with a firm but polite hand.\r\n\r\n'Whoa there, friend! You'll need a ticket to board the Everland Express. See the ticket booth just over there!'\r\n\r\n[Press any key]\r\n"
    .byte 0
bought_ticket_msg:
    .text "\r\nThe ticket master stamps a golden ticket and hands it to you.\r\n\r\n'There you go! This ticket is good for as long as you want to ride. Enjoy the journey!'\r\n\r\n[Press any key]\r\n"
    .byte 0
already_has_ticket_msg:
    .text "\r\nThe ticket master smiles and waves you off.\r\n\r\n'You already have a ticket! No need to buy another - yours is good for unlimited travel. Just board when you're ready!'\r\n\r\n[Press any key]\r\n"
    .byte 0
no_gold_ticket_msg:
    .text "\r\nThe ticket master shakes his head sympathetically.\r\n\r\n'Sorry friend, tickets are 5 gold. Come back when your purse is a bit heavier!'\r\n\r\n[Press any key]\r\n"
    .byte 0

// Station Shop / Season Pass messages
station_shop_msg:
    .text "\r\nSTATION SHOP:\r\nWelcome to the Station Shop! We sell a Season Pass for frequent travelers.\r\n\r\n1. Buy Season Pass (50 gold)\r\n2. Leave Shop\r\n> "
    .byte 0
no_gold_shop_msg:
    .text "\r\nYou check your purse and find it light. The shopkeeper pats your shoulder.\r\n\r\n'Season Pass costs 50 gold. Come back when you have more.'\r\n\r\n[Press any key]\r\n"
    .byte 0
bought_pass_msg:
    .text "\r\nThe shopkeeper hands you a worn leather pass stamped with the Everland Express seal.\r\n\r\n'You're all set — unlimited rides for the season. Safe travels!'
\n\r\n[Press any key]\r\n"
    .byte 0
already_has_pass_msg:
    .text "\r\nThe shopkeeper smiles knowingly.\r\n\r\n'You already own a Season Pass — ride away my friend!'
\n\r\n[Press any key]\r\n"
    .byte 0

// Train system messages
train_board_msg:
    .text "\r\n=== EVERLAND EXPRESS ===\r\n\r\nYou step onto the platform of the grand Train Station. Steam hisses from the magnificent locomotive as it waits to depart.\r\n\r\n"
    .byte 0
bob_all_aboard_msg:
    .text "Engineer Bob blows the whistle and shouts:\r\n'ALL ABOARD! The Everland Express is departing!'\r\n\r\n[Press any key to board]\r\n"
    .byte 0
train_status_msg:
    .text "\r\n--- EVERLAND EXPRESS ---\r\nCurrent Stop: "
    .byte 0
train_options_msg:
    .text "\r\n\r\n1. Exit Here\r\n2. Next Stop\r\n\r\n(Train will depart automatically...)\r\n> "
    .byte 0
train_exit_msg:
    .text "\r\nConductor Bob tips his hat: 'Watch your step!'\r\n\r\n[Press any key]\r\n"
    .byte 0
train_moving1_msg:
    .text "\r\n  ...the train begins to move...\r\n"
    .byte 0
train_moving2_msg:
    .text "  ...wheels clatter on the tracks...\r\n"
    .byte 0
train_whistle_msg:
    .text "  WOOOO-WOOOO! The train whistle blows!\r\n"
    .byte 0
train_stopping_msg:
    .text "  ...the train is coming to a stop...\r\n\r\n"
    .byte 0
bob_welcome_msg:
    .text "Conductor Bob announces: 'Welcome to "
    .byte 0

conductor_prefix_msg:
    .text "Conductor calls: 'Next stop: '

    .byte 0
conductor_suffix_msg:
    .text "\r\n"
    .byte 0

timetable_msg:
    .text "\r\n=== EVERLAND EXPRESS - TIMETABLE ===\r\n\r\n"
    .text "Station........ 00:00\r\n"
    .text "Marketplace..... 00:02\r\n"
    .text "Harbor.......... 00:04\r\n"
    .text "Hunter's Hovel.. 00:06\r\n"
    .text "Library......... 00:08\r\n"
    .text "Dragon Haven.... 00:10\r\n"
    .text "Temple Ruins.... 00:12\r\n"
    .text "Tipsy Maiden.... 00:14\r\n"
    .text "Kettle Cafe..... 00:16\r\n"
    .text "Louden's Rest... 00:18\r\n"
    .text "Fairy Gardens... 00:20\r\n"
    .text "Glass House..... 00:22\r\n"
    .text "Copper Confect.. 00:24\r\n"
    .text "The Stage....... 00:26\r\n\r\n[Press any key]\r\n"
    .byte 0
// Stop names
stop_name_station:
    .text "Town Station"
    .byte 0
stop_name_market:
    .text "The Marketplace"
    .byte 0
stop_name_harbor:
    .text "Harbor District"
    .byte 0
stop_name_hovel:
    .text "Hunter's Hovel"
    .byte 0
stop_name_library:
    .text "The Grand Library"
    .byte 0
stop_name_dragon:
    .text "Dragon Haven"
    .byte 0
stop_name_temple:
    .text "Temple Ruins"
    .byte 0
stop_name_tipsy:
    .text "Tipsy Maiden Tavern"
    .byte 0
stop_name_kettle:
    .text "Kettle Cafe"
    .byte 0
stop_name_louden:
    .text "Louden's Rest"
    .byte 0
stop_name_fairy:
    .text "Fairy Gardens"
    .byte 0
stop_name_glass:
    .text "Glass House"
    .byte 0
stop_name_copper:
    .text "Copper Confection"
    .byte 0
stop_name_stage:
    .text "The Stage"
    .byte 0

// Approach sounds
sound_market_msg:
    .text "\r\n  [You hear merchants calling and coins clinking...]\r\n"
    .byte 0
sound_harbor_msg:
    .text "\r\n  [Seagulls cry and waves lap against the docks...]\r\n"
    .byte 0
sound_hovel_msg:
    .text "\r\n  [Distant howls echo through the trees...]\r\n"
    .byte 0
sound_library_msg:
    .text "\r\n  [The rustle of pages and whispers of scholars...]\r\n"
    .byte 0
sound_dragon_msg:
    .text "\r\n  [The beat of leathery wings and distant roars...]\r\n"
    .byte 0
sound_station_msg:
    .text "\r\n  [Church bells ring and the town clock chimes...]\r\n"
    .byte 0
sound_temple_msg:
    .text "\r\n  [Ancient chanting and the crackle of sacred flames...]\r\n"
    .byte 0
sound_tipsy_msg:
    .text "\r\n  [Raucous laughter and clinking mugs drift out...]\r\n"
    .byte 0
sound_kettle_msg:
    .text "\r\n  [The whistle of tea kettles and gentle chatter...]\r\n"
    .byte 0
sound_louden_msg:
    .text "\r\n  [Peaceful silence and soft wind through willows...]\r\n"
    .byte 0
sound_fairy_msg:
    .text "\r\n  [Tinkling bells and ethereal giggles float by...]\r\n"
    .byte 0
sound_glass_msg:
    .text "\r\n  [Exotic birds sing and strange creatures chirp...]\r\n"
    .byte 0
sound_copper_msg:
    .text "\r\n  [Children's laughter and the sweet smell of candy...]\r\n"
    .byte 0
sound_stage_msg:
    .text "\r\n  [Crackling flames and applause ring out...]\r\n"
    .byte 0

// NPC reactions
wolves_howl_msg:
    .text "The Wolves of Winter raise their muzzles and HOWL!\r\nAOOOOOOOO! AOOOOOOO!\r\nPassengers press against windows to watch!\r\n\r\n"
    .byte 0
greg_fire_msg:
    .text "Greg the Fire Dancer sees the train and performs!\r\n  *WHOOOOSH* Flames spiral into the air!\r\n  *FWOOOM* A dragon of fire dances above!\r\nPassengers gasp and cheer at the display!\r\n\r\n"
    .byte 0
fairy_sparkle_msg:
    .text "The fairies notice the train and begin to sparkle!\r\nHundreds of tiny lights dance alongside the cars!\r\nChildren wave excitedly from the windows!\r\n\r\n"
    .byte 0
npcs_wave_msg:
    .text "The locals wave cheerfully at the passing train!\r\n\r\n"
    .byte 0

// Conductor tours
tour_station_msg:
    .text "Conductor Bob: 'Town Station - the heart of Everland!\r\nYou'll find the Tipsy Maiden tavern nearby, and the\r\ncentral plaza where all roads meet. Perfect for\r\nstarting your adventures!'\r\n"
    .byte 0
tour_market_msg:
    .text "Conductor Bob: 'The Marketplace - finest goods in\r\nall the realms! Meet the merchants, barter for\r\ntreasures, and don't miss Kira's Apothecary for\r\npotions and remedies!'\r\n"
    .byte 0
tour_harbor_msg:
    .text "Conductor Bob: 'Harbor District - where ships sail\r\nto distant shores! Captain Barnaby offers passage,\r\nand you might spot the ghost pirates on moonless\r\nnights. Watch for sea monsters!'\r\n"
    .byte 0
tour_hovel_msg:
    .text "Conductor Bob: 'Hunter's Hovel - territory of the\r\nWinter Wolves! Alpha Wulfric leads the pack. They\r\nhowl whenever we pass - an ancient tradition that\r\ndelights our passengers! Respect the Pact!'\r\n"
    .byte 0
tour_library_msg:
    .text "Conductor Bob: 'The Grand Library - all knowledge\r\ngathered here! Rare tomes, ancient songs, and the\r\nwidom of ages. Scholars and seekers find their\r\nanswers within these hallowed halls!'\r\n"
    .byte 0
tour_dragon_msg:
    .text "Conductor Bob: 'Dragon Haven - where riders bond\r\nwith their dragons! Young hatchlings learn to fly\r\nand breathe flame. The trainers here are the best\r\nin all the realms!'\r\n"
    .byte 0
tour_temple_msg:
    .text "Conductor Bob: 'Temple Ruins - remnants of the old\r\ngods! Seekers come to meditate among the stones.\r\nThey say the veil is thin here, and ancient spirits\r\nstill whisper their secrets.'\r\n"
    .byte 0
tour_tipsy_msg:
    .text "Conductor Bob: 'Tipsy Maiden Tavern - finest ales\r\nand wildest tales! The barkeep knows everyone's\r\nsecrets. Many an adventure has started over a pint\r\nand ended with legendary stories!'\r\n"
    .byte 0
tour_kettle_msg:
    .text "Conductor Bob: 'Kettle Cafe - for the refined\r\ntraveler! Tea from every realm, pastries that melt\r\non your tongue. Perfect for planning your next\r\nquest over a warm cup.'\r\n"
    .byte 0
tour_louden_msg:
    .text "Conductor Bob: 'Louden's Rest - the peaceful inn!\r\nWeary travelers find comfort here. Old Louden keeps\r\nthe fire warm and the beds soft. Many say their\r\ndreams here show them their destiny.'\r\n"
    .byte 0
tour_fairy_msg:
    .text "Conductor Bob: 'Fairy Gardens - realm of the wee\r\nfolk! They love visitors but beware their tricks!\r\nLeave an offering and they may grant you luck.\r\nCross them and... well, don't cross them!'\r\n"
    .byte 0
tour_glass_msg:
    .text "Conductor Bob: 'Glass House - our conservatory of\r\nwonders! Exotic creatures from every realm live\r\nhere. A phoenix, singing birds, and creatures you\r\nwon't believe until you see them!'\r\n"
    .byte 0
tour_copper_msg:
    .text "Conductor Bob: 'Copper Confection - sweetest spot\r\nin town! Candies, frozen treats, and confections\r\nthat'll make you feel like a child again. Try the\r\nmoonberry ice cream - my favorite!'\r\n"
    .byte 0
tour_stage_msg:
    .text "Conductor Bob: 'The Stage - entertainment awaits!\r\nGreg the Fire Dancer performs here nightly! His\r\nflames dance in impossible patterns. Best show in\r\nall of Everland, and that's no exaggeration!'\r\n"
    .byte 0

// Conductor flavor lines per stop
conductor_flavor_0:
    .text "Conductor Bob: 'The town bakery smells of fresh pies.'\r\n"
    .byte 0
conductor_flavor_1:
    .text "Conductor Bob: 'Merchants haggle loudly in the marketplace.'\r\n"
    .byte 0
conductor_flavor_2:
    .text "Conductor Bob: 'The harbor brims with ships bound for far seas.'\r\n"
    .byte 0
conductor_flavor_3:
    .text "Conductor Bob: 'Wolf howls drift from the Hunter's Hovel.'\r\n"
    .byte 0
conductor_flavor_4:
    .text "Conductor Bob: 'You can smell old parchment near the library.'\r\n"
    .byte 0
conductor_flavor_5:
    .text "Conductor Bob: 'Dragon wings beat above Dragon Haven today.'\r\n"
    .byte 0
conductor_flavor_6:
    .text "Conductor Bob: 'Ancient stones whisper at the Temple Ruins.'\r\n"
    .byte 0
conductor_flavor_7:
    .text "Conductor Bob: 'Laughter and song pour from the Tipsy Maiden.'\r\n"
    .byte 0
conductor_flavor_8:
    .text "Conductor Bob: 'Steam and tea scent the Kettle Cafe.'\r\n"
    .byte 0
conductor_flavor_9:
    .text "Conductor Bob: 'Willows sway gently around Louden's Rest.'\r\n"
    .byte 0
conductor_flavor_10:
    .text "Conductor Bob: 'Tiny lights dance where the fairies dwell.'\r\n"
    .byte 0
conductor_flavor_11:
    .text "Conductor Bob: 'Glass House creatures sing exotic melodies.'\r\n"
    .byte 0
conductor_flavor_12:
    .text "Conductor Bob: 'Sweet aromas rise from the Copper Confection.'\r\n"
    .byte 0
conductor_flavor_13:
    .text "Conductor Bob: 'The Stage burns bright with performers tonight.'\r\n"
    .byte 0

// Continue with other town location visit routines
visit_tipsy_maiden:
    ldx #0
tipsy_loop:
        lda tipsy_maiden_msg,X
        beq tipsy_done
        jsr modem_out
        inx
        bne tipsy_loop
tipsy_done:
    ; Show tavern mini-game menu
    ldx #0
tavern_menu_loop:
        lda tavern_menu_msg,X
        beq tavern_menu_done
        jsr modem_out
        inx
        bne tavern_menu_loop
tavern_menu_done:
    jsr modem_in
    cmp #'1'
    beq tavern_play_dice
    cmp #'2'
    beq tavern_armwrestle
    cmp #'0'
    beq town_show_menu
    jmp visit_tipsy_maiden

visit_kettle_cafe:
    ldx #0
kettle_loop:
        lda kettle_cafe_msg,X
        beq kettle_done
        jsr modem_out
        inx
        bne kettle_loop
kettle_done:
    jsr modem_in
    jmp town_show_menu

// Tavern mini-games
tavern_menu_msg:
    .text "\r\nTIPSY MAIDEN - Tavern Games:\r\n1. Dice (bet 2g, win 6g)\r\n2. Arm Wrestling (no bet, win 8g on success)\r\n0. Back\r\n> "
    .byte 0

tavern_dice_win_msg:
    .text "\r\nYou roll lucky! You win 6 gold!\r\n[Press any key]\r\n"
    .byte 0
tavern_dice_lose_msg:
    .text "\r\nBad roll... you lose 2 gold.\r\n[Press any key]\r\n"
    .byte 0
tavern_arm_win_msg:
    .text "\r\nYou slam your foe; victory! +8g\r\n[Press any key]\r\n"
    .byte 0
tavern_arm_lose_msg:
    .text "\r\nYou strain and lose -3 HP.\r\n[Press any key]\r\n"
    .byte 0

tavern_play_dice:
    lda player_gold
    cmp #2
    bcs tavern_dice_afford
    jmp tavern_poor
tavern_dice_afford:
    sec
    sbc #2
    sta player_gold
    jsr get_random
    and #$01
    beq tavern_dice_lose
    ; win 6g
    lda player_gold
    clc
    adc #6
    sta player_gold
    ldx #0
tavern_dice_win_loop:
        lda tavern_dice_win_msg,X
        beq tavern_dice_win_done
        jsr modem_out
        inx
        bne tavern_dice_win_loop
tavern_dice_win_done:
    jsr modem_in
    jmp visit_tipsy_maiden
tavern_dice_lose:
    ; already subtracted 2g
    ldx #0
tavern_dice_lose_loop:
        lda tavern_dice_lose_msg,X
        beq tavern_dice_lose_done
        jsr modem_out
        inx
        bne tavern_dice_lose_loop
tavern_dice_lose_done:
    jsr modem_in
    jmp visit_tipsy_maiden

tavern_armwrestle:
    jsr get_random
    and #$01
    beq tavern_arm_lose
    ; win: +8g
    lda player_gold
    clc
    adc #8
    sta player_gold
    ldx #0
tavern_arm_win_loop:
        lda tavern_arm_win_msg,X
        beq tavern_arm_win_done
        jsr modem_out
        inx
        bne tavern_arm_win_loop
tavern_arm_win_done:
    jsr modem_in
    jmp visit_tipsy_maiden
tavern_arm_lose:
    lda player_hp
    sec
    sbc #3
    bcs tavern_arm_hp_ok
    lda #1
tavern_arm_hp_ok:
    sta player_hp
    ldx #0
tavern_arm_lose_loop:
        lda tavern_arm_lose_msg,X
        beq tavern_arm_lose_done
        jsr modem_out
        inx
        bne tavern_arm_lose_loop
tavern_arm_lose_done:
    jsr modem_in
    jmp visit_tipsy_maiden

tavern_poor:
    ldx #0
    lda tavern_poor_msg,X
    beq tavern_poor_done
    jsr modem_out
    inx
    bne tavern_poor
tavern_poor_done:
    jsr modem_in
    jmp visit_tipsy_maiden
tavern_poor_msg:
    .text "\r\nYou don't have enough gold for that game.\r\n[Press any key]\r\n"
    .byte 0

visit_copper_confection:
    ldx #0
copper_loop:
        lda copper_confection_msg,X
        beq copper_done
        jsr modem_out
        inx
        bne copper_loop
copper_done:
    jsr modem_in
    jmp town_show_menu

// Stocks - market trading pit
visit_stocks:
    ldx #0
stocks_loop:
        lda stocks_msg,X
        beq stocks_done
        jsr modem_out
        inx
        bne stocks_loop
stocks_done:
    jsr modem_in
    ; place player in the stocks for a short time (3 turns)
    lda #3
    sta detain_timer
    lda #1
    sta detain_type
    ; immediately show detained message
    ldx #0
detain_stocks_print:
    lda detained_stocks_msg,X
    beq detain_stocks_print_done
    jsr modem_out
    inx
    bne detain_stocks_print
detain_stocks_print_done:
    jsr modem_in
    jmp town_show_menu

// Archery range
visit_archery:
    ldx #0
archery_loop:
        lda archery_msg,X
        beq archery_done
        jsr modem_out
        inx
        bne archery_loop
archery_done:
    jsr modem_in
    jmp town_show_menu

// Ax throwing range
visit_ax_throwing:
    ldx #0
ax_loop:
        lda ax_throw_msg,X
        beq ax_done
        jsr modem_out
        inx
        bne ax_loop
ax_done:
    jsr modem_in
    jmp town_show_menu

// Local jail
visit_jail:
    ldx #0
jail_loop:
        lda jail_msg,X
        beq jail_done
        jsr modem_out
        inx
        bne jail_loop
jail_done:
    jsr modem_in
    ; place player in jail for a longer time (6 turns)
    lda #6
    sta detain_timer
    lda #2
    sta detain_type
    ; immediately show detained message
    ldx #0
detain_jail_print:
    lda detained_jail_msg,X
    beq detain_jail_print_done
    jsr modem_out
    inx
    bne detain_jail_print
detain_jail_print_done:
    jsr modem_in
    jmp town_show_menu

// Post Office (reachable from marketplace)
visit_post_office:
    ldx #0
post_loop:
        lda post_office_msg,X
        beq post_done
        jsr modem_out
        inx
        bne post_loop
post_done:
    jsr modem_in
    jmp visit_marketplace

// Mine location - accessible from the marketplace (option 3)
visit_mine:
    ldx #0
mine_loop:
        lda mine_msg,X
        beq mine_done
        jsr modem_out
        inx
        bne mine_loop
mine_done:
    jsr modem_in
    ; show mine menu
    ldx #0
mine_menu_print:
    lda mine_menu_msg,X
    beq mine_menu_print_done
    jsr modem_out
    inx
    bne mine_menu_print
mine_menu_print_done:
    jsr modem_in
    cmp #'1'
    beq mine_do_mine
    cmp #'0'
    beq mine_leave
    jmp visit_mine

mine_do_mine:
    ; Check stamina
    lda player_stamina
    beq mine_too_tired
    ; Search inventory for a usable pickaxe (id=14, durability in slot+2)
    lda player_inventory_count
    beq mine_no_pickaxe_use
    ldy #0
mine_find_pickaxe_loop:
    cpy player_inventory_count
    beq mine_no_pickaxe_use
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #14
    bne mine_find_pickaxe_next
    lda player_inventory+2,X
    cmp #0
    beq mine_find_pickaxe_next
    ; found usable pickaxe in slot Y (X points to slot base)
    ; decrement durability in-place
    dec player_inventory+2,X
    ; small stamina cost
    dec player_stamina
    ; if durability reached 0, remove the slot and notify
    lda player_inventory+2,X
    beq mine_pickaxe_broken_slot
    jmp mine_roll

mine_find_pickaxe_next:
    iny
    jmp mine_find_pickaxe_loop

mine_pickaxe_broken_slot:
    ; inform player
    ldx #0
    lda craft_pickaxe_broken_msg,X
    beq mine_pickaxe_broken_done
    jsr modem_out
    inx
    bne mine_pickaxe_broken_slot
mine_pickaxe_broken_done:
    jsr modem_in
    ; remove this inventory slot (X currently points to slot base)
    ; compute slot index in Y (from X): Y = X/4
    tya
    ; shift subsequent slots down
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
mine_shift_loop_broken:
    cpy craft_tmp2
    beq mine_shift_done_broken
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp mine_shift_loop_broken
mine_shift_done_broken:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp visit_mine

mine_no_pickaxe_use:
    ; no pickaxe: higher stamina cost and worse odds
    dec player_stamina
    dec player_stamina
    jmp mine_roll

mine_too_tired:
    ldx #0
    lda mine_tired_msg,X
    beq mine_tired_done
    jsr modem_out
    inx
    bne mine_tired
mine_tired_done:
    jsr modem_in
    jmp visit_mine

mine_roll:
    ; RNG to determine result
    jsr get_random
    and #$07
    ; 0-3: nothing, 4-5: copper, 6: iron, 7: silver/gem mixed
    cmp #4
    bcc mine_no_ore
    cmp #5
    beq mine_copper
    cmp #6
    beq mine_iron
    cmp #7
    beq mine_silver
    jmp mine_no_ore

mine_no_ore:
    ldx #0
mine_no_print:
    lda mine_no_ore_msg,X
    beq mine_no_done
    jsr modem_out
    inx
    bne mine_no_print
mine_no_done:
    jsr modem_in
    jmp visit_mine

; Generic helper: add item id in A with count=1
; Search for existing slot, else append if space
mine_add_item:
    ; A = item id
    pha
    lda player_inventory_count
    beq mine_append_item
    ldy #0
mine_find_slot:
    cpy player_inventory_count
    beq mine_append_item
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp (0),y ; placeholder, will be replaced by A from stack
    ; instead, pull from stack to X - we'll implement differently below
    iny
    jmp mine_find_slot

; (simpler implementation follows inline per resource)

mine_copper:
    ; item id for Copper is 8
    lda #8
    jsr mine_add_or_increment
    ldx #0
mine_copper_print:
    lda mine_copper_msg,X
    beq mine_copper_done
    jsr modem_out
    inx
    bne mine_copper_print
mine_copper_done:
    jsr modem_in
    jmp visit_mine

mine_too_tired:
    ldx #0
mine_tired:
    lda mine_tired_msg,X
    beq mine_tired_done
    jsr modem_out
    inx
    bne mine_tired
mine_tired_done:
    jsr modem_in
    jmp visit_mine

mine_broken_pickaxe:
    ldx #0
mine_broken_print:
    lda craft_pickaxe_broken_msg,X
    beq mine_broken_done
    jsr modem_out
    inx
    bne mine_broken_print
mine_broken_done:
    jsr modem_in
    jmp visit_mine

mine_iron:
    lda #9
    jsr mine_add_or_increment
    ldx #0
mine_iron_print:
    lda mine_iron_msg,X
    beq mine_iron_done
    jsr modem_out
    inx
    bne mine_iron_print
mine_iron_done:
    jsr modem_in
    jmp visit_mine

mine_silver:
    lda #10
    jsr mine_add_or_increment
    ldx #0
mine_silver_print:
    lda mine_silver_msg,X
    beq mine_silver_done
    jsr modem_out
    inx
    bne mine_silver_print
mine_silver_done:
    jsr modem_in
    jmp visit_mine

mine_gem:
    lda #6
    jsr mine_add_or_increment
    ldx #0
mine_gem_print:
    lda mine_gem_msg,X
    beq mine_gem_done
    jsr modem_out
    inx
    bne mine_gem_print
mine_gem_done:
    jsr modem_in
    jmp visit_mine

mine_leave:
    jmp visit_marketplace

// Gem Quarry - dig for various gems used for cutting and crafting
visit_quarry:
    ldx #0
quarry_loop:
        lda quarry_msg,X
        beq quarry_done
        jsr modem_out
        inx
        bne quarry_loop
quarry_done:
    jsr modem_in
    ; show quarry menu
    ldx #0
quarry_menu_print:
    lda quarry_menu_msg,X
    beq quarry_menu_print_done
    jsr modem_out
    inx
    bne quarry_menu_print
quarry_menu_print_done:
    jsr modem_in
    cmp #'1'
    beq quarry_dig
    cmp #'0'
    beq quarry_leave
    jmp visit_quarry

quarry_dig:
    ; Check stamina
    lda player_stamina
    beq quarry_too_tired
    ; Search inventory for usable pickaxe (id=14)
    lda player_inventory_count
    beq quarry_no_pickaxe_use
    ldy #0
quarry_find_pickaxe_loop:
    cpy player_inventory_count
    beq quarry_no_pickaxe_use
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #14
    bne quarry_find_pickaxe_next
    lda player_inventory+2,X
    cmp #0
    beq quarry_find_pickaxe_next
    ; use this pickaxe
    dec player_inventory+2,X
    dec player_stamina
    lda player_inventory+2,X
    beq quarry_pickaxe_broken_slot
    jmp quarry_roll

quarry_find_pickaxe_next:
    iny
    jmp quarry_find_pickaxe_loop

quarry_pickaxe_broken_slot:
    ldx #0
    lda craft_pickaxe_broken_msg,X
    beq quarry_pickaxe_broken_done
    jsr modem_out
    inx
    bne quarry_pickaxe_broken_slot
quarry_pickaxe_broken_done:
    jsr modem_in
    ; remove broken slot (same shifting logic as elsewhere)
    tya
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
quarry_shift_loop_broken:
    cpy craft_tmp2
    beq quarry_shift_done_broken
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp quarry_shift_loop_broken
quarry_shift_done_broken:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp visit_quarry

quarry_no_pickaxe_use:
    dec player_stamina
    jmp quarry_roll

quarry_too_tired:
    ldx #0
    lda mine_tired_msg,X
    beq quarry_tired_done
    jsr modem_out
    inx
    bne quarry_tired
quarry_tired_done:
    jsr modem_in
    jmp visit_quarry

quarry_roll:
    jsr get_random
    and #$0F
    ; Probabilities: 0-8 nothing, 9-11 common, 12-13 rare, 14-15 very rare
    cmp #9
    bcc quarry_no_ore
    cmp #12
    bcc quarry_common
    cmp #14
    bcc quarry_rare
    jmp quarry_very_rare

quarry_no_ore:
    ldx #0
quarry_no_print:
    lda quarry_no_ore_msg,X
    beq quarry_no_done
    jsr modem_out
    inx
    bne quarry_no_print
quarry_no_done:
    jsr modem_in
    jmp visit_quarry

quarry_common:
    lda #6        ; generic Gem id
    jsr mine_add_or_increment
    ldx #0
quarry_common_print:
    lda quarry_common_gem_msg,X
    beq quarry_common_done
    jsr modem_out
    inx
    bne quarry_common_print
quarry_common_done:
    jsr modem_in
    jmp visit_quarry

quarry_too_tired:
    ldx #0
    lda mine_tired_msg,X
    beq quarry_tired_done2
    jsr modem_out
    inx
    bne quarry_tired
quarry_tired_done2:
    jsr modem_in
    jmp visit_quarry

quarry_rare:
    ; give 2 gems for rare
    lda #6
    jsr mine_add_or_increment
    lda #6
    jsr mine_add_or_increment
    ldx #0
quarry_rare_print:
    lda quarry_rare_gem_msg,X
    beq quarry_rare_done
    jsr modem_out
    inx
    bne quarry_rare_print
quarry_rare_done:
    jsr modem_in
    jmp visit_quarry

quarry_very_rare:
    ; give 3 gems (very lucky)
    lda #6
    jsr mine_add_or_increment
    lda #6
    jsr mine_add_or_increment
    lda #6
    jsr mine_add_or_increment
    ldx #0
quarry_vrare_print:
    lda quarry_rare_gem_msg,X
    beq quarry_vrare_done
    jsr modem_out
    inx
    bne quarry_vrare_print
quarry_vrare_done:
    jsr modem_in
    jmp visit_quarry

quarry_leave:
    jmp visit_marketplace

; -------------------------
; Subroutine: mine_add_or_increment
; Input: A = item id
; Behavior: if item exists in inventory, increment count; else append if space; else print no-space in caller
mine_add_or_increment:
    ; A = item id
    sta craft_temp        ; save desired id
    lda player_inventory_count
    beq mine_append_direct
    ldy #0
mine_search_loop:
    cpy player_inventory_count
    beq mine_append_direct
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp craft_temp
    bne mine_search_next
    ; found slot: if this item has a non-zero durability (craft_tmp2) we DO NOT stack - append new item
    lda craft_tmp2
    beq mine_do_stackable
    ; durability present -> skip stacking, search next
    jmp mine_search_next
mine_do_stackable:
    ; otherwise increment count
    inc player_inventory+1,X
    rts
mine_search_next:
    iny
    jmp mine_search_loop

mine_append_direct:
    ; check space
    lda player_inventory_count
    cmp #8
    bcs mine_no_space
    ; compute dest index = count*4
    lda player_inventory_count
    tay
    tya
    asl
    asl
    tax
    lda craft_temp
    sta player_inventory,X
    lda #1
    sta player_inventory+1,X
    ; if adding an item with initial durability (craft_tmp2 != 0), place it in slot+2
    lda craft_tmp2
    beq mine_append_no_dur
    sta player_inventory+2,X
    jmp mine_append_done
mine_append_no_dur:
    lda #0
    sta player_inventory+2,X
mine_append_done:
    inc player_inventory_count
    rts

mine_no_space:
    rts

; -------------------------
; Subroutine: consume_items
; Inputs: craft_temp = item id, craft_tmp2 = quantity to remove
; Precondition: caller has already verified enough total quantity exists
; Behavior: removes `craft_tmp2` units across slots (may remove from multiple slots).
; Returns: craft_tmp2 = 0 on success
consume_items:
    ldy #0
consume_loop:
    cpy player_inventory_count
    beq consume_done_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp craft_temp
    bne consume_next_slot
    lda player_inventory+1,X
    cmp #0
    beq consume_next_slot
    ; if slot_count >= needed
    lda player_inventory+1,X
    cmp craft_tmp2
    bcs consume_slot_enough
    ; slot_count < needed -> subtract slot_count from needed and remove slot
    lda craft_tmp2
    sec
    sbc player_inventory+1,X
    sta craft_tmp2
    ; remove this slot by shifting remaining slots left
    lda player_inventory_count
    sec
    sbc #1
    sta temp_amount
    tya
consume_shift_loop:
    cpy temp_amount
    beq consume_shift_done
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp consume_shift_loop
consume_shift_done:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    ; continue scanning at same Y (slot now contains next slot), do not iny
    jmp consume_loop
consume_slot_enough:
    ; slot has enough to cover remaining need
    lda player_inventory+1,X
    sec
    sbc craft_tmp2
    sta player_inventory+1,X
    lda #0
    sta craft_tmp2
    rts
consume_next_slot:
    iny
    jmp consume_loop
consume_done_fail:
    ; shouldn't happen if caller pre-validated counts; return with craft_tmp2 unchanged
    rts

; -------------------------
; Subroutine: craft_execute
; Input: A = recipe_index (0-based index into recipes_table)
; Output: craft_last_result = 0 success,1 not found,2 insufficient materials,3 chance failure
; Behavior: validates inputs, consumes them via `consume_items`, applies success chance,
;           and on success adds outputs via `mine_add_or_increment`.
craft_execute:
    sta temp_amount        ; temp_amount = recipe_index
    lda temp_amount
    cmp recipe_count
    bcs craft_not_found    ; if index >= recipe_count -> not found
    ; build pointer to recipes_table base
    lda #<recipes_table
    sta recipes_ptr_lo
    lda #>recipes_table
    sta recipes_ptr_hi
    ; advance pointer by (index * 15) bytes
    lda temp_amount
    beq craft_have_ptr
craft_ptr_loop:
    lda recipes_ptr_lo
    clc
    adc #15
    sta recipes_ptr_lo
    lda recipes_ptr_hi
    adc #0
    sta recipes_ptr_hi
    dec temp_amount
    bne craft_ptr_loop
craft_have_ptr:
    ; read fields from table using (recipes_ptr_lo),Y addressing
    ldy #0
    lda (recipes_ptr_lo),y   ; recipe_id
    sta craft_temp
    iny
    lda (recipes_ptr_lo),y   ; station_id (ignored by this generic executor)
    iny
    lda (recipes_ptr_lo),y   ; output_id
    sta craft_out_id
    iny
    lda (recipes_ptr_lo),y   ; output_qty
    sta craft_out_qty
    iny
    lda (recipes_ptr_lo),y   ; output_dur
    sta craft_out_dur
    iny
    lda (recipes_ptr_lo),y   ; input1_id
    sta craft_in1_id
    iny
    lda (recipes_ptr_lo),y   ; input1_qty
    sta craft_in1_qty
    iny
    lda (recipes_ptr_lo),y   ; input2_id
    sta craft_in2_id
    iny
    lda (recipes_ptr_lo),y   ; input2_qty
    sta craft_in2_qty
    iny
    lda (recipes_ptr_lo),y   ; input3_id
    sta craft_in3_id
    iny
    lda (recipes_ptr_lo),y   ; input3_qty
    sta craft_in3_qty
    iny
    lda (recipes_ptr_lo),y   ; time_ticks (ignored)
    iny
    lda (recipes_ptr_lo),y   ; success_rate
    sta craft_success_rate
    ; pre-validate inputs: ensure enough of each non-255 input exists
    jsr craft_prevalidate
    lda craft_last_result
    cmp #0
    bne craft_pre_done
    ; consume inputs (using consume_items) in order
    lda craft_in1_id
    cmp #255
    beq craft_skip_in1
    sta craft_temp
    lda craft_in1_qty
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne craft_consume_error
craft_skip_in1:
    lda craft_in2_id
    cmp #255
    beq craft_skip_in2
    sta craft_temp
    lda craft_in2_qty
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne craft_consume_error
craft_skip_in2:
    lda craft_in3_id
    cmp #255
    beq craft_skip_in3
    sta craft_temp
    lda craft_in3_qty
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne craft_consume_error
craft_skip_in3:
    ; success chance
    lda craft_success_rate
    sta temp_amount
    jsr get_random
    cmp temp_amount
    bcc craft_success
    ; failure (materials consumed)
    lda #3
    sta craft_last_result
    rts
; Subroutine: craft_prevalidate
; Checks for sufficient materials for craft_in1/2/3; sets craft_last_result=0 on success or 2 on insufficient
craft_prevalidate:
    lda #0
    sta craft_last_result
    ; check input1
    lda craft_in1_id
    cmp #255
    beq craft_check_in2
    lda #0
    sta temp_amount      ; sum
    ldy #0
craft_pre_find1:
    cpy player_inventory_count
    beq craft_pre_found1
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp craft_in1_id
    bne craft_pre_next1
    lda player_inventory+1,X
    clc
    adc temp_amount
    sta temp_amount
craft_pre_next1:
    iny
    bne craft_pre_find1
craft_pre_found1:
    lda temp_amount
    cmp craft_in1_qty
    bcs craft_check_in2
    lda #2
    sta craft_last_result
    rts
craft_check_in2:
    lda craft_in2_id
    cmp #255
    beq craft_check_in3
    lda #0
    sta temp_amount
    ldy #0
craft_pre_find2:
    cpy player_inventory_count
    beq craft_pre_found2
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp craft_in2_id
    bne craft_pre_next2
    lda player_inventory+1,X
    clc
    adc temp_amount
    sta temp_amount
craft_pre_next2:
    iny
    bne craft_pre_find2
craft_pre_found2:
    lda temp_amount
    cmp craft_in2_qty
    bcs craft_check_in3
    lda #2
    sta craft_last_result
    rts
craft_check_in3:
    lda craft_in3_id
    cmp #255
    beq craft_pre_ok
    lda #0
    sta temp_amount
    ldy #0
craft_pre_find3:
    cpy player_inventory_count
    beq craft_pre_found3
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp craft_in3_id
    bne craft_pre_next3
    lda player_inventory+1,X
    clc
    adc temp_amount
    sta temp_amount
craft_pre_next3:
    iny
    bne craft_pre_find3
craft_pre_found3:
    lda temp_amount
    cmp craft_in3_qty
    bcs craft_pre_ok
    lda #2
    sta craft_last_result
    rts
craft_pre_ok:
    lda #0
    sta craft_last_result
    rts
craft_consume_error:
    ; unexpected consume failure
    lda #2
    sta craft_last_result
    rts
craft_success:
    ; add outputs
    lda craft_out_qty
    beq craft_done_ok
    sta temp_amount
craft_output_loop:
    lda craft_out_dur
    sta craft_tmp2
    lda craft_out_id
    jsr mine_add_or_increment
    dec temp_amount
    bne craft_output_loop
    lda #0
    sta craft_last_result
    rts
craft_pre_done:
    rts
craft_not_found:
    lda #1
    sta craft_last_result
    rts


// Forge - blacksmith location
visit_forge:
    ldx #0
forge_desc_loop:
        lda forge_msg,X
        beq forge_done
        jsr modem_out
        inx
        bne forge_desc_loop
forge_done:
    jsr modem_in
    ; Enter simple crafting menu
    ldx #0
forge_menu_print:
    lda forge_menu_msg,X
    beq forge_menu_print_done
    jsr modem_out
    inx
    bne forge_menu_print
forge_menu_print_done:
    jsr modem_in
    ; handle choice
    cmp #'1'
    beq forge_do_ring
    cmp #'2'
    beq forge_do_amulet
    cmp #'3'
    beq forge_do_potion
    cmp #'4'
    beq forge_do_pickaxe
    cmp #'5'
    beq forge_cut_gem
    cmp #'6'
    beq forge_do_knife
    cmp #'7'
    beq forge_do_dagger
    cmp #'8'
    beq forge_do_hammer
    cmp #'9'
    beq forge_do_axe
    cmp #'a'
    beq forge_do_sword
    cmp #'b'
    beq forge_do_shield
    cmp #'c'
    beq forge_do_armor
    cmp #'0'
    beq forge_leave
    cmp #'x'
    beq visit_craft_menu
    jmp visit_forge

; -------------------------
; Small debug crafting menu: enter recipe index and execute
craft_menu_msg:
    .text "\r\nCRAFTING MENU:\r\nEnter recipe index (0-99), then press Enter.\r\n> "
    .byte 0
craft_prompt_msg:
    .text "\r\nExecuting recipe...\r\n"
    .byte 0
craft_success_msg:
    .text "\r\nCrafting succeeded!\r\n"
    .byte 0
craft_insuff_msg:
    .text "\r\nNot enough materials.\r\n"
    .byte 0
craft_fail_msg:
    .text "\r\nCrafting failed (chance).\r\n"
    .byte 0
craft_notfound_msg:
    .text "\r\nRecipe not found.\r\n"
    .byte 0

visit_craft_menu:
    ; print header
    ldx #0
craft_menu_print:
    lda craft_menu_msg,X
    beq craft_menu_print_done
    jsr modem_out
    inx
    bne craft_menu_print
craft_menu_print_done:
    ; read single digit (0-9) to select recipe index (debug)
    jsr modem_in
    ; convert ASCII digit to 0-9
    sec
    sbc #'0'
    cmp #10
    bcc craft_index_ok
    ; invalid -> not found
    lda #1
    sta craft_last_result
    jmp craft_result_notfound
craft_index_ok:
    ; A already contains numeric index
    jsr craft_execute
    lda craft_last_result
    cmp #0
    beq craft_result_ok
    cmp #2
    beq craft_result_insuff
    cmp #3
    beq craft_result_fail
    cmp #1
    beq craft_result_notfound
    jmp craft_menu_done
craft_result_ok:
    ldx #0
craft_result_ok_print:
    lda craft_success_msg,X
    beq craft_result_ok_done
    jsr modem_out
    inx
    bne craft_result_ok_print
craft_result_ok_done:
    jmp craft_menu_done
craft_result_insuff:
    ldx #0
craft_result_insuff_print:
    lda craft_insuff_msg,X
    beq craft_result_insuff_done
    jsr modem_out
    inx
    bne craft_result_insuff_print
craft_result_insuff_done:
    jmp craft_menu_done
craft_result_fail:
    ldx #0
craft_result_fail_print:
    lda craft_fail_msg,X
    beq craft_result_fail_done
    jsr modem_out
    inx
    bne craft_result_fail_print
craft_result_fail_done:
    jmp craft_menu_done
craft_result_notfound:
    ldx #0
craft_result_notfound_print:
    lda craft_notfound_msg,X
    beq craft_result_notfound_done
    jsr modem_out
    inx
    bne craft_result_notfound_print
craft_result_notfound_done:
    jmp craft_menu_done
craft_menu_done:
    jsr modem_in
    rts

; -------------------------
; Craft: Ring (needs 2 Gems, gem id=6, ring id=3)
forge_do_ring:
    ; First, check for a specific cut gem (Ruby/Sapphire/Emerald) to make a special ring
    ldy #0
forge_check_special_gem:
    cpy player_inventory_count
    beq forge_check_special_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #11
    beq forge_make_ruby_ring
    cmp #12
    beq forge_make_sapphire_ring
    cmp #13
    beq forge_make_emerald_ring
    iny
    bne forge_check_special_gem
forge_check_special_done:
    ; count gems in inventory
    lda #0
    sta craft_temp
    ldy #0
forge_count_gems:
    cpy player_inventory_count
    beq forge_count_gems_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne forge_next_gem_slot
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_gem_slot:
    iny
    bne forge_count_gems
forge_count_gems_done:
    lda craft_temp
    cmp #2
    bcc forge_not_enough_materials
    ; remove 2 gems from first gem slot found
    ldy #0
forge_find_gem_slot:
    cpy player_inventory_count
    beq forge_remove_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne forge_find_gem_next
    ; found gem slot at X
    ; consume 2 Gems (id 6) across slots using consume_items
    lda #6
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq forge_add_ring
    jmp forge_not_enough_materials
forge_find_gem_next:
    iny
    bne forge_find_gem_slot
forge_remove_fail:
    jmp forge_not_enough_materials

forge_shift_remove_slot:
    ; Y holds slot index; shift later slots left
    ; compute last index = player_inventory_count - 1
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2 ; last index
    ; Z = Y .. last-1: copy slot Z+1 to Z (4 bytes)
    ldx #0
    tya
    ; use Y as start index
forge_shift_loop:
    cpy craft_tmp2
    beq forge_shift_done
    ; compute src = (Y+1)*4
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    ; copy 4 bytes from src to dest
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop
forge_shift_done:
    ; decrement player_inventory_count
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp forge_add_ring

; Add crafted ring to inventory
forge_add_ring:
    ; try to find existing Ring (id 3)
    ldy #0
forge_find_ring_slot:
    cpy player_inventory_count
    beq forge_append_ring
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #3
    bne forge_find_ring_next
    ; increment count
    inc player_inventory+1,X
    jmp craft_ring_done
forge_find_ring_next:
    iny
    bne forge_find_ring_slot

forge_append_ring:
    ; ensure there is space
    lda player_inventory_count
    cmp #8
    bcs craft_no_space
    ; compute X = count * 4
    tya
    lda player_inventory_count
    tay
    tya
    asl
    asl
    tax
    lda #3
    sta player_inventory,X
    lda #1
    sta player_inventory+1,X
    inc player_inventory_count

craft_ring_done:
    ldx #0
    lda craft_ring_success_msg,X
    beq craft_ring_done2
    jsr modem_out
    inx
    bne craft_ring_done
craft_ring_done2:
    jsr modem_in
    jmp visit_forge

; Special ring makers (consume one cut gem and add special ring)
forge_make_ruby_ring:
    ; consume 1 Ruby (id 11) across slots using consume_items
    lda #11
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    ; add Ruby Ring (id 15)
    lda #15
    jsr mine_add_or_increment
    ldx #0
    lda craft_ring_ruby_msg,X
    beq craft_ring_ruby_done
    jsr modem_out
    inx
    bne forge_make_ruby_ring
craft_ring_ruby_done:
    jsr modem_in
    jmp visit_forge

forge_make_sapphire_ring:
    ; consume 1 Sapphire (id 12) across slots using consume_items
    lda #12
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #16
    jsr mine_add_or_increment
    ldx #0
    lda craft_ring_sapphire_msg,X
    beq craft_ring_sapphire_done
    jsr modem_out
    inx
    bne forge_make_sapphire_ring
craft_ring_sapphire_done:
    jsr modem_in
    jmp visit_forge

forge_make_emerald_ring:
    ; consume 1 Emerald (id 13) across slots using consume_items
    lda #13
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #17
    jsr mine_add_or_increment
    ldx #0
    lda craft_ring_emerald_msg,X
    beq craft_ring_emerald_done
    jsr modem_out
    inx
    bne forge_make_emerald_ring
craft_ring_emerald_done:
    jsr modem_in
    jmp visit_forge

; -------------------------
; Craft: Amulet (needs 3 Gems, amulet id=4)
forge_do_amulet:
    ; First, check for a specific cut gem to make a special amulet
    ldy #0
forge_check_spec_amulet:
    cpy player_inventory_count
    beq forge_check_spec_amulet_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #11
    beq forge_make_ruby_amulet
    cmp #12
    beq forge_make_sapphire_amulet
    cmp #13
    beq forge_make_emerald_amulet
    iny
    bne forge_check_spec_amulet
forge_check_spec_amulet_done:
    ; count gems
    lda #0
    sta craft_temp
    ldy #0
forge_count_gems2:
    cpy player_inventory_count
    beq forge_count_gems2_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne forge_next_gem_slot2
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_gem_slot2:
    iny
    bne forge_count_gems2
forge_count_gems2_done:
    lda craft_temp
    cmp #3
    bcc forge_not_enough_materials
    ; remove 3 gems (similar to ring removal — reduce count by 3)
    ldy #0
forge_find_gem_slot2:
    cpy player_inventory_count
    beq forge_remove_fail2
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne forge_find_gem_next2
    ; consume 3 Gems (id 6) across slots using consume_items
    lda #6
    sta craft_temp
    lda #3
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq forge_add_amulet
    jmp forge_not_enough_materials
forge_find_gem_next2:
    iny
    bne forge_find_gem_slot2
forge_remove_fail2:
    jmp forge_not_enough_materials

forge_shift_remove_slot2:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop2:
    cpy craft_tmp2
    beq forge_shift_done2
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop2
forge_shift_done2:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp forge_add_amulet

forge_add_amulet:
    ldy #0
forge_find_amulet_slot:
    cpy player_inventory_count
    beq forge_append_amulet
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #4
    bne forge_find_amulet_next
    inc player_inventory+1,X
    jmp craft_amulet_done
forge_find_amulet_next:
    iny
    bne forge_find_amulet_slot

forge_append_amulet:
    lda player_inventory_count
    cmp #8
    bcs craft_no_space
    lda player_inventory_count
    tay
    tya
    asl
    asl
    tax
    lda #4
    sta player_inventory,X
    lda #1
    sta player_inventory+1,X
    inc player_inventory_count

craft_amulet_done:
    ldx #0
    lda craft_amulet_success_msg,X
    beq craft_amulet_done2
    jsr modem_out
    inx
    bne craft_amulet_done
craft_amulet_done2:
    jsr modem_in
    jmp visit_forge

; Special amulet makers (consume one cut gem and add special amulet)
forge_make_ruby_amulet:
    ; consume 1 Ruby (id 11) across slots using consume_items
    lda #11
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #18
    jsr mine_add_or_increment
    ldx #0
    lda craft_amulet_ruby_msg,X
    beq craft_amulet_ruby_done
    jsr modem_out
    inx
    bne forge_make_ruby_amulet
craft_amulet_ruby_done:
    jsr modem_in
    jmp visit_forge

forge_make_sapphire_amulet:
    ; consume 1 Sapphire (id 12) across slots using consume_items
    lda #12
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #19
    jsr mine_add_or_increment
    ldx #0
    lda craft_amulet_sapphire_msg,X
    beq craft_amulet_sapphire_done
    jsr modem_out
    inx
    bne forge_make_sapphire_amulet
craft_amulet_sapphire_done:
    jsr modem_in
    jmp visit_forge

forge_make_emerald_amulet:
    ; consume 1 Emerald (id 13) across slots using consume_items
    lda #13
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #20
    jsr mine_add_or_increment
    ldx #0
    lda craft_amulet_emerald_msg,X
    beq craft_amulet_emerald_done
    jsr modem_out
    inx
    bne forge_make_emerald_amulet
craft_amulet_emerald_done:
    jsr modem_in
    jmp visit_forge

; -------------------------
; Craft: Potion (needs 1 Gem, potion id=2)
forge_do_potion:
    ; count gems
    lda #0
    sta craft_temp
    ldy #0
forge_count_gems3:
    cpy player_inventory_count
    beq forge_count_gems3_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne forge_next_gem_slot3
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_gem_slot3:
    iny
    bne forge_count_gems3
forge_count_gems3_done:
    lda craft_temp
    cmp #1
    bcc forge_not_enough_materials
    ; consume 4 Iron (id 9) then proceed to planks removal
    lda #9
    sta craft_temp
    lda #4
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    jmp forge_remove_planks_after_iron_s
    sta player_inventory_count
    jmp forge_add_potion

forge_add_potion:
    ldy #0
forge_find_potion_slot:
    cpy player_inventory_count
    beq forge_append_potion
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #2
    bne forge_find_potion_next
    inc player_inventory+1,X
    jmp craft_potion_done
forge_find_potion_next:
    iny
    bne forge_find_potion_slot

forge_append_potion:
    lda player_inventory_count
    cmp #8
    bcs craft_no_space
    lda player_inventory_count
    tay
    tya
    asl
    asl
    tax
    lda #2
    sta player_inventory,X
    lda #1
    sta player_inventory+1,X
    inc player_inventory_count

craft_potion_done:
    ldx #0
    lda craft_potion_success_msg,X
    beq craft_potion_done2
    jsr modem_out
    inx
    bne craft_potion_done
craft_potion_done2:
    jsr modem_in
    jmp visit_forge

; -------------------------
; Forge: Make Pickaxe (needs 2 Iron - id 9)
forge_do_pickaxe:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron:
    cpy player_inventory_count
    beq forge_count_iron_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_slot
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_slot:
    iny
    bne forge_count_iron
forge_count_iron_done:
    lda craft_temp
    cmp #2
    bcc forge_not_enough_materials
    ; ensure at least 1 plank (id 22) is present
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_plank:
    cpy player_inventory_count
    beq forge_count_plank_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #22
    bne forge_next_plank_slot
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_plank_slot:
    iny
    bne forge_count_plank
forge_count_plank_done:
    lda craft_tmp2
    cmp #1
    bcc forge_not_enough_materials
    ; remove 2 iron from first iron slot
    ldy #0
forge_find_iron_slot:
    cpy player_inventory_count
    beq forge_remove_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_find_iron_next
    ; consume 2 Iron (id 9) across slots using consume_items
    lda #9
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq forge_create_pickaxe
    jmp forge_not_enough_materials
forge_find_iron_next:
    iny
    bne forge_find_iron_slot
forge_remove_fail:
    jmp forge_not_enough_materials

forge_shift_remove_slot_iron:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_iron:
    cpy craft_tmp2
    beq forge_shift_done_iron
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_iron
forge_shift_done_iron:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp forge_create_pickaxe

forge_create_pickaxe:
    ; add pickaxe to inventory and set per-slot durability
    ; desired durability in craft_tmp2
    lda #30
    sta craft_tmp2
    lda #14
    jsr mine_add_or_increment
    ; (durability set via craft_tmp2 when appending)
    ldx #0
forge_pickaxe_print:
    lda craft_pickaxe_success_msg,X
    beq forge_pickaxe_done
    jsr modem_out
    inx
    bne forge_pickaxe_print
forge_pickaxe_done:
    jsr modem_in
    ; also remove one plank (id 22) from inventory now that pickaxe is created
    lda #0
    sta craft_tmp2
    ldy #0
forge_remove_plank_find:
    cpy player_inventory_count
    beq forge_remove_plank_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #22
    bne forge_remove_plank_next
    ; consume 1 Plank (id 22) across slots
    lda #22
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq forge_remove_plank_done
    jmp forge_not_enough_materials
forge_remove_plank_next:
    iny
    jmp forge_remove_plank_find
forge_remove_plank_shift:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_remove_plank_shift_loop:
    cpy craft_tmp2
    beq forge_remove_plank_shift_done
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_remove_plank_shift_loop
forge_remove_plank_shift_done:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp visit_forge
forge_remove_plank_done:
    jmp visit_forge

craft_pickaxe_success_msg:
    .text "\r\nYou forge a sturdy pickaxe. It feels balanced in your hands.\r\n[Press any key]\r\n"
    .byte 0

craft_pickaxe_broken_msg:
    .text "\r\nYour pickaxe snaps with a harsh crack and is no longer usable.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Cut Gem (1 generic Gem -> Ruby/Sapphire/Emerald)
forge_cut_gem:
    ; ensure player has at least 1 generic Gem (id 6)
    lda #0
    sta craft_temp
    ldy #0
forge_count_gem_for_cut:
    cpy player_inventory_count
    beq forge_count_gem_for_cut_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne forge_next_gem_cut_slot
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_gem_cut_slot:
    iny
    bne forge_count_gem_for_cut
forge_count_gem_for_cut_done:
    lda craft_temp
    cmp #1
    bcc forge_not_enough_materials
    ; remove one generic gem from first gem slot
    ldy #0
forge_find_gem_cut_slot:
    cpy player_inventory_count
    beq forge_remove_fail_cut
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne forge_find_gem_cut_next
    ; consume 1 Gem (id 6) across slots using consume_items
    lda #6
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq forge_produce_cut_gem
    jmp forge_not_enough_materials
forge_find_gem_cut_next:
    iny
    bne forge_find_gem_cut_slot
forge_remove_fail_cut:
    jmp forge_not_enough_materials

forge_shift_remove_slot_cut:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_cut:
    cpy craft_tmp2
    beq forge_shift_done_cut
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_cut
forge_shift_done_cut:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp forge_produce_cut_gem

forge_produce_cut_gem:
    jsr get_random
    and #$03
    cmp #0
    beq forge_make_ruby
    cmp #1
    beq forge_make_sapphire
    jmp forge_make_emerald

forge_make_ruby:
    lda #11
    jsr mine_add_or_increment
    ldx #0
    lda craft_ruby_msg,X
    beq forge_ruby_done
    jsr modem_out
    inx
    bne forge_make_ruby
forge_ruby_done:
    jsr modem_in
    jmp visit_forge

forge_make_sapphire:
    lda #12
    jsr mine_add_or_increment
    ldx #0
    lda craft_sapphire_msg,X
    beq forge_sapphire_done
    jsr modem_out
    inx
    bne forge_make_sapphire
forge_sapphire_done:
    jsr modem_in
    jmp visit_forge

forge_make_emerald:
    lda #13
    jsr mine_add_or_increment
    ldx #0
    lda craft_emerald_msg,X
    beq forge_emerald_done
    jsr modem_out
    inx
    bne forge_make_emerald
forge_emerald_done:
    jsr modem_in
    jmp visit_forge

craft_ruby_msg:
    .text "\r\nYou carefully cut the rough stone; it's a modest ruby.\r\n[Press any key]\r\n"
    .byte 0
craft_sapphire_msg:
    .text "\r\nAfter patient work, a deep blue sapphire sits in your palm.\r\n[Press any key]\r\n"
    .byte 0
craft_emerald_msg:
    .text "\r\nA bright green emerald sparks from the rough — a fine cut indeed.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; -------------------------
; Tannery - convert Hide -> Leather
visit_tannery:
    ldx #0
tannery_desc_loop:
        lda tannery_msg,X
        beq tannery_menu
        jsr modem_out
        inx
        bne tannery_desc_loop
tannery_menu:
    ldx #0
    lda tannery_menu_msg,X
    beq tannery_menu_done
    jsr modem_out
    inx
    bne tannery_menu
tannery_menu_done:
    jsr modem_in
    cmp #'1'
    beq tannery_do_tan
    cmp #'0'
    beq tannery_leave
    jmp visit_tannery

tannery_do_tan:
    ; ensure at least 1 Hide (id 26)
    lda #0
    sta craft_temp
    ldy #0
tannery_count_hide:
    cpy player_inventory_count
    beq tannery_count_hide_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #26
    bne tannery_next_hide
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
tannery_next_hide:
    iny
    bne tannery_count_hide
tannery_count_hide_done:
    lda craft_temp
    cmp #1
    bcc tannery_not_enough
    ; remove one hide from first hide slot
    ldy #0
tannery_find_hide_slot:
    cpy player_inventory_count
    beq tannery_remove_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #26
    bne tannery_find_hide_next
    ; consume 1 Hide (id 26) across slots
    lda #26
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq tannery_produce_leather
    jmp tannery_not_enough
tannery_find_hide_next:
    iny
    bne tannery_find_hide_slot
tannery_remove_fail:
    jmp tannery_not_enough

tannery_shift_remove_slot:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
tannery_shift_loop:
    cpy craft_tmp2
    beq tannery_shift_done
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp tannery_shift_loop
tannery_shift_done:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp tannery_produce_leather

tannery_produce_leather:
    ; add Leather (id 27)
    lda #27
    jsr mine_add_or_increment
    ldx #0
    lda tannery_done_msg,X
    beq tannery_done_done
    jsr modem_out
    inx
    bne tannery_produce_leather
tannery_done_done:
    jsr modem_in
    jmp visit_tannery

tannery_not_enough:
    ldx #0
    lda tannery_no_hide_msg,X
    beq tannery_not_enough_done
    jsr modem_out
    inx
    bne tannery_not_enough
tannery_not_enough_done:
    jsr modem_in
    jmp visit_tannery

tannery_leave:
    jmp visit_marketplace

tannery_msg:
    .text "\r\nThe TANNERY smells of cure and smoke. Workers stretch hides over frames. Leather is prepared here for armor and goods.\r\n[Press any key]\r\n"
    .byte 0
tannery_menu_msg:
    .text "\r\nTANNERY - What would you like to do?\r\n1) Tan Hide -> Leather (requires 1 Hide)\r\n0) Leave\r\n> "
    .byte 0
tannery_done_msg:
    .text "\r\nYou tan the hide; it becomes supple leather suitable for crafting.\r\n[Press any key]\r\n"
    .byte 0
tannery_no_hide_msg:
    .text "\r\nYou don't have any hides to tan.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Knife (1 Iron + 1 Leather)
forge_do_knife:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron_k:
    cpy player_inventory_count
    beq forge_count_iron_k_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_k
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_k:
    iny
    bne forge_count_iron_k
forge_count_iron_k_done:
    lda craft_temp
    cmp #1
    bcc forge_not_enough_materials
    ; count leather (id 27)
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_leather_k:
    cpy player_inventory_count
    beq forge_count_leather_k_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_next_leather_k
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_leather_k:
    iny
    bne forge_count_leather_k
forge_count_leather_k_done:
    lda craft_tmp2
    cmp #1
    bcc forge_not_enough_materials
    ; consume 1 Iron (id 9) across slots using consume_items
    lda #9
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    ; now remove 1 leather (id 27)
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    jmp forge_create_knife

forge_shift_remove_slot_iron_k:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_iron_k:
    cpy craft_tmp2
    beq forge_shift_done_iron_k
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_iron_k
forge_shift_done_iron_k:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count

forge_remove_leather_after_iron_k:
    ; remove 1 leather from first leather slot
    ldy #0
forge_find_leather_slot_k:
    cpy player_inventory_count
    beq forge_remove_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_find_leather_next_k
    ; consume 1 Leather (id 27) across slots
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq forge_create_knife
    jmp forge_not_enough_materials
forge_find_leather_next_k:
    iny
    jmp forge_find_leather_slot_k

forge_shift_remove_slot_leather_k:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_leather_k:
    cpy craft_tmp2
    beq forge_shift_done_leather_k
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_leather_k
forge_shift_done_leather_k:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp forge_create_knife

forge_create_knife:
    lda #28 ; Knife id
    lda #25
    sta craft_tmp2 ; durability 25
    lda #28
    jsr mine_add_or_increment
    ldx #0
    lda craft_knife_success_msg,X
    beq forge_knife_done
    jsr modem_out
    inx
    bne forge_create_knife
forge_knife_done:
    jsr modem_in
    jmp visit_forge

craft_knife_success_msg:
    .text "\r\nYou forge a small knife; it's sharp and useful.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Dagger (2 Iron + 1 Leather)
forge_do_dagger:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron_d:
    cpy player_inventory_count
    beq forge_count_iron_d_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_d
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_d:
    iny
    bne forge_count_iron_d
forge_count_iron_d_done:
    lda craft_temp
    cmp #2
    bcc forge_not_enough_materials
    ; count leather (id 27)
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_leather_d:
    cpy player_inventory_count
    beq forge_count_leather_d_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_next_leather_d
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_leather_d:
    iny
    bne forge_count_leather_d
forge_count_leather_d_done:
    lda craft_tmp2
    cmp #1
    bcc forge_not_enough_materials
    ; consume 2 Iron (id 9) across slots using consume_items
    lda #9
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    ; consume 1 Leather (id 27)
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    jmp forge_create_dagger

forge_shift_remove_slot_iron_d:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_iron_d:
    cpy craft_tmp2
    beq forge_shift_done_iron_d
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_iron_d
forge_shift_done_iron_d:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count

forge_remove_leather_after_iron_d:
    ; remove 1 leather from first leather slot
    ldy #0
forge_find_leather_slot_d:
    cpy player_inventory_count
    beq forge_remove_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_find_leather_next_d
    ; consume 1 Leather (id 27) across slots for dagger
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq forge_create_dagger
    jmp forge_not_enough_materials
forge_find_leather_next_d:
    iny
    jmp forge_find_leather_slot_d

forge_shift_remove_slot_leather_d:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_leather_d:
    cpy craft_tmp2
    beq forge_shift_done_leather_d
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_leather_d
forge_shift_done_leather_d:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp forge_create_dagger

forge_create_dagger:
    lda #29 ; Dagger id
    lda #35
    sta craft_tmp2 ; durability 35
    lda #29
    jsr mine_add_or_increment
    ldx #0
    lda craft_dagger_success_msg,X
    beq forge_dagger_done
    jsr modem_out
    inx
    bne forge_create_dagger
forge_dagger_done:
    jsr modem_in
    jmp visit_forge

craft_dagger_success_msg:
    .text "\r\nYou craft a vicious dagger, light and deadly.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Hammer (2 Iron + 1 Plank)
forge_do_hammer:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron_h:
    cpy player_inventory_count
    beq forge_count_iron_h_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_h
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_h:
    iny
    bne forge_count_iron_h
forge_count_iron_h_done:
    lda craft_temp
    cmp #2
    bcc forge_not_enough_materials
    ; count plank (id 22)
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_plank_h:
    cpy player_inventory_count
    beq forge_count_plank_h_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #22
    bne forge_next_plank_h
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_plank_h:
    iny
    bne forge_count_plank_h
forge_count_plank_h_done:
    lda craft_tmp2
    cmp #1
    bcc forge_not_enough_materials
    ; consume 2 Iron (id 9) then 1 Plank (id 22) using consume_items
    lda #9
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #22
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    jmp forge_create_hammer

forge_create_hammer:
    lda #31 ; Hammer id
    lda #40
    sta craft_tmp2 ; durability 40
    lda #31
    jsr mine_add_or_increment
    ldx #0
    lda craft_hammer_success_msg,X
    beq forge_hammer_done
    jsr modem_out
    inx
    bne forge_create_hammer
forge_hammer_done:
    jsr modem_in
    jmp visit_forge

craft_hammer_success_msg:
    .text "\r\nYou forge a stout hammer, useful for heavy work.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Axe (2 Iron + 1 Plank + 1 Leather)
forge_do_axe:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron_x:
    cpy player_inventory_count
    beq forge_count_iron_x_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_x
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_x:
    iny
    bne forge_count_iron_x
forge_count_iron_x_done:
    lda craft_temp
    cmp #2
    bcc forge_not_enough_materials
    ; count plank (id 22)
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_plank_x:
    cpy player_inventory_count
    beq forge_count_plank_x_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #22
    bne forge_next_plank_x
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_plank_x:
    iny
    bne forge_count_plank_x
forge_count_plank_x_done:
    lda craft_tmp2
    cmp #1
    bcc forge_not_enough_materials
    ; count leather (id 27)
    lda #0
    sta craft_temp
    ldy #0
forge_count_leather_x:
    cpy player_inventory_count
    beq forge_count_leather_x_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_next_leather_x
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_leather_x:
    iny
    bne forge_count_leather_x
forge_count_leather_x_done:
    lda craft_temp
    cmp #1
    bcc forge_not_enough_materials
    ; consume 2 Iron (id 9), 1 Plank (id 22), and 1 Leather (id 27) using consume_items
    lda #9
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #22
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    ; now create the Axe
forge_create_axe:
    lda #32 ; Axe id
    lda #45
    sta craft_tmp2 ; durability 45
    lda #32
    jsr mine_add_or_increment
    ldx #0
    lda craft_axe_success_msg,X
    beq forge_axe_done
    jsr modem_out
    inx
    bne forge_create_axe
forge_axe_done:
    jsr modem_in
    jmp visit_forge

craft_axe_success_msg:
    .text "\r\nYou finish a rugged axe, its blade keen and ready.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Sword (4 Iron + 2 Plank + 1 Leather)
forge_do_sword:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron_s:
    cpy player_inventory_count
    beq forge_count_iron_s_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_s
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_s:
    iny
    bne forge_count_iron_s
forge_count_iron_s_done:
    lda craft_temp
    cmp #4
    bcc forge_not_enough_materials
    ; count planks (id 22)
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_plank_s:
    cpy player_inventory_count
    beq forge_count_plank_s_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #22
    bne forge_next_plank_s
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_plank_s:
    iny
    bne forge_count_plank_s
forge_count_plank_s_done:
    lda craft_tmp2
    cmp #2
    bcc forge_not_enough_materials
    ; count leather (id 27)
    lda #0
    sta craft_tmp3
    ldy #0
forge_count_leather_s:
    cpy player_inventory_count
    beq forge_count_leather_s_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_next_leather_s
    lda player_inventory+1,X
    clc
    adc craft_tmp3
    sta craft_tmp3
forge_next_leather_s:
    iny
    bne forge_count_leather_s
forge_count_leather_s_done:
    lda craft_tmp3
    cmp #1
    bcc forge_not_enough_materials
    ; remove 4 iron (from first iron slot)
    ldy #0
forge_find_iron_slot_s:
    cpy player_inventory_count
    beq forge_remove_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_find_iron_next_s
    ; consume 4 Iron (id 9) across slots for sword
    lda #9
    sta craft_temp
    lda #4
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    jmp forge_remove_planks_after_iron_s
forge_find_iron_next_s:
    iny
    bne forge_find_iron_slot_s
    jmp forge_not_enough_materials

forge_shift_remove_slot_iron_s:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_iron_s:
    cpy craft_tmp2
    beq forge_shift_done_iron_s
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_iron_s
forge_shift_done_iron_s:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count

forge_remove_planks_after_iron_s:
    ; consume required materials across slots (split-slot aware)
    lda #9
    sta craft_temp
    lda #4
    sta craft_tmp2
    jsr consume_items
    lda #22
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    jmp forge_create_sword

forge_create_sword:
    lda #1 ; Sword id
    lda #80
    sta craft_tmp2 ; durability 80
    lda #1
    jsr mine_add_or_increment
    ldx #0
    lda craft_sword_success_msg,X
    beq forge_sword_done
    jsr modem_out
    inx
    bne forge_create_sword
forge_sword_done:
    jsr modem_in
    jmp visit_forge

craft_sword_success_msg:
    .text "\r\nYou hammer a fine sword; its edge gleams.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Shield (3 Iron + 2 Plank + 1 Leather)
forge_do_shield:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron_sh:
    cpy player_inventory_count
    beq forge_count_iron_sh_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_sh
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_sh:
    iny
    bne forge_count_iron_sh
forge_count_iron_sh_done:
    lda craft_temp
    cmp #3
    bcc forge_not_enough_materials
    ; count planks (id 22)
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_plank_sh:
    cpy player_inventory_count
    beq forge_count_plank_sh_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #22
    bne forge_next_plank_sh
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_plank_sh:
    iny
    bne forge_count_plank_sh
forge_count_plank_sh_done:
    lda craft_tmp2
    cmp #2
    bcc forge_not_enough_materials
    ; count leather (id 27)
    lda #0
    sta craft_tmp3
    ldy #0
forge_count_leather_sh:
    cpy player_inventory_count
    beq forge_count_leather_sh_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_next_leather_sh
    lda player_inventory+1,X
    clc
    adc craft_tmp3
    sta craft_tmp3
forge_next_leather_sh:
    iny
    bne forge_count_leather_sh
forge_count_leather_sh_done:
    lda craft_tmp3
    cmp #1
    bcc forge_not_enough_materials
    ; consume 3 Iron (id 9), 2 Planks (id 22), and 1 Leather (id 27) using consume_items
    lda #9
    sta craft_temp
    lda #3
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #22
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    ; now create the Shield
    jmp forge_create_shield

forge_shift_remove_slot_leather_sh:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
forge_shift_loop_leather_sh:
    cpy craft_tmp2
    beq forge_shift_done_leather_sh
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp forge_shift_loop_leather_sh
forge_shift_done_leather_sh:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count

forge_create_shield:
    lda #2 ; Shield id
    lda #90
    sta craft_tmp2 ; durability 90
    lda #2
    jsr mine_add_or_increment
    ldx #0
    lda craft_shield_success_msg,X
    beq forge_shield_done
    jsr modem_out
    inx
    bne forge_create_shield
forge_shield_done:
    jsr modem_in
    jmp visit_forge

craft_shield_success_msg:
    .text "\r\nYou forge a sturdy shield, fit for battle.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
; Forge: Armor (6 Iron + 4 Leather)
forge_do_armor:
    ; count iron
    lda #0
    sta craft_temp
    ldy #0
forge_count_iron_a:
    cpy player_inventory_count
    beq forge_count_iron_a_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #9
    bne forge_next_iron_a
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
forge_next_iron_a:
    iny
    bne forge_count_iron_a
forge_count_iron_a_done:
    lda craft_temp
    cmp #6
    bcc forge_not_enough_materials
    ; count leather (id 27)
    lda #0
    sta craft_tmp2
    ldy #0
forge_count_leather_a:
    cpy player_inventory_count
    beq forge_count_leather_a_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne forge_next_leather_a
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
forge_next_leather_a:
    iny
    bne forge_count_leather_a
forge_count_leather_a_done:
    lda craft_tmp2
    cmp #4
    bcc forge_not_enough_materials
    ; consume 6 Iron (id 9) and 4 Leather (id 27) using consume_items
    lda #9
    sta craft_temp
    lda #6
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    lda #27
    sta craft_temp
    lda #4
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne forge_not_enough_materials
    ; now create armor
forge_create_armor:
    lda #30 ; Armor id
    lda #120
    sta craft_tmp2 ; durability 120
    lda #30
    jsr mine_add_or_increment
    ldx #0
    lda craft_armor_success_msg,X
    beq forge_armor_done
    jsr modem_out
    inx
    bne forge_create_armor
forge_armor_done:
    jsr modem_in
    jmp visit_forge

craft_armor_success_msg:
    .text "\r\nYou assemble a set of armor; it offers solid protection.\r\n[Press any key]\r\n"
    .byte 0

; -------------------------
forge_not_enough_materials:
    ldx #0
forge_insuf_print:
    lda craft_insufficient_msg,X
    beq forge_insuf_done
    jsr modem_out
    inx
    bne forge_insuf_print
forge_insuf_done:
    jsr modem_in
    jmp visit_forge

craft_no_space:
    ldx #0
craft_nospace_print:
    lda craft_no_space_msg,X
    beq craft_nospace_done
    jsr modem_out
    inx
    bne craft_nospace_print
craft_nospace_done:
    jsr modem_in
    jmp visit_forge

forge_leave:
    jmp town_show_menu

// Hex Trove - witchy cold-treat shop
visit_hex_trove:
    ldx #0
hextrove_desc_loop:
        lda hextrove_msg,X
        beq hextrove_done
        jsr modem_out
        inx
        bne hextrove_desc_loop
hextrove_done:
    jsr modem_in
    jmp town_show_menu

// Food Court East - full meals
visit_foodcourt_east:
    ldx #0
food_east_loop:
        lda foodcourt_east_msg,X
        beq food_east_done
        jsr modem_out
        inx
        bne food_east_loop
food_east_done:
    jsr modem_in
    ; Food Court menu - full meals restore stamina
    ldx #0
food_east_menu_print:
    lda food_east_menu_msg,X
    beq food_east_menu_done
    jsr modem_out
    inx
    bne food_east_menu_print
food_east_menu_done:
    jsr modem_in
    cmp #'1'
    beq food_east_buy_meal
    cmp #'0'
    beq food_east_leave
    jmp visit_foodcourt_east

food_east_buy_meal:
    lda player_gold
    cmp #8
    bcc food_east_no_gold
    ; charge 8 gold, restore 8 stamina
    sec
    lda player_gold
    sbc #8
    sta player_gold
    lda player_stamina
    clc
    adc #8
    sta player_stamina
    ldx #0
food_east_thanks_loop:
    lda food_east_thanks_msg,X
    beq food_east_thanks_done
    jsr modem_out
    inx
    bne food_east_thanks_loop
food_east_thanks_done:
    jsr modem_in
    jmp visit_foodcourt_east

food_east_no_gold:
    ldx #0
food_east_nogold_loop:
    lda foodcourt_no_gold_msg,X
    beq food_east_nogold_done
    jsr modem_out
    inx
    bne food_east_nogold_loop
food_east_nogold_done:
    jsr modem_in
    jmp visit_foodcourt_east

food_east_leave:
    jmp town_show_menu

// Food Court West - soups and sandwiches
visit_foodcourt_west:
    ldx #0
food_west_loop:
        lda foodcourt_west_msg,X
        beq food_west_done
        jsr modem_out
        inx
        bne food_west_loop
food_west_done:
    jsr modem_in
    ; Food Court West menu - light meals restore smaller stamina
    ldx #0
food_west_menu_print:
    lda food_west_menu_msg,X
    beq food_west_menu_done
    jsr modem_out
    inx
    bne food_west_menu_print
food_west_menu_done:
    jsr modem_in
    cmp #'1'
    beq food_west_buy_meal
    cmp #'0'
    beq food_west_leave
    jmp visit_foodcourt_west

food_west_buy_meal:
    lda player_gold
    cmp #4
    bcc food_west_no_gold
    sec
    lda player_gold
    sbc #4
    sta player_gold
    lda player_stamina
    clc
    adc #4
    sta player_stamina
    ldx #0
food_west_thanks_loop:
    lda food_west_thanks_msg,X
    beq food_west_thanks_done
    jsr modem_out
    inx
    bne food_west_thanks_loop
food_west_thanks_done:
    jsr modem_in
    jmp visit_foodcourt_west

food_west_no_gold:
    ldx #0
food_west_nogold_loop:
    lda foodcourt_no_gold_msg,X
    beq food_west_nogold_done
    jsr modem_out
    inx
    bne food_west_nogold_loop
food_west_nogold_done:
    jsr modem_in
    jmp visit_foodcourt_west

food_west_leave:
    jmp town_show_menu

visit_glass_house:
    ldx #0
glass_loop:
        lda glass_house_msg,X
        beq glass_done
        jsr modem_out
        inx
        bne glass_loop
glass_done:
    jsr modem_in
    jmp town_show_menu

visit_dragon_haven:
    ldx #0
haven_loop:
        lda dragon_haven_msg,X
        beq haven_done
        jsr modem_out
        inx
        bne haven_loop
haven_done:
    jsr modem_in
    jmp town_show_menu

visit_temple_ruins:
    ldx #0
temple_loop:
        lda temple_ruins_msg,X
        beq temple_show_alister
        jsr modem_out
        inx
        bne temple_loop
temple_show_alister:
    ldx #0
alister_loop:
        lda alister_msg,X
        beq temple_show_torin
        jsr modem_out
        inx
        bne alister_loop
temple_show_torin:
    ldx #0
torin_loop:
        lda torin_msg,X
        beq alister_done
        jsr modem_out
        inx
        bne torin_loop
alister_done:
    jsr modem_in
    jmp town_show_menu

// Tool Vendor - sells pickaxes
visit_tool_vendor:
    ldx #0
tool_vendor_msg_loop:
    lda tool_vendor_msg,X
    beq tool_vendor_msg_done
    jsr modem_out
    inx
    bne tool_vendor_msg_loop
tool_vendor_msg_done:
    jsr modem_in
    cmp #'1'
    beq tool_buy_pickaxe
    cmp #'0'
    beq tool_leave
    jmp visit_tool_vendor

tool_buy_pickaxe:
    lda player_gold
    cmp #25
    bcc tool_no_gold
    ; charge 25 gold
    sec
    lda player_gold
    sbc #25
    sta player_gold
    ; append a fresh pickaxe with good durability
    lda #30        ; vendor pickaxe durability
    sta craft_tmp2
    lda #14
    jsr mine_add_or_increment
    jmp tool_pickaxe_thanks

tool_pickaxe_thanks:
    ldx #0
tool_thanks_loop:
    lda tool_vendor_thanks_msg,X
    beq tool_thanks_done
    jsr modem_out
    inx
    bne tool_thanks_loop
tool_thanks_done:
    jsr modem_in
    jmp visit_tool_vendor

tool_no_gold:
    ldx #0
tool_nogold_loop:
    lda tool_vendor_no_gold_msg,X
    beq tool_nogold_done
    jsr modem_out
    inx
    bne tool_nogold_loop
tool_nogold_done:
    jsr modem_in
    jmp visit_tool_vendor

tool_leave:
    jmp visit_marketplace

tool_vendor_msg:
    .text "\r\nTOOL VENDOR:\r\n1) Buy Pickaxe (30 gold)\r\n0) Leave\r\n> "
    .byte 0
tool_vendor_thanks_msg:
    .text "\r\nThe vendor polishes the pickaxe and hands it to you.\r\n[Press any key]\r\n"
    .byte 0
tool_vendor_no_gold_msg:
    .text "\r\nYou don't have enough gold for that pickaxe.\r\n[Press any key]\r\n"
    .byte 0

// Saw Mill - convert Wood -> Planks, buy a Saw
visit_sawmill:
    ldx #0
sawmill_loop:
        lda sawmill_msg,X
        beq sawmill_done
        jsr modem_out
        inx
        bne sawmill_loop
sawmill_done:
    jsr modem_in
    ; menu
    ldx #0
sawmill_menu_print:
    lda sawmill_menu_msg,X
    beq sawmill_menu_print_done
    jsr modem_out
    inx
    bne sawmill_menu_print
sawmill_menu_print_done:
    jsr modem_in
    cmp #'1'
    beq sawmill_saw_wood
    cmp #'2'
    beq sawmill_buy_saw
    cmp #'0'
    beq sawmill_leave
    jmp visit_sawmill

sawmill_saw_wood:
    ; require 1 Wood (id 21) -> produce 2 Planks (id 22)
    lda #0
    sta craft_tmp2
    ldy #0
sawmill_count_wood:
    cpy player_inventory_count
    beq sawmill_no_wood
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #21
    bne sawmill_next_wood
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
sawmill_next_wood:
    iny
    bne sawmill_count_wood
sawmill_no_wood:
    lda craft_tmp2
    cmp #1
    bcc sawmill_need_wood
    ; remove one wood from first wood slot
    ldy #0
sawmill_find_wood:
    cpy player_inventory_count
    beq sawmill_fail
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #21
    bne sawmill_find_wood_next
    ; consume 1 Wood (id 21) across slots
    lda #21
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    beq sawmill_produce_planks
    jmp sawmill_fail
sawmill_find_wood_next:
    iny
    jmp sawmill_find_wood
sawmill_shift_remove_wood:
    lda player_inventory_count
    sec
    sbc #1
    sta craft_tmp2
    tya
sawmill_shift_loop_wood:
    cpy craft_tmp2
    beq sawmill_shift_done_wood
    tya
    clc
    adc #1
    tay
    tya
    asl
    asl
    tax
    lda player_inventory,X
    sta player_inventory-4,X
    lda player_inventory+1,X
    sta player_inventory-3,X
    lda player_inventory+2,X
    sta player_inventory-2,X
    lda player_inventory+3,X
    sta player_inventory-1,X
    iny
    jmp sawmill_shift_loop_wood
sawmill_shift_done_wood:
    lda player_inventory_count
    sec
    sbc #1
    sta player_inventory_count
    jmp sawmill_produce_planks

sawmill_produce_planks:
    ; add 2 planks (id 22)
    lda #22
    jsr mine_add_or_increment
    lda #22
    jsr mine_add_or_increment
    ldx #0
    lda sawmill_done_msg,X
    beq sawmill_done_printed
    jsr modem_out
    inx
    bne sawmill_done_printed
sawmill_done_printed:
    jsr modem_in
    jmp visit_sawmill

sawmill_need_wood:
    ldx #0
    lda sawmill_need_wood_msg,X
    beq sawmill_need_wood_done
    jsr modem_out
    inx
    bne sawmill_need_wood
sawmill_need_wood_done:
    jsr modem_in
    jmp visit_sawmill

sawmill_buy_saw:
    lda player_gold
    cmp #20
    bcc sawmill_no_gold
    sec
    lda player_gold
    sbc #20
    sta player_gold
    ; give saw item id 23
    lda #23
    jsr mine_add_or_increment
    ldx #0
    lda sawmill_buy_msg,X
    beq sawmill_buy_done
    jsr modem_out
    inx
    bne sawmill_buy_msg
sawmill_buy_done:
    jsr modem_in
    jmp visit_sawmill

sawmill_no_gold:
    ldx #0
    lda sawmill_no_gold_msg,X
    beq sawmill_no_gold_done
    jsr modem_out
    inx
    bne sawmill_no_gold
sawmill_no_gold_done:
    jsr modem_in
    jmp visit_sawmill

sawmill_leave:
    jmp visit_marketplace

sawmill_msg:
    .text "\r\nSAW MILL:\r\nA steady rhythm of blades and the scent of fresh timber greet you.\r\n"
    .byte 0

sawmill_menu_msg:
    .text "\r\n1) Saw Wood -> 2 Planks\r\n2) Buy Saw (20 gold)\r\n0) Leave\r\n> "
    .byte 0

sawmill_done_msg:
    .text "\r\nThe mill hums; you pocket the planks.\r\n[Press any key]\r\n"
    .byte 0

sawmill_need_wood_msg:
    .text "\r\nYou don't have any wood to saw.\r\n[Press any key]\r\n"
    .byte 0

sawmill_buy_msg:
    .text "\r\nThe saw is heavy but sharp. Useful for crafting.\r\n[Press any key]\r\n"
    .byte 0

sawmill_no_gold_msg:
    .text "\r\nYou can't afford the saw.\r\n[Press any key]\r\n"
    .byte 0

// Dense Forest - gather wood, berries, hunt small game
visit_dense_forest:
    ldx #0
dense_forest_loop:
        lda dense_forest_msg,X
        beq dense_forest_done
        jsr modem_out
        inx
        bne dense_forest_loop
dense_forest_done:
    jsr modem_in
    ; menu
    ldx #0
dense_forest_menu_print:
    lda dense_forest_menu_msg,X
    beq dense_forest_menu_print_done
    jsr modem_out
    inx
    bne dense_forest_menu_print
dense_forest_menu_print_done:
    jsr modem_in
    cmp #'1'
    beq dense_forest_chop_wood
    cmp #'2'
    beq dense_forest_forage_berries
    cmp #'3'
    beq dense_forest_hunt
    cmp #'0'
    beq dense_forest_leave
    jmp visit_dense_forest

dense_forest_chop_wood:
    ; require stamina
    lda player_stamina
    beq dense_forest_too_tired
    dec player_stamina
    jsr get_random
    and #$03
    cmp #0
    beq dense_forest_wood_abundant
    cmp #1
    beq dense_forest_wood_found
    ; else small chance nothing
    ldx #0
    lda dense_forest_nothing_msg,X
    beq dense_forest_nothing_done
    jsr modem_out
    inx
    bne dense_forest_nothing
dense_forest_nothing_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_wood_found:
    lda #21
    jsr mine_add_or_increment
    ldx #0
    lda dense_forest_wood_msg,X
    beq dense_forest_wood_done
    jsr modem_out
    inx
    bne dense_forest_wood_found
dense_forest_wood_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_wood_abundant:
    lda #21
    jsr mine_add_or_increment
    lda #21
    jsr mine_add_or_increment
    ldx #0
    lda dense_forest_wood_many_msg,X
    beq dense_forest_wood_many_done
    jsr modem_out
    inx
    bne dense_forest_wood_many
dense_forest_wood_many_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_forage_berries:
    lda player_stamina
    beq dense_forest_too_tired
    dec player_stamina
    jsr get_random
    and #$03
    cmp #0
    beq dense_forest_berries_many
    cmp #1
    beq dense_forest_berries_found
    ldx #0
    lda dense_forest_nothing_msg,X
    beq dense_forest_nothing2_done
    jsr modem_out
    inx
    bne dense_forest_nothing2
dense_forest_nothing2_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_berries_found:
    lda #24
    jsr mine_add_or_increment
    ldx #0
    lda dense_forest_berries_msg,X
    beq dense_forest_berries_done
    jsr modem_out
    inx
    bne dense_forest_berries_found
dense_forest_berries_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_berries_many:
    lda #24
    jsr mine_add_or_increment
    lda #24
    jsr mine_add_or_increment
    ldx #0
    lda dense_forest_berries_many_msg,X
    beq dense_forest_berries_many_done
    jsr modem_out
    inx
    bne dense_forest_berries_many
dense_forest_berries_many_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_hunt:
    lda player_stamina
    cmp #2
    bcc dense_forest_too_tired
    sec
    lda player_stamina
    sbc #2
    sta player_stamina
    jsr get_random
    and #$01
    cmp #0
    beq dense_forest_hunt_success
    ldx #0
    lda dense_forest_hunt_fail_msg,X
    beq dense_forest_hunt_fail_done
    jsr modem_out
    inx
    bne dense_forest_hunt_fail
dense_forest_hunt_fail_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_hunt_success:
    lda #25
    jsr mine_add_or_increment
    ldx #0
    lda dense_forest_hunt_msg,X
    beq dense_forest_hunt_done
    jsr modem_out
    inx
    bne dense_forest_hunt_success
dense_forest_hunt_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_too_tired:
    ldx #0
    lda mine_tired_msg,X
    beq dense_forest_tired_done
    jsr modem_out
    inx
    bne dense_forest_too_tired
dense_forest_tired_done:
    jsr modem_in
    jmp visit_dense_forest

dense_forest_leave:
    jmp visit_town

dense_forest_msg:
    .text "\r\nDENSE FOREST:\r\nTrees crowd overhead and shafts of light pierce the canopy. The air smells of damp earth and green leaves. You can forage, hunt, or fell timber here.\r\n[Press any key]\r\n"
    .byte 0

dense_forest_menu_msg:
    .text "\r\nDense Forest:\r\n1) Chop Wood\r\n2) Forage Berries\r\n3) Hunt (requires 2 stamina)\r\n0) Return to Town\r\n> "
    .byte 0

dense_forest_wood_msg:
    .text "\r\nYou chop a length of wood and carry it back.\r\n[Press any key]\r\n"
    .byte 0

dense_forest_wood_many_msg:
    .text "\r\nYou find a small grove and haul several lengths of wood.\r\n[Press any key]\r\n"
    .byte 0

dense_forest_nothing_msg:
    .text "\r\nYou search but find nothing useful.\r\n[Press any key]\r\n"
    .byte 0

dense_forest_berries_msg:
    .text "\r\nYou pick a handful of ripe berries.\r\n[Press any key]\r\n"
    .byte 0

dense_forest_berries_many_msg:
    .text "\r\nYou gather a bounty of berries from a thicket.\r\n[Press any key]\r\n"
    .byte 0

dense_forest_hunt_msg:
    .text "\r\nYou bring down a small game and gut it for meat.\r\n[Press any key]\r\n"
    .byte 0

dense_forest_hunt_fail_msg:
    .text "\r\nYou stalk for hours but come away empty-handed.\r\n[Press any key]\r\n"
    .byte 0

visit_inn:
    ldx #0
inn_msg_loop:
    lda inn_msg,X
    beq inn_print_done
    jsr modem_out
    inx
    bne inn_msg_loop
inn_print_done:
    jsr modem_in
    cmp #'1'
    beq inn_rent_room
    cmp #'0'
    beq inn_leave
    jmp visit_inn

inn_rent_room:
    lda player_gold
    cmp #20
    bcc inn_no_gold
    sec
    lda player_gold
    sbc #20
    sta player_gold
    ; full restore
    lda #12
    sta player_stamina
    lda #20
    sta player_hp
    ldx #0
inn_thanks_loop:
    lda inn_rent_thanks_msg,X
    beq inn_thanks_done
    jsr modem_out
    inx
    bne inn_thanks_loop
inn_thanks_done:
    jsr modem_in
    jmp visit_marketplace

inn_no_gold:
    ldx #0
inn_nogold_loop:
    lda inn_no_gold_msg,X
    beq inn_nogold_done
    jsr modem_out
    inx
    bne inn_nogold_loop
inn_nogold_done:
    jsr modem_in
    jmp visit_inn

inn_leave:
    jmp visit_marketplace

inn_msg:
    .text "\r\nLouden's Rest - Rent a room:\r\n1) Rent Room (20 gold) - full restore\r\n0) Leave\r\n> "
    .byte 0

inn_rent_thanks_msg:
    .text "\r\nYou sleep in a warm bed and wake fully restored.\r\n[Press any key]\r\n"
    .byte 0

inn_no_gold_msg:
    .text "\r\nYou can't afford the room tonight.\r\n[Press any key]\r\n"
    .byte 0

visit_loudens_rest:
    ldx #0
louden_loop:
        lda loudens_rest_msg,X
        beq louden_show_tosh
        jsr modem_out
        inx
        bne louden_loop
louden_show_tosh:
    ldx #0
tosh_loop:
        lda louden_tosh_msg,X
        beq tosh_done
        jsr modem_out
        inx
        bne tosh_loop
tosh_done:
    jsr modem_in
    jmp town_show_menu

visit_moselem:
    ldx #0
moselem_loop:
        lda moselem_msg,X
        beq moselem_show_kas
        jsr modem_out
        inx
        bne moselem_loop
moselem_show_kas:
    ldx #0
kas_loop:
        lda moselem_kasimere_msg,X
        beq kas_done
        jsr modem_out
        inx
        bne kas_loop
kas_done:
    jsr modem_in
    jmp town_show_menu

visit_moon_portal:
    ldx #0
moon_loop:
        lda moon_portal_msg,X
        beq moon_done
        jsr modem_out
        inx
        bne moon_loop
moon_done:
    jsr modem_in
    jmp town_show_menu

visit_fairy_gardens:
    ldx #0
fairy_loop:
        lda fairy_gardens_msg,X
        beq fairy_show_lezule
        jsr modem_out
        inx
        bne fairy_loop
fairy_show_lezule:
    ldx #0
lezule_loop:
        lda lezule_msg,X
        beq fairy_show_marmalade
        jsr modem_out
        inx
        bne lezule_loop
fairy_show_marmalade:
    ldx #0
marmalade_loop:
        lda marmalade_msg,X
        beq fairy_show_marigold
        jsr modem_out
        inx
        bne marmalade_loop
fairy_show_marigold:
    ldx #0
marigold_loop:
        lda marigold_msg,X
        beq fairy_show_butterscotch
        jsr modem_out
        inx
        bne marigold_loop
fairy_show_butterscotch:
    ldx #0
butterscotch_loop:
        lda butterscotch_msg,X
        beq fairy_done
        jsr modem_out
        inx
        bne butterscotch_loop
fairy_done:
    jsr modem_in
    jmp town_show_menu

visit_town_arena:
    ldx #0
tarena_loop:
        lda town_arena_msg,X
        beq tarena_done
        jsr modem_out
        inx
        bne tarena_loop
tarena_done:
    jsr modem_in
    jmp town_show_menu

visit_circus_tent:
    ldx #0
circus_intro_loop:
        lda circus_intro_msg,X
        beq circus_intro_done
        jsr modem_out
        inx
        bne circus_intro_loop
circus_intro_done:
    jsr modem_in
    ; Offer simple minigame
    ldx #0
circus_play_loop:
        lda circus_play_msg,X
        beq circus_play_done
        jsr modem_out
        inx
        bne circus_play_loop
circus_play_done:
    jsr modem_in
    cmp #'1'
    beq circus_play
    jmp town_show_menu

circus_play:
    ; Multi-round Juggler's Challenge: 3 rounds
    ldx #0
    lda #0
    sta temp_amount      ; use temp_amount as success counter
    ldy #3
circus_round_loop:
    jsr get_random
    and #$03
    cmp #2
    bcc circus_round_miss
    ; success this round
    inc temp_amount
circus_round_miss:
    dey
    bne circus_round_loop
    ; Compute reward: 5 + successes*3
    lda temp_amount
    clc
    asl
    clc
    adc temp_amount
    clc
    adc #5
    sta temp_amount
    lda player_gold
    clc
    adc temp_amount
    sta player_gold
    ; Update high score (store highest successes)
    lda temp_amount
    cmp circus_high_score
    bcc circus_skip_hs
    sta circus_high_score
circus_skip_hs:
    ldx #0
    ; If at least one success, show win message, else lose message
    lda temp_amount
    beq circus_show_lose
    lda circus_win_msg,X
    beq circus_win_done
circus_show_win_loop:
    lda circus_win_msg,X
    beq circus_win_done
    jsr modem_out
    inx
    bne circus_show_win_loop
circus_win_done:
    jsr modem_in
    jsr set_achievement_circus
    jmp town_show_menu

circus_show_lose:
    ldx #0
circus_lose_loop2:
    lda circus_lose_msg,X
    beq circus_lose_done2
    jsr modem_out
    inx
    bne circus_lose_loop2
circus_lose_done2:
    jsr modem_in
    jmp town_show_menu

visit_pirate_ship:
    ldx #0
pirate_loop:
        lda pirate_ship_msg,X
        beq pirate_show_plum
        jsr modem_out
        inx
        bne pirate_loop
pirate_show_plum:
    ldx #0
plum_loop:
        lda pit_plum_msg,X
        beq pirate_show_bonny
        jsr modem_out
        inx
        bne plum_loop
pirate_show_bonny:
    ldx #0
bonny_loop:
        lda bonny_boots_msg,X
        beq pirate_show_ford
        jsr modem_out
        inx
        bne bonny_loop
pirate_show_ford:
    jsr modem_in
    ldx #0
ford_loop:
        lda shadow_ford_msg,X
        beq pirate_done
        jsr modem_out
        inx
        bne ford_loop
pirate_done:
    jsr modem_in
    jmp town_show_menu

visit_tower:
    ldx #0
tower_loop:
        lda tower_msg,X
        beq tower_show_owls
        jsr modem_out
        inx
        bne tower_loop
tower_show_owls:
    ldx #0
owls_loop:
        lda owls_msg,X
        beq tower_done
        jsr modem_out
        inx
        bne owls_loop
tower_done:
    jsr modem_in
    jmp town_show_menu

visit_church:
    ldx #0
church_loop:
        lda church_msg,X
        beq church_show_cordelia
        jsr modem_out
        inx
        bne church_loop
church_show_cordelia:
    ldx #0
cordelia_ch_loop:
        lda cordelia_church_msg,X
        beq church_show_cedric
        jsr modem_out
        inx
        bne cordelia_ch_loop
church_show_cedric:
    ldx #0
cedric_loop:
        lda cedric_msg,X
        beq church_done
        jsr modem_out
        inx
        bne cedric_loop
church_done:
    jsr modem_in
    jmp town_show_menu

visit_catacombs:
    ldx #0
catacombs_loop:
        lda catacombs_msg,X
        beq catacombs_show_samuel
        jsr modem_out
        inx
        bne catacombs_loop
catacombs_show_samuel:
    ldx #0
samuel_loop:
        lda samuel_msg,X
        beq catacombs_done
        jsr modem_out
        inx
        bne samuel_loop
catacombs_done:
    jsr modem_in
    jmp town_show_menu

visit_statue_michael:
    ldx #0
statue_loop:
        lda statue_michael_msg,X
        beq statue_done
        jsr modem_out
        inx
        bne statue_loop
statue_done:
    jsr modem_in
    jmp town_show_menu

visit_marketplace:
    jsr restock_shop
    ldx #0
market_loop:
        lda marketplace_msg,X
        beq market_show_bridge
        jsr modem_out
        inx
        bne market_loop
market_show_bridge:
    ldx #0
bridge_loop:
        lda bridge_troll_msg,X
        beq market_menu
        jsr modem_out
        inx
        bne bridge_loop
market_menu:
    ; Offer access to Post Office from marketplace
    ldx #0
    market_menu_msg_loop:
        lda market_menu_msg,X
        beq market_menu_done
        jsr modem_out
        inx
        bne market_menu_msg_loop
market_menu_done:
    jsr modem_in
    cmp #'1'
    beq market_back
    cmp #'2'
    beq visit_post_office
    cmp #'3'
    beq visit_mine
    cmp #'4'
    beq visit_quarry
    cmp #'5'
    beq visit_tool_vendor
    cmp #'6'
    beq visit_inn
    cmp #'7'
    beq visit_sawmill
    cmp #'8'
    beq visit_tannery
    jmp market_back
market_back:
    jmp town_show_menu

// Restock shop: small random price adjustments when visiting marketplace
restock_shop:
    jsr get_random
    and #$03        ; base randomness
    sta temp_amount
    ldx #0
restock_loop2:
    lda shop_item_prices,X
    clc
    adc temp_amount
    sta shop_item_prices,X
    inx
    cpx shop_items_count
    bne restock_loop2
    rts

market_menu_msg:
    .text "\r\nMarketplace:\r\n1. Back to Town\r\n2. Post Office\r\n3. Mine\r\n4. Gem Quarry\r\n5. Tool Vendor\r\n6. Inn (Rent a room)\r\n7. Saw Mill\r\n8. Tannery\r\n> "
    .byte 0

visit_witch_tent:
    ldx #0
witch_desc_loop:
        lda portal_witch_msg,X
        beq witch_desc_done
        jsr modem_out
        inx
        bne witch_desc_loop
witch_desc_done:
    ldx #0
witch_menu_loop:
        lda witch_npc_menu_msg,X
        beq witch_menu_done
        jsr modem_out
        inx
        bne witch_menu_loop
witch_menu_done:
    jsr modem_in
    cmp #'1'
    bne not_talk_tammis
    jmp talk_tammis
not_talk_tammis:
    cmp #'2'
    bne not_talk_saga
    jmp talk_saga
not_talk_saga:
    cmp #'3'
    bne not_witch_potions
    jmp browse_witch_potions
not_witch_potions:
    cmp #'4'
    bne witch_menu_done
    jmp town_show_menu
not_witch_back:
    cmp #'5'
    bne not_witch_craft
    jmp visit_mystic_craft
not_witch_craft:
    cmp #'6'
    bne witch_menu_done
    jmp visit_mystic_research

talk_tammis:
    ldx #0
tammis_loop:
        lda tammis_msg,X
        beq tammis_done
        jsr modem_out
        inx
        bne tammis_loop
tammis_done:
    jsr modem_in
    jmp visit_witch_tent

talk_saga:
    ldx #0
saga_loop:
        lda saga_msg,X
        beq saga_done
        jsr modem_out
        inx
        bne saga_loop
saga_done:
    jsr modem_in
    jmp visit_witch_tent

browse_witch_potions:
    ldx #0
potions_loop:
        lda witch_potions_msg,X
        beq potions_done
        jsr modem_out
        inx
        bne potions_loop
potions_done:
    jsr modem_in
    jmp visit_witch_tent

// Hunter's Hovel visit routine
visit_hunters_hovel:
    ldx #0
hovel_loop:
        lda hunters_hovel_msg,X
        beq hovel_show_wulfric
        jsr modem_out
        inx
        bne hovel_loop
hovel_show_wulfric:
    ldx #0
wulfric_h_loop:
        lda wulfric_hovel_msg,X
        beq hovel_done
        jsr modem_out
        inx
        bne wulfric_h_loop
hovel_done:
    jsr modem_in
    jmp town_show_menu

// The Burrows visit routine
visit_burrows:
    ldx #0
burrows_loop:
        lda burrows_msg,X
        beq burrows_show_queen
        jsr modem_out
        inx
        bne burrows_loop
burrows_show_queen:
    ldx #0
frost_q_loop:
        lda frost_queen_msg,X
        beq burrows_done
        jsr modem_out
        inx
        bne frost_q_loop
burrows_done:
    jsr modem_in
    jmp town_show_menu

// Mystic's Tent visit routine
visit_mystics_tent:
    ldx #0
mystics_loop:
        lda mystics_tent_msg,X
        beq mystics_show_mela
        jsr modem_out
        inx
        bne mystics_loop
mystics_show_mela:
    ldx #0
mela_loop:
        lda mela_msg,X
        beq mystics_done
        jsr modem_out
        inx
        bne mela_loop
mystics_done:
    jsr modem_in
    jmp town_show_menu

// Central Plaza visit routine
visit_central_plaza:
    ldx #0
plaza_loop:
        lda central_plaza_msg,X
        beq plaza_show_spider
        jsr modem_out
        inx
        bne plaza_loop
plaza_show_spider:
    ldx #0
spider_p_loop:
        lda spider_princess_msg,X
        beq plaza_show_knights
        jsr modem_out
        inx
        bne spider_p_loop
plaza_show_knights:
    jsr modem_in
    ldx #0
knights_loop:
        lda kora_kendrick_msg,X
        beq plaza_done
        jsr modem_out
        inx
        bne knights_loop
plaza_done:
    jsr modem_in
    jmp town_show_menu

// The Bridge - Bridge the Troll's home
visit_the_bridge:
    ldx #0
the_bridge_loop:
        lda the_bridge_msg,X
        beq the_bridge_show_troll
        jsr modem_out
        inx
        bne the_bridge_loop
the_bridge_show_troll:
    ldx #0
bridge_home_loop:
        lda bridge_home_msg,X
        beq the_bridge_show_dante
        jsr modem_out
        inx
        bne bridge_home_loop
the_bridge_show_dante:
    jsr modem_in
    ldx #0
dante_npc_loop:
        lda dante_msg,X
        beq the_bridge_show_witch
        jsr modem_out
        inx
        bne dante_npc_loop
the_bridge_show_witch:
    jsr modem_in
    ldx #0
candy_witch_loop:
        lda candy_witch_msg,X
        beq the_bridge_done
        jsr modem_out
        inx
        bne candy_witch_loop
the_bridge_done:
    jsr modem_in
    jmp town_show_menu

// Kira's Apothecary visit routine
visit_apothecary:
    ldx #0
    lda kira_apothecary_msg,X
    beq apothecary_show_menu
    jsr modem_out
    inx
    bne visit_apothecary
apothecary_show_menu:
    ldx #0
    lda apothecary_menu_msg,X
    beq apothecary_menu_done
    jsr modem_out
    inx
    bne apothecary_show_menu
apothecary_menu_done:
    jsr modem_in
    cmp #'1'
    beq apoth_do_heal
    cmp #'2'
    beq apoth_do_poison
    cmp #'0'
    beq town_show_menu
    jmp visit_apothecary

; Apothecary crafting handlers
apoth_do_heal:
    ; requires 1 Gem (id 6) and 1 Berry (id 24)
    lda #0
    sta craft_temp
    ldy #0
apoth_count_gems:
    cpy player_inventory_count
    beq apoth_count_gems_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne apoth_next_gem
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
apoth_next_gem:
    iny
    bne apoth_count_gems
apoth_count_gems_done:
    lda craft_temp
    cmp #1
    bcc apoth_no_materials
    ; count Berries (id 24)
    lda #0
    sta craft_tmp2
    ldy #0
apoth_count_berries:
    cpy player_inventory_count
    beq apoth_count_berries_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #24
    bne apoth_next_berry
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
apoth_next_berry:
    iny
    bne apoth_count_berries
apoth_count_berries_done:
    lda craft_tmp2
    cmp #1
    bcc apoth_no_materials
    ; consume 1 Gem
    lda #6
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne apoth_no_materials
    ; consume 1 Berry
    lda #24
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne apoth_no_materials
    ; give Healing Potion (id 35)
    lda #0
    sta craft_tmp2
    lda #35
    jsr mine_add_or_increment
    ldx #0
    lda craft_heal_success_msg,X
    beq apoth_heal_done
    jsr modem_out
    inx
    bne apoth_do_heal
apoth_heal_done:
    jsr modem_in
    jmp visit_apothecary

apoth_do_poison:
    ; requires 1 Meat (id 25) and 1 Berry (id 24)
    lda #0
    sta craft_temp
    ldy #0
apoth_count_meat:
    cpy player_inventory_count
    beq apoth_count_meat_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #25
    bne apoth_next_meat
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
apoth_next_meat:
    iny
    bne apoth_count_meat
apoth_count_meat_done:
    lda craft_temp
    cmp #1
    bcc apoth_no_materials
    ; count Berries (id 24)
    lda #0
    sta craft_tmp2
    ldy #0
apoth_count_berries2:
    cpy player_inventory_count
    beq apoth_count_berries2_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #24
    bne apoth_next_berry2
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
apoth_next_berry2:
    iny
    bne apoth_count_berries2
apoth_count_berries2_done:
    lda craft_tmp2
    cmp #1
    bcc apoth_no_materials
    ; consume 1 Meat
    lda #25
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne apoth_no_materials
    ; consume 1 Berry
    lda #24
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne apoth_no_materials
    ; give Poison (id 36)
    lda #0
    sta craft_tmp2
    lda #36
    jsr mine_add_or_increment
    ldx #0
    lda craft_poison_success_msg,X
    beq apoth_poison_done
    jsr modem_out
    inx
    bne apoth_do_poison
apoth_poison_done:
    jsr modem_in
    jmp visit_apothecary

apoth_no_materials:
    ldx #0
    lda apothecary_insuf_msg,X
    beq apoth_no_mat_done
    jsr modem_out
    inx
    bne apoth_no_materials
apoth_no_mat_done:
    jsr modem_in
    jmp visit_apothecary

// === THE STAGE - GREG THE FIRE DANCER ===
visit_the_stage:
    ldx #0
stage_desc_loop:
        lda the_stage_msg,X
        beq stage_show_greg
        jsr modem_out
        inx
        bne stage_desc_loop
stage_show_greg:
    ldx #0
greg_loop:
        lda greg_dancer_msg,X
        beq stage_show_menu
        jsr modem_out
        inx
        bne greg_loop
stage_show_menu:
    ldx #0
stage_menu_loop:
        lda stage_menu_msg,X
        beq stage_menu_done
        jsr modem_out
        inx
        bne stage_menu_loop
stage_menu_done:
    jsr modem_in

print_detain_stocks:
    ldx #0
detain_loop_stocks:
    lda detained_stocks_msg,X
    beq detain_done_stocks
    jsr modem_out
    inx
    bne detain_loop_stocks
detain_done_stocks:
    jsr modem_in
    dec detain_timer
    lda detain_timer
    beq clear_detain_type
    jmp town_show_menu

print_detain_jail:
    ldx #0
detain_loop_jail:
    lda detained_jail_msg,X
    beq detain_done_jail
    jsr modem_out
    inx
    bne detain_loop_jail
detain_done_jail:
    jsr modem_in
    dec detain_timer
    lda detain_timer
    beq clear_detain_type
    jmp town_show_menu

print_detain_generic:
    ldx #0
detain_loop_generic:
    lda detained_stocks_msg,X
    beq detain_done_generic
    jsr modem_out
    inx
    bne detain_loop_generic
detain_done_generic:
    jsr modem_in
    dec detain_timer
    lda detain_timer
    beq clear_detain_type
    jmp town_show_menu

clear_detain_type:
    lda #0
    sta detain_type
    jmp town_show_menu

    cmp #'1'
    bne not_watch_dance
    jmp watch_fire_dance
not_watch_dance:
    cmp #'2'
    bne not_talk_greg
    jmp talk_to_greg
not_talk_greg:
    cmp #'3'
    bne not_tip_greg
    jmp tip_greg
not_tip_greg:
    cmp #'0'
    bne stage_menu_done
    jmp town_show_menu

watch_fire_dance:
    ldx #0
fire_dance_loop:
        lda fire_dance_msg,X
        beq fire_dance_done
        jsr modem_out
        inx
        bne fire_dance_loop
fire_dance_done:
    jsr modem_in
    jmp stage_show_menu

talk_to_greg:
    ldx #0
greg_talk_loop:
        lda greg_talk_msg,X
        beq greg_talk_done
        jsr modem_out
        inx
        bne greg_talk_loop
greg_talk_done:
    jsr modem_in
    jmp stage_show_menu

tip_greg:
    // Check if player has at least 1 gold (16-bit check)
    lda player_gold
    ora player_gold+1
    bne has_gold_tip
    // No money at all
    ldx #0
no_tip_loop:
        lda no_tip_msg,X
        beq no_tip_done
        jsr modem_out
        inx
        bne no_tip_loop
no_tip_done:
    jsr modem_in
    jmp stage_show_menu
has_gold_tip:
    // Subtract 1 gold (16-bit decrement)
    lda player_gold
    sec
    sbc #1
    sta player_gold
    lda player_gold+1
    sbc #0
    sta player_gold+1
tip_given:
    ldx #0
tip_thanks_loop:
        lda tip_thanks_msg,X
        beq tip_thanks_done
        jsr modem_out
        inx
        bne tip_thanks_loop
; -------------------------
; Mystic Tent - Crafting
visit_mystic_craft:
    ldx #0
    lda mystic_craft_menu_msg,X
    beq mystic_craft_done
    jsr modem_out
    inx
    bne visit_mystic_craft
mystic_craft_done:
    jsr modem_in
    cmp #'1'
    beq mystic_do_scroll
    cmp #'2'
    beq mystic_do_trinket
    cmp #'0'
    beq visit_witch_tent
    jmp visit_mystic_craft

mystic_do_scroll:
    ; count Gems (id 6)
    lda #0
    sta craft_temp
    ldy #0
mystic_count_gems:
    cpy player_inventory_count
    beq mystic_count_gems_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne mystic_next_gem
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
mystic_next_gem:
    iny
    bne mystic_count_gems
mystic_count_gems_done:
    lda craft_temp
    cmp #1
    bcc mystic_no_materials
    ; count Leather (id 27)
    lda #0
    sta craft_tmp2
    ldy #0
mystic_count_leather:
    cpy player_inventory_count
    beq mystic_count_leather_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne mystic_next_leather
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
mystic_next_leather:
    iny
    bne mystic_count_leather
mystic_count_leather_done:
    lda craft_tmp2
    cmp #1
    bcc mystic_no_materials
    ; consume 1 Gem and 1 Leather
    lda #6
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne mystic_no_materials
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne mystic_no_materials
    ; give Spell Tome (id 33)
    lda #0
    sta craft_tmp2
    lda #33
    jsr mine_add_or_increment
    ldx #0
    lda craft_scroll_success_msg,X
    beq mystic_scroll_done
    jsr modem_out
    inx
    bne mystic_do_scroll
mystic_scroll_done:
    jsr modem_in
    jmp visit_mystic_craft

mystic_do_trinket:
    ; requires 2 Gems + 1 Leather
    lda #0
    sta craft_temp
    ldy #0
mystic_count_gems2:
    cpy player_inventory_count
    beq mystic_count_gems2_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #6
    bne mystic_next_gem2
    lda player_inventory+1,X
    clc
    adc craft_temp
    sta craft_temp
mystic_next_gem2:
    iny
    bne mystic_count_gems2
mystic_count_gems2_done:
    lda craft_temp
    cmp #2
    bcc mystic_no_materials
    ; count Leather
    lda #0
    sta craft_tmp2
    ldy #0
mystic_count_leather2:
    cpy player_inventory_count
    beq mystic_count_leather2_done
    tya
    asl
    asl
    tax
    lda player_inventory,X
    cmp #27
    bne mystic_next_leather2
    lda player_inventory+1,X
    clc
    adc craft_tmp2
    sta craft_tmp2
mystic_next_leather2:
    iny
    bne mystic_count_leather2
mystic_count_leather2_done:
    lda craft_tmp2
    cmp #1
    bcc mystic_no_materials
    ; consume 2 Gems and 1 Leather
    lda #6
    sta craft_temp
    lda #2
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne mystic_no_materials
    lda #27
    sta craft_temp
    lda #1
    sta craft_tmp2
    jsr consume_items
    lda craft_tmp2
    bne mystic_no_materials
    ; give Magic Item (id 34)
    lda #0
    sta craft_tmp2
    lda #34
    jsr mine_add_or_increment
    ldx #0
    lda craft_trinket_success_msg,X
    beq mystic_trinket_done
    jsr modem_out
    inx
    bne mystic_do_trinket
mystic_trinket_done:
    jsr modem_in
    jmp visit_mystic_craft

mystic_no_materials:
    ldx #0
    lda mystic_insuf_msg,X
    beq mystic_no_mat_done
    jsr modem_out
    inx
    bne mystic_no_materials
mystic_no_mat_done:
    jsr modem_in
    jmp visit_mystic_craft

; -------------------------
; Mystic Tent - Research
visit_mystic_research:
    ldx #0
    lda research_menu_msg,X
    beq research_menu_done
    jsr modem_out
    inx
    bne visit_mystic_research
research_menu_done:
    jsr modem_in
    cmp #'1'
    beq mystic_do_research
    cmp #'0'
    beq visit_witch_tent
    jmp visit_mystic_research

mystic_do_research:
    lda player_gold
    cmp #20
    bcc mystic_research_no_gold
    sec
    lda player_gold
    sbc #20
    sta player_gold
    jsr get_random
    and #$03
    bne mystic_research_fail
    ; success: grant Spell Tome (id 33)
    lda #0
    sta craft_tmp2
    lda #33
    jsr mine_add_or_increment
    ldx #0
    lda research_success_msg,X
    beq research_success_done
    jsr modem_out
    inx
    bne mystic_do_research
research_success_done:
    jsr modem_in
    jmp visit_mystic_research

mystic_research_fail:
    ldx #0
    lda research_fail_msg,X
    beq research_fail_done
    jsr modem_out
    inx
    bne mystic_research_fail
research_fail_done:
    jsr modem_in
    jmp visit_mystic_research

mystic_research_no_gold:
    ldx #0
    lda tool_vendor_no_gold_msg,X
    beq mystic_research_no_gold_done
    jsr modem_out
    inx
    bne mystic_research_no_gold
mystic_research_no_gold_done:
    jsr modem_in
    jmp visit_mystic_research
tip_thanks_done:
    jsr modem_in
    jmp stage_show_menu

// England / Whitecastle visit routine
visit_england:
    ldx #0
england_desc_loop:
        lda portal_england_msg,X
        beq england_menu
        jsr modem_out
        inx
        bne england_desc_loop
england_menu:
    ldx #0
england_menu_loop:
        lda england_menu_msg,X
        beq england_menu_done
        jsr modem_out
        inx
        bne england_menu_loop
england_menu_done:
    jsr modem_in
    cmp #'1'
    bne not_whitecastle
    jmp visit_whitecastle
not_whitecastle:
    cmp #'2'
    bne not_countryside
    jmp visit_countryside
not_countryside:
    cmp #'3'
    bne england_menu_done
    jmp portal_travel

visit_whitecastle:
    ldx #0
castle_loop:
        lda whitecastle_msg,X
        beq castle_done
        jsr modem_out
        inx
        bne castle_loop
castle_done:
    jsr modem_in
    jmp england_menu

visit_countryside:
    ldx #0
country_loop:
        lda england_countryside_msg,X
        beq country_done
        jsr modem_out
        inx
        bne country_loop
country_done:
    jsr modem_in
    jmp england_menu

go_portal_back:
    jmp portal_travel

portal_menu_msg:
    .text "\r\n=== PORTAL TRAVEL ===\r\nThe portal shimmers with fractured light...\r\n\r\n1. Aurora (Frost realm)\r\n2. Lore (Knight kingdom)\r\n3. Mythos (Jungle secrets)\r\n4. Town of Everland\r\n5. England (Whitecastle)\r\n0. Back to Main\r\n> "
    .byte 0

// England / Whitecastle
portal_england_msg:
    .text "\r\nYou step through the portal and arrive in ENGLAND. Rolling green hills stretch before you. In the distance, the towers of WHITECASTLE gleam in the sunlight.\r\n\r\nThis is where Damien and Princess Delphi spent their honeymoon after defeating the Pumpkin King.\r\n"
    .byte 0
england_menu_msg:
    .text "\r\nENGLAND:\r\n1. Visit Whitecastle\r\n2. Explore the Countryside\r\n3. Back to Portal\r\n> "
    .byte 0
whitecastle_msg:
    .text "\r\nWHITECASTLE rises majestically, its white stone walls gleaming. Banners flutter in the breeze. This castle hosted the royal honeymoon of Damien and Princess Delphi.\r\n\r\nServants bow as you enter. 'Welcome, traveler. The halls still echo with tales of love and triumph.'\r\n[Press any key]\r\n"
    .byte 0
england_countryside_msg:
    .text "\r\nThe English countryside spreads before you - hedgerows, meadows, and ancient oaks. Sheep graze peacefully. A distant church bell tolls.\r\n\r\n'This land knows peace,' a farmer says. 'May it ever be so.'\r\n[Press any key]\r\n"
    .byte 0

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

// === LORE BOOK BROWSER ===
browse_lore_book:
    ldx #0
lore_book_hdr_loop:
        lda lore_book_hdr_msg,X
        beq lore_book_menu
        jsr modem_out
        inx
        bne lore_book_hdr_loop
lore_book_menu:
    ldx #0
lorebook_menu_loop:
        lda lore_menu_msg,X
        beq lore_get_choice
        jsr modem_out
        inx
        bne lorebook_menu_loop
lore_get_choice:
    jsr modem_in
    cmp #'1'
    beq lore_view_history
    cmp #'2'
    beq lore_view_realms
    cmp #'3'
    beq lore_view_factions
    cmp #'4'
    beq lore_view_artifacts
    cmp #'0'
    bne lore_get_choice
    jmp library_menu
lore_view_history:
    ldx #0
lore_hist_loop:
        lda lore_history_msg,X
        beq lore_wait_key
        jsr modem_out
        inx
        bne lore_hist_loop
lore_view_realms:
    ldx #0
lore_realms_loop:
        lda lore_realms_msg,X
        beq lore_wait_key
        jsr modem_out
        inx
        bne lore_realms_loop
lore_view_factions:
    ldx #0
lore_factions_loop:
        lda lore_factions_msg,X
        beq lore_wait_key
        jsr modem_out
        inx
        bne lore_factions_loop
lore_view_artifacts:
    ldx #0
lore_artifacts_loop:
        lda lore_artifacts_msg,X
        beq lore_wait_key
        jsr modem_out
        inx
        bne lore_artifacts_loop
lore_wait_key:
    jsr modem_in
    jmp browse_lore_book

lore_book_hdr_msg:
    .text "\r\n=== LORE BOOK ===\r\nThe collected knowledge of Everland\r\n"
    .byte 0
lore_menu_msg:
    .text "\r\n1. History of Everland\r\n2. The Five Realms\r\n3. Factions & Guilds\r\n4. Legendary Artifacts\r\n0. Back\r\n> "
    .byte 0
lore_history_msg:
    .text "\r\n--- HISTORY ---\r\n\r\nEverland arose from the Fractured Rift, where realities collided. The Spider Princess arrived disoriented, protected by Kora and Kendrick. Dante the mage contains the rifts with arcane wards, while the Candy Witch delights in tearing them apart.\r\n\r\nThe Ghost Pirates, cursed and bound in Dante's bottle, haunt the spaces between. Memory and magic entwine here, where forgotten things find new life.\r\n\r\n[Press any key]\r\n"
    .byte 0
lore_realms_msg:
    .text "\r\n--- THE FIVE REALMS ---\r\n\r\nAURORA: Land of eternal twilight and crystalline spires.\r\nLORE: Ancient kingdom where wolves and humans forged the Winter Pact.\r\nMYTHOS: Realm of legends, where stories become real.\r\nENGLAND: Victorian crossroads, touched by the rifts.\r\nEVERLAND: The nexus where all realms meet.\r\n\r\n[Press any key]\r\n"
    .byte 0
lore_factions_msg:
    .text "\r\n--- FACTIONS ---\r\n\r\nTHE WINTER WOLVES: Led by Alpha Wulfric, bound by the Pact of Winter's Howl.\r\nTHE MAGES' CIRCLE: Dante and allies who ward the fractures.\r\nTHE SPIDER COURT: Followers of the lost Spider Princess.\r\nTHE GHOST CORSAIRS: Cursed pirates seeking freedom.\r\nTHE SWEET CHAOS: The Candy Witch's chaotic followers.\r\n\r\n[Press any key]\r\n"
    .byte 0
lore_artifacts_msg:
    .text "\r\n--- LEGENDARY ARTIFACTS ---\r\n\r\nDante's Bottle: Imprisons the cursed ghost pirates.\r\nThe Web Crown: The Spider Princess's lost diadem.\r\nWinter's Fang: Alpha Wulfric's blessed blade.\r\nThe Sugar Grimoire: Source of the Candy Witch's power.\r\nThe Fractured Mirror: Portal between realms.\r\n\r\n[Press any key]\r\n"
    .byte 0

// --- Songbook System ---
browse_songbooks:
    ldx #0
browse_songbooks_loop:
        lda browse_songbooks_msg,X
        beq browse_songbooks_done
        jsr modem_out
        inx
        bne browse_songbooks_loop
browse_songbooks_done:
    jsr modem_in
    cmp #'1'
    beq go_view_last_shackle
    cmp #'2'
    beq go_view_dragon_festival
    cmp #'3'
    beq go_view_anderon
    cmp #'4'
    beq go_view_fall_lore
    cmp #'5'
    beq go_view_winter_howl
    cmp #'6'
    beq go_view_frost_weaver
    cmp #'7'
    beq go_view_unseely
    cmp #'8'
    beq go_view_fractured
    cmp #'9'
    beq go_library_from_songs
    jmp browse_songbooks
go_view_last_shackle:
    jmp view_last_shackle
go_view_dragon_festival:
    jmp view_dragon_festival
go_view_anderon:
    jmp view_anderon_story
go_view_fall_lore:
    jmp view_fall_lore
go_view_winter_howl:
    jmp view_winter_howl
go_view_frost_weaver:
    jmp view_frost_weaver
go_view_unseely:
    jmp view_unseely_ritual
go_view_fractured:
    jmp view_fractured_rift
go_library_from_songs:
    jmp library_menu

browse_songbooks_msg:
    .text "\r\n=== LIBRARY COLLECTION ===\r\n"
    .text "1. The Last Shackle (Song)\r\n"
    .text "2. The Dragon Lantern Festival\r\n"
    .text "3. Anderon & The Emerald Sky\r\n"
    .text "4. The Fall of Lore\r\n"
    .text "5. The Pact of Winter's Howl\r\n"
    .text "6. The Frost Weaver's Rite\r\n"
    .text "7. The Unseely Fae Ritual\r\n"
    .text "8. The Fractured Rift\r\n"
    .text "9. Back to Library\r\n> "
    .byte 0

view_last_shackle:
    ldx #0
view_last_shackle_loop:
        lda last_shackle_song,X
        beq view_last_shackle_done
        jsr modem_out
        inx
        bne view_last_shackle_loop
view_last_shackle_done:
    // Continue with second part (string > 255 chars)
    ldx #0
view_last_shackle_loop2:
        lda last_shackle_song2,X
        beq view_last_shackle_done2
        jsr modem_out
        inx
        bne view_last_shackle_loop2
view_last_shackle_done2:
    ldx #0
view_last_shackle_loop3:
        lda last_shackle_song3,X
        beq view_last_shackle_done3
        jsr modem_out
        inx
        bne view_last_shackle_loop3
view_last_shackle_done3:
    jsr modem_in  // Wait for keypress
    jmp browse_songbooks

last_shackle_song:
    .text "\r\n======================================\r\n"
    .text "     THE LAST SHACKLE\r\n"
    .text "     by Bonny Red Boots\r\n"
    .text "======================================\r\n\r\n"
    .text "There once was a ship that sailed\r\n"
    .text "through the skies\r\n"
    .byte 0

last_shackle_song2:
    .text "Her hold was loaded with broken lives\r\n"
    .text "For she was manned by a slaver's crew\r\n"
    .text "She longed for the day she could\r\n"
    .text "sing this tune\r\n\r\n"
    .text "  Come all ye pirates, ye bold and true\r\n"
    .text "  Come all ye pirates the lucky few\r\n"
    .text "  The endless sea calls out to the free\r\n"
    .byte 0

last_shackle_song3:
    .text "  Aboard the last shackle with\r\n"
    .text "  all of her crew\r\n\r\n"
    .text "A dastardly trap the slavers had planned\r\n"
    .text "They caught some sailors, shackled\r\n"
    .text "their hands\r\n"
    .text "But a prisoner waited, biding his time\r\n"
    .text "He poisoned the guards with fancy wine\r\n\r\n"
    .text "[Chorus repeats]\r\n\r\n"
    .text "Oh they were outnumbered by one to 5\r\n"
    .text "But the captives left not a slaver alive\r\n"
    .text "Then the prisoner rose to captain\r\n"
    .text "the helm\r\n"
    .text "Named her, the Last Shackle, to sail\r\n"
    .text "through the realms\r\n\r\n"
    .text "  Come board the last shackle,\r\n"
    .text "  she's waiting for you!\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// --- Dragon Lantern Festival Story ---
view_dragon_festival:
    ldx #0
view_dragon_fest_loop1:
        lda dragon_festival_1,X
        beq view_dragon_fest_done1
        jsr modem_out
        inx
        bne view_dragon_fest_loop1
view_dragon_fest_done1:
    ldx #0
view_dragon_fest_loop2:
        lda dragon_festival_2,X
        beq view_dragon_fest_done2
        jsr modem_out
        inx
        bne view_dragon_fest_loop2
view_dragon_fest_done2:
    ldx #0
view_dragon_fest_loop3:
        lda dragon_festival_3,X
        beq view_dragon_fest_done3
        jsr modem_out
        inx
        bne view_dragon_fest_loop3
view_dragon_fest_done3:
    ldx #0
view_dragon_fest_loop4:
        lda dragon_festival_4,X
        beq view_dragon_fest_done4
        jsr modem_out
        inx
        bne view_dragon_fest_loop4
view_dragon_fest_done4:
    ldx #0
view_dragon_fest_loop5:
        lda dragon_festival_5,X
        beq view_dragon_fest_done5
        jsr modem_out
        inx
        bne view_dragon_fest_loop5
view_dragon_fest_done5:
    ldx #0
view_dragon_fest_loop6:
        lda dragon_festival_6,X
        beq view_dragon_fest_done6
        jsr modem_out
        inx
        bne view_dragon_fest_loop6
view_dragon_fest_done6:
    jsr modem_in  // Wait for keypress
    jmp browse_songbooks

dragon_festival_1:
    .text "\r\n======================================\r\n"
    .text "   THE DRAGON LANTERN FESTIVAL\r\n"
    .text "======================================\r\n\r\n"
    .text "Mage Damon's mind was clouded,\r\n"
    .text "memories of the fateful night before\r\n"
    .text "the disappearance faded, but now,\r\n"
    .text "fragment by fragment, they started\r\n"
    .text "to piece together.\r\n\r\n"
    .byte 0

dragon_festival_2:
    .text "He recalled when Tammis and her\r\n"
    .text "sister Saga invited him to the\r\n"
    .text "mystical Dragon Lantern Festival.\r\n\r\n"
    .text "The storyteller announced: 'Ladies\r\n"
    .text "and gentle folk, gather around for\r\n"
    .text "a revered tradition - the tale of\r\n"
    .text "the timeless battle: Everland.'\r\n\r\n"
    .byte 0

dragon_festival_3:
    .text "Long ago, three realms coexisted:\r\n"
    .text "Aurora with snow-capped peaks,\r\n"
    .text "Lore with radiant cities,\r\n"
    .text "Mythos with lush jungles.\r\n\r\n"
    .text "Within Mythos, a malevolent force\r\n"
    .text "brewed. Banished, it traveled to\r\n"
    .text "Lore, perfecting its darkness.\r\n"
    .text "This became The Darkness.\r\n\r\n"
    .byte 0

dragon_festival_4:
    .text "King Lowden vowed to defend his\r\n"
    .text "realm. Though outnumbered, his\r\n"
    .text "warriors stood their ground.\r\n\r\n"
    .text "With the Dragon Queen's arrival,\r\n"
    .text "the tides turned. Her flames proved\r\n"
    .text "pivotal, leading to victory.\r\n\r\n"
    .text "[MORE - Press any key]\r\n"
    .byte 0

dragon_festival_5:
    .text "\r\nAs the narrative reached its\r\n"
    .text "crescendo, deep silence descended.\r\n"
    .text "Torches cast elongated shadows.\r\n\r\n"
    .text "Damon pondered the implications.\r\n"
    .text "The sense of foreboding lingered,\r\n"
    .text "amplified by the absence of Tammis,\r\n"
    .text "Saga, and the townsfolk.\r\n\r\n"
    .byte 0

dragon_festival_6:
    .text "He sensed lingering magic, like\r\n"
    .text "wisps of a fading enchantment.\r\n\r\n"
    .text "Venturing into the woods, he found\r\n"
    .text "a clearing where a fading portal\r\n"
    .text "shimmered - the ancient Celtic\r\n"
    .text "temple that connected Lore to\r\n"
    .text "Mythos and Earth.\r\n\r\n"
    .text "Taking a deep breath, Mage Damon\r\n"
    .text "stepped through the portal...\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// === STORY 3: ANDERON & ORDER OF THE EMERALD SKY ===
view_anderon_story:
    ldx #0
view_anderon_loop1:
        lda anderon_story_1,X
        beq view_anderon_done1
        jsr modem_out
        inx
        bne view_anderon_loop1
view_anderon_done1:
    ldx #0
view_anderon_loop2:
        lda anderon_story_2,X
        beq view_anderon_done2
        jsr modem_out
        inx
        bne view_anderon_loop2
view_anderon_done2:
    ldx #0
view_anderon_loop3:
        lda anderon_story_3,X
        beq view_anderon_done3
        jsr modem_out
        inx
        bne view_anderon_loop3
view_anderon_done3:
    ldx #0
view_anderon_loop4:
        lda anderon_story_4,X
        beq view_anderon_done4
        jsr modem_out
        inx
        bne view_anderon_loop4
view_anderon_done4:
    jsr modem_in
    jmp browse_songbooks

anderon_story_1:
    .text "\r\n======================================\r\n"
    .text "  ANDERON & THE ORDER OF EMERALD SKY\r\n"
    .text "======================================\r\n\r\n"
    .text "Alister, the renowned Dragon Trainer,\r\n"
    .text "stood before a crowd in Everland.\r\n\r\n"
    .text "'Many years ago, Anderon the great\r\n"
    .text "dragon found himself in dire straits.\r\n"
    .byte 0

anderon_story_2:
    .text "As he soared through the sky, he\r\n"
    .text "snagged the tip of a great pine tree,\r\n"
    .text "which dug deep between his claws.'\r\n\r\n"
    .text "'His cry reached a village nearby.\r\n"
    .text "The villagers banded together and\r\n"
    .text "ventured into the woods to aid him.'\r\n\r\n"
    .text "'As the tree was pulled free, a bond\r\n"
    .text "between humans and dragons was forged.'\r\n"
    .byte 0

anderon_story_3:
    .text "\r\n'Through the Order of the Emerald Sky,\r\n"
    .text "we vow to protect, aid, and deepen\r\n"
    .text "our knowledge of dragons.'\r\n\r\n"
    .text "THE OATHS:\r\n"
    .text "'I swear to protect dragons for as\r\n"
    .text "long as my arms have strength.'\r\n\r\n"
    .text "'I swear to aid dragons as long as\r\n"
    .text "my legs may carry me.'\r\n"
    .byte 0

anderon_story_4:
    .text "\r\n'I swear to deepen my knowledge of\r\n"
    .text "dragons and share it with others as\r\n"
    .text "long as my mind follows me.'\r\n\r\n"
    .text "'When saying goodbye, sweep your\r\n"
    .text "fingers away and say: Fly on the\r\n"
    .text "dragon's wings.'\r\n\r\n"
    .text "Welcome to the Order of Emerald Sky.\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// === STORY 4: THE FALL OF LORE ===
view_fall_lore:
    ldx #0
view_fall_lore_loop1:
        lda fall_lore_1,X
        beq view_fall_lore_done1
        jsr modem_out
        inx
        bne view_fall_lore_loop1
view_fall_lore_done1:
    ldx #0
view_fall_lore_loop2:
        lda fall_lore_2,X
        beq view_fall_lore_done2
        jsr modem_out
        inx
        bne view_fall_lore_loop2
view_fall_lore_done2:
    ldx #0
view_fall_lore_loop3:
        lda fall_lore_3,X
        beq view_fall_lore_done3
        jsr modem_out
        inx
        bne view_fall_lore_loop3
view_fall_lore_done3:
    ldx #0
view_fall_lore_loop4:
        lda fall_lore_4,X
        beq view_fall_lore_done4
        jsr modem_out
        inx
        bne view_fall_lore_loop4
view_fall_lore_done4:
    jsr modem_in
    jmp browse_songbooks

fall_lore_1:
    .text "\r\n======================================\r\n"
    .text "       THE FALL OF LORE\r\n"
    .text "======================================\r\n\r\n"
    .text "Once upon a time, in the enchanting\r\n"
    .text "world of Lore, Damon was an aspiring\r\n"
    .text "mage entertaining knights with magic.\r\n\r\n"
    .text "But a plague of vampires began to\r\n"
    .text "terrorize the land...\r\n"
    .byte 0

fall_lore_2:
    .text "\r\nAmongst this grim backdrop existed a\r\n"
    .text "garden of poisonous green thorns.\r\n"
    .text "The plants became center of oaths:\r\n\r\n"
    .text "'May the green thorn pierce me if I\r\n"
    .text "fail in my quest.'\r\n\r\n"
    .text "Mage Damon discovered the location of\r\n"
    .text "a mystical portal to Everland...\r\n"
    .byte 0

fall_lore_3:
    .text "\r\nWith the dark sun and moon crystals,\r\n"
    .text "Damon, Barnabis, Damian, and Princess\r\n"
    .text "Delphi fled through the portal as it\r\n"
    .text "closed behind them.\r\n\r\n"
    .text "Unknown to them, Arch Magus Kasimere,\r\n"
    .text "the oldest vampire, followed through.\r\n"
    .text "'Soon we conquer this land also...'\r\n"
    .byte 0

fall_lore_4:
    .text "\r\nAs they passed through, a dense fog\r\n"
    .text "swept over their minds, erasing all\r\n"
    .text "memories temporarily.\r\n\r\n"
    .text "In Lore, the Order of the Black Rose\r\n"
    .text "fell to the vampires' assault.\r\n\r\n"
    .text "Mage Damon retook the oath and vowed\r\n"
    .text "to restore the order.\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// === STORY 5: THE PACT OF WINTER'S HOWL ===
view_winter_howl:
    ldx #0
view_winter_loop1:
        lda winter_howl_1,X
        beq view_winter_done1
        jsr modem_out
        inx
        bne view_winter_loop1
view_winter_done1:
    ldx #0
view_winter_loop2:
        lda winter_howl_2,X
        beq view_winter_done2
        jsr modem_out
        inx
        bne view_winter_loop2
view_winter_done2:
    ldx #0
view_winter_loop3:
        lda winter_howl_3,X
        beq view_winter_done3
        jsr modem_out
        inx
        bne view_winter_loop3
view_winter_done3:
    jsr modem_in
    jmp browse_songbooks

winter_howl_1:
    .text "\r\n======================================\r\n"
    .text "    THE PACT OF WINTER'S HOWL\r\n"
    .text "======================================\r\n\r\n"
    .text "As winter's whispers wove through\r\n"
    .text "Everland, the Wolves of Winter, led\r\n"
    .text "by Alpha Wulfric Vassa, knew their\r\n"
    .text "time had come.\r\n\r\n"
    .byte 0

winter_howl_2:
    .text "Beta Lyra approached Van Bueler's\r\n"
    .text "office on a frost-laden evening.\r\n\r\n"
    .text "'We seek sustenance for the winter.\r\n"
    .text "In exchange for our protection, we\r\n"
    .text "ask that you provide provisions.'\r\n\r\n"
    .text "The negotiation continued into night,\r\n"
    .text "until an agreement was reached.\r\n"
    .byte 0

winter_howl_3:
    .text "\r\nWith the Pact sealed, wolves embarked\r\n"
    .text "on traditional trials: enduring cold,\r\n"
    .text "outwitting riddles, braving wilderness.\r\n\r\n"
    .text "Upon completion, wolves and humans\r\n"
    .text "join under moonlit sky, their united\r\n"
    .text "howls echoing when the train rumbles\r\n"
    .text "by, delighting passing passengers.\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// === STORY 6: THE FROST WEAVER'S RITE ===
view_frost_weaver:
    ldx #0
view_frost_loop1:
        lda frost_weaver_1,X
        beq view_frost_done1
        jsr modem_out
        inx
        bne view_frost_loop1
view_frost_done1:
    ldx #0
view_frost_loop2:
        lda frost_weaver_2,X
        beq view_frost_done2
        jsr modem_out
        inx
        bne view_frost_loop2
view_frost_done2:
    ldx #0
view_frost_loop3:
        lda frost_weaver_3,X
        beq view_frost_done3
        jsr modem_out
        inx
        bne view_frost_loop3
view_frost_done3:
    jsr modem_in
    jmp browse_songbooks

frost_weaver_1:
    .text "\r\n======================================\r\n"
    .text "     THE FROST WEAVER'S RITE\r\n"
    .text "======================================\r\n\r\n"
    .text "As the snowy storm raged outside the\r\n"
    .text "Burrows, the Frost Weaver Queen,\r\n"
    .text "radiant and powerful, beckoned the\r\n"
    .text "citizens to join her ritual.\r\n\r\n"
    .byte 0

frost_weaver_2:
    .text "'In the tradition of witches, wizards\r\n"
    .text "and sages that protected Aurora for\r\n"
    .text "centuries, our duty falls onto you.'\r\n\r\n"
    .text "THE SPELLS:\r\n"
    .text "GLACIOUS - The power of ice at your\r\n"
    .text "fingertips, to fight enemies.\r\n\r\n"
    .text "NIX - The flowy drifts of snow are\r\n"
    .text "yours to command and ensnare.\r\n"
    .byte 0

frost_weaver_3:
    .text "\r\nILLUMINA - You shall be a light in\r\n"
    .text "the darkness, a beacon in the storm,\r\n"
    .text "and a guide in the chaos.\r\n\r\n"
    .text "'The ritual is complete. May all\r\n"
    .text "magic join with yours and yours\r\n"
    .text "with ours. Together we bring peace\r\n"
    .text "and light to this land.'\r\n\r\n"
    .text "Welcome to the Frost Weavers.\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// === STORY 7: THE UNSEELY FAE RITUAL ===
view_unseely_ritual:
    ldx #0
view_unseely_loop1:
        lda unseely_ritual_1,X
        beq view_unseely_done1
        jsr modem_out
        inx
        bne view_unseely_loop1
view_unseely_done1:
    ldx #0
view_unseely_loop2:
        lda unseely_ritual_2,X
        beq view_unseely_done2
        jsr modem_out
        inx
        bne view_unseely_loop2
view_unseely_done2:
    ldx #0
view_unseely_loop3:
        lda unseely_ritual_3,X
        beq view_unseely_done3
        jsr modem_out
        inx
        bne view_unseely_loop3
view_unseely_done3:
    jsr modem_in
    jmp browse_songbooks

unseely_ritual_1:
    .text "\r\n======================================\r\n"
    .text "   THE UNSEELY FAE'S NECROMANCY\r\n"
    .text "======================================\r\n\r\n"
    .text "The sun dipped low, casting shadows\r\n"
    .text "across ancient ruins. Mage Damon\r\n"
    .text "stood amidst the unseely fae, their\r\n"
    .text "silhouettes dancing in firelight.\r\n\r\n"
    .byte 0

unseely_ritual_2:
    .text "Torin, leader of the unseely court,\r\n"
    .text "spoke: 'You have proven your loyalty.\r\n"
    .text "In return, we wish for you to become\r\n"
    .text "part of the unseely Fae court.'\r\n\r\n"
    .text "'Hold out your hand and kneel. To\r\n"
    .text "join us, you must take part in a\r\n"
    .text "binding ritual.'\r\n"
    .byte 0

unseely_ritual_3:
    .text "\r\nTHE INCANTATION:\r\n"
    .text "Goofice Goafice Alakda,\r\n"
    .text "Orgawal, Goragawal.\r\n\r\n"
    .text "'Now I have your binding acknowledge-\r\n"
    .text "ments that you will forever follow\r\n"
    .text "in everything that I have planned.'\r\n\r\n"
    .text "The souls are now bound to the\r\n"
    .text "unseely court forever...\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// === STORY 8: THE FRACTURED RIFT ===
view_fractured_rift:
    ldx #0
view_rift_loop1:
        lda fractured_rift_1,X
        beq view_rift_done1
        jsr modem_out
        inx
        bne view_rift_loop1
view_rift_done1:
    ldx #0
view_rift_loop2:
        lda fractured_rift_2,X
        beq view_rift_done2
        jsr modem_out
        inx
        bne view_rift_loop2
view_rift_done2:
    ldx #0
view_rift_loop3:
        lda fractured_rift_3,X
        beq view_rift_done3
        jsr modem_out
        inx
        bne view_rift_loop3
view_rift_done3:
    ldx #0
view_rift_loop4:
        lda fractured_rift_4,X
        beq view_rift_done4
        jsr modem_out
        inx
        bne view_rift_loop4
view_rift_done4:
    jsr modem_in
    jmp browse_songbooks

fractured_rift_1:
    .text "\r\n======================================\r\n"
    .text "       THE FRACTURED RIFT\r\n"
    .text "======================================\r\n\r\n"
    .text "Mage Damon entered town expecting\r\n"
    .text "song and dance. But the Mayor looked\r\n"
    .text "at him peculiarly...\r\n\r\n"
    .text "'Don't you know me?' Damon offered.\r\n"
    .text "'I believe this is the first time\r\n"
    .text "we have met.'\r\n"
    .byte 0

fractured_rift_2:
    .text "\r\n'I have been here many months!'\r\n"
    .text "exclaimed Mage Damon.\r\n\r\n"
    .text "'Perhaps consult the Mystics,' the\r\n"
    .text "Mayor offered. No one knew him.\r\n\r\n"
    .text "At the Mystic's tent, Mela spoke:\r\n"
    .text "'Come back when we close for night,\r\n"
    .text "and we shall speak more of this.'\r\n"
    .byte 0

fractured_rift_3:
    .text "\r\nMela's eyes glowed as she spoke:\r\n"
    .text "'The temporal strands that weave the\r\n"
    .text "tapestry of time now lie in disarray,\r\n"
    .text "beset by an enigmatic force.'\r\n\r\n"
    .text "Kal added: 'The very vivacity of this\r\n"
    .text "realm is assailed by an enigmatic\r\n"
    .text "rift transcending temporal artifice.'\r\n"
    .byte 0

fractured_rift_4:
    .text "\r\n'Fragments of time coalesce in\r\n"
    .text "enigmatic convergence, weaving a\r\n"
    .text "tapestry of discordant echoes.'\r\n\r\n"
    .text "With collective resolve, they sought\r\n"
    .text "to unveil the source of the anomaly,\r\n"
    .text "a conundrum that defied boundaries\r\n"
    .text "of comprehension...\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

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
    .text "\r\nBeta Lyra, seasoned second-in-command of the Wolves of Winter, regards you with glistening determination.\r\n\r\n'We seek sustenance for the winter. In exchange for our protection, Van Bueler provides provisions. The Pact of Winter's Howl binds us.'\r\n\r\nWolf Quest Chain:\r\n1. Prove your mettle through trials\r\n2. Endure biting cold without complaint\r\n3. Outwit the cunning riddles\r\n4. Join the moonlit howl with the pack\r\n\r\n'Upon success, we convene whenever trains rumble by - our howls delight the passengers.'\r\n\r\n(Quest: Earn the trust of the Wolves.)\r\n[Press any key]\r\n"

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
    .text "\r\nVan Bueler, a man of stern countenance with piercing eyes, greets you from his trading office. A fireplace crackles within.\r\n\r\n'Beta Lyra of the Wolves approached me for the Pact of Winter's Howl. Sustenance for the pack in exchange for protection.'\r\n\r\nTrade Quest Chain:\r\n1. Negotiate fair terms for the town's stores\r\n2. Funnel provisions to Hunter's Hovel\r\n3. Ensure Everland survives the winter\r\n4. Witness the wolf-human howl when trains pass\r\n\r\n'The town requires its own stores - I must assure our people as well.'\r\n\r\n(Quest: Help balance wolf and human needs.)\r\n[Press any key]\r\n"

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
    .text "\r\nGwen stands silently, her eyes betraying deep emotion rarely shown. 'Grim... he gave everything to defeat the Pumpkin King. One strike of the enchanted spear, one green thorn through his heart.'\r\n\r\nShe clutches a withered black rose. 'I wept but once. That was enough.'\r\n\r\n(Quest: Honor Grim's sacrifice - plant black roses at the cursed garden.)\r\n[Press any key]\r\n"

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
    .text "\r\nGrim of the Blackhearts looms silent, his massive enchanted spear resting nearby. Few words leave his lips, but his eyes speak volumes.\r\n\r\n'The Pumpkin King thought himself immortal. He was wrong. One strike from behind while others drew his gaze... that's how legends fall.'\r\n\r\n(Quest: Join Grim in the final assault on the cursed garden.)\r\n[Press any key]\r\n"

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
    bne not_edit_desc
    jmp edit_room_description
not_edit_desc:
    cmp #'2'
    bne not_choose_decor
    jmp choose_room_decor
not_choose_decor:
    cmp #'3'
    bne not_choose_color
    jmp choose_room_color
not_choose_color:
    cmp #'4'
    bne not_edit_ascii
    jmp edit_room_ascii
not_edit_ascii:
    cmp #'5'
    bne not_view_ascii
    jmp view_room_ascii
not_view_ascii:
    cmp #'6'
    bne not_view_guestbook
    jmp view_guestbook
not_view_guestbook:
    cmp #'7'
    bne not_leave_guestbook
    jmp leave_guestbook
not_leave_guestbook:
    cmp #'8'
    bne not_room_privacy
    jmp room_privacy_menu
not_room_privacy:
    cmp #'9'
    bne not_friends_list
    jmp friends_list_menu
not_friends_list:
    cmp #'V'
    bne not_visit_rooms
    jmp go_visit_rooms
not_visit_rooms:
    cmp #'M'
    bne not_messaging
    jmp messaging_menu
not_messaging:
    cmp #'P'
    bne not_room_preview
    jmp room_preview
not_room_preview:
    cmp #'L'
    bne not_visitor_log
    jmp go_visitor_log
not_visitor_log:
    cmp #'Y'
    bne not_player_profile
    jmp go_player_profile
not_player_profile:
    cmp #'G'
    bne not_gifts_menu
    jmp go_gifts_menu
not_gifts_menu:
    cmp #'T'
    bne not_top_rooms
    jmp go_top_rooms
not_top_rooms:
    cmp #'E'
    bne not_events_menu
    jmp go_events_menu
not_events_menu:
    cmp #'X'
    bne not_trade_menu
    jmp go_trade_menu
not_trade_menu:
    cmp #'W'
    bne not_minigames_menu
    jmp go_minigames_menu
not_minigames_menu:
    cmp #'D'
    bne not_daily_reward
    jmp go_daily_reward
not_daily_reward:
    cmp #'S'
    bne not_room_shop
    jmp go_room_shop
not_room_shop:
    cmp #'Q'
    bne not_quests_menu
    jmp go_quests_menu
not_quests_menu:
    cmp #'H'
    bne not_hall_of_fame
    jmp go_hall_of_fame
not_hall_of_fame:
    cmp #'A'
    bne not_pets_menu
    jmp go_pets_menu
not_pets_menu:
    cmp #'B'
    bne not_badges_menu
    jmp go_badges_menu
not_badges_menu:
    cmp #'$'
    bne not_lottery_menu
    jmp go_lottery_menu
not_lottery_menu:
    cmp #'K'
    bne not_bank_menu
    jmp go_bank_menu
not_bank_menu:
    cmp #'U'
    bne not_auction_menu
    jmp go_auction_menu
not_auction_menu:
    cmp #'Z'
    bne not_weather_menu
    jmp go_weather_menu
not_weather_menu:
    cmp #'C'
    bne not_crafting_menu
    jmp go_crafting_menu
not_crafting_menu:
    cmp #'R'
    bne not_reputation_menu
    jmp go_reputation_menu
not_reputation_menu:
    cmp #'J'
    bne not_achievements_menu
    jmp go_achievements_menu
not_achievements_menu:
    cmp #'F'
    bne not_guilds_menu
    jmp go_guilds_menu
not_guilds_menu:
    cmp #'N'
    bne not_titles_menu
    jmp go_titles_menu
not_titles_menu:
    cmp #'O'
    bne not_fortune_menu
    jmp go_fortune_menu
not_fortune_menu:
    cmp #'I'
    bne not_garden_menu
    jmp go_garden_menu
not_garden_menu:
    cmp #'~'
    bne not_fishing_menu
    jmp go_fishing_menu
not_fishing_menu:
    cmp #'`'
    bne not_racing_menu
    jmp go_racing_menu
not_racing_menu:
    cmp #';'
    bne not_treasure_menu
    jmp go_treasure_menu
not_treasure_menu:
    cmp #':'
    beq go_cooking_menu
    cmp #'='
    beq go_dueling_menu
    cmp #'+'
    beq go_mailbox_menu
    cmp #'?'
    beq go_riddles_menu
    cmp #'!'
    bne not_bounty_menu2
    jmp go_bounty_menu
not_bounty_menu2:
    cmp #'@'
    bne not_companion_menu2
    jmp go_companion_menu
not_companion_menu2:
    cmp #'#'
    bne not_tavern_menu
    jmp go_tavern_menu
not_tavern_menu:
    cmp #'%'
    bne not_dice_menu
    jmp go_dice_menu
not_dice_menu:
    cmp #'^'
    bne not_scavenge_menu
    jmp go_scavenge_menu
not_scavenge_menu:
    cmp #'&'
    bne not_meditate_menu
    jmp go_meditate_menu
not_meditate_menu:
    cmp #'*'
    bne not_spy_menu
    jmp go_spy_menu
not_spy_menu:
    cmp #'('
    bne not_arena_menu
    jmp go_arena_menu
not_arena_menu:
    cmp #')'
    bne not_museum_menu
    jmp go_museum_menu
not_museum_menu:
    cmp #'0'
    bne stay_room_menu
    jmp go_main_from_room
stay_room_menu:
    jmp user_room_menu

go_museum_menu:
    jmp museum_menu
go_arena_menu:
    jmp arena_menu
go_spy_menu:
    jmp spy_menu
go_meditate_menu:
    jmp meditate_menu
go_scavenge_menu:
    jmp scavenge_menu
go_dice_menu:
    jmp dice_menu
go_tavern_menu:
    jmp tavern_menu
go_companion_menu:
    jmp companion_menu
go_bounty_menu:
    jmp bounty_menu
go_riddles_menu:
    jmp riddles_menu
go_mailbox_menu:
    jmp mailbox_menu
go_dueling_menu:
    jmp dueling_menu
go_cooking_menu:
    jmp cooking_menu
go_treasure_menu:
    jmp treasure_menu
go_racing_menu:
    jmp racing_menu

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
go_visit_rooms:
    jmp visit_rooms_menu
go_messaging:
    jmp messaging_menu
go_room_preview:
    jmp room_preview
go_visitor_log:
    jmp view_visitor_log
go_player_profile:
    jmp player_profile_menu
go_gifts_menu:
    jmp gifts_menu
go_top_rooms:
    jmp top_rooms_leaderboard
go_events_menu:
    jmp events_menu
go_trade_menu:
    jmp trade_menu
go_minigames_menu:
    jmp minigames_menu
go_daily_reward:
    jmp daily_reward_menu
go_room_shop:
    jmp room_shop_menu
go_quests_menu:
    jmp quests_menu
go_hall_of_fame:
    jmp hall_of_fame_menu
go_pets_menu:
    jmp pets_menu
go_badges_menu:
    jmp badges_menu
go_lottery_menu:
    jmp lottery_menu
go_bank_menu:
    jmp bank_menu
go_auction_menu:
    jmp auction_menu
go_weather_menu:
    jmp weather_menu
go_crafting_menu:
    jmp crafting_menu
go_reputation_menu:
    jmp reputation_menu
go_achievements_menu:
    jmp achievements_menu
go_guilds_menu:
    jmp guilds_menu
go_titles_menu:
    jmp titles_menu
go_fortune_menu:
    jmp fortune_menu
go_garden_menu:
    jmp garden_menu
go_fishing_menu:
    jmp fishing_menu
go_main_from_room:
    jmp main_loop

user_room_menu_msg:
    .text "\r\nMY ROOM:\r\n1. Edit Description\r\n2. Choose Decor\r\n3. Choose Color\r\n4. Edit ASCII Art\r\n5. View ASCII Art\r\n6. View Guestbook\r\n7. Leave Guestbook Entry\r\n8. Privacy Settings\r\n9. Friends List\r\nV. Visit Other Rooms\r\nM. Messages\r\nP. Preview Room\r\nL. Visitor Log\r\nY. Your Profile\r\nG. Gifts\r\nT. Top Rooms\r\nE. Events\r\nX. Trade\r\nW. Mini-Games\r\nD. Daily Reward\r\nS. Shop\r\nQ. Quests\r\nH. Hall of Fame\r\nA. Pets\r\nB. Badges\r\n$. Lottery\r\nK. Bank\r\nU. Auction\r\nZ. Weather\r\nC. Crafting\r\nR. Reputation\r\nJ. Achievements\r\nF. Guilds\r\nN. Titles\r\nO. Fortune\r\nI. Garden\r\n~. Fishing\r\n`. Racing\r\n;. Treasure\r\n:. Cooking\r\n=. Dueling\r\n+. Mailbox\r\n?. Riddles\r\n!. Bounty\r\n@. Companion\r\n#. Tavern\r\n%. Dice\r\n^. Scavenge\r\n&. Meditate\r\n*. Spy\r\n(. Arena\r\n). Museum\r\n0. Back to Main\r\n> "

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

// ============================================
// VISIT OTHER ROOMS
// ============================================
visit_rooms_menu:
    ldx #0
visit_rooms_header_loop:
        lda visit_rooms_header_msg,X
        beq visit_rooms_header_done
        jsr modem_out
        inx
        bne visit_rooms_header_loop
visit_rooms_header_done:
    // List sample rooms
    ldy #0
list_rooms_loop:
        // Print room number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print room name (16 chars)
        ldx #0
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_room_name:
            lda sample_room_names,X
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_room_name
        lda #13
        jsr modem_out
        iny
        cpy #5
        bne list_rooms_loop
    // Show menu prompt
    ldx #0
visit_rooms_prompt_loop:
        lda visit_rooms_prompt_msg,X
        beq visit_rooms_prompt_done
        jsr modem_out
        inx
        bne visit_rooms_prompt_loop
visit_rooms_prompt_done:
    jsr modem_in
    cmp #'0'
    beq go_back_to_room_menu
    cmp #'1'
    bcc visit_rooms_menu
    cmp #'6'
    bcs visit_rooms_menu
    // Valid room 1-5, store selection
    sec
    sbc #'1'
    sta visit_selected_room
    jmp enter_visited_room
go_back_to_room_menu:
    jmp user_room_menu

visit_selected_room: .byte 0

enter_visited_room:
    // Show visiting message
    ldx #0
entering_room_loop:
        lda entering_room_msg,X
        beq entering_room_done
        jsr modem_out
        inx
        bne entering_room_loop
entering_room_done:
    // Show room owner name
    lda visit_selected_room
    asl
    asl
    asl
    asl  // * 16
    tax
print_owner_loop:
        lda sample_room_owners,X
        jsr modem_out
        inx
        txa
        and #$0F
        bne print_owner_loop
    ldx #0
room_content_loop:
        lda room_content_msg,X
        beq room_content_done
        jsr modem_out
        inx
        bne room_content_loop
room_content_done:
    // Show rating
    ldx visit_selected_room
    lda sample_room_ratings,X
    clc
    adc #'0'
    jsr modem_out
    lda #'/'
    jsr modem_out
    lda #'5'
    jsr modem_out
    lda #13
    jsr modem_out
    // Show actions menu
    ldx #0
visit_actions_loop:
        lda visit_actions_msg,X
        beq visit_actions_done
        jsr modem_out
        inx
        bne visit_actions_loop
visit_actions_done:
    jsr modem_in
    cmp #'G'
    beq visit_leave_guestbook
    cmp #'R'
    beq visit_rate_room
    cmp #'F'
    beq go_visit_add_friend
    cmp #'M'
    beq go_visit_send_msg
    cmp #'0'
    beq go_back_visit_list
    jmp enter_visited_room
go_visit_add_friend:
    jmp visit_add_owner_friend
go_visit_send_msg:
    jmp visit_send_owner_msg
go_back_visit_list:
    jmp visit_rooms_menu

visit_leave_guestbook:
    ldx #0
visit_guest_prompt_loop:
        lda visit_guest_prompt_msg,X
        beq visit_guest_prompt_done
        jsr modem_out
        inx
        bne visit_guest_prompt_loop
visit_guest_prompt_done:
    // Read input (simulated - in real BBS would save to owner's file)
    ldx #0
visit_guest_input:
        jsr modem_in
        cmp #13
        beq visit_guest_saved
        inx
        cpx #32
        bne visit_guest_input
visit_guest_saved:
    ldx #0
visit_guest_saved_loop:
        lda visit_guest_saved_msg,X
        beq visit_guest_saved_done
        jsr modem_out
        inx
        bne visit_guest_saved_loop
visit_guest_saved_done:
    jmp enter_visited_room

visit_rate_room:
    ldx #0
visit_rate_prompt_loop:
        lda visit_rate_prompt_msg,X
        beq visit_rate_prompt_done
        jsr modem_out
        inx
        bne visit_rate_prompt_loop
visit_rate_prompt_done:
    jsr modem_in
    cmp #'1'
    bcc visit_rate_invalid
    cmp #'6'
    bcs visit_rate_invalid
    // Update rating (simulated)
    ldx #0
visit_rated_loop:
        lda visit_rated_msg,X
        beq visit_rated_done
        jsr modem_out
        inx
        bne visit_rated_loop
visit_rated_done:
    jmp enter_visited_room
visit_rate_invalid:
    jmp visit_rate_room

visit_add_owner_friend:
    // Add room owner to friends list
    ldy #0
find_empty_friend:
        lda user_friends_list,Y
        beq found_friend_slot
        iny
        cpy #16
        bne find_empty_friend
        // Full - show error
        ldx #0
friends_full_loop:
            lda friends_full_msg,X
            beq friends_full_done
            jsr modem_out
            inx
            bne friends_full_loop
friends_full_done:
        jmp enter_visited_room
found_friend_slot:
    // Store owner's first char as ID (simplified)
    lda visit_selected_room
    asl
    asl
    asl
    asl
    tax
    lda sample_room_owners,X
    sta user_friends_list,Y
    inc user_friends_count
    ldx #0
friend_added_visit_loop:
        lda friend_added_visit_msg,X
        beq friend_added_visit_done
        jsr modem_out
        inx
        bne friend_added_visit_loop
friend_added_visit_done:
    jmp enter_visited_room

visit_send_owner_msg:
    ldx #0
visit_msg_prompt_loop:
        lda visit_msg_prompt_msg,X
        beq visit_msg_prompt_done
        jsr modem_out
        inx
        bne visit_msg_prompt_loop
visit_msg_prompt_done:
    ldx #0
visit_msg_input:
        jsr modem_in
        cmp #13
        beq visit_msg_sent
        inx
        cpx #48
        bne visit_msg_input
visit_msg_sent:
    ldx #0
visit_msg_sent_loop:
        lda visit_msg_sent_msg,X
        beq visit_msg_sent_done
        jsr modem_out
        inx
        bne visit_msg_sent_loop
visit_msg_sent_done:
    jmp enter_visited_room

visit_rooms_header_msg:
    .text "\r\nVISIT OTHER ROOMS:\r\n"
visit_rooms_prompt_msg:
    .text "\r\nEnter room # (1-5) or 0 to go back: "
entering_room_msg:
    .text "\r\nEntering room owned by: "
room_content_msg:
    .text "\r\n\r\nWelcome to this room!\r\nA cozy space decorated with care.\r\n\r\nRating: "
visit_actions_msg:
    .text "\r\n(G) Leave Guestbook\r\n(R) Rate Room\r\n(F) Add Owner as Friend\r\n(M) Send Message\r\n(0) Back to Room List\r\n> "
visit_guest_prompt_msg:
    .text "\r\nLeave a message (32 chars): "
visit_guest_saved_msg:
    .text "\r\nGuestbook entry saved!\r\n"
visit_rate_prompt_msg:
    .text "\r\nRate this room (1-5): "
visit_rated_msg:
    .text "\r\nThanks for rating!\r\n"
friends_full_msg:
    .text "\r\nFriends list is full!\r\n"
friend_added_visit_msg:
    .text "\r\nOwner added to friends!\r\n"
visit_msg_prompt_msg:
    .text "\r\nEnter message (48 chars): "
visit_msg_sent_msg:
    .text "\r\nMessage sent!\r\n"

// ============================================
// MESSAGING SYSTEM
// ============================================
messaging_menu:
    ldx #0
messaging_header_loop:
        lda messaging_header_msg,X
        beq messaging_header_done
        jsr modem_out
        inx
        bne messaging_header_loop
messaging_header_done:
    // Show inbox count
    lda user_inbox_count
    clc
    adc #'0'
    jsr modem_out
    ldx #0
inbox_count_suffix_loop:
        lda inbox_count_suffix_msg,X
        beq inbox_count_suffix_done
        jsr modem_out
        inx
        bne inbox_count_suffix_loop
inbox_count_suffix_done:
    // Show menu
    ldx #0
messaging_options_loop:
        lda messaging_options_msg,X
        beq messaging_options_done
        jsr modem_out
        inx
        bne messaging_options_loop
messaging_options_done:
    jsr modem_in
    cmp #'R'
    beq go_read_messages
    cmp #'C'
    beq go_compose_message
    cmp #'D'
    beq go_delete_message
    cmp #'G'
    beq go_claim_mail_gold
    cmp #'0'
    beq go_back_room_msg
    jmp messaging_menu
go_read_messages:
    jmp read_messages
go_compose_message:
    jmp compose_message
go_delete_message:
    jmp delete_message
go_claim_mail_gold:
    jmp claim_mail_gold
go_back_room_msg:
    jmp user_room_menu

read_messages:
    lda user_inbox_count
    beq go_no_messages
    // List messages
    ldx #0
read_msg_header_loop:
        lda read_msg_header_msg,X
        beq read_msg_header_done
        jsr modem_out
        inx
        bne read_msg_header_loop
read_msg_header_done:
    jmp list_messages_start
go_no_messages:
    jmp no_messages
list_messages_start:
    ldy #0
list_messages_loop:
        cpy user_inbox_count
        beq list_messages_done
        // Print message number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print from (first 16 bytes of message)
        tya
        asl
        asl
        asl
        asl
        asl
        asl  // Y * 64
        tax
print_msg_from:
            lda user_inbox,X
            beq print_msg_from_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_msg_from
print_msg_from_done:
        lda #13
        jsr modem_out
        iny
        cpy #5
        bne list_messages_loop
list_messages_done:
    ldx #0
read_which_loop:
        lda read_which_msg,X
        beq read_which_done
        jsr modem_out
        inx
        bne read_which_loop
read_which_done:
    jsr modem_in
    cmp #'0'
    beq go_back_messaging
    sec
    sbc #'1'
    cmp user_inbox_count
    bcs read_messages
    // Show message content
    asl
    asl
    asl
    asl
    asl
    asl  // * 64
    clc
    adc #16  // Skip from, get content
    tax
    ldx #0
show_msg_content_loop:
        lda user_inbox+16,X
        beq show_msg_content_done
        jsr modem_out
        inx
        cpx #48
        bne show_msg_content_loop
show_msg_content_done:
    lda #13
    jsr modem_out
    jsr modem_in  // Wait for key
    jmp read_messages
go_back_messaging:
    jmp messaging_menu

no_messages:
    ldx #0
no_messages_loop:
        lda no_messages_msg,X
        beq no_messages_done
        jsr modem_out
        inx
        bne no_messages_loop
no_messages_done:
    jsr modem_in
    jmp messaging_menu

compose_message:
    ldx #0
compose_to_loop:
        lda compose_to_msg,X
        beq compose_to_done
        jsr modem_out
        inx
        bne compose_to_loop
compose_to_done:
    // Get recipient
    ldx #0
compose_to_input:
        jsr modem_in
        cmp #13
        beq compose_to_entered
        sta user_outbox_temp,X
        inx
        cpx #16
        bne compose_to_input
compose_to_entered:
    lda #0
    sta user_outbox_temp,X
    // Get message content
    ldx #0
compose_content_loop:
        lda compose_content_msg,X
        beq compose_content_done
        jsr modem_out
        inx
        bne compose_content_loop
compose_content_done:
    ldx #0
compose_content_input:
        jsr modem_in
        cmp #13
        beq compose_content_entered
        sta user_outbox_temp+16,X
        inx
        cpx #48
        bne compose_content_input
compose_content_entered:
    lda #0
    sta user_outbox_temp+16,X
    // Confirm sent
    ldx #0
compose_sent_loop:
        lda compose_sent_msg,X
        beq compose_sent_done
        jsr modem_out
        inx
        bne compose_sent_loop
compose_sent_done:
    jmp messaging_menu

delete_message:
    lda user_inbox_count
    beq no_messages
    ldx #0
delete_which_loop:
        lda delete_which_msg,X
        beq delete_which_done
        jsr modem_out
        inx
        bne delete_which_loop
delete_which_done:
    jsr modem_in
    cmp #'0'
    beq go_back_messaging2
    sec
    sbc #'1'
    cmp user_inbox_count
    bcs delete_message
    // Shift messages down
    tay
    dec user_inbox_count
    ldx #0
delete_confirmed_loop:
        lda delete_confirmed_msg,X
        beq delete_confirmed_done
        jsr modem_out
        inx
        bne delete_confirmed_loop
delete_confirmed_done:
    jmp messaging_menu
go_back_messaging2:
    jmp messaging_menu

claim_mail_gold:
    lda mail_claimed
    bne mail_gold_already
    lda #1
    sta mail_claimed
    lda player_gold
    clc
    adc mail_reward
    sta player_gold
    ldx #0
mail_gold_claimed_loop:
        lda mail_gold_claimed_msg,X
        beq mail_gold_claimed_done
        jsr modem_out
        inx
        bne mail_gold_claimed_loop
mail_gold_claimed_done:
    jsr modem_in
    jmp messaging_menu
mail_gold_already:
    ldx #0
mail_gold_already_loop:
        lda mail_gold_already_msg,X
        beq mail_gold_already_done
        jsr modem_out
        inx
        bne mail_gold_already_loop
mail_gold_already_done:
    jsr modem_in
    jmp messaging_menu

messaging_header_msg:
    .text "\r\nMESSAGES:\r\nInbox: "
inbox_count_suffix_msg:
    .text " message(s)\r\n"
messaging_options_msg:
    .text "\r\n(R) Read Messages\r\n(C) Compose New\r\n(D) Delete Message\r\n(G) Claim Daily Reward\r\n(0) Back\r\n> "
read_msg_header_msg:
    .text "\r\nINBOX:\r\n"
read_which_msg:
    .text "\r\nEnter # to read, 0 to go back: "
no_messages_msg:
    .text "\r\nNo messages in inbox.\r\n[Press any key]\r\n"
compose_to_msg:
    .text "\r\nTo (player name): "
compose_content_msg:
    .text "\r\nMessage (48 chars): "
compose_sent_msg:
    .text "\r\nMessage sent!\r\n"
delete_which_msg:
    .text "\r\nEnter # to delete, 0 to cancel: "
delete_confirmed_msg:
    .text "\r\nMessage deleted.\r\n"
mail_gold_claimed_msg:
    .text "\r\nDaily reward claimed! +5 gold\r\n[Press any key]\r\n"
    .byte 0
mail_gold_already_msg:
    .text "\r\nReward already claimed today!\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// ROOM PREVIEW
// ============================================
room_preview:
    ldx #0
preview_header_loop:
        lda preview_header_msg,X
        beq preview_header_done
        jsr modem_out
        inx
        bne preview_header_loop
preview_header_done:
    // Show title
    ldx #0
preview_title_loop:
        lda user_room_title,X
        beq preview_title_done
        jsr modem_out
        inx
        cpx #32
        bne preview_title_loop
preview_title_done:
    lda #13
    jsr modem_out
    // Show description
    ldx #0
preview_desc_loop:
        lda user_room_desc,X
        beq preview_desc_done
        jsr modem_out
        inx
        cpx #64
        bne preview_desc_loop
preview_desc_done:
    lda #13
    jsr modem_out
    // Show ASCII art
    ldy #0
preview_art_line:
        ldx #0
preview_art_char:
            lda user_room_ascii,X
            beq preview_art_next
            jsr modem_out
            inx
            cpx #32
            bne preview_art_char
preview_art_next:
        lda #13
        jsr modem_out
        iny
        cpy #4
        bne preview_art_line
    // Show rating
    ldx #0
preview_rating_loop:
        lda preview_rating_msg,X
        beq preview_rating_done
        jsr modem_out
        inx
        bne preview_rating_loop
preview_rating_done:
    lda user_room_rating_count
    beq preview_no_rating
    // Calculate average
    lda user_room_rating_sum
    ldx user_room_rating_count
    jsr divide_a_by_x
    clc
    adc #'0'
    jsr modem_out
    lda #'/'
    jsr modem_out
    lda #'5'
    jsr modem_out
    jmp preview_end
preview_no_rating:
    ldx #0
preview_no_rating_loop:
        lda preview_no_rating_msg,X
        beq preview_no_rating_done
        jsr modem_out
        inx
        bne preview_no_rating_loop
preview_no_rating_done:
preview_end:
    lda #13
    jsr modem_out
    ldx #0
preview_footer_loop:
        lda preview_footer_msg,X
        beq preview_footer_done
        jsr modem_out
        inx
        bne preview_footer_loop
preview_footer_done:
    jsr modem_in
    jmp user_room_menu

divide_a_by_x:
    // Simple division: A / X -> A
    stx temp_divisor
    ldy #0
divide_loop:
        cmp temp_divisor
        bcc divide_done
        sec
        sbc temp_divisor
        iny
        jmp divide_loop
divide_done:
    tya
    rts
temp_divisor: .byte 0

preview_header_msg:
    .text "\r\n=== ROOM PREVIEW ===\r\n"
preview_rating_msg:
    .text "\r\nRating: "
preview_no_rating_msg:
    .text "No ratings yet"
preview_footer_msg:
    .text "\r\n[Press any key to continue]\r\n"

// ============================================
// VISITOR LOG
// ============================================
view_visitor_log:
    ldx #0
visitor_log_header_loop:
        lda visitor_log_header_msg,X
        beq visitor_log_header_done
        jsr modem_out
        inx
        bne visitor_log_header_loop
visitor_log_header_done:
    lda user_room_visitor_count
    beq no_visitors
    // List visitors
    ldy #0
list_visitors_loop:
        cpy user_room_visitor_count
        beq list_visitors_done
        // Print visitor number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print visitor ID (8 bytes per entry)
        tya
        asl
        asl
        asl  // Y * 8
        tax
print_visitor:
            lda user_room_visitors,X
            beq print_visitor_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_visitor
print_visitor_done:
        lda #13
        jsr modem_out
        iny
        cpy #5
        bne list_visitors_loop
list_visitors_done:
    jsr modem_in
    jmp user_room_menu

no_visitors:
    ldx #0
no_visitors_loop:
        lda no_visitors_msg,X
        beq no_visitors_done
        jsr modem_out
        inx
        bne no_visitors_loop
no_visitors_done:
    jsr modem_in
    jmp user_room_menu

visitor_log_header_msg:
    .text "\r\nVISITOR LOG:\r\n"
no_visitors_msg:
    .text "No visitors yet.\r\n[Press any key]\r\n"

// ============================================
// PLAYER PROFILE SYSTEM
// ============================================

player_profile_menu:
    ldx #0
profile_menu_loop:
        lda profile_menu_msg,X
        beq profile_menu_done
        jsr modem_out
        inx
        bne profile_menu_loop
profile_menu_done:
    jsr modem_in
    cmp #'1'
    beq go_view_my_profile
    cmp #'2'
    beq go_edit_my_bio
    cmp #'3'
    beq go_edit_my_title
    cmp #'4'
    beq go_view_achievements
    cmp #'5'
    beq go_view_my_stats
    cmp #'0'
    beq go_back_from_profile
    jmp player_profile_menu
go_view_my_profile:
    jmp view_my_profile
go_edit_my_bio:
    jmp edit_my_bio
go_edit_my_title:
    jmp edit_my_title
go_view_achievements:
    jmp view_achievements
go_view_my_stats:
    jmp view_my_stats
go_back_from_profile:
    jmp user_room_menu

profile_menu_msg:
    .text "\r\nYOUR PROFILE:\r\n1. View Profile\r\n2. Edit Bio\r\n3. Edit Title\r\n4. View Achievements\r\n5. View Stats\r\n0. Back\r\n> "

view_my_profile:
    // Print header
    ldx #0
view_profile_header_loop:
        lda view_profile_header_msg,X
        beq view_profile_header_done
        jsr modem_out
        inx
        bne view_profile_header_loop
view_profile_header_done:
    // Print username
    ldx #0
print_profile_name:
        lda user_name,X
        beq profile_name_done
        cmp #32
        beq profile_name_done
        jsr modem_out
        inx
        cpx #16
        bne print_profile_name
profile_name_done:
    lda #13
    jsr modem_out
    // Print title
    ldx #0
print_title_label:
        lda title_label_msg,X
        beq title_label_done
        jsr modem_out
        inx
        bne print_title_label
title_label_done:
    lda player_title
    beq no_title_set
    ldx #0
print_player_title:
        lda player_title,X
        beq player_title_done
        jsr modem_out
        inx
        cpx #16
        bne print_player_title
    jmp player_title_done
no_title_set:
    ldx #0
print_no_title:
        lda no_title_msg,X
        beq player_title_done
        jsr modem_out
        inx
        bne print_no_title
player_title_done:
    lda #13
    jsr modem_out
    // Print bio
    ldx #0
print_bio_label:
        lda bio_label_msg,X
        beq bio_label_done
        jsr modem_out
        inx
        bne print_bio_label
bio_label_done:
    lda player_bio
    beq no_bio_set
    ldx #0
print_player_bio:
        lda player_bio,X
        beq player_bio_done
        jsr modem_out
        inx
        cpx #64
        bne print_player_bio
    jmp player_bio_done
no_bio_set:
    ldx #0
print_no_bio:
        lda no_bio_msg,X
        beq player_bio_done
        jsr modem_out
        inx
        bne print_no_bio
player_bio_done:
    lda #13
    jsr modem_out
    // Wait for key
    ldx #0
press_key_profile_loop:
        lda press_key_msg,X
        beq press_key_profile_done
        jsr modem_out
        inx
        bne press_key_profile_loop
press_key_profile_done:
    jsr modem_in
    jmp player_profile_menu

view_profile_header_msg:
    .text "\r\n=== PLAYER PROFILE ===\r\nName: "
title_label_msg:
    .text "Title: "
bio_label_msg:
    .text "Bio: "
no_title_msg:
    .text "(No title set)"
no_bio_msg:
    .text "(No bio set)"
press_key_msg:
    .text "\r\n[Press any key]\r\n"

edit_my_bio:
    ldx #0
edit_bio_prompt_loop:
        lda edit_bio_prompt_msg,X
        beq edit_bio_prompt_done
        jsr modem_out
        inx
        bne edit_bio_prompt_loop
edit_bio_prompt_done:
    ldx #0
edit_bio_input:
        jsr modem_in
        cmp #13
        beq edit_bio_save
        sta player_bio,X
        inx
        cpx #64
        bne edit_bio_input
edit_bio_save:
    lda #0
    sta player_bio,X
    ldx #0
bio_saved_loop:
        lda bio_saved_msg,X
        beq bio_saved_done
        jsr modem_out
        inx
        bne bio_saved_loop
bio_saved_done:
    jmp player_profile_menu

edit_bio_prompt_msg:
    .text "\r\nEnter your bio (64 chars max):\r\n> "
bio_saved_msg:
    .text "\r\nBio saved!\r\n"

edit_my_title:
    ldx #0
edit_title_prompt_loop:
        lda edit_title_prompt_msg,X
        beq edit_title_prompt_done
        jsr modem_out
        inx
        bne edit_title_prompt_loop
edit_title_prompt_done:
    ldx #0
edit_title_input:
        jsr modem_in
        cmp #13
        beq edit_title_save
        sta player_title,X
        inx
        cpx #16
        bne edit_title_input
edit_title_save:
    lda #0
    sta player_title,X
    ldx #0
title_saved_loop:
        lda title_saved_msg,X
        beq title_saved_done
        jsr modem_out
        inx
        bne title_saved_loop
title_saved_done:
    jmp player_profile_menu

edit_title_prompt_msg:
    .text "\r\nEnter your title (16 chars max):\r\n> "
title_saved_msg:
    .text "\r\nTitle saved!\r\n"

view_achievements:
    ldx #0
achieve_header_loop:
        lda achieve_header_msg,X
        beq achieve_header_done
        jsr modem_out
        inx
        bne achieve_header_loop
achieve_header_done:
    // Check each achievement bit
    ldy #0
check_achievement_loop:
        lda player_achievements
        and achieve_bit_masks,Y
        beq achievement_locked
        // Unlocked - print checkmark and name
        lda #'*'
        jsr modem_out
        lda #' '
        jsr modem_out
        jmp print_achievement_name
achievement_locked:
        // Locked - print space and name
        lda #' '
        jsr modem_out
        lda #' '
        jsr modem_out
print_achievement_name:
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_achieve_char:
            lda achievement_names,X
            beq achieve_name_done
            cmp #$20
            beq achieve_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_achieve_char
achieve_name_done:
        lda #13
        jsr modem_out
        iny
        cpy #8
        bne check_achievement_loop
    // Wait for key
    ldx #0
achieve_press_key_loop:
        lda press_key_msg,X
        beq achieve_press_key_done
        jsr modem_out
        inx
        bne achieve_press_key_loop
achieve_press_key_done:
    jsr modem_in
    jmp player_profile_menu

achieve_header_msg:
    .text "\r\n=== ACHIEVEMENTS ===\r\n(* = unlocked)\r\n"
achieve_bit_masks:
    .byte $01, $02, $04, $08, $10, $20, $40, $80
achievement_names:
    .text "First Login     "  // Bit 0
    .text "Reached Level 5 "  // Bit 1
    .text "Monster Slayer  "  // Bit 2
    .text "Quest Complete  "  // Bit 3
    .text "Friendship      "  // Bit 4
    .text "Room Explorer   "  // Bit 5
    .text "Gold Collector  "  // Bit 6
    .text "Master Adventur "  // Bit 7

view_my_stats:
    ldx #0
stats_header_loop:
        lda stats_header_msg,X
        beq stats_header_done
        jsr modem_out
        inx
        bne stats_header_loop
stats_header_done:
    // Games Played
    ldx #0
games_played_label_loop:
        lda games_played_label,X
        beq games_played_label_done
        jsr modem_out
        inx
        bne games_played_label_loop
games_played_label_done:
    lda player_games_played
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Games Won
    ldx #0
games_won_label_loop:
        lda games_won_label,X
        beq games_won_label_done
        jsr modem_out
        inx
        bne games_won_label_loop
games_won_label_done:
    lda player_games_won
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Quests Done
    ldx #0
quests_label_loop:
        lda quests_done_label,X
        beq quests_label_done
        jsr modem_out
        inx
        bne quests_label_loop
quests_label_done:
    lda player_quests_done
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Friends Made
    ldx #0
friends_label_loop:
        lda friends_made_label,X
        beq friends_label_done
        jsr modem_out
        inx
        bne friends_label_loop
friends_label_done:
    lda player_friends_made
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Rooms Visited
    ldx #0
rooms_label_loop:
        lda rooms_visited_label,X
        beq rooms_label_done
        jsr modem_out
        inx
        bne rooms_label_loop
rooms_label_done:
    lda player_rooms_visited
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Messages Sent
    ldx #0
messages_label_loop:
        lda messages_sent_label,X
        beq messages_label_done
        jsr modem_out
        inx
        bne messages_label_loop
messages_label_done:
    lda player_messages_sent
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Wait for key
    ldx #0
stats_press_key_loop:
        lda press_key_msg,X
        beq stats_press_key_done
        jsr modem_out
        inx
        bne stats_press_key_loop
stats_press_key_done:
    jsr modem_in
    jmp player_profile_menu

stats_header_msg:
    .text "\r\n=== YOUR STATS ===\r\n"
games_played_label:
    .text "Games Played: "
games_won_label:
    .text "Games Won: "
quests_done_label:
    .text "Quests Done: "
friends_made_label:
    .text "Friends Made: "
rooms_visited_label:
    .text "Rooms Visited: "
messages_sent_label:
    .text "Messages Sent: "

// Print byte in A as decimal (0-255)
print_byte_decimal:
    pha
    ldx #0
    // Hundreds
    lda #0
    sta temp_digit
hundreds_loop:
        pla
        cmp #100
        bcc print_tens
        sec
        sbc #100
        pha
        inc temp_digit
        jmp hundreds_loop
print_tens:
    pha
    lda temp_digit
    beq skip_hundreds
    clc
    adc #'0'
    jsr modem_out
    ldx #1  // Flag that we printed something
skip_hundreds:
    lda #0
    sta temp_digit
    pla
tens_loop:
        cmp #10
        bcc print_ones
        sec
        sbc #10
        inc temp_digit
        jmp tens_loop
print_ones:
    pha
    lda temp_digit
    bne print_tens_digit
    cpx #0
    beq skip_tens
print_tens_digit:
    clc
    adc #'0'
    jsr modem_out
skip_tens:
    pla
    clc
    adc #'0'
    jsr modem_out
    rts
temp_digit: .byte 0

// ============================================
// GIFTS SYSTEM
// ============================================

gifts_menu:
    ldx #0
gifts_menu_header_loop:
        lda gifts_menu_msg,X
        beq gifts_menu_header_done
        jsr modem_out
        inx
        bne gifts_menu_header_loop
gifts_menu_header_done:
    jsr modem_in
    cmp #'1'
    beq go_view_received_gifts
    cmp #'2'
    beq go_send_gift
    cmp #'3'
    beq go_view_balance
    cmp #'0'
    beq go_back_from_gifts
    jmp gifts_menu
go_view_received_gifts:
    jmp view_received_gifts
go_send_gift:
    jmp send_gift_menu
go_view_balance:
    jmp view_gift_balance
go_back_from_gifts:
    jmp user_room_menu

gifts_menu_msg:
    .text "\r\nGIFTS:\r\n1. View Received Gifts\r\n2. Send a Gift\r\n3. View Balance\r\n0. Back\r\n> "

view_received_gifts:
    lda received_gifts_count
    beq go_no_gifts_received
    // Print header
    ldx #0
received_gifts_header_loop:
        lda received_gifts_header_msg,X
        beq received_gifts_header_done
        jsr modem_out
        inx
        bne received_gifts_header_loop
received_gifts_header_done:
    ldy #0
list_gifts_loop:
        cpy received_gifts_count
        beq go_list_gifts_done
        // Print gift number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print from name (8 chars at offset Y*16)
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_gift_from:
            lda received_gifts,X
            beq gift_from_done
            cmp #$20
            beq gift_from_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_gift_from
gift_from_done:
        // Print gift type
        lda #':'
        jsr modem_out
        lda #' '
        jsr modem_out
        tya
        asl
        asl
        asl
        asl
        clc
        adc #8  // Offset to type byte
        tax
        lda received_gifts,X
        // Multiply by 8 for gift name lookup
        asl
        asl
        asl
        tax
print_gift_type:
            lda gift_type_names,X
            cmp #$20
            beq gift_type_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_gift_type
gift_type_done:
        lda #13
        jsr modem_out
        iny
        cpy #5
        bne list_gifts_loop
    jmp list_gifts_done
go_no_gifts_received:
    jmp no_gifts_received
go_list_gifts_done:
    jmp list_gifts_done
list_gifts_done:
    // Option to accept/clear gifts
    ldx #0
accept_gifts_prompt_loop:
        lda accept_gifts_prompt_msg,X
        beq accept_gifts_prompt_done
        jsr modem_out
        inx
        bne accept_gifts_prompt_loop
accept_gifts_prompt_done:
    jsr modem_in
    cmp #'Y'
    bne go_skip_accept_gifts
    // Clear all gifts
    lda #0
    sta received_gifts_count
    ldx #0
gifts_accepted_loop:
        lda gifts_accepted_msg,X
        beq gifts_accepted_done
        jsr modem_out
        inx
        bne gifts_accepted_loop
gifts_accepted_done:
    jmp gifts_menu
go_skip_accept_gifts:
    jmp gifts_menu

no_gifts_received:
    ldx #0
no_gifts_loop:
        lda no_gifts_msg,X
        beq no_gifts_done
        jsr modem_out
        inx
        bne no_gifts_loop
no_gifts_done:
    jsr modem_in
    jmp gifts_menu

received_gifts_header_msg:
    .text "\r\nRECEIVED GIFTS:\r\n"
no_gifts_msg:
    .text "\r\nNo gifts received.\r\n[Press any key]\r\n"
accept_gifts_prompt_msg:
    .text "\r\nAccept all gifts? (Y/N) "
gifts_accepted_msg:
    .text "\r\nGifts accepted!\r\n"

send_gift_menu:
    // Show current balance
    ldx #0
send_gift_balance_loop:
        lda send_gift_balance_msg,X
        beq send_gift_balance_done
        jsr modem_out
        inx
        bne send_gift_balance_loop
send_gift_balance_done:
    lda player_gold
    jsr print_byte_decimal
    ldx #0
gold_suffix_loop:
        lda gold_suffix_msg,X
        beq gold_suffix_done
        jsr modem_out
        inx
        bne gold_suffix_loop
gold_suffix_done:
    // Show gift types with costs
    ldx #0
gift_types_header_loop:
        lda gift_types_msg,X
        beq gift_types_header_done
        jsr modem_out
        inx
        bne gift_types_header_loop
gift_types_header_done:
    ldy #0
list_gift_types_loop:
        cpy gift_types_count
        beq list_gift_types_done
        // Print number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print gift name
        tya
        asl
        asl
        asl
        tax
print_gift_name_list:
            lda gift_type_names,X
            cmp #$20
            beq gift_name_list_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_gift_name_list
gift_name_list_done:
        // Print cost
        lda #' '
        jsr modem_out
        lda #'('
        jsr modem_out
        lda gift_type_costs,Y
        jsr print_byte_decimal
        lda #'g'
        jsr modem_out
        lda #')'
        jsr modem_out
        lda #13
        jsr modem_out
        iny
        cpy #4
        bne list_gift_types_loop
list_gift_types_done:
    // Prompt for choice
    ldx #0
choose_gift_prompt_loop:
        lda choose_gift_msg,X
        beq choose_gift_prompt_done
        jsr modem_out
        inx
        bne choose_gift_prompt_loop
choose_gift_prompt_done:
    jsr modem_in
    cmp #'0'
    beq go_back_to_gifts
    sec
    sbc #'1'
    cmp #4
    bcs go_send_gift_menu_again
    sta gift_choice
    // Check if player can afford
    tax
    lda gift_type_costs,X
    cmp player_gold
    beq can_afford_gift
    bcc can_afford_gift
    // Can't afford
    ldx #0
cant_afford_loop:
        lda cant_afford_msg,X
        beq cant_afford_done
        jsr modem_out
        inx
        bne cant_afford_loop
cant_afford_done:
    jsr modem_in
    jmp gifts_menu
go_back_to_gifts:
    jmp gifts_menu
go_send_gift_menu_again:
    jmp send_gift_menu
can_afford_gift:
    // Deduct cost
    ldx gift_choice
    lda player_gold
    sec
    sbc gift_type_costs,X
    sta player_gold
    // Show recipient prompt
    ldx #0
recipient_prompt_loop:
        lda recipient_prompt_msg,X
        beq recipient_prompt_done
        jsr modem_out
        inx
        bne recipient_prompt_loop
recipient_prompt_done:
    // For now, just confirm sent
    jsr modem_in
    ldx #0
gift_sent_loop:
        lda gift_sent_msg,X
        beq gift_sent_done
        jsr modem_out
        inx
        bne gift_sent_loop
gift_sent_done:
    jsr modem_in
    jmp gifts_menu

gift_choice: .byte 0
send_gift_balance_msg:
    .text "\r\nYour gold: "
gold_suffix_msg:
    .text "\r\n"
gift_types_msg:
    .text "\r\nGift Types:\r\n"
choose_gift_msg:
    .text "\r\nChoose gift (0=back): "
cant_afford_msg:
    .text "\r\nNot enough gold!\r\n[Press any key]\r\n"
recipient_prompt_msg:
    .text "\r\nEnter recipient (press key): "
gift_sent_msg:
    .text "\r\nGift sent!\r\n[Press any key]\r\n"

view_gift_balance:
    ldx #0
balance_header_loop:
        lda balance_header_msg,X
        beq balance_header_done
        jsr modem_out
        inx
        bne balance_header_loop
balance_header_done:
    // Gold
    ldx #0
gold_label_loop:
        lda gold_label_msg,X
        beq gold_label_done
        jsr modem_out
        inx
        bne gold_label_loop
gold_label_done:
    lda player_gold
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Gems
    ldx #0
gems_label_loop:
        lda gems_label_msg,X
        beq gems_label_done
        jsr modem_out
        inx
        bne gems_label_loop
gems_label_done:
    lda player_gems
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Wait for key
    ldx #0
balance_press_key_loop:
        lda press_key_msg,X
        beq balance_press_key_done
        jsr modem_out
        inx
        bne balance_press_key_loop
balance_press_key_done:
    jsr modem_in
    jmp gifts_menu

balance_header_msg:
    .text "\r\n=== YOUR BALANCE ===\r\n"
gold_label_msg:
    .text "Gold: "
gems_label_msg:
    .text "Gems: "

// ============================================
// ROOM LEADERBOARD
// ============================================

top_rooms_leaderboard:
    // Print header
    ldx #0
leaderboard_header_loop:
        lda leaderboard_header_msg,X
        beq leaderboard_header_done
        jsr modem_out
        inx
        bne leaderboard_header_loop
leaderboard_header_done:
    // Sort and display top 5 rooms by rating
    // For now, display sample rooms in order with their ratings
    ldy #0
leaderboard_rank_loop:
        cpy sample_rooms_count
        beq go_leaderboard_done
        // Print rank
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print stars for rating
        ldx sample_room_ratings,Y
        stx star_count
print_stars_loop:
            lda star_count
            beq stars_done
            lda #'*'
            jsr modem_out
            dec star_count
            jmp print_stars_loop
stars_done:
        lda #' '
        jsr modem_out
        // Print room name (16 chars)
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_lb_room_name:
            lda sample_room_names,X
            cmp #$20
            beq lb_room_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_lb_room_name
lb_room_name_done:
        // Print owner in parentheses
        lda #' '
        jsr modem_out
        lda #'('
        jsr modem_out
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_lb_owner:
            lda sample_room_owners,X
            cmp #$20
            beq lb_owner_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_lb_owner
lb_owner_done:
        lda #')'
        jsr modem_out
        lda #13
        jsr modem_out
        iny
        cpy #5
        bne leaderboard_rank_loop
    jmp leaderboard_done
go_leaderboard_done:
    jmp leaderboard_done
leaderboard_done:
    // Show your room's rank
    ldx #0
your_rank_loop:
        lda your_rank_msg,X
        beq your_rank_done
        jsr modem_out
        inx
        bne your_rank_loop
your_rank_done:
    lda user_room_rating
    jsr print_byte_decimal
    ldx #0
stars_suffix_loop:
        lda stars_suffix_msg,X
        beq stars_suffix_done
        jsr modem_out
        inx
        bne stars_suffix_loop
stars_suffix_done:
    // Wait for key
    ldx #0
lb_press_key_loop:
        lda press_key_msg,X
        beq lb_press_key_done
        jsr modem_out
        inx
        bne lb_press_key_loop
lb_press_key_done:
    jsr modem_in
    jmp user_room_menu

star_count: .byte 0
leaderboard_header_msg:
    .text "\r\n=== TOP ROOMS ===\r\n\r\n"
your_rank_msg:
    .text "\r\nYour room rating: "
stars_suffix_msg:
    .text " stars\r\n"

// ============================================
// ROOM EVENTS SYSTEM
// ============================================

events_menu:
    ldx #0
events_menu_header_loop:
        lda events_menu_msg,X
        beq events_menu_header_done
        jsr modem_out
        inx
        bne events_menu_header_loop
events_menu_header_done:
    jsr modem_in
    cmp #'1'
    beq go_view_my_events
    cmp #'2'
    beq go_create_event
    cmp #'3'
    beq go_cancel_event
    cmp #'4'
    beq go_browse_events
    cmp #'5'
    beq go_realm_calendar
    cmp #'0'
    beq go_back_from_events
    jmp events_menu
go_view_my_events:
    jmp view_my_events
go_create_event:
    jmp create_event
go_cancel_event:
    jmp cancel_event
go_browse_events:
    jmp browse_all_events
go_realm_calendar:
    jmp realm_calendar
go_back_from_events:
    jmp user_room_menu

events_menu_msg:
    .text "\r\nEVENTS:\r\n1. View My Events\r\n2. Create Event\r\n3. Cancel Event\r\n4. Browse All Events\r\n5. Realm Calendar\r\n0. Back\r\n\r\n*** OCTOBER: Dragon Lantern Festival ***\r\nAll carry lanterns! Visit Dragon Haven!\r\n> "

view_my_events:
    lda user_events_count
    beq go_no_events
    // Print header
    ldx #0
my_events_header_loop:
        lda my_events_header_msg,X
        beq my_events_header_done
        jsr modem_out
        inx
        bne my_events_header_loop
my_events_header_done:
    ldy #0
list_my_events_loop:
        cpy user_events_count
        beq go_list_my_events_done
        // Print event number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print event title (16 chars at offset Y*32)
        tya
        asl
        asl
        asl
        asl
        asl  // Y * 32
        tax
print_event_title:
            lda user_events,X
            beq event_title_done
            cmp #$20
            beq event_title_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_event_title
event_title_done:
        // Print event type
        lda #' '
        jsr modem_out
        lda #'['
        jsr modem_out
        tya
        asl
        asl
        asl
        asl
        asl
        clc
        adc #24  // Offset to type byte
        tax
        lda user_events,X
        // Multiply by 8 for type name lookup
        asl
        asl
        asl
        tax
print_event_type:
            lda event_type_names,X
            cmp #$20
            beq event_type_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_event_type
event_type_done:
        lda #']'
        jsr modem_out
        lda #13
        jsr modem_out
        iny
        cpy #3
        bne list_my_events_loop
    jmp list_my_events_done
go_no_events:
    jmp no_events_scheduled
go_list_my_events_done:
    jmp list_my_events_done
list_my_events_done:
    ldx #0
events_press_key_loop:
        lda press_key_msg,X
        beq events_press_key_done
        jsr modem_out
        inx
        bne events_press_key_loop
events_press_key_done:
    jsr modem_in
    jmp events_menu

no_events_scheduled:
    ldx #0
no_events_loop:
        lda no_events_msg,X
        beq no_events_done
        jsr modem_out
        inx
        bne no_events_loop
no_events_done:
    jsr modem_in
    jmp events_menu

my_events_header_msg:
    .text "\r\nYOUR SCHEDULED EVENTS:\r\n"
no_events_msg:
    .text "\r\nNo events scheduled.\r\n[Press any key]\r\n"

create_event:
    // Check if max events
    lda user_events_count
    cmp #3
    bcc can_create_event
    ldx #0
max_events_loop:
        lda max_events_msg,X
        beq max_events_done
        jsr modem_out
        inx
        bne max_events_loop
max_events_done:
    jsr modem_in
    jmp events_menu
can_create_event:
    // Get event title
    ldx #0
event_title_prompt_loop:
        lda event_title_prompt_msg,X
        beq event_title_prompt_done
        jsr modem_out
        inx
        bne event_title_prompt_loop
event_title_prompt_done:
    // Calculate offset for new event
    lda user_events_count
    asl
    asl
    asl
    asl
    asl  // count * 32
    tax
    ldy #0
event_title_input:
        jsr modem_in
        cmp #13
        beq event_title_input_done
        sta user_events,X
        inx
        iny
        cpy #16
        bne event_title_input
event_title_input_done:
    lda #0
    sta user_events,X
    // Get event type
    ldx #0
event_type_prompt_loop:
        lda event_type_prompt_msg,X
        beq event_type_prompt_done
        jsr modem_out
        inx
        bne event_type_prompt_loop
event_type_prompt_done:
    jsr modem_in
    sec
    sbc #'1'
    cmp #4
    bcs go_create_event_again
    sta event_temp_type
    // Store type in event
    lda user_events_count
    asl
    asl
    asl
    asl
    asl
    clc
    adc #24  // Offset to type byte
    tax
    lda event_temp_type
    sta user_events,X
    // Increment count
    inc user_events_count
    // Confirm
    ldx #0
event_created_loop:
        lda event_created_msg,X
        beq event_created_done
        jsr modem_out
        inx
        bne event_created_loop
event_created_done:
    jsr modem_in
    jmp events_menu
go_create_event_again:
    jmp create_event

event_temp_type: .byte 0
max_events_msg:
    .text "\r\nMax 3 events allowed!\r\n[Press any key]\r\n"
event_title_prompt_msg:
    .text "\r\nEvent title (16 chars): "
event_type_prompt_msg:
    .text "\r\nType: 1.Party 2.Game 3.Meeting 4.Contest: "
event_created_msg:
    .text "\r\nEvent created!\r\n[Press any key]\r\n"

cancel_event:
    lda user_events_count
    beq go_no_events_to_cancel
    // Show events and ask which to cancel
    ldx #0
cancel_prompt_loop:
        lda cancel_prompt_msg,X
        beq cancel_prompt_done
        jsr modem_out
        inx
        bne cancel_prompt_loop
cancel_prompt_done:
    jsr modem_in
    cmp #'0'
    beq go_back_to_events
    sec
    sbc #'1'
    cmp user_events_count
    bcs cancel_event
    // Remove event by shifting remaining
    sta cancel_index
    // For simplicity, just decrement count (last event removed)
    dec user_events_count
    ldx #0
event_cancelled_loop:
        lda event_cancelled_msg,X
        beq event_cancelled_done
        jsr modem_out
        inx
        bne event_cancelled_loop
event_cancelled_done:
    jsr modem_in
    jmp events_menu
go_no_events_to_cancel:
    jmp no_events_scheduled
go_back_to_events:
    jmp events_menu

cancel_index: .byte 0
cancel_prompt_msg:
    .text "\r\nCancel which event? (1-3, 0=back): "
event_cancelled_msg:
    .text "\r\nEvent cancelled!\r\n[Press any key]\r\n"

browse_all_events:
    // Show sample events from other rooms
    ldx #0
browse_events_header_loop:
        lda browse_events_header_msg,X
        beq browse_events_header_done
        jsr modem_out
        inx
        bne browse_events_header_loop
browse_events_header_done:
    // Print some sample events
    ldy #0
sample_events_loop:
        cpy #3
        beq sample_events_done
        // Print number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print sample event name
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_sample_event:
            lda sample_event_names,X
            cmp #$20
            beq sample_event_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_sample_event
sample_event_done:
        // Print host
        lda #' '
        jsr modem_out
        lda #'@'
        jsr modem_out
        tya
        asl
        asl
        asl
        asl
        tax
print_event_host:
            lda sample_room_owners,X
            cmp #$20
            beq event_host_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_event_host
event_host_done:
        lda #13
        jsr modem_out
        iny
        jmp sample_events_loop
sample_events_done:
    ldx #0
browse_press_key_loop:
        lda press_key_msg,X
        beq browse_press_key_done
        jsr modem_out
        inx
        bne browse_press_key_loop
browse_press_key_done:
    jsr modem_in
    jmp events_menu

browse_events_header_msg:
    .text "\r\n=== ALL EVENTS ===\r\n"
sample_event_names:
    .text "Grand Ball      "  // 16 chars each
    .text "Trivia Night    "
    .text "Trade Fair      "

// ============================================
// REALM CALENDAR - SEASONAL EVENTS
// ============================================

realm_calendar:
    ldx #0
realm_cal_loop:
        lda realm_calendar_msg,X
        beq realm_cal_done
        jsr modem_out
        inx
        cpx #0
        bne realm_cal_loop
realm_cal_done:
    jsr modem_in
    jmp events_menu

realm_calendar_msg:
    .text "\r\n========================================\r\n"
    .text "     REALM CALENDAR OF EVERLAND\r\n"
    .text "========================================\r\n\r\n"
    .text "JANUARY - New Year's Frost Feast\r\n"
    .text "  The Frost Weavers gather at The Burrows\r\n\r\n"
    .text "FEBRUARY - Lovers' Lantern Walk\r\n"
    .text "  Couples carry lanterns to the Moon Portal\r\n\r\n"
    .text "MARCH - Spring Awakening Festival\r\n"
    .text "  Fairy Gardens bloom with impossible flowers\r\n\r\n"
    .text "APRIL - Fool's Day Mischief\r\n"
    .text "  Bridge the Troll leads pranks across town\r\n\r\n"
    .text "MAY - Order of the Black Rose Memorial\r\n"
    .text "  Honor the fallen at Louden's Rest\r\n\r\n"
    .text "JUNE - Midsummer Dragon Flight\r\n"
    .text "  Dragon trainers race at Dragon Haven\r\n\r\n"
    .text "JULY - Pirate's Plunder Games\r\n"
    .text "  Captain Pit Plum hosts challenges\r\n\r\n"
    .text "AUGUST - Order of the Owls Wisdom Trials\r\n"
    .text "  Test your wit at the Tower\r\n\r\n"
    .text "SEPTEMBER - Harvest Moon Ball\r\n"
    .text "  Pumpkin Fairies host the celebration\r\n\r\n"
    .text "*** OCTOBER - DRAGON LANTERN FESTIVAL ***\r\n"
    .text "  ALL CARRY LANTERNS! (Tradition!)\r\n"
    .text "  Gather at Dragon Haven as the tale of\r\n"
    .text "  the Battle for Everland is told!\r\n"
    .text "  King Lowden's sacrifice remembered.\r\n\r\n"
    .text "NOVEMBER - Pact of Winter's Howl\r\n"
    .text "  Wolves and humans renew their bond\r\n\r\n"
    .text "DECEMBER - Everland Yuletide Feast\r\n"
    .text "  All realms unite at the Dining Hall\r\n\r\n"
    .text "[Press any key]\r\n"
    .byte 0

// ============================================
// TRADE SYSTEM
// ============================================

trade_menu:
    ldx #0
trade_menu_header_loop:
        lda trade_menu_msg,X
        beq trade_menu_header_done
        jsr modem_out
        inx
        bne trade_menu_header_loop
trade_menu_header_done:
    jsr modem_in
    cmp #'1'
    beq go_view_inventory
    cmp #'2'
    beq go_create_trade
    cmp #'3'
    beq go_view_trade_offers
    cmp #'4'
    beq go_browse_trades
    cmp #'0'
    beq go_back_from_trade
    jmp trade_menu
go_view_inventory:
    jmp view_inventory
go_create_trade:
    jmp create_trade_offer
go_view_trade_offers:
    jmp view_my_trade_offers
go_browse_trades:
    jmp browse_trade_board
go_back_from_trade:
    jmp user_room_menu

trade_menu_msg:
    .text "\r\nTRADE:\r\n1. View Inventory\r\n2. Create Trade Offer\r\n3. My Trade Offers\r\n4. Browse Trade Board\r\n0. Back\r\n> "

view_inventory:
    ldx #0
inventory_header_loop:
        lda inventory_header_msg,X
        beq inventory_header_done
        jsr modem_out
        inx
        bne inventory_header_loop
inventory_header_done:
    lda player_inventory_count
    beq go_empty_inventory
    ldy #0
list_inventory_loop:
        cpy player_inventory_count
        beq go_list_inventory_done
        // Print number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Get item ID and print name
        tya
        asl
        asl  // Y * 4
        tax
        lda player_inventory,X
        // Multiply by 8 for item name
        asl
        asl
        asl
        tax
print_item_name:
            lda item_names,X
            cmp #$20
            beq item_name_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_item_name
item_name_done:
        // Print quantity or durability if present
        lda #' '
        jsr modem_out
        ; compute slot base = Y * 4
        tya
        asl
        asl
        tax
        lda player_inventory+2,X  ; durability byte
        beq print_inv_count
        ; print durability as " (d:NN)"
        lda #' '
        jsr modem_out
        lda #'('
        jsr modem_out
        lda #'d'
        jsr modem_out
        lda #':'
        jsr modem_out
        lda player_inventory+2,X
        jsr print_byte_decimal
        lda #')'
        jsr modem_out
        jmp print_inv_done
    print_inv_count:
        lda #'x'
        jsr modem_out
        tya
        asl
        asl
        clc
        adc #1  // Offset to count
        tax
        lda player_inventory,X
        clc
        adc #'0'
        jsr modem_out
    print_inv_done:
        lda #13
        jsr modem_out
        iny
        cpy #8
        bne list_inventory_loop
    jmp list_inventory_done
go_empty_inventory:
    jmp empty_inventory
go_list_inventory_done:
    jmp list_inventory_done
list_inventory_done:
    ldx #0
inv_press_key_loop:
        lda press_key_msg,X
        beq inv_press_key_done
        jsr modem_out
        inx
        bne inv_press_key_loop
inv_press_key_done:
    jsr modem_in
    jmp trade_menu

empty_inventory:
    ldx #0
empty_inv_loop:
        lda empty_inv_msg,X
        beq empty_inv_done
        jsr modem_out
        inx
        bne empty_inv_loop
empty_inv_done:
    jsr modem_in
    jmp trade_menu

inventory_header_msg:
    .text "\r\n=== YOUR INVENTORY ===\r\n"
empty_inv_msg:
    .text "\r\nInventory is empty.\r\n[Press any key]\r\n"

create_trade_offer:
    // Check max offers
    lda trade_offers_count
    cmp #3
    bcc can_create_trade
    ldx #0
max_trades_loop:
        lda max_trades_msg,X
        beq max_trades_done
        jsr modem_out
        inx
        bne max_trades_loop
max_trades_done:
    jsr modem_in
    jmp trade_menu
can_create_trade:
    // Ask what to offer
    ldx #0
offer_what_loop:
        lda offer_what_msg,X
        beq offer_what_done
        jsr modem_out
        inx
        bne offer_what_loop
offer_what_done:
    jsr modem_in
    sec
    sbc #'1'
    cmp player_inventory_count
    bcs go_create_trade_again
    sta trade_offer_item
    ; Disallow offering durable (per-slot) items which carry slot metadata
    lda trade_offer_item
    tay
    tya
    asl
    asl
    tax
    lda player_inventory+2,X
    cmp #0
    beq offer_what_continue
    ; Durable item selected - show message and abort
    ldx #0
durable_offer_msg_loop:
        lda durable_offer_msg,X
        beq durable_offer_done
        jsr modem_out
        inx
        bne durable_offer_msg_loop
durable_offer_done:
    jsr modem_in
    jmp trade_menu
offer_what_continue:
    // Ask what you want
    ldx #0
want_what_loop:
        lda want_what_msg,X
        beq want_what_done
        jsr modem_out
        inx
        bne want_what_loop
want_what_done:
    jsr modem_in
    sec
    sbc #'1'
    cmp #8
    bcs go_create_trade_again
    sta trade_want_item
    // Create the offer
    lda trade_offers_count
    asl
    asl
    asl
    asl  // count * 16
    tax
    lda trade_offer_item
    sta trade_offers,X
    inx
    lda trade_want_item
    sta trade_offers,X
    inc trade_offers_count
    // Confirm
    ldx #0
trade_created_loop:
        lda trade_created_msg,X
        beq trade_created_done
        jsr modem_out
        inx
        bne trade_created_loop
trade_created_done:
    jsr modem_in
    jmp trade_menu
go_create_trade_again:
    jmp create_trade_offer

// trade_offer_item defined in variables section
trade_want_item: .byte 0
max_trades_msg:
    .text "\r\nMax 3 trade offers!\r\n[Press any key]\r\n"
offer_what_msg:
    .text "\r\nOffer which item? (1-8): "
want_what_msg:
    .text "\r\nWant which item? (1-8): "
trade_created_msg:
    .text "\r\nTrade offer posted!\r\n[Press any key]\r\n"
    .byte 0

durable_offer_msg:
    .text "\r\nDurable/tools cannot be offered on the trade board.\r\n[Press any key]\r\n"
    .byte 0

view_my_trade_offers:
    lda trade_offers_count
    beq go_no_trade_offers
    ldx #0
my_trades_header_loop:
        lda my_trades_header_msg,X
        beq my_trades_header_done
        jsr modem_out
        inx
        bne my_trades_header_loop
my_trades_header_done:
    ldy #0
list_trades_loop:
        cpy trade_offers_count
        beq go_list_trades_done
        // Print number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print offering item
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
        lda trade_offers,X
        asl
        asl
        asl
        tax
print_trade_offer_item:
            lda item_names,X
            cmp #$20
            beq trade_offer_item_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_trade_offer_item
trade_offer_item_done:
        // Print arrow
        ldx #0
arrow_loop:
            lda arrow_msg,X
            beq arrow_done
            jsr modem_out
            inx
            bne arrow_loop
arrow_done:
        // Print wanted item
        tya
        asl
        asl
        asl
        asl
        clc
        adc #1  // Offset to want byte
        tax
        lda trade_offers,X
        asl
        asl
        asl
        tax
print_trade_want_item:
            lda item_names,X
            cmp #$20
            beq trade_want_item_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_trade_want_item
trade_want_item_done:
        lda #13
        jsr modem_out
        iny
        cpy #3
        bne list_trades_loop
    jmp list_trades_done
go_no_trade_offers:
    jmp no_trade_offers
go_list_trades_done:
    jmp list_trades_done
list_trades_done:
    ldx #0
trades_press_key_loop:
        lda press_key_msg,X
        beq trades_press_key_done
        jsr modem_out
        inx
        bne trades_press_key_loop
trades_press_key_done:
    jsr modem_in
    jmp trade_menu

no_trade_offers:
    ldx #0
no_trades_loop:
        lda no_trades_msg,X
        beq no_trades_done
        jsr modem_out
        inx
        bne no_trades_loop
no_trades_done:
    jsr modem_in
    jmp trade_menu

my_trades_header_msg:
    .text "\r\nYOUR TRADE OFFERS:\r\n"
arrow_msg:
    .text " -> "
no_trades_msg:
    .text "\r\nNo active trade offers.\r\n[Press any key]\r\n"

browse_trade_board:
    ldx #0
board_header_loop:
        lda board_header_msg,X
        beq board_header_done
        jsr modem_out
        inx
        bne board_header_loop
board_header_done:
    // Show sample trades from others
    ldy #0
sample_trades_loop:
        cpy #3
        beq sample_trades_done
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print sample trade
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_sample_trade:
            lda sample_trades,X
            beq sample_trade_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_sample_trade
sample_trade_done:
        lda #13
        jsr modem_out
        iny
        jmp sample_trades_loop
sample_trades_done:
    ldx #0
board_press_key_loop:
        lda press_key_msg,X
        beq board_press_key_done
        jsr modem_out
        inx
        bne board_press_key_loop
board_press_key_done:
    jsr modem_in
    jmp trade_menu

board_header_msg:
    .text "\r\n=== TRADE BOARD ===\r\n"
sample_trades:
    .text "Sword -> Potion "  // 16 chars each
    .text "Ring -> Gem     "
    .text "Shield -> Scroll"

// ============================================
// MINI-GAMES SYSTEM
// ============================================

minigames_menu:
    ldx #0
minigames_header_loop:
        lda minigames_menu_msg,X
        beq minigames_header_done
        jsr modem_out
        inx
        bne minigames_header_loop
minigames_header_done:
    jsr modem_in
    cmp #'1'
    beq go_guess_number
    cmp #'2'
    beq go_dice_game
    cmp #'3'
    beq go_slots_game
    cmp #'4'
    beq go_game_stats
    cmp #'0'
    beq go_back_from_games
    jmp minigames_menu
go_guess_number:
    jmp guess_number_game
go_dice_game:
    jmp dice_roll_game
go_slots_game:
    jmp slots_game
go_game_stats:
    jmp view_game_stats
go_back_from_games:
    jmp user_room_menu

minigames_menu_msg:
    .text "\r\nMINI-GAMES:\r\n1. Guess the Number\r\n2. Dice Roll\r\n3. Slots\r\n4. My Stats\r\n0. Back\r\n> "

// Simple RNG: XOR shift
get_random:
    lda game_rng_seed
    asl
    bcc rng_no_eor
    eor #$1D
rng_no_eor:
    sta game_rng_seed
    rts

guess_number_game:
    ldx #0
guess_header_loop:
        lda guess_header_msg,X
        beq guess_header_done
        jsr modem_out
        inx
        bne guess_header_loop
guess_header_done:
    // Generate target 1-9
    jsr get_random
    and #$07
    clc
    adc #1
    sta guess_target
    lda #3
    sta guess_tries
guess_loop:
    // Show tries left
    ldx #0
tries_left_loop:
        lda tries_left_msg,X
        beq tries_left_done
        jsr modem_out
        inx
        bne tries_left_loop
tries_left_done:
    lda guess_tries
    clc
    adc #'0'
    jsr modem_out
    ldx #0
guess_prompt_loop:
        lda guess_prompt_msg,X
        beq guess_prompt_done
        jsr modem_out
        inx
        bne guess_prompt_loop
guess_prompt_done:
    jsr modem_in
    sec
    sbc #'0'
    cmp guess_target
    beq guess_correct
    bcc guess_too_low
    // Too high
    ldx #0
too_high_loop:
        lda too_high_msg,X
        beq too_high_done
        jsr modem_out
        inx
        bne too_high_loop
too_high_done:
    jmp guess_check_tries
guess_too_low:
    ldx #0
too_low_loop:
        lda too_low_msg,X
        beq too_low_done
        jsr modem_out
        inx
        bne too_low_loop
too_low_done:
guess_check_tries:
    dec guess_tries
    lda guess_tries
    bne guess_loop
    // Out of tries
    ldx #0
guess_lose_loop:
        lda guess_lose_msg,X
        beq guess_lose_done
        jsr modem_out
        inx
        bne guess_lose_loop
guess_lose_done:
    lda guess_target
    clc
    adc #'0'
    jsr modem_out
    lda #13
    jsr modem_out
    inc player_games_total
    jsr modem_in
    jmp minigames_menu
guess_correct:
    ldx #0
guess_win_loop:
        lda guess_win_msg,X
        beq guess_win_done
        jsr modem_out
        inx
        bne guess_win_loop
guess_win_done:
    // Award gold
    lda player_gold
    clc
    adc #5
    sta player_gold
    inc player_games_total
    jsr modem_in
    jmp minigames_menu

guess_target: .byte 0
guess_tries: .byte 0
guess_header_msg:
    .text "\r\n=== GUESS THE NUMBER ===\r\nI'm thinking of a number 1-9\r\n"
tries_left_msg:
    .text "\r\nTries left: "
guess_prompt_msg:
    .text "\r\nYour guess: "
too_high_msg:
    .text "Too high!\r\n"
too_low_msg:
    .text "Too low!\r\n"
guess_lose_msg:
    .text "\r\nOut of tries! It was: "
guess_win_msg:
    .text "\r\nCorrect! You win 5 gold!\r\n[Press any key]\r\n"

dice_roll_game:
    ldx #0
dice_header_loop:
        lda dice_header_msg,X
        beq dice_header_done
        jsr modem_out
        inx
        bne dice_header_loop
dice_header_done:
    // Roll player dice
    jsr get_random
    and #$05
    clc
    adc #1
    sta player_dice
    // Roll opponent dice
    jsr get_random
    and #$05
    clc
    adc #1
    sta opponent_dice
    // Show rolls
    ldx #0
you_rolled_loop:
        lda you_rolled_msg,X
        beq you_rolled_done
        jsr modem_out
        inx
        bne you_rolled_loop
you_rolled_done:
    lda player_dice
    clc
    adc #'0'
    jsr modem_out
    ldx #0
opp_rolled_loop:
        lda opp_rolled_msg,X
        beq opp_rolled_done
        jsr modem_out
        inx
        bne opp_rolled_loop
opp_rolled_done:
    lda opponent_dice
    clc
    adc #'0'
    jsr modem_out
    lda #13
    jsr modem_out
    // Compare
    lda player_dice
    cmp opponent_dice
    beq dice_tie
    bcc dice_lose
    // Win
    ldx #0
dice_win_loop:
        lda dice_win_msg,X
        beq dice_win_done
        jsr modem_out
        inx
        bne dice_win_loop
dice_win_done:
    lda player_gold
    clc
    adc #3
    sta player_gold
    jmp dice_finish
dice_lose:
    ldx #0
dice_lose_loop:
        lda dice_lose_msg,X
        beq dice_lose_done
        jsr modem_out
        inx
        bne dice_lose_loop
dice_lose_done:
    jmp dice_finish
dice_tie:
    ldx #0
dice_tie_loop:
        lda dice_tie_msg,X
        beq dice_tie_done
        jsr modem_out
        inx
        bne dice_tie_loop
dice_tie_done:
dice_finish:
    inc player_games_total
    jsr modem_in
    jmp minigames_menu

player_dice: .byte 0
opponent_dice: .byte 0
dice_header_msg:
    .text "\r\n=== DICE ROLL ===\r\nRolling dice...\r\n"
you_rolled_msg:
    .text "\r\nYou rolled: "
opp_rolled_msg:
    .text "\r\nOpponent rolled: "
dice_win_msg:
    .text "\r\nYou win! +3 gold\r\n[Press any key]\r\n"
dice_lose_msg:
    .text "\r\nYou lose!\r\n[Press any key]\r\n"
dice_tie_msg:
    .text "\r\nIt's a tie!\r\n[Press any key]\r\n"

slots_game:
    ldx #0
slots_header_loop:
        lda slots_header_msg,X
        beq slots_header_done
        jsr modem_out
        inx
        bne slots_header_loop
slots_header_done:
    // Spin 3 slots
    jsr get_random
    and #$03
    sta slot1
    jsr get_random
    and #$03
    sta slot2
    jsr get_random
    and #$03
    sta slot3
    // Display slots
    lda #'['
    jsr modem_out
    ldx slot1
    lda slot_symbols,X
    jsr modem_out
    lda #']'
    jsr modem_out
    lda #'['
    jsr modem_out
    ldx slot2
    lda slot_symbols,X
    jsr modem_out
    lda #']'
    jsr modem_out
    lda #'['
    jsr modem_out
    ldx slot3
    lda slot_symbols,X
    jsr modem_out
    lda #']'
    jsr modem_out
    lda #13
    jsr modem_out
    // Check for match
    lda slot1
    cmp slot2
    bne slots_no_win
    cmp slot3
    bne slots_no_win
    // Jackpot!
    ldx #0
slots_jackpot_loop:
        lda slots_jackpot_msg,X
        beq slots_jackpot_done
        jsr modem_out
        inx
        bne slots_jackpot_loop
slots_jackpot_done:
    lda player_gold
    clc
    adc #20
    sta player_gold
    jmp slots_finish
slots_no_win:
    // Check two match
    lda slot1
    cmp slot2
    beq slots_partial
    lda slot2
    cmp slot3
    beq slots_partial
    lda slot1
    cmp slot3
    beq slots_partial
    // No match
    ldx #0
slots_lose_loop:
        lda slots_lose_msg,X
        beq slots_lose_done
        jsr modem_out
        inx
        bne slots_lose_loop
slots_lose_done:
    jmp slots_finish
slots_partial:
    ldx #0
slots_partial_loop:
        lda slots_partial_msg,X
        beq slots_partial_done
        jsr modem_out
        inx
        bne slots_partial_loop
slots_partial_done:
    lda player_gold
    clc
    adc #2
    sta player_gold
slots_finish:
    inc player_games_total
    jsr modem_in
    jmp minigames_menu

slot1: .byte 0
slot2: .byte 0
slot3: .byte 0
slot_symbols: .byte '*', '#', '@', '$'
slots_header_msg:
    .text "\r\n=== SLOTS ===\r\nSpinning...\r\n\r\n"
slots_jackpot_msg:
    .text "\r\nJACKPOT! +20 gold!\r\n[Press any key]\r\n"
slots_partial_msg:
    .text "\r\nTwo match! +2 gold\r\n[Press any key]\r\n"
slots_lose_msg:
    .text "\r\nNo match. Try again!\r\n[Press any key]\r\n"

view_game_stats:
    ldx #0
game_stats_header_loop:
        lda game_stats_header_msg,X
        beq game_stats_header_done
        jsr modem_out
        inx
        bne game_stats_header_loop
game_stats_header_done:
    // Games played
    ldx #0
games_total_label_loop:
        lda games_total_label_msg,X
        beq games_total_label_done
        jsr modem_out
        inx
        bne games_total_label_loop
games_total_label_done:
    lda player_games_total
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Current gold
    ldx #0
current_gold_label_loop:
        lda current_gold_label_msg,X
        beq current_gold_label_done
        jsr modem_out
        inx
        bne current_gold_label_loop
current_gold_label_done:
    lda player_gold
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    ldx #0
stats_press_key2_loop:
        lda press_key_msg,X
        beq stats_press_key2_done
        jsr modem_out
        inx
        bne stats_press_key2_loop
stats_press_key2_done:
    jsr modem_in
    jmp minigames_menu

game_stats_header_msg:
    .text "\r\n=== GAME STATS ===\r\n"
games_total_label_msg:
    .text "Games Played: "
current_gold_label_msg:
    .text "Current Gold: "

// ============================================
// DAILY REWARDS SYSTEM
// ============================================

daily_reward_menu:
    ldx #0
daily_header_loop:
        lda daily_header_msg,X
        beq daily_header_done
        jsr modem_out
        inx
        bne daily_header_loop
daily_header_done:
    // Show current streak
    ldx #0
streak_label_loop:
        lda streak_label_msg,X
        beq streak_label_done
        jsr modem_out
        inx
        bne streak_label_loop
streak_label_done:
    lda login_streak
    jsr print_byte_decimal
    ldx #0
days_suffix_loop:
        lda days_suffix_msg,X
        beq days_suffix_done
        jsr modem_out
        inx
        bne days_suffix_loop
days_suffix_done:
    // Show streak calendar
    ldx #0
calendar_loop:
        lda calendar_header_msg,X
        beq calendar_done
        jsr modem_out
        inx
        bne calendar_loop
calendar_done:
    ldy #0
print_streak_days:
        cpy #7
        beq streak_days_done
        lda #'['
        jsr modem_out
        tya
        clc
        adc #1
        cmp login_streak
        bcc day_complete
        beq day_current
        // Future day
        lda #' '
        jsr modem_out
        jmp day_printed
day_complete:
        lda #'*'
        jsr modem_out
        jmp day_printed
day_current:
        lda daily_claimed
        bne day_complete
        lda #'?'
        jsr modem_out
day_printed:
        lda #']'
        jsr modem_out
        iny
        jmp print_streak_days
streak_days_done:
    lda #13
    jsr modem_out
    // Show reward amounts
    ldx #0
reward_amounts_loop:
        lda reward_amounts_msg,X
        beq reward_amounts_done
        jsr modem_out
        inx
        bne reward_amounts_loop
reward_amounts_done:
    // Check if already claimed
    lda daily_claimed
    bne already_claimed
    // Show claim option
    ldx #0
claim_prompt_loop:
        lda claim_prompt_msg,X
        beq claim_prompt_done
        jsr modem_out
        inx
        bne claim_prompt_loop
claim_prompt_done:
    jsr modem_in
    cmp #'C'
    beq claim_reward
    cmp #'0'
    beq go_back_daily
    jmp daily_reward_menu
go_back_daily:
    jmp user_room_menu

claim_reward:
    // Get reward based on streak
    ldx login_streak
    dex  // 0-indexed
    cpx #7
    bcc valid_streak
    ldx #6  // Max day 7
valid_streak:
    lda streak_rewards,X
    clc
    adc player_gold
    sta player_gold
    // Mark as claimed
    lda #1
    sta daily_claimed
    // Show claimed message
    ldx #0
claimed_msg_loop:
        lda claimed_msg,X
        beq claimed_msg_done
        jsr modem_out
        inx
        bne claimed_msg_loop
claimed_msg_done:
    // Show amount
    ldx login_streak
    dex
    cpx #7
    bcc valid_streak2
    ldx #6
valid_streak2:
    lda streak_rewards,X
    jsr print_byte_decimal
    ldx #0
gold_claimed_suffix_loop:
        lda gold_claimed_suffix_msg,X
        beq gold_claimed_suffix_done
        jsr modem_out
        inx
        bne gold_claimed_suffix_loop
gold_claimed_suffix_done:
    // Increase streak for tomorrow
    lda login_streak
    cmp #7
    bcs max_streak
    inc login_streak
max_streak:
    jsr modem_in
    jmp user_room_menu

already_claimed:
    ldx #0
already_claimed_loop:
        lda already_claimed_msg,X
        beq already_claimed_done
        jsr modem_out
        inx
        bne already_claimed_loop
already_claimed_done:
    jsr modem_in
    jmp user_room_menu

daily_header_msg:
    .text "\r\n=== DAILY REWARDS ===\r\n"
streak_label_msg:
    .text "Current Streak: "
days_suffix_msg:
    .text " day(s)\r\n"
calendar_header_msg:
    .text "\r\nWeek Progress:\r\n"
reward_amounts_msg:
    .text "\r\nRewards: Day1=5g Day2=10g Day3=15g\r\nDay4=20g Day5=30g Day6=40g Day7=50g\r\n"
claim_prompt_msg:
    .text "\r\nC. Claim Today's Reward\r\n0. Back\r\n> "
claimed_msg:
    .text "\r\nReward claimed: +"
gold_claimed_suffix_msg:
    .text " gold!\r\n[Press any key]\r\n"
already_claimed_msg:
    .text "\r\nAlready claimed today!\r\nCome back tomorrow.\r\n[Press any key]\r\n"

// ============================================
// ROOM SHOP
// ============================================

room_shop_menu:
    ldx #0
shop_header_loop:
        lda shop_header_msg,X
        beq shop_header_done
        jsr modem_out
        inx
        bne shop_header_loop
shop_header_done:
    // Show gold balance
    ldx #0
shop_gold_loop:
        lda shop_gold_msg,X
        beq shop_gold_done
        jsr modem_out
        inx
        bne shop_gold_loop
shop_gold_done:
    lda player_gold
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    lda #13
    jsr modem_out
    // List items
    ldy #0
list_shop_items_loop:
        cpy shop_items_count
        beq go_list_shop_done
        // Print number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Check if owned
        lda shop_item_owned,Y
        beq not_owned_yet
        // Owned - show checkmark
        lda #'['
        jsr modem_out
        lda #'*'
        jsr modem_out
        lda #']'
        jsr modem_out
        jmp print_shop_item_name
not_owned_yet:
        // Not owned - show price
        lda #'('
        jsr modem_out
        lda shop_item_prices,Y
        jsr print_byte_decimal
        lda #'g'
        jsr modem_out
        lda #')'
        jsr modem_out
print_shop_item_name:
        lda #' '
        jsr modem_out
        // Print item name
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_shop_name_char:
            lda shop_item_names,X
            cmp #$20
            beq shop_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_shop_name_char
shop_name_done:
        lda #13
        jsr modem_out
        iny
        cpy #6
        bne list_shop_items_loop
    jmp list_shop_done
go_list_shop_done:
    jmp list_shop_done
list_shop_done:
    // Show prompt
    ldx #0
shop_prompt_loop:
        lda shop_prompt_msg,X
        beq shop_prompt_done
        jsr modem_out
        inx
        bne shop_prompt_loop
shop_prompt_done:
    jsr modem_in
    cmp #'0'
    beq go_back_from_shop
    sec
    sbc #'1'
    cmp shop_items_count
    bcs go_room_shop_again
    sta shop_selection
    // Check if already owned
    tax
    lda shop_item_owned,X
    bne already_own_item
    // Check if can afford
    ldx shop_selection
    lda shop_item_prices,X
    cmp player_gold
    beq can_afford_item
    bcc can_afford_item
    // Can't afford
    ldx #0
cant_afford_shop_loop:
        lda cant_afford_shop_msg,X
        beq cant_afford_shop_done
        jsr modem_out
        inx
        bne cant_afford_shop_loop
cant_afford_shop_done:
    jsr modem_in
    jmp room_shop_menu
go_back_from_shop:
    jmp user_room_menu
go_room_shop_again:
    jmp room_shop_menu

can_afford_item:
    // Deduct gold
    ldx shop_selection
    lda player_gold
    sec
    sbc shop_item_prices,X
    sta player_gold
    // Mark as owned
    ldx shop_selection
    lda #1
    sta shop_item_owned,X
    // Show purchase message
    ldx #0
purchased_loop:
        lda purchased_msg,X
        beq purchased_done
        jsr modem_out
        inx
        bne purchased_loop
purchased_done:
    jsr modem_in
    jmp room_shop_menu

already_own_item:
    ldx #0
already_own_loop:
        lda already_own_msg,X
        beq already_own_done
        jsr modem_out
        inx
        bne already_own_loop
already_own_done:
    jsr modem_in
    jmp room_shop_menu

shop_selection: .byte 0
shop_header_msg:
    .text "\r\n=== ROOM SHOP ===\r\n"
shop_gold_msg:
    .text "Your gold: "
shop_prompt_msg:
    .text "\r\nBuy item (1-6, 0=back): "
cant_afford_shop_msg:
    .text "\r\nNot enough gold!\r\n[Press any key]\r\n"
purchased_msg:
    .text "\r\nItem purchased!\r\nIt's now in your room.\r\n[Press any key]\r\n"
already_own_msg:
    .text "\r\nYou already own this!\r\n[Press any key]\r\n"

// ============================================
// QUESTS SYSTEM
// ============================================

quests_menu:
    ldx #0
quests_header_loop:
        lda quests_header_msg,X
        beq quests_header_done
        jsr modem_out
        inx
        bne quests_header_loop
quests_header_done:
    // List all quests
    ldy #0
    jmp list_quests_loop
go_list_quests_done_early:
    jmp list_quests_done
list_quests_loop:
        cpy quest_count
        beq go_list_quests_done_early
        // Print number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Check if complete
        lda quest_complete,Y
        beq quest_not_done
        // Complete - show checkmark
        lda #'['
        jsr modem_out
        lda #'*'
        jsr modem_out
        lda #']'
        jsr modem_out
        lda #' '
        jsr modem_out
        jmp print_quest_name
quest_not_done:
        // Show progress
        lda #'['
        jsr modem_out
        lda quest_progress,Y
        clc
        adc #'0'
        jsr modem_out
        lda #'/'
        jsr modem_out
        lda quest_targets,Y
        clc
        adc #'0'
        jsr modem_out
        lda #']'
        jsr modem_out
print_quest_name:
        lda #' '
        jsr modem_out
        // Print quest name
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
print_quest_char:
            lda quest_names,X
            cmp #$20
            beq quest_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_quest_char
quest_name_done:
        // Show reward
        lda #' '
        jsr modem_out
        lda #'('
        jsr modem_out
        lda quest_rewards,Y
        jsr print_byte_decimal
        lda #'g'
        jsr modem_out
        lda #')'
        jsr modem_out
        lda #13
        jsr modem_out
        iny
        cpy #4
        bne go_list_quests_continue
    jmp list_quests_done
go_list_quests_continue:
    jmp list_quests_loop
go_list_quests_done:
    jmp list_quests_done
list_quests_done:
    // Show claim prompt
    ldx #0
quest_prompt_loop:
        lda quest_prompt_msg,X
        beq quest_prompt_done
        jsr modem_out
        inx
        bne quest_prompt_loop
quest_prompt_done:
    jsr modem_in
    cmp #'0'
    beq go_back_from_quests
    sec
    sbc #'1'
    cmp quest_count
    bcs go_quests_menu_again
    sta quest_selection
    // Check if claimable
    tax
    lda quest_complete,X
    bne already_claimed_quest
    // Check if progress meets target
    lda quest_progress,X
    cmp quest_targets,X
    bcc quest_not_ready
    // Claim reward!
    ldx quest_selection
    lda quest_rewards,X
    clc
    adc player_gold
    sta player_gold
    // Mark complete
    ldx quest_selection
    lda #1
    sta quest_complete,X
    // Show claimed
    ldx #0
quest_claimed_loop:
        lda quest_claimed_msg,X
        beq quest_claimed_done
        jsr modem_out
        inx
        bne quest_claimed_loop
quest_claimed_done:
    ldx quest_selection
    lda quest_rewards,X
    jsr print_byte_decimal
    ldx #0
quest_gold_suffix_loop:
        lda quest_gold_suffix_msg,X
        beq quest_gold_suffix_done
        jsr modem_out
        inx
        bne quest_gold_suffix_loop
quest_gold_suffix_done:
    jsr modem_in
    jmp quests_menu
go_back_from_quests:
    jmp user_room_menu
go_quests_menu_again:
    jmp quests_menu

quest_not_ready:
    ldx #0
not_ready_loop:
        lda not_ready_msg,X
        beq not_ready_done
        jsr modem_out
        inx
        bne not_ready_loop
not_ready_done:
    jsr modem_in
    jmp quests_menu

already_claimed_quest:
    ldx #0
already_claimed_quest_loop:
        lda already_claimed_quest_msg,X
        beq already_claimed_quest_done
        jsr modem_out
        inx
        bne already_claimed_quest_loop
already_claimed_quest_done:
    jsr modem_in
    jmp quests_menu

quest_selection: .byte 0
quests_header_msg:
    .text "\r\n=== DAILY QUESTS ===\r\n"
quest_prompt_msg:
    .text "\r\nClaim reward (1-4, 0=back): "
quest_claimed_msg:
    .text "\r\nQuest complete! +"
quest_gold_suffix_msg:
    .text " gold!\r\n[Press any key]\r\n"
not_ready_msg:
    .text "\r\nQuest not complete yet!\r\n[Press any key]\r\n"
already_claimed_quest_msg:
    .text "\r\nAlready claimed!\r\n[Press any key]\r\n"

// ============================================
// HALL OF FAME
// ============================================

hall_of_fame_menu:
    ldx #0
hof_header_loop:
        lda hof_header_msg,X
        beq hof_header_done
        jsr modem_out
        inx
        bne hof_header_loop
hof_header_done:
    jsr modem_in
    cmp #'1'
    beq go_hof_gold
    cmp #'2'
    beq go_hof_achieve
    cmp #'3'
    beq go_hof_games
    cmp #'0'
    beq go_back_from_hof
    jmp hall_of_fame_menu
go_hof_gold:
    jmp show_hof_gold
go_hof_achieve:
    jmp show_hof_achievements
go_hof_games:
    jmp show_hof_games
go_back_from_hof:
    jmp user_room_menu

hof_header_msg:
    .text "\r\n=== HALL OF FAME ===\r\n1. Richest Players\r\n2. Most Achievements\r\n3. Most Games Played\r\n0. Back\r\n> "

show_hof_gold:
    ldx #0
hof_gold_header_loop:
        lda hof_gold_header_msg,X
        beq hof_gold_header_done
        jsr modem_out
        inx
        bne hof_gold_header_loop
hof_gold_header_done:
    ldy #0
hof_gold_loop:
        cpy #3
        beq hof_gold_done
        // Print rank
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print name
        tya
        asl
        asl
        asl
        asl  // Y * 16
        tax
hof_gold_name_loop:
            lda hof_gold_names,X
            cmp #$20
            beq hof_gold_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne hof_gold_name_loop
hof_gold_name_done:
        // Print score
        lda #' '
        jsr modem_out
        lda #'-'
        jsr modem_out
        lda #' '
        jsr modem_out
        lda hof_gold_scores,Y
        jsr print_byte_decimal
        lda #'g'
        jsr modem_out
        lda #13
        jsr modem_out
        iny
        jmp hof_gold_loop
hof_gold_done:
    ldx #0
hof_press_key_loop:
        lda press_key_msg,X
        beq hof_press_key_done
        jsr modem_out
        inx
        bne hof_press_key_loop
hof_press_key_done:
    jsr modem_in
    jmp hall_of_fame_menu

hof_gold_header_msg:
    .text "\r\n-- RICHEST PLAYERS --\r\n"

show_hof_achievements:
    ldx #0
hof_ach_header_loop:
        lda hof_ach_header_msg,X
        beq hof_ach_header_done
        jsr modem_out
        inx
        bne hof_ach_header_loop
hof_ach_header_done:
    ldy #0
hof_ach_loop:
        cpy #3
        beq hof_ach_done
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        tya
        asl
        asl
        asl
        asl
        tax
hof_ach_name_loop:
            lda hof_achieve_names,X
            cmp #$20
            beq hof_ach_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne hof_ach_name_loop
hof_ach_name_done:
        lda #' '
        jsr modem_out
        lda #'-'
        jsr modem_out
        lda #' '
        jsr modem_out
        lda hof_achieve_scores,Y
        jsr print_byte_decimal
        ldx #0
achieve_suffix_loop:
            lda achieve_suffix_msg,X
            beq achieve_suffix_done
            jsr modem_out
            inx
            bne achieve_suffix_loop
achieve_suffix_done:
        lda #13
        jsr modem_out
        iny
        jmp hof_ach_loop
hof_ach_done:
    ldx #0
hof_ach_press_key_loop:
        lda press_key_msg,X
        beq hof_ach_press_key_done
        jsr modem_out
        inx
        bne hof_ach_press_key_loop
hof_ach_press_key_done:
    jsr modem_in
    jmp hall_of_fame_menu

hof_ach_header_msg:
    .text "\r\n-- MOST ACHIEVEMENTS --\r\n"
achieve_suffix_msg:
    .text "/8"

show_hof_games:
    ldx #0
hof_games_header_loop:
        lda hof_games_header_msg,X
        beq hof_games_header_done
        jsr modem_out
        inx
        bne hof_games_header_loop
hof_games_header_done:
    ldy #0
hof_games_loop:
        cpy #3
        beq hof_games_done
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        tya
        asl
        asl
        asl
        asl
        tax
hof_games_name_loop:
            lda hof_games_names,X
            cmp #$20
            beq hof_games_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne hof_games_name_loop
hof_games_name_done:
        lda #' '
        jsr modem_out
        lda #'-'
        jsr modem_out
        lda #' '
        jsr modem_out
        lda hof_games_scores,Y
        jsr print_byte_decimal
        ldx #0
games_suffix_loop:
            lda games_suffix_msg,X
            beq games_suffix_done
            jsr modem_out
            inx
            bne games_suffix_loop
games_suffix_done:
        lda #13
        jsr modem_out
        iny
        jmp hof_games_loop
hof_games_done:
    ldx #0
hof_games_press_key_loop:
        lda press_key_msg,X
        beq hof_games_press_key_done
        jsr modem_out
        inx
        bne hof_games_press_key_loop
hof_games_press_key_done:
    jsr modem_in
    jmp hall_of_fame_menu

hof_games_header_msg:
    .text "\r\n-- MOST GAMES PLAYED --\r\n"
games_suffix_msg:
    .text " games"

// ============================================
// PETS SYSTEM
// ============================================

pets_menu:
    lda pet_owned
    beq go_no_pet_yet
    jmp has_pet_menu
go_no_pet_yet:
    jmp adopt_pet_menu

has_pet_menu:
    // Show pet status
    ldx #0
pet_status_header_loop:
        lda pet_status_header_msg,X
        beq pet_status_header_done
        jsr modem_out
        inx
        bne pet_status_header_loop
pet_status_header_done:
    // Print pet name
    ldx #0
print_pet_name:
        lda pet_name,X
        beq pet_name_printed
        jsr modem_out
        inx
        cpx #12
        bne print_pet_name
pet_name_printed:
    // Print pet type
    lda #' '
    jsr modem_out
    lda #'('
    jsr modem_out
    lda pet_owned
    sec
    sbc #1
    asl
    asl
    asl
    tax
print_pet_type_name:
        lda pet_type_names,X
        cmp #$20
        beq pet_type_printed
        jsr modem_out
        inx
        txa
        and #$07
        bne print_pet_type_name
pet_type_printed:
    lda #')'
    jsr modem_out
    lda #13
    jsr modem_out
    // Show stats
    ldx #0
hunger_label_loop:
        lda hunger_label_msg,X
        beq hunger_label_done
        jsr modem_out
        inx
        bne hunger_label_loop
hunger_label_done:
    lda pet_hunger
    jsr print_byte_decimal
    ldx #0
of_ten_loop:
        lda of_ten_msg,X
        beq of_ten_done
        jsr modem_out
        inx
        bne of_ten_loop
of_ten_done:
    // Happiness
    ldx #0
happy_label_loop:
        lda happy_label_msg,X
        beq happy_label_done
        jsr modem_out
        inx
        bne happy_label_loop
happy_label_done:
    lda pet_happiness
    jsr print_byte_decimal
    ldx #0
of_ten_loop2:
        lda of_ten_msg,X
        beq of_ten_done2
        jsr modem_out
        inx
        bne of_ten_loop2
of_ten_done2:
    // Level
    ldx #0
level_label_loop:
        lda pet_level_label_msg,X
        beq level_label_done
        jsr modem_out
        inx
        bne level_label_loop
level_label_done:
    lda pet_level
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Show actions
    ldx #0
pet_actions_loop:
        lda pet_actions_msg,X
        beq pet_actions_done
        jsr modem_out
        inx
        bne pet_actions_loop
pet_actions_done:
    jsr modem_in
    cmp #'1'
    beq go_feed_pet
    cmp #'2'
    beq go_play_pet
    cmp #'3'
    beq go_rename_pet
    cmp #'0'
    beq go_back_pets
    jmp pets_menu
go_feed_pet:
    jmp feed_pet
go_play_pet:
    jmp play_with_pet
go_rename_pet:
    jmp rename_pet
go_back_pets:
    jmp user_room_menu

pet_status_header_msg:
    .text "\r\n=== YOUR PET ===\r\nName: "
hunger_label_msg:
    .text "Hunger: "
of_ten_msg:
    .text "/10\r\n"
happy_label_msg:
    .text "Happiness: "
pet_level_label_msg:
    .text "Level: "
pet_actions_msg:
    .text "\r\n1. Feed (5g)\r\n2. Play\r\n3. Rename\r\n0. Back\r\n> "

feed_pet:
    // Check gold
    lda player_gold
    cmp #5
    bcs can_feed
    ldx #0
no_gold_feed_loop:
        lda no_gold_msg,X
        beq no_gold_feed_done
        jsr modem_out
        inx
        bne no_gold_feed_loop
no_gold_feed_done:
    jsr modem_in
    jmp pets_menu
can_feed:
    lda player_gold
    sec
    sbc #5
    sta player_gold
    // Increase hunger
    lda pet_hunger
    clc
    adc #3
    cmp #10
    bcc hunger_ok
    lda #10
hunger_ok:
    sta pet_hunger
    ldx #0
fed_msg_loop:
        lda fed_msg,X
        beq fed_msg_done
        jsr modem_out
        inx
        bne fed_msg_loop
fed_msg_done:
    jsr modem_in
    jmp pets_menu

no_gold_msg:
    .text "\r\nNot enough gold!\r\n[Press any key]\r\n"
fed_msg:
    .text "\r\nYour pet is fed! +3 hunger\r\n[Press any key]\r\n"

play_with_pet:
    // Increase happiness, maybe level up
    lda pet_happiness
    clc
    adc #2
    cmp #10
    bcc happy_ok
    lda #10
happy_ok:
    sta pet_happiness
    // Check for level up (if both stats high)
    lda pet_hunger
    cmp #8
    bcc no_level_up
    lda pet_happiness
    cmp #8
    bcc no_level_up
    lda pet_level
    cmp #10
    bcs no_level_up
    inc pet_level
    ldx #0
level_up_loop:
        lda level_up_msg,X
        beq level_up_done
        jsr modem_out
        inx
        bne level_up_loop
level_up_done:
    jsr modem_in
    jmp pets_menu
no_level_up:
    ldx #0
played_msg_loop:
        lda played_msg,X
        beq played_msg_done
        jsr modem_out
        inx
        bne played_msg_loop
played_msg_done:
    jsr modem_in
    jmp pets_menu

level_up_msg:
    .text "\r\nYour pet leveled up!\r\n[Press any key]\r\n"
played_msg:
    .text "\r\nYou played with your pet! +2 happy\r\n[Press any key]\r\n"

rename_pet:
    ldx #0
rename_prompt_loop:
        lda rename_prompt_msg,X
        beq rename_prompt_done
        jsr modem_out
        inx
        bne rename_prompt_loop
rename_prompt_done:
    ldx #0
rename_input_loop:
        jsr modem_in
        cmp #13
        beq rename_done
        sta pet_name,X
        inx
        cpx #12
        bne rename_input_loop
rename_done:
    lda #0
    sta pet_name,X
    ldx #0
renamed_msg_loop:
        lda renamed_msg,X
        beq renamed_msg_done
        jsr modem_out
        inx
        bne renamed_msg_loop
renamed_msg_done:
    jsr modem_in
    jmp pets_menu

rename_prompt_msg:
    .text "\r\nNew name (12 chars): "
renamed_msg:
    .text "\r\nPet renamed!\r\n[Press any key]\r\n"

adopt_pet_menu:
    ldx #0
adopt_header_loop:
        lda adopt_header_msg,X
        beq adopt_header_done
        jsr modem_out
        inx
        bne adopt_header_loop
adopt_header_done:
    // List pets
    ldy #0
list_adopt_loop:
        cpy pet_types_count
        beq list_adopt_done
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Print pet name
        tya
        asl
        asl
        asl
        tax
print_adopt_name:
            lda pet_type_names,X
            cmp #$20
            beq adopt_name_done
            jsr modem_out
            inx
            txa
            and #$07
            bne print_adopt_name
adopt_name_done:
        // Print cost
        lda #' '
        jsr modem_out
        lda #'('
        jsr modem_out
        lda pet_adopt_cost,Y
        jsr print_byte_decimal
        lda #'g'
        jsr modem_out
        lda #')'
        jsr modem_out
        lda #13
        jsr modem_out
        iny
        cpy #4
        bne list_adopt_loop
list_adopt_done:
    ldx #0
adopt_prompt_loop:
        lda adopt_prompt_msg,X
        beq adopt_prompt_done
        jsr modem_out
        inx
        bne adopt_prompt_loop
adopt_prompt_done:
    jsr modem_in
    cmp #'0'
    beq go_back_adopt
    sec
    sbc #'1'
    cmp #4
    bcs go_adopt_menu_again
    sta adopt_choice
    // Check if can afford
    tax
    lda pet_adopt_cost,X
    cmp player_gold
    beq can_adopt
    bcc can_adopt
    ldx #0
cant_adopt_loop:
        lda no_gold_msg,X
        beq cant_adopt_done
        jsr modem_out
        inx
        bne cant_adopt_loop
cant_adopt_done:
    jsr modem_in
    jmp adopt_pet_menu
go_back_adopt:
    jmp user_room_menu
go_adopt_menu_again:
    jmp adopt_pet_menu

can_adopt:
    // Deduct cost
    ldx adopt_choice
    lda player_gold
    sec
    sbc pet_adopt_cost,X
    sta player_gold
    // Set pet
    lda adopt_choice
    clc
    adc #1
    sta pet_owned
    // Default name
    ldx #0
set_default_name:
        lda default_pet_name,X
        sta pet_name,X
        beq default_name_done
        inx
        cpx #12
        bne set_default_name
default_name_done:
    lda #5
    sta pet_hunger
    sta pet_happiness
    lda #1
    sta pet_level
    ldx #0
adopted_msg_loop:
        lda adopted_msg,X
        beq adopted_msg_done
        jsr modem_out
        inx
        bne adopted_msg_loop
adopted_msg_done:
    jsr modem_in
    jmp pets_menu

adopt_choice: .byte 0
adopt_header_msg:
    .text "\r\n=== ADOPT A PET ===\r\n"
adopt_prompt_msg:
    .text "\r\nAdopt which? (0=back): "
default_pet_name:
    .text "Buddy"
    .byte 0
adopted_msg:
    .text "\r\nCongratulations! Pet adopted!\r\n[Press any key]\r\n"

// ============================================
// BADGES SYSTEM
// ============================================

badges_menu:
    ldx #0
badges_header_loop:
        lda badges_header_msg,X
        beq badges_header_done
        jsr modem_out
        inx
        bne badges_header_loop
badges_header_done:
    // Show current displayed badge
    ldx #0
displayed_badge_loop:
        lda displayed_badge_msg,X
        beq displayed_badge_done
        jsr modem_out
        inx
        bne displayed_badge_loop
displayed_badge_done:
    ldx badge_displayed
    lda badge_icons,X
    jsr modem_out
    lda #' '
    jsr modem_out
    // Print badge name
    lda badge_displayed
    asl
    asl
    asl
    asl
    tax
print_current_badge:
        lda badge_names,X
        cmp #$20
        beq current_badge_done
        jsr modem_out
        inx
        txa
        and #$0F
        bne print_current_badge
current_badge_done:
    lda #13
    jsr modem_out
    lda #13
    jsr modem_out
    // List all badges
    ldx #0
badges_list_header_loop:
        lda badges_list_msg,X
        beq badges_list_header_done
        jsr modem_out
        inx
        bne badges_list_header_loop
badges_list_header_done:
    ldy #0
    jmp list_badges_loop
go_list_badges_done_early:
    jmp list_badges_done
list_badges_loop:
        cpy badge_count
        beq go_list_badges_done_early
        // Print number
        tya
        clc
        adc #'1'
        jsr modem_out
        lda #'.'
        jsr modem_out
        lda #' '
        jsr modem_out
        // Check if earned
        lda badges_earned
        and badge_bit_masks,Y
        beq badge_locked
        // Earned - show icon
        lda #'['
        jsr modem_out
        ldx badge_icons,Y
        txa
        jsr modem_out
        lda #']'
        jsr modem_out
        jmp print_badge_name
badge_locked:
        lda #'['
        jsr modem_out
        lda #' '
        jsr modem_out
        lda #']'
        jsr modem_out
print_badge_name:
        lda #' '
        jsr modem_out
        tya
        asl
        asl
        asl
        asl
        tax
print_badge_char:
            lda badge_names,X
            cmp #$20
            beq badge_name_done
            jsr modem_out
            inx
            txa
            and #$0F
            bne print_badge_char
badge_name_done:
        lda #13
        jsr modem_out
        iny
        cpy #8
        bne list_badges_loop
list_badges_done:
    // Prompt
    ldx #0
badge_prompt_loop:
        lda badge_prompt_msg,X
        beq badge_prompt_done
        jsr modem_out
        inx
        bne badge_prompt_loop
badge_prompt_done:
    jsr modem_in
    cmp #'0'
    beq go_back_badges
    sec
    sbc #'1'
    cmp #8
    bcs go_badges_menu_again
    // Check if earned
    tay
    lda badges_earned
    and badge_bit_masks,Y
    beq badge_not_earned
    // Set as displayed
    sty badge_displayed
    ldx #0
badge_set_loop:
        lda badge_set_msg,X
        beq badge_set_done
        jsr modem_out
        inx
        bne badge_set_loop
badge_set_done:
    jsr modem_in
    jmp badges_menu
go_back_badges:
    jmp user_room_menu
go_badges_menu_again:
    jmp badges_menu

badge_not_earned:
    ldx #0
not_earned_loop:
        lda not_earned_msg,X
        beq not_earned_done
        jsr modem_out
        inx
        bne not_earned_loop
not_earned_done:
    jsr modem_in
    jmp badges_menu

badge_bit_masks: .byte $01, $02, $04, $08, $10, $20, $40, $80
badges_header_msg:
    .text "\r\n=== BADGES ===\r\n"
displayed_badge_msg:
    .text "Current Badge: "
badges_list_msg:
    .text "Your Badges:\r\n"
badge_prompt_msg:
    .text "\r\nSet display badge (1-8, 0=back): "
badge_set_msg:
    .text "\r\nBadge set!\r\n[Press any key]\r\n"
not_earned_msg:
    .text "\r\nBadge not earned yet!\r\n[Press any key]\r\n"

// ============================================
// LOTTERY SYSTEM
// ============================================

lottery_menu:
    ldx #0
lottery_header_loop:
        lda lottery_header_msg,X
        beq lottery_header_done
        jsr modem_out
        inx
        bne lottery_header_loop
lottery_header_done:
    // Show jackpot
    ldx #0
jackpot_label_loop:
        lda jackpot_label_msg,X
        beq jackpot_label_done
        jsr modem_out
        inx
        bne jackpot_label_loop
jackpot_label_done:
    lda lottery_jackpot
    jsr print_byte_decimal
    ldx #0
gold_suffix_lottery_loop:
        lda gold_suffix_lottery_msg,X
        beq gold_suffix_lottery_done
        jsr modem_out
        inx
        bne gold_suffix_lottery_loop
gold_suffix_lottery_done:
    // Show tickets owned
    ldx #0
tickets_label_loop:
        lda tickets_label_msg,X
        beq tickets_label_done
        jsr modem_out
        inx
        bne tickets_label_loop
tickets_label_done:
    lda lottery_tickets
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Show your gold
    ldx #0
your_gold_lottery_loop:
        lda your_gold_lottery_msg,X
        beq your_gold_lottery_done
        jsr modem_out
        inx
        bne your_gold_lottery_loop
your_gold_lottery_done:
    lda player_gold
    jsr print_byte_decimal
    lda #'g'
    jsr modem_out
    lda #13
    jsr modem_out
    // Show menu
    ldx #0
lottery_options_loop:
        lda lottery_options_msg,X
        beq lottery_options_done
        jsr modem_out
        inx
        bne lottery_options_loop
lottery_options_done:
    jsr modem_in
    cmp #'1'
    beq go_buy_ticket
    cmp #'2'
    beq go_play_lottery
    cmp #'3'
    beq go_view_prizes
    cmp #'0'
    beq go_back_lottery
    jmp lottery_menu
go_buy_ticket:
    jmp buy_lottery_ticket
go_play_lottery:
    jmp play_lottery
go_view_prizes:
    jmp view_lottery_prizes
go_back_lottery:
    jmp user_room_menu

lottery_header_msg:
    .text "\r\n=== LOTTERY ===\r\n"
jackpot_label_msg:
    .text "Current Jackpot: "
gold_suffix_lottery_msg:
    .text " gold!\r\n"
tickets_label_msg:
    .text "Your Tickets: "
your_gold_lottery_msg:
    .text "Your Gold: "
lottery_options_msg:
    .text "\r\n1. Buy Ticket (10g)\r\n2. Play Lottery\r\n3. View Prizes\r\n0. Back\r\n> "

buy_lottery_ticket:
    // Check gold
    lda player_gold
    cmp lottery_ticket_cost
    bcs can_buy_ticket
    ldx #0
no_gold_lottery_loop:
        lda no_gold_lottery_msg,X
        beq no_gold_lottery_done
        jsr modem_out
        inx
        bne no_gold_lottery_loop
no_gold_lottery_done:
    jsr modem_in
    jmp lottery_menu
can_buy_ticket:
    // Deduct gold
    lda player_gold
    sec
    sbc lottery_ticket_cost
    sta player_gold
    // Add ticket
    inc lottery_tickets
    // Add to jackpot
    lda lottery_jackpot
    clc
    adc #5
    sta lottery_jackpot
    ldx #0
ticket_bought_loop:
        lda ticket_bought_msg,X
        beq ticket_bought_done
        jsr modem_out
        inx
        bne ticket_bought_loop
ticket_bought_done:
    jsr modem_in
    jmp lottery_menu

no_gold_lottery_msg:
    .text "\r\nNot enough gold!\r\n[Press any key]\r\n"
ticket_bought_msg:
    .text "\r\nTicket purchased!\r\n[Press any key]\r\n"

play_lottery:
    // Need at least 1 ticket
    lda lottery_tickets
    beq no_tickets
    // Use a ticket
    dec lottery_tickets
    // Draw random number 0-15
    jsr get_random
    and #$0F
    sta lottery_result
    // Check result - use intermediate jumps
    cmp #0
    beq go_win_jackpot
    cmp #1
    beq go_win_prize4
    cmp #2
    beq go_win_prize3
    cmp #3
    beq go_win_prize3
    cmp #4
    beq go_win_prize2
    cmp #5
    beq go_win_prize2
    cmp #6
    beq go_win_prize2
    cmp #7
    beq go_win_prize1
    cmp #8
    beq go_win_prize1
    cmp #9
    beq go_win_prize1
    cmp #10
    beq go_win_prize1
    // Lose (11-15)
    ldx #0
lottery_lose_loop:
        lda lottery_lose_msg,X
        beq lottery_lose_done
        jsr modem_out
        inx
        bne lottery_lose_loop
lottery_lose_done:
    jsr modem_in
    jmp lottery_menu

go_win_jackpot:
    jmp win_jackpot
go_win_prize4:
    jmp win_prize4
go_win_prize3:
    jmp win_prize3
go_win_prize2:
    jmp win_prize2
go_win_prize1:
    jmp win_prize1

no_tickets:
    ldx #0
no_tickets_loop:
        lda no_tickets_msg,X
        beq no_tickets_done
        jsr modem_out
        inx
        bne no_tickets_loop
no_tickets_done:
    jsr modem_in
    jmp lottery_menu

win_jackpot:
    lda player_gold
    clc
    adc lottery_jackpot
    sta player_gold
    ldx #0
jackpot_win_loop:
        lda jackpot_win_msg,X
        beq jackpot_win_done
        jsr modem_out
        inx
        bne jackpot_win_loop
jackpot_win_done:
    lda lottery_jackpot
    jsr print_byte_decimal
    lda #100
    sta lottery_jackpot
    jmp lottery_win_finish

win_prize4:
    lda player_gold
    clc
    adc #50
    sta player_gold
    ldx #0
prize4_loop:
        lda prize_win_msg,X
        beq prize4_done
        jsr modem_out
        inx
        bne prize4_loop
prize4_done:
    lda #50
    jsr print_byte_decimal
    jmp lottery_win_finish

win_prize3:
    lda player_gold
    clc
    adc #25
    sta player_gold
    ldx #0
prize3_loop:
        lda prize_win_msg,X
        beq prize3_done
        jsr modem_out
        inx
        bne prize3_loop
prize3_done:
    lda #25
    jsr print_byte_decimal
    jmp lottery_win_finish

win_prize2:
    lda player_gold
    clc
    adc #10
    sta player_gold
    ldx #0
prize2_loop:
        lda prize_win_msg,X
        beq prize2_done
        jsr modem_out
        inx
        bne prize2_loop
prize2_done:
    lda #10
    jsr print_byte_decimal
    jmp lottery_win_finish

win_prize1:
    lda player_gold
    clc
    adc #5
    sta player_gold
    ldx #0
prize1_loop:
        lda prize_win_msg,X
        beq prize1_done
        jsr modem_out
        inx
        bne prize1_loop
prize1_done:
    lda #5
    jsr print_byte_decimal
lottery_win_finish:
    ldx #0
gold_win_suffix_loop:
        lda gold_win_suffix_msg,X
        beq gold_win_suffix_done
        jsr modem_out
        inx
        bne gold_win_suffix_loop
gold_win_suffix_done:
    jsr modem_in
    jmp lottery_menu

lottery_result: .byte 0
no_tickets_msg:
    .text "\r\nYou need a ticket!\r\n[Press any key]\r\n"
lottery_lose_msg:
    .text "\r\nNo luck this time...\r\n[Press any key]\r\n"
jackpot_win_msg:
    .text "\r\n*** JACKPOT! *** You won "
prize_win_msg:
    .text "\r\nYou won "
gold_win_suffix_msg:
    .text " gold!\r\n[Press any key]\r\n"

view_lottery_prizes:
    ldx #0
prizes_header_loop:
        lda prizes_header_msg,X
        beq prizes_header_done
        jsr modem_out
        inx
        bne prizes_header_loop
prizes_header_done:
    ldx #0
prizes_list_loop:
        lda prizes_list_msg,X
        beq prizes_list_done
        jsr modem_out
        inx
        bne prizes_list_loop
prizes_list_done:
    jsr modem_in
    jmp lottery_menu

prizes_header_msg:
    .text "\r\n=== LOTTERY PRIZES ===\r\n"
prizes_list_msg:
    .text "Jackpot (1/16): 100+ gold\r\n50 gold  (1/16)\r\n25 gold  (2/16)\r\n10 gold  (3/16)\r\n5 gold   (4/16)\r\nNothing  (5/16)\r\n[Press any key]\r\n"

// ============================================
// BANK SYSTEM
// ============================================

bank_menu:
    ldx #0
bank_header_loop:
        lda bank_header_msg,X
        beq bank_header_done
        jsr modem_out
        inx
        bne bank_header_loop
bank_header_done:
    // Show balances
    ldx #0
wallet_label_loop:
        lda wallet_label_msg,X
        beq wallet_label_done
        jsr modem_out
        inx
        bne wallet_label_loop
wallet_label_done:
    lda player_gold
    jsr print_byte_decimal
    lda #'g'
    jsr modem_out
    lda #13
    jsr modem_out
    // Savings
    ldx #0
savings_label_loop:
        lda savings_label_msg,X
        beq savings_label_done
        jsr modem_out
        inx
        bne savings_label_loop
savings_label_done:
    lda bank_balance
    jsr print_byte_decimal
    lda #'g'
    jsr modem_out
    lda #13
    jsr modem_out
    // Loan
    ldx #0
loan_label_loop:
        lda loan_label_msg,X
        beq loan_label_done
        jsr modem_out
        inx
        bne loan_label_loop
loan_label_done:
    lda bank_loan
    jsr print_byte_decimal
    lda #'g'
    jsr modem_out
    lda #13
    jsr modem_out
    // Menu options
    ldx #0
bank_options_loop:
        lda bank_options_msg,X
        beq bank_options_done
        jsr modem_out
        inx
        bne bank_options_loop
bank_options_done:
    jsr modem_in
    cmp #'1'
    beq go_deposit
    cmp #'2'
    beq go_withdraw
    cmp #'3'
    beq go_take_loan
    cmp #'4'
    beq go_repay_loan
    cmp #'5'
    beq go_collect_interest
    cmp #'0'
    beq go_back_bank
    jmp bank_menu
go_deposit:
    jmp bank_deposit
go_withdraw:
    jmp bank_withdraw
go_take_loan:
    jmp take_loan
go_repay_loan:
    jmp repay_loan
go_collect_interest:
    jmp collect_interest
go_back_bank:
    jmp user_room_menu

bank_header_msg:
    .text "\r\n=== BANK ===\r\n"
wallet_label_msg:
    .text "Wallet: "
savings_label_msg:
    .text "Savings: "
loan_label_msg:
    .text "Loan Owed: "
bank_options_msg:
    .text "\r\n1. Deposit (10g)\r\n2. Withdraw (10g)\r\n3. Take Loan (50g)\r\n4. Repay Loan\r\n5. Collect Interest\r\n0. Back\r\n> "

bank_deposit:
    // Need at least 10 gold
    lda player_gold
    cmp #10
    bcs can_deposit
    ldx #0
no_gold_bank_loop:
        lda no_gold_bank_msg,X
        beq no_gold_bank_done
        jsr modem_out
        inx
        bne no_gold_bank_loop
no_gold_bank_done:
    jsr modem_in
    jmp bank_menu
can_deposit:
    lda player_gold
    sec
    sbc #10
    sta player_gold
    lda bank_balance
    clc
    adc #10
    sta bank_balance
    ldx #0
deposit_done_loop:
        lda deposit_done_msg,X
        beq deposit_done_done
        jsr modem_out
        inx
        bne deposit_done_loop
deposit_done_done:
    jsr modem_in
    jmp bank_menu

no_gold_bank_msg:
    .text "\r\nNot enough gold!\r\n[Press any key]\r\n"
deposit_done_msg:
    .text "\r\nDeposited 10 gold!\r\n[Press any key]\r\n"

bank_withdraw:
    // Need at least 10 in savings
    lda bank_balance
    cmp #10
    bcs can_withdraw
    ldx #0
no_savings_loop:
        lda no_savings_msg,X
        beq no_savings_done
        jsr modem_out
        inx
        bne no_savings_loop
no_savings_done:
    jsr modem_in
    jmp bank_menu
can_withdraw:
    lda bank_balance
    sec
    sbc #10
    sta bank_balance
    lda player_gold
    clc
    adc #10
    sta player_gold
    ldx #0
withdraw_done_loop:
        lda withdraw_done_msg,X
        beq withdraw_done_done
        jsr modem_out
        inx
        bne withdraw_done_loop
withdraw_done_done:
    jsr modem_in
    jmp bank_menu

no_savings_msg:
    .text "\r\nNot enough savings!\r\n[Press any key]\r\n"
withdraw_done_msg:
    .text "\r\nWithdrew 10 gold!\r\n[Press any key]\r\n"

take_loan:
    // Check if already have loan
    lda bank_loan
    bne already_have_loan
    // Give 50 gold loan
    lda player_gold
    clc
    adc #50
    sta player_gold
    lda #55  // 50 + 10% interest
    sta bank_loan
    ldx #0
loan_taken_loop:
        lda loan_taken_msg,X
        beq loan_taken_done
        jsr modem_out
        inx
        bne loan_taken_loop
loan_taken_done:
    jsr modem_in
    jmp bank_menu
already_have_loan:
    ldx #0
already_loan_loop:
        lda already_loan_msg,X
        beq already_loan_done
        jsr modem_out
        inx
        bne already_loan_loop
already_loan_done:
    jsr modem_in
    jmp bank_menu

loan_taken_msg:
    .text "\r\nLoan granted: 50g\r\nYou owe: 55g (with interest)\r\n[Press any key]\r\n"
already_loan_msg:
    .text "\r\nRepay existing loan first!\r\n[Press any key]\r\n"

repay_loan:
    // Check if have loan
    lda bank_loan
    beq no_loan_to_repay
    // Check if have enough gold
    cmp player_gold
    beq can_repay
    bcc can_repay
    ldx #0
not_enough_repay_loop:
        lda not_enough_repay_msg,X
        beq not_enough_repay_done
        jsr modem_out
        inx
        bne not_enough_repay_loop
not_enough_repay_done:
    jsr modem_in
    jmp bank_menu
can_repay:
    lda player_gold
    sec
    sbc bank_loan
    sta player_gold
    lda #0
    sta bank_loan
    ldx #0
loan_repaid_loop:
        lda loan_repaid_msg,X
        beq loan_repaid_done
        jsr modem_out
        inx
        bne loan_repaid_loop
loan_repaid_done:
    jsr modem_in
    jmp bank_menu
no_loan_to_repay:
    ldx #0
no_loan_loop:
        lda no_loan_msg,X
        beq no_loan_done
        jsr modem_out
        inx
        bne no_loan_loop
no_loan_done:
    jsr modem_in
    jmp bank_menu

not_enough_repay_msg:
    .text "\r\nNot enough gold to repay!\r\n[Press any key]\r\n"
loan_repaid_msg:
    .text "\r\nLoan repaid in full!\r\n[Press any key]\r\n"
no_loan_msg:
    .text "\r\nNo loan to repay.\r\n[Press any key]\r\n"

collect_interest:
    // 5% interest on savings (min 1g if balance >= 20)
    lda bank_balance
    cmp #20
    bcc no_interest_yet
    // Calculate 5%: divide by 20
    lsr
    lsr
    lsr
    lsr  // Rough divide by 16 ~ 6%
    beq no_interest_yet
    sta interest_amount
    clc
    adc bank_balance
    sta bank_balance
    ldx #0
interest_collected_loop:
        lda interest_collected_msg,X
        beq interest_collected_done
        jsr modem_out
        inx
        bne interest_collected_loop
interest_collected_done:
    lda interest_amount
    jsr print_byte_decimal
    ldx #0
interest_suffix_loop:
        lda interest_suffix_msg,X
        beq interest_suffix_done
        jsr modem_out
        inx
        bne interest_suffix_loop
interest_suffix_done:
    jsr modem_in
    jmp bank_menu
no_interest_yet:
    ldx #0
no_interest_loop:
        lda no_interest_msg,X
        beq no_interest_done
        jsr modem_out
        inx
        bne no_interest_loop
no_interest_done:
    jsr modem_in
    jmp bank_menu

interest_amount: .byte 0
interest_collected_msg:
    .text "\r\nInterest collected: +"
interest_suffix_msg:
    .text "g\r\n[Press any key]\r\n"
no_interest_msg:
    .text "\r\nNeed 20+ savings for interest.\r\n[Press any key]\r\n"

// ============================================
// AUCTION HOUSE
// ============================================

auction_menu:
    ldx #0
auction_header_loop:
        lda auction_header_msg,X
        beq auction_header_done
        jsr modem_out
        inx
        bne auction_header_loop
auction_header_done:
    // Show current auction status
    lda auction_active
    bne show_current_auction
    ldx #0
no_auction_loop:
        lda no_auction_msg,X
        beq no_auction_done
        jsr modem_out
        inx
        bne no_auction_loop
no_auction_done:
    jmp auction_show_options
show_current_auction:
    ldx #0
current_auction_loop:
        lda current_auction_msg,X
        beq current_auction_done
        jsr modem_out
        inx
        bne current_auction_loop
current_auction_done:
    // Show item name
    lda auction_item
    asl
    asl
    asl
    asl
    tax
auction_item_name_loop:
        lda shop_item_names,X
        beq auction_item_name_done
        jsr modem_out
        inx
        bne auction_item_name_loop
auction_item_name_done:
    ldx #0
bid_label_loop:
        lda bid_label_msg,X
        beq bid_label_done
        jsr modem_out
        inx
        bne bid_label_loop
bid_label_done:
    lda auction_current_bid
    jsr print_byte_decimal
    lda #'g'
    jsr modem_out
    lda #13
    jsr modem_out
auction_show_options:
    ldx #0
auction_options_loop:
        lda auction_options_msg,X
        beq auction_options_done
        jsr modem_out
        inx
        bne auction_options_loop
auction_options_done:
    jsr modem_in
    cmp #'1'
    beq go_list_auction
    cmp #'2'
    beq go_place_bid
    cmp #'3'
    beq go_end_auction
    cmp #'0'
    beq go_back_auction
    jmp auction_menu
go_list_auction:
    jmp list_auction
go_place_bid:
    jmp place_bid
go_end_auction:
    jmp end_auction
go_back_auction:
    jmp user_room_menu

auction_header_msg:
    .text "\r\n=== AUCTION HOUSE ===\r\n"
no_auction_msg:
    .text "No active auction.\r\n"
current_auction_msg:
    .text "Current Item: "
bid_label_msg:
    .text "\r\nHighest Bid: "
auction_options_msg:
    .text "\r\n1. List Item\r\n2. Place Bid\r\n3. End Auction\r\n0. Back\r\n> "

list_auction:
    // Check if auction already active
    lda auction_active
    beq can_list
    ldx #0
auction_busy_loop:
        lda auction_busy_msg,X
        beq auction_busy_done
        jsr modem_out
        inx
        bne auction_busy_loop
auction_busy_done:
    jsr modem_in
    jmp auction_menu
can_list:
    ldx #0
list_prompt_loop:
        lda list_prompt_msg,X
        beq list_prompt_done
        jsr modem_out
        inx
        bne list_prompt_loop
list_prompt_done:
    jsr modem_in
    sec
    sbc #'1'
    cmp #6
    bcs list_invalid
    sta auction_item
    lda #10
    sta auction_min_bid
    sta auction_current_bid
    lda #0
    sta auction_seller
    lda #1
    sta auction_active
    ldx #0
listed_loop:
        lda listed_msg,X
        beq listed_done
        jsr modem_out
        inx
        bne listed_loop
listed_done:
    jsr modem_in
    jmp auction_menu
list_invalid:
    jmp auction_menu

auction_busy_msg:
    .text "\r\nAuction in progress!\r\n[Press any key]\r\n"
list_prompt_msg:
    .text "\r\nList item (1-6):\r\n1. Fancy Rug\r\n2. Gold Frame\r\n3. Crystal Lamp\r\n4. Velvet Drapes\r\n5. Marble Statue\r\n6. Magic Mirror\r\n> "
listed_msg:
    .text "\r\nItem listed! Min bid: 10g\r\n[Press any key]\r\n"

place_bid:
    // Check if auction active
    lda auction_active
    bne can_bid
    ldx #0
no_auction_bid_loop:
        lda no_auction_bid_msg,X
        beq no_auction_bid_done
        jsr modem_out
        inx
        bne no_auction_bid_loop
no_auction_bid_done:
    jsr modem_in
    jmp auction_menu
can_bid:
    // Bid is current + 5
    lda auction_current_bid
    clc
    adc #5
    sta bid_amount
    // Check if player has enough
    cmp player_gold
    beq enough_for_bid
    bcc enough_for_bid
    ldx #0
not_enough_bid_loop:
        lda not_enough_bid_msg,X
        beq not_enough_bid_done
        jsr modem_out
        inx
        bne not_enough_bid_loop
not_enough_bid_done:
    jsr modem_in
    jmp auction_menu
enough_for_bid:
    lda bid_amount
    sta auction_current_bid
    ldx #0
bid_placed_loop:
        lda bid_placed_msg,X
        beq bid_placed_done
        jsr modem_out
        inx
        bne bid_placed_loop
bid_placed_done:
    lda bid_amount
    jsr print_byte_decimal
    ldx #0
bid_suffix_loop:
        lda bid_suffix_msg,X
        beq bid_suffix_done
        jsr modem_out
        inx
        bne bid_suffix_loop
bid_suffix_done:
    jsr modem_in
    jmp auction_menu

bid_amount: .byte 0
no_auction_bid_msg:
    .text "\r\nNo auction active!\r\n[Press any key]\r\n"
not_enough_bid_msg:
    .text "\r\nNot enough gold!\r\n[Press any key]\r\n"
bid_placed_msg:
    .text "\r\nBid placed: "
bid_suffix_msg:
    .text "g\r\n[Press any key]\r\n"

end_auction:
    // Check if auction active
    lda auction_active
    bne can_end
    ldx #0
no_auction_end_loop:
        lda no_auction_end_msg,X
        beq no_auction_end_done
        jsr modem_out
        inx
        bne no_auction_end_loop
no_auction_end_done:
    jsr modem_in
    jmp auction_menu
can_end:
    // Seller gets current bid
    lda auction_current_bid
    clc
    adc player_gold
    sta player_gold
    lda #0
    sta auction_active
    ldx #0
auction_sold_loop:
        lda auction_sold_msg,X
        beq auction_sold_done
        jsr modem_out
        inx
        bne auction_sold_loop
auction_sold_done:
    lda auction_current_bid
    jsr print_byte_decimal
    ldx #0
sold_suffix_loop:
        lda sold_suffix_msg,X
        beq sold_suffix_done
        jsr modem_out
        inx
        bne sold_suffix_loop
sold_suffix_done:
    jsr modem_in
    jmp auction_menu

no_auction_end_msg:
    .text "\r\nNo auction to end!\r\n[Press any key]\r\n"
auction_sold_msg:
    .text "\r\nSold for: "
sold_suffix_msg:
    .text "g\r\n[Press any key]\r\n"

// ============================================
// WEATHER SYSTEM
// ============================================

weather_menu:
    ldx #0
weather_header_loop:
        lda weather_header_msg,X
        beq weather_header_done
        jsr modem_out
        inx
        bne weather_header_loop
weather_header_done:
    // Show current weather
    ldx #0
current_weather_loop:
        lda current_weather_label,X
        beq current_weather_label_done
        jsr modem_out
        inx
        bne current_weather_loop
current_weather_label_done:
    lda current_weather
    asl
    asl
    asl
    asl
    tax
weather_name_loop:
        lda weather_names,X
        beq weather_name_done
        jsr modem_out
        inx
        bne weather_name_loop
weather_name_done:
    lda #13
    jsr modem_out
    // Show weather effect
    ldx #0
effect_label_loop:
        lda effect_label_msg,X
        beq effect_label_done
        jsr modem_out
        inx
        bne effect_label_loop
effect_label_done:
    lda current_weather
    asl
    asl
    asl
    asl
    asl
    tax
effect_desc_loop:
        lda weather_effects,X
        beq effect_desc_done
        jsr modem_out
        inx
        bne effect_desc_loop
effect_desc_done:
    lda #13
    jsr modem_out
    // Show options
    ldx #0
weather_options_loop:
        lda weather_options_msg,X
        beq weather_options_done
        jsr modem_out
        inx
        bne weather_options_loop
weather_options_done:
    jsr modem_in
    cmp #'1'
    beq go_check_forecast
    cmp #'2'
    beq go_weather_dance
    cmp #'3'
    beq go_collect_weather_bonus
    cmp #'0'
    beq go_back_weather
    jmp weather_menu
go_check_forecast:
    jmp check_forecast
go_weather_dance:
    jmp weather_dance
go_collect_weather_bonus:
    jmp collect_weather_bonus
go_back_weather:
    jmp user_room_menu

weather_header_msg:
    .text "\r\n=== WEATHER ===\r\n"
current_weather_label:
    .text "Current: "
effect_label_msg:
    .text "Effect: "
weather_options_msg:
    .text "\r\n1. Check Forecast\r\n2. Rain Dance\r\n3. Collect Bonus\r\n0. Back\r\n> "

weather_names:
    .text "Sunny           "  // 0
    .text "Rainy           "  // 1
    .text "Stormy          "  // 2
    .text "Snowy           "  // 3
    .text "Foggy           "  // 4

weather_effects:
    .text "+2g shop discount           "  // Sunny
    .text "+1g pet happiness           "  // Rainy
    .text "2x lottery chance           "  // Stormy
    .text "+5 visitor bonus            "  // Snowy
    .text "Mystery bonus!              "  // Foggy

check_forecast:
    ldx #0
forecast_loop:
        lda forecast_msg,X
        beq forecast_done
        jsr modem_out
        inx
        bne forecast_loop
forecast_done:
    // Random next weather
    jsr get_random
    and #7
    cmp #5
    bcc forecast_valid
    lda #0
forecast_valid:
    asl
    asl
    asl
    asl
    tax
forecast_name_loop:
        lda weather_names,X
        beq forecast_name_done
        jsr modem_out
        inx
        bne forecast_name_loop
forecast_name_done:
    ldx #0
forecast_suffix_loop:
        lda forecast_suffix_msg,X
        beq forecast_suffix_done
        jsr modem_out
        inx
        bne forecast_suffix_loop
forecast_suffix_done:
    jsr modem_in
    jmp weather_menu

forecast_msg:
    .text "\r\nTomorrow's forecast: "
forecast_suffix_msg:
    .text "\r\n[Press any key]\r\n"

weather_dance:
    ldx #0
dance_loop:
        lda dance_msg,X
        beq dance_done
        jsr modem_out
        inx
        bne dance_loop
dance_done:
    // Random chance to change weather
    jsr get_random
    and #3
    bne dance_failed
    // Change to random weather
    jsr get_random
    and #7
    cmp #5
    bcc dance_weather_ok
    lda #1  // Default to rainy
dance_weather_ok:
    sta current_weather
    ldx #0
dance_success_loop:
        lda dance_success_msg,X
        beq dance_success_done
        jsr modem_out
        inx
        bne dance_success_loop
dance_success_done:
    jsr modem_in
    jmp weather_menu
dance_failed:
    ldx #0
dance_fail_loop:
        lda dance_fail_msg,X
        beq dance_fail_done
        jsr modem_out
        inx
        bne dance_fail_loop
dance_fail_done:
    jsr modem_in
    jmp weather_menu

dance_msg:
    .text "\r\nYou perform a ritual dance...\r\n"
dance_success_msg:
    .text "The weather changes!\r\n[Press any key]\r\n"
dance_fail_msg:
    .text "Nothing happens.\r\n[Press any key]\r\n"

collect_weather_bonus:
    // Check if bonus available
    lda weather_bonus
    bne already_collected
    // Give bonus based on weather
    lda current_weather
    cmp #0  // Sunny = 2g
    bne not_sunny_bonus
    lda player_gold
    clc
    adc #2
    sta player_gold
    jmp bonus_given
not_sunny_bonus:
    cmp #1  // Rainy = pet hunger
    bne not_rainy_bonus
    inc pet_hunger
    jmp bonus_given
not_rainy_bonus:
    cmp #2  // Stormy = lottery ticket
    bne not_stormy_bonus
    inc lottery_tickets
    jmp bonus_given
not_stormy_bonus:
    cmp #3  // Snowy = 5g
    bne not_snowy_bonus
    lda player_gold
    clc
    adc #5
    sta player_gold
    jmp bonus_given
not_snowy_bonus:
    // Foggy = mystery (random 1-10g)
    jsr get_random
    and #15
    clc
    adc #1
    clc
    adc player_gold
    sta player_gold
bonus_given:
    lda #1
    sta weather_bonus
    ldx #0
bonus_collected_loop:
        lda bonus_collected_msg,X
        beq bonus_collected_done
        jsr modem_out
        inx
        bne bonus_collected_loop
bonus_collected_done:
    jsr modem_in
    jmp weather_menu
already_collected:
    ldx #0
already_bonus_loop:
        lda already_bonus_msg,X
        beq already_bonus_done
        jsr modem_out
        inx
        bne already_bonus_loop
already_bonus_done:
    jsr modem_in
    jmp weather_menu

bonus_collected_msg:
    .text "\r\nWeather bonus collected!\r\n[Press any key]\r\n"
already_bonus_msg:
    .text "\r\nBonus already collected today.\r\n[Press any key]\r\n"

// ============================================
// MAGIC & SPELLS SYSTEM
// Based on Frost Weaver lore from Chapter 14
// Spells: GLACIOUS (ice), NIX (snow), ILLUMINA (light)
// ============================================

magic_menu:
    ldx #0
magic_header_loop:
        lda magic_header_msg,X
        beq magic_header_done
        jsr modem_out
        inx
        bne magic_header_loop
magic_header_done:
    // Show mana
    ldx #0
mana_label_loop:
        lda mana_label_msg,X
        beq mana_label_done
        jsr modem_out
        inx
        bne mana_label_loop
mana_label_done:
    lda player_mana
    jsr print_byte_decimal
    lda #'/'
    jsr modem_out
    lda player_max_mana
    jsr print_byte_decimal
    // Show Frost Weaver rank
    ldx #0
fw_rank_label_loop:
        lda fw_rank_label_msg,X
        beq fw_rank_label_done
        jsr modem_out
        inx
        bne fw_rank_label_loop
fw_rank_label_done:
    lda frost_weaver_rank
    beq show_rank_none
    cmp #1
    beq show_rank_initiate
    cmp #2
    beq show_rank_adept
    jmp show_rank_master
show_rank_none:
    ldx #0
rank_none_loop:
        lda rank_none_msg,X
        beq rank_done
        jsr modem_out
        inx
        bne rank_none_loop
    jmp rank_done
show_rank_initiate:
    ldx #0
rank_init_loop:
        lda rank_initiate_msg,X
        beq rank_done
        jsr modem_out
        inx
        bne rank_init_loop
    jmp rank_done
show_rank_adept:
    ldx #0
rank_adept_loop:
        lda rank_adept_msg,X
        beq rank_done
        jsr modem_out
        inx
        bne rank_adept_loop
    jmp rank_done
show_rank_master:
    ldx #0
rank_master_loop:
        lda rank_master_msg,X
        beq rank_done
        jsr modem_out
        inx
        bne rank_master_loop
rank_done:
    // Show spell options
    ldx #0
magic_options_loop:
        lda magic_options_msg,X
        beq magic_options_done
        jsr modem_out
        inx
        bne magic_options_loop
magic_options_done:
    jsr modem_in
    cmp #'1'
    beq go_cast_glacious
    cmp #'2'
    beq go_cast_nix
    cmp #'3'
    beq go_cast_illumina
    cmp #'4'
    beq go_learn_spells
    cmp #'5'
    beq go_third_eye
    cmp #'6'
    beq go_spell_lore
    cmp #'0'
    beq go_back_magic
    jmp magic_menu
go_cast_glacious:
    jmp cast_glacious
go_cast_nix:
    jmp cast_nix
go_cast_illumina:
    jmp cast_illumina
go_learn_spells:
    jmp learn_spells
go_third_eye:
    jmp practice_third_eye
go_spell_lore:
    jmp view_spell_lore
go_back_magic:
    jmp main_loop

// --- Cast GLACIOUS (Ice Spell) ---
cast_glacious:
    // Check if spell known
    lda spells_known
    and #$01
    beq glacious_not_known
    // Check mana cost (5 mana)
    lda player_mana
    cmp #5
    bcc glacious_no_mana
    // Cast the spell!
    sec
    sbc #5
    sta player_mana
    lda #0
    sta last_spell_cast
    inc spell_combo_count
    ldx #0
glacious_cast_loop:
        lda glacious_cast_msg,X
        beq glacious_cast_done
        jsr modem_out
        inx
        bne glacious_cast_loop
glacious_cast_done:
    jmp magic_menu
glacious_not_known:
    ldx #0
glacious_unknown_loop:
        lda spell_not_known_msg,X
        beq glacious_unknown_done
        jsr modem_out
        inx
        bne glacious_unknown_loop
glacious_unknown_done:
    jmp magic_menu
glacious_no_mana:
    ldx #0
glacious_nomana_loop:
        lda no_mana_msg,X
        beq glacious_nomana_done
        jsr modem_out
        inx
        bne glacious_nomana_loop
glacious_nomana_done:
    jmp magic_menu

// --- Cast NIX (Snow Spell) ---
cast_nix:
    // Check if spell known
    lda spells_known
    and #$02
    beq nix_not_known
    // Check mana cost (8 mana)
    lda player_mana
    cmp #8
    bcc nix_no_mana
    // Cast the spell!
    sec
    sbc #8
    sta player_mana
    lda #1
    sta last_spell_cast
    inc spell_combo_count
    ldx #0
nix_cast_loop:
        lda nix_cast_msg,X
        beq nix_cast_done
        jsr modem_out
        inx
        bne nix_cast_loop
nix_cast_done:
    jmp magic_menu
nix_not_known:
    ldx #0
nix_unknown_loop:
        lda spell_not_known_msg,X
        beq nix_unknown_done
        jsr modem_out
        inx
        bne nix_unknown_loop
nix_unknown_done:
    jmp magic_menu
nix_no_mana:
    ldx #0
nix_nomana_loop:
        lda no_mana_msg,X
        beq nix_nomana_done
        jsr modem_out
        inx
        bne nix_nomana_loop
nix_nomana_done:
    jmp magic_menu

// --- Cast ILLUMINA (Light Spell) ---
cast_illumina:
    // Check if spell known
    lda spells_known
    and #$04
    beq illumina_not_known
    // Check mana cost (10 mana)
    lda player_mana
    cmp #10
    bcc illumina_no_mana
    // Cast the spell!
    sec
    sbc #10
    sta player_mana
    lda #2
    sta last_spell_cast
    inc spell_combo_count
    ldx #0
illumina_cast_loop:
        lda illumina_cast_msg,X
        beq illumina_cast_done
        jsr modem_out
        inx
        bne illumina_cast_loop
illumina_cast_done:
    jmp magic_menu
illumina_not_known:
    ldx #0
illumina_unknown_loop:
        lda spell_not_known_msg,X
        beq illumina_unknown_done
        jsr modem_out
        inx
        bne illumina_unknown_loop
illumina_unknown_done:
    jmp magic_menu
illumina_no_mana:
    ldx #0
illumina_nomana_loop:
        lda no_mana_msg,X
        beq illumina_nomana_done
        jsr modem_out
        inx
        bne illumina_nomana_loop
illumina_nomana_done:
    jmp magic_menu

// --- Learn Spells (Frost Weaver Initiation) ---
learn_spells:
    ldx #0
learn_spells_header_loop:
        lda learn_spells_header_msg,X
        beq learn_spells_header_done
        jsr modem_out
        inx
        bne learn_spells_header_loop
learn_spells_header_done:
    jsr modem_in
    cmp #'1'
    beq learn_glacious
    cmp #'2'
    bne not_learn_nix
    jmp learn_nix
not_learn_nix:
    cmp #'3'
    bne not_learn_illumina
    jmp learn_illumina
not_learn_illumina:
    cmp #'0'
    bne stay_learn_spells
    jmp back_from_learn
stay_learn_spells:
    jmp learn_spells
learn_glacious:
    // Check if already known
    lda spells_known
    and #$01
    bne already_know_glacious
    // Learn the spell!
    lda spells_known
    ora #$01
    sta spells_known
    // Set rank to initiate if not already
    lda frost_weaver_rank
    bne skip_rank_glacious
    lda #1
    sta frost_weaver_rank
skip_rank_glacious:
    ldx #0
learned_glacious_loop:
        lda learned_glacious_msg,X
        beq learned_glacious_done
        jsr modem_out
        inx
        bne learned_glacious_loop
learned_glacious_done:
    jmp learn_spells
already_know_glacious:
    ldx #0
already_known_loop:
        lda already_known_msg,X
        beq already_known_done
        jsr modem_out
        inx
        bne already_known_loop
already_known_done:
    jmp learn_spells
learn_nix:
    // Must know GLACIOUS first
    lda spells_known
    and #$01
    beq need_prerequisite
    // Check if already known
    lda spells_known
    and #$02
    bne already_know_nix
    // Learn the spell!
    lda spells_known
    ora #$02
    sta spells_known
    // Upgrade rank to adept
    lda frost_weaver_rank
    cmp #2
    bcs skip_rank_nix
    lda #2
    sta frost_weaver_rank
skip_rank_nix:
    ldx #0
learned_nix_loop:
        lda learned_nix_msg,X
        beq learned_nix_done
        jsr modem_out
        inx
        bne learned_nix_loop
learned_nix_done:
    jmp learn_spells
already_know_nix:
    jmp already_know_glacious
need_prerequisite:
    ldx #0
prereq_loop:
        lda prereq_msg,X
        beq prereq_done
        jsr modem_out
        inx
        bne prereq_loop
prereq_done:
    jmp learn_spells
learn_illumina:
    // Must know NIX first
    lda spells_known
    and #$02
    beq need_prerequisite
    // Check if already known
    lda spells_known
    and #$04
    bne already_know_illumina
    // Learn the spell!
    lda spells_known
    ora #$04
    sta spells_known
    // Upgrade rank to master
    lda #3
    sta frost_weaver_rank
    // Increase max mana as reward
    lda player_max_mana
    clc
    adc #10
    sta player_max_mana
    sta player_mana
    ldx #0
learned_illumina_loop:
        lda learned_illumina_msg,X
        beq learned_illumina_done
        jsr modem_out
        inx
        bne learned_illumina_loop
learned_illumina_done:
    jmp learn_spells
already_know_illumina:
    jmp already_know_glacious
back_from_learn:
    jmp magic_menu

// --- Third Eye Practice (Chapter 20) ---
practice_third_eye:
    ldx #0
third_eye_intro_loop:
        lda third_eye_intro_msg,X
        beq third_eye_intro_done
        jsr modem_out
        inx
        bne third_eye_intro_loop
third_eye_intro_done:
    jsr modem_in
    cmp #'1'
    beq do_pendulum_practice
    cmp #'2'
    bne not_meditation
    jmp do_meditation
not_meditation:
    cmp #'0'
    bne stay_third_eye
    jmp back_from_third_eye
stay_third_eye:
    jmp practice_third_eye
do_pendulum_practice:
    // Increase pendulum mastery
    lda pendulum_mastery
    cmp #10
    bcs pendulum_max
    inc pendulum_mastery
    // Grant mana regen bonus at milestones
    lda pendulum_mastery
    cmp #5
    bne pend_not_5
    inc mana_regen_rate
pend_not_5:
    cmp #10
    bne pend_not_10
    inc mana_regen_rate
pend_not_10:
    ldx #0
pendulum_success_loop:
        lda pendulum_success_msg,X
        beq pendulum_success_done
        jsr modem_out
        inx
        bne pendulum_success_loop
pendulum_success_done:
    lda pendulum_mastery
    jsr print_byte_decimal
    ldx #0
pendulum_level_loop:
        lda pendulum_level_msg,X
        beq pendulum_level_done
        jsr modem_out
        inx
        bne pendulum_level_loop
pendulum_level_done:
    jmp practice_third_eye
pendulum_max:
    ldx #0
pendulum_max_loop:
        lda pendulum_max_msg,X
        beq pendulum_max_done
        jsr modem_out
        inx
        bne pendulum_max_loop
pendulum_max_done:
    jmp practice_third_eye
do_meditation:
    // Restore mana
    lda player_mana
    clc
    adc mana_regen_rate
    cmp player_max_mana
    bcc mana_not_full
    lda player_max_mana
mana_not_full:
    sta player_mana
    ldx #0
meditation_done_loop:
        lda meditation_done_msg,X
        beq meditation_done_done
        jsr modem_out
        inx
        bne meditation_done_loop
meditation_done_done:
    lda player_mana
    jsr print_byte_decimal
    lda #'/'
    jsr modem_out
    lda player_max_mana
    jsr print_byte_decimal
    ldx #0
mana_restored_loop:
        lda mana_restored_msg,X
        beq mana_restored_done
        jsr modem_out
        inx
        bne mana_restored_loop
mana_restored_done:
    jmp practice_third_eye
back_from_third_eye:
    jmp magic_menu

// --- Spell Lore View ---
view_spell_lore:
    ldx #0
spell_lore_loop:
        lda spell_lore_msg,X
        beq spell_lore_done
        jsr modem_out
        inx
        bne spell_lore_loop
spell_lore_done:
    jsr modem_in
    jmp magic_menu

// === MAGIC SYSTEM MESSAGES ===
magic_header_msg:
    .text "\r\n=== MAGIC & SPELLS ===\r\n'May all magic join with yours and yours with ours.' - Frost Weaver Queen\r\n\r\n"
mana_label_msg:
    .text "Mana: "
fw_rank_label_msg:
    .text "\r\nFrost Weaver Rank: "
rank_none_msg:
    .text "Uninitiated"
rank_initiate_msg:
    .text "Initiate"
rank_adept_msg:
    .text "Adept"
rank_master_msg:
    .text "Master"
magic_options_msg:
    .text "\r\n\r\n--- CAST SPELLS ---\r\n1. GLACIOUS (Ice) [5 mana]\r\n2. NIX (Snow) [8 mana]\r\n3. ILLUMINA (Light) [10 mana]\r\n\r\n--- TRAINING ---\r\n4. Learn New Spells\r\n5. Third Eye Practice\r\n6. View Spell Lore\r\n0. Back\r\n> "

glacious_cast_msg:
    .text "\r\n\r\n*** GLACIOUS! ***\r\nIce crystallizes at your fingertips! Shards of frost spiral outward, striking your foes with bitter cold!\r\n(Effect: 8 ice damage + chance to freeze)\r\n[Press any key]\r\n"
nix_cast_msg:
    .text "\r\n\r\n*** NIX! ***\r\nFlowy drifts of snow swirl around you! The blizzard ensnares your enemies, slowing their movements!\r\n(Effect: 5 damage + slow debuff on all enemies)\r\n[Press any key]\r\n"
illumina_cast_msg:
    .text "\r\n\r\n*** ILLUMINA! ***\r\nYou become a beacon in the darkness! Radiant light pierces the shadows, revealing hidden paths and weakening creatures of night!\r\n(Effect: 12 light damage + reveals secrets + blinds undead)\r\n[Press any key]\r\n"

spell_not_known_msg:
    .text "\r\nYou have not learned this spell yet. Visit The Burrows and seek the Frost Weaver Queen!\r\n[Press any key]\r\n"
no_mana_msg:
    .text "\r\nNot enough mana! Rest or meditate to restore your magical energy.\r\n[Press any key]\r\n"

learn_spells_header_msg:
    .text "\r\n=== FROST WEAVER INITIATION ===\r\n'In the tradition of witches, wizards, and sages who protected Aurora for centuries, our duty falls onto you.'\r\n\r\n1. Learn GLACIOUS (Ice) - First spell\r\n2. Learn NIX (Snow) - Requires GLACIOUS\r\n3. Learn ILLUMINA (Light) - Requires NIX\r\n0. Back\r\n> "

learned_glacious_msg:
    .text "\r\n*** GLACIOUS LEARNED! ***\r\n'Glacious - the power of ice at your fingertips. Use it to fight against your enemies, use it to support your allies.'\r\nYou are now a Frost Weaver Initiate!\r\n[Press any key]\r\n"
learned_nix_msg:
    .text "\r\n*** NIX LEARNED! ***\r\n'Nix - the flowy drifts of snow are yours to command. Weave them about your enemies to ensnare them.'\r\nYou have advanced to Frost Weaver Adept!\r\n[Press any key]\r\n"
learned_illumina_msg:
    .text "\r\n*** ILLUMINA LEARNED! ***\r\n'Illumina - you shall be a light in darkness, a beacon in storm, a guide in chaos.'\r\nYou are now a Frost Weaver MASTER! Max mana increased by 10!\r\n[Press any key]\r\n"
already_known_msg:
    .text "\r\nYou have already mastered this spell.\r\n[Press any key]\r\n"
prereq_msg:
    .text "\r\nYou must learn the previous spell first. The path of the Frost Weaver is one of discipline.\r\n[Press any key]\r\n"

third_eye_intro_msg:
    .text "\r\n=== THIRD EYE PRACTICE ===\r\n'To activate your third eye, concentrate on its focal point - centered between hairline and brow, back about 2 inches.'\r\n- Samuel, Apprentice of Mage Damon\r\n\r\n1. Pendulum Practice (Increase mastery)\r\n2. Meditation (Restore mana)\r\n0. Back\r\n> "
pendulum_success_msg:
    .text "\r\nYou hold the pendulum still, observing your breathing... commanding it to spin with your mind alone!\r\nPendulum Mastery: "
pendulum_level_msg:
    .text "/10\r\n[Press any key]\r\n"
pendulum_max_msg:
    .text "\r\nYour pendulum spins nearly horizontal! You have achieved maximum mastery!\r\n[Press any key]\r\n"
meditation_done_msg:
    .text "\r\nYou focus on your breathing, drawing ambient magic through your third eye...\r\nMana restored: "
mana_restored_msg:
    .text "\r\n[Press any key]\r\n"

spell_lore_msg:
    .text "\r\n=== SPELL LORE ===\r\n\r\n--- THE FROST WEAVER'S RITE ---\r\n'As the snowy storm raged outside of the Burrows, the Frost Weaver Queen beckoned the citizens of Everland to join her in a ritual unlike any other.'\r\n\r\nThe three sacred spells of Aurora:\r\n\r\nGLACIOUS - Ice magic for combat\r\n  'Bring your fingers together...'\r\n\r\nNIX - Snow magic for control\r\n  'Weave the drifts about your foes...'\r\n\r\nILLUMINA - Light magic for revelation\r\n  'Be a beacon in the storm...'\r\n\r\n'The ritual is now complete. May all magic join with yours and yours with ours. Welcome to the Frost Weavers!'\r\n\r\n[Press any key]\r\n"

// ============================================
// ROMANCE SYSTEM
// ============================================

romance_menu:
    ldx #0
romance_header_loop:
        lda romance_header_msg,X
        beq romance_header_done
        jsr modem_out
        inx
        bne romance_header_loop
romance_header_done:
    // Show current status
    lda romance_partner
    cmp #255
    bne has_a_partner
    jmp show_no_partner
has_a_partner:
    // Has a partner
    ldx #0
partner_label_loop:
        lda partner_label_msg,X
        beq show_partner_name
        jsr modem_out
        inx
        bne partner_label_loop
show_partner_name:
    lda romance_partner
    cmp #0
    bne not_kira_partner
    ldx #0
kira_name_loop:
        lda kira_name_msg,X
        beq show_romance_level
        jsr modem_out
        inx
        bne kira_name_loop
not_kira_partner:
    cmp #1
    bne not_lyra_partner
    ldx #0
lyra_name_loop:
        lda lyra_name_msg,X
        beq show_romance_level
        jsr modem_out
        inx
        bne lyra_name_loop
not_lyra_partner:
    cmp #2
    bne not_kendrick_partner
    ldx #0
kendrick_name_loop:
        lda kendrick_name_msg,X
        beq show_romance_level
        jsr modem_out
        inx
        bne kendrick_name_loop
not_kendrick_partner:
    ldx #0
bonny_name_loop:
        lda bonny_name_msg,X
        beq show_romance_level
        jsr modem_out
        inx
        bne bonny_name_loop
show_romance_level:
    ldx #0
rom_level_loop:
        lda level_label_msg,X
        beq rom_level_num
        jsr modem_out
        inx
        bne rom_level_loop
rom_level_num:
    lda romance_level
    jsr print_byte_decimal
    ldx #0
stage_label_loop:
        lda stage_label_msg,X
        beq show_stage
        jsr modem_out
        inx
        bne stage_label_loop
show_stage:
    lda courtship_stage
    cmp #1
    bne not_introduced
    ldx #0
introduced_loop:
        lda introduced_msg,X
        beq romance_prompt_show
        jsr modem_out
        inx
        bne introduced_loop
not_introduced:
    cmp #2
    bne not_courting
    ldx #0
courting_loop:
        lda courting_msg,X
        beq romance_prompt_show
        jsr modem_out
        inx
        bne courting_loop
not_courting:
    cmp #3
    bne not_engaged
    ldx #0
engaged_loop:
        lda engaged_msg,X
        beq romance_prompt_show
        jsr modem_out
        inx
        bne engaged_loop
not_engaged:
    cmp #4
    bne romance_prompt_show
    ldx #0
married_loop:
        lda married_msg,X
        beq romance_prompt_show
        jsr modem_out
        inx
        bne married_loop
    jmp romance_prompt_show
show_no_partner:
    ldx #0
no_partner_loop:
        lda no_partner_msg,X
        beq romance_prompt_show
        jsr modem_out
        inx
        bne no_partner_loop
romance_prompt_show:
    ldx #0
romance_prompt_loop:
        lda romance_prompt_msg,X
        beq romance_wait_key
        jsr modem_out
        inx
        bne romance_prompt_loop
romance_wait_key:
    jsr modem_in
    cmp #'1'
    beq go_meet_partners
    cmp #'2'
    beq go_give_gift
    cmp #'3'
    beq go_go_on_date
    cmp #'4'
    beq go_propose
    cmp #'5'
    beq go_wedding
    cmp #'0'
    bne romance_wait_key
    jmp main_loop
go_meet_partners:
    jmp meet_partners
go_give_gift:
    jmp give_romance_gift
go_go_on_date:
    jmp go_on_date
go_propose:
    jmp propose_marriage
go_wedding:
    jmp hold_wedding

meet_partners:
    ldx #0
meet_partners_loop:
        lda meet_partners_msg,X
        beq meet_partners_wait
        jsr modem_out
        inx
        bne meet_partners_loop
meet_partners_wait:
    jsr modem_in
    cmp #'1'
    bne not_choose_kira
    lda #0
    sta romance_partner
    lda #1
    sta courtship_stage
    jmp partner_chosen
not_choose_kira:
    cmp #'2'
    bne not_choose_lyra
    lda #1
    sta romance_partner
    lda #1
    sta courtship_stage
    jmp partner_chosen
not_choose_lyra:
    cmp #'3'
    bne not_choose_kendrick
    lda #2
    sta romance_partner
    lda #1
    sta courtship_stage
    jmp partner_chosen
not_choose_kendrick:
    cmp #'4'
    bne not_choose_bonny
    lda #3
    sta romance_partner
    lda #1
    sta courtship_stage
    jmp partner_chosen
not_choose_bonny:
    cmp #'0'
    bne meet_partners_wait
    jmp romance_menu
partner_chosen:
    ldx #0
partner_chosen_loop:
        lda partner_chosen_msg,X
        beq partner_chosen_done
        jsr modem_out
        inx
        bne partner_chosen_loop
partner_chosen_done:
    jsr modem_in
    jmp romance_menu

give_romance_gift:
    lda romance_partner
    cmp #255
    bne has_partner_gift
    ldx #0
need_partner_loop:
        lda need_partner_msg,X
        beq need_partner_done
        jsr modem_out
        inx
        bne need_partner_loop
need_partner_done:
    jsr modem_in
    jmp romance_menu
has_partner_gift:
    lda player_gold
    cmp #10
    bcs afford_gift
    ldx #0
no_gold_gift_loop:
        lda no_gold_gift_msg,X
        beq no_gold_gift_done
        jsr modem_out
        inx
        bne no_gold_gift_loop
no_gold_gift_done:
    jsr modem_in
    jmp romance_menu
afford_gift:
    lda player_gold
    sec
    sbc #10
    sta player_gold
    inc gifts_given
    lda romance_level
    cmp #10
    bcs max_love
    inc romance_level
    lda romance_level
    cmp #5
    bne not_level_5
    lda #2
    sta courtship_stage
not_level_5:
max_love:
    ldx #0
gift_given_loop:
        lda gift_given_msg,X
        beq gift_given_done
        jsr modem_out
        inx
        bne gift_given_loop
gift_given_done:
    jsr modem_in
    jmp romance_menu

go_on_date:
    lda romance_partner
    cmp #255
    bne has_partner_date
    jmp need_partner_done
has_partner_date:
    lda courtship_stage
    cmp #2
    bcs can_date
    ldx #0
not_courting_yet_loop:
        lda not_courting_yet_msg,X
        beq not_courting_yet_done
        jsr modem_out
        inx
        bne not_courting_yet_loop
not_courting_yet_done:
    jsr modem_in
    jmp romance_menu
can_date:
    inc dates_completed
    lda romance_level
    cmp #10
    bcs max_date_love
    inc romance_level
max_date_love:
    ldx #0
date_success_loop:
        lda date_success_msg,X
        beq date_success_done
        jsr modem_out
        inx
        bne date_success_loop
date_success_done:
    jsr modem_in
    jmp romance_menu

propose_marriage:
    lda romance_partner
    cmp #255
    bne has_partner_propose
    jmp need_partner_done
has_partner_propose:
    lda romance_level
    cmp #8
    bcs can_propose
    ldx #0
rom_not_ready_loop:
        lda rom_not_ready_msg,X
        beq rom_not_ready_done
        jsr modem_out
        inx
        bne rom_not_ready_loop
rom_not_ready_done:
    jsr modem_in
    jmp romance_menu
can_propose:
    lda courtship_stage
    cmp #3
    bcs already_engaged
    lda #3
    sta courtship_stage
    ldx #0
proposal_accept_loop:
        lda proposal_accept_msg,X
        beq proposal_accept_done
        jsr modem_out
        inx
        bne proposal_accept_loop
proposal_accept_done:
    jsr modem_in
    jmp romance_menu
already_engaged:
    ldx #0
already_engaged_loop:
        lda already_engaged_msg,X
        beq already_engaged_done
        jsr modem_out
        inx
        bne already_engaged_loop
already_engaged_done:
    jsr modem_in
    jmp romance_menu

hold_wedding:
    lda courtship_stage
    cmp #3
    beq can_wedding
    ldx #0
not_engaged_wed_loop:
        lda not_engaged_wed_msg,X
        beq not_engaged_wed_done
        jsr modem_out
        inx
        bne not_engaged_wed_loop
not_engaged_wed_done:
    jsr modem_in
    jmp romance_menu
can_wedding:
    lda player_gold
    cmp #100
    bcs afford_wedding
    ldx #0
no_wedding_gold_loop:
        lda no_wedding_gold_msg,X
        beq no_wedding_gold_done
        jsr modem_out
        inx
        bne no_wedding_gold_loop
no_wedding_gold_done:
    jsr modem_in
    jmp romance_menu
afford_wedding:
    lda player_gold
    sec
    sbc #100
    sta player_gold
    lda #4
    sta courtship_stage
    lda #10
    sta romance_level
    ldx #0
wedding_ceremony_loop:
        lda wedding_ceremony_msg,X
        beq wedding_ceremony_done
        jsr modem_out
        inx
        bne wedding_ceremony_loop
wedding_ceremony_done:
    jsr modem_in
    jmp romance_menu

romance_header_msg:
    .text "\r\n=== ROMANCE & COURTSHIP ===\r\nLove blooms in the gardens of Everland...\r\n"
    .byte 0
partner_label_msg:
    .text "\r\nYour Beloved: "
    .byte 0
kira_name_msg:
    .text "Kira the Apothecary"
    .byte 0
lyra_name_msg:
    .text "Lyra of the Wolves"
    .byte 0
kendrick_name_msg:
    .text "Kendrick the Knight"
    .byte 0
bonny_name_msg:
    .text "Bonny Red Boots"
    .byte 0
level_label_msg:
    .text "\r\nAffection Level: "
    .byte 0
stage_label_msg:
    .text "/10  Stage: "
    .byte 0
introduced_msg:
    .text "Introduced"
    .byte 0
courting_msg:
    .text "Courting"
    .byte 0
engaged_msg:
    .text "Engaged!"
    .byte 0
married_msg:
    .text "MARRIED!"
    .byte 0
no_partner_msg:
    .text "\r\nYou have not yet found love in Everland..."
    .byte 0
romance_prompt_msg:
    .text "\r\n\r\n1. Meet Potential Partners\r\n2. Give Gift (-10g)\r\n3. Go on Date\r\n4. Propose\r\n5. Hold Wedding (-100g)\r\n0. Back\r\n> "
    .byte 0
meet_partners_msg:
    .text "\r\n--- CHOOSE YOUR HEART'S DESIRE ---\r\n\r\n1. Kira - The gentle apothecary with healing hands\r\n   'Her smile makes all aches feel remote...'\r\n\r\n2. Lyra - The fierce wolf of winter\r\n   'Seasoned, determined, loyal beyond measure...'\r\n\r\n3. Kendrick - The noble knight of Everland\r\n   'Honor guides his every action...'\r\n\r\n4. Bonny Red Boots - The free-spirited pirate\r\n   'Adventure flows through her veins...'\r\n\r\n0. Back\r\n> "
    .byte 0
partner_chosen_msg:
    .text "\r\nYou have expressed your interest! A new chapter begins...\r\n[Press any key]\r\n"
    .byte 0
need_partner_msg:
    .text "\r\nYou must first meet someone special!\r\n[Press any key]\r\n"
    .byte 0
no_gold_gift_msg:
    .text "\r\nYou need 10 gold for a gift!\r\n[Press any key]\r\n"
    .byte 0
gift_given_msg:
    .text "\r\nYour gift brings a smile! Affection grows...\r\n[Press any key]\r\n"
    .byte 0
not_courting_yet_msg:
    .text "\r\nReach affection level 5 to begin courting!\r\n[Press any key]\r\n"
    .byte 0
date_success_msg:
    .text "\r\nA wonderful time together! Your bond deepens...\r\n[Press any key]\r\n"
    .byte 0
rom_not_ready_msg:
    .text "\r\nYour love must be stronger! Reach level 8.\r\n[Press any key]\r\n"
    .byte 0
proposal_accept_msg:
    .text "\r\n'YES!' Your beloved accepts your proposal!\r\nYou are now ENGAGED!\r\n[Press any key]\r\n"
    .byte 0
already_engaged_msg:
    .text "\r\nYou are already engaged! Time for the wedding!\r\n[Press any key]\r\n"
    .byte 0
not_engaged_wed_msg:
    .text "\r\nYou must be engaged first!\r\n[Press any key]\r\n"
    .byte 0
no_wedding_gold_msg:
    .text "\r\nA proper wedding costs 100 gold!\r\n[Press any key]\r\n"
    .byte 0
wedding_ceremony_msg:
    .text "\r\n=== THE WEDDING CEREMONY ===\r\n\r\nBells ring across Everland as you exchange vows in the Rose Gardens.\r\nBishop Cordelia officiates the sacred union.\r\n\r\n'By the light of Aurora and the wisdom of the ancients,\r\nI pronounce you bound in love eternal!'\r\n\r\nGuests cheer! Flowers rain from above!\r\n\r\nYou are now MARRIED! May your love endure all trials!\r\n\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// DREAM SYSTEM
// ============================================

dream_menu:
    ldx #0
dream_header_loop:
        lda dream_header_msg,X
        beq dream_header_done
        jsr modem_out
        inx
        bne dream_header_loop
dream_header_done:
    // Show dream stats
    ldx #0
dreams_had_loop:
        lda dreams_had_label,X
        beq dreams_had_num
        jsr modem_out
        inx
        bne dreams_had_loop
dreams_had_num:
    lda dreams_had
    jsr print_byte_decimal
    ldx #0
nightmares_loop:
        lda nightmares_label,X
        beq nightmares_num
        jsr modem_out
        inx
        bne nightmares_loop
nightmares_num:
    lda nightmares_survived
    jsr print_byte_decimal
    ldx #0
prophecies_loop:
        lda prophecies_label,X
        beq prophecies_num
        jsr modem_out
        inx
        bne prophecies_loop
prophecies_num:
    lda prophecies_received
    jsr print_byte_decimal
    ldx #0
veylan_inf_loop:
        lda veylan_inf_label,X
        beq veylan_inf_num
        jsr modem_out
        inx
        bne veylan_inf_loop
veylan_inf_num:
    lda veylan_influence
    jsr print_byte_decimal
    ldx #0
dream_prompt_loop:
        lda dream_prompt_msg,X
        beq dream_wait_key
        jsr modem_out
        inx
        bne dream_prompt_loop
dream_wait_key:
    jsr modem_in
    cmp #'1'
    beq go_enter_dream
    cmp #'2'
    beq go_view_prophecy
    cmp #'3'
    beq go_dream_lore
    cmp #'0'
    bne dream_wait_key
    jmp main_loop
go_enter_dream:
    jmp enter_dream
go_view_prophecy:
    jmp view_prophecy
go_dream_lore:
    jmp show_dream_lore

enter_dream:
    // Random dream type
    jsr get_random
    and #$03
    sta last_dream_type
    inc dreams_had
    cmp #0
    bne not_peaceful_dream
    jmp peaceful_dream
not_peaceful_dream:
    cmp #1
    bne not_nightmare_dream
    jmp nightmare_dream
not_nightmare_dream:
    cmp #2
    bne prophetic_dream
    jmp memory_dream
prophetic_dream:
    inc prophecies_received
    ldx #0
prophecy_dream_loop:
        lda prophecy_dream_msg,X
        beq prophecy_dream_done
        jsr modem_out
        inx
        bne prophecy_dream_loop
prophecy_dream_done:
    jsr modem_in
    jmp dream_menu

peaceful_dream:
    // Restore some mana/health
    lda player_mana
    clc
    adc #5
    cmp player_max_mana
    bcc peaceful_mana_ok
    lda player_max_mana
peaceful_mana_ok:
    sta player_mana
    ldx #0
peaceful_dream_loop:
        lda peaceful_dream_msg,X
        beq peaceful_dream_done
        jsr modem_out
        inx
        bne peaceful_dream_loop
peaceful_dream_done:
    jsr modem_in
    jmp dream_menu

nightmare_dream:
    // Battle Veylan's influence
    inc veylan_influence
    lda dream_protection
    beq no_protection
    dec dream_protection
    jmp nightmare_protected
no_protection:
    lda veylan_influence
    cmp #10
    bcc nightmare_survived
    // Veylan wins - major penalty
    lda #0
    sta veylan_influence
    lda player_gold
    cmp #20
    bcc no_gold_loss
    sec
    sbc #20
    sta player_gold
no_gold_loss:
    ldx #0
nightmare_fail_loop:
        lda nightmare_fail_msg,X
        beq nightmare_fail_done
        jsr modem_out
        inx
        bne nightmare_fail_loop
nightmare_fail_done:
    jsr modem_in
    jmp dream_menu
nightmare_survived:
    inc nightmares_survived
    lda player_gold
    clc
    adc #15
    sta player_gold
    ldx #0
nightmare_win_loop:
        lda nightmare_win_msg,X
        beq nightmare_win_done
        jsr modem_out
        inx
        bne nightmare_win_loop
nightmare_win_done:
    jsr modem_in
    jmp dream_menu
nightmare_protected:
    inc nightmares_survived
    ldx #0
nightmare_prot_loop:
        lda nightmare_prot_msg,X
        beq nightmare_prot_done
        jsr modem_out
        inx
        bne nightmare_prot_loop
nightmare_prot_done:
    jsr modem_in
    jmp dream_menu

memory_dream:
    ldx #0
memory_dream_loop:
        lda memory_dream_msg,X
        beq memory_dream_done
        jsr modem_out
        inx
        bne memory_dream_loop
memory_dream_done:
    jsr modem_in
    jmp dream_menu

view_prophecy:
    lda prophecies_received
    bne has_prophecies
    ldx #0
no_prophecy_loop:
        lda no_prophecy_msg,X
        beq no_prophecy_done
        jsr modem_out
        inx
        bne no_prophecy_loop
no_prophecy_done:
    jsr modem_in
    jmp dream_menu
has_prophecies:
    ldx #0
show_prophecy_loop:
        lda show_prophecy_msg,X
        beq show_prophecy_done
        jsr modem_out
        inx
        bne show_prophecy_loop
show_prophecy_done:
    jsr modem_in
    jmp dream_menu

show_dream_lore:
    ldx #0
dream_lore_loop:
        lda dream_lore_msg,X
        beq dream_lore_done
        jsr modem_out
        inx
        bne dream_lore_loop
dream_lore_done:
    jsr modem_in
    jmp dream_menu

dream_header_msg:
    .text "\r\n=== THE REALM OF DREAMS ===\r\nWhere Veylan's shadow reaches even the sleeping...\r\n"
    .byte 0
dreams_had_label:
    .text "\r\nDreams Experienced: "
    .byte 0
nightmares_label:
    .text "  Nightmares Survived: "
    .byte 0
prophecies_label:
    .text "\r\nProphecies Received: "
    .byte 0
veylan_inf_label:
    .text "  Veylan's Influence: "
    .byte 0
dream_prompt_msg:
    .text "/10\r\n\r\n1. Enter the Dreamscape\r\n2. View Prophecies\r\n3. Dream Lore\r\n0. Back\r\n> "
    .byte 0
peaceful_dream_msg:
    .text "\r\n--- A PEACEFUL DREAM ---\r\n\r\nYou drift through fields of silver flowers under a violet sky.\r\nThe Frost Weaver Queen's voice echoes softly: 'Rest, child of Everland...'\r\n\r\nYou awaken refreshed. +5 Mana restored!\r\n\r\n[Press any key]\r\n"
    .byte 0
prophecy_dream_msg:
    .text "\r\n--- A PROPHETIC VISION ---\r\n\r\nYou stand before the shattered Moon Portal. A figure in shadows speaks:\r\n'The Dragon Lantern Festival approaches... Old bonds will be tested.'\r\n'The one who holds the memory stone shall face a choice.'\r\n'Trust not the path most traveled.'\r\n\r\nYou wake with a sense of foreboding...\r\n\r\n[Press any key]\r\n"
    .byte 0
nightmare_win_msg:
    .text "\r\n--- NIGHTMARE BATTLE ---\r\n\r\nVeylan's dark tendrils reach for your mind!\r\nYou struggle against the void, channeling your will...\r\n\r\nWith a burst of light, you break free!\r\n+15 gold from dream treasures!\r\n\r\n[Press any key]\r\n"
    .byte 0
nightmare_fail_msg:
    .text "\r\n--- NIGHTMARE DEFEAT ---\r\n\r\nVeylan's corruption overwhelms you!\r\n'Your memories are MINE,' the darkness whispers...\r\n\r\nYou wake in cold sweat. -20 gold lost to the void!\r\nVeylan's influence resets.\r\n\r\n[Press any key]\r\n"
    .byte 0
nightmare_prot_msg:
    .text "\r\n--- PROTECTED DREAM ---\r\n\r\nVeylan's shadows reach for you, but a ward flares!\r\nThe protection charm absorbs the attack!\r\n\r\nYou wake safely. Protection consumed.\r\n\r\n[Press any key]\r\n"
    .byte 0
memory_dream_msg:
    .text "\r\n--- MEMORY FRAGMENT ---\r\n\r\nYou see flashes of a life before the portal:\r\n- A castle with golden spires\r\n- Faces of loved ones, now forgotten\r\n- The moment the fog swept your memories away\r\n\r\nWho were you before Everland?\r\n\r\n[Press any key]\r\n"
    .byte 0
no_prophecy_msg:
    .text "\r\nNo prophecies received yet. Enter the dreamscape to seek visions.\r\n[Press any key]\r\n"
    .byte 0
show_prophecy_msg:
    .text "\r\n--- YOUR PROPHECIES ---\r\n\r\nThe ancient seers have shown you glimpses:\r\n\r\n* 'When dragon fire meets frost, a champion rises'\r\n* 'The Spider Princess weaves fate's final thread'\r\n* 'Memory is the key that unlocks all doors'\r\n* 'Veylan's shadow grows with each forgotten dream'\r\n\r\n[Press any key]\r\n"
    .byte 0
dream_lore_msg:
    .text "\r\n--- DREAM LORE ---\r\n\r\nThe Dreamscape is where Veylan's influence is strongest.\r\nWhen refugees fled through the portal, their memories became\r\nvulnerable to the shadow's reach.\r\n\r\nDream Types:\r\n- Peaceful: Restore mana and find tranquility\r\n- Nightmare: Battle Veylan for rewards (risky!)\r\n- Prophetic: Receive visions of future events\r\n- Memory: Glimpse your forgotten past\r\n\r\nPendulum mastery provides dream protection.\r\n\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// SHIP TRAVEL SYSTEM
// ============================================

ship_menu:
    ldx #0
ship_header_loop:
        lda ship_header_msg,X
        beq ship_header_done
        jsr modem_out
        inx
        bne ship_header_loop
ship_header_done:
    // Show current port
    ldx #0
port_label_loop:
        lda port_label_msg,X
        beq show_port_name
        jsr modem_out
        inx
        bne port_label_loop
show_port_name:
    lda current_port
    cmp #0
    bne not_everland_port
    ldx #0
everland_port_loop:
        lda everland_port_msg,X
        beq show_voyages
        jsr modem_out
        inx
        bne everland_port_loop
not_everland_port:
    cmp #1
    bne not_aurora_port
    ldx #0
aurora_port_loop:
        lda aurora_port_msg,X
        beq show_voyages
        jsr modem_out
        inx
        bne aurora_port_loop
not_aurora_port:
    cmp #2
    bne not_mythos_port
    ldx #0
mythos_port_loop:
        lda mythos_port_msg,X
        beq show_voyages
        jsr modem_out
        inx
        bne mythos_port_loop
not_mythos_port:
    ldx #0
england_port_loop:
        lda england_port_msg,X
        beq show_voyages
        jsr modem_out
        inx
        bne england_port_loop
show_voyages:
    ldx #0
voyages_label_loop:
        lda voyages_label_msg,X
        beq voyages_num
        jsr modem_out
        inx
        bne voyages_label_loop
voyages_num:
    lda voyages_completed
    jsr print_byte_decimal
    ldx #0
ship_prompt_loop:
        lda ship_prompt_msg,X
        beq ship_wait_key
        jsr modem_out
        inx
        bne ship_prompt_loop
ship_wait_key:
    jsr modem_in
    cmp #'1'
    beq go_set_sail
    cmp #'2'
    beq go_trade_goods
    cmp #'3'
    beq go_ship_lore
    cmp #'0'
    bne ship_wait_key
    jmp main_loop
go_set_sail:
    jmp set_sail
go_trade_goods:
    jmp trade_goods
go_ship_lore:
    jmp show_ship_lore

set_sail:
    lda player_gold
    cmp #25
    bcs afford_voyage
    ldx #0
no_voyage_gold_loop:
        lda no_voyage_gold_msg,X
        beq no_voyage_gold_done
        jsr modem_out
        inx
        bne no_voyage_gold_loop
no_voyage_gold_done:
    jsr modem_in
    jmp ship_menu
afford_voyage:
    ldx #0
dest_menu_loop:
        lda dest_menu_msg,X
        beq dest_wait_key
        jsr modem_out
        inx
        bne dest_menu_loop
dest_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_sail_everland
    lda #0
    jmp sail_to_port
not_sail_everland:
    cmp #'2'
    bne not_sail_aurora
    lda #1
    jmp sail_to_port
not_sail_aurora:
    cmp #'3'
    bne not_sail_mythos
    lda #2
    jmp sail_to_port
not_sail_mythos:
    cmp #'4'
    bne not_sail_england
    lda #3
    jmp sail_to_port
not_sail_england:
    cmp #'0'
    bne dest_wait_key
    jmp ship_menu
sail_to_port:
    sta current_port
    lda player_gold
    sec
    sbc #25
    sta player_gold
    inc voyages_completed
    // Check for sea encounter
    jsr get_random
    and #$03
    cmp #0
    beq sea_encounter
    jmp voyage_success
sea_encounter:
    inc sea_encounters
    jsr get_random
    and #$01
    beq pirate_encounter
    // Storm encounter
    ldx #0
storm_enc_loop:
        lda storm_enc_msg,X
        beq storm_enc_done
        jsr modem_out
        inx
        bne storm_enc_loop
storm_enc_done:
    jsr modem_in
    jmp ship_menu
pirate_encounter:
    ldx #0
pirate_enc_loop:
        lda pirate_enc_msg,X
        beq pirate_enc_done
        jsr modem_out
        inx
        bne pirate_enc_loop
pirate_enc_done:
    // Reward gold
    lda player_gold
    clc
    adc #30
    sta player_gold
    jsr modem_in
    jmp ship_menu
voyage_success:
    ldx #0
voyage_ok_loop:
        lda voyage_ok_msg,X
        beq voyage_ok_done
        jsr modem_out
        inx
        bne voyage_ok_loop
voyage_ok_done:
    jsr modem_in
    jmp ship_menu

trade_goods:
    ldx #0
ship_trade_menu_loop:
        lda ship_trade_menu_msg,X
        beq ship_trade_wait_key
        jsr modem_out
        inx
        bne ship_trade_menu_loop
ship_trade_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_buy_spices
    lda player_gold
    cmp #20
    bcs can_buy_spices
    jmp ship_trade_no_gold
can_buy_spices:
    sec
    sbc #20
    sta player_gold
    lda #1
    sta cargo_hold
    lda #5
    sta cargo_amount
    jmp ship_trade_bought
not_buy_spices:
    cmp #'2'
    bne not_buy_silk
    lda player_gold
    cmp #30
    bcs can_buy_silk
    jmp ship_trade_no_gold
can_buy_silk:
    sec
    sbc #30
    sta player_gold
    lda #2
    sta cargo_hold
    lda #3
    sta cargo_amount
    jmp ship_trade_bought
not_buy_silk:
    cmp #'3'
    bne not_sell_cargo
    lda cargo_amount
    beq no_cargo_sell
    // Sell cargo for profit
    lda cargo_hold
    cmp #1
    bne not_sell_spice
    lda cargo_amount
    asl
    asl
    asl
    clc
    adc player_gold
    sta player_gold
    jmp trade_sold
not_sell_spice:
    lda cargo_amount
    asl
    asl
    asl
    asl
    clc
    adc player_gold
    sta player_gold
trade_sold:
    lda #0
    sta cargo_hold
    sta cargo_amount
    ldx #0
sold_cargo_loop:
        lda sold_cargo_msg,X
        beq sold_cargo_done
        jsr modem_out
        inx
        bne sold_cargo_loop
sold_cargo_done:
    jsr modem_in
    jmp ship_menu
not_sell_cargo:
    cmp #'0'
    beq back_to_ship_menu
    jmp ship_trade_wait_key
back_to_ship_menu:
    jmp ship_menu
ship_trade_no_gold:
    ldx #0
ship_trade_no_gold_loop:
        lda ship_trade_no_gold_msg,X
        beq ship_trade_no_gold_done
        jsr modem_out
        inx
        bne ship_trade_no_gold_loop
ship_trade_no_gold_done:
    jsr modem_in
    jmp ship_menu
ship_trade_bought:
    ldx #0
ship_trade_bought_loop:
        lda ship_trade_bought_msg,X
        beq ship_trade_bought_done
        jsr modem_out
        inx
        bne ship_trade_bought_loop
ship_trade_bought_done:
    jsr modem_in
    jmp ship_menu
no_cargo_sell:
    ldx #0
no_cargo_loop:
        lda no_cargo_msg,X
        beq no_cargo_done
        jsr modem_out
        inx
        bne no_cargo_loop
no_cargo_done:
    jsr modem_in
    jmp ship_menu

show_ship_lore:
    ldx #0
ship_lore_loop:
        lda ship_lore_msg,X
        beq ship_lore_done
        jsr modem_out
        inx
        bne ship_lore_loop
ship_lore_done:
    jsr modem_in
    jmp ship_menu

ship_header_msg:
    .text "\r\n=== THE BLACK SIREN - SHIP TRAVEL ===\r\nCaptain Pit Plum welcomes you aboard!\r\n"
    .byte 0
port_label_msg:
    .text "\r\nCurrent Port: "
    .byte 0
everland_port_msg:
    .text "Everland Harbor"
    .byte 0
aurora_port_msg:
    .text "Aurora Ice Docks"
    .byte 0
mythos_port_msg:
    .text "Mythos Jungle Bay"
    .byte 0
england_port_msg:
    .text "Whitecastle Port"
    .byte 0
voyages_label_msg:
    .text "\r\nVoyages Completed: "
    .byte 0
ship_prompt_msg:
    .text "\r\n\r\n1. Set Sail (-25g)\r\n2. Trade Goods\r\n3. Ship Lore\r\n0. Back\r\n> "
    .byte 0
no_voyage_gold_msg:
    .text "\r\nA voyage costs 25 gold!\r\n[Press any key]\r\n"
    .byte 0
dest_menu_msg:
    .text "\r\n--- CHOOSE DESTINATION ---\r\n1. Everland Harbor\r\n2. Aurora Ice Docks\r\n3. Mythos Jungle Bay\r\n4. Whitecastle Port\r\n0. Cancel\r\n> "
    .byte 0
voyage_ok_msg:
    .text "\r\nSmooth sailing! You arrive safely at your destination.\r\n[Press any key]\r\n"
    .byte 0
storm_enc_msg:
    .text "\r\n--- STORM ENCOUNTER ---\r\nDark clouds gather as lightning splits the sky!\r\nThe crew battles the waves... but you weather the storm!\r\n\r\nYou arrive shaken but safe.\r\n[Press any key]\r\n"
    .byte 0
pirate_enc_msg:
    .text "\r\n--- PIRATE ENCOUNTER ---\r\nA rival ship approaches... Bonny Red Boots signals!\r\n'Ahoy! Friends of the Black Siren sail free!'\r\nShe gifts you 30 gold from a recent haul!\r\n\r\n+30 gold!\r\n[Press any key]\r\n"
    .byte 0
ship_trade_menu_msg:
    .text "\r\n--- TRADE GOODS ---\r\n1. Buy Spices (20g)\r\n2. Buy Silk (30g)\r\n3. Sell Cargo\r\n0. Back\r\n> "
    .byte 0
ship_trade_no_gold_msg:
    .text "\r\nNot enough gold for this purchase!\r\n[Press any key]\r\n"
    .byte 0
ship_trade_bought_msg:
    .text "\r\nCargo loaded! Sell at another port for profit!\r\n[Press any key]\r\n"
    .byte 0
sold_cargo_msg:
    .text "\r\nCargo sold! Profit added to your gold!\r\n[Press any key]\r\n"
    .byte 0
no_cargo_msg:
    .text "\r\nNo cargo to sell!\r\n[Press any key]\r\n"
    .byte 0
ship_lore_msg:
    .text "\r\n--- SHIP LORE ---\r\n\r\nThe Black Siren is captained by Pit Plum, a legend of the seas.\r\nWith Bonny Red Boots and Shadow Ford as crew, they sail\r\nbetween the ports of Everland's realms.\r\n\r\nPorts:\r\n- Everland Harbor: The main hub, best for selling\r\n- Aurora Ice Docks: Rare frost goods\r\n- Mythos Jungle Bay: Exotic spices and silk\r\n- Whitecastle Port: English luxuries\r\n\r\nBuy low, sail far, sell high!\r\n\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// CRAFTING SYSTEM
// ============================================

crafting_menu:
    ldx #0
craft_header_loop:
        lda craft_header_msg,X
        beq craft_header_done
        jsr modem_out
        inx
        bne craft_header_loop
craft_header_done:
    // Show materials
    ldx #0
wood_label_loop:
        lda wood_label_msg,X
        beq wood_label_done
        jsr modem_out
        inx
        bne wood_label_loop
wood_label_done:
    lda craft_wood
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    ldx #0
craft_stone_label_loop:
        lda craft_stone_label_msg,X
        beq craft_stone_label_done
        jsr modem_out
        inx
        bne craft_stone_label_loop
craft_stone_label_done:
    lda craft_stone
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    ldx #0
craft_gems_label_loop:
        lda craft_gems_label_msg,X
        beq craft_gems_label_done
        jsr modem_out
        inx
        bne craft_gems_label_loop
craft_gems_label_done:
    lda craft_gems
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    ldx #0
craft_cloth_label_loop:
        lda craft_cloth_label_msg,X
        beq craft_cloth_label_done
        jsr modem_out
        inx
        bne craft_cloth_label_loop
craft_cloth_label_done:
    lda craft_cloth
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Show recipes
    ldx #0
craft_options_loop:
        lda craft_options_msg,X
        beq craft_options_done
        jsr modem_out
        inx
        bne craft_options_loop
craft_options_done:
    jsr modem_in
    cmp #'1'
    beq go_craft_shelf
    cmp #'2'
    beq go_craft_statue
    cmp #'3'
    beq go_craft_tapestry
    cmp #'4'
    beq go_craft_crown
    cmp #'5'
    beq go_gather_materials
    cmp #'0'
    beq go_back_craft
    jmp crafting_menu
go_craft_shelf:
    jmp craft_shelf
go_craft_statue:
    jmp craft_statue
go_craft_tapestry:
    jmp craft_tapestry
go_craft_crown:
    jmp craft_crown
go_gather_materials:
    jmp gather_materials
go_back_craft:
    jmp user_room_menu

craft_header_msg:
    .text "\r\n=== CRAFTING ===\r\nMaterials:\r\n"
wood_label_msg:
    .text "Wood: "
craft_stone_label_msg:
    .text "Stone: "
craft_gems_label_msg:
    .text "Gems: "
craft_cloth_label_msg:
    .text "Cloth: "
craft_options_msg:
    .text "\r\nRecipes:\r\n1. Wood Shelf (3 wood)\r\n2. Stone Statue (4 stone, 1 gem)\r\n3. Tapestry (5 cloth)\r\n4. Gem Crown (3 gems)\r\n5. Gather Materials\r\n0. Back\r\n> "

craft_shelf:
    // Need 3 wood
    lda craft_wood
    cmp #3
    bcs can_craft_shelf
    jmp not_enough_mats
can_craft_shelf:
    lda craft_wood
    sec
    sbc #3
    sta craft_wood
    ldx #0
shelf_made_loop:
        lda shelf_made_msg,X
        beq shelf_made_done
        jsr modem_out
        inx
        bne shelf_made_loop
shelf_made_done:
    jsr modem_in
    jmp crafting_menu

craft_statue:
    // Need 4 stone, 1 gem
    lda craft_stone
    cmp #4
    bcc not_enough_mats
    lda craft_gems
    cmp #1
    bcc not_enough_mats
    lda craft_stone
    sec
    sbc #4
    sta craft_stone
    dec craft_gems
    ldx #0
statue_made_loop:
        lda statue_made_msg,X
        beq statue_made_done
        jsr modem_out
        inx
        bne statue_made_loop
statue_made_done:
    jsr modem_in
    jmp crafting_menu

craft_tapestry:
    // Need 5 cloth
    lda craft_cloth
    cmp #5
    bcc not_enough_mats
    lda craft_cloth
    sec
    sbc #5
    sta craft_cloth
    ldx #0
tapestry_made_loop:
        lda tapestry_made_msg,X
        beq tapestry_made_done
        jsr modem_out
        inx
        bne tapestry_made_loop
tapestry_made_done:
    jsr modem_in
    jmp crafting_menu

craft_crown:
    // Need 3 gems
    lda craft_gems
    cmp #3
    bcc not_enough_mats
    lda craft_gems
    sec
    sbc #3
    sta craft_gems
    ldx #0
crown_made_loop:
        lda crown_made_msg,X
        beq crown_made_done
        jsr modem_out
        inx
        bne crown_made_loop
crown_made_done:
    jsr modem_in
    jmp crafting_menu

not_enough_mats:
    ldx #0
not_enough_mats_loop:
        lda not_enough_mats_msg,X
        beq not_enough_mats_done
        jsr modem_out
        inx
        bne not_enough_mats_loop
not_enough_mats_done:
    jsr modem_in
    jmp crafting_menu

shelf_made_msg:
    .text "\r\nWood Shelf crafted!\r\n[Press any key]\r\n"
statue_made_msg:
    .text "\r\nStone Statue crafted!\r\n[Press any key]\r\n"
tapestry_made_msg:
    .text "\r\nTapestry crafted!\r\n[Press any key]\r\n"
crown_made_msg:
    .text "\r\nGem Crown crafted!\r\n[Press any key]\r\n"
not_enough_mats_msg:
    .text "\r\nNot enough materials!\r\n[Press any key]\r\n"

gather_materials:
    ldx #0
gathering_loop:
        lda gathering_msg,X
        beq gathering_done
        jsr modem_out
        inx
        bne gathering_loop
gathering_done:
    // Random material
    jsr get_random
    and #3
    cmp #0
    bne not_gather_wood
    inc craft_wood
    inc craft_wood
    ldx #0
found_wood_loop:
        lda found_wood_msg,X
        beq found_wood_done
        jsr modem_out
        inx
        bne found_wood_loop
found_wood_done:
    jmp gather_finish
not_gather_wood:
    cmp #1
    bne not_gather_stone
    inc craft_stone
    inc craft_stone
    ldx #0
found_stone_loop:
        lda found_stone_msg,X
        beq found_stone_done
        jsr modem_out
        inx
        bne found_stone_loop
found_stone_done:
    jmp gather_finish
not_gather_stone:
    cmp #2
    bne gather_cloth
    // Rare gem find
    jsr get_random
    and #3
    bne gather_cloth
    inc craft_gems
    ldx #0
found_gem_loop:
        lda found_gem_msg,X
        beq found_gem_done
        jsr modem_out
        inx
        bne found_gem_loop
found_gem_done:
    jmp gather_finish
gather_cloth:
    inc craft_cloth
    inc craft_cloth
    ldx #0
found_cloth_loop:
        lda found_cloth_msg,X
        beq found_cloth_done
        jsr modem_out
        inx
        bne found_cloth_loop
found_cloth_done:
gather_finish:
    jsr modem_in
    jmp crafting_menu

gathering_msg:
    .text "\r\nYou search for materials...\r\n"
found_wood_msg:
    .text "Found 2 wood!\r\n[Press any key]\r\n"
found_stone_msg:
    .text "Found 2 stone!\r\n[Press any key]\r\n"
found_gem_msg:
    .text "Found a rare gem!\r\n[Press any key]\r\n"
found_cloth_msg:
    .text "Found 2 cloth!\r\n[Press any key]\r\n"

// ============================================
// REPUTATION SYSTEM
// ============================================

reputation_menu:
    ldx #0
rep_header_loop:
        lda rep_header_msg,X
        beq rep_header_done
        jsr modem_out
        inx
        bne rep_header_loop
rep_header_done:
    // Show current reputation
    ldx #0
rep_score_loop:
        lda rep_score_msg,X
        beq rep_score_done
        jsr modem_out
        inx
        bne rep_score_loop
rep_score_done:
    lda player_reputation
    jsr print_byte_decimal
    ldx #0
rep_100_loop:
        lda rep_100_msg,X
        beq rep_100_done
        jsr modem_out
        inx
        bne rep_100_loop
rep_100_done:
    // Show title
    ldx #0
rep_title_label_loop:
        lda rep_title_label_msg,X
        beq rep_title_label_done
        jsr modem_out
        inx
        bne rep_title_label_loop
rep_title_label_done:
    // Calculate title based on rep
    lda player_reputation
    cmp #80
    bcs title_hero
    cmp #60
    bcs title_trusted
    cmp #40
    bcs title_known
    cmp #20
    bcs title_newcomer
    jmp title_unknown
title_hero:
    lda #4
    jmp show_title
title_trusted:
    lda #3
    jmp show_title
title_known:
    lda #2
    jmp show_title
title_newcomer:
    lda #1
    jmp show_title
title_unknown:
    lda #0
show_title:
    sta rep_title_index
    asl
    asl
    asl
    asl
    tax
print_title_loop:
        lda rep_titles,X
        beq print_title_done
        jsr modem_out
        inx
        bne print_title_loop
print_title_done:
    lda #13
    jsr modem_out
    // Show options
    ldx #0
rep_options_loop:
        lda rep_options_msg,X
        beq rep_options_done
        jsr modem_out
        inx
        bne rep_options_loop
rep_options_done:
    jsr modem_in
    cmp #'1'
    beq go_do_good_deed
    cmp #'2'
    beq go_view_perks
    cmp #'3'
    beq go_donate_gold
    cmp #'4'
    beq go_view_factions
    cmp #'0'
    beq go_back_rep
    jmp reputation_menu
go_do_good_deed:
    jmp do_good_deed
go_view_perks:
    jmp view_perks
go_donate_gold:
    jmp donate_gold
go_view_factions:
    jmp view_factions
go_back_rep:
    jmp user_room_menu

rep_header_msg:
    .text "\r\n=== REPUTATION & FACTIONS ===\r\n"
rep_score_msg:
    .text "Overall reputation: "
rep_100_msg:
    .text "/100\r\n"
rep_title_label_msg:
    .text "Title: "
rep_options_msg:
    .text "\r\n1. Do Good Deed\r\n2. View Perks\r\n3. Donate Gold\r\n4. View Factions\r\n0. Back\r\n> "

rep_titles:
    .text "Unknown         "  // 0-19
    .text "Newcomer        "  // 20-39
    .text "Known           "  // 40-59
    .text "Trusted         "  // 60-79
    .text "Hero            "  // 80-100

do_good_deed:
    // Check if already done 3 today
    lda rep_deeds_today
    cmp #3
    bcc can_do_deed
    ldx #0
max_deeds_loop:
        lda max_deeds_msg,X
        beq max_deeds_done
        jsr modem_out
        inx
        bne max_deeds_loop
max_deeds_done:
    jsr modem_in
    jmp reputation_menu
can_do_deed:
    inc rep_deeds_today
    // Gain 2-5 rep
    jsr get_random
    and #3
    clc
    adc #2
    sta deed_rep_gain
    clc
    adc player_reputation
    cmp #100
    bcc rep_under_max
    lda #100
rep_under_max:
    sta player_reputation
    ldx #0
deed_done_loop:
        lda deed_done_msg,X
        beq deed_done_done
        jsr modem_out
        inx
        bne deed_done_loop
deed_done_done:
    lda deed_rep_gain
    jsr print_byte_decimal
    ldx #0
rep_suffix_loop:
        lda rep_suffix_msg,X
        beq rep_suffix_done
        jsr modem_out
        inx
        bne rep_suffix_loop
rep_suffix_done:
    jsr modem_in
    jmp reputation_menu

deed_rep_gain: .byte 0
max_deeds_msg:
    .text "\r\nMax 3 deeds per day!\r\n[Press any key]\r\n"
deed_done_msg:
    .text "\r\nGood deed done! +"
rep_suffix_msg:
    .text " rep\r\n[Press any key]\r\n"

view_perks:
    ldx #0
perks_header_loop:
        lda perks_header_msg,X
        beq perks_header_done
        jsr modem_out
        inx
        bne perks_header_loop
perks_header_done:
    ldx #0
perks_list_loop:
        lda perks_list_msg,X
        beq perks_list_done
        jsr modem_out
        inx
        bne perks_list_loop
perks_list_done:
    jsr modem_in
    jmp reputation_menu

perks_header_msg:
    .text "\r\n=== REPUTATION PERKS ===\r\n"
perks_list_msg:
    .text "20+ Newcomer: +1 daily gold\r\n40+ Known: Shop discount\r\n60+ Trusted: Extra lottery\r\n80+ Hero: VIP room access\r\n[Press any key]\r\n"

donate_gold:
    // Need 10 gold
    lda player_gold
    cmp #10
    bcs can_donate
    ldx #0
no_gold_donate_loop:
        lda no_gold_donate_msg,X
        beq no_gold_donate_done
        jsr modem_out
        inx
        bne no_gold_donate_loop
no_gold_donate_done:
    jsr modem_in
    jmp reputation_menu
can_donate:
    lda player_gold
    sec
    sbc #10
    sta player_gold
    // Gain 5 rep
    lda player_reputation
    clc
    adc #5
    cmp #100
    bcc donate_rep_ok
    lda #100
donate_rep_ok:
    sta player_reputation
    ldx #0
donated_loop:
        lda donated_msg,X
        beq donated_done
        jsr modem_out
        inx
        bne donated_loop
donated_done:
    jsr modem_in
    jmp reputation_menu

no_gold_donate_msg:
    .text "\r\nNeed 10 gold to donate!\r\n[Press any key]\r\n"
donated_msg:
    .text "\r\nDonated 10g! +5 rep\r\n[Press any key]\r\n"

view_factions:
    ldx #0
factions_hdr_loop:
        lda factions_hdr_msg,X
        beq factions_hdr_done
        jsr modem_out
        inx
        bne factions_hdr_loop
factions_hdr_done:
    // Show each faction standing
    ldx #0
frost_label_loop:
        lda frost_faction_msg,X
        beq frost_faction_done
        jsr modem_out
        inx
        bne frost_label_loop
frost_faction_done:
    lda rep_frost_weavers
    jsr print_byte_decimal
    ldx #0
merchant_label_loop:
        lda merchant_faction_msg,X
        beq merchant_faction_done
        jsr modem_out
        inx
        bne merchant_label_loop
merchant_faction_done:
    lda rep_merchants
    jsr print_byte_decimal
    ldx #0
rose_label_loop:
        lda rose_faction_msg,X
        beq rose_faction_done
        jsr modem_out
        inx
        bne rose_label_loop
rose_faction_done:
    lda rep_black_rose
    jsr print_byte_decimal
    ldx #0
wolves_label_loop:
        lda wolves_faction_msg,X
        beq wolves_faction_done
        jsr modem_out
        inx
        bne wolves_label_loop
wolves_faction_done:
    lda rep_wolves
    jsr print_byte_decimal
    ldx #0
owls_label_loop:
        lda owls_faction_msg,X
        beq owls_faction_done
        jsr modem_out
        inx
        bne owls_label_loop
owls_faction_done:
    lda rep_owls
    jsr print_byte_decimal
    ldx #0
pirates_label_loop:
        lda pirates_faction_msg,X
        beq pirates_faction_done
        jsr modem_out
        inx
        bne pirates_label_loop
pirates_faction_done:
    lda rep_pirates
    jsr print_byte_decimal
    ldx #0
faction_key_loop:
        lda faction_key_msg,X
        beq faction_key_done
        jsr modem_out
        inx
        bne faction_key_loop
faction_key_done:
    jsr modem_in
    jmp reputation_menu

factions_hdr_msg:
    .text "\r\n=== FACTION STANDINGS ===\r\n"
    .byte 0
frost_faction_msg:
    .text "\r\nFrost Weavers: "
    .byte 0
merchant_faction_msg:
    .text "\r\nMerchant Guild: "
    .byte 0
rose_faction_msg:
    .text "\r\nOrder of Black Rose: "
    .byte 0
wolves_faction_msg:
    .text "\r\nWolves of Winter: "
    .byte 0
owls_faction_msg:
    .text "\r\nOrder of the Owls: "
    .byte 0
pirates_faction_msg:
    .text "\r\nBlack Siren Crew: "
    .byte 0
faction_key_msg:
    .text "\r\n\r\n0-25 = Hostile | 26-50 = Neutral\r\n51-75 = Friendly | 76-100 = Exalted\r\n\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// ACHIEVEMENTS SYSTEM
// ============================================

achievements_menu:
    ldx #0
achievements_hdr_loop:
        lda achievements_hdr_msg,X
        beq achievements_hdr_done
        jsr modem_out
        inx
        bne achievements_hdr_loop
achievements_hdr_done:
    // Show count
    ldx #0
achievements_cnt_loop:
        lda achievements_cnt_msg,X
        beq achievements_cnt_done
        jsr modem_out
        inx
        bne achievements_cnt_loop
achievements_cnt_done:
    lda achieve_count
    jsr print_byte_decimal
    ldx #0
achieve_8_loop:
        lda achieve_8_msg,X
        beq achieve_8_done
        jsr modem_out
        inx
        bne achieve_8_loop
achieve_8_done:
    // List achievements
    ldx #0
achieve_list_header_loop:
        lda achieve_list_header_msg,X
        beq achieve_list_header_done
        jsr modem_out
        inx
        bne achieve_list_header_loop
achieve_list_header_done:
    // Check each achievement
    lda #0
    sta achieve_check_idx
achieve_check_loop:
    lda achieve_check_idx
    cmp #8
    bcs achieve_list_end
    // Print number
    lda achieve_check_idx
    clc
    adc #'1'
    jsr modem_out
    lda #'.'
    jsr modem_out
    lda #' '
    jsr modem_out
    // Check if unlocked
    lda achieve_check_idx
    tax
    lda bit_masks,X
    and achieve_flags
    beq show_locked
    // Unlocked - show checkmark
    lda #'*'
    jsr modem_out
    jmp show_achieve_name
show_locked:
    lda #'-'
    jsr modem_out
show_achieve_name:
    lda #' '
    jsr modem_out
    // Print achievement name
    lda achieve_check_idx
    asl
    asl
    asl
    asl
    tax
print_achieve_name_loop:
        lda achieve_names,X
        beq print_achieve_name_done
        jsr modem_out
        inx
        bne print_achieve_name_loop
print_achieve_name_done:
    lda #13
    jsr modem_out
    inc achieve_check_idx
    jmp achieve_check_loop
achieve_list_end:
    // Options
    ldx #0
achieve_options_loop:
        lda achieve_options_msg,X
        beq achieve_options_done
        jsr modem_out
        inx
        bne achieve_options_loop
achieve_options_done:
    jsr modem_in
    cmp #'1'
    beq go_check_progress
    cmp #'2'
    beq go_claim_rewards
    cmp #'0'
    beq go_back_achieve
    jmp achievements_menu
go_check_progress:
    jmp check_achieve_progress
go_claim_rewards:
    jmp claim_achieve_rewards
go_back_achieve:
    jmp user_room_menu

achieve_check_idx: .byte 0
bit_masks: .byte 1, 2, 4, 8, 16, 32, 64, 128

achievements_hdr_msg:
    .text "\r\n=== ACHIEVEMENTS ===\r\n"
achievements_cnt_msg:
    .text "Unlocked: "
achieve_8_msg:
    .text "/8\r\n"
achieve_list_header_msg:
    .text "\r\n"
achieve_options_msg:
    .text "\r\n1. Check Progress\r\n2. Claim Rewards\r\n0. Back\r\n> "

achieve_names:
    .text "First Visit     "  // 0
    .text "100 Gold        "  // 1
    .text "10 Friends      "  // 2
    .text "Max Reputation  "  // 3
    .text "Craft Master    "  // 4
    .text "Pet Owner       "  // 5
    .text "Lottery Winner  "  // 6
    .text "Master Trader   "  // 7

check_achieve_progress:
    // Auto-check and unlock achievements
    // First Visit - always unlocked
    lda achieve_flags
    ora #1
    sta achieve_flags
    // 100 Gold check
    lda player_gold
    cmp #100
    bcc skip_gold_achieve
    lda achieve_flags
    ora #2
    sta achieve_flags
skip_gold_achieve:
    // Max Rep check
    lda player_reputation
    cmp #100
    bcc skip_rep_achieve
    lda achieve_flags
    ora #8
    sta achieve_flags
skip_rep_achieve:
    // Pet Owner check
    lda pet_owned
    beq skip_pet_achieve
    lda achieve_flags
    ora #32
    sta achieve_flags
skip_pet_achieve:
    // Count achievements
    lda #0
    sta achieve_count
    lda achieve_flags
    ldx #8
count_achieve_loop:
    lsr
    bcc no_inc_count
    inc achieve_count
no_inc_count:
    dex
    bne count_achieve_loop
    ldx #0
progress_checked_loop:
        lda progress_checked_msg,X
        beq progress_checked_done
        jsr modem_out
        inx
        bne progress_checked_loop
progress_checked_done:
    jsr modem_in
    jmp achievements_menu

progress_checked_msg:
    .text "\r\nProgress checked!\r\n[Press any key]\r\n"

claim_achieve_rewards:
    // 5 gold per achievement
    lda achieve_count
    beq no_rewards
    asl
    asl
    clc
    adc achieve_count  // count * 5
    clc
    adc player_gold
    sta player_gold
    ldx #0
rewards_claimed_loop:
        lda rewards_claimed_msg,X
        beq rewards_claimed_done
        jsr modem_out
        inx
        bne rewards_claimed_loop
rewards_claimed_done:
    lda achieve_count
    asl
    asl
    clc
    adc achieve_count
    jsr print_byte_decimal
    ldx #0
rewards_suffix_loop:
        lda rewards_suffix_msg,X
        beq rewards_suffix_done
        jsr modem_out
        inx
        bne rewards_suffix_loop
rewards_suffix_done:
    jsr modem_in
    jmp achievements_menu
no_rewards:
    ldx #0
no_rewards_loop:
        lda no_rewards_msg,X
        beq no_rewards_done
        jsr modem_out
        inx
        bne no_rewards_loop
no_rewards_done:
    jsr modem_in
    jmp achievements_menu

rewards_claimed_msg:
    .text "\r\nRewards claimed: "
rewards_suffix_msg:
    .text "g\r\n[Press any key]\r\n"
no_rewards_msg:
    .text "\r\nNo achievements yet!\r\n[Press any key]\r\n"

// ============================================
// GUILDS SYSTEM
// ============================================

guilds_menu:
    ldx #0
guilds_header_loop:
        lda guilds_header_msg,X
        beq guilds_header_done
        jsr modem_out
        inx
        bne guilds_header_loop
guilds_header_done:
    // Check if in a guild
    lda player_guild
    beq not_in_guild
    jmp show_guild_status
not_in_guild:
    // Not in guild - show join options
    ldx #0
no_guild_loop:
        lda no_guild_msg,X
        beq no_guild_done
        jsr modem_out
        inx
        bne no_guild_loop
no_guild_done:
    ldx #0
join_options_loop:
        lda join_options_msg,X
        beq join_options_done
        jsr modem_out
        inx
        bne join_options_loop
join_options_done:
    jsr modem_in
    cmp #'1'
    beq join_guild_1
    cmp #'2'
    beq join_guild_2
    cmp #'3'
    beq join_guild_3
    cmp #'4'
    beq join_guild_4
    cmp #'5'
    beq join_guild_5
    cmp #'6'
    beq join_guild_6
    cmp #'7'
    beq join_guild_7
    cmp #'8'
    beq join_guild_8
    cmp #'9'
    beq join_guild_9
    cmp #'A'
    beq join_guild_10
    cmp #'B'
    beq join_guild_11
    cmp #'C'
    beq join_guild_12
    cmp #'D'
    beq join_guild_13
    cmp #'E'
    beq join_guild_14
    cmp #'F'
    beq join_guild_15
    cmp #'0'
    beq go_back_guilds
    jmp guilds_menu
join_guild_1:
    lda #1
    jmp do_join_guild
join_guild_2:
    lda #2
    jmp do_join_guild
join_guild_3:
    lda #3
    jmp do_join_guild
join_guild_4:
    lda #4
    jmp do_join_guild
join_guild_5:
    lda #5
    jmp do_join_guild
join_guild_6:
    lda #6
    jmp do_join_guild
join_guild_7:
    lda #7
    jmp do_join_guild
join_guild_8:
    lda #8
    jmp do_join_guild
join_guild_9:
    lda #9
    jmp do_join_guild
join_guild_10:
    lda #10
    jmp do_join_guild
join_guild_11:
    lda #11
    jmp do_join_guild
join_guild_12:
    lda #12
    jmp do_join_guild
join_guild_13:
    lda #13
    jmp do_join_guild
join_guild_14:
    lda #14
    jmp do_join_guild
join_guild_15:
    lda #15
do_join_guild:
    sta player_guild
    lda #0
    sta guild_rank
    sta guild_contrib
    ldx #0
joined_guild_loop:
        lda joined_guild_msg,X
        beq joined_guild_done
        jsr modem_out
        inx
        bne joined_guild_loop
joined_guild_done:
    jsr modem_in
    jmp guilds_menu
go_back_guilds:
    jmp user_room_menu

show_guild_status:
    // Show current guild
    ldx #0
your_guild_loop:
        lda your_guild_msg,X
        beq your_guild_done
        jsr modem_out
        inx
        bne your_guild_loop
your_guild_done:
    lda player_guild
    sec
    sbc #1
    asl
    asl
    asl
    asl
    tax
print_guild_name_loop:
        lda guild_names,X
        beq print_guild_name_done
        jsr modem_out
        inx
        bne print_guild_name_loop
print_guild_name_done:
    lda #13
    jsr modem_out
    // Show rank
    ldx #0
rank_label_loop:
        lda rank_label_msg,X
        beq rank_label_done
        jsr modem_out
        inx
        bne rank_label_loop
rank_label_done:
    lda guild_rank
    asl
    asl
    asl
    asl
    tax
print_rank_loop:
        lda rank_names,X
        beq print_rank_done
        jsr modem_out
        inx
        bne print_rank_loop
print_rank_done:
    lda #13
    jsr modem_out
    // Show contribution
    ldx #0
contrib_label_loop:
        lda contrib_label_msg,X
        beq contrib_label_done
        jsr modem_out
        inx
        bne contrib_label_loop
contrib_label_done:
    lda guild_contrib
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Guild options
    ldx #0
guild_options_loop:
        lda guild_options_msg,X
        beq guild_options_done
        jsr modem_out
        inx
        bne guild_options_loop
guild_options_done:
    jsr modem_in
    cmp #'1'
    beq go_contribute_gold
    cmp #'2'
    beq go_guild_bonus
    cmp #'3'
    beq go_leave_guild
    cmp #'0'
    beq go_back_guilds2
    jmp guilds_menu
go_contribute_gold:
    jmp contribute_gold
go_guild_bonus:
    jmp guild_bonus
go_leave_guild:
    jmp leave_guild
go_back_guilds2:
    jmp user_room_menu

guilds_header_msg:
    .text "\r\n=== GUILDS ===\r\n"
no_guild_msg:
    .text "You are not in a guild.\r\n"
join_options_msg:
    .text "\r\n1. Warriors      2. Merchants\r\n3. Explorers     4. Crafters\r\n5. Mystics       6. Faeries\r\n7. Witches       8. Unseelie Fae\r\n9. Dragon Train  A. Pirates\r\nB. Knights       C. Rogues\r\nD. Frost Weaver  E. Black Rose\r\nF. Mages         0. Back\r\n> "
joined_guild_msg:
    .text "\r\nWelcome to the guild!\r\n[Press any key]\r\n"
your_guild_msg:
    .text "Your Guild: "
rank_label_msg:
    .text "Rank: "
contrib_label_msg:
    .text "Contribution: "
guild_options_msg:
    .text "\r\n1. Contribute (10g)\r\n2. Guild Bonus\r\n3. Leave Guild\r\n0. Back\r\n> "

guild_names:
    .text "Warriors        "  // 1
    .text "Merchants       "  // 2
    .text "Explorers       "  // 3
    .text "Crafters        "  // 4
    .text "Mystics         "  // 5
    .text "Faeries         "  // 6
    .text "Witches         "  // 7
    .text "Unseelie Fae    "  // 8
    .text "Dragon Trainers "  // 9
    .text "Pirates         "  // 10
    .text "Knights         "  // 11
    .text "Rogues          "  // 12
    .text "Frost Weavers   "  // 13
    .text "Black Rose      "  // 14
    .text "Mages           "  // 15

rank_names:
    .text "Member          "  // 0
    .text "Officer         "  // 1
    .text "Leader          "  // 2

contribute_gold:
    // Need 10 gold
    lda player_gold
    cmp #10
    bcs can_contribute
    ldx #0
no_gold_contrib_loop:
        lda no_gold_contrib_msg,X
        beq no_gold_contrib_done
        jsr modem_out
        inx
        bne no_gold_contrib_loop
no_gold_contrib_done:
    jsr modem_in
    jmp guilds_menu
can_contribute:
    lda player_gold
    sec
    sbc #10
    sta player_gold
    lda guild_contrib
    clc
    adc #10
    sta guild_contrib
    // Check for rank up
    cmp #50
    bcc no_rank_up
    lda guild_rank
    cmp #2
    bcs no_rank_up
    inc guild_rank
    ldx #0
rank_up_loop:
        lda rank_up_msg,X
        beq rank_up_done
        jsr modem_out
        inx
        bne rank_up_loop
rank_up_done:
    jsr modem_in
    jmp guilds_menu
no_rank_up:
    ldx #0
contributed_loop:
        lda contributed_msg,X
        beq contributed_done
        jsr modem_out
        inx
        bne contributed_loop
contributed_done:
    jsr modem_in
    jmp guilds_menu

no_gold_contrib_msg:
    .text "\r\nNeed 10 gold!\r\n[Press any key]\r\n"
rank_up_msg:
    .text "\r\nContributed! RANK UP!\r\n[Press any key]\r\n"
contributed_msg:
    .text "\r\nContributed 10g!\r\n[Press any key]\r\n"

guild_bonus:
    // Bonus based on guild type
    lda player_guild
    // Gold guilds: Merchants(2), Pirates(10), Rogues(12)
    cmp #2
    beq gold_bonus
    cmp #10
    beq gold_bonus
    cmp #12
    beq gold_bonus
    jmp check_craft_guilds
gold_bonus:
    lda player_gold
    clc
    adc #5
    sta player_gold
    ldx #0
gold_bonus_loop:
        lda gold_bonus_msg,X
        beq gold_bonus_done
        jsr modem_out
        inx
        bne gold_bonus_loop
gold_bonus_done:
    jsr modem_in
    jmp guilds_menu
check_craft_guilds:
    // Craft guilds: Crafters(4), Witches(7), Frost Weavers(13), Mages(15)
    lda player_guild
    cmp #4
    beq craft_bonus
    cmp #7
    beq craft_bonus
    cmp #13
    beq craft_bonus
    cmp #15
    beq craft_bonus
    jmp check_pet_guilds
craft_bonus:
    inc craft_wood
    inc craft_stone
    inc craft_gems
    ldx #0
craft_bonus_loop:
        lda craft_bonus_msg,X
        beq craft_bonus_done
        jsr modem_out
        inx
        bne craft_bonus_loop
craft_bonus_done:
    jsr modem_in
    jmp guilds_menu
check_pet_guilds:
    // Pet guilds: Faeries(6), Dragon Trainers(9)
    lda player_guild
    cmp #6
    beq pet_bonus
    cmp #9
    beq pet_bonus
    jmp check_luck_guilds
pet_bonus:
    lda pet_happiness
    clc
    adc #2
    cmp #10
    bcc pet_happy_ok
    lda #10
pet_happy_ok:
    sta pet_happiness
    ldx #0
pet_bonus_loop:
        lda pet_bonus_msg,X
        beq pet_bonus_done
        jsr modem_out
        inx
        bne pet_bonus_loop
pet_bonus_done:
    jsr modem_in
    jmp guilds_menu
check_luck_guilds:
    // Luck guilds: Mystics(5), Unseelie(8)
    lda player_guild
    cmp #5
    beq luck_bonus
    cmp #8
    beq luck_bonus
    jmp rep_bonus
luck_bonus:
    inc lottery_tickets
    ldx #0
luck_bonus_loop:
        lda luck_bonus_msg,X
        beq luck_bonus_done
        jsr modem_out
        inx
        bne luck_bonus_loop
luck_bonus_done:
    jsr modem_in
    jmp guilds_menu
rep_bonus:
    // Rep guilds: Warriors(1), Explorers(3), Knights(11), Black Rose(14)
    lda player_reputation
    clc
    adc #3
    cmp #100
    bcc rep_bonus_ok
    lda #100
rep_bonus_ok:
    sta player_reputation
    ldx #0
rep_bonus_loop:
        lda rep_bonus_msg,X
        beq rep_bonus_done
        jsr modem_out
        inx
        bne rep_bonus_loop
rep_bonus_done:
    jsr modem_in
    jmp guilds_menu

gold_bonus_msg:
    .text "\r\nGuild bonus: +5 gold\r\n[Press any key]\r\n"
craft_bonus_msg:
    .text "\r\nGuild bonus: +1 each material\r\n[Press any key]\r\n"
pet_bonus_msg:
    .text "\r\nGuild bonus: +2 pet happiness\r\n[Press any key]\r\n"
luck_bonus_msg:
    .text "\r\nGuild bonus: +1 lottery ticket\r\n[Press any key]\r\n"
rep_bonus_msg:
    .text "\r\nGuild bonus: +3 reputation\r\n[Press any key]\r\n"

leave_guild:
    lda #0
    sta player_guild
    sta guild_rank
    sta guild_contrib
    ldx #0
left_guild_loop:
        lda left_guild_msg,X
        beq left_guild_done
        jsr modem_out
        inx
        bne left_guild_loop
left_guild_done:
    jsr modem_in
    jmp guilds_menu

left_guild_msg:
    .text "\r\nYou left the guild.\r\n[Press any key]\r\n"

// ============================================
// TITLES SYSTEM
// ============================================

titles_menu:
    ldx #0
titles_header_loop:
        lda titles_header_msg,X
        beq titles_header_done
        jsr modem_out
        inx
        bne titles_header_loop
titles_header_done:
    // Show current title
    ldx #0
current_title_loop:
        lda current_title_msg,X
        beq current_title_done
        jsr modem_out
        inx
        bne current_title_loop
current_title_done:
    lda equipped_honorific
    asl
    asl
    asl
    asl
    tax
print_cur_title_loop:
        lda title_names,X
        beq print_cur_title_done
        jsr modem_out
        inx
        bne print_cur_title_loop
print_cur_title_done:
    lda #13
    jsr modem_out
    // List all titles
    ldx #0
titles_list_header_loop:
        lda titles_list_header_msg,X
        beq titles_list_header_done
        jsr modem_out
        inx
        bne titles_list_header_loop
titles_list_header_done:
    lda #0
    sta title_check_idx
title_list_loop:
    lda title_check_idx
    cmp #8
    bcs title_list_end
    // Print number
    lda title_check_idx
    clc
    adc #'1'
    jsr modem_out
    lda #'.'
    jsr modem_out
    lda #' '
    jsr modem_out
    // Check if unlocked
    lda title_check_idx
    tax
    lda title_bit_masks,X
    and unlocked_titles
    beq show_title_locked
    lda #'*'
    jsr modem_out
    jmp show_title_name
show_title_locked:
    lda #'-'
    jsr modem_out
show_title_name:
    lda #' '
    jsr modem_out
    lda title_check_idx
    asl
    asl
    asl
    asl
    tax
print_title_name_loop:
        lda title_names,X
        beq print_title_name_done
        jsr modem_out
        inx
        bne print_title_name_loop
print_title_name_done:
    lda #13
    jsr modem_out
    inc title_check_idx
    jmp title_list_loop
title_list_end:
    // Options
    ldx #0
titles_options_loop:
        lda titles_options_msg,X
        beq titles_options_done
        jsr modem_out
        inx
        bne titles_options_loop
titles_options_done:
    jsr modem_in
    cmp #'1'
    beq go_equip_title
    cmp #'2'
    beq go_check_title_unlock
    cmp #'0'
    beq go_back_titles
    jmp titles_menu
go_equip_title:
    jmp equip_title
go_check_title_unlock:
    jmp check_title_unlock
go_back_titles:
    jmp user_room_menu

title_check_idx: .byte 0
title_bit_masks: .byte 1, 2, 4, 8, 16, 32, 64, 128

titles_header_msg:
    .text "\r\n=== TITLES ===\r\n"
current_title_msg:
    .text "Current: "
titles_list_header_msg:
    .text "\r\n"
titles_options_msg:
    .text "\r\n1. Equip Title\r\n2. Check Unlocks\r\n0. Back\r\n> "

title_names:
    .text "Newcomer        "  // 0 - default
    .text "Adventurer      "  // 1 - visit 5 rooms
    .text "Wealthy         "  // 2 - have 100g
    .text "Popular         "  // 3 - 5 friends
    .text "Crafter         "  // 4 - craft 3 items
    .text "Champion        "  // 5 - win minigame
    .text "Legend          "  // 6 - max rep
    .text "Master          "  // 7 - all badges

equip_title:
    ldx #0
equip_prompt_loop:
        lda equip_prompt_msg,X
        beq equip_prompt_done
        jsr modem_out
        inx
        bne equip_prompt_loop
equip_prompt_done:
    jsr modem_in
    sec
    sbc #'1'
    cmp #8
    bcs equip_invalid
    sta title_temp
    // Check if unlocked
    tax
    lda title_bit_masks,X
    and unlocked_titles
    beq title_not_unlocked
    lda title_temp
    sta equipped_honorific
    ldx #0
title_equipped_loop:
        lda title_equipped_msg,X
        beq title_equipped_done
        jsr modem_out
        inx
        bne title_equipped_loop
title_equipped_done:
    jsr modem_in
    jmp titles_menu
title_not_unlocked:
    ldx #0
title_locked_loop:
        lda title_locked_msg,X
        beq title_locked_done
        jsr modem_out
        inx
        bne title_locked_loop
title_locked_done:
    jsr modem_in
    jmp titles_menu
equip_invalid:
    jmp titles_menu

title_temp: .byte 0
equip_prompt_msg:
    .text "\r\nEquip which title (1-8)? "
title_equipped_msg:
    .text "\r\nTitle equipped!\r\n[Press any key]\r\n"
title_locked_msg:
    .text "\r\nTitle not unlocked!\r\n[Press any key]\r\n"

check_title_unlock:
    // Check various conditions and unlock titles
    // Wealthy - 100+ gold
    lda player_gold
    cmp #100
    bcc skip_wealthy_title
    lda unlocked_titles
    ora #4
    sta unlocked_titles
skip_wealthy_title:
    // Legend - max rep
    lda player_reputation
    cmp #100
    bcc skip_legend_title
    lda unlocked_titles
    ora #64
    sta unlocked_titles
skip_legend_title:
    // Pet owner unlocks Adventurer
    lda pet_owned
    beq skip_adventurer_title
    lda unlocked_titles
    ora #2
    sta unlocked_titles
skip_adventurer_title:
    ldx #0
titles_checked_loop:
        lda titles_checked_msg,X
        beq titles_checked_done
        jsr modem_out
        inx
        bne titles_checked_loop
titles_checked_done:
    jsr modem_in
    jmp titles_menu

titles_checked_msg:
    .text "\r\nTitles checked!\r\n[Press any key]\r\n"

// ============================================
// FORTUNE TELLER
// ============================================

fortune_menu:
    ldx #0
fortune_header_loop:
        lda fortune_header_msg,X
        beq fortune_header_done
        jsr modem_out
        inx
        bne fortune_header_loop
fortune_header_done:
    // Show options
    ldx #0
fortune_options_loop:
        lda fortune_options_msg,X
        beq fortune_options_done
        jsr modem_out
        inx
        bne fortune_options_loop
fortune_options_done:
    jsr modem_in
    cmp #'1'
    beq go_daily_fortune
    cmp #'2'
    beq go_lucky_number
    cmp #'3'
    beq go_crystal_ball
    cmp #'0'
    beq go_back_fortune
    jmp fortune_menu
go_daily_fortune:
    jmp daily_fortune
go_lucky_number:
    jmp show_lucky_number
go_crystal_ball:
    jmp crystal_ball
go_back_fortune:
    jmp user_room_menu

fortune_header_msg:
    .text "\r\n=== FORTUNE TELLER ===\r\n"
fortune_options_msg:
    .text "\r\n1. Daily Fortune (free)\r\n2. Lucky Number\r\n3. Crystal Ball (5g)\r\n0. Back\r\n> "

daily_fortune:
    // Check if already claimed
    lda fortune_claimed
    beq can_get_fortune
    ldx #0
already_fortune_loop:
        lda already_fortune_msg,X
        beq already_fortune_done
        jsr modem_out
        inx
        bne already_fortune_loop
already_fortune_done:
    jsr modem_in
    jmp fortune_menu
can_get_fortune:
    lda #1
    sta fortune_claimed
    // Random fortune
    jsr get_random
    and #7
    sta last_fortune
    asl
    asl
    asl
    asl
    asl
    tax
    ldx #0
your_fortune_loop:
        lda your_fortune_msg,X
        beq your_fortune_done
        jsr modem_out
        inx
        bne your_fortune_loop
your_fortune_done:
    lda last_fortune
    asl
    asl
    asl
    asl
    asl
    tax
print_fortune_loop:
        lda fortune_texts,X
        beq print_fortune_done
        jsr modem_out
        inx
        bne print_fortune_loop
print_fortune_done:
    lda #13
    jsr modem_out
    // Give small bonus based on fortune
    lda last_fortune
    cmp #0  // Great luck = gold
    bne not_great_luck
    lda player_gold
    clc
    adc #10
    sta player_gold
    ldx #0
fortune_bonus_loop:
        lda fortune_bonus_msg,X
        beq fortune_bonus_done
        jsr modem_out
        inx
        bne fortune_bonus_loop
fortune_bonus_done:
    jmp fortune_finish
not_great_luck:
    cmp #7  // Bad luck = nothing
    bne medium_luck
    ldx #0
bad_luck_loop:
        lda bad_luck_msg,X
        beq bad_luck_done
        jsr modem_out
        inx
        bne bad_luck_loop
bad_luck_done:
    jmp fortune_finish
medium_luck:
    // Other fortunes give 1-3 gold
    lda player_gold
    clc
    adc #2
    sta player_gold
fortune_finish:
    ldx #0
fortune_end_loop:
        lda fortune_end_msg,X
        beq fortune_end_done
        jsr modem_out
        inx
        bne fortune_end_loop
fortune_end_done:
    jsr modem_in
    jmp fortune_menu

already_fortune_msg:
    .text "\r\nCome back tomorrow!\r\n[Press any key]\r\n"
your_fortune_msg:
    .text "\r\nYour fortune: "
fortune_bonus_msg:
    .text "The stars bless you with 10g!\r\n"
bad_luck_msg:
    .text "Be careful today...\r\n"
fortune_end_msg:
    .text "[Press any key]\r\n"

fortune_texts:
    .text "Great fortune awaits!   "  // 0 - best
    .text "Love is in the air.    "  // 1
    .text "Wealth comes your way. "  // 2
    .text "A friend brings news.  "  // 3
    .text "Adventure calls you.   "  // 4
    .text "Trust your instincts.  "  // 5
    .text "Change is coming soon. "  // 6
    .text "Beware dark omens.     "  // 7 - worst

show_lucky_number:
    // Generate lucky number
    jsr get_random
    and #15
    clc
    adc #1
    sta lucky_number
    ldx #0
lucky_num_loop:
        lda lucky_num_msg,X
        beq lucky_num_done
        jsr modem_out
        inx
        bne lucky_num_loop
lucky_num_done:
    lda lucky_number
    jsr print_byte_decimal
    ldx #0
lucky_suffix_loop:
        lda lucky_suffix_msg,X
        beq lucky_suffix_done
        jsr modem_out
        inx
        bne lucky_suffix_loop
lucky_suffix_done:
    jsr modem_in
    jmp fortune_menu

lucky_num_msg:
    .text "\r\nYour lucky number: "
lucky_suffix_msg:
    .text "\r\n[Press any key]\r\n"

crystal_ball:
    // Costs 5 gold
    lda player_gold
    cmp #5
    bcs can_crystal
    ldx #0
no_gold_crystal_loop:
        lda no_gold_crystal_msg,X
        beq no_gold_crystal_done
        jsr modem_out
        inx
        bne no_gold_crystal_loop
no_gold_crystal_done:
    jsr modem_in
    jmp fortune_menu
can_crystal:
    lda player_gold
    sec
    sbc #5
    sta player_gold
    ldx #0
crystal_intro_loop:
        lda crystal_intro_msg,X
        beq crystal_intro_done
        jsr modem_out
        inx
        bne crystal_intro_loop
crystal_intro_done:
    // Random vision
    jsr get_random
    and #3
    asl
    asl
    asl
    asl
    asl
    tax
print_vision_loop:
        lda crystal_visions,X
        beq print_vision_done
        jsr modem_out
        inx
        bne print_vision_loop
print_vision_done:
    ldx #0
crystal_end_loop:
        lda crystal_end_msg,X
        beq crystal_end_done
        jsr modem_out
        inx
        bne crystal_end_loop
crystal_end_done:
    jsr modem_in
    jmp fortune_menu

no_gold_crystal_msg:
    .text "\r\nNeed 5 gold!\r\n[Press any key]\r\n"
crystal_intro_msg:
    .text "\r\nThe crystal glows...\r\n"
crystal_end_msg:
    .text "\r\n[Press any key]\r\n"

crystal_visions:
    .text "You see treasure ahead! "  // 0
    .text "A new friend appears... "  // 1
    .text "Danger lurks nearby...  "  // 2
    .text "The mists reveal nothing"  // 3

// ============================================
// GARDEN SYSTEM
// ============================================

garden_menu:
    ldx #0
garden_header_loop:
        lda garden_header_msg,X
        beq garden_header_done
        jsr modem_out
        inx
        bne garden_header_loop
garden_header_done:
    // Show plots
    ldx #0
plot1_label_loop:
        lda plot1_label_msg,X
        beq plot1_label_done
        jsr modem_out
        inx
        bne plot1_label_loop
plot1_label_done:
    lda garden_plot1
    jsr show_plot_status
    ldx #0
plot2_label_loop:
        lda plot2_label_msg,X
        beq plot2_label_done
        jsr modem_out
        inx
        bne plot2_label_loop
plot2_label_done:
    lda garden_plot2
    jsr show_plot_status
    ldx #0
plot3_label_loop:
        lda plot3_label_msg,X
        beq plot3_label_done
        jsr modem_out
        inx
        bne plot3_label_loop
plot3_label_done:
    lda garden_plot3
    jsr show_plot_status
    // Show seeds
    ldx #0
seeds_label_loop:
        lda seeds_label_msg,X
        beq seeds_label_done
        jsr modem_out
        inx
        bne seeds_label_loop
seeds_label_done:
    lda garden_seeds
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Options
    ldx #0
garden_options_loop:
        lda garden_options_msg,X
        beq garden_options_done
        jsr modem_out
        inx
        bne garden_options_loop
garden_options_done:
    jsr modem_in
    cmp #'1'
    beq go_plant_seed
    cmp #'2'
    beq go_water_garden
    cmp #'3'
    beq go_harvest_crops
    cmp #'4'
    beq go_buy_seeds
    cmp #'0'
    beq go_back_garden
    jmp garden_menu
go_plant_seed:
    jmp plant_seed
go_water_garden:
    jmp water_garden
go_harvest_crops:
    jmp harvest_crops
go_buy_seeds:
    jmp buy_seeds
go_back_garden:
    jmp user_room_menu

garden_header_msg:
    .text "\r\n=== GARDEN ===\r\n"
plot1_label_msg:
    .text "Plot 1: "
plot2_label_msg:
    .text "Plot 2: "
plot3_label_msg:
    .text "Plot 3: "
seeds_label_msg:
    .text "Seeds: "
garden_options_msg:
    .text "\r\n1. Plant Seed\r\n2. Water (daily)\r\n3. Harvest\r\n4. Buy Seeds (5g)\r\n0. Back\r\n> "

show_plot_status:
    // A = plot value
    cmp #0
    bne plot_not_empty
    ldx #0
empty_plot_loop:
        lda empty_plot_msg,X
        beq empty_plot_done
        jsr modem_out
        inx
        bne empty_plot_loop
empty_plot_done:
    rts
plot_not_empty:
    cmp #10
    bcs plot_ready
    // Growing
    ldx #0
growing_plot_loop:
        lda growing_plot_msg,X
        beq growing_plot_done
        jsr modem_out
        inx
        bne growing_plot_loop
growing_plot_done:
    rts
plot_ready:
    ldx #0
ready_plot_loop:
        lda ready_plot_msg,X
        beq ready_plot_done
        jsr modem_out
        inx
        bne ready_plot_loop
ready_plot_done:
    rts

empty_plot_msg:
    .text "[Empty]\r\n"
growing_plot_msg:
    .text "[Growing...]\r\n"
ready_plot_msg:
    .text "[READY!]\r\n"

plant_seed:
    // Check if have seeds
    lda garden_seeds
    bne have_seeds
    ldx #0
no_seeds_loop:
        lda no_seeds_msg,X
        beq no_seeds_done
        jsr modem_out
        inx
        bne no_seeds_loop
no_seeds_done:
    jsr modem_in
    jmp garden_menu
have_seeds:
    // Find empty plot
    lda garden_plot1
    beq plant_in_1
    lda garden_plot2
    beq plant_in_2
    lda garden_plot3
    beq plant_in_3
    // All full
    ldx #0
plots_full_loop:
        lda plots_full_msg,X
        beq plots_full_done
        jsr modem_out
        inx
        bne plots_full_loop
plots_full_done:
    jsr modem_in
    jmp garden_menu
plant_in_1:
    lda #1
    sta garden_plot1
    jmp seed_planted
plant_in_2:
    lda #1
    sta garden_plot2
    jmp seed_planted
plant_in_3:
    lda #1
    sta garden_plot3
seed_planted:
    dec garden_seeds
    ldx #0
planted_loop:
        lda planted_msg,X
        beq planted_done
        jsr modem_out
        inx
        bne planted_loop
planted_done:
    jsr modem_in
    jmp garden_menu

no_seeds_msg:
    .text "\r\nNo seeds!\r\n[Press any key]\r\n"
plots_full_msg:
    .text "\r\nAll plots full!\r\n[Press any key]\r\n"
planted_msg:
    .text "\r\nSeed planted!\r\n[Press any key]\r\n"

water_garden:
    // Check if already watered
    lda garden_water
    beq can_water
    ldx #0
already_watered_loop:
        lda already_watered_msg,X
        beq already_watered_done
        jsr modem_out
        inx
        bne already_watered_loop
already_watered_done:
    jsr modem_in
    jmp garden_menu
can_water:
    lda #1
    sta garden_water
    // Advance all growing plants
    lda garden_plot1
    beq skip_water_1
    cmp #10
    bcs skip_water_1
    clc
    adc #3
    cmp #10
    bcc water1_ok
    lda #11  // Ready
water1_ok:
    sta garden_plot1
skip_water_1:
    lda garden_plot2
    beq skip_water_2
    cmp #10
    bcs skip_water_2
    clc
    adc #3
    cmp #10
    bcc water2_ok
    lda #11
water2_ok:
    sta garden_plot2
skip_water_2:
    lda garden_plot3
    beq skip_water_3
    cmp #10
    bcs skip_water_3
    clc
    adc #3
    cmp #10
    bcc water3_ok
    lda #11
water3_ok:
    sta garden_plot3
skip_water_3:
    ldx #0
watered_loop:
        lda watered_msg,X
        beq watered_done
        jsr modem_out
        inx
        bne watered_loop
watered_done:
    jsr modem_in
    jmp garden_menu

already_watered_msg:
    .text "\r\nAlready watered today!\r\n[Press any key]\r\n"
watered_msg:
    .text "\r\nGarden watered! Crops grow.\r\n[Press any key]\r\n"

harvest_crops:
    lda #0
    sta harvest_count
    // Check each plot
    lda garden_plot1
    cmp #10
    bcc no_harvest_1
    lda #0
    sta garden_plot1
    inc harvest_count
no_harvest_1:
    lda garden_plot2
    cmp #10
    bcc no_harvest_2
    lda #0
    sta garden_plot2
    inc harvest_count
no_harvest_2:
    lda garden_plot3
    cmp #10
    bcc no_harvest_3
    lda #0
    sta garden_plot3
    inc harvest_count
no_harvest_3:
    lda harvest_count
    beq nothing_to_harvest
    // Give gold: 8g per harvest
    asl
    asl
    asl
    clc
    adc player_gold
    sta player_gold
    ldx #0
harvested_loop:
        lda harvested_msg,X
        beq harvested_done
        jsr modem_out
        inx
        bne harvested_loop
harvested_done:
    lda harvest_count
    jsr print_byte_decimal
    ldx #0
harvest_suffix_loop:
        lda harvest_suffix_msg,X
        beq harvest_suffix_done
        jsr modem_out
        inx
        bne harvest_suffix_loop
harvest_suffix_done:
    jsr modem_in
    jmp garden_menu
nothing_to_harvest:
    ldx #0
no_harvest_loop:
        lda no_harvest_msg,X
        beq no_harvest_done
        jsr modem_out
        inx
        bne no_harvest_loop
no_harvest_done:
    jsr modem_in
    jmp garden_menu

harvest_count: .byte 0
harvested_msg:
    .text "\r\nHarvested "
harvest_suffix_msg:
    .text " crops! (8g each)\r\n[Press any key]\r\n"
no_harvest_msg:
    .text "\r\nNothing ready to harvest.\r\n[Press any key]\r\n"

buy_seeds:
    // Cost 5 gold for 3 seeds
    lda player_gold
    cmp #5
    bcs can_buy_seeds
    ldx #0
no_gold_seeds_loop:
        lda no_gold_seeds_msg,X
        beq no_gold_seeds_done
        jsr modem_out
        inx
        bne no_gold_seeds_loop
no_gold_seeds_done:
    jsr modem_in
    jmp garden_menu
can_buy_seeds:
    lda player_gold
    sec
    sbc #5
    sta player_gold
    lda garden_seeds
    clc
    adc #3
    sta garden_seeds
    ldx #0
seeds_bought_loop:
        lda seeds_bought_msg,X
        beq seeds_bought_done
        jsr modem_out
        inx
        bne seeds_bought_loop
seeds_bought_done:
    jsr modem_in
    jmp garden_menu

no_gold_seeds_msg:
    .text "\r\nNeed 5 gold!\r\n[Press any key]\r\n"
seeds_bought_msg:
    .text "\r\nBought 3 seeds!\r\n[Press any key]\r\n"

// ============================================
// FISHING SYSTEM
// ============================================

fishing_menu:
    ldx #0
fishing_header_loop:
        lda fishing_header_msg,X
        beq fishing_header_done
        jsr modem_out
        inx
        bne fishing_header_loop
fishing_header_done:
    // Show stats
    ldx #0
bucket_label_loop:
        lda bucket_label_msg,X
        beq bucket_label_done
        jsr modem_out
        inx
        bne bucket_label_loop
bucket_label_done:
    lda fish_caught
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    ldx #0
casts_label_loop:
        lda casts_label_msg,X
        beq casts_label_done
        jsr modem_out
        inx
        bne casts_label_loop
casts_label_done:
    lda fish_casts
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    ldx #0
bait_label_loop:
        lda bait_label_msg,X
        beq bait_label_done
        jsr modem_out
        inx
        bne bait_label_loop
bait_label_done:
    lda bait_count
    jsr print_byte_decimal
    lda #13
    jsr modem_out
    // Options
    ldx #0
fishing_options_loop:
        lda fishing_options_msg,X
        beq fishing_options_done
        jsr modem_out
        inx
        bne fishing_options_loop
fishing_options_done:
    jsr modem_in
    cmp #'1'
    beq go_cast_line
    cmp #'2'
    beq go_sell_fish
    cmp #'3'
    beq go_buy_bait
    cmp #'0'
    beq go_back_fishing
    jmp fishing_menu
go_cast_line:
    jmp cast_line
go_sell_fish:
    jmp sell_fish
go_buy_bait:
    jmp buy_bait
go_back_fishing:
    jmp user_room_menu

fishing_header_msg:
    .text "\r\n=== FISHING ===\r\n"
bucket_label_msg:
    .text "Fish in bucket: "
casts_label_msg:
    .text "Casts today: "
bait_label_msg:
    .text "Bait: "
fishing_options_msg:
    .text "\r\n1. Cast Line\r\n2. Sell Fish (3g each)\r\n3. Buy Bait (2g)\r\n0. Back\r\n> "

cast_line:
    // Check casts remaining
    lda fish_casts
    bne have_casts
    ldx #0
no_casts_loop:
        lda no_casts_msg,X
        beq no_casts_done
        jsr modem_out
        inx
        bne no_casts_loop
no_casts_done:
    jsr modem_in
    jmp fishing_menu
have_casts:
    // Check bait
    lda bait_count
    bne have_bait
    ldx #0
no_bait_loop:
        lda no_bait_msg,X
        beq no_bait_done
        jsr modem_out
        inx
        bne no_bait_loop
no_bait_done:
    jsr modem_in
    jmp fishing_menu
have_bait:
    dec fish_casts
    dec bait_count
    ldx #0
casting_loop:
        lda casting_msg,X
        beq casting_done
        jsr modem_out
        inx
        bne casting_loop
casting_done:
    // Random catch
    jsr get_random
    and #7
    cmp #6  // Nothing
    bcs caught_nothing
    cmp #5  // Big fish!
    beq caught_big
    // Normal catch
    inc fish_caught
    ldx #0
caught_fish_loop:
        lda caught_fish_msg,X
        beq caught_fish_done
        jsr modem_out
        inx
        bne caught_fish_loop
caught_fish_done:
    jsr modem_in
    jmp fishing_menu
caught_big:
    lda fish_caught
    clc
    adc #3
    sta fish_caught
    ldx #0
big_catch_loop:
        lda big_catch_msg,X
        beq big_catch_done
        jsr modem_out
        inx
        bne big_catch_loop
big_catch_done:
    jsr modem_in
    jmp fishing_menu
caught_nothing:
    ldx #0
no_catch_loop:
        lda no_catch_msg,X
        beq no_catch_done
        jsr modem_out
        inx
        bne no_catch_loop
no_catch_done:
    jsr modem_in
    jmp fishing_menu

no_casts_msg:
    .text "\r\nNo casts left today!\r\n[Press any key]\r\n"
no_bait_msg:
    .text "\r\nNo bait! Buy some.\r\n[Press any key]\r\n"
casting_msg:
    .text "\r\nCasting line...\r\n"
caught_fish_msg:
    .text "You caught a fish!\r\n[Press any key]\r\n"
big_catch_msg:
    .text "WOW! Big catch! (+3 fish)\r\n[Press any key]\r\n"
no_catch_msg:
    .text "Nothing bites...\r\n[Press any key]\r\n"

sell_fish:
    lda fish_caught
    bne have_fish
    ldx #0
no_fish_loop:
        lda no_fish_msg,X
        beq no_fish_done
        jsr modem_out
        inx
        bne no_fish_loop
no_fish_done:
    jsr modem_in
    jmp fishing_menu
have_fish:
    // Sell all fish for 3g each
    lda fish_caught
    sta fish_sold_count
    asl  // x2
    clc
    adc fish_caught  // x3
    clc
    adc player_gold
    sta player_gold
    lda #0
    sta fish_caught
    ldx #0
fish_sold_loop:
        lda fish_sold_msg,X
        beq fish_sold_done
        jsr modem_out
        inx
        bne fish_sold_loop
fish_sold_done:
    lda fish_sold_count
    jsr print_byte_decimal
    ldx #0
fish_sold_suffix_loop:
        lda fish_sold_suffix_msg,X
        beq fish_sold_suffix_done
        jsr modem_out
        inx
        bne fish_sold_suffix_loop
fish_sold_suffix_done:
    jsr modem_in
    jmp fishing_menu

fish_sold_count: .byte 0
no_fish_msg:
    .text "\r\nNo fish to sell!\r\n[Press any key]\r\n"
fish_sold_msg:
    .text "\r\nSold "
fish_sold_suffix_msg:
    .text " fish! (3g each)\r\n[Press any key]\r\n"

buy_bait:
    lda player_gold
    cmp #2
    bcs can_buy_bait
    ldx #0
no_gold_bait_loop:
        lda no_gold_bait_msg,X
        beq no_gold_bait_done
        jsr modem_out
        inx
        bne no_gold_bait_loop
no_gold_bait_done:
    jsr modem_in
    jmp fishing_menu
can_buy_bait:
    lda player_gold
    sec
    sbc #2
    sta player_gold
    lda bait_count
    clc
    adc #5
    sta bait_count
    ldx #0
bait_bought_loop:
        lda bait_bought_msg,X
        beq bait_bought_done
        jsr modem_out
        inx
        bne bait_bought_loop
bait_bought_done:
    jsr modem_in
    jmp fishing_menu

no_gold_bait_msg:
    .text "\r\nNeed 2 gold!\r\n[Press any key]\r\n"
bait_bought_msg:
    .text "\r\nBought 5 bait!\r\n[Press any key]\r\n"

// === RACING SYSTEM ===
racing_menu:
    ldx #0
racing_menu_loop:
        lda racing_menu_msg,X
        beq racing_show_stats
        jsr modem_out
        inx
        bne racing_menu_loop
racing_show_stats:
    // Show wins
    ldx #0
wins_label_loop:
        lda wins_label,X
        beq show_wins_num
        jsr modem_out
        inx
        bne wins_label_loop
show_wins_num:
    lda race_wins
    jsr print_byte_decimal
    // Show losses
    ldx #0
losses_label_loop:
        lda losses_label,X
        beq show_losses_num
        jsr modem_out
        inx
        bne losses_label_loop
show_losses_num:
    lda race_losses
    jsr print_byte_decimal
    // Show streak
    ldx #0
race_streak_loop:
        lda streak_label,X
        beq show_streak_num
        jsr modem_out
        inx
        bne race_streak_loop
show_streak_num:
    lda race_streak
    jsr print_byte_decimal
    // Show races today
    ldx #0
races_left_loop:
        lda races_left_msg,X
        beq racing_get_input
        jsr modem_out
        inx
        bne races_left_loop
racing_get_input:
    lda race_today
    jsr print_byte_decimal
    ldx #0
racing_prompt_loop:
        lda racing_prompt,X
        beq racing_wait_key
        jsr modem_out
        inx
        bne racing_prompt_loop
racing_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_enter_race
    jmp enter_race
not_enter_race:
    cmp #'2'
    bne not_race_tips
    jmp view_race_tips
not_race_tips:
    cmp #'0'
    bne racing_wait_key
    jmp user_room_menu

enter_race:
    // Check races left
    lda race_today
    beq no_races_left
    // Check entry fee (5 gold)
    lda player_gold
    cmp #5
    bcc no_gold_race
    // Pay entry fee
    sec
    sbc #5
    sta player_gold
    // Use race
    dec race_today
    // Race! Random 0-2: 0=lose, 1-2=win
    jsr get_random
    and #$03
    cmp #1
    bcc race_lost
    // Won!
    inc race_wins
    inc race_streak
    // Prize based on streak
    lda race_streak
    cmp #3
    bcc normal_win
    // Streak bonus: 15 gold
    lda player_gold
    clc
    adc #15
    sta player_gold
    ldx #0
streak_win_loop:
        lda streak_win_msg,X
        beq race_result_wait
        jsr modem_out
        inx
        bne streak_win_loop
normal_win:
    // Normal win: 10 gold
    lda player_gold
    clc
    adc #10
    sta player_gold
    ldx #0
race_won_loop:
        lda race_won_msg,X
        beq race_result_wait
        jsr modem_out
        inx
        bne race_won_loop
race_lost:
    inc race_losses
    lda #0
    sta race_streak
    ldx #0
race_lost_loop:
        lda race_lost_msg,X
        beq race_result_wait
        jsr modem_out
        inx
        bne race_lost_loop
race_result_wait:
    jsr modem_in
    jmp racing_menu

no_races_left:
    ldx #0
no_races_loop:
        lda no_races_msg,X
        beq no_races_done
        jsr modem_out
        inx
        bne no_races_loop
no_races_done:
    jsr modem_in
    jmp racing_menu

no_gold_race:
    ldx #0
no_gold_race_loop:
        lda no_gold_race_msg,X
        beq no_gold_race_done
        jsr modem_out
        inx
        bne no_gold_race_loop
no_gold_race_done:
    jsr modem_in
    jmp racing_menu

view_race_tips:
    ldx #0
race_tips_loop:
        lda race_tips_msg,X
        beq race_tips_done
        jsr modem_out
        inx
        bne race_tips_loop
race_tips_done:
    jsr modem_in
    jmp racing_menu

racing_menu_msg:
    .text "\r\n=== PET RACING ===\r\n"
    .byte 0
wins_label:
    .text "\r\nWins: "
    .byte 0
losses_label:
    .text "  Losses: "
    .byte 0
streak_label:
    .text "  Streak: "
    .byte 0
races_left_msg:
    .text "\r\nRaces Left Today: "
    .byte 0
racing_prompt:
    .text "\r\n\r\n1. Enter Race (5g)\r\n2. Racing Tips\r\n0. Back\r\n> "
    .byte 0
race_won_msg:
    .text "\r\nYour pet WINS! +10 gold!\r\n[Press any key]\r\n"
    .byte 0
streak_win_msg:
    .text "\r\nSTREAK BONUS! Your pet WINS! +15 gold!\r\n[Press any key]\r\n"
    .byte 0
race_lost_msg:
    .text "\r\nYour pet lost the race...\r\n[Press any key]\r\n"
    .byte 0
no_races_msg:
    .text "\r\nNo races left today!\r\n[Press any key]\r\n"
    .byte 0
no_gold_race_msg:
    .text "\r\nNeed 5 gold entry fee!\r\n[Press any key]\r\n"
    .byte 0
race_tips_msg:
    .text "\r\n=== RACING TIPS ===\r\nEntry: 5 gold\r\nWin: 10 gold\r\n3+ Streak: 15 gold!\r\n3 races per day\r\n[Press any key]\r\n"
    .byte 0

// === TREASURE HUNT SYSTEM ===
treasure_menu:
    // Randomize treasure location daily
    jsr get_random
    and #$03
    sta treasure_loc
    ldx #0
treasure_menu_loop:
        lda treasure_menu_msg,X
        beq treasure_show_digs
        jsr modem_out
        inx
        bne treasure_menu_loop
treasure_show_digs:
    ldx #0
digs_left_loop:
        lda digs_left_msg,X
        beq show_digs_num
        jsr modem_out
        inx
        bne digs_left_loop
show_digs_num:
    lda dig_attempts
    jsr print_byte_decimal
    ldx #0
treasure_prompt_loop:
        lda treasure_prompt,X
        beq treasure_wait_key
        jsr modem_out
        inx
        bne treasure_prompt_loop
treasure_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_get_clue
    jmp get_clue
not_get_clue:
    cmp #'2'
    bne not_dig_treasure
    jmp dig_for_treasure
not_dig_treasure:
    cmp #'3'
    bne not_treasure_stats
    jmp treasure_stats
not_treasure_stats:
    cmp #'0'
    bne treasure_wait_key
    jmp user_room_menu

get_clue:
    // Show a random clue
    jsr get_random
    and #$03
    cmp #0
    bne clue_not_0
    ldx #0
clue0_loop:
        lda clue0_msg,X
        beq clue_done
        jsr modem_out
        inx
        bne clue0_loop
clue_not_0:
    cmp #1
    bne clue_not_1
    ldx #0
clue1_loop:
        lda clue1_msg,X
        beq clue_done
        jsr modem_out
        inx
        bne clue1_loop
clue_not_1:
    cmp #2
    bne clue_not_2
    ldx #0
clue2_loop:
        lda clue2_msg,X
        beq clue_done
        jsr modem_out
        inx
        bne clue2_loop
clue_not_2:
    ldx #0
clue3_loop:
        lda clue3_msg,X
        beq clue_done
        jsr modem_out
        inx
        bne clue3_loop
clue_done:
    jsr modem_in
    jmp treasure_menu

dig_for_treasure:
    // Check digs left
    lda dig_attempts
    beq no_digs_left
    dec dig_attempts
    // Ask where to dig
    ldx #0
dig_where_loop:
        lda dig_where_msg,X
        beq dig_wait_input
        jsr modem_out
        inx
        bne dig_where_loop
dig_wait_input:
    jsr modem_in
    sec
    sbc #'1'
    cmp #4
    bcs dig_invalid
    // Check if matches treasure location
    cmp treasure_loc
    bne dig_miss
    // Found treasure!
    inc treasure_found
    // Award gold
    lda player_gold
    clc
    adc #25
    sta player_gold
    // New random location
    jsr get_random
    and #$03
    sta treasure_loc
    ldx #0
treasure_found_loop:
        lda treasure_found_msg,X
        beq dig_result_done
        jsr modem_out
        inx
        bne treasure_found_loop
dig_miss:
    ldx #0
dig_miss_loop:
        lda dig_miss_msg,X
        beq dig_result_done
        jsr modem_out
        inx
        bne dig_miss_loop
dig_invalid:
    ldx #0
dig_invalid_loop:
        lda dig_invalid_msg,X
        beq dig_result_done
        jsr modem_out
        inx
        bne dig_invalid_loop
dig_result_done:
    jsr modem_in
    jmp treasure_menu

no_digs_left:
    ldx #0
no_digs_loop:
        lda no_digs_msg,X
        beq no_digs_done
        jsr modem_out
        inx
        bne no_digs_loop
no_digs_done:
    jsr modem_in
    jmp treasure_menu

treasure_stats:
    ldx #0
treasure_stats_loop:
        lda treasure_stats_msg,X
        beq treasure_stats_num
        jsr modem_out
        inx
        bne treasure_stats_loop
treasure_stats_num:
    lda treasure_found
    jsr print_byte_decimal
    ldx #0
treasure_stats_end_loop:
        lda treasure_stats_end,X
        beq treasure_stats_done
        jsr modem_out
        inx
        bne treasure_stats_end_loop
treasure_stats_done:
    jsr modem_in
    jmp treasure_menu

treasure_menu_msg:
    .text "\r\n=== TREASURE HUNT ===\r\n"
    .byte 0
digs_left_msg:
    .text "Digs Left: "
    .byte 0
treasure_prompt:
    .text "\r\n\r\n1. Get Clue\r\n2. Dig (1-4)\r\n3. My Stats\r\n0. Back\r\n> "
    .byte 0
dig_where_msg:
    .text "\r\nDig where? (1-4): "
    .byte 0
clue0_msg:
    .text "\r\nClue: The treasure is NOT at spot 1.\r\n[Press any key]\r\n"
    .byte 0
clue1_msg:
    .text "\r\nClue: Try an even number...\r\n[Press any key]\r\n"
    .byte 0
clue2_msg:
    .text "\r\nClue: The chest is buried deep...\r\n[Press any key]\r\n"
    .byte 0
clue3_msg:
    .text "\r\nClue: X marks the spot near 3!\r\n[Press any key]\r\n"
    .byte 0
treasure_found_msg:
    .text "\r\nYou found TREASURE! +25 gold!\r\n[Press any key]\r\n"
    .byte 0
dig_miss_msg:
    .text "\r\nNothing here... try again!\r\n[Press any key]\r\n"
    .byte 0
dig_invalid_msg:
    .text "\r\nInvalid spot! Choose 1-4.\r\n[Press any key]\r\n"
    .byte 0
no_digs_msg:
    .text "\r\nNo digs left today!\r\n[Press any key]\r\n"
    .byte 0
treasure_stats_msg:
    .text "\r\nTotal Treasures Found: "
    .byte 0
treasure_stats_end:
    .text "\r\n[Press any key]\r\n"
    .byte 0

// === COOKING SYSTEM ===
cooking_menu:
    ldx #0
cooking_menu_loop:
        lda cooking_menu_msg,X
        beq cooking_show_inv
        jsr modem_out
        inx
        bne cooking_menu_loop
cooking_show_inv:
    // Show fish count
    ldx #0
fish_inv_loop:
        lda fish_inv_msg,X
        beq fish_inv_num
        jsr modem_out
        inx
        bne fish_inv_loop
fish_inv_num:
    lda fish_caught
    jsr print_byte_decimal
    // Show meals cooked
    ldx #0
meals_inv_loop:
        lda meals_inv_msg,X
        beq meals_inv_num
        jsr modem_out
        inx
        bne meals_inv_loop
meals_inv_num:
    lda meals_cooked
    jsr print_byte_decimal
    ldx #0
cooking_prompt_loop:
        lda cooking_prompt,X
        beq cooking_wait_key
        jsr modem_out
        inx
        bne cooking_prompt_loop
cooking_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_cook_fish
    jmp cook_fish_stew
not_cook_fish:
    cmp #'2'
    bne not_cook_feast
    jmp cook_feast
not_cook_feast:
    cmp #'3'
    bne not_eat_meal
    jmp eat_meal
not_eat_meal:
    cmp #'0'
    bne cooking_wait_key
    jmp user_room_menu

cook_fish_stew:
    // Needs 2 fish
    lda fish_caught
    cmp #2
    bcc not_enough_fish
    // Cook it!
    sec
    sbc #2
    sta fish_caught
    inc meals_cooked
    ldx #0
stew_done_loop:
        lda stew_done_msg,X
        beq stew_done_wait
        jsr modem_out
        inx
        bne stew_done_loop
stew_done_wait:
    jsr modem_in
    jmp cooking_menu

not_enough_fish:
    ldx #0
need_fish_loop:
        lda need_fish_msg,X
        beq need_fish_done
        jsr modem_out
        inx
        bne need_fish_loop
need_fish_done:
    jsr modem_in
    jmp cooking_menu

cook_feast:
    // Needs 5 fish for big feast
    lda fish_caught
    cmp #5
    bcc not_enough_feast
    // Cook it!
    sec
    sbc #5
    sta fish_caught
    lda meals_cooked
    clc
    adc #3
    sta meals_cooked
    ldx #0
feast_done_loop:
        lda feast_done_msg,X
        beq feast_done_wait
        jsr modem_out
        inx
        bne feast_done_loop
feast_done_wait:
    jsr modem_in
    jmp cooking_menu

not_enough_feast:
    ldx #0
need_feast_loop:
        lda need_feast_msg,X
        beq need_feast_done
        jsr modem_out
        inx
        bne need_feast_loop
need_feast_done:
    jsr modem_in
    jmp cooking_menu

eat_meal:
    // Check for meals
    lda meals_cooked
    beq no_meals
    dec meals_cooked
    // Activate buff
    lda #1
    sta buff_active
    lda #5
    sta buff_timer
    // Bonus gold
    lda player_gold
    clc
    adc #5
    sta player_gold
    ldx #0
eat_done_loop:
        lda eat_done_msg,X
        beq eat_done_wait
        jsr modem_out
        inx
        bne eat_done_loop
eat_done_wait:
    jsr modem_in
    jmp cooking_menu

no_meals:
    ldx #0
no_meals_loop:
        lda no_meals_msg,X
        beq no_meals_done
        jsr modem_out
        inx
        bne no_meals_loop
no_meals_done:
    jsr modem_in
    jmp cooking_menu

cooking_menu_msg:
    .text "\r\n=== KITCHEN ===\r\n"
    .byte 0
fish_inv_msg:
    .text "Fish: "
    .byte 0
meals_inv_msg:
    .text "  Meals: "
    .byte 0
cooking_prompt:
    .text "\r\n\r\n1. Fish Stew (2 fish)\r\n2. Grand Feast (5 fish=3 meals)\r\n3. Eat Meal (+5g buff)\r\n0. Back\r\n> "
    .byte 0
stew_done_msg:
    .text "\r\nCooked Fish Stew! +1 meal\r\n[Press any key]\r\n"
    .byte 0
need_fish_msg:
    .text "\r\nNeed 2 fish to cook!\r\n[Press any key]\r\n"
    .byte 0
feast_done_msg:
    .text "\r\nCooked Grand Feast! +3 meals\r\n[Press any key]\r\n"
    .byte 0
need_feast_msg:
    .text "\r\nNeed 5 fish for feast!\r\n[Press any key]\r\n"
    .byte 0
eat_done_msg:
    .text "\r\nDelicious! +5 gold, Buff active!\r\n[Press any key]\r\n"
    .byte 0
no_meals_msg:
    .text "\r\nNo meals to eat!\r\n[Press any key]\r\n"
    .byte 0

// === DUELING SYSTEM ===
dueling_menu:
    ldx #0
dueling_menu_loop:
        lda dueling_menu_msg,X
        beq dueling_show_stats
        jsr modem_out
        inx
        bne dueling_menu_loop
dueling_show_stats:
    // Show HP
    ldx #0
hp_label_loop:
        lda hp_label,X
        beq hp_label_num
        jsr modem_out
        inx
        bne hp_label_loop
hp_label_num:
    lda player_hp
    jsr print_byte_decimal
    // Show wins
    ldx #0
duel_wins_loop:
        lda duel_wins_label,X
        beq duel_wins_num
        jsr modem_out
        inx
        bne duel_wins_loop
duel_wins_num:
    lda duel_wins
    jsr print_byte_decimal
    // Show losses
    ldx #0
duel_losses_loop:
        lda duel_losses_label,X
        beq duel_losses_num
        jsr modem_out
        inx
        bne duel_losses_loop
duel_losses_num:
    lda duel_losses
    jsr print_byte_decimal
    ldx #0
dueling_prompt_loop:
        lda dueling_prompt,X
        beq dueling_wait_key
        jsr modem_out
        inx
        bne dueling_prompt_loop
dueling_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_start_duel
    jmp start_duel
not_start_duel:
    cmp #'2'
    bne not_rest_hp
    jmp rest_heal
not_rest_hp:
    cmp #'0'
    bne dueling_wait_key
    jmp user_room_menu

start_duel:
    // Check duels left
    lda duels_today
    bne duels_available
    jmp no_duels_left
duels_available:
    dec duels_today
    // Init enemy HP
    lda #10
    sta enemy_hp
    // Battle loop
battle_round:
    // Show status
    ldx #0
battle_status_loop:
        lda battle_status_msg,X
        beq show_player_hp
        jsr modem_out
        inx
        bne battle_status_loop
show_player_hp:
    lda player_hp
    jsr print_byte_decimal
    ldx #0
enemy_hp_label_loop:
        lda enemy_hp_label,X
        beq show_enemy_hp
        jsr modem_out
        inx
        bne enemy_hp_label_loop
show_enemy_hp:
    lda enemy_hp
    jsr print_byte_decimal
    ldx #0
battle_prompt_loop:
        lda battle_prompt,X
        beq battle_wait
        jsr modem_out
        inx
        bne battle_prompt_loop
battle_wait:
    jsr modem_in
    cmp #'1'
    bne not_attack
    jmp do_attack
not_attack:
    cmp #'2'
    bne battle_wait
    jmp do_defend

do_attack:
    // Player attacks: 3-5 damage
    jsr get_random
    and #$03
    clc
    adc #3
    sta $02
    // Deal damage to enemy
    lda enemy_hp
    sec
    sbc $02
    bcc enemy_defeated
    beq enemy_defeated
    sta enemy_hp
    // Enemy attacks: 2-4 damage
    jsr get_random
    and #$03
    clc
    adc #2
    sta $02
    lda player_hp
    sec
    sbc $02
    bcc player_defeated
    beq player_defeated
    sta player_hp
    jmp battle_round

do_defend:
    // Defend: enemy does 1 damage, heal 1
    lda player_hp
    sec
    sbc #1
    bcc player_defeated
    beq player_defeated
    clc
    adc #2
    cmp #25
    bcc defend_ok
    lda #25
defend_ok:
    sta player_hp
    jmp battle_round

enemy_defeated:
    inc duel_wins
    // Award gold
    lda player_gold
    clc
    adc #15
    sta player_gold
    ldx #0
victory_loop:
        lda victory_msg,X
        beq victory_done
        jsr modem_out
        inx
        bne victory_loop
victory_done:
    jsr modem_in
    jmp dueling_menu

player_defeated:
    lda #0
    sta player_hp
    inc duel_losses
    // Restore some HP
    lda #10
    sta player_hp
    ldx #0
defeat_loop:
        lda defeat_msg,X
        beq defeat_done
        jsr modem_out
        inx
        bne defeat_loop
defeat_done:
    jsr modem_in
    jmp dueling_menu

no_duels_left:
    ldx #0
no_duels_loop:
        lda no_duels_today_msg,X
        beq no_duels_done
        jsr modem_out
        inx
        bne no_duels_loop
no_duels_done:
    jsr modem_in
    jmp dueling_menu

rest_heal:
    // Heal 5 HP, max 25
    lda player_hp
    clc
    adc #5
    cmp #25
    bcc rest_ok
    lda #25
rest_ok:
    sta player_hp
    ldx #0
rest_done_loop:
        lda rest_done_msg,X
        beq rest_done
        jsr modem_out
        inx
        bne rest_done_loop
rest_done:
    jsr modem_in
    jmp dueling_menu

dueling_menu_msg:
    .text "\r\n=== ARENA ===\r\n"
    .byte 0
hp_label:
    .text "Your HP: "
    .byte 0
duel_wins_label:
    .text "  Wins: "
    .byte 0
duel_losses_label:
    .text "  Losses: "
    .byte 0
dueling_prompt:
    .text "\r\n\r\n1. Fight! (15g prize)\r\n2. Rest (+5 HP)\r\n0. Back\r\n> "
    .byte 0
battle_status_msg:
    .text "\r\n--- BATTLE ---\r\nYou: "
    .byte 0
enemy_hp_label:
    .text " HP  Enemy: "
    .byte 0
battle_prompt:
    .text " HP\r\n1. Attack\r\n2. Defend\r\n> "
    .byte 0
victory_msg:
    .text "\r\nVICTORY! +15 gold!\r\n[Press any key]\r\n"
    .byte 0
defeat_msg:
    .text "\r\nDefeated... Rest and try again.\r\n[Press any key]\r\n"
    .byte 0
no_duels_today_msg:
    .text "\r\nNo duels left today!\r\n[Press any key]\r\n"
    .byte 0
rest_done_msg:
    .text "\r\nRested. +5 HP!\r\n[Press any key]\r\n"
    .byte 0

// === MAILBOX SYSTEM ===
// Now redirects to unified Messages system
mailbox_menu:
    jmp messaging_menu

// === RIDDLES SYSTEM ===
riddles_menu:
    ldx #0
riddles_menu_loop:
        lda riddles_menu_msg,X
        beq riddles_show_stats
        jsr modem_out
        inx
        bne riddles_menu_loop
riddles_show_stats:
    ldx #0
solved_label_loop:
        lda solved_label,X
        beq solved_num
        jsr modem_out
        inx
        bne solved_label_loop
solved_num:
    lda riddles_solved
    jsr print_byte_decimal
    ldx #0
ciphers_label_loop:
        lda ciphers_label,X
        beq ciphers_num
        jsr modem_out
        inx
        bne ciphers_label_loop
ciphers_num:
    lda ciphers_solved
    jsr print_byte_decimal
    ldx #0
attempts_label_loop:
        lda attempts_label,X
        beq attempts_num
        jsr modem_out
        inx
        bne attempts_label_loop
attempts_num:
    lda riddle_attempts
    jsr print_byte_decimal
    ldx #0
cipher_att_label_loop:
        lda cipher_attempts_label,X
        beq cipher_att_num
        jsr modem_out
        inx
        bne cipher_att_label_loop
cipher_att_num:
    lda cipher_attempts
    jsr print_byte_decimal
    ldx #0
riddles_prompt_loop:
        lda riddles_prompt,X
        beq riddles_wait_key
        jsr modem_out
        inx
        bne riddles_prompt_loop
riddles_wait_key:
    jsr modem_in
    cmp #'1'
    beq go_ask_riddle
    cmp #'2'
    beq go_ask_cipher
    cmp #'3'
    beq go_cipher_lore
    cmp #'0'
    bne riddles_wait_key
    jmp user_room_menu
go_ask_riddle:
    jmp ask_riddle
go_ask_cipher:
    jmp ask_cipher
go_cipher_lore:
    jmp show_cipher_lore

ask_riddle:
    lda riddle_attempts
    bne riddle_available
    jmp no_attempts_left
riddle_available:
    dec riddle_attempts
    // Pick random riddle
    jsr get_random
    and #$03
    sta current_riddle
    // Show riddle
    cmp #0
    bne riddle_not_0
    ldx #0
riddle0_loop:
        lda riddle0_msg,X
        beq riddle_get_answer
        jsr modem_out
        inx
        bne riddle0_loop
riddle_not_0:
    cmp #1
    bne riddle_not_1
    ldx #0
riddle1_loop:
        lda riddle1_msg,X
        beq riddle_get_answer
        jsr modem_out
        inx
        bne riddle1_loop
riddle_not_1:
    cmp #2
    bne riddle_not_2
    ldx #0
riddle2_loop:
        lda riddle2_msg,X
        beq riddle_get_answer
        jsr modem_out
        inx
        bne riddle2_loop
riddle_not_2:
    ldx #0
riddle3_loop:
        lda riddle3_msg,X
        beq riddle_get_answer
        jsr modem_out
        inx
        bne riddle3_loop
riddle_get_answer:
    jsr modem_in
    // Check answer (1-4 for A-D)
    sec
    sbc #'1'
    cmp #4
    bcs riddle_wrong
    // Compare to correct answer
    ldx current_riddle
    cmp riddle_answers,X
    bne riddle_wrong
    // Correct!
    inc riddles_solved
    lda player_gold
    clc
    adc #10
    sta player_gold
    ldx #0
riddle_correct_loop:
        lda riddle_correct_msg,X
        beq riddle_done
        jsr modem_out
        inx
        bne riddle_correct_loop
riddle_wrong:
    ldx #0
riddle_wrong_loop:
        lda riddle_wrong_msg,X
        beq riddle_done
        jsr modem_out
        inx
        bne riddle_wrong_loop
riddle_done:
    jsr modem_in
    jmp riddles_menu

no_attempts_left:
    ldx #0
no_attempts_loop:
        lda no_attempts_msg,X
        beq no_attempts_done
        jsr modem_out
        inx
        bne no_attempts_loop
no_attempts_done:
    jsr modem_in
    jmp riddles_menu

riddle_answers:
    .byte 1, 2, 0, 3    // Answers: B, C, A, D

riddles_menu_msg:
    .text "\r\n=== RIDDLE & CIPHER CHAMBER ===\r\n"
    .byte 0
solved_label:
    .text "Riddles Solved: "
    .byte 0
ciphers_label:
    .text "  Ciphers Cracked: "
    .byte 0
attempts_label:
    .text "\r\nRiddle Attempts: "
    .byte 0
cipher_attempts_label:
    .text "  Cipher Attempts: "
    .byte 0
riddles_prompt:
    .text "\r\n\r\n1. Try a Riddle (+10g)\r\n2. Crack a Cipher (+25g)\r\n3. Cipher Lore\r\n0. Back\r\n> "
    .byte 0
riddle0_msg:
    .text "\r\nWhat has keys but no locks?\r\n1.Door 2.Piano 3.Car 4.Safe\r\n> "
    .byte 0
riddle1_msg:
    .text "\r\nWhat has hands but cannot clap?\r\n1.Robot 2.Baby 3.Clock 4.Tree\r\n> "
    .byte 0
riddle2_msg:
    .text "\r\nWhat has a head and tail but no body?\r\n1.Coin 2.Snake 3.Fish 4.Arrow\r\n> "
    .byte 0
riddle3_msg:
    .text "\r\nWhat gets wetter the more it dries?\r\n1.Sponge 2.Rain 3.Ice 4.Towel\r\n> "
    .byte 0
riddle_correct_msg:
    .text "\r\nCORRECT! +10 gold!\r\n[Press any key]\r\n"
    .byte 0
riddle_wrong_msg:
    .text "\r\nWrong answer...\r\n[Press any key]\r\n"
    .byte 0
no_attempts_msg:
    .text "\r\nNo attempts left today!\r\n[Press any key]\r\n"
    .byte 0

// === CIPHER SYSTEM ===
ask_cipher:
    lda cipher_attempts
    bne cipher_available
    jmp no_cipher_attempts
cipher_available:
    dec cipher_attempts
    // Pick random cipher
    jsr get_random
    and #$03
    sta current_cipher
    // Show cipher
    cmp #0
    bne cipher_not_0
    ldx #0
cipher0_loop:
        lda cipher0_msg,X
        beq cipher_get_answer
        jsr modem_out
        inx
        bne cipher0_loop
cipher_not_0:
    cmp #1
    bne cipher_not_1
    ldx #0
cipher1_loop:
        lda cipher1_msg,X
        beq cipher_get_answer
        jsr modem_out
        inx
        bne cipher1_loop
cipher_not_1:
    cmp #2
    bne cipher_not_2
    ldx #0
cipher2_loop:
        lda cipher2_msg,X
        beq cipher_get_answer
        jsr modem_out
        inx
        bne cipher2_loop
cipher_not_2:
    ldx #0
cipher3_loop:
        lda cipher3_msg,X
        beq cipher_get_answer
        jsr modem_out
        inx
        bne cipher3_loop
cipher_get_answer:
    jsr modem_in
    // Check cipher answer (single letter)
    ldx current_cipher
    cmp cipher_answers,X
    bne cipher_wrong
    // Correct!
    inc ciphers_solved
    lda player_gold
    clc
    adc #25
    sta player_gold
    ldx #0
cipher_correct_loop:
        lda cipher_correct_msg,X
        beq cipher_done
        jsr modem_out
        inx
        bne cipher_correct_loop
cipher_wrong:
    ldx #0
cipher_wrong_loop:
        lda cipher_wrong_msg,X
        beq cipher_done
        jsr modem_out
        inx
        bne cipher_wrong_loop
cipher_done:
    jsr modem_in
    jmp riddles_menu

no_cipher_attempts:
    ldx #0
no_cipher_att_loop:
        lda no_cipher_att_msg,X
        beq no_cipher_att_done
        jsr modem_out
        inx
        bne no_cipher_att_loop
no_cipher_att_done:
    jsr modem_in
    jmp riddles_menu

show_cipher_lore:
    ldx #0
cipher_lore_loop:
        lda cipher_lore_msg,X
        beq cipher_lore_done
        jsr modem_out
        inx
        bne cipher_lore_loop
cipher_lore_done:
    jsr modem_in
    jmp riddles_menu

cipher_answers:
    .byte 'F', 'M', 'D', 'S'    // Answers for each cipher

cipher0_msg:
    .text "\r\n--- CAESAR CIPHER ---\r\nShift: +3 letters\r\n\r\nEncrypted: 'FURVW'\r\n\r\nWhat word is this?\r\n(Hint: A=D, B=E, C=F...)\r\n> "
    .byte 0
cipher1_msg:
    .text "\r\n--- REVERSE CIPHER ---\r\n\r\nEncrypted: 'CIGAM'\r\n\r\nWhat is the last letter of the decoded word?\r\n> "
    .byte 0
cipher2_msg:
    .text "\r\n--- SYMBOL CIPHER ---\r\n\r\n* = A, @ = R, # = G, % = O, ^ = N\r\n\r\nDecode: '#@*#%^'\r\n\r\nWhat is the first letter?\r\n> "
    .byte 0
cipher3_msg:
    .text "\r\n--- ATBASH CIPHER ---\r\nA=Z, B=Y, C=X...\r\n\r\nEncrypted: 'HKRWVI'\r\n\r\nWhat is the first letter of the decoded word?\r\n> "
    .byte 0
cipher_correct_msg:
    .text "\r\nCRACKED! +25 gold! The ancient secrets reveal themselves!\r\n[Press any key]\r\n"
    .byte 0
cipher_wrong_msg:
    .text "\r\nIncorrect... The cipher remains unbroken.\r\n[Press any key]\r\n"
    .byte 0
no_cipher_att_msg:
    .text "\r\nNo cipher attempts left today! Return tomorrow.\r\n[Press any key]\r\n"
    .byte 0
cipher_lore_msg:
    .text "\r\n--- CIPHER LORE ---\r\n\r\nThe Order of the Owls perfected the art of secret messages.\r\nGarrett himself created ciphers to protect guild secrets.\r\n\r\nCaesar Shift: Each letter shifts forward by a number.\r\nReverse Cipher: Text is simply reversed.\r\nSymbol Cipher: Symbols replace letters.\r\nAtbash Cipher: A becomes Z, B becomes Y, etc.\r\n\r\nMastering ciphers grants access to hidden knowledge!\r\n\r\n[Press any key]\r\n"
    .byte 0

// === BOUNTY BOARD SYSTEM ===
bounty_menu:
    ldx #0
bounty_menu_loop:
        lda bounty_menu_msg,X
        beq bounty_show_stats
        jsr modem_out
        inx
        bne bounty_menu_loop
bounty_show_stats:
    ldx #0
bounties_done_loop:
        lda bounties_done_msg,X
        beq bounties_done_num
        jsr modem_out
        inx
        bne bounties_done_loop
bounties_done_num:
    lda bounties_done
    jsr print_byte_decimal
    // Show active bounty
    lda active_bounty
    cmp #255
    bne has_active_bounty
    ldx #0
no_bounty_loop:
        lda no_active_msg,X
        beq bounty_prompt_show
        jsr modem_out
        inx
        bne no_bounty_loop
has_active_bounty:
    ldx #0
active_bounty_loop:
        lda active_bounty_msg,X
        beq show_target_type
        jsr modem_out
        inx
        bne active_bounty_loop
show_target_type:
    lda bounty_target
    cmp #0
    bne not_goblin
    ldx #0
goblin_loop:
        lda goblin_name,X
        beq bounty_prompt_show
        jsr modem_out
        inx
        bne goblin_loop
not_goblin:
    cmp #1
    bne not_bandit
    ldx #0
bandit_loop:
        lda bandit_name,X
        beq bounty_prompt_show
        jsr modem_out
        inx
        bne bandit_loop
not_bandit:
    cmp #2
    bne not_wolf
    ldx #0
wolf_loop:
        lda wolf_name,X
        beq bounty_prompt_show
        jsr modem_out
        inx
        bne wolf_loop
not_wolf:
    ldx #0
dragon_loop:
        lda dragon_name,X
        beq bounty_prompt_show
        jsr modem_out
        inx
        bne dragon_loop
bounty_prompt_show:
    ldx #0
bounty_prompt_loop:
        lda bounty_prompt,X
        beq bounty_wait_key
        jsr modem_out
        inx
        bne bounty_prompt_loop
bounty_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_accept_bounty
    jmp accept_bounty
not_accept_bounty:
    cmp #'2'
    bne not_hunt_bounty
    jmp hunt_bounty
not_hunt_bounty:
    cmp #'0'
    bne bounty_wait_key
    jmp user_room_menu

accept_bounty:
    lda active_bounty
    cmp #255
    bne already_has_bounty
    // Assign random bounty
    jsr get_random
    and #$03
    sta active_bounty
    sta bounty_target
    ldx #0
bounty_accepted_loop:
        lda bounty_accepted_msg,X
        beq bounty_accepted_done
        jsr modem_out
        inx
        bne bounty_accepted_loop
bounty_accepted_done:
    jsr modem_in
    jmp bounty_menu

already_has_bounty:
    ldx #0
already_bounty_loop:
        lda already_bounty_msg,X
        beq already_bounty_done
        jsr modem_out
        inx
        bne already_bounty_loop
already_bounty_done:
    jsr modem_in
    jmp bounty_menu

hunt_bounty:
    lda active_bounty
    cmp #255
    beq no_bounty_hunt
    // Hunt! Random success
    jsr get_random
    and #$03
    cmp #0
    beq hunt_failed
    // Success!
    inc bounties_done
    lda player_gold
    clc
    adc bounty_reward
    sta player_gold
    lda #255
    sta active_bounty
    ldx #0
hunt_success_loop:
        lda hunt_success_msg,X
        beq hunt_done
        jsr modem_out
        inx
        bne hunt_success_loop
hunt_failed:
    ldx #0
hunt_failed_loop:
        lda hunt_failed_msg,X
        beq hunt_done
        jsr modem_out
        inx
        bne hunt_failed_loop
hunt_done:
    jsr modem_in
    jmp bounty_menu

no_bounty_hunt:
    ldx #0
no_bounty_hunt_loop:
        lda no_bounty_hunt_msg,X
        beq no_bounty_hunt_done
        jsr modem_out
        inx
        bne no_bounty_hunt_loop
no_bounty_hunt_done:
    jsr modem_in
    jmp bounty_menu

bounty_menu_msg:
    .text "\r\n=== BOUNTY BOARD ===\r\n"
    .byte 0
bounties_done_msg:
    .text "Bounties Completed: "
    .byte 0
no_active_msg:
    .text "\r\nNo active bounty"
    .byte 0
active_bounty_msg:
    .text "\r\nTarget: "
    .byte 0
goblin_name:
    .text "Goblin (20g)"
    .byte 0
bandit_name:
    .text "Bandit (20g)"
    .byte 0
wolf_name:
    .text "Wolf (20g)"
    .byte 0
dragon_name:
    .text "Dragon (20g)"
    .byte 0
bounty_prompt:
    .text "\r\n\r\n1. Accept Bounty\r\n2. Hunt Target\r\n0. Back\r\n> "
    .byte 0
bounty_accepted_msg:
    .text "\r\nBounty accepted! Go hunt!\r\n[Press any key]\r\n"
    .byte 0
already_bounty_msg:
    .text "\r\nFinish current bounty first!\r\n[Press any key]\r\n"
    .byte 0
hunt_success_msg:
    .text "\r\nTarget slain! +20 gold!\r\n[Press any key]\r\n"
    .byte 0
hunt_failed_msg:
    .text "\r\nTarget escaped... try again!\r\n[Press any key]\r\n"
    .byte 0
no_bounty_hunt_msg:
    .text "\r\nAccept a bounty first!\r\n[Press any key]\r\n"
    .byte 0

// === COMPANIONS SYSTEM ===
companion_menu:
    ldx #0
companion_menu_loop:
        lda companion_menu_msg,X
        beq companion_show_current
        jsr modem_out
        inx
        bne companion_menu_loop
companion_show_current:
    lda companion_slot
    cmp #255
    bne show_companion
    ldx #0
no_companion_loop:
        lda no_companion_msg,X
        beq companion_prompt_show
        jsr modem_out
        inx
        bne no_companion_loop
show_companion:
    ldx #0
current_comp_loop:
        lda current_comp_msg,X
        beq show_comp_name
        jsr modem_out
        inx
        bne current_comp_loop
show_comp_name:
    lda companion_slot
    cmp #0
    bne comp_not_hawk
    ldx #0
hawk_name_loop:
        lda hawk_name,X
        beq show_bond_level
        jsr modem_out
        inx
        bne hawk_name_loop
comp_not_hawk:
    cmp #1
    bne comp_not_wolf
    ldx #0
comp_wolf_loop:
        lda comp_wolf_name,X
        beq show_bond_level
        jsr modem_out
        inx
        bne comp_wolf_loop
comp_not_wolf:
    cmp #2
    bne comp_not_sprite
    ldx #0
sprite_name_loop:
        lda sprite_name,X
        beq show_bond_level
        jsr modem_out
        inx
        bne sprite_name_loop
comp_not_sprite:
    ldx #0
golem_name_loop:
        lda golem_name,X
        beq show_bond_level
        jsr modem_out
        inx
        bne golem_name_loop
show_bond_level:
    ldx #0
bond_label_loop:
        lda bond_label,X
        beq bond_num
        jsr modem_out
        inx
        bne bond_label_loop
bond_num:
    lda companion_bond
    jsr print_byte_decimal
companion_prompt_show:
    ldx #0
companion_prompt_loop:
        lda companion_prompt,X
        beq companion_wait_key
        jsr modem_out
        inx
        bne companion_prompt_loop
companion_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_recruit_comp
    jmp recruit_companion
not_recruit_comp:
    cmp #'2'
    bne not_bond_comp
    jmp bond_with_companion
not_bond_comp:
    cmp #'3'
    bne not_dismiss_comp
    jmp dismiss_companion
not_dismiss_comp:
    cmp #'0'
    bne companion_wait_key
    jmp user_room_menu

recruit_companion:
    lda companion_slot
    cmp #255
    bne already_has_companion
    // Recruit random companion
    jsr get_random
    and #$03
    sta companion_slot
    lda #1
    sta companion_bond
    ldx #0
recruited_loop:
        lda recruited_msg,X
        beq recruited_done
        jsr modem_out
        inx
        bne recruited_loop
recruited_done:
    jsr modem_in
    jmp companion_menu

already_has_companion:
    ldx #0
already_comp_loop:
        lda already_comp_msg,X
        beq already_comp_done
        jsr modem_out
        inx
        bne already_comp_loop
already_comp_done:
    jsr modem_in
    jmp companion_menu

bond_with_companion:
    lda companion_slot
    cmp #255
    beq no_comp_to_bond
    // Increase bond
    lda companion_bond
    cmp #10
    bcs bond_maxed
    inc companion_bond
    // Bonus gold at high bond
    lda companion_bond
    cmp #5
    bcc bond_done_msg
    lda player_gold
    clc
    adc #3
    sta player_gold
bond_done_msg:
    ldx #0
bond_up_loop:
        lda bond_up_msg,X
        beq bond_up_done
        jsr modem_out
        inx
        bne bond_up_loop
bond_up_done:
    jsr modem_in
    jmp companion_menu

bond_maxed:
    ldx #0
bond_max_loop:
        lda bond_max_msg,X
        beq bond_max_done
        jsr modem_out
        inx
        bne bond_max_loop
bond_max_done:
    jsr modem_in
    jmp companion_menu

no_comp_to_bond:
    ldx #0
no_comp_bond_loop:
        lda no_comp_bond_msg,X
        beq no_comp_bond_done
        jsr modem_out
        inx
        bne no_comp_bond_loop
no_comp_bond_done:
    jsr modem_in
    jmp companion_menu

dismiss_companion:
    lda companion_slot
    cmp #255
    beq no_comp_dismiss
    lda #255
    sta companion_slot
    lda #0
    sta companion_bond
    ldx #0
dismissed_loop:
        lda dismissed_msg,X
        beq dismissed_done
        jsr modem_out
        inx
        bne dismissed_loop
dismissed_done:
    jsr modem_in
    jmp companion_menu

no_comp_dismiss:
    ldx #0
no_comp_dismiss_loop:
        lda no_comp_dismiss_msg,X
        beq no_comp_dismiss_done
        jsr modem_out
        inx
        bne no_comp_dismiss_loop
no_comp_dismiss_done:
    jsr modem_in
    jmp companion_menu

companion_menu_msg:
    .text "\r\n=== COMPANIONS ===\r\n"
    .byte 0
no_companion_msg:
    .text "No companion recruited"
    .byte 0
current_comp_msg:
    .text "Companion: "
    .byte 0
hawk_name:
    .text "Swift Hawk"
    .byte 0
comp_wolf_name:
    .text "Grey Wolf"
    .byte 0
sprite_name:
    .text "Forest Sprite"
    .byte 0
golem_name:
    .text "Stone Golem"
    .byte 0
bond_label:
    .text "  Bond: "
    .byte 0
companion_prompt:
    .text "\r\n\r\n1. Recruit\r\n2. Bond (+3g at 5+)\r\n3. Dismiss\r\n0. Back\r\n> "
    .byte 0
recruited_msg:
    .text "\r\nCompanion recruited!\r\n[Press any key]\r\n"
    .byte 0
already_comp_msg:
    .text "\r\nDismiss current first!\r\n[Press any key]\r\n"
    .byte 0
bond_up_msg:
    .text "\r\nBond increased!\r\n[Press any key]\r\n"
    .byte 0
bond_max_msg:
    .text "\r\nBond is at maximum!\r\n[Press any key]\r\n"
    .byte 0
no_comp_bond_msg:
    .text "\r\nRecruit a companion first!\r\n[Press any key]\r\n"
    .byte 0
dismissed_msg:
    .text "\r\nCompanion dismissed.\r\n[Press any key]\r\n"
    .byte 0
no_comp_dismiss_msg:
    .text "\r\nNo companion to dismiss!\r\n[Press any key]\r\n"
    .byte 0

// === TAVERN SYSTEM ===
tavern_menu:
    ldx #0
tavern_menu_loop:
        lda tavern_menu_msg,X
        beq tavern_show_gold
        jsr modem_out
        inx
        bne tavern_menu_loop
tavern_show_gold:
    ldx #0
tavern_gold_loop:
        lda tavern_gold_msg,X
        beq tavern_gold_num
        jsr modem_out
        inx
        bne tavern_gold_loop
tavern_gold_num:
    lda player_gold
    jsr print_byte_decimal
    ldx #0
tavern_prompt_loop:
        lda tavern_prompt,X
        beq tavern_wait_key
        jsr modem_out
        inx
        bne tavern_prompt_loop
tavern_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_buy_ale
    jmp buy_ale
not_buy_ale:
    cmp #'2'
    bne not_buy_wine
    jmp buy_wine
not_buy_wine:
    cmp #'3'
    bne not_buy_mead
    jmp buy_mead
not_buy_mead:
    cmp #'4'
    bne not_hear_rumor
    jmp hear_rumor
not_hear_rumor:
    cmp #'0'
    bne tavern_wait_key
    jmp user_room_menu

buy_ale:
    // Ale costs 2g
    lda player_gold
    cmp #2
    bcc no_gold_tavern
    sec
    sbc #2
    sta player_gold
    inc drinks_bought
    lda #1
    sta tavern_buff
    lda #3
    sta tavern_timer
    ldx #0
ale_bought_loop:
        lda ale_bought_msg,X
        beq drink_done
        jsr modem_out
        inx
        bne ale_bought_loop

buy_wine:
    // Wine costs 5g
    lda player_gold
    cmp #5
    bcc no_gold_tavern
    sec
    sbc #5
    sta player_gold
    inc drinks_bought
    lda #2
    sta tavern_buff
    lda #5
    sta tavern_timer
    ldx #0
wine_bought_loop:
        lda wine_bought_msg,X
        beq drink_done
        jsr modem_out
        inx
        bne wine_bought_loop

buy_mead:
    // Mead costs 10g, heals HP
    lda player_gold
    cmp #10
    bcc no_gold_tavern
    sec
    sbc #10
    sta player_gold
    inc drinks_bought
    // Heal to full
    lda #25
    sta player_hp
    ldx #0
mead_bought_loop:
        lda mead_bought_msg,X
        beq drink_done
        jsr modem_out
        inx
        bne mead_bought_loop

drink_done:
    jsr modem_in
    jmp tavern_menu

no_gold_tavern:
    ldx #0
no_gold_tavern_loop:
        lda no_gold_drink_msg,X
        beq no_gold_tavern_done
        jsr modem_out
        inx
        bne no_gold_tavern_loop
no_gold_tavern_done:
    jsr modem_in
    jmp tavern_menu

hear_rumor:
    // Random rumor
    jsr get_random
    and #$03
    cmp #0
    bne rumor_not_0
    ldx #0
rumor0_loop:
        lda rumor0_msg,X
        beq rumor_done
        jsr modem_out
        inx
        bne rumor0_loop
rumor_not_0:
    cmp #1
    bne rumor_not_1
    ldx #0
rumor1_loop:
        lda rumor1_msg,X
        beq rumor_done
        jsr modem_out
        inx
        bne rumor1_loop
rumor_not_1:
    cmp #2
    bne rumor_not_2
    ldx #0
rumor2_loop:
        lda rumor2_msg,X
        beq rumor_done
        jsr modem_out
        inx
        bne rumor2_loop
rumor_not_2:
    ldx #0
rumor3_loop:
        lda rumor3_msg,X
        beq rumor_done
        jsr modem_out
        inx
        bne rumor3_loop
rumor_done:
    jsr modem_in
    jmp tavern_menu

tavern_menu_msg:
    .text "\r\n=== THE RUSTY FLAGON ===\r\n"
    .byte 0
tavern_gold_msg:
    .text "Your Gold: "
    .byte 0
tavern_prompt:
    .text "\r\n\r\n1. Ale (2g buff)\r\n2. Wine (5g buff)\r\n3. Mead (10g heal)\r\n4. Hear Rumor\r\n0. Back\r\n> "
    .byte 0
ale_bought_msg:
    .text "\r\nRefreshing! Luck buff active.\r\n[Press any key]\r\n"
    .byte 0
wine_bought_msg:
    .text "\r\nExquisite! Charm buff active.\r\n[Press any key]\r\n"
    .byte 0
mead_bought_msg:
    .text "\r\nHearty mead! HP fully restored!\r\n[Press any key]\r\n"
    .byte 0
no_gold_drink_msg:
    .text "\r\nNot enough gold!\r\n[Press any key]\r\n"
    .byte 0
rumor0_msg:
    .text "\r\nRumor: Dragon spotted near the mountains...\r\n[Press any key]\r\n"
    .byte 0
rumor1_msg:
    .text "\r\nRumor: Treasure buried in the old ruins...\r\n[Press any key]\r\n"
    .byte 0
rumor2_msg:
    .text "\r\nRumor: The king seeks brave adventurers...\r\n[Press any key]\r\n"
    .byte 0
rumor3_msg:
    .text "\r\nRumor: Strange lights seen in the forest...\r\n[Press any key]\r\n"
    .byte 0

// === DICE GAMBLING SYSTEM ===
dice_menu:
    ldx #0
dice_menu_loop:
        lda dice_menu_msg,X
        beq dice_show_stats
        jsr modem_out
        inx
        bne dice_menu_loop
dice_show_stats:
    ldx #0
dice_gold_loop:
        lda dice_gold_msg,X
        beq dice_gold_num
        jsr modem_out
        inx
        bne dice_gold_loop
dice_gold_num:
    lda player_gold
    jsr print_byte_decimal
    ldx #0
dice_wins_loop:
        lda dice_wins_msg,X
        beq dice_wins_num
        jsr modem_out
        inx
        bne dice_wins_loop
dice_wins_num:
    lda gamble_wins
    jsr print_byte_decimal
    ldx #0
dice_losses_loop:
        lda dice_losses_msg,X
        beq dice_losses_num
        jsr modem_out
        inx
        bne dice_losses_loop
dice_losses_num:
    lda gamble_losses
    jsr print_byte_decimal
    ldx #0
dice_prompt_loop:
        lda dice_prompt,X
        beq dice_wait_key
        jsr modem_out
        inx
        bne dice_prompt_loop
dice_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_bet_5
    jmp bet_five
not_bet_5:
    cmp #'2'
    bne not_bet_10
    jmp bet_ten
not_bet_10:
    cmp #'3'
    bne not_bet_25
    jmp bet_twentyfive
not_bet_25:
    cmp #'0'
    bne dice_wait_key
    jmp user_room_menu

bet_five:
    lda #5
    jmp do_dice_game
bet_ten:
    lda #10
    jmp do_dice_game
bet_twentyfive:
    lda #25
    jmp do_dice_game

do_dice_game:
    sta $02               // Store bet amount
    // Check if player has enough gold
    lda player_gold
    cmp $02
    bcc not_enough_bet
    // Roll dice (1-6)
    jsr get_random
    and #$07
    cmp #7
    bcc roll_ok
    and #$03
roll_ok:
    clc
    adc #1
    sta last_roll
    // Show roll
    ldx #0
gamble_rolled_loop:
        lda gamble_rolled_msg,X
        beq show_roll_num
        jsr modem_out
        inx
        bne gamble_rolled_loop
show_roll_num:
    lda last_roll
    jsr print_byte_decimal
    // High-low game: 4+ wins
    lda last_roll
    cmp #4
    bcs dice_win
    // Lost
    inc gamble_losses
    lda player_gold
    sec
    sbc $02
    sta player_gold
    ldx #0
gamble_lose_loop:
        lda gamble_lose_msg,X
        beq dice_result_done
        jsr modem_out
        inx
        bne gamble_lose_loop
dice_win:
    inc gamble_wins
    lda player_gold
    clc
    adc $02
    sta player_gold
    ldx #0
gamble_win_loop:
        lda gamble_win_msg,X
        beq dice_result_done
        jsr modem_out
        inx
        bne gamble_win_loop
dice_result_done:
    jsr modem_in
    jmp dice_menu

not_enough_bet:
    ldx #0
not_enough_loop:
        lda not_enough_msg,X
        beq not_enough_done
        jsr modem_out
        inx
        bne not_enough_loop
not_enough_done:
    jsr modem_in
    jmp dice_menu

dice_menu_msg:
    .text "\r\n=== DICE DEN ===\r\n"
    .byte 0
dice_gold_msg:
    .text "Gold: "
    .byte 0
dice_wins_msg:
    .text "  Wins: "
    .byte 0
dice_losses_msg:
    .text "  Losses: "
    .byte 0
dice_prompt:
    .text "\r\nRoll 4+ to win!\r\n1. Bet 5g\r\n2. Bet 10g\r\n3. Bet 25g\r\n0. Back\r\n> "
    .byte 0
gamble_rolled_msg:
    .text "\r\nYou rolled: "
    .byte 0
gamble_win_msg:
    .text "\r\nWIN! Double your bet!\r\n[Press any key]\r\n"
    .byte 0
gamble_lose_msg:
    .text "\r\nLost... better luck next time.\r\n[Press any key]\r\n"
    .byte 0
not_enough_msg:
    .text "\r\nNot enough gold to bet!\r\n[Press any key]\r\n"
    .byte 0

// === SCAVENGER HUNT SYSTEM ===
scavenge_menu:
    ldx #0
scavenge_menu_loop:
        lda scavenge_menu_msg,X
        beq scavenge_show_stats
        jsr modem_out
        inx
        bne scavenge_menu_loop
scavenge_show_stats:
    ldx #0
found_label_loop:
        lda found_label,X
        beq found_num
        jsr modem_out
        inx
        bne found_label_loop
found_num:
    lda items_found
    jsr print_byte_decimal
    ldx #0
hunts_label_loop:
        lda hunts_label,X
        beq hunts_num
        jsr modem_out
        inx
        bne hunts_label_loop
hunts_num:
    lda hunt_complete
    jsr print_byte_decimal
    ldx #0
scavenge_prompt_loop:
        lda scavenge_prompt,X
        beq scavenge_wait_key
        jsr modem_out
        inx
        bne scavenge_prompt_loop
scavenge_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_search_area
    jmp search_area
not_search_area:
    cmp #'2'
    bne not_check_list
    jmp check_hunt_list
not_check_list:
    cmp #'3'
    bne not_turn_in
    jmp turn_in_hunt
not_turn_in:
    cmp #'0'
    bne scavenge_wait_key
    jmp user_room_menu

search_area:
    // Random search result
    jsr get_random
    and #$03
    cmp #0
    beq found_nothing
    // Found an item!
    inc items_found
    // Update progress
    jsr get_random
    and #$07
    ora hunt_progress
    sta hunt_progress
    ldx #0
found_item_loop:
        lda found_item_msg,X
        beq search_done
        jsr modem_out
        inx
        bne found_item_loop
found_nothing:
    ldx #0
found_nothing_loop:
        lda found_nothing_msg,X
        beq search_done
        jsr modem_out
        inx
        bne found_nothing_loop
search_done:
    jsr modem_in
    jmp scavenge_menu

check_hunt_list:
    ldx #0
hunt_list_loop:
        lda hunt_list_msg,X
        beq show_hunt_progress
        jsr modem_out
        inx
        bne hunt_list_loop
show_hunt_progress:
    // Show which items found
    lda hunt_progress
    and #$01
    beq item1_not
    lda #'X'
    jsr modem_out
    jmp item2_check
item1_not:
    lda #'-'
    jsr modem_out
item2_check:
    lda hunt_progress
    and #$02
    beq item2_not
    lda #'X'
    jsr modem_out
    jmp item3_check
item2_not:
    lda #'-'
    jsr modem_out
item3_check:
    lda hunt_progress
    and #$04
    beq item3_not
    lda #'X'
    jsr modem_out
    jmp list_done
item3_not:
    lda #'-'
    jsr modem_out
list_done:
    ldx #0
list_end_loop:
        lda list_end_msg,X
        beq list_end_done
        jsr modem_out
        inx
        bne list_end_loop
list_end_done:
    jsr modem_in
    jmp scavenge_menu

turn_in_hunt:
    // Check if all 3 items found
    lda hunt_progress
    and #$07
    cmp #$07
    bne hunt_incomplete
    // Complete!
    inc hunt_complete
    lda #0
    sta hunt_progress
    lda player_gold
    clc
    adc #30
    sta player_gold
    ldx #0
hunt_done_loop:
        lda hunt_done_msg,X
        beq hunt_turn_done
        jsr modem_out
        inx
        bne hunt_done_loop
hunt_incomplete:
    ldx #0
hunt_incomplete_loop:
        lda hunt_incomplete_msg,X
        beq hunt_turn_done
        jsr modem_out
        inx
        bne hunt_incomplete_loop
hunt_turn_done:
    jsr modem_in
    jmp scavenge_menu

scavenge_menu_msg:
    .text "\r\n=== SCAVENGER HUNT ===\r\n"
    .byte 0
found_label:
    .text "Items Found: "
    .byte 0
hunts_label:
    .text "  Hunts Complete: "
    .byte 0
scavenge_prompt:
    .text "\r\n\r\n1. Search Area\r\n2. Check List\r\n3. Turn In\r\n0. Back\r\n> "
    .byte 0
found_item_msg:
    .text "\r\nYou found something!\r\n[Press any key]\r\n"
    .byte 0
found_nothing_msg:
    .text "\r\nNothing here...\r\n[Press any key]\r\n"
    .byte 0
hunt_list_msg:
    .text "\r\nHunt List: Gem-Scroll-Rune\r\nProgress: "
    .byte 0
list_end_msg:
    .text "\r\n[Press any key]\r\n"
    .byte 0
hunt_done_msg:
    .text "\r\nHUNT COMPLETE! +30 gold!\r\n[Press any key]\r\n"
    .byte 0
hunt_incomplete_msg:
    .text "\r\nFind all 3 items first!\r\n[Press any key]\r\n"
    .byte 0

// === MEDITATION SYSTEM ===
meditate_menu:
    ldx #0
meditate_menu_loop:
        lda meditate_menu_msg,X
        beq meditate_show_stats
        jsr modem_out
        inx
        bne meditate_menu_loop
meditate_show_stats:
    ldx #0
med_lvl_loop:
        lda med_lvl_msg,X
        beq med_lvl_num
        jsr modem_out
        inx
        bne med_lvl_loop
med_lvl_num:
    lda meditation_lvl
    jsr print_byte_decimal
    ldx #0
wisdom_loop:
        lda wisdom_msg,X
        beq wisdom_num
        jsr modem_out
        inx
        bne wisdom_loop
wisdom_num:
    lda wisdom_points
    jsr print_byte_decimal
    ldx #0
med_left_loop:
        lda med_left_msg,X
        beq med_left_num
        jsr modem_out
        inx
        bne med_left_loop
med_left_num:
    lda meditate_today
    jsr print_byte_decimal
    ldx #0
meditate_prompt_loop:
        lda meditate_prompt,X
        beq meditate_wait_key
        jsr modem_out
        inx
        bne meditate_prompt_loop
meditate_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_do_meditate
    jmp do_meditate
not_do_meditate:
    cmp #'2'
    bne not_deep_meditate
    jmp deep_meditate
not_deep_meditate:
    cmp #'3'
    bne not_level_up_med
    jmp level_up_meditation
not_level_up_med:
    cmp #'0'
    bne meditate_wait_key
    jmp user_room_menu

do_meditate:
    lda meditate_today
    beq no_med_left
    dec meditate_today
    // Heal HP based on level
    lda player_hp
    clc
    adc meditation_lvl
    adc meditation_lvl
    cmp #25
    bcc med_hp_ok
    lda #25
med_hp_ok:
    sta player_hp
    // Gain wisdom
    inc wisdom_points
    ldx #0
med_done_loop:
        lda med_done_msg,X
        beq med_result_done
        jsr modem_out
        inx
        bne med_done_loop

deep_meditate:
    lda meditate_today
    cmp #2
    bcc no_med_left
    // Uses 2 meditations
    dec meditate_today
    dec meditate_today
    // Full heal
    lda #25
    sta player_hp
    // More wisdom
    lda wisdom_points
    clc
    adc #3
    sta wisdom_points
    ldx #0
deep_done_loop:
        lda deep_done_msg,X
        beq med_result_done
        jsr modem_out
        inx
        bne deep_done_loop

med_result_done:
    jsr modem_in
    jmp meditate_menu

no_med_left:
    ldx #0
no_med_loop:
        lda no_med_msg,X
        beq no_med_done
        jsr modem_out
        inx
        bne no_med_loop
no_med_done:
    jsr modem_in
    jmp meditate_menu

level_up_meditation:
    // Cost: 10 wisdom
    lda wisdom_points
    cmp #10
    bcc not_enough_wisdom
    sec
    sbc #10
    sta wisdom_points
    inc meditation_lvl
    ldx #0
lvl_up_med_loop:
        lda lvl_up_med_msg,X
        beq lvl_up_med_done
        jsr modem_out
        inx
        bne lvl_up_med_loop
lvl_up_med_done:
    jsr modem_in
    jmp meditate_menu

not_enough_wisdom:
    ldx #0
need_wisdom_loop:
        lda need_wisdom_msg,X
        beq need_wisdom_done
        jsr modem_out
        inx
        bne need_wisdom_loop
need_wisdom_done:
    jsr modem_in
    jmp meditate_menu

meditate_menu_msg:
    .text "\r\n=== MEDITATION ===\r\n"
    .byte 0
med_lvl_msg:
    .text "Level: "
    .byte 0
wisdom_msg:
    .text "  Wisdom: "
    .byte 0
med_left_msg:
    .text "  Today: "
    .byte 0
meditate_prompt:
    .text "\r\n\r\n1. Meditate (heal)\r\n2. Deep (2x, full)\r\n3. Level Up (10wis)\r\n0. Back\r\n> "
    .byte 0
med_done_msg:
    .text "\r\nPeaceful... HP restored, +1 wisdom\r\n[Press any key]\r\n"
    .byte 0
deep_done_msg:
    .text "\r\nDeep trance... Full HP, +3 wisdom!\r\n[Press any key]\r\n"
    .byte 0
no_med_msg:
    .text "\r\nNo meditations left today!\r\n[Press any key]\r\n"
    .byte 0
lvl_up_med_msg:
    .text "\r\nMeditation level increased!\r\n[Press any key]\r\n"
    .byte 0
need_wisdom_msg:
    .text "\r\nNeed 10 wisdom to level up!\r\n[Press any key]\r\n"
    .byte 0

// === SPY NETWORK SYSTEM ===
spy_menu:
    ldx #0
spy_menu_loop:
        lda spy_menu_msg,X
        beq spy_show_stats
        jsr modem_out
        inx
        bne spy_menu_loop
spy_show_stats:
    ldx #0
spy_rank_loop:
        lda spy_rank_msg,X
        beq spy_rank_num
        jsr modem_out
        inx
        bne spy_rank_loop
spy_rank_num:
    lda spy_rank
    jsr print_byte_decimal
    ldx #0
intel_count_loop:
        lda intel_count_msg,X
        beq intel_count_num
        jsr modem_out
        inx
        bne intel_count_loop
intel_count_num:
    lda intel_gathered
    jsr print_byte_decimal
    ldx #0
missions_left_loop:
        lda missions_left_msg,X
        beq missions_left_num
        jsr modem_out
        inx
        bne missions_left_loop
missions_left_num:
    lda spy_missions
    jsr print_byte_decimal
    ldx #0
spy_prompt_loop:
        lda spy_prompt,X
        beq spy_wait_key
        jsr modem_out
        inx
        bne spy_prompt_loop
spy_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_gather_intel
    jmp gather_intel
not_gather_intel:
    cmp #'2'
    bne not_sabotage
    jmp do_sabotage
not_sabotage:
    cmp #'3'
    bne not_sell_intel
    jmp sell_intel
not_sell_intel:
    cmp #'0'
    bne spy_wait_key
    jmp user_room_menu

gather_intel:
    lda spy_missions
    beq no_spy_missions
    dec spy_missions
    // Random intel
    jsr get_random
    and #$03
    clc
    adc spy_rank
    clc
    adc intel_gathered
    sta intel_gathered
    ldx #0
intel_gathered_loop:
        lda intel_gathered_msg,X
        beq spy_result_done
        jsr modem_out
        inx
        bne intel_gathered_loop

do_sabotage:
    lda spy_missions
    beq no_spy_missions
    dec spy_missions
    // Sabotage success based on rank
    jsr get_random
    and #$03
    cmp spy_rank
    bcs sabotage_failed
    // Success - bonus gold
    lda player_gold
    clc
    adc #20
    sta player_gold
    ldx #0
sabotage_success_loop:
        lda sabotage_success_msg,X
        beq spy_result_done
        jsr modem_out
        inx
        bne sabotage_success_loop
sabotage_failed:
    ldx #0
sabotage_failed_loop:
        lda sabotage_failed_msg,X
        beq spy_result_done
        jsr modem_out
        inx
        bne sabotage_failed_loop

spy_result_done:
    jsr modem_in
    jmp spy_menu

no_spy_missions:
    ldx #0
no_missions_loop:
        lda no_missions_msg,X
        beq no_missions_done
        jsr modem_out
        inx
        bne no_missions_loop
no_missions_done:
    jsr modem_in
    jmp spy_menu

sell_intel:
    lda intel_gathered
    cmp #5
    bcc not_enough_intel
    // Sell 5 intel for gold
    sec
    sbc #5
    sta intel_gathered
    lda player_gold
    clc
    adc #15
    sta player_gold
    // Rank up check
    inc spy_rank
    lda spy_rank
    cmp #6
    bcc rank_ok
    lda #5
    sta spy_rank
rank_ok:
    ldx #0
intel_sold_loop:
        lda intel_sold_msg,X
        beq intel_sold_done
        jsr modem_out
        inx
        bne intel_sold_loop
intel_sold_done:
    jsr modem_in
    jmp spy_menu

not_enough_intel:
    ldx #0
need_intel_loop:
        lda need_intel_msg,X
        beq need_intel_done
        jsr modem_out
        inx
        bne need_intel_loop
need_intel_done:
    jsr modem_in
    jmp spy_menu

spy_menu_msg:
    .text "\r\n=== SPY NETWORK ===\r\n"
    .byte 0
spy_rank_msg:
    .text "Rank: "
    .byte 0
intel_count_msg:
    .text "  Intel: "
    .byte 0
missions_left_msg:
    .text "  Missions: "
    .byte 0
spy_prompt:
    .text "\r\n\r\n1. Gather Intel\r\n2. Sabotage (+20g)\r\n3. Sell Intel (5=15g)\r\n0. Back\r\n> "
    .byte 0
intel_gathered_msg:
    .text "\r\nIntel acquired!\r\n[Press any key]\r\n"
    .byte 0
sabotage_success_msg:
    .text "\r\nSabotage successful! +20 gold!\r\n[Press any key]\r\n"
    .byte 0
sabotage_failed_msg:
    .text "\r\nMission failed... escaped!\r\n[Press any key]\r\n"
    .byte 0
no_missions_msg:
    .text "\r\nNo missions left today!\r\n[Press any key]\r\n"
    .byte 0
intel_sold_msg:
    .text "\r\nIntel sold! +15g, Rank up!\r\n[Press any key]\r\n"
    .byte 0
need_intel_msg:
    .text "\r\nNeed 5 intel to sell!\r\n[Press any key]\r\n"
    .byte 0

// === ARENA BATTLE SYSTEM ===
arena_menu:
    ; Require arena ticket or season pass to enter
    lda arena_season_pass_owned
    bne arena_menu_continue
    lda arena_ticket_owned
    bne arena_consume_ticket
    ; No ticket or pass - show purchase prompt
    ldx #0
no_arena_ticket_loop:
        lda arena_no_ticket_msg,X
        beq no_arena_ticket_done
        jsr modem_out
        inx
        bne no_arena_ticket_loop
no_arena_ticket_done:
    jsr modem_in
    cmp #'1'
    beq buy_arena_ticket
    cmp #'2'
    beq buy_arena_pass
    cmp #'0'
    beq user_room_menu
    jmp arena_menu

arena_consume_ticket:
    lda #0
    sta arena_ticket_owned

arena_menu_continue:
    ldx #0
arena_menu_loop:
        lda arena_menu_msg,X
        beq arena_show_stats
        jsr modem_out
        inx
        bne arena_menu_loop
arena_show_stats:
    ldx #0
arena_rank_loop:
        lda arena_rank_msg,X
        beq arena_rank_num
        jsr modem_out
        inx
        bne arena_rank_loop
arena_rank_num:
    lda arena_rank
    jsr print_byte_decimal
    ldx #0
arena_wins_loop:
        lda arena_wins_msg,X
        beq arena_wins_num
        jsr modem_out
        inx
        bne arena_wins_loop
arena_wins_num:
    lda arena_wins
    jsr print_byte_decimal
    ldx #0
fights_left_loop:
        lda fights_left_msg,X
        beq fights_left_num
        jsr modem_out
        inx
        bne fights_left_loop
fights_left_num:
    lda arena_fights
    jsr print_byte_decimal
    ldx #0
arena_prompt_loop:
        lda arena_prompt,X
        beq arena_wait_key
        jsr modem_out
        inx
        bne arena_prompt_loop
arena_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_quick_fight
    jmp quick_fight
not_quick_fight:
    cmp #'2'
    bne not_ranked_fight
    jmp ranked_fight
not_ranked_fight:
    cmp #'3'
    bne not_arena_bet
    jmp arena_bet_fight
not_arena_bet:
    cmp #'4'
    bne not_view_rankings
    jmp view_arena_rankings
not_view_rankings:
    cmp #'5'
    bne not_view_leaderboard
    jmp view_arena_leaderboard
not_view_leaderboard:
    cmp #'0'
    bne arena_wait_key
    jmp user_room_menu

quick_fight:
    lda arena_fights
    beq no_fights_left
    dec arena_fights
    // Random fight outcome
    jsr get_random
    and #$01
    beq quick_fight_lose
    // Won!
    inc arena_wins
    jsr set_achievement_arena
    jsr update_arena_leaderboard
    inc duels_won
    lda player_gold
    clc
    adc #10
    sta player_gold
    ldx #0
quick_win_loop:
        lda quick_win_msg,X
        beq arena_result_done
        jsr modem_out
        inx
        bne quick_win_loop
quick_fight_lose:
    inc duels_lost
    lda player_hp
    sec
    sbc #5
    bcs quick_hp_ok
    lda #1
quick_hp_ok:
    sta player_hp
    ldx #0
quick_lose_loop:
        lda quick_lose_msg,X
        beq arena_result_done
        jsr modem_out
        inx
        bne quick_lose_loop

arena_result_done:
    jsr modem_in
    jmp arena_menu

no_fights_left:
    ldx #0
no_fights_loop:
        lda no_fights_msg,X
        beq no_fights_done
        jsr modem_out
        inx
        bne no_fights_loop
no_fights_done:
    jsr modem_in
    jmp arena_menu

ranked_fight:
    lda arena_fights
    beq no_fights_left
    dec arena_fights
    // Harder fight, better rewards
    jsr get_random
    and #$03
    cmp arena_rank
    bcc ranked_fight_win
    // Lost ranked
    inc duels_lost
    lda player_hp
    sec
    sbc #10
    bcs ranked_hp_ok
    lda #1
ranked_hp_ok:
    sta player_hp
    ldx #0
ranked_lose_loop:
        lda ranked_lose_msg,X
        beq arena_result_done
        jsr modem_out
        inx
        bne ranked_lose_loop
ranked_fight_win:
    inc arena_wins
    jsr set_achievement_arena
    jsr update_arena_leaderboard
    inc duels_won
    // Rank up check
    inc arena_rank
    lda arena_rank
    cmp #11
    bcc arena_rank_ok
    lda #10
    sta arena_rank
arena_rank_ok:
    lda player_gold
    clc
    adc #25
    sta player_gold
    ldx #0
ranked_win_loop:
        lda ranked_win_msg,X
        beq ranked_win_done
        jsr modem_out
        inx
        bne ranked_win_loop
ranked_win_done:
    jmp arena_result_done

arena_bet_fight:
    lda arena_fights
    bne bet_has_fights
    jmp no_fights_left
bet_has_fights:
    lda player_gold
    cmp #20
    bcs bet_can_afford
    jmp arena_too_poor
bet_can_afford:
    ; Show current prize pool and ask confirmation before placing bet
    ldx #0
pool_label_loop:
        lda pool_label_msg,X
        beq pool_label_done
        jsr modem_out
        inx
        bne pool_label_loop
pool_label_done:
    lda arena_prize_pool
    jsr print_byte_decimal
    jsr modem_in
    cmp #'Y'
    beq bet_confirmed
    cmp #'y'
    beq bet_confirmed
    jmp arena_menu
bet_confirmed:
    // Pay bet
    sec
    sbc #20
    sta player_gold
    dec arena_fights
    // High risk, high reward
    jsr get_random
    and #$01
    beq bet_fight_lose
    // Won bet!
    inc arena_wins
    jsr update_arena_leaderboard
    inc duels_won
    lda player_gold
    clc
    adc #50
    sta player_gold
    ; award up to 10g from prize pool if available
    lda arena_prize_pool+1
    bne bet_pool_amount_ten
    lda arena_prize_pool
    cmp #10
    bcc bet_pool_amount_from_low
    lda #10
    jmp bet_pool_amount_ready
bet_pool_amount_from_low:
    lda arena_prize_pool
bet_pool_amount_ready:
    sta temp_amount
    lda temp_amount
    clc
    adc player_gold
    sta player_gold
    lda player_gold+1
    adc #0
    sta player_gold+1
    ; subtract given amount from pool (16-bit)
    lda arena_prize_pool
    sec
    sbc temp_amount
    sta arena_prize_pool
    lda arena_prize_pool+1
    sbc #0
    sta arena_prize_pool+1
    ldx #0
bet_win_loop:
        lda bet_win_msg,X
        beq bet_win_done
        jsr modem_out
        inx
        bne bet_win_loop
bet_win_done:
    jsr set_achievement_arena
    jmp arena_result_done
bet_fight_lose:
    inc duels_lost
    lda player_hp
    sec
    sbc #15
    bcs bet_hp_ok
    lda #1
bet_hp_ok:
    sta player_hp
    ; Add lost bet (20g) to arena prize pool
    lda arena_prize_pool
    clc
    adc #20
    sta arena_prize_pool
    lda arena_prize_pool+1
    adc #0
    sta arena_prize_pool+1
    ldx #0
bet_lose_loop:
        lda bet_lose_msg,X
        beq bet_lose_done
        jsr modem_out
        inx
        bne bet_lose_loop
bet_lose_done:
    jmp arena_result_done

// Update arena leaderboard (top 3) using `arena_wins` as score
update_arena_leaderboard:
    lda arena_wins
    cmp arena_leader_1
    bcc check_leader_2
    ; shift 1->2, 2->3
    lda arena_leader_1
    sta arena_leader_2
    lda arena_leader_2
    sta arena_leader_3
    lda arena_wins
    sta arena_leader_1
    rts
check_leader_2:
    lda arena_wins
    cmp arena_leader_2
    bcc check_leader_3
    lda arena_leader_2
    sta arena_leader_3
    lda arena_wins
    sta arena_leader_2
    rts
check_leader_3:
    lda arena_wins
    cmp arena_leader_3
    bcc update_done
    lda arena_wins
    sta arena_leader_3
update_done:
    rts

arena_too_poor:
    ldx #0
arena_poor_loop:
        lda arena_poor_msg,X
        beq arena_poor_done
        jsr modem_out
        inx
        bne arena_poor_loop
arena_poor_done:
    jsr modem_in
    jmp arena_menu

arena_menu_msg:
    .text "\r\n=== DUELING ARENA ===\r\nGlory awaits the brave!\r\n"
    .byte 0
arena_rank_msg:
    .text "Rank: "
    .byte 0
arena_wins_msg:
    .text "  Wins: "
    .byte 0
fights_left_msg:
    .text "  Fights: "
    .byte 0
arena_prompt:
    .text "\r\n\r\n1. Quick Fight (+10g)\r\n2. Ranked (+25g,rank)\r\n3. Bet Fight (20g->50g)\r\n4. View Rankings\r\n5. View Leaderboard\r\n0. Back\r\n> "
    .byte 0
    .byte 0
quick_win_msg:
    .text "\r\nVictory! +10 gold!\r\n[Press any key]\r\n"
    .byte 0
quick_lose_msg:
    .text "\r\nDefeated... -5 HP\r\n[Press any key]\r\n"
    .byte 0
no_fights_msg:
    .text "\r\nNo fights left today!\r\n[Press any key]\r\n"
    .byte 0
ranked_win_msg:
    .text "\r\nRanked Victory! +25g, Rank up!\r\n[Press any key]\r\n"
    .byte 0
ranked_lose_msg:
    .text "\r\nRanked loss... -10 HP\r\n[Press any key]\r\n"
    .byte 0
bet_win_msg:
    .text "\r\nBet paid off! +50 gold!\r\n[Press any key]\r\n"
    .byte 0
bet_lose_msg:
    .text "\r\nLost your bet... -15 HP\r\n[Press any key]\r\n"
    .byte 0
arena_poor_msg:
    .text "\r\nNeed 20 gold to bet!\r\n[Press any key]\r\n"
    .byte 0

arena_no_ticket_msg:
    .text "\r\nYou need an Arena Ticket to enter the dueling pits.\r\n\r\n1. Buy Session Ticket (5 gold)\r\n2. Buy Season Pass (30 gold)\r\n0. Leave\r\n> "
    .byte 0

bought_arena_ticket_msg:
    .text "\r\nThe box office clerk hands you a small token.\r\n\r\n'This will grant you entrance for one arena session.'\r\n\r\n[Press any key]\r\n"
    .byte 0

no_gold_arena_ticket_msg:
    .text "\r\nYour purse is too light. Come back when you have more gold.\r\n\r\n[Press any key]\r\n"
    .byte 0

bought_arena_pass_msg:
    .text "\r\nThe clerk stamps a leather pass and hands it to you.\r\n\r\n'You now have unlimited arena entry for the season.'\r\n\r\n[Press any key]\r\n"
    .byte 0

already_has_arena_pass_msg:
    .text "\r\nThe clerk smiles: 'You already own an Arena Season Pass.'\r\n\r\n[Press any key]\r\n"
    .byte 0

buy_arena_ticket:
    lda arena_season_pass_owned
    bne buy_arena_already_pass
    lda player_gold
    cmp arena_ticket_price
    bcs buy_arena_ticket_enough
    lda player_gold+1
    bne buy_arena_ticket_enough
    ldx #0
no_gold_arena_ticket_loop2:
    lda no_gold_arena_ticket_msg,X
    beq no_gold_arena_ticket_done2
    jsr modem_out
    inx
    bne no_gold_arena_ticket_loop2
no_gold_arena_ticket_done2:
    jsr modem_in
    jmp arena_menu

buy_arena_ticket_enough:
    lda player_gold
    sec
    sbc arena_ticket_price
    sta player_gold
    lda player_gold+1
    sbc #0
    sta player_gold+1
    lda #1
    sta arena_ticket_owned
    ldx #0
bought_arena_ticket_loop2:
    lda bought_arena_ticket_msg,X
    beq bought_arena_ticket_done2
    jsr modem_out
    inx
    bne bought_arena_ticket_loop2
bought_arena_ticket_done2:
    jsr modem_in
    jmp arena_menu

buy_arena_pass:
    lda arena_season_pass_owned
    bne buy_arena_already_pass
    lda player_gold
    cmp arena_season_pass_price
    bcs buy_arena_pass_enough
    lda player_gold+1
    bne buy_arena_pass_enough
    ldx #0
no_gold_arena_pass_loop:
    lda no_gold_arena_ticket_msg,X
    beq no_gold_arena_pass_done
    jsr modem_out
    inx
    bne no_gold_arena_pass_loop
no_gold_arena_pass_done:
    jsr modem_in
    jmp arena_menu

buy_arena_pass_enough:
    lda player_gold
    sec
    sbc arena_season_pass_price
    sta player_gold
    lda player_gold+1
    sbc #0
    sta player_gold+1
    lda #1
    sta arena_season_pass_owned
    ldx #0
bought_arena_pass_loop:
    lda bought_arena_pass_msg,X
    beq bought_arena_pass_done
    jsr modem_out
    inx
    bne bought_arena_pass_loop
bought_arena_pass_done:
    jsr modem_in
    jmp arena_menu

buy_arena_already_pass:
    ldx #0
already_pass_loop:
    lda already_has_arena_pass_msg,X
    beq already_pass_done
    jsr modem_out
    inx
    bne already_pass_loop
already_pass_done:
    jsr modem_in
    jmp arena_menu

view_arena_rankings:
    ldx #0
rankings_hdr_loop:
        lda rankings_hdr_msg,X
        beq rankings_hdr_done
        jsr modem_out
        inx
        bne rankings_hdr_loop
rankings_hdr_done:
    // Show rating
    ldx #0
rating_label_loop:
        lda rating_label_msg,X
        beq rating_label_done
        jsr modem_out
        inx
        bne rating_label_loop
rating_label_done:
    lda arena_rating
    jsr print_byte_decimal
    // Show win/loss
    ldx #0
arena_wins_lbl_loop:
        lda wins_label_msg,X
        beq arena_wins_lbl_done
        jsr modem_out
        inx
        bne arena_wins_lbl_loop
arena_wins_lbl_done:
    lda duels_won
    jsr print_byte_decimal
    ldx #0
arena_losses_lbl_loop:
        lda losses_label_msg,X
        beq arena_losses_lbl_done
        jsr modem_out
        inx
        bne arena_losses_lbl_loop
arena_losses_lbl_done:
    lda duels_lost
    jsr print_byte_decimal
    // Show title
    ldx #0
title_label_loop:
        lda arena_title_label,X
        beq show_arena_title
        jsr modem_out
        inx
        bne title_label_loop
show_arena_title:
    lda arena_title
    cmp #1
    bne not_contender_title
    ldx #0
contender_loop:
        lda contender_title_msg,X
        beq arena_rank_key
        jsr modem_out
        inx
        bne contender_loop
not_contender_title:
    cmp #2
    bne not_gladiator_title
    ldx #0
gladiator_loop:
        lda gladiator_title_msg,X
        beq arena_rank_key
        jsr modem_out
        inx
        bne gladiator_loop
not_gladiator_title:
    cmp #3
    bne no_title_yet
    ldx #0
champion_loop:
        lda champion_title_msg,X
        beq arena_rank_key
        jsr modem_out
        inx
        bne champion_loop
no_title_yet:
    ldx #0
novice_loop:
        lda novice_title_msg,X
        beq arena_rank_key
        jsr modem_out
        inx
        bne novice_loop
arena_rank_key:
    ldx #0
rank_legend_loop:
        lda rank_legend_msg,X
        beq rank_legend_done
        jsr modem_out
        inx
        bne rank_legend_loop
rank_legend_done:
    jsr modem_in
    jmp arena_menu

view_arena_leaderboard:
    ldx #0
ldr_hdr_loop:
        lda leaderboard_hdr_msg,X
        beq ldr_hdr_done
        jsr modem_out
        inx
        bne ldr_hdr_loop
ldr_hdr_done:
    ; Show top 3 leader win counts
    ldx #0
    lda arena_leader_1
    jsr print_byte_decimal
    lda arena_leader_2
    jsr print_byte_decimal
    lda arena_leader_3
    jsr print_byte_decimal
    ; Show prize pool (low byte approx)
    ldx #0
    lda prize_pool_msg,X
    beq prize_pool_msg_done
    jsr modem_out
    inx
    bne prize_pool_msg_done
prize_pool_msg_done:
    lda arena_prize_pool
    jsr print_byte_decimal
    jsr modem_in
    jmp arena_menu

rankings_hdr_msg:
    .text "\r\n=== ARENA RANKINGS ===\r\n"
    .byte 0
rating_label_msg:
    .text "\r\nYour Rating: "
    .byte 0
wins_label_msg:
    .text "\r\nDuels Won: "
    .byte 0
losses_label_msg:
    .text "  Duels Lost: "
    .byte 0
arena_title_label:
    .text "\r\nTitle: "
    .byte 0
novice_title_msg:
    .text "Novice"
    .byte 0
contender_title_msg:
    .text "Contender"
    .byte 0
gladiator_title_msg:
    .text "Gladiator"
    .byte 0
champion_title_msg:
    .text "CHAMPION"
    .byte 0
rank_legend_msg:
    .text "\r\n\r\n--- TITLES ---\r\nNovice: 0-4 wins\r\nContender: 5-14 wins\r\nGladiator: 15-29 wins\r\nChampion: 30+ wins\r\n\r\n[Press any key]\r\n"
    .byte 0

// === MUSEUM SYSTEM ===
museum_menu:
    ldx #0
museum_menu_loop:
        lda museum_menu_msg,X
        beq museum_show_stats
        jsr modem_out
        inx
        bne museum_menu_loop
museum_show_stats:
    ldx #0
artifacts_stat_loop:
        lda artifacts_stat_msg,X
        beq artifacts_stat_num
        jsr modem_out
        inx
        bne artifacts_stat_loop
artifacts_stat_num:
    lda artifacts_found
    jsr print_byte_decimal
    ldx #0
donations_stat_loop:
        lda donations_stat_msg,X
        beq donations_stat_num
        jsr modem_out
        inx
        bne donations_stat_loop
donations_stat_num:
    lda museum_donations
    jsr print_byte_decimal
    ldx #0
pass_stat_loop:
        lda pass_stat_msg,X
        beq pass_stat_type
        jsr modem_out
        inx
        bne pass_stat_loop
pass_stat_type:
    lda museum_pass
    beq show_no_pass
    cmp #1
    beq show_member_pass
    ldx #0
patron_pass_loop:
        lda patron_pass_msg,X
        beq museum_prompt_out
        jsr modem_out
        inx
        bne patron_pass_loop
show_member_pass:
    ldx #0
member_pass_loop:
        lda member_pass_msg,X
        beq museum_prompt_out
        jsr modem_out
        inx
        bne member_pass_loop
show_no_pass:
    ldx #0
no_pass_loop:
        lda no_pass_msg,X
        beq museum_prompt_out
        jsr modem_out
        inx
        bne no_pass_loop
museum_prompt_out:
    ldx #0
museum_prompt_loop:
        lda museum_prompt,X
        beq museum_wait_key
        jsr modem_out
        inx
        bne museum_prompt_loop
museum_wait_key:
    jsr modem_in
    cmp #'1'
    bne not_view_exhibits
    jmp view_exhibits
not_view_exhibits:
    cmp #'2'
    bne not_donate_artifact
    jmp donate_artifact
not_donate_artifact:
    cmp #'3'
    bne not_buy_pass
    jmp buy_museum_pass
not_buy_pass:
    cmp #'0'
    bne museum_wait_key
    jmp user_room_menu

view_exhibits:
    lda museum_pass
    beq need_pass
    // Show random exhibit
    jsr get_random
    and #$03
    cmp #0
    bne exhibit_not_0
    ldx #0
exhibit0_loop:
        lda exhibit0_msg,X
        beq exhibit_done
        jsr modem_out
        inx
        bne exhibit0_loop
exhibit_not_0:
    cmp #1
    bne exhibit_not_1
    ldx #0
exhibit1_loop:
        lda exhibit1_msg,X
        beq exhibit_done
        jsr modem_out
        inx
        bne exhibit1_loop
exhibit_not_1:
    cmp #2
    bne exhibit_not_2
    ldx #0
exhibit2_loop:
        lda exhibit2_msg,X
        beq exhibit_done
        jsr modem_out
        inx
        bne exhibit2_loop
exhibit_not_2:
    ldx #0
exhibit3_loop:
        lda exhibit3_msg,X
        beq exhibit_done
        jsr modem_out
        inx
        bne exhibit3_loop
exhibit_done:
    // Chance to find artifact
    jsr get_random
    and #$03
    bne no_artifact_found
    inc artifacts_found
    ldx #0
artifact_found_loop:
        lda artifact_found_msg,X
        beq exhibit_result_done
        jsr modem_out
        inx
        bne artifact_found_loop
no_artifact_found:
    ldx #0
no_artifact_loop:
        lda no_artifact_msg,X
        beq exhibit_result_done
        jsr modem_out
        inx
        bne no_artifact_loop
exhibit_result_done:
    jsr modem_in
    jmp museum_menu

need_pass:
    ldx #0
need_pass_loop:
        lda need_pass_msg,X
        beq need_pass_done
        jsr modem_out
        inx
        bne need_pass_loop
need_pass_done:
    jsr modem_in
    jmp museum_menu

donate_artifact:
    lda artifacts_found
    beq no_artifacts
    dec artifacts_found
    inc museum_donations
    // Reward gold for donation
    lda player_gold
    clc
    adc #10
    sta player_gold
    ldx #0
donation_made_loop:
        lda donation_made_msg,X
        beq donation_made_done
        jsr modem_out
        inx
        bne donation_made_loop
donation_made_done:
    jsr modem_in
    jmp museum_menu

no_artifacts:
    ldx #0
no_artifacts_loop:
        lda no_artifacts_msg,X
        beq no_artifacts_done
        jsr modem_out
        inx
        bne no_artifacts_loop
no_artifacts_done:
    jsr modem_in
    jmp museum_menu

buy_museum_pass:
    lda museum_pass
    cmp #2
    bcs already_patron
    lda player_gold
    cmp #30
    bcc pass_too_poor
    sec
    sbc #30
    sta player_gold
    inc museum_pass
    ldx #0
pass_bought_loop:
        lda pass_bought_msg,X
        beq pass_bought_done
        jsr modem_out
        inx
        bne pass_bought_loop
pass_bought_done:
    jsr modem_in
    jmp museum_menu

already_patron:
    ldx #0
already_patron_loop:
        lda already_patron_msg,X
        beq already_patron_done
        jsr modem_out
        inx
        bne already_patron_loop
already_patron_done:
    jsr modem_in
    jmp museum_menu

pass_too_poor:
    ldx #0
pass_poor_loop:
        lda pass_poor_msg,X
        beq pass_poor_done
        jsr modem_out
        inx
        bne pass_poor_loop
pass_poor_done:
    jsr modem_in
    jmp museum_menu

museum_menu_msg:
    .text "\r\n=== MUSEUM ===\r\n"
    .byte 0
artifacts_stat_msg:
    .text "Artifacts: "
    .byte 0
donations_stat_msg:
    .text "  Donated: "
    .byte 0
pass_stat_msg:
    .text "  Pass: "
    .byte 0
no_pass_msg:
    .text "None"
    .byte 0
member_pass_msg:
    .text "Member"
    .byte 0
patron_pass_msg:
    .text "Patron"
    .byte 0
museum_prompt:
    .text "\r\n\r\n1. View Exhibits\r\n2. Donate Artifact (+10g)\r\n3. Buy Pass (30g)\r\n0. Back\r\n> "
    .byte 0
exhibit0_msg:
    .text "\r\nThe Dragon's Tooth - An ancient fang from the first dragon.\r\n"
    .byte 0
exhibit1_msg:
    .text "\r\nCrown of Everland - Worn by the forgotten king.\r\n"
    .byte 0
exhibit2_msg:
    .text "\r\nCrystal of Memories - Holds visions of the past.\r\n"
    .byte 0
exhibit3_msg:
    .text "\r\nShadow Blade - Forged in moonlight and shadow.\r\n"
    .byte 0
artifact_found_msg:
    .text "\r\nYou discovered a hidden artifact!\r\n[Press any key]\r\n"
    .byte 0
no_artifact_msg:
    .text "\r\nA fascinating exhibit!\r\n[Press any key]\r\n"
    .byte 0
need_pass_msg:
    .text "\r\nYou need a museum pass!\r\n[Press any key]\r\n"
    .byte 0
donation_made_msg:
    .text "\r\nThank you for your donation! +10g\r\n[Press any key]\r\n"
    .byte 0
no_artifacts_msg:
    .text "\r\nNo artifacts to donate!\r\n[Press any key]\r\n"
    .byte 0
pass_bought_msg:
    .text "\r\nMuseum pass acquired!\r\n[Press any key]\r\n"
    .byte 0
already_patron_msg:
    .text "\r\nYou're already a patron!\r\n[Press any key]\r\n"
    .byte 0
pass_poor_msg:
    .text "\r\nNeed 30 gold for a pass!\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// DAY/NIGHT CYCLE SYSTEM
// ============================================
time_menu:
    jsr advance_time      // Advance time with each visit
    ldx #0
time_menu_loop:
        lda time_menu_msg,X
        beq time_menu_show_time
        jsr modem_out
        inx
        bne time_menu_loop
time_menu_show_time:
    // Show current time of day
    lda time_of_day
    asl
    asl
    asl
    asl
    tax
    ldy #0
show_time_name:
        lda time_names,X
        beq time_menu_input
        jsr modem_out
        inx
        iny
        cpy #16
        bne show_time_name
time_menu_input:
    ldx #0
time_effects_loop:
        lda time_effects_msg,X
        beq time_get_input
        jsr modem_out
        inx
        bne time_effects_loop
time_get_input:
    jsr modem_in
    cmp #'1'
    beq time_check_shops
    cmp #'2'
    beq time_rest_til_dawn
    cmp #'0'
    beq time_back
    jmp time_menu
time_check_shops:
    lda time_of_day
    cmp #5         // Night?
    bne time_shops_open
    ldx #0
time_closed_loop:
        lda shops_closed_msg,X
        beq time_wait_key
        jsr modem_out
        inx
        bne time_closed_loop
    jmp time_wait_key
time_shops_open:
    ldx #0
time_open_loop:
        lda shops_open_msg,X
        beq time_wait_key
        jsr modem_out
        inx
        bne time_open_loop
time_wait_key:
    jsr modem_in
    jmp time_menu
time_rest_til_dawn:
    lda #0
    sta time_of_day
    sta action_counter
    ldx #0
rested_loop:
        lda rested_msg,X
        beq time_wait_key
        jsr modem_out
        inx
        bne rested_loop
    jmp time_wait_key
time_back:
    jmp main_loop

advance_time:
    inc action_counter
    lda action_counter
    cmp actions_per_phase
    bcc advance_time_done
    lda #0
    sta action_counter
    inc time_of_day
    lda time_of_day
    cmp #6
    bcc advance_time_done
    lda #0
    sta time_of_day   // Wrap to dawn
advance_time_done:
    rts

time_menu_msg:
    .text "\r\n=== TIME OF DAY ===\r\n\r\nCurrent time: "
    .byte 0
time_names:
    .text "Dawn            "   // 0
    .text "Morning         "   // 1
    .text "Midday          "   // 2
    .text "Afternoon       "   // 3
    .text "Evening         "   // 4
    .text "Night           "   // 5
time_effects_msg:
    .text "\r\n\r\nEffects:\r\n- Night: Some shops closed\r\n- Dawn: Best fishing\r\n- Evening: Tavern lively\r\n\r\n1. Check Shop Hours\r\n2. Rest Until Dawn\r\n0. Back\r\n> "
    .byte 0
shops_closed_msg:
    .text "\r\nMost shops are CLOSED at night.\r\nOnly the Tavern and Black Market open!\r\n[Press any key]\r\n"
    .byte 0
shops_open_msg:
    .text "\r\nAll shops are OPEN during the day!\r\n[Press any key]\r\n"
    .byte 0
rested_msg:
    .text "\r\nYou rest through the night...\r\nIt is now DAWN. HP restored!\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// PLAYER-TO-PLAYER TRADING SYSTEM
// ============================================
player_trade_menu:
    ldx #0
p2p_trade_loop:
        lda p2p_trade_menu_msg,X
        beq trade_get_input
        jsr modem_out
        inx
        bne p2p_trade_loop
trade_get_input:
    jsr modem_in
    cmp #'1'
    beq trade_initiate
    cmp #'2'
    beq go_trade_check_pending
    cmp #'3'
    beq go_trade_history
    cmp #'0'
    beq go_trade_back
    jmp player_trade_menu
go_trade_check_pending:
    jmp trade_check_pending
go_trade_history:
    jmp trade_history
go_trade_back:
    jmp trade_back
trade_initiate:
    ldx #0
trade_who_loop:
        lda trade_who_msg,X
        beq trade_who_input
        jsr modem_out
        inx
        bne trade_who_loop
trade_who_input:
    jsr modem_in
    sec
    sbc #'1'       // Convert to 0-7
    cmp #8
    bcs trade_invalid_slot
    sta trade_partner
    // Set up trade offer
    ldx #0
trade_offer_loop:
        lda trade_offer_msg,X
        beq trade_offer_gold_input
        jsr modem_out
        inx
        bne trade_offer_loop
trade_offer_gold_input:
    jsr modem_in
    sec
    sbc #'0'       // Simple 0-9 gold
    cmp #10
    bcs trade_invalid_gold
    asl
    asl
    asl            // Multiply by 8 for 0-72 gold
    sta trade_offer_gold
    // Mark trade pending
    lda #1
    sta trade_active
    ldx trade_partner
    lda #1
    sta trade_pending,X
    ldx #0
trade_sent_loop:
        lda trade_sent_msg,X
        beq trade_wait_key
        jsr modem_out
        inx
        bne trade_sent_loop
    jmp trade_wait_key
trade_invalid_slot:
trade_invalid_gold:
    ldx #0
trade_invalid_loop:
        lda trade_invalid_msg,X
        beq trade_wait_key
        jsr modem_out
        inx
        bne trade_invalid_loop
trade_wait_key:
    jsr modem_in
    jmp player_trade_menu
trade_check_pending:
    ldx user_slot
    lda trade_pending,X
    beq trade_no_pending
    // Accept trade
    ldx #0
trade_accept_loop:
        lda trade_accept_msg,X
        beq trade_confirm_input
        jsr modem_out
        inx
        bne trade_accept_loop
trade_confirm_input:
    jsr modem_in
    cmp #'Y'
    bne trade_decline
    // Complete trade
    lda #0
    ldx user_slot
    sta trade_pending,X
    lda trade_offer_gold
    clc
    adc player_gold
    sta player_gold
    ldx #0
trade_complete_loop:
        lda trade_complete_msg,X
        beq trade_wait_key
        jsr modem_out
        inx
        bne trade_complete_loop
    jmp trade_wait_key
trade_decline:
    lda #0
    ldx user_slot
    sta trade_pending,X
    jmp player_trade_menu
trade_no_pending:
    ldx #0
no_pending_loop:
        lda no_pending_msg,X
        beq trade_wait_key
        jsr modem_out
        inx
        bne no_pending_loop
    jmp trade_wait_key
trade_history:
    ldx #0
trade_history_loop:
        lda trade_history_msg,X
        beq trade_wait_key
        jsr modem_out
        inx
        bne trade_history_loop
    jmp trade_wait_key
trade_back:
    jmp main_loop

p2p_trade_menu_msg:
    .text "\r\n=== PLAYER TRADING ===\r\n\r\n1. Initiate Trade\r\n2. Check Pending Trades\r\n3. Trade History\r\n0. Back\r\n> "
    .byte 0
trade_who_msg:
    .text "\r\nTrade with which player slot (1-8)?\r\n> "
    .byte 0
trade_offer_msg:
    .text "\r\nHow much gold to offer (0-9 x8)?\r\n> "
    .byte 0
trade_sent_msg:
    .text "\r\nTrade offer sent!\r\nThey will see it when they log in.\r\n[Press any key]\r\n"
    .byte 0
trade_invalid_msg:
    .text "\r\nInvalid selection!\r\n[Press any key]\r\n"
    .byte 0
trade_accept_msg:
    .text "\r\nYou have a pending trade offer!\r\nAccept? (Y/N)\r\n> "
    .byte 0
trade_complete_msg:
    .text "\r\nTrade completed! Gold received!\r\n[Press any key]\r\n"
    .byte 0
no_pending_msg:
    .text "\r\nNo pending trades.\r\n[Press any key]\r\n"
    .byte 0
trade_history_msg:
    .text "\r\nRecent trades:\r\n- No trade history yet\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// DUNGEON CRAWL SYSTEM
// ============================================
dungeon_menu:
    ldx #0
dungeon_menu_loop:
        lda dungeon_menu_msg,X
        beq dungeon_get_input
        jsr modem_out
        inx
        bne dungeon_menu_loop
dungeon_get_input:
    jsr modem_in
    cmp #'1'
    beq dungeon_enter
    cmp #'2'
    beq dungeon_stats
    cmp #'0'
    beq dungeon_back
    jmp dungeon_menu
dungeon_enter:
    lda dungeon_level
    bne dungeon_continue
    // Start new crawl
    lda #1
    sta dungeon_level
    lda #100
    sta dungeon_hp
    lda #0
    sta dungeon_room
    sta dungeon_keys
    sta dungeon_gold_found
    ldx #0
    lda #0
clear_rooms:
    sta room_cleared,X
    inx
    cpx #10
    bne clear_rooms
dungeon_continue:
    jmp dungeon_explore
dungeon_stats:
    ldx #0
dungeon_stats_loop:
        lda dungeon_stats_msg,X
        beq dung_show_deepest
        jsr modem_out
        inx
        bne dungeon_stats_loop
dung_show_deepest:
    lda dungeon_deepest
    clc
    adc #'0'
    jsr modem_out
    ldx #0
dung_defeated_loop:
        lda bosses_defeated_msg,X
        beq dungeon_wait_key
        jsr modem_out
        inx
        bne dung_defeated_loop
dungeon_wait_key:
    jsr modem_in
    jmp dungeon_menu
dungeon_back:
    jmp main_loop

dungeon_explore:
    // Show current room
    ldx #0
dung_room_loop:
        lda dungeon_room_msg,X
        beq dung_show_level
        jsr modem_out
        inx
        bne dung_room_loop
dung_show_level:
    lda dungeon_level
    clc
    adc #'0'
    jsr modem_out
    lda #'-'
    jsr modem_out
    lda dungeon_room
    clc
    adc #'0'
    jsr modem_out
    // Generate room type if not cleared
    ldx dungeon_room
    lda room_cleared,X
    bne go_dung_room_cleared
    // Random room type
    jsr simple_random
    and #$07
    cmp #5
    bcc dung_room_valid
    lda #0             // Empty if >=5
dung_room_valid:
    sta room_type
    // Handle room type
    lda room_type
    cmp #1
    beq dung_monster
    cmp #2
    beq go_dung_treasure
    cmp #3
    beq go_dung_trap
    cmp #4
    beq go_dung_merchant
    jmp dung_empty_room
go_dung_room_cleared:
    jmp dung_room_cleared
go_dung_treasure:
    jmp dung_treasure
go_dung_trap:
    jmp dung_trap
go_dung_merchant:
    jmp dung_merchant
dung_empty_room:
    // Empty room
    ldx #0
dung_empty_loop:
        lda dung_empty_msg,X
        beq go_dung_room_done1
        jsr modem_out
        inx
        bne dung_empty_loop
go_dung_room_done1:
    jmp dung_room_done
dung_monster:
    ldx #0
dung_monster_loop:
        lda dung_monster_msg,X
        beq dung_fight
        jsr modem_out
        inx
        bne dung_monster_loop
dung_fight:
    // Simple combat - lose 10-20 HP, gain 5-15 gold
    jsr simple_random
    and #$0F
    clc
    adc #10
    sta $02            // Damage temp
    lda dungeon_hp
    sec
    sbc $02
    sta dungeon_hp
    bpl dung_survived
    // Died!
    lda #0
    sta dungeon_level
    ldx #0
dung_died_loop:
        lda dung_died_msg,X
        beq dungeon_wait_key2
        jsr modem_out
        inx
        bne dung_died_loop
dungeon_wait_key2:
    jsr modem_in
    jmp dungeon_menu
dung_survived:
    jsr simple_random
    and #$0F
    clc
    adc #5
    clc
    adc dungeon_gold_found
    sta dungeon_gold_found
    ldx #0
dung_victory_loop:
        lda dung_victory_msg,X
        beq go_dung_room_done2
        jsr modem_out
        inx
        bne dung_victory_loop
go_dung_room_done2:
    jmp dung_room_done
dung_treasure:
    jsr simple_random
    and #$1F
    clc
    adc #10
    clc
    adc dungeon_gold_found
    sta dungeon_gold_found
    ldx #0
dung_treasure_loop:
        lda dung_treasure_msg,X
        beq go_dung_room_done3
        jsr modem_out
        inx
        bne dung_treasure_loop
go_dung_room_done3:
    jmp dung_room_done
dung_trap:
    jsr simple_random
    and #$0F
    clc
    adc #5
    sta $02
    lda dungeon_hp
    sec
    sbc $02
    sta dungeon_hp
    bmi dung_trap_died
    ldx #0
dung_trap_loop:
        lda dung_trap_msg,X
        beq go_dung_room_done4
        jsr modem_out
        inx
        bne dung_trap_loop
go_dung_room_done4:
    jmp dung_room_done
dung_trap_died:
    lda #0
    sta dungeon_level
    jmp dungeon_wait_key2
dung_merchant:
    ldx #0
dung_merch_loop:
        lda dung_merchant_msg,X
        beq dung_merch_buy
        jsr modem_out
        inx
        bne dung_merch_loop
dung_merch_buy:
    jsr modem_in
    cmp #'Y'
    bne dung_room_done
    lda dungeon_gold_found
    cmp #20
    bcc dung_room_done
    sec
    sbc #20
    sta dungeon_gold_found
    lda dungeon_hp
    clc
    adc #30
    cmp #100
    bcc dung_hp_ok
    lda #100
dung_hp_ok:
    sta dungeon_hp
    jmp dung_room_done
dung_room_cleared:
    ldx #0
dung_cleared_loop:
        lda dung_cleared_msg,X
        beq dung_room_done
        jsr modem_out
        inx
        bne dung_cleared_loop
dung_room_done:
    ldx dungeon_room
    lda #1
    sta room_cleared,X
    // Show options
    ldx #0
dung_options_loop:
        lda dung_options_msg,X
        beq dung_options_input
        jsr modem_out
        inx
        bne dung_options_loop
dung_options_input:
    jsr modem_in
    cmp #'1'
    beq dung_go_forward
    cmp #'2'
    beq dung_go_back_room
    cmp #'3'
    beq dung_descend
    cmp #'0'
    beq dung_leave
    jmp dungeon_explore
dung_go_forward:
    inc dungeon_room
    lda dungeon_room
    cmp #10
    bcc dung_explore_next
    lda #9
    sta dungeon_room
dung_explore_next:
    jmp dungeon_explore
dung_go_back_room:
    dec dungeon_room
    bpl dung_explore_next
    lda #0
    sta dungeon_room
    jmp dungeon_explore
dung_descend:
    lda dungeon_room
    cmp #9
    bne dung_cant_descend
    // Next level!
    inc dungeon_level
    lda dungeon_level
    cmp dungeon_deepest
    bcc dung_not_record
    sta dungeon_deepest
dung_not_record:
    lda dungeon_level
    cmp #5
    bcc dung_normal_level
    // Level 5 = boss!
    jmp dungeon_boss_fight
dung_normal_level:
    lda #0
    sta dungeon_room
    ldx #0
    lda #0
dung_clear_new:
    sta room_cleared,X
    inx
    cpx #10
    bne dung_clear_new
    ldx #0
dung_descend_loop:
        lda dung_descend_msg,X
        beq dung_desc_wait
        jsr modem_out
        inx
        bne dung_descend_loop
dung_desc_wait:
    jsr modem_in
    jmp dungeon_explore
dung_cant_descend:
    ldx #0
dung_no_stairs_loop:
        lda dung_no_stairs_msg,X
        beq dung_no_wait
        jsr modem_out
        inx
        bne dung_no_stairs_loop
dung_no_wait:
    jsr modem_in
    jmp dungeon_explore
dung_leave:
    // Collect gold and exit
    lda dungeon_gold_found
    clc
    adc player_gold
    sta player_gold
    lda #0
    sta dungeon_level
    ldx #0
dung_exit_loop:
        lda dung_exit_msg,X
        beq dung_exit_wait
        jsr modem_out
        inx
        bne dung_exit_loop
dung_exit_wait:
    jsr modem_in
    jmp dungeon_menu

dungeon_boss_fight:
    // Mini dungeon boss
    lda #1
    ora dungeon_boss_defeated
    sta dungeon_boss_defeated
    ldx #0
dung_boss_loop:
        lda dung_boss_msg,X
        beq dung_boss_reward
        jsr modem_out
        inx
        bne dung_boss_loop
dung_boss_reward:
    lda dungeon_gold_found
    clc
    adc #50
    sta dungeon_gold_found
    lda #0
    sta dungeon_level
    jsr modem_in
    jmp dungeon_menu

simple_random:
    // Simple PRNG using timer
    lda $A2            // Use jiffy clock low byte
    eor dungeon_hp
    eor dungeon_room
    rts

dungeon_menu_msg:
    .text "\r\n=== DUNGEON CRAWL ===\r\n\r\nDescend into darkness...\r\n\r\n1. Enter Dungeon\r\n2. View Stats\r\n0. Back\r\n> "
    .byte 0
dungeon_stats_msg:
    .text "\r\nDungeon Stats:\r\nDeepest Level: "
    .byte 0
bosses_defeated_msg:
    .text "\r\nDungeon bosses defeated!\r\n[Press any key]\r\n"
    .byte 0
dungeon_room_msg:
    .text "\r\n--- LEVEL "
    .byte 0
dung_empty_msg:
    .text "\r\nAn empty chamber. Dust swirls...\r\n"
    .byte 0
dung_monster_msg:
    .text "\r\nA MONSTER attacks!\r\n*Combat ensues*\r\n"
    .byte 0
dung_victory_msg:
    .text "Victory! You found gold!\r\n"
    .byte 0
dung_died_msg:
    .text "\r\nYou have fallen in the dungeon!\r\nYour gold is lost...\r\n[Press any key]\r\n"
    .byte 0
dung_treasure_msg:
    .text "\r\nTREASURE! A chest of gold coins!\r\n"
    .byte 0
dung_trap_msg:
    .text "\r\nTRAP! Poison darts hit you!\r\n"
    .byte 0
dung_merchant_msg:
    .text "\r\nA shady MERCHANT offers healing.\r\n20 gold for 30 HP? (Y/N)\r\n> "
    .byte 0
dung_cleared_msg:
    .text "\r\nThis room is already cleared.\r\n"
    .byte 0
dung_options_msg:
    .text "\r\n\r\n1. Forward\r\n2. Back\r\n3. Descend (at room 9)\r\n0. Leave Dungeon\r\n> "
    .byte 0
dung_descend_msg:
    .text "\r\nYou descend deeper into darkness...\r\n[Press any key]\r\n"
    .byte 0
dung_no_stairs_msg:
    .text "\r\nNo stairs here. Reach room 9.\r\n[Press any key]\r\n"
    .byte 0
dung_exit_msg:
    .text "\r\nYou escape with your gold!\r\n[Press any key]\r\n"
    .byte 0
dung_boss_msg:
    .text "\r\n*** DUNGEON BOSS ***\r\nThe Shadow Guardian attacks!\r\n\r\n*Epic battle*\r\n\r\nVICTORY! +50 gold bonus!\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// BOSS ENCOUNTERS SYSTEM
// ============================================
boss_menu:
    ldx #0
boss_menu_loop:
        lda boss_menu_msg,X
        beq boss_get_input
        jsr modem_out
        inx
        bne boss_menu_loop
boss_get_input:
    jsr modem_in
    cmp #'1'
    beq boss_kasimere
    cmp #'2'
    beq boss_veylan
    cmp #'3'
    beq boss_dragon
    cmp #'4'
    beq boss_unseely
    cmp #'0'
    beq boss_back
    jmp boss_menu
boss_kasimere:
    lda boss_defeated
    and #$01
    bne boss_already_dead
    lda #1
    sta boss_active
    lda #<200
    sta boss_hp
    lda #>200
    sta boss_hp+1
    jmp boss_fight_loop
boss_veylan:
    lda boss_defeated
    and #$02
    bne boss_already_dead
    lda #2
    sta boss_active
    lda #<150
    sta boss_hp
    lda #>150
    sta boss_hp+1
    jmp boss_fight_loop
boss_dragon:
    lda boss_defeated
    and #$04
    bne boss_already_dead
    lda #3
    sta boss_active
    lda #<250
    sta boss_hp
    lda #>250
    sta boss_hp+1
    jmp boss_fight_loop
boss_unseely:
    lda boss_defeated
    and #$08
    bne boss_already_dead
    lda #4
    sta boss_active
    lda #<180
    sta boss_hp
    lda #>180
    sta boss_hp+1
    jmp boss_fight_loop
boss_already_dead:
    ldx #0
boss_dead_loop:
        lda boss_dead_msg,X
        beq boss_wait_key
        jsr modem_out
        inx
        bne boss_dead_loop
boss_wait_key:
    jsr modem_in
    jmp boss_menu
boss_back:
    jmp main_loop

boss_fight_loop:
    // Show boss intro based on boss_active
    lda boss_active
    cmp #1
    beq boss_show_kasimere
    cmp #2
    beq boss_show_veylan
    cmp #3
    beq boss_show_dragon
    jmp boss_show_unseely_king
boss_show_kasimere:
    ldx #0
boss_kas_intro:
        lda kasimere_intro_msg,X
        beq boss_combat
        jsr modem_out
        inx
        bne boss_kas_intro
    jmp boss_combat
boss_show_veylan:
    ldx #0
boss_vey_intro:
        lda veylan_intro_msg,X
        beq boss_combat
        jsr modem_out
        inx
        bne boss_vey_intro
    jmp boss_combat
boss_show_dragon:
    ldx #0
boss_drg_intro:
        lda dragon_intro_msg,X
        beq boss_combat
        jsr modem_out
        inx
        bne boss_drg_intro
    jmp boss_combat
boss_show_unseely_king:
    ldx #0
boss_uns_intro:
        lda unseely_intro_msg,X
        beq boss_combat
        jsr modem_out
        inx
        bne boss_uns_intro
boss_combat:
    ldx #0
boss_action_loop:
        lda boss_action_msg,X
        beq boss_action_input
        jsr modem_out
        inx
        bne boss_action_loop
boss_action_input:
    jsr modem_in
    cmp #'1'
    beq boss_attack
    cmp #'2'
    beq go_boss_spell
    cmp #'3'
    beq go_boss_flee
    jmp boss_combat
go_boss_spell:
    jmp boss_spell
go_boss_flee:
    jmp boss_flee
boss_attack:
    // Deal 15-25 damage
    jsr simple_random
    and #$0F
    clc
    adc #15
    sta $02
    lda boss_hp
    sec
    sbc $02
    sta boss_hp
    lda boss_hp+1
    sbc #0
    sta boss_hp+1
    bmi go_boss_defeated1
    lda boss_hp
    bne boss_counter
    lda boss_hp+1
    beq go_boss_defeated2
    jmp boss_counter
go_boss_defeated1:
    jmp boss_defeated_now
go_boss_defeated2:
    jmp boss_defeated_now
boss_counter:
    // Boss counterattack
    jsr simple_random
    and #$1F
    clc
    adc #10
    sta $02
    lda player_hp
    sec
    sbc $02
    sta player_hp
    bmi boss_player_died
    ldx #0
boss_exchange_loop:
        lda boss_exchange_msg,X
        beq boss_wait_combat
        jsr modem_out
        inx
        bne boss_exchange_loop
boss_wait_combat:
    jsr modem_in
    jmp boss_combat
boss_spell:
    // Magic attack - uses mana
    lda player_mana
    cmp #10
    bcc boss_no_mana
    sec
    sbc #10
    sta player_mana
    jsr simple_random
    and #$1F
    clc
    adc #25
    sta $02
    lda boss_hp
    sec
    sbc $02
    sta boss_hp
    lda boss_hp+1
    sbc #0
    sta boss_hp+1
    bmi go_boss_defeated3
    jmp boss_counter
go_boss_defeated3:
    jmp boss_defeated_now
boss_no_mana:
    ldx #0
boss_mana_loop:
        lda boss_no_mana_msg,X
        beq boss_wait_combat
        jsr modem_out
        inx
        bne boss_mana_loop
    jmp boss_wait_combat
boss_flee:
    ldx #0
boss_flee_loop:
        lda boss_fled_msg,X
        beq boss_fled_done
        jsr modem_out
        inx
        bne boss_flee_loop
boss_fled_done:
    lda #0
    sta boss_active
    jsr modem_in
    jmp boss_menu
boss_player_died:
    lda #20
    sta player_hp
    ldx #0
boss_lose_loop:
        lda boss_lose_msg,X
        beq boss_lose_done
        jsr modem_out
        inx
        bne boss_lose_loop
boss_lose_done:
    lda #0
    sta boss_active
    inc boss_attempts
    jsr modem_in
    jmp boss_menu
boss_defeated_now:
    // Mark boss as defeated
    lda boss_active
    tax
    lda #1
    dex
boss_shift:
    cpx #0
    beq boss_shift_done
    asl
    dex
    jmp boss_shift
boss_shift_done:
    ora boss_defeated
    sta boss_defeated
    // Reward
    lda player_gold
    clc
    adc #100
    sta player_gold
    ldx #0
boss_win_loop:
        lda boss_win_msg,X
        beq boss_win_done
        jsr modem_out
        inx
        bne boss_win_loop
boss_win_done:
    lda #0
    sta boss_active
    jsr modem_in
    jmp boss_menu

boss_menu_msg:
    .text "\r\n=== BOSS ENCOUNTERS ===\r\n\r\nFace the legends of darkness!\r\n\r\n1. Kasimere (Vampire Lord)\r\n2. Veylan (Dream Corruptor)\r\n3. Corrupted Dragon\r\n4. Unseely King\r\n0. Back\r\n> "
    .byte 0
boss_dead_msg:
    .text "\r\nThis boss has been defeated!\r\n[Press any key]\r\n"
    .byte 0
kasimere_intro_msg:
    .text "\r\n*** ARCH MAGUS KASIMERE ***\r\nThe ancient vampire lord emerges!\r\n'Soon we conquer this land also...'\r\n\r\n"
    .byte 0
veylan_intro_msg:
    .text "\r\n*** VEYLAN THE CORRUPTOR ***\r\nThe dream invader materializes!\r\n'Your nightmares are my domain...'\r\n\r\n"
    .byte 0
dragon_intro_msg:
    .text "\r\n*** CORRUPTED DRAGON ***\r\nOnce noble, now twisted by darkness!\r\nFlames lick the ancient stones...\r\n\r\n"
    .byte 0
unseely_intro_msg:
    .text "\r\n*** UNSEELY KING ***\r\n'Goofice Goafice Alakda!'\r\nDark fae magic swirls around you...\r\n\r\n"
    .byte 0
boss_action_msg:
    .text "\r\n1. Attack\r\n2. Cast Spell (10 mana)\r\n3. Flee\r\n> "
    .byte 0
boss_exchange_msg:
    .text "\r\nYou exchange blows!\r\n[Press any key]\r\n"
    .byte 0
boss_no_mana_msg:
    .text "\r\nNot enough mana!\r\n[Press any key]\r\n"
    .byte 0
boss_fled_msg:
    .text "\r\nYou flee from the battle!\r\n[Press any key]\r\n"
    .byte 0
boss_lose_msg:
    .text "\r\nYou have been defeated!\r\nYou wake at the town entrance...\r\n[Press any key]\r\n"
    .byte 0
boss_win_msg:
    .text "\r\n*** VICTORY! ***\r\nThe boss falls before you!\r\n+100 gold reward!\r\n[Press any key]\r\n"
    .byte 0

// ============================================
// SKILL TREE SYSTEM
// ============================================
skills_menu:
    ldx #0
skills_menu_loop:
        lda skills_menu_msg,X
        beq skills_show_points
        jsr modem_out
        inx
        bne skills_menu_loop
skills_show_points:
    lda skill_points
    clc
    adc #'0'
    jsr modem_out
    ldx #0
skills_trees_loop:
        lda skills_trees_msg,X
        beq skills_show_levels
        jsr modem_out
        inx
        bne skills_trees_loop
skills_show_levels:
    // Show combat level
    lda #'('
    jsr modem_out
    lda skill_combat
    clc
    adc #'0'
    jsr modem_out
    lda #')'
    jsr modem_out
    ldx #0
skills_show_magic:
        lda skills_magic_label,X
        beq skills_magic_num
        jsr modem_out
        inx
        cpx #16
        bne skills_show_magic
skills_magic_num:
    lda #'('
    jsr modem_out
    lda skill_magic
    clc
    adc #'0'
    jsr modem_out
    lda #')'
    jsr modem_out
    ldx #0
skills_show_social:
        lda skills_social_label,X
        beq skills_social_num
        jsr modem_out
        inx
        cpx #16
        bne skills_show_social
skills_social_num:
    lda #'('
    jsr modem_out
    lda skill_social
    clc
    adc #'0'
    jsr modem_out
    lda #')'
    jsr modem_out
    ldx #0
skills_show_surv:
        lda skills_surv_label,X
        beq skills_surv_num
        jsr modem_out
        inx
        cpx #16
        bne skills_show_surv
skills_surv_num:
    lda #'('
    jsr modem_out
    lda skill_survival
    clc
    adc #'0'
    jsr modem_out
    lda #')'
    jsr modem_out
    ldx #0
skills_prompt_loop:
        lda skills_prompt_msg,X
        beq skills_get_input
        jsr modem_out
        inx
        bne skills_prompt_loop
skills_get_input:
    jsr modem_in
    cmp #'1'
    beq skills_upgrade_combat
    cmp #'2'
    beq go_skills_magic
    cmp #'3'
    beq go_skills_social
    cmp #'4'
    beq go_skills_survival
    cmp #'5'
    beq go_skills_perks
    cmp #'0'
    beq go_skills_back2
    jmp skills_menu
go_skills_magic:
    jmp skills_upgrade_magic
go_skills_social:
    jmp skills_upgrade_social
go_skills_survival:
    jmp skills_upgrade_survival
go_skills_perks:
    jmp skills_view_perks
go_skills_back2:
    jmp skills_back
skills_upgrade_combat:
    lda skill_points
    beq go_skills_nopts0
    lda skill_combat
    cmp #10
    bcs go_skills_maxed0
    dec skill_points
    inc skill_combat
    jmp skills_combat_perk_check
go_skills_nopts0:
    jmp skills_no_points
go_skills_maxed0:
    jmp skills_maxed
skills_combat_perk_check:
    // Check for perk unlock at 3, 6, 9
    lda skill_combat
    cmp #3
    bne skill_not_3
    lda combat_perks
    ora #$01
    sta combat_perks
skill_not_3:
    lda skill_combat
    cmp #6
    bne skill_not_6
    lda combat_perks
    ora #$02
    sta combat_perks
skill_not_6:
    lda skill_combat
    cmp #9
    bne skill_upgraded
    lda combat_perks
    ora #$04
    sta combat_perks
skill_upgraded:
    ldx #0
skill_up_loop:
        lda skill_upgraded_msg,X
        beq skills_wait_key
        jsr modem_out
        inx
        bne skill_up_loop
skills_wait_key:
    jsr modem_in
    jmp skills_menu
skills_upgrade_magic:
    lda skill_points
    beq go_skills_nopts3
    lda skill_magic
    cmp #10
    bcs go_skills_maxed3
    dec skill_points
    inc skill_magic
    jmp skills_magic_perk_check
go_skills_nopts3:
    jmp skills_no_points
go_skills_maxed3:
    jmp skills_maxed
skills_magic_perk_check:
    lda skill_magic
    cmp #3
    bne magic_not_3
    lda magic_perks
    ora #$01
    sta magic_perks
magic_not_3:
    lda skill_magic
    cmp #6
    bne magic_not_6
    lda magic_perks
    ora #$02
    sta magic_perks
magic_not_6:
    lda skill_magic
    cmp #9
    bne go_skill_upgraded1
    lda magic_perks
    ora #$04
    sta magic_perks
go_skill_upgraded1:
    jmp skill_upgraded
skills_upgrade_social:
    lda skill_points
    beq go_skills_no_points1
    lda skill_social
    cmp #10
    bcs go_skills_maxed1
    dec skill_points
    inc skill_social
    lda skill_social
    cmp #3
    bne social_not_3
    lda social_perks
    ora #$01
    sta social_perks
social_not_3:
    lda skill_social
    cmp #6
    bne social_not_6
    lda social_perks
    ora #$02
    sta social_perks
social_not_6:
    lda skill_social
    cmp #9
    bne go_skill_upgraded2
    lda social_perks
    ora #$04
    sta social_perks
go_skill_upgraded2:
    jmp skill_upgraded
go_skills_no_points1:
    jmp skills_no_points
go_skills_maxed1:
    jmp skills_maxed

; -------------------------
; Achievements & Tutorial
; -------------------------
set_achievement_circus:
    lda player_feature_achievements
    ora #$01
    sta player_feature_achievements
    rts

set_achievement_arena:
    lda player_feature_achievements
    ora #$02
    sta player_feature_achievements
    rts

set_achievement_train:
    lda player_feature_achievements
    ora #$04
    sta player_feature_achievements
    rts

view_achievements:
    ldx #0
ach_hdr_loop:
        lda achievements_hdr_msg,X
        beq ach_hdr_done
        jsr modem_out
        inx
        bne ach_hdr_loop
ach_hdr_done:
    ; Circus
    lda player_feature_achievements
    and #$01
    beq ach_circus_locked
    ldx #0
    lda ach_circus_unlocked_msg,X
    beq ach_circus_done
    jsr modem_out
    inx
    bne ach_circus_unloop
ach_circus_unloop:
    jmp ach_circus_done
ach_circus_locked:
    ldx #0
    lda ach_circus_locked_msg,X
    beq ach_circus_done
    jsr modem_out
    inx
    bne ach_circus_locked
ach_circus_done:
    ; Arena
    lda player_feature_achievements
    and #$02
    beq ach_arena_locked
    ldx #0
    lda ach_arena_unlocked_msg,X
    beq ach_arena_done
    jsr modem_out
    inx
    bne ach_arena_unlocked_msg
ach_arena_done:
    lda player_feature_achievements
    and #$02
    beq ach_arena_skip
    jmp ach_arena_skip
ach_arena_locked:
    ldx #0
    lda ach_arena_locked_msg,X
    beq ach_arena_done2
    jsr modem_out
    inx
    bne ach_arena_locked
ach_arena_done2:
    jmp ach_train_check
ach_arena_skip:
    ; fallthrough
    nop
ach_train_check:
    lda player_feature_achievements
    and #$04
    beq ach_train_locked
    ldx #0
    lda ach_train_unlocked_msg,X
    beq ach_train_done
    jsr modem_out
    inx
    bne ach_train_unlocked_msg
ach_train_done:
    jsr modem_in
    jmp main_loop
ach_train_locked:
    ldx #0
    lda ach_train_locked_msg,X
    beq ach_train_done
    jsr modem_out
    inx
    bne ach_train_locked

tutorial_start:
    ldx #0
tut_loop:
        lda tutorial_msg,X
        beq tut_done
        jsr modem_out
        inx
        bne tut_loop
tut_done:
    jsr modem_in
    jmp main_loop

achievements_hdr_msg:
    .text "\r\n=== ACHIEVEMENTS ===\r\n"
    .byte 0
ach_circus_unlocked_msg:
    .text "Circus: Juggler's Adept (Unlocked)\r\n"
    .byte 0
ach_circus_locked_msg:
    .text "Circus: Juggler's Adept (Locked) - Win the Juggler's Challenge\r\n"
    .byte 0
ach_arena_unlocked_msg:
    .text "Arena: Challenger (Unlocked)\r\n"
    .byte 0
ach_arena_locked_msg:
    .text "Arena: Challenger (Locked) - Win an arena fight\r\n"
    .byte 0
ach_train_unlocked_msg:
    .text "Train: Traveler (Unlocked)\r\n"
    .byte 0
ach_train_locked_msg:
    .text "Train: Traveler (Locked) - Board the Everland Express\r\n"
    .byte 0

tutorial_msg:
    .text "\r\n=== QUICK TUTORIAL ===\r\n- Circus: Test your timing in the Juggler's Challenge (Town key Q).\r\n- Arena: Buy a ticket or a season pass to enter; bets contribute to the prize pool.\r\n- Train: Buy a ticket to ride or get a season pass for unlimited rides.\r\n\r\n[Press any key to continue]\r\n"
    .byte 0
skills_upgrade_survival:
    lda skill_points
    beq go_skills_no_points2
    lda skill_survival
    cmp #10
    bcs go_skills_maxed2
    dec skill_points
    inc skill_survival
    lda skill_survival
    cmp #3
    bne surv_not_3
    lda survival_perks
    ora #$01
    sta survival_perks
surv_not_3:
    lda skill_survival
    cmp #6
    bne surv_not_6
    lda survival_perks
    ora #$02
    sta survival_perks
surv_not_6:
    lda skill_survival
    cmp #9
    bne go_skill_upgraded3
    lda survival_perks
    ora #$04
    sta survival_perks
go_skill_upgraded3:
    jmp skill_upgraded
go_skills_no_points2:
    jmp skills_no_points
go_skills_maxed2:
    jmp skills_maxed
skills_no_points:
    ldx #0
skills_no_pts_loop:
        lda skills_no_points_msg,X
        beq skills_wait_key_near1
        jsr modem_out
        inx
        bne skills_no_pts_loop
skills_wait_key_near1:
    jmp skills_wait_key
skills_maxed:
    ldx #0
skills_max_loop:
        lda skills_maxed_msg,X
        beq skills_wait_key_near2
        jsr modem_out
        inx
        bne skills_max_loop
skills_wait_key_near2:
    jmp skills_wait_key
skills_view_perks:
    ldx #0
skill_perks_hdr_loop:
        lda skill_perks_hdr_msg,X
        beq perks_show_combat
        jsr modem_out
        inx
        bne skill_perks_hdr_loop
perks_show_combat:
    ldx #0
perks_combat_loop:
        lda perks_combat_msg,X
        beq perks_show_magic
        jsr modem_out
        inx
        bne perks_combat_loop
perks_show_magic:
    ldx #0
perks_magic_loop:
        lda perks_magic_msg,X
        beq perks_show_social
        jsr modem_out
        inx
        bne perks_magic_loop
perks_show_social:
    ldx #0
perks_social_loop:
        lda perks_social_msg,X
        beq perks_show_surv
        jsr modem_out
        inx
        bne perks_social_loop
perks_show_surv:
    ldx #0
perks_surv_loop:
        lda perks_surv_msg,X
        beq perks_done
        jsr modem_out
        inx
        bne perks_surv_loop
perks_done:
    jsr modem_in
    jmp skills_menu
skills_back:
    jmp main_loop

skills_menu_msg:
    .text "\r\n=== SKILL TREES ===\r\n\r\nLevel up to earn skill points!\r\nSpend them to unlock abilities.\r\n\r\nSkill Points: "
    .byte 0
skills_trees_msg:
    .text "\r\n\r\n1. COMBAT "
    .byte 0
skills_magic_label:
    .text "\r\n2. MAGIC "
    .byte 0
skills_social_label:
    .text "\r\n3. SOCIAL "
    .byte 0
skills_surv_label:
    .text "\r\n4. SURVIVAL "
    .byte 0
skills_prompt_msg:
    .text "\r\n\r\n5. View Perks\r\n0. Back\r\n> "
    .byte 0
skill_upgraded_msg:
    .text "\r\nSkill upgraded!\r\n[Press any key]\r\n"
    .byte 0
skills_no_points_msg:
    .text "\r\nNo skill points available!\r\n[Press any key]\r\n"
    .byte 0
skills_maxed_msg:
    .text "\r\nThis skill is already maxed!\r\n[Press any key]\r\n"
    .byte 0
skill_perks_hdr_msg:
    .text "\r\n=== UNLOCKED PERKS ===\r\n\r\n"
    .byte 0
perks_combat_msg:
    .text "COMBAT:\r\n Lv3: +5 damage\r\n Lv6: Crit chance\r\n Lv9: Double attack\r\n\r\n"
    .byte 0
perks_magic_msg:
    .text "MAGIC:\r\n Lv3: +10 mana\r\n Lv6: Spell power+\r\n Lv9: Free spell/day\r\n\r\n"
    .byte 0
perks_social_msg:
    .text "SOCIAL:\r\n Lv3: Better prices\r\n Lv6: More XP\r\n Lv9: Faction bonus\r\n\r\n"
    .byte 0
perks_surv_msg:
    .text "SURVIVAL:\r\n Lv3: More HP\r\n Lv6: Find items\r\n Lv9: Cheat death\r\n\r\n[Press any key]\r\n"
    .byte 0

// End of file
