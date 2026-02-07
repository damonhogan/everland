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
//   Bit 2: Slayed 10 Monsters
//   Bit 3: Completed a Quest
//   Bit 4: Made a Friend
//   Bit 5: Visited 5 Rooms
//   Bit 6: Earned 1000 Gold
//   Bit 7: Master Adventurer

// --- Gifting System Data ---
player_gold: .word 100               // Player's gold balance
player_gems: .byte 10                // Player's gem balance
received_gifts: .fill 80, 0          // 5 gifts x 16 bytes (from:8, type:1, amount:1, msg:6)
received_gifts_count: .byte 0        // Number of pending gifts
gift_types_count: .byte 4            // Number of gift types
gift_type_names:
    .text "Gold    "                // 8 chars each
    .text "Gems    "
    .text "Flower  "
    .text "Trophy  "
gift_type_costs: .byte 10, 5, 2, 20  // Cost in gold for each gift type

// --- Room Events Data ---
user_events: .fill 96, 0             // 3 events x 32 bytes (title:16, time:8, type:1, attendees:7)
user_events_count: .byte 0           // Number of scheduled events
event_types_count: .byte 6
event_type_names:
    .text "Party   "                // 8 chars each
    .text "Game    "
    .text "Meeting "
    .text "Contest "
    .text "Lantern "                // Dragon Lantern Festival (October)
    .text "Feast   "                // Realm feast events

// --- Trade System Data ---
player_inventory: .fill 32, 0        // 8 items x 4 bytes (id, count, 2 reserved)
player_inventory_count: .byte 3      // Start with 3 items
trade_offers: .fill 48, 0            // 3 trade offers x 16 bytes
trade_offers_count: .byte 0
item_names:
    .text "Sword   "                // 8 chars each
    .text "Shield  "
    .text "Potion  "
    .text "Ring    "
    .text "Amulet  "
    .text "Scroll  "
    .text "Gem     "
    .text "Key     "

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

// --- Room Shop Data ---
shop_items_count: .byte 6
shop_item_names:
    .text "Fancy Rug       "  // 16 chars each
    .text "Crystal Lamp    "
    .text "Gold Frame      "
    .text "Magic Mirror    "
    .text "Royal Banner    "
    .text "Ancient Statue  "
shop_item_prices: .byte 25, 40, 60, 80, 100, 150
shop_item_owned: .byte 0, 0, 0, 0, 0, 0  // 0=not owned, 1=owned

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
auction_current_bid: .byte 0        