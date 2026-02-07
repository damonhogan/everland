# Everland BBS Door Game — Complete Manual

## Overview

Everland BBS Door Game is a text-adventure door game for BBS systems, written in Kick Assembler for the Commodore 64. This is a multi-user online game designed to run as a BBS door, featuring rich lore, quests, NPCs, and social features.

**Build:** Memory Map $c000-$200aa (~65KB)

---

## Table of Contents

1. [Complete Feature List](#complete-feature-list)
2. [Portal System & Realms](#portal-system--realms)
3. [Town of Everland Locations](#town-of-everland-locations)
4. [NPC Directory](#npc-directory)
5. [Social & Room Features](#social--room-features)
6. [Events System](#events-system)
7. [Economy & Trading](#economy--trading)
8. [Mini-Games & Activities](#mini-games--activities)
9. [Magic System](#magic-system)
10. [Romance & Wedding System](#romance--wedding-system)
11. [Dream System](#dream-system)
12. [Ship Travel System](#ship-travel-system)
13. [Faction Reputation System](#faction-reputation-system)
14. [Dueling Arena](#dueling-arena)
15. [Build Instructions](#build-instructions)
16. [Appendix A: Complete Quest Walkthrough](#appendix-a-complete-quest-walkthrough)
17. [Appendix B: Memory Expansion Support](#appendix-b-memory-expansion-support)

---

## Complete Feature List

### Core Systems (50+ Features)

#### Portal & Travel System
- **5 Portal Destinations**: Aurora, Lore, Mythos, Town of Everland, England
- **25 Town Locations**: Full town with shops, taverns, landmarks, and NPCs
- **Realm Calendar**: 12 monthly seasonal events including October's Dragon Lantern Festival

#### NPC & Quest System
- **40+ Unique NPCs** with dialogue, quests, and lore
- **Multi-step Quest Chains**: 4-step quest progressions for most NPCs
- **Branching Choices**: Fight/Negotiate, Help/Betray decision points
- **Guild Memberships**: Order of Black Rose, Frost Weavers, Order of Emerald Sky, Unseely Court, Order of the Owls, Wolves of Winter

#### Room & Social Features
- **Personal Rooms**: Customizable player rooms with descriptions and decorations
- **ASCII Art Editor**: Create and display custom room art
- **Guestbook System**: Leave and read visitor messages
- **Privacy Settings**: Control who can visit your room
- **Friends List**: Manage friend connections
- **Visitor Log**: Track who visited your room
- **Messaging System**: Send messages to other players
- **Profile System**: Customizable player profiles

#### Events System
- **Personal Events**: Create, view, and cancel personal events
- **Event Types**: Party, Game, Meeting, Contest, Lantern (festival), Feast
- **Realm Calendar**: 12 monthly events tied to lore
- **Browse Events**: See all events across the realm

#### Economy & Trade
- **Coin System**: Gold, Silver, Copper currencies
- **Trade System**: Create and browse trade offers
- **Inventory Management**: 8-slot inventory with item tracking
- **Bank System**: Deposit, withdraw, and exchange currencies
- **Auction House**: Buy and sell items
- **Shop System**: Purchase room decorations and items
- **Dynamic Exchange Rates**: Fluctuating currency values

#### Mini-Games & Activities
- **Lottery System**: Weekly drawings with prizes
- **Dice Games**: Gambling mini-game
- **Fishing**: Catch fish for rewards
- **Racing**: Compete in races
- **Treasure Hunting**: Find hidden treasures
- **Cooking**: Craft food items
- **Dueling**: PvP combat system
- **Arena**: Combat challenges
- **Riddles**: Puzzle challenges
- **Scavenging**: Find random items

#### Character Progression
- **Daily Rewards**: Login streak bonuses (7-day cycle)
- **Quests System**: Track and complete quests for rewards
- **Achievements**: Unlock accomplishments
- **Badges**: Collectible badges
- **Titles**: Earn titles for accomplishments
- **Reputation System**: Build standing with factions
- **Hall of Fame**: Leaderboards

#### Pets & Companions
- **Pet System**: Adopt and care for pets
- **Companion System**: AI companions that assist
- **Garden System**: Grow plants and herbs

#### Crafting & Production
- **Crafting Menu**: Create items from materials
- **Potion Brewing**: Create magical potions
- **Weather System**: Dynamic weather affecting gameplay

#### Magic & Spells
- **Mana System**: 20 max mana, regenerates over time
- **Three Frost Weaver Spells**: GLACIOUS (frost bolt), NIX (ice shield), ILLUMINA (light burst)
- **Spell Learning**: Progressive prerequisites (GLACIOUS → NIX → ILLUMINA)
- **Frost Weaver Ranks**: Initiate, Adept, Master with increasing power
- **Third Eye Practice**: Pendulum mastery training (10 levels)
- **Meditation**: Restore mana through focused concentration
- **Spell Lore**: Study the ancient traditions of the Frost Weavers

#### Romance & Wedding System
- **4 Romance Options**: Kira, Lyra, Kendrick, Bonny Red Boots
- **Courtship Stages**: Introduced → Courting → Engaged → Married
- **Gift Giving**: Increase affection with romantic gifts
- **Dating**: Go on dates to deepen your bond
- **Wedding Ceremony**: Marry your beloved in the Rose Gardens

#### Dream System
- **4 Dream Types**: Peaceful, Nightmare, Prophetic, Memory
- **Veylan's Influence**: Battle the shadow's corruption
- **Dream Protection**: Pendulum mastery provides shields
- **Prophecies**: Receive visions of future events

#### Ship Travel System
- **4 Ports**: Everland Harbor, Aurora Ice Docks, Mythos Jungle Bay, Whitecastle
- **Sea Trading**: Buy cargo low, sail far, sell high
- **Sea Encounters**: Storms and pirate encounters
- **The Black Siren**: Captain Pit Plum's legendary vessel

#### Faction Reputation
- **7 Factions**: Frost Weavers, Merchant Guild, Order of Black Rose, Wolves of Winter, Order of the Owls, Black Siren Crew
- **Standings**: 0-25 Hostile, 26-50 Neutral, 51-75 Friendly, 76-100 Exalted
- **Faction Perks**: Unlock rewards as reputation grows

#### Dueling Arena
- **Arena Ratings**: Competitive ranking system
- **Win/Loss Tracking**: Track your combat record
- **Arena Titles**: Novice → Contender → Gladiator → Champion
- **Bet Fights**: Risk gold for greater rewards

#### Administrative Features
- **Admin Menu**: User management tools
- **Ban/Unban System**: Moderation controls
- **User Slot System**: Multi-user profile management

---

## Portal System & Realms

### Main Portal Destinations

#### 1. Aurora (Land of Frost and Light)
- **Theme**: Snow-capped peaks, ice magic, winter
- **Key NPCs**: Frost Weaver Queen, Winter Wolf
- **Quests**: Frost spell mastery, wolf challenge survival
- **Guild**: Frost Weavers Guild

#### 2.Lore (Kingdom of Knights and Memory)
- **Theme**: Medieval kingdom, knights, ancient oaths
- **Key NPCs**: Lady Cordelia, Grim the Blackheart
- **Quests**: Knight's oath, Battle for the Cursed Garden
- **Guild**: Order of the Black Rose
- **Special Location**: Cursed Garden (Pumpkin King battle)

#### 3. Mythos (Realm of Jungles and Secrets)
- **Theme**: Lush jungles, dragons, ancient mysteries
- **Key NPCs**: Dragon Queen, Ancient Mystic
- **Quests**: Dragon scale retrieval, trainer initiation
- **Guild**: Order of the Emerald Sky

#### 4. Town of Everland (Hub World)
- **Theme**: Central town with 25 sub-locations
- **See**: [Town of Everland Locations](#town-of-everland-locations)

#### 5. England (Whitecastle)
- **Theme**: Countryside and castle
- **Locations**: Whitecastle, Countryside

---

## Town of Everland Locations

### Complete Location Directory (25 Locations)

| Key | Location | Description | Key NPCs |
|-----|----------|-------------|----------|
| 1 | Train Station | Grand clock tower, steam trains | Damsel of the Mist |
| 2 | Tipsy Maiden Tavern | Laughter, song, ale | Bartender |
| 3 | Kettle Cafe | Tea, pastries, warmth | - |
| 4 | Copper Confection | Candies, frozen treats | - |
| 5 | Glass House | Exotic creatures, phoenix | - |
| 6 | Dragon Haven | Dragon training, obsidian spires | Dragon Trainers |
| 7 | Temple Ruins | Ancient faith, Order of Emerald Sky | Alister, Torin |
| 8 | Louden's Rest | Graveyard, honored dead | Tosh |
| 9 | The Moselem | Domed towers, ancient wisdom | Kasimere |
| A | Fairy Gardens | Pumpkin fairies, magical grove | Lezule, Marmalade, Marigold, Butterscotch |
| B | Arena | Combat challenges, glory | - |
| C | Pirate Ship (Black Siren) | Captain's vessel, rogues | Pit Plum, Bonny Red Boots, Shadow Ford |
| D | Tower | Order of the Owls headquarters | Garrett, Fletcher, Poppy |
| E | Church | Stained glass, serene worship | Bishop Cordelia, Cedric |
| F | Catacombs | Underground tunnels, bones | Samuel |
| G | Statue of Michael | Bronze memorial | - |
| H | Marketplace | Commerce, stalls, trading | Bridge the Troll |
| I | Witch's Tent | Herbs, cauldrons, potions | Tammis, Saga |
| J | Hunter's Hovel | Knights (summer), Wolves (winter) | Wulfric, Lyra |
| K | The Burrows | Frost Weaver gathering halls | Frost Queen |
| L | Mystic's Tent | Forbidden knowledge, secrets | Mela, Kal, Daemos |
| M | Moon Portal | Silver gateway, moonstone arch | - |
| N | Central Plaza | Fountain, heart of Everland | Spider Princess, Kora, Kendrick |
| O | The Bridge | Stone arch, troll home | Bridge, Dante, Candy Witch |
| P | Kira's Apothecary | Remedies, healing, romance | Kira |

---

## NPC Directory

### Major NPCs by Location

#### Aurora NPCs
| NPC | Role | Quest Chain |
|-----|------|-------------|
| Frost Weaver Queen | Guild Leader | Frost spell initiation (GLACIOUS, NIX, ILLUMINA) |
| Winter Wolf | Guardian | Pact of Winter's Howl trials |

#### Lore NPCs
| NPC | Role | Quest Chain |
|-----|------|-------------|
| Lady Cordelia | Knight Commander | Memory restoration, Knight's Oath, Order of Black Rose |
| Grim the Blackheart | Warrior | Final assault on Cursed Garden, enchanted spear |
| Gwen | Mourner | Honor Grim's sacrifice, plant black roses |

---

## Recent Additions & Updates

- **Train Timetable & Announcements**: The Everland Express now includes an in-game timetable accessible at the Train Station (`3. View Timetable`). The conductor will announce the next stop as the train approaches. This improves navigation and immersion for players using the station and train system.


#### Mythos NPCs
| NPC | Role | Quest Chain |
|-----|------|-------------|
| Dragon Queen | Ruler | Dragon scale retrieval, dragon lore |
| Ancient Mystic | Sage | Hidden treasure, wisdom |

#### Town NPCs (Alphabetical)
| NPC | Location | Quest Chain |
|-----|----------|-------------|
| Alister | Temple Ruins | Dragon Trainer Oaths (Order of Emerald Sky) |
| Bishop Cordelia | Church | Green thorn oath, blessing |
| Bonny Red Boots | Pirate Ship | Last Shackle song, freedom ballad |
| Bridge the Troll | Marketplace/Bridge | Trinket trading, mischief pranks |
| Butterscotch | Fairy Gardens | Human alliance, crop tending |
| Candy Witch | The Bridge | Chaos quests, ward destruction |
| Captain Pit Plum | Pirate Ship | Pirate's Trials (trade, flags, combat) |
| Captain Shadow Ford | Pirate Ship | Combat training (footwork, parrying) |
| Cedric | Church | Redemption arc, renounce Kasimere |
| Damsel of the Mist | Train Station | Destiny quest, blue light guidance |
| Dante | The Bridge | Fracture containment, ward strengthening |
| Daemos | Mystic's Tent | Dark covenant (Warning: vampire!) |
| Fletcher | Tower | Archery, Order of Owls |
| Frost Queen | The Burrows | Frost Weaver initiation ritual |
| Garrett | Tower | Order of Owls founding, wisdom trials |
| Kal | Mystic's Tent | Promises of power (Warning: vampire!) |
| Kasimere | The Moselem | Vampire lord - Help or Betray choice |
| Kendrick | Central Plaza | Spider Princess protection |
| Kira | Kira's Apothecary | Healing, romance, mutual craft |
| Kora | Central Plaza | Spider Princess guardian |
| Lezule | Fairy Gardens | Stolen names protection |
| Lyra | Hunter's Hovel | Wolf negotiations, Pact of Winter's Howl |
| Marigold | Fairy Gardens | Potion ingredients quest |
| Marmalade | Fairy Gardens | Prank quest chain |
| Mela | Mystic's Tent | Immortality temptation (Warning: vampire!) |
| Poppy | Tower | Feast sponsorship, Order of Owls |
| Pumpkin King | Cursed Garden | Boss battle - Fight or Negotiate |
| Saga | Witch's Tent | Prophecy, destiny revelation |
| Samuel | Catacombs | Third eye activation, pendulum mastery |
| Spider Princess | Central Plaza | Magical artifact gift, spider blessing |
| Tammis | Witch's Tent | Enchantment, rune learning |
| Torin | Temple Ruins | Unseely Fae binding ritual |
| Tosh | Louden's Rest | Graveyard secrets, lost mementos |
| Van Bueler | Hunter's Hovel | Wolf-human trade negotiations |
| Wulfric (Alpha) | Hunter's Hovel | Wolf trials, Pact of Winter's Howl |

---

## Social & Room Features

### Personal Room System
- **Edit Description**: Write custom room description
- **Choose Decor**: Select room decorations
- **Choose Color**: Set room color theme
- **ASCII Art Editor**: Create 80x24 ASCII art
- **View ASCII Art**: Display your creation
- **Preview Room**: See how visitors see your room

### Social Features
- **Guestbook**: Leave/read visitor messages
- **Privacy Settings**: Public/Private/Friends-only
- **Friends List**: Manage connections
- **Visitor Log**: Track visitors
- **Messages**: Private messaging system
- **Gifts**: Send gifts to friends

### Room Shop Items
| Item | Price |
|------|-------|
| Fancy Rug | 25g |
| Crystal Lamp | 40g |
| Gold Frame | 60g |
| Magic Mirror | 80g |
| Royal Banner | 100g |
| Ancient Statue | 150g |

---

## Events System

### Personal Events
- **Create Event**: Schedule gatherings with title, time, and type
- **View My Events**: See your scheduled events
- **Cancel Event**: Remove scheduled events
- **Browse All Events**: See realm-wide events

### Event Types
1. Party
2. Game
3. Meeting
4. Contest
5. Lantern (Festival)
6. Feast

### Realm Calendar (Seasonal Events)

| Month | Event | Location |
|-------|-------|----------|
| January | New Year's Frost Feast | The Burrows |
| February | Lovers' Lantern Walk | Moon Portal |
| March | Spring Awakening Festival | Fairy Gardens |
| April | Fool's Day Mischief | Bridge the Troll hosts |
| May | Order of the Black Rose Memorial | Louden's Rest |
| June | Midsummer Dragon Flight | Dragon Haven |
| July | Pirate's Plunder Games | Pirate Ship |
| August | Order of the Owls Wisdom Trials | Tower |
| September | Harvest Moon Ball | Pumpkin Fairies |
| **October** | **DRAGON LANTERN FESTIVAL** | **Dragon Haven** |
| November | Pact of Winter's Howl | Hunter's Hovel |
| December | Everland Yuletide Feast | Dining Hall |

### October: Dragon Lantern Festival (Special)
**Tradition: Everyone carries a lantern!**

The Dragon Lantern Festival commemorates the Battle for Everland:
- Three realms once coexisted: Aurora, Lore, Mythos
- The Darkness was banished from Mythos and spread to Lore
- King Lowden fell defending his realm
- The Dragon Queen of Mythos arrived with her flames and turned the tide
- Heroes buried their weapons beneath the fallen temple
- All return yearly to honor the sacrifice

---

## Economy & Trading

### Currency System
- **Gold**: Primary currency
- **Silver**: Secondary currency
- **Copper**: Tertiary currency

### Bank Services
- **Deposit**: Store currency safely
- **Withdraw**: Retrieve stored currency
- **Exchange**: Convert between currencies (dynamic rates)
- **Vault**: Secure item storage (10 slots, rent: 10 silver)

### Trading
- **Create Trade Offer**: Post items for trade
- **Browse Trades**: See available trades
- **Accept Trades**: Complete transactions

---

## Mini-Games & Activities

### Available Activities
| Activity | Description |
|----------|-------------|
| Lottery | Weekly drawings, buy tickets |
| Dice Games | Gambling with dice |
| Fishing | Catch fish for rewards |
| Racing | Competitive races |
| Treasure Hunting | Find hidden treasures |
| Cooking | Craft food items |
| Dueling | PvP combat |
| Arena | Combat challenges |
| Riddles | Puzzle solving |
| Scavenging | Random item discovery |
| Crafting | Create items |
| Garden | Grow plants |
| Fortune | Have your fortune told |
| Meditation | Restore stats |
| Spy | Gather information |
| Bounty | Hunt targets |
| Museum | View collections |
| Tavern | Social gathering |
| Companion | AI assistant |
| Mailbox | Correspondence |

---

## Magic System

The Magic System allows players to learn and cast spells through the Frost Weaver tradition. Access the magic menu by pressing **M** from the main menu.

### Mana System
- **Maximum Mana**: 20 points
- **Mana Regeneration**: Base rate + bonuses from Pendulum Mastery
- **Restore Mana**: Through meditation or resting

### Frost Weaver Spells

| Spell | Cost | Effect | Prerequisite |
|-------|------|--------|--------------|
| GLACIOUS | 5 mana | Frost bolt - deals ice damage | Frost Weaver Initiate |
| NIX | 8 mana | Ice shield - defensive barrier | Know GLACIOUS |
| ILLUMINA | 10 mana | Light burst - reveals hidden paths | Know NIX |

### Learning Spells
Spells must be learned in order:
1. **GLACIOUS** - Entry spell for Frost Weaver initiates
2. **NIX** - Requires mastery of GLACIOUS
3. **ILLUMINA** - Requires mastery of NIX

### Frost Weaver Ranks
| Rank | Requirement |
|------|-------------|
| Initiate | Learn GLACIOUS |
| Adept | Learn all three spells |
| Master | Pendulum mastery level 10 |

### Third Eye Practice
Train your magical perception through Pendulum Practice:
- **10 Mastery Levels**: Each level improves Third Eye sensitivity
- **Level 5**: +1 mana regeneration rate
- **Level 10**: +1 additional mana regeneration, Master rank unlock

### Meditation
- Restore mana through focused concentration
- Available from the Magic menu
- No cost, restores mana over time

### Spell Lore
Study the ancient traditions and history of the Frost Weavers, including:
- The Frost Weaver Queen's teachings
- Origins of ice magic in Aurora
- The bond between caster and elements

---

## Romance & Wedding System

Find love in Everland! Access the Romance menu by pressing **<** from the main menu.

### Romance Options
| Partner | Description |
|---------|-------------|
| Kira | The gentle apothecary with healing hands |
| Lyra | The fierce wolf of winter, loyal beyond measure |
| Kendrick | The noble knight of Everland, guided by honor |
| Bonny Red Boots | The free-spirited pirate, full of adventure |

### Courtship Stages
1. **Introduced** - Express your interest
2. **Courting** - Reach affection level 5
3. **Engaged** - Propose at affection level 8
4. **Married** - Hold a wedding ceremony (100g)

### Activities
- **Give Gifts** (-10g): Increase affection
- **Go on Dates**: Deepen your bond (requires Courting stage)
- **Propose**: Ask for their hand (requires level 8)
- **Wedding**: Marry in the Rose Gardens, officiated by Bishop Cordelia

---

## Dream System

Enter the Dreamscape where Veylan's shadow reaches even the sleeping. Access by pressing **>** from the main menu.

### Dream Types
| Type | Effect |
|------|--------|
| Peaceful | Restore 5 mana, find tranquility |
| Nightmare | Battle Veylan for 15g reward (risky!) |
| Prophetic | Receive visions of future events |
| Memory | Glimpse your forgotten past |

### Veylan's Influence
- Increases with nightmares (0-10 scale)
- At level 10, Veylan wins: -20g, influence resets
- Pendulum mastery provides dream protection

### Prophecies
Collect prophetic visions that hint at:
- The Dragon Lantern Festival
- Memory stones and choices
- The Spider Princess's weaving
- Veylan's growing shadow

---

## Ship Travel System

Sail aboard The Black Siren with Captain Pit Plum! Access by pressing **[** from the main menu.

### Ports
| Port | Location | Specialty |
|------|----------|-----------|
| Everland Harbor | Main hub | Best for selling |
| Aurora Ice Docks | Aurora | Rare frost goods |
| Mythos Jungle Bay | Mythos | Exotic spices and silk |
| Whitecastle Port | England | English luxuries |

### Trading
- **Spices** (20g): Sell for 40g profit at different port
- **Silk** (30g): Sell for 48g profit at different port
- Buy low, sail far, sell high!

### Sea Encounters
- **Storms**: Weather the waves, arrive shaken but safe
- **Pirates**: Bonny Red Boots may gift you 30g!

### Voyage Cost
25 gold per voyage between ports

---

## Faction Reputation System

Build standing with Everland's guilds and factions. View from the Reputation menu (R in Room menu).

### Factions
| Faction | Description |
|---------|-------------|
| Frost Weavers | Ice magic practitioners of Aurora |
| Merchant Guild | Trade and commerce masters |
| Order of Black Rose | Knights of the cursed garden |
| Wolves of Winter | The pack of Alpha Wulfric |
| Order of the Owls | Secret keepers and spies |
| Black Siren Crew | Pirates of the high seas |

### Standing Levels
| Range | Status |
|-------|--------|
| 0-25 | Hostile |
| 26-50 | Neutral |
| 51-75 | Friendly |
| 76-100 | Exalted |

---

## Dueling Arena

Test your combat prowess! Access from the Arena in the Room menu.

### Fight Types
| Type | Cost | Reward |
|------|------|--------|
| Quick Fight | Free | +10g on win |
| Ranked Fight | Free | +25g, rank increase |
| Bet Fight | 20g | +50g on win |

### Arena Titles
| Title | Requirement |
|-------|-------------|
| Novice | 0-4 wins |
| Contender | 5-14 wins |
| Gladiator | 15-29 wins |
| Champion | 30+ wins |

### Arena Ratings
Track your competitive rating, wins, and losses. Rise through the ranks to become the Champion of Everland!

---

## Build Instructions

### Requirements
- **KickAssembler** v5.25 or later
- **Java** (for KickAssembler)
- **VICE** C64 Emulator (for testing)

### Build Command
```powershell
cd "c:\commodore\everland\bbs\custom"
java -jar "C:/commodore/KickAssembler/KickAss.jar" everland_bbs.asm -o "c:\commodore\everland\bin\everland_bbs.prg"
```

### Output
- **PRG File**: `bin/everland_bbs.prg`
- **Symbol File**: `everland_bbs.sym`

---

## Appendix A: Complete Quest Walkthrough

This appendix provides detailed step-by-step walkthroughs for every quest chain in Everland.

---

### Chapter 1 Quests: The Fall of Lore

#### Quest: Memory Restoration (Lady Cordelia)
**Location**: Lore Portal → Lady Cordelia  
**Prerequisite**: None

**Background**: When the refugees fled through the portal from Lore, a dense fog swept over their minds, erasing all memories temporarily. Mage Damon, Damian, Barnabis, and Princess Delphi all lost their memories.

**Steps**:
1. **Speak to refugees** - Travel through Everland and speak to NPCs who came through the portal
2. **Retrieve the dark crystals** - The dark sun and moon crystals are needed to restore memories. Kasimere possesses one.
3. **Swear the green thorn oath** - "May the green thorn pierce me if I fail in my quest"
4. **Restore the Order of the Black Rose** - Complete the restoration and join the Order

**Reward**: Black Rose Emblem, Order membership

---

### Chapter 2 Quests: Mischief and Merriment

#### Quest: Marmalade's Prank Quest Chain
**Location**: Town → Fairy Gardens → Marmalade  
**Prerequisite**: None

**Background**: Marmalade is a fiery-haired Pumpkin Fairy who loves mischief. The Pumpkin King demands tribute through pranks!

**Steps**:
1. **Swap hats with the scarecrow** - Find the scarecrow in the field and swap your hat
2. **Dance a merry jig with a woodland fox** - Locate a fox in the forest and dance together
3. **Bow before the grand Pumpkin carving** - Find the Pumpkin King's carving and pay respects

**Reward**: Marmalade's blessing

---

#### Quest: Marigold's Potion Quest Chain
**Location**: Town → Fairy Gardens → Marigold  
**Prerequisite**: None

**Background**: Marigold, adorned in shimmering gold, needs ingredients for her potion of mischief - one sip makes you dance!

**Steps**:
1. **Gather moonlit dewdrops** - Collect dewdrops from the garden at night
2. **Find caramel apple essence** - Obtain essence from the festival vendors
3. **Collect a whispered secret from the wind** - Listen to the wind in a quiet place

**Reward**: Potion of Mischief

---

#### Quest: Butterscotch's Alliance Quest Chain
**Location**: Town → Fairy Gardens → Butterscotch  
**Prerequisite**: None

**Background**: Butterscotch's name doesn't start with 'M', so she can't join her sisters. She found another path - befriending humans.

**Steps**:
1. **Help tend crops** - Work at the nearby farmstead
2. **Whisper encouragement to the harvest** - Speak blessings to the growing plants
3. **Earn the Pumpkin King's recognition** - Gain recognition for your work

**Reward**: Alliance between fairy and human

---

#### Quest: Defeat the Pumpkin King
**Location**: Lore Portal → Cursed Garden  
**Prerequisite**: Complete Fairy quests (recommended)

**Background**: The Pumpkin King towers in the cursed garden, eyes glowing unearthly orange. His sinister laughter echoes as thorny plants obey his will.

**Steps**:
1. **Gather spider allies** - Speak to Spider Princess in Central Plaza
2. **Rally the knights of Lore** - Gather support from Lady Cordelia
3. **Obtain the enchanted spear** - Get the spear from Grim the Blackheart
4. **Launch coordinated attack** - Execute the plan

**Choice**: (F)ight or (N)egotiate

**Warning**: Grim will sacrifice himself in the final battle!

**Reward**: Victory over the Pumpkin King, but at great cost

---

#### Quest: Honor Grim's Sacrifice (Gwen)
**Location**: Lore Portal → Gwen (after Pumpkin King defeat)  
**Prerequisite**: Complete Pumpkin King battle

**Background**: Gwen stands silently, clutching a withered black rose. "Grim gave everything. One strike of the enchanted spear, one green thorn through his heart. I wept but once."

**Steps**:
1. **Obtain black rose seeds** - Find seeds from the Order of Black Rose
2. **Travel to the Cursed Garden** - Return to where Grim fell
3. **Plant black roses at the memorial** - Create a lasting tribute
4. **Report to Gwen** - Share that the tribute is complete

**Reward**: Gwen's gratitude, closure

---

### Chapter 3-6 Quests: The Vampires' Descent

#### Quest: Help or Betray Kasimere
**Location**: Town → The Moselem → Kasimere  
**Prerequisite**: None

**Background**: Arch Magus Kasimere, the oldest vampire, followed through the portal as it closed. His crystal globe resonates with the dark sun crystal, reaching into dreams with whispered promises of power. He corrupts refugees with foggy memories, turning them into servants.

**Choice**:
- **(H)elp Kasimere**: Join his dark dominion
- **(B)etray Kasimere**: Expose his treachery to the defenders

**Steps (Betray path)**:
1. **Pretend to serve** - Gain Kasimere's trust
2. **Gather evidence** - Document his corrupted servants
3. **Alert Lady Cordelia** - Report to the Order of Black Rose
4. **Confront Kasimere** - Join the defenders in his lair

**Reward**: Depends on choice - dark power or heroic standing

---

#### Quest: Cedric's Redemption
**Location**: Town → Church → Cedric  
**Prerequisite**: None

**Background**: "At the witching hour, Kasimere invaded my dreams. His crystal globe resonated with the dark sun crystal, whispering promises of power and glory. But Mage Damon wove a protective barrier around my mind."

**Steps**:
1. **Confess your moment of weakness** - Cedric admits his temptation
2. **Face Kasimere's lair with the defenders** - Join the assault
3. **Sever the dark crystal's hold** - Break the connection
4. **Swear renewed oath to the Order** - Recommit to the light

**Reward**: Cedric's redemption, renewed faith

---

### Chapter 7 Quests: The Pact of Winter's Howl

#### Quest: Winter Wolf Trials (Wulfric)
**Location**: Town → Hunter's Hovel → Alpha Wulfric  
**Prerequisite**: None (Available in winter months)

**Background**: "The Pact of Winter's Howl binds wolf and human. Each frost-laden evening, we gather to renew our vows." Beta Lyra negotiated with Van Bueler - provisions for protection.

**Steps**:
1. **Endure the biting cold without shelter** - Survive a night in the wilderness
2. **Outwit the cunning riddles of the pack** - Solve wolf riddles
3. **Brave the harshest wilderness paths** - Navigate dangerous terrain
4. **Join the moonlit howl when the train rumbles by** - Participate in the tradition

**Reward**: Pack membership, Wolves of Winter standing

---

#### Quest: Pact Negotiations (Van Bueler/Lyra)
**Location**: Town → Hunter's Hovel  
**Prerequisite**: None

**Steps**:
1. **Negotiate fair terms** - Balance town and wolf needs
2. **Funnel provisions to Hunter's Hovel** - Arrange the supply chain
3. **Ensure Everland survives the winter** - Verify preparations
4. **Witness the wolf-human howl** - Join the celebration when trains pass

**Reward**: Improved wolf-human relations

---

### Chapter 8 Quests: Bridge and Kevin

#### Quest: Bridge's Mischief
**Location**: Town → The Bridge or Marketplace → Bridge the Troll  
**Prerequisite**: None

**Background**: Bridge makes his home under the old stone bridge, twirling Kevin - his skull-tipped club and closest confidant. "Ah, you look absolutely revolting!" (He means it kindly.)

**Steps**:
1. **Swap trinkets at the marketplace** - Trade unusual items with Bridge
2. **Spread playful chaos in town** - Help with harmless pranks
3. **Learn Bridge's hauntingly off-key tune** - Memorize the song
4. **Join Kevin's midnight tribunal of oddities** - Attend the strange gathering

**Reward**: Unique trinkets, Bridge's friendship

---

### Chapter 9 Quests: The Fracture's Grip

#### Quest: Contain the Fractures (Dante)
**Location**: Town → The Bridge → Dante  
**Prerequisite**: None

**Background**: Dante maintains shimmering wards against the fractures that blur reality. The ghost pirates in his bottle delight in targeting the Spider Princess.

**Steps**:
1. **Gather ward components from the realms** - Collect magical ingredients
2. **Confront the Candy Witch's sabotage** - Stop her destruction
3. **Seal the ghost pirates' bottle permanently** - Contain the threat
4. **Restore balance between worlds** - Complete the ward network

**Reward**: Stabilized fractures, Dante's gratitude

---

#### Quest: Stop the Candy Witch
**Location**: Town → The Bridge → Candy Witch  
**Prerequisite**: None

**Background**: The Candy Witch tears at Dante's wards with candy-coated claws. "Why mend what can be broken? Chaos is so much sweeter!"

**Steps**:
1. **Track her through the fractures** - Follow her trail
2. **Resist her sweet temptations** - Avoid corruption
3. **Sever her bond with the ghost pirates** - Break the alliance
4. **Seal her in crystallized sugar** - Imprison the witch

**Reward**: Wards restored, chaos contained

---

#### Quest: Protect the Spider Princess (Kora/Kendrick)
**Location**: Town → Central Plaza → Kora and Kendrick  
**Prerequisite**: None

**Steps**:
1. **Strengthen the protective perimeter** - Reinforce defenses
2. **Track ghost pirate movements** - Monitor threats
3. **Counter the Candy Witch's sabotage** - Prevent attacks
4. **Escort the Spider Princess to safety** - Complete protection

**Reward**: Guardian standing, Spider Princess's favor

---

### Chapter 10-12 Quests: The Mystic's Tent

#### Quest: Uncover the Mystics' Secret
**Location**: Town → Mystic's Tent → Mela  
**Prerequisite**: None

**Warning**: The mystics (Mela, Kal, Daemos) are secretly vampires! They experimented with Kasimere's ashes and necromancy!

**Steps**:
1. **Resist their promises of immortality** - Maintain your resolve
2. **Uncover their vampiric nature** - Investigate their secrets
3. **Expose Daemos's schemes for the Spider Princess** - Reveal the plot
4. **Choose: Join them or destroy them** - Make your decision

**Reward**: Depends on choice - vampiric power or heroic standing

---

### Chapter 11 & 16 Quests: The Pirate's Path

#### Quest: Pirate's Trials (Captain Pit Plum)
**Location**: Town → Pirate Ship → Captain Pit Plum  
**Prerequisite**: None

**Background**: "So ye want to be a part-time pirate, eh? Mage Damon himself trained under me!"

**Steps**:
1. **Make a trade for gold** - Complete a merchant transaction at port
2. **Find hidden flags** - Locate flags across distant islands
3. **Collect mysterious objects** - Gather items for the ship
4. **Learn combat from Captain Shadow Ford** - Complete training

**Reward**: Crew membership on the Black Siren

---

#### Quest: Combat Training (Shadow Ford)
**Location**: Town → Pirate Ship → Captain Shadow Ford  
**Prerequisite**: None

**Background**: "First, shed your gear and outer clothing - to move freely, shed unnecessary weight."

**Steps**:
1. **Master footwork** - Learn the dance of combat (precise, agile)
2. **Learn parrying** - Your sword is an extension of will
3. **Practice until moonrise** - Train in the secluded cove
4. **Earn Shadow Ford's nod of approval** - Demonstrate mastery

**Reward**: Combat proficiency, Shadow Ford's respect

---

#### Quest: The Last Shackle Song (Bonny Red Boots)
**Location**: Town → Pirate Ship → Bonny Red Boots  
**Prerequisite**: None

**Background**: "The Last Shackle - a slaver ship turned to freedom! A prisoner poisoned the guards with fancy wine, and the captives left not a slaver alive!"

**Steps**:
1. **Learn the full ballad** - Memorize all verses
2. **Spread the song across taverns** - Perform in Everland's taverns
3. **Find the legendary freed prisoners** - Locate survivors
4. **Join Bonny's fiddle performance** - Perform together

**Reward**: The song of freedom, Bonny's friendship

---

### Chapter 13 Quests: The Tale of Anderon's Rescue

#### Quest: Dragon Trainer Oaths (Alister)
**Location**: Town → Temple Ruins → Alister  
**Prerequisite**: None

**Background**: "Long ago, Anderon the great dragon snagged a pine tree between his claws. The villagers banded together to free him, forging a bond between humans and dragons!"

**Oaths**:
1. "I swear to protect dragons as long as my arms have strength."
2. "I swear to aid dragons as long as my legs may carry me."
3. "I swear to deepen my knowledge and share it with others."

**Symbol**: Two fingers intertwined - the bond between dragon and trainer.  
**Farewell**: "Fly on the dragon's wings!"

**Reward**: Order of the Emerald Sky membership

---

### Chapter 14 Quests: The Frost Weaver's Rite

#### Quest: Frost Weaver Initiation
**Location**: Town → The Burrows → Frost Queen  
**Prerequisite**: None

**Background**: "In the tradition of witches, wizards, and sages who protected Aurora for centuries, our duty falls onto you."

**Ritual Spells**:
1. **GLACIOUS** - Ice at your fingertips to fight enemies
2. **NIX** - Flowy drifts of snow to ensnare foes
3. **ILLUMINA** - Be a light in darkness, a beacon in storm

**Steps**:
1. **Bring your fingers together** - Begin the ritual
2. **Learn GLACIOUS** - Master ice magic
3. **Learn NIX** - Master snow control
4. **Learn ILLUMINA** - Master light magic

**Completion**: "May all magic join with yours and yours with ours. Welcome to the Frost Weavers!"

**Reward**: Frost Weaver Guild membership, frost spells

---

### Chapter 15 Quests: The Unseely Fae's Necromancy Ritual

#### Quest: Unseely Court Binding (Torin)
**Location**: Town → Temple Ruins → Torin  
**Prerequisite**: None

**Warning**: This binds your soul forever!

**Background**: "You have proven your loyalty. Now take part in the binding ritual that will bind your soul to us."

**Steps**:
1. **Retrieve the heart of Loudon** - Find it at Louden's Rest graveyard
2. **Complete the necromancy incantation challenge** - Pass the test
3. **Kneel and hold out your hand** - Begin the binding
4. **Repeat the incantation**: "Goofice Goafice Alakda, orgawal, Goragawal"

**Reward**: Unseely Court membership, dark powers (at great cost)

---

### Chapter 17-18 Quests: The Fractured Rift & Order of the Owls

#### Quest: Investigate the Memory Rift
**Location**: Town → Mystic's Tent → Mela and Kal  
**Prerequisite**: None

**Background**: Mage Damon discovered no one remembered him - not even the Mayor. "Perhaps you should consult the Mystics," the Mayor offered. The temporal strands are in disarray.

**Steps**:
1. **Speak to townsfolk** - Confirm the memory loss
2. **Consult Mela and Kal** - Learn about the temporal dissonance
3. **Investigate the ley lines** - Find the source
4. **Repair the fractured rift** - Restore temporal stability

**Reward**: Memories restored, temporal balance

---

#### Quest: Order of the Owls Initiation
**Location**: Town → Tower → Garrett  
**Prerequisite**: None

**Background**: "The Order of the Owls - wise and intrepid souls united! I proposed the owl as our emblem for collective wisdom." Fletcher practices archery. Poppy sponsors the feast.

**Steps**:
1. **Walk the circular path around town** - Complete the ritual walk
2. **Prove your wisdom to Garrett** - Answer questions
3. **Earn Fletcher's respect at archery** - Demonstrate skill
4. **Attend Poppy's inaugural feast** - Join the Dining Hall celebration

**Reward**: Order of the Owls membership

---

### Chapter 19 Quests: The Enchantment of Everland

#### Quest: Unlock Magical Abilities (Tammis/Saga)
**Location**: Town → Witch's Tent → Tammis and Saga  
**Prerequisite**: None

**Background**: "We see within you the flickering embers of magic. Your staff, your crystal, the energy around you - it speaks of destiny waiting to unfurl."

**Steps**:
1. **Learn ancient runes** - Study with the sisters
2. **Understand your staff's lineage** - Discover its history
3. **Weave magic into everyday artifacts** - Practice enchanting
4. **Awaken the power slumbering within** - Complete transformation

**Reward**: Magical awakening, enchanting abilities

---

#### Quest: Reveal Your Destiny (Saga)
**Location**: Town → Witch's Tent → Saga  
**Prerequisite**: None

**Steps**:
1. **Gather three prophecy fragments** - Collect from different realms
2. **Spend endless nights crafting spells with Tammis** - Practice
3. **Turn creations into vessels for arcane energy** - Enchant items
4. **Complete your extraordinary journey** - Fulfill the prophecy

**Reward**: Destiny revealed, magical mastery

---

### Chapter 20 Quests: The Enigmatic Disappearance

#### Quest: Third Eye Activation (Samuel)
**Location**: Town → Catacombs → Samuel  
**Prerequisite**: None

**Background**: When the town vanished, only Samuel and Mage Damon remained. "Mage Damon made me his apprentice. Want to learn to activate your THIRD EYE?"

**Steps**:
1. **Find your focal point** - Between hairline and brow, back 2 inches
2. **Hold the pendulum still, observe your breathing** - Meditation
3. **Command it to spin with your mind** - Not your hand!
4. **Master spinning it both directions** - Prove control

**Practice**: With experience, the pendulum can spin nearly horizontal!

**Reward**: Third eye activation, pendulum mastery

---

### Chapter 21 Quests: The Dragon Lantern Festival

#### Quest: Participate in the Festival
**Location**: Town → Dragon Haven (October)  
**Prerequisite**: None

**Tradition**: Everyone carries a lantern!

**Steps**:
1. **Obtain a lantern** - Purchase or craft one
2. **Gather at Dragon Haven** - Join the crowd
3. **Listen to the story of the Battle for Everland** - Hear the tale
4. **Honor King Lowden's sacrifice** - Pay respects at the temple

**Reward**: Festival participation, community standing

---

### Chapter 22 Quests: Hope of Light

#### Quest: The Damsel's Destiny
**Location**: Town → Train Station → Damsel of the Mist  
**Prerequisite**: None

**Background**: "On muddy roads to Everland, the blue glow held true - a beacon through the tangled veil. The lion of the muddy road tore at my gown, but I lifted my sword with fearless grace."

**Steps**:
1. **Follow the blue light through the mist** - Navigate the path
2. **Face the lion of the muddy road** - Overcome the challenge
3. **Weave your courage into a radiant garment** - Transform the omen
4. **Find the Damon of your Dreams** - Complete the journey

**Reward**: Destiny fulfilled, hope restored

---

### Chapter 23 Quests: First Love, First Light

#### Quest: Mutual Craft (Kira)
**Location**: Town → Kira's Apothecary → Kira  
**Prerequisite**: None

**Background**: "Balm of Quick Mend for wounds, Oil of Orchid for massages... or perhaps just a moment of care? I too am an aspiring magic-user - small charms, healing threads."

**Steps**:
1. **Accept healing for your wounds** - Receive treatment
2. **Experience the massage table with scented oils** - Relaxation
3. **Share stories of magic and craft** - Build connection
4. **Return at dusk when the lamp is lit** - Deepen relationship

**Reward**: Healing, romance, mutual understanding

**Kira's Wisdom**: "We'll call it mutual craft - you mend quarrels, I mend weariness."

---

### Boss Encounters

#### Pumpkin King (Fight Path)
**Location**: Lore → Cursed Garden  
**Recommended Level**: High  
**Required Allies**: Spider Princess allies, Knights of Lore, Grim with enchanted spear

**Tactics**:
1. Use parrying skills from knight training
2. Summon spider allies to distract
3. Position Grim for the flank attack
4. Coordinate the final strike

**Warning**: Grim sacrifices himself

---

#### Kasimere (Betray Path)
**Location**: The Moselem → Kasimere's Lair  
**Recommended Level**: High  
**Required Allies**: Lady Cordelia, Cedric, Mage Damon

**Tactics**:
1. Break the crystal globe connection
2. Shield against dream invasion
3. Unite the defenders
4. Vanquish the vampire lord

---

## Appendix B: Guild Reference

### Available Guilds

| Guild | Location | Leader | Initiation |
|-------|----------|--------|------------|
| Order of the Black Rose | Lore | Lady Cordelia | Green thorn oath |
| Frost Weavers | The Burrows | Frost Queen | Learn GLACIOUS, NIX, ILLUMINA |
| Order of the Emerald Sky | Temple Ruins | Alister | Dragon Trainer Oaths |
| Unseely Court | Temple Ruins | Torin | Necromancy binding ritual |
| Order of the Owls | Tower | Garrett | Wisdom trials, archery, feast |
| Wolves of Winter | Hunter's Hovel | Alpha Wulfric | Survival trials, riddles |

---

## Appendix C: Quick Reference

### Portal Keys
- **A** - Aurora
- **L** - Lore
- **M** - Mythos
- **T** - Town of Everland
- **E** - England

### Town Location Keys
- **1-9** - First 9 locations
- **A-P** - Additional locations
- **M** - Moon Portal
- **0** - Return to main

### Common Commands
- **I** - Inventory
- **S** - Status
- **H** - Help
- **Q** - Quit/Back

---

## Appendix D: Character Directory

This appendix introduces the major characters of Everland, drawn from the lore that shapes this world.

---

### Heroes of Everland

#### Mage Damon
![Mage Damon](../images/MageDamon3Up.png)

*"I'm dying, just taking it one day at a time."*

Mage Damon is an aspiring mage with a heart full of wonder and a mind brimming with spells. He once entertained the valiant knights of Lore with his mesmerizing magic just outside the towering gates of the kingdom. When the vampire plague struck, he discovered the location of the mystical portal to Everland—a gateway hidden in the darkest recesses of Lore, retold in stories for generations but lost to time.

Practiced in the art of Divination, Damon can cast illusions to distract creatures. After passing through the portal, he lost his memories temporarily but slowly regained them, retaking the oath to restore the Order of the Black Rose. He later discovered he could draw ambient magic into his third eye, eventually channeling immense power through the headpiece given to him by the Spider Princess.

In Everland, Mage Damon founded the **Order of the Owls** alongside Garrett, Fletcher, Shadow Ford, and Poppy. He studied under the Nordic witches Tammis and Saga, unlocking his latent magical abilities. He also participated in the Unseely Fae's binding ritual under Torin, gaining forbidden necromantic knowledge.

**Affiliations**: Order of the Black Rose, Order of the Owls, Unseely Court
**Skills**: Divination, illusion magic, third eye activation, pendulum mastery
**Location**: Throughout Everland

---

#### Knight Damian
![Knight Damian](../images/Damian1Up.png)

Knight Damian is a wise guide and defender in times of turmoil. Known for his unwavering loyalty, he sought guidance from fellow knights when the vampire invasion struck Lore. Together with Mage Damon and Barnabis, he devised a plan to save their beloved kingdom.

Damian had long sought the company of Princess Delphinia (Delphi), and besides his vow to protect her and the kingdom, he had his own special interest. He valiantly took turns carrying the princess through the treacherous paths as they fled to the portal. More resilient somehow, Damian started to remember first after passing through the portal, giving quests to help others slowly regain their memories.

His shared love for spiders with Princess Delphi became a source of power—from their hands, spiders of all sizes materialized to aid in battle against the Pumpkin King. After victory, Damian and Delphi were married in a secret grove hidden deep within the enchanted forests of Lore, blessed by Bishop Cordelia, and embarked on their honeymoon to Whitecastle.

**Affiliations**: Order of the Black Rose, Knights of Lore
**Skills**: Combat, leadership, spider summoning (with Delphi)
**Romance**: Princess Delphinia

---

#### The Spider Princess (Princess Delphinia/Delphi)
![The Spider Princess](../images/SpiderPrincess1Up.png)

Princess Delphinia, known as Delphi and later as the Spider Princess, traveled through the portal in a faint, weakened state as if something was happening to her. She seemed to struggle as if between two personalities, with some spirit beginning to take over her mind.

Her shared love for spiders with Damian became legendary—together they could summon arachnid allies in battle. She gave Mage Damon a magical headpiece that became the vessel for immense concentrated magical power. After defeating the Pumpkin King, she married Damian in a ceremony in the enchanted grove.

In Everland, the Spider Princess requires protection from Kora and Kendrick, as ghost pirates imprisoned by Dante particularly delight in targeting her as part of their twisted games.

**Affiliations**: Royal House of Lore
**Skills**: Spider communion, magical artifacts
**Romance**: Knight Damian
**Location**: Central Plaza (protected by Kora and Kendrick)

---

#### Bridge the Troll (and Kevin)
![Bridge and Kevin](../images/BridgeAndKevin1.png)

*"Ah, you look absolutely revolting!" (He means it kindly.)*

Bridge is a peculiar troll who makes his home under the old stone bridge that connects the two halves of Everland. His cozy spot is adorned with trinkets and oddities he has collected over the years. Kevin, his trusty club adorned with a menacing skull at its tip, is more than a mere weapon—it's his closest companion, his confidant, and often the recipient of his wayward thoughts.

The townsfolk are accustomed to Bridge's strange mannerisms. They know better than to take his words at face value—if he says he's "just terrible," he means he's fine; if he calls you "revolting," he's showing affection. He often swaps odd trinkets at the marketplace in exchange for fresh produce and bread.

Bridge sings a hauntingly off-key tune that the townsfolk find themselves humming long after he's returned to his abode. Under the bridge at twilight, he regales Kevin with tales of the day's events, sharing moments of contented silence.

**Personality**: Mischievous, loyal, speaks in opposites
**Companion**: Kevin (skull-tipped club)
**Location**: The Bridge, Marketplace

---

### The Pumpkin Fairies

#### Lezule
![Lezule the Fairy](../images/fairy_named_lezule_lezule_colored_in_the_fairy_gardens_sweet_and_tender_shy_mouth_open_waiting_to_m_mthcye2lh1va3w5b8vtv_2.png)

Lezule is a sweet and tender fairy of the Fairy Gardens, known for her shy demeanor and protective nature. She guards the stolen names of those who wander too close to fairy enchantments.

**Location**: Fairy Gardens

---

#### Marmalade

*"The Pumpkin King demands tribute through pranks!"*

Marmalade is a fiery-haired Pumpkin Fairy with a mischievous grin. She flits about in a frenzy, plotting escapades to spread quests of practical jokes and cajole the gentle folk of Everland into bending the knee to the mighty Pumpkin King.

Her quest chain involves swapping hats with scarecrows, dancing merry jigs with woodland creatures, and bowing before the grand Pumpkin carving.

**Location**: Fairy Gardens

---

#### Marigold

*"One sip of my potion and you'll dance whether you want to or not!"*

Marigold, adorned in a gown of shimmering gold, hums merry tunes as she concocts potions of mischief. As the potent elixir bubbles and froths in her tiny cauldron, she shares mischievous giggles with her sister Marmalade before casting the meddlesome brew into the wind.

Her quest chain involves gathering moonlit dewdrops, caramel apple essence, and whispered secrets from the wind.

**Location**: Fairy Gardens

---

#### Butterscotch

*"My name doesn't start with 'M', so I found another path—befriending humans."*

Butterscotch's heart is more kind and tender than her peers. She seeks not to perpetrate pranks or revel in mischief, but rather to ensure the well-being and joy of the gentle folk of Everland. Her name does not begin with the cherished letter "M," which bars her from joining the esteemed company of her fairy peers.

Instead, she visits nearby farmsteads, quietly tending to crops and whispering gentle encouragement to the harvest. She has formed bonds with those who work the land, eschewing the playful trickery of her kin. The sentient Pumpkin King has acknowledged her noble deeds with a nod of acceptance.

**Location**: Fairy Gardens

---

### Villains and Antagonists

#### Arch Magus Kasimere

*"Soon we will conquer this land also."*

Kasimere is the Arch Magus, the oldest of the vampires, and the one with all the power. When the portal from Lore closed, he dashed through just in time, lurking in the shadows on the other side with a snarled laugh emanating from his lips.

Fueled by his insatiable hunger for power and dominion, Kasimere sought to expand his reach beyond the borders of Lore. He patiently watched and bided his time, hidden in the shadows of Everland. He whispered promises into the ears of confused refugees, enticing them with the allure of power and satisfaction of primal desires, seeking bribes from fearful inhabitants.

His black crystal globe resonates with the dark sun crystal, allowing him to reach into dreams with whispered promises at the witching hour. He invaded Cedric's dreams, attempting to corrupt him to his cause. Eventually, the defenders of Everland confronted him in his lair beneath the gnarled boughs of an ancient oak, vanquishing him with radiant magic.

Yet whispers suggest his defeat only ignited his insatiable hunger for power, and he awaits his next opportunity to strike...

**Powers**: Dream invasion, corruption, crystal globe resonance
**Weakness**: Radiant magic, unity of defenders
**Location**: The Moselem (his lair)

---

#### The Pumpkin King

*"His eyes glowed an unearthly orange, and sinister laughter echoed throughout the garden."*

The Pumpkin King towers in the cursed garden, perched atop a magnificent and eerie pumpkin throne. He possesses the ability to warp minds and bend reality, harboring an insatiable desire for chaos and despair. The thorny plants with gnarled green thorns obey his will.

Defeating him requires more than physical strength and magic—it requires the unity of knights remembering their oaths, spider allies from the Spider Princess, and a coordinated attack. When Grim of the Blackhearts delivered the final blow with an enchanted spear, he was pierced by a green thorn and sacrificed himself.

**Powers**: Mind warping, plant control, otherworldly resilience
**Weakness**: Unity, enchanted weapons, spider allies
**Location**: Cursed Garden (Lore)

---

#### The Candy Witch

*"Why mend what can be broken? Chaos is so much sweeter!"*

The Candy Witch tears at Dante's wards with candy-coated claws, seeking to destroy the barriers that contain the fractures between worlds. She delights in sabotage and has allied with the ghost pirates to target the Spider Princess.

**Powers**: Ward destruction, chaos magic
**Location**: The Bridge area

---

### The Mystics (Secret Vampires)

#### Mela, Kal, and Daemos

*"We see within you the flickering embers of magic..."*

In the heart of Everland, within a humble mystic's tent, Mela, Daemos, and Kal embarked on their journey into the realms of the esoteric and arcane. But beneath their roles as mystics lies a dark secret—they are vampires.

**Mela** consumed herself with the allure of ancient secrets and the pursuit of immortality. She spent countless nights poring over dusty tomes, delving into forbidden lore of vampire ashes and remains.

**Kal**, with his silver tongue and beguiling charm, weaves intricate tales to lure the curious and ambitious into their fold. His words whisper promises of untold power.

**Daemos** plots to entice the Spider Princess herself, knowing her enigmatic nature could elevate their brotherhood to unimaginable heights.

Their vampiric nature was born from rituals and experimentation with Kasimere's ashes and ancient necromancy incantations. They seek to expand their numbers, luring townsfolk with promises of arcane knowledge and immortality.

**Warning**: Approaching the Mystic's Tent may result in vampiric corruption!
**Location**: Mystic's Tent

---

### Knights and Warriors

#### Lady Cordelia (Bishop Cordelia)

Lady Cordelia is a legendary figure in Everland, taking charge of restoring the castle and training a new generation of knights. She instills in them the virtues of honor, duty, and loyalty. Now known as Bishop Cordelia, she blessed the wedding of Damian and Princess Delphi.

She leads the **Order of the Black Rose** and confronted Kasimere in his lair alongside Mage Damon and Cedric.

**Affiliations**: Order of the Black Rose
**Location**: Church, Lore

---

#### Grim the Blackheart

*"One strike of the enchanted spear, one green thorn through his heart."*

Grim of the Blackhearts was a warrior who fought in the final battle against the Pumpkin King. While the main assault distracted the enemy, Grim snuck around back with a huge enchanted spear. With his final blow to the Pumpkin King, he was pierced by a green thorn and sacrificed himself for the good of all.

Gwen ran to him as his life faded away. "I wept but once," she later said.

**Status**: Deceased (heroic sacrifice)
**Memorial**: Black roses planted at the Cursed Garden

---

#### Gwen

Gwen stands silently, clutching a withered black rose. She watched Grim sacrifice himself and wept a single tear—unusual for one who rarely shows emotion. She seeks heroes to honor Grim's sacrifice by planting black roses at his memorial in the Cursed Garden.

**Location**: Lore (after Pumpkin King defeat)

---

#### Cedric

*"At the witching hour, Kasimere invaded my dreams..."*

Cedric is an aspiring knight whose thoughts wavered at the touch of the vampire lord. Kasimere's crystal globe resonated with the dark sun crystal, whispering promises of power and glory in his dreams. He was torn between his noble self and the temptations of darkness.

However, Mage Damon had woven a protective barrier around Cedric's mind. When confronted with the truth of Kasimere's depravity, Cedric pledged himself to the defense of Everland, swearing an oath to vanquish the darkness.

**Affiliations**: Order of the Black Rose (renewed)
**Location**: Church

---

#### Barnabis

A courageous knight known for his unwavering loyalty, Barnabis sought guidance when the vampire invasion struck. He helped carry Princess Delphi through the treacherous paths to the portal and remained loyal to the cause of restoring Lore.

**Affiliations**: Knights of Lore

---

### The Wolves of Winter

#### Alpha Wulfric Vassa

*"The time has come for the Pact of Winter's Howl."*

Alpha Wulfric leads the Wolves of Winter from Hunter's Hovel at the edge of town. The pack's territory resonates with howls of anticipation, signaling the trials to come and the unity that follows.

The Pact of Winter's Howl binds wolf and human—provisions for protection. Those who wish to join must endure the biting cold, outwit cunning riddles, and brave the harshest wilderness. Upon success, wolves and humans join together under the moonlit sky, their united howls reverberating through town whenever the train rumbles by.

**Location**: Hunter's Hovel (winter)

---

#### Beta Lyra

Beta Lyra is the seasoned negotiator of the Wolves of Winter. She approached Van Bueler's office to negotiate the Pact, seeking sustenance for winter in exchange for protection.

*"In exchange for our protection, we ask that you provide us with provisions to see us through the harshest months."*

**Location**: Hunter's Hovel

---

### The Pirates

#### Captain Pit Plum

*"So ye want to be a part-time pirate, eh?"*

Captain Pit Plum commands the Black Siren. He trained Mage Damon (under the alias "Dashing Daren") in the ways of piracy, giving him tasks: make a trade for gold, find hidden flags, collect mysterious objects, and learn combat from Captain Shadow Ford.

**Location**: Pirate Ship (Black Siren)

---

#### Captain Shadow Ford

*"First, shed your gear and outer clothing—to move freely, shed unnecessary weight."*

Captain Shadow Ford is an enigmatic figure renowned for expertise in footwork and parrying. He resides in a secluded cove and trains aspiring pirates in the art of combat.

His teachings emphasize: footwork must be precise, agile, and poised; your sword is an extension of your will; timing, perception, and finesse are paramount.

**Location**: Pirate Ship, secluded cove

---

#### Bonny Red Boots

*"Come board the last shackle, she's waiting for you!"*

Bonny Red Boots is a spirited skallywag known for her relentless boldness. Her vibrant red boots clack against wooden planks as she plays her fiddle and sings the ballad of the Last Shackle—the tale of a slaver ship turned to freedom.

The song tells of a dastardly trap, prisoners breaking free from chains, and a cunning insurrection. "They caught some sailors and shackled their hands, but a prisoner waited, just biding his time. He poisoned the guards with some fancy wine!"

**Location**: Pirate Ship

---

### The Order of the Owls

#### Garrett

*"The owl symbolizes our collective wisdom and keen insight."*

Garrett, garbed in symbolic knightly attire, proposed the formation of an official group of wise and intrepid souls. When Mage Damon suggested "Order of the Owls," Garrett enthusiastically approved, marking the inception of the order.

**Location**: Tower

---

#### Fletcher

Fletcher has an affinity for archery and often spends prolonged hours at the range with Shadow Ford. He prefers circumambulating the town in a counterclockwise manner. Mage Damon sometimes mistakenly calls him "Archer" due to his skill.

An enigmatic aura surrounds Fletcher—he converses with a mysterious lady, and both bear an air of having emerged from an alternate realm.

**Location**: Tower

---

#### Poppy

*"A woman of remarkable poise, elegance, and unfathomable wealth."*

Poppy plays a pivotal role in the Order of the Owls. Her lavish Victorian attire and ornate parasol speak volumes of a mysterious past. As confidant of Garrett, she extended a generous invitation to unite the Order for a sumptuous feast at the illustrious Dining Hall, graciously underwriting the gathering.

**Location**: Tower

---

### The Nordic Witches

#### Tammis and Saga

*"We see within you the flickering embers of magic, a power waiting to be unleashed."*

Sisters Tammis and Saga operate from a small leather tent, infusing even the simplest items with otherworldly allure. They are more than skilled artisans—they are keepers of ancient magic.

They guided Mage Damon, teaching ancient runes, enchantments, and the intricate weaving of magic into everyday artifacts. They unearthed the secrets of his staff, helping him understand its lineage and how it had chosen him.

Tammis grounds Mage Damon with her wisdom and grace, amplifying his abilities. They spend endless nights working on crafting spells and enchanting items. Saga speaks of destiny and prophecy, guiding seekers toward their extraordinary journeys.

**Location**: Witch's Tent

---

### Other Notable Characters

#### The Mermaid
![The Mermaid](../images/mermaid_sitting_in_a_wicker_chair_at_a_medieval_theme_park_she_will_tend_to_quests_with_patrons_blo_arttzoc89ruq0s6vmraj_2.png)

The Mermaid sits in a wicker chair, tending to quests with patrons. She offers trade quests and rewards for those who bring her the items she seeks.

---

#### Samuel

*"I am Samuel. They are all gone."*

Samuel was the only other figure left when the entire town of Everland vanished during the Dragon Lantern Festival. Using a makeshift wooden cart for mobility despite his disability, he pushed forward with admirable determination.

Mage Damon made Samuel his apprentice, teaching him the mysteries of the arcane arts. Samuel learned to activate his third eye—concentrating on the focal point within the mind, using a pendulum not for divination but to channel personal energy. With unwavering resolve, Samuel mastered spinning the pendulum with his mind alone.

**Skills**: Third eye activation, pendulum mastery (in training)
**Location**: Catacombs

---

#### Van Bueler

Van Bueler is a man of stern countenance with piercing eyes who runs a trading company. He negotiated the Pact of Winter's Howl with the Wolves, agreeing to funnel provisions in exchange for protection during the harshest months.

**Location**: Trading Company Office

---

#### Dante

Dante maintains shimmering wards against the fractures that blur reality between worlds. He has imprisoned a crew of cursed ghost pirates within a bottle—they resent him and delight in targeting the Spider Princess. The Candy Witch constantly sabotages his wards.

**Location**: The Bridge

---

#### Kora and Kendrick

Steadfast knights from Lore, Kora and Kendrick swore to protect the Spider Princess. They remain vigilant against the ghost pirates and the Candy Witch's schemes.

**Location**: Central Plaza

---

#### Alister

*"Fly on the dragon's wings!"*

Alister is the renowned Dragon Trainer who tells the tale of Anderon's rescue and administers the oaths of the Order of the Emerald Sky. He teaches the sacred oaths: protect dragons, aid dragons, deepen knowledge and share it. The symbol of two intertwined fingers represents the bond between dragon and trainer.

**Location**: Temple Ruins

---

#### Torin

*"You must take part in a binding ritual that will bind your soul to us."*

Torin leads the Unseely Fae court, administering the necromancy binding ritual. The ritual requires retrieving the heart of Loudon, completing incantation challenges, and repeating the words: "Goofice Goafice Alakda, orgawal, Goragawal."

**Warning**: This binds your soul forever!
**Location**: Temple Ruins

---

#### The Frost Weaver Queen

*"May all magic join with yours and yours with ours. Welcome to the Frost Weavers!"*

The Frost Weaver Queen, radiant and powerful, initiates new recruits into the Frost Weavers Guild from the ancient halls of the Burrows. She teaches the three ritual spells: GLACIOUS (ice), NIX (snow), and ILLUMINA (light).

**Location**: The Burrows

---

#### Tosh

Tosh is an enigmatic figure who serves as both undertaker at Louden's Rest and diligent explorer of the underground world. He retrieves misplaced trinkets discarded into the sewers, venturing where few others dare to tread.

**Location**: Louden's Rest

---

#### Kira

*"We'll call it mutual craft—you mend quarrels, I mend weariness."*

Kira runs the apothecary at first light when Everland yawns awake. Her hair is the color of newly spun gold, her hands dusted with dried petals, her eyes bright with quick, hopeful intelligence. Shelves line her walls like the ribs of a safe ship, filled with jars of powders and waters labeled in neat, looping script.

She offers Balm of Quick Mend for wounds and Oil of Orchid for massages. An aspiring magic-user herself, she practices small charms and healing threads. When Mage Damon arrived wounded, she tended to him—and something in both their chests rearranged.

**Services**: Healing, massage, remedies
**Location**: Kira's Apothecary

---

#### The Damsel of the Mist

*"The blue light surges ahead, a steadfast lantern in the murk."*

On the muddy roads to Everland, the Damsel wanders lost within the magic forest of mist. She seeks the enigmatic Damon of her Dreams, guided by a blue light through the tangled veil. When the lion of the muddy road tore at her gown, she lifted her sword with fearless grace and cloaked herself in the lion's fur, weaving a radiant new gown from moonlit tapestry and forest charm.

**Location**: Train Station

---

## Appendix B: Memory Expansion Support

### Overview

Everland BBS Door Game supports multiple memory expansion options for storing user data such as custom lore books. The game automatically detects available expansion RAM at startup and uses the best available option.

### Detection Priority

1. **REU (Ram Expansion Unit)** — Checked first
2. **GeoRAM** — Checked as fallback if REU not present
3. **Disk Storage** — Used if no expansion RAM is detected

### Supported Hardware

| Hardware | Detection | Capacity Used | Notes |
|----------|-----------|---------------|-------|
| REU (1700/1764/1750) | $DF00-$DF01 registers | 2KB (expandable) | Commodore's official expansion |
| GeoRAM/BBGRam | $DE00 window, $DFFE/$DFFF page | 2KB (8 pages) | Berkeley Softworks compatible |
| Disk (Device 8) | Always available | Limited by disk space | Fallback for unexpanded C64 |

### Technical Details

**REU Detection:**
- Writes test patterns $AA and $55 to $DF00/$DF01
- Reads back to verify REU responds
- If verified, sets `expansion_ram = 1`

**GeoRAM Detection:**
- Selects block 0, page 0 via $DFFE/$DFFF
- Writes pattern $A5 to $DE00 window
- Switches to page 1, writes $5A
- Switches back to page 0, verifies $A5 preserved
- If verified, sets `expansion_ram = 2`

**Runtime Variables:**
```
reu_present:    .byte 0  ; 0=no, 1=yes
georam_present: .byte 0  ; 0=no, 1=yes
expansion_ram:  .byte 0  ; 0=none, 1=REU, 2=GeoRAM
```

### User Lore Storage

When pasting custom lore books via the Library menu:
- **REU**: Stored in `reu_lore_pages` buffer (2KB, 16 x 128-byte pages)
- **GeoRAM**: Stored in block 0, pages 0-7 (2KB)
- **Disk**: Stored as sequential file "USERLORE,S" on device 8

### Performance Considerations

- **REU/GeoRAM**: Instant access, no disk I/O latency
- **Disk**: Slower but works on any C64 with drive
- Built-in library stories remain in program memory for fast access

---

## Credits

- **Producer**: Damon Hogan
- **Inspired by**: Perry Fraptic (RetroRecipes YouTube)
- **Hardware inspiration**: Commodore 64 Ultimate, commodore.net
- **Tooling**: Kick Assembler, Visual Studio Code, VICE

---

*This manual documents the Everland BBS Door Game as of build $c000-$262d2*
