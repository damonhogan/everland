// KICK ASSEMBLER C64 ADVENTURE ENGINE
// Enhanced with location descriptions, extended commands, and NPCs
:BasicUpstart2(start)
// HP regeneration timer
lastRegen0: .byte 0
// Player race name and index
raceName: .fill 12, 0
playerRaceIdx: .byte 0
// Player PIN and level
pinLo: .byte 0
pinHi: .byte 0
currentLevel: .byte 0
// Player score and quest state
scoreLo: .byte 0
scoreHi: .byte 0
activeQuest: .byte 0
questStatus: .byte 0
// Player coin balances
playerGold: .byte 0
playerSilver: .byte 0
playerCopper: .byte 0

// KERNAL routines
.label CHROUT = $FFD2
.label SCNKEY = $FF9F
.label GETIN  = $FFE4
.label PLOT   = $FFF0
.label SETNAM = $FFBD
.label SETLFS = $FFBA
.label OPEN   = $FFC0
.label CLOSE  = $FFC3
.label CHKIN  = $FFC6
.label CHKOUT = $FFC9
.label CLRCHN = $FFCC
.label CHRIN  = $FFCF
.label READST = $FFB7
.label RDTIM  = $FFDE

// SID registers
.label SID_V1_FREQLO = $D400
.label SID_V1_FREQHI = $D401
.label SID_V1_PWLO   = $D402
.label SID_V1_PWHI   = $D403
.label SID_V1_CTRL   = $D404
.label SID_V1_AD     = $D405
.label SID_V1_SR     = $D406
.label SID_V2_FREQLO = $D407
.label SID_V2_FREQHI = $D408
.label SID_V2_PWLO   = $D409
.label SID_V2_PWHI   = $D40A
.label SID_V2_CTRL   = $D40B
.label SID_V2_AD     = $D40C
.label SID_V2_SR     = $D40D
.label SID_V3_FREQLO = $D40E
.label SID_V3_FREQHI = $D40F
.label SID_V3_PWLO   = $D410
.label SID_V3_PWHI   = $D411
.label SID_V3_CTRL   = $D412
.label SID_V3_AD     = $D413
.label SID_V3_SR     = $D414
.label SID_MODE_VOL  = $D418

// IRQ vectors
.label IRQ_VEC_LO = $0314
.label IRQ_VEC_HI = $0315

// VIC raster IRQ
.label VIC_IRQFLAG = $D019
.label VIC_IRQMASK = $D01A
.label VIC_RASTER  = $D012
.label VIC_CTRL1   = $D011

// Memory
.label SCREEN = $0400

// Zero page
.label ZP_PTR  = $FB // $FB/$FC
.label ZP_PTR2 = $FD // $FD/$FE

// IEC/device constants
.const DEVICE = 8
.const LFN    = 1
.const SA     = 2

// Location constants (Train  Bank)
.const LOC_TRAIN     = 0
.const LOC_MARKET    = 1
.const LOC_PORTAL    = 2
.const LOC_GOLEM     = 3
.const LOC_PLAZA     = 4
.const LOC_ALLEY     = 5
.const LOC_MYSTIC    = 6
.const LOC_GROVE     = 7
.const LOC_TAVERN    = 8
.const LOC_GRAVE     = 9
.const LOC_CATACOMBS = 10
.const LOC_INN       = 11
.const LOC_TEMPLE    = 12
.const LOC_BANK      = 13
.const LOC_COUNT     = 14

// Screen row layout
.const ROW_MAP_LAST   = 11
.const ROW_DIVIDER    = 12
.const ROW_UI_START   = 13
.const ROW_DESC       = 14
.const ROW_SEASON     = 17
.const ROW_EXITS      = 18
.const ROW_QUEST      = 19
.const ROW_MSG        = 20
.const ROW_HELP       = 22
.const ROW_PROMPT     = 24

.const ROW_AUTH_MSG    = 12
.const ROW_AUTH_PROMPT = 14

.const OBJ_LANTERN     = 0
.const OBJ_COIN        = 1
.const OBJ_MUG         = 2
.const OBJ_KEY         = 3
.const OBJ_TREASURE    = 4
.const OBJ_STOLEN_NAME = 5
.const OBJ_HEART       = 6
.const OBJ_PINECONE    = 7
.const OBJ_SHELL       = 8
.const OBJ_SCOTCH      = 9
.const OBJ_WARD        = 10
.const OBJ_COUNT       = 11
.const OBJ_INVENTORY   = $FE
.const OBJ_NOWHERE     = $FF

// NPC constants
.const NPC_CONDUCTOR        = 0
.const NPC_BARTENDER        = 1
.const NPC_KNIGHT           = 2
.const NPC_MYSTIC           = 3
.const NPC_FAIRY            = 4
.const NPC_KENDRICK         = 5
.const NPC_SPIDER_PRINCESS  = 6
.const NPC_PIRATE_CAPTAIN   = 7
.const NPC_WARLOCK          = 8
.const NPC_UNSEELY_FAE      = 9
.const NPC_APOLLONIA        = 10
.const NPC_ALYSTER          = 11
.const NPC_TROLL            = 12
.const NPC_TOSH             = 13
.const NPC_LOUDEN           = 14
.const NPC_MERMAID          = 15
.const NPC_CANDY_WITCH      = 16
.const NPC_KORA             = 17
.const NPC_ALPHA_WOLFRIC    = 18
.const NPC_VASHTEE          = 19
.const NPC_TRADING_OWNER    = 20
.const NPC_FROST_WEAVERS_QUEEN = 21
.const NPC_BANKER           = 22
// Legacy alias (maps PIXIE to FAIRY slot)
.const NPC_PIXIE            = NPC_FAIRY
// First mate alias; currently share captain slot
.const NPC_PIRATE_FIRSTMATE = NPC_PIRATE_CAPTAIN
.const NPC_COUNT            = 32

// Max characters stored for each NPC given name
.const NPC_GIVEN_NAME_LEN   = 16

// Seasons
.const SEASON_OFF    = 0
.const SEASON_MYTHOS = 1
.const SEASON_LORE   = 2
.const SEASON_AURORA = 3

// Quest IDs
.const QUEST_NONE                   = $FF
.const QUEST_COIN_BARTENDER         = 0
.const QUEST_KEY_KNIGHT             = 1
.const QUEST_LANTERN_MYSTIC         = 2
.const QUEST_TREASURE               = 3
.const QUEST_LURE_MYSTIC            = 4
.const QUEST_BLACK_ROSE             = 5
.const QUEST_UNSEELY_NAME           = 6
.const QUEST_APOLLONIA_OFFERING     = 7
.const QUEST_LOUDEN_HEART           = 8
.const QUEST_MERMAID_TRADE          = 9
.const QUEST_KENDRICK_SCOTCH        = 10
.const QUEST_WARLOCK_WARD           = 11
.const QUEST_CANDY_WITCH_DISABLE_WARD = 12
.const QUEST_KORA_JAPE              = 13
.const QUEST_ALPHA_WOLFRIC          = 14
// Total number of distinct quest IDs used with assignQuest_mod / rewards
.const QUEST_COUNT                  = 15

.encoding "petscii_upper"

// Game and UI state
currentLoc:    .byte LOC_PLAZA
prevLoc:       .byte LOC_PLAZA
lastMsgLo:     .byte <msgWelcome
lastMsgHi:     .byte >msgWelcome
uiHideExits:   .byte 0
uiInConversation: .byte 0

// Combat / debug flags
inCombat:       .byte 0    // 0 = not in combat, 1 = in combat (reserved for future use)
combatNpcIdx:   .byte 0    // last/active combat opponent (npc index)
// Debug mode flag (enabled in dev auto-login)
debugEnabled: .byte 0

// Debug print for coin location/state if enabled
debug_print_coin_info:
	rts

// Player profile (fixed-length text, 0 padded)
usernameLen: .byte 0
username:
	.fill 12, 0
displayLen: .byte 0
displayName:
	.fill 16, 0
// Player class (e.g. KNIGHT, PALADIN, MAGE) - stored as fixed 12-byte, 0-padded
classLen: .byte 0
className:
	.fill 12, 0
playerClassIdx: .byte 0
playerCurHp: .byte 0
// Temporary bonus to max HP from training (session-only)
playerHpBonus: .byte 0
// Player guild membership flags
playerGuildMember: .byte 0	// 1 = member of Order of the Emerald Sky
// Player race (e.g. HUMAN, TROLL, ELF, DRAGON) - fixed 12-byte, 0-padded
raceLen: .byte 0
// Calendar / progression
month: .byte 1  // 1-12 (default JAN)
week:  .byte 1  // 1-52 (default week 1)
lastRegen1:    .byte 0
lastRegen2:    .byte 0
nowRegen0:     .byte 0
nowRegen1:     .byte 0
nowRegen2:     .byte 0
deltaReg0:     .byte 0
deltaReg1:     .byte 0
deltaReg2:     .byte 0
regenMinutes:  .byte 0
regenTotal:    .byte 0
regenInit:     .byte 0
hpChangedFlag: .byte 0
healLeft:      .byte 0

// Bank variables
bankCopper: .byte 0
bankSilver: .byte 0
bankGold: .byte 0
interestRate: .byte 5 // 5% interest
exchangeCopperToSilver: .byte 10
exchangeSilverToGold: .byte 10
vaultRented: .byte 0
vaultItems: .fill 10, $FF  // 10 vault slots, $FF = empty

// Trinket system
.const TRINKET_COUNT = 32
playerTrinkets: .fill 5, $FF  // 5 trinket slots, $FF = none
playerTrinketsAssigned: .byte 0
npcTrinkets: .fill 32*3, $FF  // 3 trinkets per NPC, $FF = none

// Save filename buffers
saveBaseLen: .byte 0
saveBaseBuf:
	.fill 16, 0
saveNameLen: .byte 0
saveNameBuf:
	.fill 24, 0
// --- Dev-mode auto login defaults ---
autoMarkerName: .byte 'E','V','A','U','T','O'
autoUserZ:  .text "autotest"; .byte 0
autoDispZ:  .text "auto"; .byte 0
autoClassZ: .text "knight"; .byte 0


// Music state (runs in IRQ)
musicEnabled: .byte 0
musicTheme:   .byte 0 // 0=off,1=mythos,2=lore,3=aurora,4=scary,5=tavern,6=inn,7=temple,8=fairy,9=pirate
musicPattern: .byte 0 // 0..2 within theme
musicStep:    .byte 0 // 0..15
musicTick:    .byte 0 // countdown
musicStepLen: .byte 8
musicBassStep:.byte 0
musicBassTick:.byte 0
musicBassLen: .byte 16
musicSparkStep:.byte 0
musicSparkTick:.byte 0
musicSparkLen: .byte 4
leadWave: .byte $10   // TRI by default (waveform bits only// gate bit added dynamically)
bassWave: .byte $10   // TRI
sparkWave:.byte $40   // PULSE
irqOldLo: .byte 0
irqOldHi: .byte 0
musicInstalled: .byte 0

// Dynamic message buffer (used for characters/inventory listings)
msgBufLen: .byte 0
msgBuf:
	.fill 256, 0

// Temporary selection state for menus
selCount: .byte 0
selChoice: .byte 0
tmpNpcIdx: .byte 0
tmpHp: .byte 0
tmpPer: .byte 0,0
tmpNumber: .byte 0
tmpDigit: .byte 0
tmpNounStart: .byte 0
// Per-NPC conversation stage (0 = initial, 1 = progressed)
npcConvStage:
	.fill NPC_COUNT, 0
npcMaskHiTemp: .byte 0
npcMaskB2Temp: .byte 0
npcMaskB3Temp: .byte 0
// Ward disable flag used by Candy Witch
wardDisabledFlag: .byte 0
tmpCnt: .byte 0
tmpCnt2: .byte 0

// Input buffer (PETSCII)
prefetchedHas: .byte 0
prefetchedKey: .byte 0
inputLen: .byte 0
lastKey: .byte 0
inputBuf:
	.fill 48, 0
// Object locations (location id, $FE=inventory, $FF=nowhere)
objLoc:
	.fill OBJ_COUNT, 0

// --- Program entry ---
start:
	// Force a consistent C64 character set for all UI text
	lda #$0e
	jsr CHROUT
	jsr init
mainLoop:
	jsr applyRegenIfDue
	jsr render
	jsr readLine
	jsr executeCommand
	jmp mainLoop

// --- Profile / Save system ---
// MVP: per-username save file on DEVICE 8.
// File format (binary, fixed sizes):
//  EV1: "EV1" username[12], display[16], pinLo,pinHi, scoreLo,scoreHi, level, curHP, classIdx, month, week, loc, objLoc[], activeQuest, questStatus
//  EV2: "EV2" username[12], display[16], class[12], race[12], pinLo,pinHi, scoreLo,scoreHi, level, curHP, classIdx, raceIdx, month, week, loc, objLoc[], activeQuest, questStatus
//  EV3: "EV3" username[12], display[16], class[12], race[12], pinLo,pinHi, scoreLo,scoreHi, level, curHP, classIdx, raceIdx, maxHP, month, week, loc, objLoc[], activeQuest, questStatus

loginOrCreate:
	// Prompt USERNAME
	lda #<msgAskUser
	sta lastMsgLo
	lda #>msgAskUser
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr copyInputToUsername
	jsr buildSaveNameBase

	// Try load// if fails, create profile
	jsr tryLoadGame
	bcc @loc_create
	jmp @loaded

@loc_create:
  	// Prompt DISPLAY NAME
	lda #<msgAskDisplay
	sta lastMsgLo
	lda #>msgAskDisplay
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr copyInputToDisplay

	// Prompt CLASS
	lda #<msgAskClass
	sta lastMsgLo
	lda #>msgAskClass
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr copyInputToClass
	jsr mapPlayerClass
	// Initialize HP based on chosen class/level
	jsr computePlayerMaxHp
	lda tmpHp
	sta playerCurHp

	// Prompt RACE
	lda #<msgAskRace
	sta lastMsgLo
	lda #>msgAskRace
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr copyInputToRace
	jsr mapPlayerRace

	// Prompt PIN
	lda #<msgAskPin
	sta lastMsgLo
	lda #>msgAskPin
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr parsePinFromInput

	// Set MONTH and WEEK from C64 clock (RDTIM)
	jsr RDTIM
	// RDTIM returns: A = 1/60 sec, X = seconds, Y = minutes
	stx ZP_PTR    // save X (seconds) to ZP_PTR
	sty ZP_PTR+1  // save Y (minutes) to ZP_PTR+1
	lda ZP_PTR
	and #$0F
	clc
	adc #1
	sta month   // 1-12
	lda ZP_PTR+1
	lsr
	lsr
	clc
	adc #1
	sta week    // 1-52

	// Defaults
	lda #LOC_TRAIN
	sta currentLoc
	lda #0
	sta scoreLo
	sta scoreHi
	lda #QUEST_NONE
	sta activeQuest
	lda #0
	sta questStatus
	lda #9
	sta playerCopper
	lda #1
	sta playerSilver

	// Reset objects to starting positions
	lda #LOC_TRAIN
	sta objLoc+OBJ_LANTERN
	lda #LOC_TAVERN
	sta objLoc+OBJ_MUG
	lda #LOC_PORTAL
	sta objLoc+OBJ_KEY
	lda #LOC_GROVE
	sta objLoc+OBJ_PINECONE
	lda #OBJ_NOWHERE
	sta objLoc+OBJ_SHELL

	jsr setupNpcGivenNames
	jsr assignRandomTrinkets
	lda #1
	sta playerTrinketsAssigned
	jsr saveGame
	lda #<msgCreated
	sta lastMsgLo
	lda #>msgCreated
	sta lastMsgHi
	rts

@loaded:
	// Prompt PIN to unlock
	lda #<msgAskPinLogin
	sta lastMsgLo
	lda #>msgAskPinLogin
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr parsePinFromInput
	lda pinLo
	cmp loadedPinLo
	bne @pin_bad
	lda pinHi
	cmp loadedPinHi
	bne @pin_bad
	// Pin OK, copy loaded state into live state
	jsr commitLoadedState
	jsr buildWelcomeBack
	rts

@pin_bad:
	lda #<msgBadPin
	sta lastMsgLo
	lda #>msgBadPin
	sta lastMsgHi
	rts

// Loaded staging
loadedPinLo: .byte 0
loadedPinHi: .byte 0
loadedScoreLo: .byte 0
loadedScoreHi: .byte 0
loadedMonth: .byte 4
loadedWeek: .byte 14
loadedLoc: .byte LOC_PLAZA
loadedLevel: .byte 0
loadedObjLoc:
	.fill OBJ_COUNT, 0
loadedActiveQuest: .byte QUEST_NONE
loadedQuestStatus: .byte 0
loadedDisplay:
	.fill 16, 0
loadedClass:
	.fill 12, 0
loadedCurHp: .byte 0
loadedClassIdx: .byte 0
loadedRace:
	.fill 12, 0
loadedRaceIdx: .byte 0
loadedFileVer: .byte 1
loadedMaxHp: .byte 0
loadedGold: .byte 0
loadedSilver: .byte 0
loadedCopper: .byte 0

commitLoadedState:
	lda loadedPinLo
	sta pinLo
	lda loadedPinHi
	sta pinHi
	lda loadedScoreLo
	sta scoreLo
	lda loadedScoreHi
	sta scoreHi
	lda loadedLevel
	sta currentLevel
	lda loadedMonth
	sta month
	lda loadedWeek
	sta week
	lda loadedLoc
	sta currentLoc
	ldx #0
commit_c1:
	lda loadedObjLoc,x
	sta objLoc,x
	inx
	cpx #OBJ_COUNT
	bne commit_c1
	lda loadedActiveQuest
	sta activeQuest
	lda loadedQuestStatus
	sta questStatus
	// Copy display
	ldx #0
commit_c2:
	lda loadedDisplay,x
	sta displayName,x
	inx
	cpx #16
	bne commit_c2
	// Copy loaded class into live className (12 bytes)
	ldx #0
commit_c3:
	lda loadedClass,x
	sta className,x
	inx
	cpx #12
	bne commit_c3
	// Copy loaded race into live raceName (12 bytes)
	ldx #0
commit_c4:
	lda loadedRace,x
	sta raceName,x
	inx
	cpx #12
	bne commit_c4
	// restore player class idx and HP from loaded values
	lda loadedClassIdx
	sta playerClassIdx
	lda loadedCurHp
	sta playerCurHp
	// restore player race idx
	lda loadedRaceIdx
	sta playerRaceIdx
	// restore player coins
	lda loadedGold
	sta playerGold
	lda loadedSilver
	sta playerSilver
	lda loadedCopper
	sta playerCopper
	// copy loaded given names into runtime buffer
	ldx #0
@cln_copy:
	lda loadedGivenNames,x
	sta npcGivenNames,x
	inx
	cpx #(NPC_COUNT * NPC_GIVEN_NAME_LEN)
	bne @cln_copy
	rts

// Copy inputBuf to username (max 12)
copyInputToUsername:
	ldx #0
	stx usernameLen

copyInputToUsername_loop:
	lda inputBuf,x
	beq copyInputToUsername_done
	cpx #12
	bcs copyInputToUsername_done
	sta username,x
	inx
	stx usernameLen
	jmp copyInputToUsername_loop

copyInputToUsername_done:
	// Pad remaining with 0
	lda #0

copyInputToUsername_pad:
	cpx #12
	beq copyInputToUsername_pdone
	sta username,x
	inx
	jmp copyInputToUsername_pad

copyInputToUsername_pdone:
	rts

	// Copy inputBuf to className (max 12)
	copyInputToClass:
		ldx #0
		stx classLen

	@copyClass_loop:
		lda inputBuf,x
		beq @copyClass_done
		cpx #12
		bcs @copyClass_done
		sta className,x
		inx
		stx classLen
		jmp @copyClass_loop

	@copyClass_done:
		// Pad remaining with 0
		lda #0

	@copyClass_pad:
		cpx #12
		beq @copyClass_pdone
		sta className,x
		inx
		jmp @copyClass_pad

	@copyClass_pdone:
		rts

// Copy inputBuf to raceName (max 12)
copyInputToRace:
	ldx #0
	stx raceLen

@copyRace_loop:
	lda inputBuf,x
	beq @copyRace_done
	cpx #12
	bcs @copyRace_done
	sta raceName,x
	inx
	stx raceLen
	jmp @copyRace_loop

@copyRace_done:
	// Pad remaining with 0
	lda #0

@copyRace_pad:
	cpx #12
	beq @copyRace_pdone
	sta raceName,x
	inx
	jmp @copyRace_pad

@copyRace_pdone:
	rts

// Map player's textual className to playable class index by first letter
mapPlayerClass:
	lda className
	beq @mpc_default
	// convert lowercase to uppercase if needed
	cmp #'a'
	bcc @mpc_check
	cmp #'z'+1
	bcs @mpc_check
	sec
	sbc #32

@mpc_check:
	cmp #'M'
	beq @mpc_m
	cmp #'K'
	beq @mpc_k
	cmp #'H'
	beq @mpc_h
	cmp #'B'
	beq @mpc_b
	cmp #'W'
	beq @mpc_w

@mpc_default:
	lda #0
	sta playerClassIdx
	rts

@mpc_m:
	lda #0
	sta playerClassIdx
	rts
@mpc_k:
	lda #1
	sta playerClassIdx
	rts
@mpc_h:
	lda #2
	sta playerClassIdx
	rts
@mpc_b:
	lda #3
	sta playerClassIdx
	rts
@mpc_w:
	lda #4
	sta playerClassIdx
	rts

// Map player's textual raceName to race index by first letter
mapPlayerRace:
	lda raceName
	beq @mpr_default
	// convert lowercase to uppercase if needed
	cmp #'a'
	bcc @mpr_check
	cmp #'z'+1
	bcs @mpr_check
	sec
	sbc #32

@mpr_check:
	cmp #'H'
	beq @mpr_h
	cmp #'T'
	beq @mpr_t
	cmp #'E'
	beq @mpr_e
	cmp #'D'
	beq @mpr_d

@mpr_default:
	lda #0
	sta playerRaceIdx
	rts

@mpr_h:
	lda #0
	sta playerRaceIdx
	rts
@mpr_t:
	lda #1
	sta playerRaceIdx
	rts
@mpr_e:
	lda #2
	sta playerRaceIdx
	rts
@mpr_d:
	lda #3
	sta playerRaceIdx
	rts

copyInputToDisplay:
	ldx #0
	stx displayLen

@cd_loop:
	lda inputBuf,x
	beq @cd_done
	cpx #16
	bcs @cd_done
	sta displayName,x
	inx
	stx displayLen
	jmp @cd_loop

@cd_done:
	lda #0

@cd_pad:
	cpx #16
	beq @cd_pdone
	sta displayName,x
	inx
	jmp @cd_pad

@cd_pdone:
	rts

// Copy inputBuf to given-name slot for NPC index in X (0..NPC_COUNT-1)
copyInputToGivenName:
	// set pointer to the NPC's given-name slot
	lda npcGivenNamePtrLo,x
	sta ZP_PTR
	lda npcGivenNamePtrHi,x
	sta ZP_PTR+1
	ldy #0
@cign_loop:
	lda inputBuf,y
	beq @cign_done
	cpy #NPC_GIVEN_NAME_LEN
	bcs @cign_done
	sta (ZP_PTR),y
	iny
	jmp @cign_loop
@cign_done:
	// pad remaining bytes with 0
	cpy #NPC_GIVEN_NAME_LEN
	beq @cign_pad_done
	lda #0
@cign_pad:
	sta (ZP_PTR),y
	iny
	cpy #NPC_GIVEN_NAME_LEN
	bcc @cign_pad
@cign_pad_done:
	rts

// Interactive setup: ask the player for a given name for each known NPC
setupNpcGivenNames:
	// linear loop index stored in givenNameLoopIndex
	lda #0
	sta givenNameLoopIndex
@sn_loop:
	lda givenNameLoopIndex
	cmp #NPC_COUNT
	bcs @sn_continue
	rts
@sn_continue:
	tax
	// skip unknown named NPC slots
	lda npcNameLo,x
	cmp #<npcNameUnknown
	bne @sn_hasname
	lda npcNameHi,x
	cmp #>npcNameUnknown
	beq @sn_inc
@sn_hasname:
	// Prompt: "ENTER A GIVEN NAME FOR:" then print NPC title
	lda #<msgAskNpcName
	sta lastMsgLo
	lda #>msgAskNpcName
	sta lastMsgHi
	jsr render
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	// Read player's input and store into the slot
	jsr readLine
	lda givenNameLoopIndex
	tax
	jsr copyInputToGivenName
@sn_inc:
	// increment index
	lda givenNameLoopIndex
	clc
	adc #1
	sta givenNameLoopIndex
	jmp @sn_loop

// Parse 0-65535 from inputBuf into pinLo/pinHi
parsePinFromInput:
	lda #0
	sta pinLo
	sta pinHi
	ldx #0

@pp_loop:
	lda inputBuf,x
	beq @pp_done
	cmp #'0'
	bcc @pp_skip
	cmp #'9'+1
	bcs @pp_skip
	sec
	sbc #'0'
	sta ZP_PTR // digit
	// pin = pin*10 + digit
	jsr pinMul10
	clc
	lda pinLo
	adc ZP_PTR
	sta pinLo
	lda pinHi
	adc #0
	sta pinHi

@pp_skip:
	inx
	cpx #48
	bne @pp_loop

@pp_done:
	rts

pinMul10:
	// (pinHi:pinLo) *= 10
	// tmp = pin*2
	lda pinLo
	asl
	sta ZP_PTR
	lda pinHi
	rol
	sta ZP_PTR+1
	// pin*8 = pin*2*4
	lda ZP_PTR
	asl
	asl
	sta ZP_PTR2
	lda ZP_PTR+1
	rol
	rol
	sta ZP_PTR2+1
	// pin*10 = pin*8 + pin*2
	clc
	lda ZP_PTR2
	adc ZP_PTR
	sta pinLo
	lda ZP_PTR2+1
	adc ZP_PTR+1
	sta pinHi
	rts

parseMonthFromInput:
	jsr parseSmallNumber
	cmp #1
	bcc @pm_def
	cmp #13
	bcs @pm_def
	sta month
	rts

@pm_def:
	lda #4
	sta month
	rts

parseWeekFromInput:
	jsr parseSmallNumber
	cmp #1
	bcc @pw_def
	cmp #53
	bcs @pw_def
	sta week
	rts

@pw_def:
	lda #14
	sta week
	rts

// Parse small number 0-255 from inputBuf, returns in A
parseSmallNumber:
	lda #0
	sta ZP_PTR
	ldx #0

@ps_loop:
	lda inputBuf,x
	beq @ps_done
	cmp #'0'
	bcc @ps_next
	cmp #'9'+1
	bcs @ps_next
	sec
	sbc #'0'
	sta ZP_PTR2
	// val = val*10 + digit
	lda ZP_PTR
	asl
	sta ZP_PTR
	asl
	asl
	clc
	adc ZP_PTR
	adc ZP_PTR2
	sta ZP_PTR

@ps_next:
	inx
	cpx #48
	bne @ps_loop

@ps_done:
	lda ZP_PTR
	rts

// Build base save filename: "EV" + username (no extension)
buildSaveNameBase:
	ldx #0
	lda #'E'
	sta saveBaseBuf,x
	inx
	lda #'V'
	sta saveBaseBuf,x
	inx
	ldy #0

@bsb_loop:
	cpy usernameLen
	beq @bsb_done
	lda username,y
	beq @bsb_done
	sta saveBaseBuf,x
	inx
	iny
	cpx #16
	bcc @bsb_loop

@bsb_done:
	stx saveBaseLen
	rts

// Build saveNameBuf = base + ",S,R" or ",S,W" (mode in A: 'R' or 'W')
buildSaveNameWithMode:
	pha
	// Copy base into saveNameBuf
	ldx #0
@cbase:
	cpx saveBaseLen
	beq @suffix
	lda saveBaseBuf,x
	sta saveNameBuf,x
	inx
	jmp @cbase
@suffix:
	// Append suffix
	lda #','
	sta saveNameBuf,x
	inx
	lda #'S'
	sta saveNameBuf,x
	inx
	lda #','
	sta saveNameBuf,x
	inx
	pla
	sta saveNameBuf,x
	inx
	stx saveNameLen
	rts

tryLoadGame:
	// returns C=1 if loaded into staging
	lda #'R'
	jsr buildSaveNameWithMode
	lda saveNameLen
	ldx #<saveNameBuf
	ldy #>saveNameBuf
	jsr SETNAM
	lda #LFN
	ldx #DEVICE
	ldy #SA
	jsr SETLFS
	jsr OPEN
	jsr READST
	beq @tl_ok
	jmp @tl_fail

@tl_ok:
	lda #LFN
	jsr CHKIN
	// Read header
	jsr CHRIN
	cmp #'E'
	beq @tl_c1
	jmp @fail2
@tl_c1:
	jsr CHRIN
	cmp #'V'
	beq @tl_c2
	jmp @fail2
@tl_c2:
	jsr CHRIN
	cmp #'1'
	beq @tl_ver1
	cmp #'2'
	beq @tl_ver2
	cmp #'3'
	beq @tl_ver3
	cmp #'4'
	beq @tl_ver4
	jmp @fail2
@tl_ver1:
	lda #0
	sta loadedFileVer
	jmp @tl_header_ok
@tl_ver2:
	lda #1
	sta loadedFileVer
 	jmp @tl_header_ok
@tl_ver3:
	lda #2
	sta loadedFileVer
@tl_ver4:
	lda #3
	sta loadedFileVer
@tl_header_ok:
	// Read username (skip, we already have it)
	ldx #0
@ru:
	jsr CHRIN
	sta ZP_PTR
	ldx #0
@rcl:
	jsr CHRIN
	sta loadedClass,x
	inx
	cpx #12
	bne @rcl
	// Read race (12 bytes) if version 2
	lda loadedFileVer
	beq @rcl_race_default
	ldx #0
@rr:
	jsr CHRIN
	sta loadedRace,x
	inx
	cpx #12
	bne @rr
	jmp @after_race_read
@rcl_race_default:
	// Default race = HUMAN
	ldx #0
	lda #'H'
	sta loadedRace,x
	inx
	lda #'U'
	sta loadedRace,x
	inx
	lda #'M'
	sta loadedRace,x
	inx
	lda #'A'
	sta loadedRace,x
	inx
	lda #'N'
	sta loadedRace,x
	inx
@fill_race_zero:
	cpx #12
	beq @after_race_read
	lda #0
	sta loadedRace,x
	inx
	jmp @fill_race_zero
@after_race_read:
	// pin
	jsr CHRIN
	sta loadedPinLo
	jsr CHRIN
	sta loadedPinHi
	// score
	jsr CHRIN
	sta loadedScoreLo
	jsr CHRIN
	sta loadedScoreHi
	// level
	jsr CHRIN
	sta loadedLevel
	// player current HP
	jsr CHRIN
	sta loadedCurHp
	// player class index
	jsr CHRIN
	sta loadedClassIdx
	// player race index (version 2)
	lda loadedFileVer
	beq @skip_race_idx
	jsr CHRIN
	sta loadedRaceIdx
@skip_race_idx:
	// max HP (version 3)
	lda loadedFileVer
	cmp #2
	bne @skip_maxhp
	jsr CHRIN
	sta loadedMaxHp
@skip_maxhp:
	// month/week/loc
	jsr CHRIN
	sta loadedMonth
	jsr CHRIN
	sta loadedWeek
	jsr CHRIN
	sta loadedLoc
	// objLoc
	ldx #0
@ro:
	jsr CHRIN
	sta loadedObjLoc,x
	inx
	cpx #OBJ_COUNT
	bne @ro
	// quest
	jsr CHRIN
	sta loadedActiveQuest
	jsr CHRIN
	sta loadedQuestStatus
	// player coins (EV4)
	lda loadedFileVer
	cmp #3
	bne @skip_coins
	jsr CHRIN
	sta loadedGold
	jsr CHRIN
	sta loadedSilver
	jsr CHRIN
	sta loadedCopper
@skip_coins:
	// Read given names (fixed-length slots) only for EV3 saves
	lda loadedFileVer
	cmp #2
	bne @rln_skip
	ldx #0
@rln_read:
	jsr CHRIN
	sta loadedGivenNames,x
	inx
	cpx #(NPC_COUNT * NPC_GIVEN_NAME_LEN)
	bne @rln_read
@rln_skip:
	jsr CLRCHN
	lda #LFN
	jsr CLOSE
	sec
	rts

@fail2:
	jsr CLRCHN
	lda #LFN
	jsr CLOSE

@tl_fail:
	clc
	rts

saveGame:
	// Show a friendly message while saving
	jsr setCursorMsg
	lda #<strSavingUser
	sta ZP_PTR
	lda #>strSavingUser
	sta ZP_PTR+1
	jsr printZ

	lda #'W'
	jsr buildSaveNameWithMode
	lda saveNameLen
	ldx #<saveNameBuf
	ldy #>saveNameBuf
	jsr SETNAM
	lda #LFN
	ldx #DEVICE
	ldy #SA
	jsr SETLFS
	jsr OPEN
	jsr READST
	beq @sg_write

@sg_write:
	lda #LFN
	jsr CHKOUT
	// Header
	lda #'E'
	jsr CHROUT
	lda #'V'
	jsr CHROUT
	lda #'4'
	jsr CHROUT
	// username
	ldx #0
@wu:
	lda username,x
	jsr CHROUT
	inx
	cpx #12
	bne @wu
	// display
	ldx #0
@wd:
	lda displayName,x
	jsr CHROUT
	inx
	cpx #16
	bne @wd
	// className (12 bytes)
	ldx #0
@wc:
	lda className,x
	jsr CHROUT
	inx
	cpx #12
	bne @wc
	// raceName (12 bytes)
	ldx #0
@wr:
	lda raceName,x
	jsr CHROUT
	inx
	cpx #12
	bne @wr
	// pin
	lda pinLo
	jsr CHROUT
	lda pinHi
	jsr CHROUT
	// score
	lda scoreLo
	jsr CHROUT
	lda scoreHi
	jsr CHROUT
	// level
	lda currentLevel
	jsr CHROUT
	// player current HP
	lda playerCurHp
	jsr CHROUT
	// player class index
	lda playerClassIdx
	jsr CHROUT
	// player race index
	lda playerRaceIdx
	jsr CHROUT
	// player max HP at time of save (recomputed)
	jsr computePlayerMaxHp
	lda tmpHp
	jsr CHROUT
	// month/week/loc
	lda month
	jsr CHROUT
	lda week
	jsr CHROUT
	lda currentLoc
	jsr CHROUT
	// objLoc
	ldx #0
@wo:
	lda objLoc,x
	jsr CHROUT
	inx
	cpx #OBJ_COUNT
	bne @wo
	// quest
	lda activeQuest
	jsr CHROUT
	lda questStatus
	jsr CHROUT
	// player coins
	lda playerGold
	jsr CHROUT
	lda playerSilver
	jsr CHROUT
	lda playerCopper
	jsr CHROUT
	// Write given names (fixed-length slots)
	ldx #0
@wgn_write:
	lda npcGivenNames,x
	jsr CHROUT
	inx
	cpx #(NPC_COUNT * NPC_GIVEN_NAME_LEN)
	bne @wgn_write
	jsr CLRCHN
	lda #LFN
	jsr CLOSE

@sg_done:
	rts

buildWelcomeBack:
	jsr clearMsgBuf
	lda #<msgWelcomeBack
	sta ZP_PTR
	lda #>msgWelcomeBack
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<displayName
	sta ZP_PTR
	lda #>displayName
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<msgExclaim
	sta ZP_PTR
	lda #>msgExclaim
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<msgBuf
	sta lastMsgLo
	lda #>msgBuf
	sta lastMsgHi
	rts

// --- Seasons / Weather ---
getSeason:
	// returns season in A
	lda month
	cmp #4
	bcc @off
	cmp #9
	bcc @mythos
	cmp #11
	bcc @lore
	cmp #13
	bcc @aurora
@off:
	lda #SEASON_OFF
	rts
@mythos:
	lda #SEASON_MYTHOS
	rts
@lore:
	lda #SEASON_LORE
	rts
@aurora:
	lda #SEASON_AURORA
	rts

renderSeasonLine:
	// Clear the entire season row, then print a compact season label.
	// Cursor is already at ROW_SEASON when this is called.
	ldx #40
	lda #' '
@rsl_clear_loop:
	jsr CHROUT
	dex
	bne @rsl_clear_loop
	// Reset cursor to start of season row and print label + season name.
	jsr setCursorSeason
	lda #<strSeason
	sta ZP_PTR
	lda #>strSeason
	sta ZP_PTR+1
	jsr printZ
	jsr getSeason
	cmp #SEASON_MYTHOS
	beq @rsl_mythos
	cmp #SEASON_LORE
	beq @rsl_lore
	cmp #SEASON_AURORA
	beq @rsl_aurora
@rsl_off:
	lda #<strSeasonOff
	sta ZP_PTR
	lda #>strSeasonOff
	sta ZP_PTR+1
	jsr printZ
	rts
@rsl_mythos:
	lda #<strSeasonMythos
	sta ZP_PTR
	lda #>strSeasonMythos
	sta ZP_PTR+1
	jsr printZ
	rts
@rsl_lore:
	lda #<strSeasonLore
	sta ZP_PTR
	lda #>strSeasonLore
	sta ZP_PTR+1
	jsr printZ
	rts
@rsl_aurora:
	lda #<strSeasonAurora
	sta ZP_PTR
	lda #>strSeasonAurora
	sta ZP_PTR+1
	jsr printZ
	rts

// --- HP Regeneration (1 HP per minute when not in combat) ---
// Uses the KERNAL real-time clock (jiffy clock) via RDTIM.
// We record the last regen timestamp and, on each loop, compute elapsed minutes.
// For each elapsed minute, we heal up to 1 HP (not exceeding max), and always
// advance the regen baseline by the full elapsed minutes.

initRegenTimer:
	jsr RDTIM
	sta lastRegen0
	txa
	sta lastRegen1
	tya
	sta lastRegen2
	lda #1
	sta regenInit
	rts

applyRegenIfDue:
	lda regenInit
	bne @ard_have_base
	jsr initRegenTimer
	rts
@ard_have_base:
	// Read current time
	jsr RDTIM
	sta nowRegen0
	txa
	sta nowRegen1
	tya
	sta nowRegen2
	// delta = now - last
	sec
	lda nowRegen0
	sbc lastRegen0
	sta deltaReg0
	lda nowRegen1
	sbc lastRegen1
	sta deltaReg1
	lda nowRegen2
	sbc lastRegen2
	sta deltaReg2
	// If borrow occurred (C=0), it wrapped across midnight: add 24h (0x4F1A00 jiffies)
	bcs @ard_no_wrap
	clc
	lda deltaReg0
	adc #$00
	sta deltaReg0
	lda deltaReg1
	adc #$1A
	sta deltaReg1
	lda deltaReg2
	adc #$4F
	sta deltaReg2
@ard_no_wrap:
	// Compute how many full minutes (3600 jiffies = $000E10) have elapsed
	lda #0
	sta regenMinutes
	lda #0
	sta hpChangedFlag
@ard_min_check:
	// if delta >= $000E10, subtract once and increment minutes
	lda deltaReg2
	bne @ard_sub_minute       // any high byte implies >= 1 minute
	lda deltaReg1
	cmp #$0E
	bcc @ard_compute_heal
	beq @ard_check_low
	// deltaReg1 > $0E
	jmp @ard_sub_minute
@ard_check_low:
	lda deltaReg0
	cmp #$10
	bcc @ard_compute_heal
@ard_sub_minute:
	// delta -= $00 0E 10
	sec
	lda deltaReg0
	sbc #$10
	sta deltaReg0
	lda deltaReg1
	sbc #$0E
	sta deltaReg1
	lda deltaReg2
	sbc #$00
	sta deltaReg2
	inc regenMinutes
	jmp @ard_min_check

@ard_compute_heal:
	// Preserve total elapsed minutes
	lda regenMinutes
	sta regenTotal
	// Heal up to regenMinutes HP (capped at max)
	jsr computePlayerMaxHp
	lda playerCurHp
	cmp tmpHp
	beq @ard_advance_baseline // already full
	// While minutes > 0 and hp < max: hp++
    lda regenTotal
    sta healLeft
@ard_heal_loop:
	lda healLeft
	beq @ard_advance_baseline
	lda playerCurHp
	cmp tmpHp
	bcs @ard_advance_baseline
	inc playerCurHp
	lda #1
	sta hpChangedFlag
	dec healLeft
	jmp @ard_heal_loop

	// NPC healing: for each NPC, heal up to regenTotal (one HP per minute), capped at its max
	ldx #0
	lda regenTotal
	sta ZP_PTR2      // reuse ZP_PTR2 as global heal count template
@npc_heal_outer:
	lda ZP_PTR2
	beq @npc_heal_done
	// compute NPC max HP for index X
	jsr computeNpcMaxHp   // returns tmpHp
	lda npcCurHp,x
	cmp tmpHp
	beq @npc_heal_next
	// per-NPC heal loop
	lda ZP_PTR2
	sta healLeft
@npc_heal_inner:
	lda healLeft
	beq @npc_heal_next
	lda npcCurHp,x
	cmp tmpHp
	bcs @npc_heal_next
	inc npcCurHp,x
	lda #1
	sta hpChangedFlag
	dec healLeft
	jmp @npc_heal_inner

@npc_heal_next:
	inx
	cpx #NPC_COUNT
	bne @npc_heal_outer
@npc_heal_done:

@ard_advance_baseline:
	// Advance lastRegen by the total elapsed full minutes we computed
    // Add $000E10 per minute to lastRegen for all elapsed minutes
    lda regenTotal
    sta regenMinutes
@ard_adv_loop:
	lda regenMinutes
	beq @ard_maybe_save
	clc
	lda lastRegen0
	adc #$10
	sta lastRegen0
	lda lastRegen1
	adc #$0E
	sta lastRegen1
	lda lastRegen2
	adc #$00
	sta lastRegen2
	dec regenMinutes
	jmp @ard_adv_loop

@ard_maybe_save:
	lda hpChangedFlag
	beq @ard_done
	jsr saveGame
@ard_done:
	rts

renderQuestLine:
	// Ensure cursor is at the quest row, then clear the full line
	jsr setCursorQuest
	ldx #40          // 40 columns per row
@rql_clear_loop:
	lda #' '
	jsr CHROUT
	dex
	bne @rql_clear_loop
	// Return cursor to start of quest row for fresh rendering
	jsr setCursorQuest

	// Print "WEEK <n>  SCORE <n>  QUEST <name|NONE>"
	lda #<strWeek
	sta ZP_PTR
	lda #>strWeek
	sta ZP_PTR+1
	jsr printZ
	lda week
	jsr printDecimal
	lda #<strScore
	sta ZP_PTR
	lda #>strScore
	sta ZP_PTR+1
	jsr printZ
	lda scoreLo
	jsr printDecimal
	lda #<strQuest
	sta ZP_PTR
	lda #>strQuest
	sta ZP_PTR+1
	jsr printZ

	// Show quest status: NONE, a valid quest name, or a safe fallback.
	lda activeQuest
	cmp #QUEST_COUNT
	bcc @rql_check_none
	jmp @rql_none
@rql_check_none:
	cmp #QUEST_NONE
	beq @rql_none
	tax
	lda questNameLo,x
	sta ZP_PTR
	lda questNameHi,x
	sta ZP_PTR+1
	jsr printZ
	rts
@rql_none:
	lda #<strNone
	sta ZP_PTR
	lda #>strNone
	sta ZP_PTR+1
	jsr printZ
	rts

// Append A (0-255) as decimal to msgBuf
appendByteAsDec:
	pha
	// hundreds
	lda #0
	sta ZP_PTR2
	pla
@h:
	cmp #100
	bcc @tens
	sec
	sbc #100
	inc ZP_PTR2
	jmp @h
@tens:
	sta ZP_PTR2+1
	lda ZP_PTR2
	beq @skipH
	clc
	adc #'0'
	jsr appendCharA
@skipH:
	// tens
	lda #0
	sta ZP_PTR
	lda ZP_PTR2+1
@t:
	cmp #10
	bcc @ones
	sec
	sbc #10
	inc ZP_PTR
	jmp @t
@ones:
	sta ZP_PTR2+1
	lda ZP_PTR
	beq @maybeZero
	clc
	adc #'0'
	jsr appendCharA
	jmp @printOne
@maybeZero:
	// if we printed hundreds, we need a 0 tens
	lda ZP_PTR2
	beq @printOne
	lda #'0'
	jsr appendCharA
@printOne:
	lda ZP_PTR2+1
	clc
	adc #'0'
	jsr appendCharA
	rts

appendCharA:
	ldx msgBufLen
	cpx #255
	bcs @d
	sta msgBuf,x
	inx
	stx msgBufLen
@d:
	rts

// --- Quest system ---
ensureQuest:
	// ...existing code...
	rts
@set:
	sta activeQuest
	lda #1
	sta questStatus
	rts

assignQuest_mod:
	// A = desired quest id (may be out of range); reduce modulo QUEST_COUNT
	// Use simple subtraction loop
@aqm_loop:
	cmp #QUEST_COUNT
	bcc @aqm_set
	sec
	sbc #QUEST_COUNT
	jmp @aqm_loop
@aqm_set:
	sta activeQuest
	lda #1
	sta questStatus
	rts

questComplete:
	lda questStatus
	cmp #2
	bne @qc_qc_continue
	jmp @qc_done
@qc_qc_continue:
	lda #2
	sta questStatus
	inc scoreLo
	lda scoreLo
	bne @qc_level_check
	inc scoreHi

@qc_level_check:
	// Update level if score increased above currentLevel
	lda scoreLo
	cmp currentLevel
	beq @qc_msg
	bcc @qc_msg
	sta currentLevel

@qc_msg:
	lda #<msgQuestDone
	sta lastMsgLo
	lda #>msgQuestDone
	sta lastMsgHi
	jsr saveGame

	// Log quest completion to EVLOG (device 8)
	jsr log_quest_complete

	// Grant quest-specific rewards via table-dispatch (indexed by quest id)
	lda activeQuest
	tay
	lda questRewardLo,y
	sta ZP_PTR
	lda questRewardHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@qc_reward_bartender:
	// Give player the mug (OBJ_MUG)
	lda #OBJ_MUG
	tax
	lda #OBJ_INVENTORY
	sta objLoc,x
	// Optionally set a message (keep quest done message)
	jmp @qc_done_after

@qc_reward_treasure:
	// Treasure quest: give a larger score reward (+5)
	lda scoreLo
	clc
	adc #5
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	jmp @qc_done_after

@qc_reward_lure:
	// Lure quest: modest reputation reward (+3)
	lda scoreLo
	clc
	adc #3
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	jmp @qc_done_after

// Reward dispatch table (low/high pointers) - indexed by quest id
questRewardLo:
	.byte <@qc_reward_bartender, <@qc_done_after, <@qc_done_after, <@qc_reward_treasure, <@qc_reward_lure, <@qc_done_after, <@qc_reward_unseely, <@qc_reward_apollonia, <@qc_done_after, <@qc_done_after, <@qc_reward_kendrick, <@qc_reward_warlock, <@qc_reward_candywitch, <@qc_reward_kora, <@qc_done_after, <@qc_reward_warlock
questRewardHi:
	.byte >@qc_reward_bartender, >@qc_done_after, >@qc_done_after, >@qc_reward_treasure, >@qc_reward_lure, >@qc_done_after, >@qc_reward_unseely, >@qc_reward_apollonia, >@qc_done_after, >@qc_done_after, >@qc_reward_kendrick, >@qc_reward_warlock, >@qc_reward_candywitch, >@qc_reward_kora, >@qc_done_after, >@qc_reward_warlock

@qc_reward_unseely:
	// Reward for retrieving the stolen name: +4 score and progress Unseely Fae
	lda scoreLo
	clc
	adc #4
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	// set Unseely Fae conversation stage progressed
	lda #NPC_UNSEELY_FAE
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	jmp @qc_done_after

@qc_reward_apollonia:
	// Apollonia offering: healing touch + gentle blessing (+2 score)
	jsr computePlayerMaxHp
	lda tmpHp
	sta playerCurHp
	lda scoreLo
	clc
	adc #2
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	jmp @qc_done_after

@qc_reward_kendrick:
	// Kendrick quest reward: +2 score and a mug souvenir
	lda scoreLo
	clc
	adc #2
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	// give player a mug (OBJ_MUG)
	lda #OBJ_MUG
	tax
	lda #OBJ_INVENTORY
	sta objLoc,x
	// mark Kendrick's conv stage progressed
	lda #NPC_KENDRICK
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	jmp @qc_done_after

@qc_reward_warlock:
	// Warlock ward quest reward: +3 score
	lda scoreLo
	clc
	adc #3
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	jmp @qc_done_after

@qc_reward_candywitch:
	// Candy Witch quest reward: +2 score, and a sly grin
	lda scoreLo
	clc
	adc #2
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	jmp @qc_done_after

@qc_reward_kora:
	// Kora jape quest: +2 score for clever wordplay
	lda scoreLo
	clc
	adc #2
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	jmp @qc_done_after

@qc_done_after:

@qc_done:
	rts

advanceWeek:
	inc week
	lda week
	cmp #53
	bcc @aw_ok
	lda #1
	sta week

@aw_ok:
	// Some quests can persist// MVP: rotate if completed, else keep
	lda questStatus
	cmp #2
	bne @keep
	lda #QUEST_NONE
	sta activeQuest
	lda #0
	sta questStatus
	jsr ensureQuest
@keep:
	lda #<msgWeekAdvanced
	sta lastMsgLo
	lda #>msgWeekAdvanced
	sta lastMsgHi
	jsr saveGame
	rts

// --- Music engine (SID, raster IRQ) ---
musicInit:
	// Install our IRQ hook only once// we chain to the original KERNAL IRQ.
	lda musicInstalled
	bne @mi_installed
	sei
	// Save old IRQ vector
	lda IRQ_VEC_LO
	sta irqOldLo
	lda IRQ_VEC_HI
	sta irqOldHi
	// Install our IRQ
	lda #<musicIrq
	sta IRQ_VEC_LO
	lda #>musicIrq
	sta IRQ_VEC_HI
	lda #1
	sta musicInstalled
	cli

@mi_installed:
	// Enable raster IRQ
	lda VIC_CTRL1
	and #%01111111
	sta VIC_CTRL1
	lda #$32
	sta VIC_RASTER
	lda #%00000001
	sta VIC_IRQMASK
	// Clear pending
	lda #%00000001
	sta VIC_IRQFLAG
	// SID init: low volume, triangle voices, gentle ADSR
	lda #$0F
	sta SID_MODE_VOL
	lda #$08
	sta SID_V1_AD
	lda #$A8
	sta SID_V1_SR
	lda #$08
	sta SID_V2_AD
	lda #$A8
	sta SID_V2_SR
	// Sparkle voice (pulse, short ADSR)
	lda #$00
	sta SID_V3_PWLO
	lda #$08
	sta SID_V3_PWHI
	lda #$02
	sta SID_V3_AD
	lda #$78
	sta SID_V3_SR
	lda #0
	sta SID_V1_CTRL
	sta SID_V2_CTRL
	sta SID_V3_CTRL
	rts

// Pick music theme based on season and scary locations.
musicPickForLocation:
	// Special rule: CLOCKWORK ALLEY uses pirate music, except during LORE season (scary).
	lda currentLoc
	cmp #LOC_ALLEY
	bne @overrides
	jsr getSeason
	cmp #SEASON_LORE
	bne @pirate
	lda #4
	sta musicTheme
	jmp @pick
@pirate:
	lda #9
	sta musicTheme
	jmp @pick

	// Indoor/location overrides ("enter" music): $FF = none
@overrides:
	// Indoor/location overrides ("enter" music): $FF = none
	ldx currentLoc
	lda locMusicOverride,x
	cmp #$FF
	beq @scary
	sta musicTheme
	jmp @pick
@scary:
	// Determine if scary
	ldx currentLoc
	lda locScary,x
	beq @season
	lda #4
	sta musicTheme
	jmp @pick
@season:
	jsr getSeason
	sta musicTheme
@pick:
	jsr musicApplyThemeSettings
	jsr musicAllNotesOff
	jsr musicPickRandomPattern
	jsr musicRestart
	rts

musicApplyThemeSettings:
	ldx musicTheme
	lda themeLeadLen,x
	sta musicStepLen
	lda themeBassLen,x
	sta musicBassLen
	lda themeSparkLen,x
	sta musicSparkLen
	lda themeLeadWave,x
	sta leadWave
	lda themeBassWave,x
	sta bassWave
	lda themeSparkWave,x
	sta sparkWave
	// Per-theme envelopes (SR only// AD set once in init)
	lda themeV1SR,x
	sta SID_V1_SR
	lda themeV2SR,x
	sta SID_V2_SR
	lda themeV3SR,x
	sta SID_V3_SR
	rts

musicAllNotesOff:
	// Gate off + clear frequencies so theme switches don't overlap.
	lda leadWave
	sta SID_V1_CTRL
	lda #0
	sta SID_V1_FREQLO
	sta SID_V1_FREQHI
	lda bassWave
	sta SID_V2_CTRL
	lda #0
	sta SID_V2_FREQLO
	sta SID_V2_FREQHI
	lda sparkWave
	sta SID_V3_CTRL
	lda #0
	sta SID_V3_FREQLO
	sta SID_V3_FREQHI
	rts

musicPickRandomPattern:
	// Choose 0..2
	lda $D012
	eor $DC04
	and #$03
	cmp #3
	bne @mpr_ok
	lda #2

@mpr_ok:
	sta musicPattern
	rts

musicRestart:
	lda #0
	sta musicStep
	lda musicStepLen
	sta musicTick
	lda #0
	sta musicBassStep
	lda musicBassLen
	sta musicBassTick
	lda #0
	sta musicSparkStep
	lda musicSparkLen
	sta musicSparkTick
	rts

musicIrq:
	pha
	txa
	pha
	tya
	pha
	// Preserve shared zero-page pointers (mainline + KERNAL use these heavily)
	lda ZP_PTR
	pha
	lda ZP_PTR+1
	pha
	lda ZP_PTR2
	pha
	lda ZP_PTR2+1
	pha
	// Acknowledge raster IRQ
	lda #%00000001
	sta VIC_IRQFLAG
	lda musicEnabled
	beq @mi_done
	jsr musicTickRoutine

@mi_done:
	pla
	sta ZP_PTR2+1
	pla
	sta ZP_PTR2
	pla
	sta ZP_PTR+1
	pla
	sta ZP_PTR
	pla
	tay
	pla
	tax
	pla
	jmp (irqOldLo)

musicTickRoutine:
	// Lead voice update
	dec musicTick
	bne @mt_bass
	lda musicStepLen
	sta musicTick
	jsr musicAdvanceLead

@mt_bass:
	dec musicBassTick
	bne @mt_spark
	lda musicBassLen
	sta musicBassTick
	jsr musicAdvanceBass


@mt_spark:
	dec musicSparkTick
	bne @mt_done
	lda musicSparkLen
	sta musicSparkTick
	jsr musicAdvanceSparkle

@mt_done:
	rts

musicAdvanceLead:
	ldx musicTheme
	lda themeLeadNotesLo,x
	sta ZP_PTR
	lda themeLeadNotesHi,x
	sta ZP_PTR+1

	// ZP_PTR points to table of 3 pattern pointers (lo/hi pairs)
	lda musicPattern
	asl
	tay
	lda (ZP_PTR),y
	sta ZP_PTR2
	iny
	lda (ZP_PTR),y
	sta ZP_PTR2+1

	ldx musicStep
	lda (ZP_PTR2),x
	beq @mal_rest
	tay
	dey
	lda noteFreqLo,y
	sta SID_V1_FREQLO
	lda noteFreqHi,y
	sta SID_V1_FREQHI
	lda leadWave
	ora #$01
	sta SID_V1_CTRL
	jmp @mal_next

@mal_rest:
	lda leadWave
	sta SID_V1_CTRL

@mal_next:
	inc musicStep
	lda musicStep
	cmp #16
	bcc @mal_rts
	lda #0
	sta musicStep
	// At end of pattern, pick another from same theme
	jsr musicPickRandomPattern
	// Keep bass/sparkle aligned with the new pattern.
	lda #0
	sta musicBassStep
	sta musicSparkStep
	lda musicBassLen
	sta musicBassTick
	lda musicSparkLen
	sta musicSparkTick

@mal_rts:
	rts

musicAdvanceBass:
	ldx musicTheme
	lda themeBassNotesLo,x
	sta ZP_PTR
	lda themeBassNotesHi,x
	sta ZP_PTR+1
	lda musicPattern
	asl
	tay
	lda (ZP_PTR),y
	sta ZP_PTR2
	iny
	lda (ZP_PTR),y
	sta ZP_PTR2+1
	ldx musicBassStep
	lda (ZP_PTR2),x
	beq @mab_rest
	tay
	dey
	lda noteFreqLo,y
	sta SID_V2_FREQLO
	lda noteFreqHi,y
	sta SID_V2_FREQHI
	lda bassWave
	ora #$01
	sta SID_V2_CTRL
	jmp @mab_next

@mab_rest:
	lda bassWave
	sta SID_V2_CTRL

@mab_next:
	inc musicBassStep
	lda musicBassStep
	cmp #16
	bcc @mab_rts
	lda #0
	sta musicBassStep

@mab_rts:
	rts

musicAdvanceSparkle:
	// Only active for Aurora (3) and Tavern (5)// otherwise gate off.
	lda musicTheme
	cmp #3
	beq @mas_do
	cmp #5
	beq @mas_do
	cmp #8
	beq @mas_do
	lda sparkWave
	sta SID_V3_CTRL
	rts

@mas_do:
	ldx musicTheme
	lda themeSparkNotesLo,x
	sta ZP_PTR
	lda themeSparkNotesHi,x
	sta ZP_PTR+1
	lda musicPattern
	asl
	tay
	lda (ZP_PTR),y
	sta ZP_PTR2
	iny
	lda (ZP_PTR),y
	sta ZP_PTR2+1
	ldx musicSparkStep
	lda (ZP_PTR2),x
	beq @mas_rest
	tay
	dey
	lda noteFreqLo,y
	sta SID_V3_FREQLO
	lda noteFreqHi,y
	sta SID_V3_FREQHI
	lda sparkWave
	ora #$01
	sta SID_V3_CTRL
	jmp @mas_next

@mas_rest:
	lda sparkWave
	sta SID_V3_CTRL

@mas_next:
	inc musicSparkStep
	lda musicSparkStep
	cmp #16
	bcc @mas_rts
	lda #0
	sta musicSparkStep

@mas_rts:
	rts

// Scary locations (spooky music)
locScary:
	// TRAIN, MARKET, PORTAL, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	// Extra (non-map) locations reuse nearby marker positions.
	.byte 0,0,0,1,0,0,1,0,0,1,1,0,0

// Indoor/location music override ($FF = none). Theme ids match musicTheme.
locMusicOverride:
	// TRAIN, MARKET, PORTAL, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,8,5,$FF,$FF,6,7

// Notes table (indices used in sequences):
// 1=C4 2=D4 3=E4 4=F4 5=G4 6=A4 7=B4 8=C5 9=D5 10=E5 11=G5 12=A5
noteFreqLo:
	.byte $67,$89,$ED,$3B,$13,$45,$DA,$CE,$11,$DA,$26,$89
noteFreqHi:
	.byte $11,$13,$15,$17,$1A,$1D,$20,$22,$27,$2B,$34,$3A

// --- Music patterns (16 steps each// 0=rest// note index 1..12) ---
// MYTHOS (soft, major, medieval slow)
myLead0: .byte 1,0,3,0,5,0,8,0,6,0,5,0,3,0,1,0
myLead1: .byte 3,0,5,0,8,0,10,0,8,0,6,0,5,0,3,0
myLead2: .byte 5,0,6,0,8,0,10,0,11,0,10,0,8,0,6,0
myBass0: .byte 1,0,0,0,5,0,0,0,6,0,0,0,5,0,0,0
myBass1: .byte 1,0,0,0,6,0,0,0,5,0,0,0,3,0,0,0
myBass2: .byte 5,0,0,0,6,0,0,0,8,0,0,0,6,0,0,0

// LORE (minor-ish, slower feel, atmospheric)
loLead0: .byte 6,0,5,0,3,0,2,0,3,0,5,0,6,0,5,0
loLead1: .byte 5,0,3,0,2,0,1,0,2,0,3,0,5,0,6,0
loLead2: .byte 6,0,8,0,7,0,6,0,5,0,3,0,2,0,1,0
loBass0: .byte 6,0,0,0,5,0,0,0,3,0,0,0,2,0,0,0
loBass1: .byte 5,0,0,0,3,0,0,0,2,0,0,0,1,0,0,0
loBass2: .byte 6,0,0,0,7,0,0,0,5,0,0,0,3,0,0,0

// AURORA (sparkly, higher notes, ethereal)
auLead0: .byte 8,0,0,0,10,0,0,0,11,0,0,0,12,0,0,0
auLead1: .byte 10,0,0,0,11,0,0,0,12,0,0,0,11,0,0,0
auLead2: .byte 8,0,0,0,9,0,0,0,10,0,0,0,11,0,0,0
auBass0: .byte 1,0,0,0,5,0,0,0,8,0,0,0,5,0,0,0
auBass1: .byte 3,0,0,0,6,0,0,0,10,0,0,0,6,0,0,0
auBass2: .byte 1,0,0,0,6,0,0,0,8,0,0,0,6,0,0,0

auSpk0:  .byte 12,0,11,0,10,0,11,0,12,0,11,0,10,0,11,0
auSpk1:  .byte 11,0,12,0,11,0,10,0,11,0,10,0,9,0,10,0
auSpk2:  .byte 10,0,11,0,12,0,0,0,11,0,10,0,9,0,8,0

// OFF SEASON (simple, airy, minimal)
ofLead0: .byte 1,0,0,0,2,0,0,0,3,0,0,0,2,0,0,0
ofLead1: .byte 3,0,0,0,2,0,0,0,1,0,0,0,0,0,0,0
ofLead2: .byte 2,0,0,0,1,0,0,0,2,0,0,0,3,0,0,0
ofBass0: .byte 1,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0
ofBass1: .byte 3,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0
ofBass2: .byte 5,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0

// SCARY (dissonant steps, sparse, eerie)
scLead0: .byte 7,0,0,0,4,0,0,0,7,0,0,0,4,0,0,0
scLead1: .byte 4,0,0,0,7,0,0,0,4,0,0,0,7,0,0,0
scLead2: .byte 7,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0
scBass0: .byte 1,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0
scBass1: .byte 2,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
scBass2: .byte 1,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0

// TAVERN (indoor, cozy, warm)
tvLead0: .byte 5,0,6,0,5,0,3,0,2,0,3,0,5,0,6,0
tvLead1: .byte 6,0,8,0,6,0,5,0,3,0,5,0,6,0,8,0
tvLead2: .byte 3,0,5,0,6,0,5,0,3,0,2,0,1,0,2,0
tvBass0: .byte 1,0,0,0,3,0,0,0,5,0,0,0,6,0,0,0
tvBass1: .byte 3,0,0,0,5,0,0,0,6,0,0,0,8,0,0,0
tvBass2: .byte 5,0,0,0,6,0,0,0,8,0,0,0,10,0,0,0

tvSpk0:  .byte 8,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0
tvSpk1:  .byte 10,0,0,0,0,0,0,0,11,0,0,0,0,0,0,0
tvSpk2:  .byte 11,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0

// INN (warm, restful, soothing)
inLead0: .byte 3,0,0,0,5,0,0,0,6,0,0,0,5,0,0,0
inLead1: .byte 5,0,0,0,6,0,0,0,8,0,0,0,6,0,0,0
inLead2: .byte 6,0,0,0,5,0,0,0,3,0,0,0,2,0,0,0
inBass0: .byte 1,0,0,0,3,0,0,0,5,0,0,0,3,0,0,0
inBass1: .byte 3,0,0,0,5,0,0,0,6,0,0,0,5,0,0,0
inBass2: .byte 5,0,0,0,3,0,0,0,2,0,0,0,1,0,0,0

// TEMPLE (martial, grand)
tpLead0: .byte 1,0,0,0,3,0,0,0,5,0,0,0,6,0,0,0
tpLead1: .byte 3,0,0,0,5,0,0,0,6,0,0,0,8,0,0,0
tpLead2: .byte 5,0,0,0,6,0,0,0,5,0,0,0,3,0,0,0
tpBass0: .byte 1,0,0,0,1,0,0,0,1,0,0,0,3,0,0,0
tpBass1: .byte 3,0,0,0,3,0,0,0,5,0,0,0,5,0,0,0
tpBass2: .byte 5,0,0,0,5,0,0,0,6,0,0,0,6,0,0,0

// FAIRY (light, sparkly, magical)
faLead0: .byte 8,0,10,0,12,0,11,0,10,0,9,0,8,0,9,0
faLead1: .byte 10,0,11,0,12,0,0,0,11,0,10,0,9,0,8,0
faLead2: .byte 8,0,9,0,10,0,11,0,12,0,11,0,10,0,9,0
faBass0: .byte 1,0,0,0,5,0,0,0,6,0,0,0,5,0,0,0
faBass1: .byte 3,0,0,0,6,0,0,0,5,0,0,0,3,0,0,0
faBass2: .byte 1,0,0,0,6,0,0,0,5,0,0,0,3,0,0,0

faSpk0:  .byte 12,0,0,0,0,0,11,0,0,0,0,0,12,0,0,0
faSpk1:  .byte 11,0,0,0,0,0,12,0,0,0,0,0,11,0,0,0
faSpk2:  .byte 10,0,0,0,0,0,11,0,0,0,0,0,12,0,0,0

// PIRATE (jaunty, sea shanty)
piLead0: .byte 5,0,5,0,6,0,5,0,3,0,2,0,3,0,5,0
piLead1: .byte 6,0,6,0,8,0,6,0,5,0,3,0,5,0,6,0
piLead2: .byte 8,0,8,0,6,0,5,0,3,0,2,0,1,0,2,0
piBass0: .byte 1,0,0,0,5,0,0,0,1,0,0,0,6,0,0,0
piBass1: .byte 3,0,0,0,6,0,0,0,3,0,0,0,5,0,0,0
piBass2: .byte 5,0,0,0,8,0,0,0,5,0,0,0,6,0,0,0

// INN sparkle ornaments (soft trills)
inSpk0: .byte 0,0,9,0,0,0,10,0,0,0,9,0,0,0,10,0
inSpk1: .byte 9,0,0,0,10,0,0,0,9,0,0,0,10,0,0,0
inSpk2: .byte 0,0,10,0,0,0,9,0,0,0,10,0,0,0,9,0

// Theme pointer tables: each theme entry points to 3 patterns
myLeadPtr: .word myLead0,myLead1,myLead2
loLeadPtr: .word loLead0,loLead1,loLead2
auLeadPtr: .word auLead0,auLead1,auLead2
ofLeadPtr: .word ofLead0,ofLead1,ofLead2
scLeadPtr: .word scLead0,scLead1,scLead2
tvLeadPtr: .word tvLead0,tvLead1,tvLead2
inLeadPtr: .word inLead0,inLead1,inLead2
tpLeadPtr: .word tpLead0,tpLead1,tpLead2
faLeadPtr: .word faLead0,faLead1,faLead2
piLeadPtr: .word piLead0,piLead1,piLead2

myBassPtr: .word myBass0,myBass1,myBass2
loBassPtr: .word loBass0,loBass1,loBass2
auBassPtr: .word auBass0,auBass1,auBass2
ofBassPtr: .word ofBass0,ofBass1,ofBass2
scBassPtr: .word scBass0,scBass1,scBass2
tvBassPtr: .word tvBass0,tvBass1,tvBass2
inBassPtr: .word inBass0,inBass1,inBass2
tpBassPtr: .word tpBass0,tpBass1,tpBass2
faBassPtr: .word faBass0,faBass1,faBass2
piBassPtr: .word piBass0,piBass1,piBass2

auSpkPtr:  .word auSpk0,auSpk1,auSpk2
tvSpkPtr:  .word tvSpk0,tvSpk1,tvSpk2
faSpkPtr:  .word faSpk0,faSpk1,faSpk2
inSpkPtr: .word inSpk0,inSpk1,inSpk2

// Dummy sparkle (all rests) for themes that don't use it
noSpk0: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
noSpkPtr: .word noSpk0,noSpk0,noSpk0

// Tables indexed by musicTheme (0..9) of pointers to pointer-tables above
themeLeadNotesLo:
	.byte <ofLeadPtr,<myLeadPtr,<loLeadPtr,<auLeadPtr,<scLeadPtr,<tvLeadPtr,<inLeadPtr,<tpLeadPtr,<faLeadPtr,<piLeadPtr
themeLeadNotesHi:
	.byte >ofLeadPtr,>myLeadPtr,>loLeadPtr,>auLeadPtr,>scLeadPtr,>tvLeadPtr,>inLeadPtr,>tpLeadPtr,>faLeadPtr,>piLeadPtr

themeBassNotesLo:
	.byte <ofBassPtr,<myBassPtr,<loBassPtr,<auBassPtr,<scBassPtr,<tvBassPtr,<inBassPtr,<tpBassPtr,<faBassPtr,<piBassPtr
themeBassNotesHi:
	.byte >ofBassPtr,>myBassPtr,>loBassPtr,>auBassPtr,>scBassPtr,>tvBassPtr,>inBassPtr,>tpBassPtr,>faBassPtr,>piBassPtr

themeSparkNotesLo:
    	.byte <noSpkPtr,<noSpkPtr,<noSpkPtr,<auSpkPtr,<noSpkPtr,<tvSpkPtr,<inSpkPtr,<noSpkPtr,<faSpkPtr,<noSpkPtr
themeSparkNotesHi:
    	.byte >noSpkPtr,>noSpkPtr,>noSpkPtr,>auSpkPtr,>noSpkPtr,>tvSpkPtr,>inSpkPtr,>noSpkPtr,>faSpkPtr,>noSpkPtr

// Theme settings (tempo + timbre). 10 entries, indexed by musicTheme.
// Smaller = faster (ticks per step). Values tuned for atmosphere.
themeLeadLen:  .byte 9,16,18,12,20,14,16,12,10,12
themeBassLen:  .byte 18,32,36,24,40,28,32,24,20,24
themeSparkLen: .byte 6, 8, 8, 6, 10,6, 8, 8, 6, 8

// Waveform bits only (gate bit added dynamically): TRI=$10 SAW=$20 PULSE=$40 NOISE=$80
themeLeadWave: .byte $10,$10,$20,$10,$20,$10,$10,$40,$10,$40
themeBassWave: .byte $10,$10,$10,$10,$10,$10,$10,$10,$10,$10
themeSparkWave:.byte $40,$40,$40,$40,$80,$40,$40,$40,$40,$40

// Release-heavy for scary// otherwise smooth.
themeV1SR: .byte $C8,$C8,$D8,$C8,$46,$C8,$C8,$A8,$98,$C8
themeV2SR: .byte $C8,$C8,$C8,$C8,$46,$C8,$C8,$C8,$98,$C8
themeV3SR: .byte $88,$98,$98,$98,$28,$98,$88,$88,$98,$88

init:
	// Start music early so the login screen has its own theme.
	lda #1
	sta musicEnabled
	jsr musicInit
	jsr musicStartLoginTheme

	// Ensure debug mode is disabled for normal operation
	lda #0
	sta debugEnabled
	lda #1
	sta uiHideExits
	jsr loginOrCreate
@init_skip_login:
	lda #0
	sta uiHideExits
	jsr initRegenTimer
	jsr musicPickForLocation
	jsr ensureQuest
	rts

musicStartLoginTheme:
	// Happy welcome theme (fairy).
	lda #8
	sta musicTheme
	jsr musicApplyThemeSettings
	jsr musicAllNotesOff
	jsr musicPickRandomPattern
	jsr musicRestart
	rts

// --- Rendering ---
render:
	jsr clearScreen
	// During login/account creation, keep the screen minimal.
	lda uiHideExits
	beq render_game
	// Auth mode: just the active auth message + prompt.
	clc
	ldx #ROW_AUTH_MSG
	ldy #0
	jsr PLOT
	lda lastMsgLo
	sta ZP_PTR
	lda lastMsgHi
	sta ZP_PTR+1
	jsr printZ
    
	clc
	ldx #ROW_AUTH_PROMPT
	ldy #0
	jsr PLOT
	lda #<strPrompt
	sta ZP_PTR
	lda #>strPrompt
	sta ZP_PTR+1
	jsr printZ
	rts

render_game:
	lda uiInConversation
	cmp #0
	bne @render_skip_map
	jsr drawMap
@render_skip_map:

	// UI title line
	jsr setCursorUi
	ldx currentLoc
	lda locNameLo,x
	sta ZP_PTR
	lda locNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Description (hand-wrapped// limited to description area)
	jsr setCursorDesc
	ldx currentLoc
	lda locDescLo,x
	sta ZP_PTR
	lda locDescHi,x
	sta ZP_PTR+1
	jsr printZ

	// Season + week/score/quest are printed at fixed rows so wrapping above can’t collide.
	jsr setCursorSeason
	jsr renderSeasonLine
	jsr setCursorQuest
	jsr renderQuestLine

	// Exits (hidden during login/account creation)
	lda uiHideExits
	bne @render_skipExits
	ldx #0
	jsr setCursorExits
	// Clear the entire exits row to avoid leftover characters.
	ldx #40
	lda #' '
@rge_clear_exits:
	jsr CHROUT
	dex
	bne @rge_clear_exits
	// Reset cursor and print exits label + directions.
	jsr setCursorExits
	lda #<strExits
	sta ZP_PTR
	lda #>strExits
	sta ZP_PTR+1
	jsr printZ
	jsr printExits

@render_skipExits:

	// Last message
	jsr setCursorMsg
	// Force a known-good default message here so the line under the map is always readable.
	lda activeQuest
	cmp #QUEST_NONE
	beq @rg_show_welcome
	cmp #QUEST_COUNT
	bcs @rg_show_welcome
	// Show quest detail for active quest
	tax
	lda questDetailLo,x
	sta ZP_PTR
	lda questDetailHi,x
	sta ZP_PTR+1
	jsr printZ40
	jmp @rg_after_msg
@rg_show_welcome:
	lda #<msgWelcome
	sta ZP_PTR
	lda #>msgWelcome
	sta ZP_PTR+1
	jsr printZ
@rg_after_msg:


	// Help (two fixed-width lines)
	// Clear the entire help row before printing
	jsr setCursorHelp
	ldx #40
	lda #' '
@rg_help_clear:
	jsr CHROUT
	dex
	bne @rg_help_clear
	jsr setCursorHelp
	lda #<strHelp2
	sta ZP_PTR
	lda #>strHelp2
	sta ZP_PTR+1
	jsr printZ

	// Prompt
	// Clear the entire prompt row before printing
	jsr setCursorPrompt
	ldx #40
	lda #' '
@rg_prompt_clear:
	jsr CHROUT
	dex
	bne @rg_prompt_clear
	jsr setCursorPrompt
	lda #<strPrompt
	sta ZP_PTR
	lda #>strPrompt
	sta ZP_PTR+1
	jsr printZ
	rts

clearScreen:
	// CHROUT $93 = CLR/HOME
	lda #$93
	jsr CHROUT
	rts

	// Render a context tag line under the auth message indicating the active prompt
	renderAuthTag:
		// Position at ROW_AUTH_MSG+1
		clc
		ldx #ROW_AUTH_MSG+1
		ldy #0
		jsr PLOT
		// Compare lastMsg to known auth prompts
		lda lastMsgLo
		cmp #<msgAskUser
		bne @rat_disp
		lda lastMsgHi
		cmp #>msgAskUser
		bne @rat_disp
		lda #<msgTagUser
		sta ZP_PTR
		lda #>msgTagUser
		sta ZP_PTR+1
		jmp @rat_print
	@rat_disp:
		lda lastMsgLo
		cmp #<msgAskDisplay
		bne @rat_class
		lda lastMsgHi
		cmp #>msgAskDisplay
		bne @rat_class
		lda #<msgTagDisplay
		sta ZP_PTR
		lda #>msgTagDisplay
		sta ZP_PTR+1
		jmp @rat_print
	@rat_class:
		lda lastMsgLo
		cmp #<msgAskClass
		bne @rat_pin
		lda lastMsgHi
		cmp #>msgAskClass
		bne @rat_pin
		lda #<msgTagClass
		sta ZP_PTR
		lda #>msgTagClass
		sta ZP_PTR+1
		jmp @rat_print
	@rat_pin:
		lda lastMsgLo
		cmp #<msgAskPin
		beq @rat_pin_set
		cmp #<msgAskPinLogin
		bne @rat_month
	@rat_pin_set:
		lda #<msgTagPin
		sta ZP_PTR
		lda #>msgTagPin
		sta ZP_PTR+1
		jmp @rat_print
	@rat_month:
		lda lastMsgLo
		cmp #<msgAskMonth
		bne @rat_week
		lda lastMsgHi
		cmp #>msgAskMonth
		bne @rat_week
		lda #<msgTagMonth
		sta ZP_PTR
		lda #>msgTagMonth
		sta ZP_PTR+1
		jmp @rat_print
	@rat_week:
		lda lastMsgLo
		cmp #<msgAskWeek
		bne @rat_rts
		lda lastMsgHi
		cmp #>msgAskWeek
		bne @rat_rts
		lda #<msgTagWeek
		sta ZP_PTR
		lda #>msgTagWeek
		sta ZP_PTR+1
		jmp @rat_print
	@rat_print:
		jsr printZ
	@rat_rts:
		rts

drawMap:
	// Skip drawing the map while in a conversation (extra safety)
	lda uiInConversation
	cmp #0
	bne drawMap_skip
	// Print static 12-line map
	ldx #0
	@lineLoop:
	lda mapLineLo,x
	sta ZP_PTR
	lda mapLineHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	inx
	cpx #12
	bne @lineLoop

	// Divider line
	lda #<strDivider
	sta ZP_PTR
	lda #>strDivider
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr placeMarker
	drawMap_skip:
	rts

placeMarker:
	ldx currentLoc
	lda locMarkX,x
	sta ZP_PTR
	lda locMarkY,x
	sta ZP_PTR+1

	// Set cursor (PLOT): X=row, Y=col
	clc
	ldx ZP_PTR+1
	ldy ZP_PTR
	jsr PLOT
	// Reverse-video 'X' so the cell background is the current color.
	// Light green = $99, reverse on = $12, reverse off = $92
	lda #$12
	jsr CHROUT
	lda #$99
	jsr CHROUT
	lda #'X'
	jsr CHROUT
	lda #$92
	jsr CHROUT
	// Restore normal text color (white)
	lda #$05
	jsr CHROUT
	rts

// Cursor helpers
setCursorUi:
	clc
	ldx #ROW_UI_START
	ldy #0
	jsr PLOT
	rts

setCursorDesc:
	clc
	ldx #ROW_DESC
	ldy #0
	jsr PLOT
	rts

setCursorSeason:
	clc
	ldx #ROW_SEASON
	ldy #0
	jsr PLOT
	rts

setCursorExits:
	clc
	ldx #ROW_EXITS
	ldy #0
	jsr PLOT
	rts

setCursorQuest:
	clc
	ldx #ROW_QUEST
	ldy #0
	jsr PLOT
	rts

setCursorMsg:
	clc
	ldx #ROW_MSG
	ldy #0
	jsr PLOT
	rts

setCursorHelp:
	clc
	ldx #ROW_HELP
	ldy #0
	jsr PLOT
	rts

setCursorPrompt:
	clc
	ldx #ROW_PROMPT
	ldy #0
	jsr PLOT
	rts

newline:
	lda #$0D
	jsr CHROUT
	rts

printZ:
	// Print 0-terminated string at (ZP_PTR)
	ldy #0

@pz_loop:
	lda (ZP_PTR),y
	beq @pz_done
	jsr CHROUT
	iny
	bne @pz_loop

@pz_done:
	rts

// Print up to 40 chars from 0-terminated string at (ZP_PTR)
printZ40:
	ldy #0
@pz40_loop:
	lda (ZP_PTR),y
	beq @pz40_done
	jsr CHROUT
	iny
	cpy #40
	bne @pz40_loop
@pz40_done:
	rts

printChar:
	jsr CHROUT
	rts

// Print NPC entry for current X index; expects X=index, uses selCount to number entries
printNpcEntry:
	// Prefer given name if present
	lda npcGivenNamePtrLo,x
	sta ZP_PTR
	lda npcGivenNamePtrHi,x
	sta ZP_PTR+1
	ldy #0
	lda (ZP_PTR),y
	beq @pne_use_title
	// given name present — print numbered entry
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jsr printZ
	jsr newline
	inc selCount
// Print NPC display name for NPC index in X.
// If a given name is present, prints: GIVEN (TITLE)
// Otherwise prints just the TITLE.
printNpcDisplayName:
	// Check first character of given name
	lda npcGivenNamePtrLo,x
	sta ZP_PTR
	lda npcGivenNamePtrHi,x
	sta ZP_PTR+1
	ldy #0
	lda (ZP_PTR),y
	beq @pnd_no_given
	// Given name present: print given, then space + '(' + title + ')'
	jsr printZ
	lda #' '
	jsr CHROUT
	lda #'('
	jsr CHROUT
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	lda #')'
	jsr CHROUT
	rts

@pnd_no_given:
	// No given name: fall back to title only
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	rts

	rts

@pne_use_title:
	// No given name: print numbered entry using title only
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	inc selCount
	rts
@pne_skip:
	rts

// conv_apply_effect: expects A = effectType (at call), effect value saved at tmpPer+1
// effectType: 0=none,1=startQuest,2=completeQuest,3=giveItem,4=takeItem,5=addScore,6=setNpcStage
conv_apply_effect:
	// effect type already in A
	cmp #1
	beq conv_apply_startquest
	cmp #2
	beq conv_apply_completequest
	cmp #3
	beq conv_apply_give_item
	cmp #4
	beq conv_apply_take_item
	cmp #5
	beq conv_apply_add_score
	cmp #6
	beq conv_apply_set_npcstage
	rts

conv_apply_startquest:
	// load effect value
	lda tmpPer+1
	jsr assignQuest_mod  // expects A = quest id (mod will clamp)
	rts

conv_apply_completequest:
	lda tmpPer+1
	sta activeQuest
	jsr questComplete
	rts

conv_apply_give_item:
	// tmpPer+1 = item id -> give to player (put in inventory)
	lda tmpPer+1
	tax
	lda #OBJ_INVENTORY
	sta objLoc,x
	jsr log_give_item
	lda #<msgTook
	sta lastMsgLo
	lda #>msgTook
	sta lastMsgHi
	jsr saveGame
	rts

conv_apply_take_item:
	// tmpPer+1 = item id -> remove from player (set nowhere)
	lda tmpPer+1
	tax
	lda #OBJ_NOWHERE
	sta objLoc,x
	lda #<msgDropped
	sta lastMsgLo
	lda #>msgDropped
	sta lastMsgHi
	jsr saveGame
	rts

conv_apply_add_score:
	// tmpPer+1 = amount to add to score (8-bit add, carry into high byte)
	lda scoreLo
	clc
	adc tmpPer+1
	sta scoreLo
	lda scoreHi
	adc #0
	sta scoreHi
	lda #<msgOk
	sta lastMsgLo
	lda #>msgOk
	sta lastMsgHi
	rts

conv_apply_set_npcstage:
	// tmpPer+1 = npc index; set its conv stage to progressed (1)
	lda tmpPer+1
	tax
	lda #1
	sta npcConvStage,x
	lda #<msgOk
	sta lastMsgLo
	lda #>msgOk
	sta lastMsgHi
	rts

// log_give_item: write a short record to device 8 file EVLOG
// Expects tmpPer+1 contains the item id to log as an ASCII digit.
log_give_item:
	// set filename EVLOG
	lda #5
	ldx #<logName
	ldy #>logName
	jsr SETNAM
	// set LFN/DEVICE/SA
	lda #LFN
	ldx #DEVICE
	ldy #SA
	jsr SETLFS
	jsr OPEN
	jsr CHKOUT
	// write: 'G ' <item> ' Q ' <quest|N> ' L ' <loc>
	lda #'G'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda tmpPer+1
	clc
	adc #$30
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #'Q'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda activeQuest
	cmp #QUEST_NONE
	beq @lgq_none
	clc
	adc #$30
	jsr CHROUT
	jmp @lg_loc
@lgq_none:
	lda #'N'
	jsr CHROUT
@lg_loc:
	lda #' '
	jsr CHROUT
	lda #'L'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda currentLoc
	cmp #10
	bcc @lg_loc_low
	// >=10: write '1' then ones digit
	lda #'1'
	jsr CHROUT
	lda currentLoc
	sec
	sbc #10
	clc
	adc #$30
	jsr CHROUT
	jmp @lg_cr
@lg_loc_low:
	lda currentLoc
	clc
	adc #$30
	jsr CHROUT
@lg_cr:
	lda #$0D
	jsr CHROUT
	// close file
	lda #LFN
	jsr CLOSE
	rts

// --- Input ---
readLine:
	lda #0
	sta inputLen
	sta lastKey
	// no initial flush: avoid discarding the first Enter at prompts
	// If a key was prefetched (typed immediately after prior Enter), seed the buffer
	lda prefetchedHas
	beq @poll
	lda prefetchedKey
	sta inputBuf
	lda #0
	sta prefetchedHas
	lda #1
	sta inputLen
	// echo the prefetched character
	lda inputBuf
	jsr CHROUT
	sta lastKey

@poll:
	jsr SCNKEY
	jsr GETIN
	beq @poll

	cmp #$0D // RETURN
	bne @notReturn
	jmp @maybeFinish
@notReturn:
	cmp #$14 // DEL/BACKSPACE
	bne @noBack
	jmp @back
@noBack:

	// Limit length
	ldx inputLen
	cpx #47
	bcs @poll

	// Debounce to prevent key repeat
	cmp lastKey
	beq @poll
	sta lastKey

	// Store and echo
	sta inputBuf,x
	inx
	stx inputLen
	jsr CHROUT
	jmp @poll

// log_quest_complete: write a short record for quest completion to EVLOG
// Format: 'C ' <questId> ' L ' <loc>
log_quest_complete:
	// set filename EVLOG
	lda #5
	ldx #<logName
	ldy #>logName
	jsr SETNAM
	// set LFN/DEVICE/SA
	lda #LFN
	ldx #DEVICE
	ldy #SA
	jsr SETLFS
	jsr OPEN
	jsr CHKOUT
	// write: 'C ' <questId> ' L ' <loc>
	lda #'C'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda activeQuest
	cmp #10
	bcc @lqc_q_low
	// >=10: write '1' then ones digit
	lda #'1'
	jsr CHROUT
	lda activeQuest
	sec
	sbc #10
	clc
	adc #$30
	jsr CHROUT
	jmp @lqc_q_done
@lqc_q_low:
	lda activeQuest
	clc
	adc #$30
	jsr CHROUT
@lqc_q_done:
	lda #' '
	jsr CHROUT
	lda #'L'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda currentLoc
	cmp #10
	bcc @lqc_loc_low
	// >=10: write '1' then ones digit
	lda #'1'
	jsr CHROUT
	lda currentLoc
	sec
	sbc #10
	clc
	adc #$30
	jsr CHROUT
	jmp @lqc_done
@lqc_loc_low:
	lda currentLoc
	clc
	adc #$30
	jsr CHROUT
@lqc_done:
	rts
@maybeFinish:
	// Finish on RETURN (empty input allowed) — avoid double-enter at prompts.
	ldx inputLen
	bne @finish
	jmp @finish

@back:
	ldx inputLen
	bne @back_has
	jmp @poll
@back_has:
	dex
	stx inputLen
	lda #$14
	jsr CHROUT
	jmp @poll

@finish:
	// Null-terminate
	ldx inputLen
	lda #0
	sta inputBuf,x
	// Drain repeated RETURNs; if a non-RETURN key is pending, prefetch it for next prompt
	jsr SCNKEY
@post_drain:
	jsr GETIN
	beq @post_done
	cmp #$0D
	beq @post_drain
	// store first non-RETURN for next readLine
	sta prefetchedKey
	lda #1
	sta prefetchedHas
@post_done:
	rts

// Drain any pending buffered keys (helps avoid stray RETURN requiring double-enter)
flushKeys:
@fk:
	jsr SCNKEY
	jsr GETIN
	bne @fk
	rts

// tryAutoLoginDev: if file EVAUTO exists on device 8, fill profile with defaults,
// attempt to load and commit save, else create default profile. Returns C=1 on success (skip login).
tryAutoLoginDev:
	// Check for marker file EVAUTO
	lda #6
	ldx #<autoMarkerName
	ldy #>autoMarkerName
	jsr SETNAM
	lda #LFN
	ldx #DEVICE
	ldy #SA
	jsr SETLFS
	jsr OPEN
	jsr READST
	bne @tad_fail_near
	// close
	lda #LFN
	jsr CLOSE

	// Copy defaults: USERNAME
	lda #<autoUserZ
	sta ZP_PTR
	lda #>autoUserZ
	sta ZP_PTR+1
	lda #<username
	sta ZP_PTR2
	lda #>username
	sta ZP_PTR2+1
	lda #12
	jsr copyZToFixedGeneric
	lda tmpCnt
	sta usernameLen

	// DISPLAY NAME
	lda #<autoDispZ
	sta ZP_PTR
	lda #>autoDispZ
	sta ZP_PTR+1
	lda #<displayName
	sta ZP_PTR2
	lda #>displayName
	sta ZP_PTR2+1
	lda #16
	jsr copyZToFixedGeneric
	lda tmpCnt
	sta displayLen

	// CLASS NAME
	lda #<autoClassZ
	sta ZP_PTR
	lda #>autoClassZ
	sta ZP_PTR+1
	lda #<className
	sta ZP_PTR2
	lda #>className
	sta ZP_PTR2+1
	lda #12
	jsr copyZToFixedGeneric
	lda tmpCnt
	sta classLen
	jsr mapPlayerClass

	// PIN = 0000
	lda #0
	sta pinLo
	sta pinHi

	// Month/Week = 1
	lda #1
	sta month
	sta week

	// Build save base and try load
	jsr buildSaveNameBase
	jsr tryLoadGame
	bcc @tad_create
	// loaded: commit without PIN
	jsr commitLoadedState
	// enable debug during auto-login
	lda #1
	sta debugEnabled
	sec
	rts
@tad_fail_near:
	clc
	rts
@tad_create:
	// set HP from class
	jsr computePlayerMaxHp
	lda tmpHp
	sta playerCurHp
	// save defaults
	jsr saveGame
	// enable debug during auto-login
	lda #1
	sta debugEnabled
	sec
	rts

@tad_fail:
	clc
	rts

// copyZToFixedGeneric: copy zero-terminated string at (ZP_PTR) into dest (ZP_PTR2),
// up to A bytes max. Writes copied length into tmpCnt. Pads remaining with 0.
copyZToFixedGeneric:
	sta tmpHp         // tmpHp = max bytes
	ldy #0
@cz_loop:
	cpy tmpHp
	bcs @cz_done_copy
	lda (ZP_PTR),y
	beq @cz_done_copy
	sta (ZP_PTR2),y
	iny
	bne @cz_loop
@cz_done_copy:
	sty tmpCnt        // tmpCnt = length copied
	lda #0
@cz_pad_loop:
	cpy tmpHp
	bcs @cz_rts
	sta (ZP_PTR2),y   // pad with 0
	iny
	bne @cz_pad_loop
@cz_rts:
	rts

// --- Command execution ---
executeCommand:
	// Default: clear last message unless overwritten
	lda #<msgOk
	sta lastMsgLo
	lda #>msgOk
	sta lastMsgHi

	// Skip leading spaces
	ldx #0
@skip:
	lda inputBuf,x
	cmp #' '
	bne @ec_start
	inx
	cpx inputLen
	bcc @skip
	rts

@ec_start:
	// Single-letter quick commands
	lda inputBuf,x
	bne @ec_start2
	jmp @ec_done

@ec_start2:
	// Two-letter directional shortcuts: NE, NW, SE, SW
	cmp #'N'
	beq @ec_chkNdiag
	cmp #'S'
	beq @ec_chkSdiag
	jmp @ec_afterDiag

@ec_chkNdiag:
	ldy #1
	lda inputBuf,y
	cmp #'E'
	beq @ec_tryNE
	cmp #'W'
	beq @ec_tryNW
	jmp @ec_afterDiag
@ec_tryNE:
	ldy #2
	lda inputBuf,y
	cmp #' '
	beq @ec_doNE
	cmp #0
	beq @ec_doNE
	jmp @ec_afterDiag
@ec_doNE:
	jmp cmdNE
@ec_tryNW:
	ldy #2
	lda inputBuf,y
	cmp #' '
	beq @ec_doNW
	cmp #0
	beq @ec_doNW
	jmp @ec_afterDiag
@ec_doNW:
	jmp cmdNW

@ec_chkSdiag:
	ldy #1
	lda inputBuf,y
	cmp #'E'
	beq @ec_trySE
	cmp #'W'
	beq @ec_trySW
	lda inputBuf,y
	cmp #' '
	bne @check_zero
	jmp @do_cmdSouth
@check_zero:
	cmp #0
	bne @after
	jmp @do_cmdSouth
@after:
	jmp @ec_afterDiag
@ec_trySE:
	ldy #2
	lda inputBuf,y
	cmp #' '
	beq @ec_doSE
	cmp #0
	beq @ec_doSE
	jmp @ec_afterDiag
@ec_doSE:
	jmp cmdSE
@ec_trySW:
	ldy #2
	lda inputBuf,y
	cmp #' '
	beq @ec_doSW
	cmp #0
	beq @ec_doSW
	jmp @ec_afterDiag
@ec_doSW:
	jmp cmdSW

@ec_afterDiag:
	// treat single-letter directional commands only when the input is a single-letter
	cmp #'N'
	bne @ec_chk_n
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdNorth
	cmp #0
	beq @do_cmdNorth
	jmp @ec_chkS
@ec_chk_n:
	cmp #'n'
	bne @ec_chkS
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdNorth
	cmp #0
	beq @do_cmdNorth
	jmp @ec_chkS
@do_cmdNorth:
	jmp cmdNorth
@ec_chkS:
	cmp #'S'
	bne @ec_chk_s
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdSouth
	cmp #0
	beq @do_cmdSouth
	jmp @ec_chkE
@ec_chk_s:
	cmp #'s'
	bne @ec_chkE
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdSouth
	cmp #0
	beq @do_cmdSouth
	jmp @ec_chkE
@do_cmdSouth:
	jmp cmdSouth
@ec_chkE:
	cmp #'E'
	bne @ec_chk_e
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdEast
	cmp #0
	beq @do_cmdEast
	jmp @ec_chkW
@ec_chk_e:
	cmp #'e'
	bne @ec_chkW
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdEast
	cmp #0
	beq @do_cmdEast
	jmp @ec_chkW
@do_cmdEast:
	jmp cmdEast
@ec_chkW:
	cmp #'W'
	bne @ec_chk_w
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdWest
	cmp #0
	beq @do_cmdWest
	jmp @ec_chkC
@ec_chk_w:
	cmp #'w'
	bne @ec_chkC
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdWest
	cmp #0
	beq @do_cmdWest
	jmp @ec_chkC
@do_cmdWest:
	jmp cmdWest
@do_cmdNE:
	jmp cmdNE
@do_cmdNW:
	jmp cmdNW
@do_cmdSE:
	jmp cmdSE
@do_cmdSW:
	jmp cmdSW
@ec_chkC:
	cmp #'C'
	beq @ec_doC_check
	cmp #'c'
	bne @ec_chkT
	jmp @ec_doC_check
@ec_doC_check:
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdCharacters
	cmp #0
	beq @do_cmdCharacters
	jmp @ec_chkT
@do_cmdCharacters:
	jmp cmdCharactersMenu
@ec_chkT:
	cmp #'T'
	bne @ec_chkI
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdTalk
	cmp #0
	beq @do_cmdTalk
	jmp @ec_chkI
@do_cmdTalk:
	jmp cmdTalk
@ec_chkI:
	cmp #'I'
	bne @ec_chkM
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdInventory
	cmp #0
	beq @do_cmdInventory
@do_cmdInventory:
	jmp cmdInventory
	jmp @ec_chkM
@ec_chkM:
	cmp #'M'
	beq @ec_m_ok
	cmp #'m'
	bne @ec_chkQ
@ec_m_ok:
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdMusic
	cmp #0
	beq @do_cmdMusic
	jmp @ec_chkQ

@do_cmdMusic:
	jmp cmdMusicToggle

@ec_chkQ:
	// Single-character HELP alias: '?'
	lda inputBuf,x
	cmp #'?'
	bne @ec_afterQuick
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdHelpQuick
	cmp #0
	beq @do_cmdHelpQuick
	jmp @ec_afterQuick

@do_cmdHelpQuick:
	jmp cmdHelp

@ec_afterQuick:

	// Word commands (INSPECT/LOOK/EXAMINE)
	txa
	pha
	lda #<kwInspect
	sta ZP_PTR2
	lda #>kwInspect
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryLook
	jmp cmdInspect

@ec_tryLook:

	txa
	pha
	lda #<kwLook
	sta ZP_PTR2
	lda #>kwLook
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryExamine
	jmp cmdInspect

@ec_tryExamine:

	txa
	pha
	lda #<kwExamine
	sta ZP_PTR2
	lda #>kwExamine
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryTake
	jmp cmdInspect

@ec_tryTake:

	// TAKE/GET/PICK UP
	txa
	pha
	lda #<kwTake
	sta ZP_PTR2
	lda #>kwTake
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryGet
	jmp cmdTake

@ec_tryGet:

	txa
	pha
	lda #<kwGet
	sta ZP_PTR2
	lda #>kwGet
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryPick
	jmp cmdTake

@ec_tryPick:

	txa
	pha
	lda #<kwPick
	sta ZP_PTR2
	lda #>kwPick
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDrop
	jmp cmdPickUp

@ec_tryDrop:

	// DROP/SET DOWN
	txa
	pha
	lda #<kwDrop
	sta ZP_PTR2
	lda #>kwDrop
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_trySet
	jmp cmdDrop

@ec_trySet:

	txa
	pha
	lda #<kwSet
	sta ZP_PTR2
	lda #>kwSet
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryGive
	jmp cmdSetDown

@ec_tryGive:

	// GIVE
	txa
	pha
	lda #<kwGive
	sta ZP_PTR2
	lda #>kwGive
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirNorth
	jmp cmdGive

@ec_tryDirNorth:

	// Direction words (NORTH/SOUTH/EAST/WEST)
	txa
	pha
	lda #<kwNorth
	sta ZP_PTR2
	lda #>kwNorth
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirSouth
	jmp cmdNorth

@ec_tryDirSouth:

	txa
	pha
	lda #<kwSouth
	sta ZP_PTR2
	lda #>kwSouth
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirEast
	jmp cmdSouth

@ec_tryDirEast:

	txa
	pha
	lda #<kwEast
	sta ZP_PTR2
	lda #>kwEast
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirWest
	jmp cmdEast

@ec_tryDirWest:

	txa
	pha
	lda #<kwWest
	sta ZP_PTR2
	lda #>kwWest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirNE
	jmp cmdWest

@ec_tryDirNE:

	txa
	pha
	lda #<kwNortheast
	sta ZP_PTR2
	lda #>kwNortheast
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirNW
	jmp cmdNE

@ec_tryDirNW:

	txa
	pha
	lda #<kwNorthwest
	sta ZP_PTR2
	lda #>kwNorthwest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirSE
	jmp cmdNW

@ec_tryDirSE:

	txa
	pha
	lda #<kwSoutheast
	sta ZP_PTR2
	lda #>kwSoutheast
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryDirSW
	jmp cmdSE

@ec_tryDirSW:

	txa
	pha
	lda #<kwSouthwest
	sta ZP_PTR2
	lda #>kwSouthwest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryTalk
	jmp cmdSW

@ec_tryTalk:

	// TALK word
	txa
	pha
	lda #<kwTalk
	sta ZP_PTR2
	lda #>kwTalk
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryFight
	jmp cmdTalkWord

@ec_tryFight:
	// FIGHT word
	txa
	pha
	lda #<kwFight
	sta ZP_PTR2
	lda #>kwFight
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryCharacters
	jmp cmdFightWord

@ec_tryCharacters:

	// CHARACTERS word
	txa
	pha
	lda #<kwCharacters
	sta ZP_PTR2
	lda #>kwCharacters
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryInventory
	jmp cmdCharactersMenu

@ec_tryInventory:

	// INVENTORY word
	txa
	pha
	lda #<kwInventory
	sta ZP_PTR2
	lda #>kwInventory
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_trySave
	jmp cmdInventory

@ec_trySave:

	// SAVE
	txa
	pha
	lda #<kwSave
	sta ZP_PTR2
	lda #>kwSave
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryLoad
	jmp cmdSave

@ec_tryLoad:

	// LOAD
	txa
	pha
	lda #<kwLoad
	sta ZP_PTR2
	lda #>kwLoad
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryWait
	jmp cmdLoad

@ec_tryWait:

	// WAIT / REST / NEXT
	txa
	pha
	lda #<kwWait
	sta ZP_PTR2
	lda #>kwWait
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryRest
	jmp cmdWait

@ec_tryRest:

	txa
	pha
	lda #<kwRest
	sta ZP_PTR2
	lda #>kwRest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryNext
	jmp cmdWait

@ec_tryNext:

	txa
	pha
	lda #<kwNext
	sta ZP_PTR2
	lda #>kwNext
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryStatus
	jmp cmdWait

@ec_tryStatus:

	// STATUS / QUEST
	txa
	pha
	lda #<kwStatus
	sta ZP_PTR2
	lda #>kwStatus
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryQuest
	jmp cmdStatus

@ec_tryQuest:

	txa
	pha
	lda #<kwQuest
	sta ZP_PTR2
	lda #>kwQuest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryChart
	jmp cmdStatus

@ec_tryChart:

	// CHART (PETSCII glyph finder)
	txa
	pha
	lda #<kwChart
	sta ZP_PTR2
	lda #>kwChart
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_tryHelp
	jmp cmdChart

@ec_tryHelp:

	// HELP
	txa
	pha
	lda #<kwHelp
	sta ZP_PTR2
	lda #>kwHelp
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @ec_unknown
	jmp cmdHelp

@ec_unknown:

	// Unknown
	lda #<msgUnknown
	sta lastMsgLo
	lda #>msgUnknown
	sta lastMsgHi

@ec_done:
	rts

// Match keyword pointed to by ZP_PTR2 against inputBuf at X.
// Carry set if matches whole word (ends at space or 0).
matchKeywordAtX:
	ldy #0
@mk:
	lda (ZP_PTR2),y
	beq @endkw
	sta tmpCnt                // save keyword char (upper-case in tables)
	lda inputBuf,x            // load input char
	// to upper-case if in 'a'..'z'
	cmp #'a'
	bcc @cmp_kw
	cmp #'z'+1
	bcs @cmp_kw
	sec
	sbc #32                   // A = input uppe 300r-case
@cmp_kw:
	cmp tmpCnt               // compare input upper-case with keyword
	bne @no
	iny
	inx
	bne @mk

@endkw:
	lda inputBuf,x
	beq @yes
	cmp #' '
	beq @yes
@no:
	clc
	rts

// --- PETSCII chart helpers ---

printHexNibble:
	and #$0F
	cmp #10
	bcc @phn_num
	clc
	adc #('A'-10)
	jmp @phn_out
@phn_num:
	clc
	adc #'0'
@phn_out:
	jsr CHROUT
	rts

// Prints A as two hex digits
printHexByte:
	pha
	lsr
	lsr
	lsr
	lsr
	jsr printHexNibble
	pla
	and #$0F
	jsr printHexNibble
	rts

// Print one 16-char row: label + 16 glyphs + spaces
// A = row base (multiple of $10)
chartPrintRow:
	sta ZP_PTR
	lda ZP_PTR
	jsr printHexByte
	lda #':'
	jsr CHROUT
	lda #' '
	jsr CHROUT

	ldy #0
@cpr_loop:
	tya
	clc
	adc ZP_PTR
	jsr CHROUT
	lda #' '
	jsr CHROUT
	iny
	cpy #16
	bne @cpr_loop
	jsr newline
	rts

waitAnyKey:
	jsr flushKeys
@wak:
	jsr SCNKEY
	jsr GETIN
	beq @wak
	rts
@yes:
	sec
	rts

// Skip spaces starting at X// returns X at first non-space
skipSpaces:
@ss:
	lda inputBuf,x
	cmp #' '
	bne @ssdone
	inx
	bne @ss
@ssdone:
	rts

// Skip spaces and common filler words (TO/THE/A/AN) starting at X.
// Returns X at start of the next meaningful token.
skipFillers:
@again:
	jsr skipSpaces
	// TO
	txa
	pha
	lda #<kwTo
	sta ZP_PTR2
	lda #>kwTo
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @the
	inx
	inx
	jmp @again
@the:
	// THE
	txa
	pha
	lda #<kwThe
	sta ZP_PTR2
	lda #>kwThe
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @a
	inx
	inx
	inx
	jmp @again
@a:
	// A
	lda inputBuf,x
	cmp #'A'
	bne @an
	inx
	jmp @again
@an:
	// AN
	txa
	pha
	lda #<kwAn
	sta ZP_PTR2
	lda #>kwAn
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @sf_done
	inx
	inx
	jmp @again

@sf_done:
	rts

// Parse object noun starting at X. Returns A=objId, carry set if found.
parseObjectNoun:
	jsr skipFillers
	// Try LANTERN
	txa
	pha
	lda #<kwLantern
	sta ZP_PTR2
	lda #>kwLantern
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @coin
	lda #OBJ_LANTERN
	sec
	rts
@coin:
	txa
	pha
	lda #<kwCoin
	sta ZP_PTR2
	lda #>kwCoin
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @mug
	lda #OBJ_COIN
	sec
	rts
@mug:
	txa
	pha
	lda #<kwMug
	sta ZP_PTR2
	lda #>kwMug
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @mug_no_match
	lda #OBJ_MUG
	sec
	rts
@mug_no_match:
	// check for SCOTCH or BOTTLE keywords
	txa
	pha
	lda #<kwScotch
	sta ZP_PTR2
	lda #>kwScotch
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @mug_check_bottle
	lda #OBJ_SCOTCH
	sec
	rts
@mug_check_bottle:
	txa
	pha
	lda #<kwBottle
	sta ZP_PTR2
	lda #>kwBottle
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @key
	lda #OBJ_SCOTCH
	sec
	rts
@key:
	// also support WARD / PROTECTION keywords
	txa
	pha
	lda #<kwWard
	sta ZP_PTR2
	lda #>kwWard
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @key_check_protection
	lda #OBJ_WARD
	sec
	rts
@key_check_protection:
	txa
	pha
	lda #<kwProtection
	sta ZP_PTR2
	lda #>kwProtection
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @key_real
	lda #OBJ_WARD
	sec
	rts
@key_real:
	txa
	pha
	lda #<kwKey
	sta ZP_PTR2
	lda #>kwKey
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @heart
	lda #OBJ_KEY
	sec
	rts

@heart:
	txa
	pha
	lda #<kwHeart
	sta ZP_PTR2
	lda #>kwHeart
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @pinecone
	lda #OBJ_HEART
	sec
	rts

@pinecone:
	txa
	pha
	lda #<kwPinecone
	sta ZP_PTR2
	lda #>kwPinecone
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @shell
	lda #OBJ_PINECONE
	sec
	rts

@shell:
	txa
	pha
	lda #<kwShell
	sta ZP_PTR2
	lda #>kwShell
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @pon_fail
	lda #OBJ_SHELL
	sec
	rts

@pon_fail:
	clc
	rts

// Parse NPC noun starting at X. Returns A=npcId, carry set if found.
parseNpcNoun:
	jsr skipFillers
	// CONDUCTOR
	txa
	pha
	lda #<kwConductor
	sta ZP_PTR2
	lda #>kwConductor
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @bart
	lda #NPC_CONDUCTOR
	sec
	rts
@bart:
	txa
	pha
	lda #<kwBartender
	sta ZP_PTR2
	lda #>kwBartender
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @knight
	lda #NPC_BARTENDER
	sec
	rts
@knight:
	txa
	pha
	lda #<kwKnight
	sta ZP_PTR2
	lda #>kwKnight
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @mystic
	lda #NPC_KNIGHT
	sec
	rts
@mystic:
	txa
	pha
	lda #<kwMystic
	sta ZP_PTR2
	lda #>kwMystic
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @fairy
	lda #NPC_MYSTIC
	sec
	rts
@fairy:
	txa
	pha
	lda #<kwFairy
	sta ZP_PTR2
	lda #>kwFairy
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @pixie
	lda #NPC_FAIRY
	sec
	rts
@pixie:
	txa
	pha
	lda #<kwPixie
	sta ZP_PTR2
	lda #>kwPixie
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @apollonia
	lda #NPC_PIXIE
	sec
	rts
@apollonia:
	txa
	pha
	lda #<kwApollonia
	sta ZP_PTR2
	lda #>kwApollonia
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @statue
	lda #NPC_APOLLONIA
	sec
	rts
@statue:
	txa
	pha
	lda #<kwStatue
	sta ZP_PTR2
	lda #>kwStatue
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @alyster
	lda #NPC_APOLLONIA
	sec
	rts
@alyster:
	txa
	pha
	lda #<kwAlyster
	sta ZP_PTR2
	lda #>kwAlyster
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @dragontrainer
	lda #NPC_ALYSTER
	sec
	rts
@dragontrainer:
	txa
	pha
	lda #<kwDragonTrainer
	sta ZP_PTR2
	lda #>kwDragonTrainer
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @troll
	lda #NPC_ALYSTER
	sec
	rts
@troll:
	txa
	pha
	lda #<kwTroll
	sta ZP_PTR2
	lda #>kwTroll
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @bridge
	lda #NPC_TROLL
	sec
	rts
@bridge:
	txa
	pha
	lda #<kwBridge
	sta ZP_PTR2
	lda #>kwBridge
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @tosh
	lda #NPC_TROLL
	sec
	rts
@tosh:
	txa
	pha
	lda #<kwTosh
	sta ZP_PTR2
	lda #>kwTosh
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @tosher
	lda #NPC_TOSH
	sec
	rts
@tosher:
	txa
	pha
	lda #<kwTosher
	sta ZP_PTR2
	lda #>kwTosher
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcs @tosher_match
	jmp @nf
@tosher_match:
	lda #NPC_TOSH
	sec
	rts
@louden:
	txa
	pha
	lda #<kwLouden
	sta ZP_PTR2
	lda #>kwLouden
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @spirit
	lda #NPC_LOUDEN
	sec
	rts
@spirit:
	txa
	pha
	lda #<kwSpirit
	sta ZP_PTR2
	lda #>kwSpirit
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @mermaid
	lda #NPC_LOUDEN
	sec
	rts
@mermaid:
	txa
	pha
	lda #<kwMermaid
	sta ZP_PTR2
	lda #>kwMermaid
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcs @mermaid_match
	jmp @nf
@mermaid_match:
	lda #NPC_MERMAID
	sec
	rts
@kora:
	txa
	pha
	lda #<kwKora
	sta ZP_PTR2
	lda #>kwKora
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcs @kora_match
	jmp @nf
@kora_match:
	lda #NPC_KORA
	sec
	rts
@warlock:
	txa
	pha
	lda #<kwWarlock
	sta ZP_PTR2
	lda #>kwWarlock
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcs @warlock_match
	jmp @nf
@warlock_match:
	lda #NPC_WARLOCK
	sec
	rts
@candywitch:
	txa
	pha
	lda #<kwCandyWitch
	sta ZP_PTR2
	lda #>kwCandyWitch
	sta ZP_PTR2+1
	pla
	 tax
	jsr matchKeywordAtX
	bcs @candywitch_match
	jmp @nf
@candywitch_match:
	lda #NPC_CANDY_WITCH
	sec
	rts
@nf:
	// No built-in NPC noun matched; try dynamic given-name matching.
	// X currently points at the start of the noun word in inputBuf.
	stx tmpNounStart
	ldy #0              // Y = candidate NPC id
@ng_npcLoop:
	cpy #NPC_COUNT
	bcs @ng_fail
	sty tmpNpcIdx       // save candidate NPC id
	ldx tmpNpcIdx
	lda npcGivenNamePtrLo,x
	sta ZP_PTR
	lda npcGivenNamePtrHi,x
	sta ZP_PTR+1
	ldy #0
	lda (ZP_PTR),y
	beq @ng_nextNpc     // no given name for this NPC
	// Compare inputBuf[tmpNounStart..] to this given name
	ldx tmpNounStart
	ldy #0
@ng_cmpLoop:
	lda (ZP_PTR),y
	beq @ng_givenEnd    // reached end of given name
	cmp inputBuf,x
	bne @ng_nextNpc
	inx
	iny
	jmp @ng_cmpLoop
@ng_givenEnd:
	// All given-name characters matched; ensure token ends here in input
	lda inputBuf,x
	cmp #' '
	beq @ng_match
	cmp #0
	beq @ng_match
	// Extra characters in token (e.g. BOBBY vs BOB) -> no match
@ng_nextNpc:
	ldy tmpNpcIdx
	iny
	jmp @ng_npcLoop

@ng_match:
	lda tmpNpcIdx       // return npcId in A
	sec
	rts

@ng_fail:
	clc
	rts

// Parse simple scenery noun starting at X. Returns A=sceneryId, carry set if found.
// 0=STALL, 1=SIGN, 2=PORTAL
parseSceneryNoun:
	jsr skipFillers
	// STALL
	txa
	pha
	lda #<kwStall
	sta ZP_PTR2
	lda #>kwStall
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @pscn_sign
	lda #0
	sec
	rts

@pscn_sign:
	// SIGN
	txa
	pha
	lda #<kwSign
	sta ZP_PTR2
	lda #>kwSign
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @pscn_portal
	lda #1
	sec
	rts

@pscn_portal:
	// PORTAL
	txa
	pha
	lda #<kwPortal
	sta ZP_PTR2
	lda #>kwPortal
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @pscn_none
	lda #2
	sec
	rts

@pscn_none:
	clc
	rts

// --- Commands ---
cmdNorth:
	ldx currentLoc
	lda exitN,x
	cmp #$FF
	bne @n_direct
	// find y where exitS[y] = currentLoc
	ldy #0
@n_loop:
	lda exitS,y
	cmp currentLoc
	beq @n_found
	iny
	cpy #13
	bne @n_loop
	jmp @diag_no
@n_found:
	tya
	jmp doMove
@n_direct:
	jmp doMove
cmdSouth:
	ldx currentLoc
	lda exitS,x
	cmp #$FF
	bne @s_direct
	// find y where exitN[y] = currentLoc
	ldy #0
@s_loop:
	lda exitN,y
	cmp currentLoc
	beq @s_found
	iny
	cpy #13
	bne @s_loop
	jmp @diag_no
@s_found:
	tya
	jmp doMove
@s_direct:
	jmp doMove
cmdEast:
	ldx currentLoc
	lda exitE,x
	cmp #$FF
	bne @e_direct
	// find y where exitW[y] = currentLoc
	ldy #0
@e_loop:
	lda exitW,y
	cmp currentLoc
	beq @e_found
	iny
	cpy #13
	bne @e_loop
	jmp @diag_no
@e_found:
	tya
	jmp doMove
@e_direct:
	jmp doMove
cmdWest:
	ldx currentLoc
	lda exitW,x
	cmp #$FF
	bne @w_direct
	// find y where exitE[y] = currentLoc
	ldy #0
@w_loop:
	lda exitE,y
	cmp currentLoc
	beq @w_found
	iny
	cpy #13
	bne @w_loop
	jmp @diag_no
@w_found:
	tya
	jmp doMove
@w_direct:
	jmp doMove

// Diagonal movement: attempt two-step paths via cardinal exits
cmdNE:
	// Try N then E
	ldx currentLoc
	lda exitN,x
	cmp #$FF
	beq @ne_try_e
	tax
	lda exitE,x
	cmp #$FF
	bne @ne_go
@ne_try_e:
	// Try E then N
	ldx currentLoc
	lda exitE,x
	cmp #$FF
	beq @diag_no
	tax
	lda exitN,x
@ne_go:
	jmp doMove

cmdNW:
	// Try N then W
	ldx currentLoc
	lda exitN,x
	cmp #$FF
	beq @nw_try_w
	tax
	lda exitW,x
	cmp #$FF
	bne @nw_go
@nw_try_w:
	// Try W then N
	ldx currentLoc
	lda exitW,x
	cmp #$FF
	beq @diag_no
	tax
	lda exitN,x
@nw_go:
	jmp doMove

cmdSE:
	// Try S then E
	ldx currentLoc
	lda exitS,x
	cmp #$FF
	beq @se_try_e
	tax
	lda exitE,x
	cmp #$FF
	bne @se_go
@se_try_e:
	// Try E then S
	ldx currentLoc
	lda exitE,x
	cmp #$FF
	beq @diag_no
	tax
	lda exitS,x
@se_go:
	jmp doMove

cmdSW:
	// Try S then W
	ldx currentLoc
	lda exitS,x
	cmp #$FF
	beq @sw_try_w
	tax
	lda exitW,x
	cmp #$FF
	bne @sw_go
@sw_try_w:
	// Try W then S
	ldx currentLoc
	lda exitW,x
	cmp #$FF
	beq @diag_no
	tax
	lda exitS,x
@sw_go:
	jmp doMove

@diag_no:
	lda #<msgNoWay
	sta lastMsgLo
	lda #>msgNoWay
	sta lastMsgHi
	rts

doMove:
	cmp #$FF
	bne @mv_ok
	lda #<msgNoWay
	sta lastMsgLo
	lda #>msgNoWay
	sta lastMsgHi
	rts

@mv_ok:
	sta currentLoc
	jsr musicPickForLocation
	lda #<msgMoved
	sta lastMsgLo
	lda #>msgMoved
	sta lastMsgHi
	rts

cmdCharactersMenu:
	jsr clearScreen
	// Title
	lda #<strCharacters
	sta ZP_PTR
	lda #>strCharacters
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Option 0: player
	lda #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda displayLen
	beq @cc_print_user
	lda #<displayName
	sta ZP_PTR
	lda #>displayName
	sta ZP_PTR+1
	jsr printZ
	jmp @cc_afterPlayer

@cc_print_user:
	lda #<username
	sta ZP_PTR
	lda #>username
	sta ZP_PTR+1
	jsr printZ

@cc_afterPlayer:
	jsr newline

	// List NPCs present at this location (supports >8 NPCs via low/high mask)
	ldx currentLoc
	lda npcMaskByLocLo,x
	sta ZP_PTR2
	lda npcMaskByLocHi,x
	sta npcMaskHiTemp
	lda npcMaskByLocB2,x
	sta npcMaskB2Temp
	lda npcMaskByLocB3,x
	sta npcMaskB3Temp
	lda #0
	sta selCount
	ldx #0
@cc_npc_loop:
	lda ZP_PTR2
	and npcBitLo,x
	bne @cc_present_lo_tramp
	jmp @cc_check_hi_1
@cc_present_lo_tramp:
	// Prefer given name if present; otherwise use title, showing GIVEN (TITLE) when present
	lda npcGivenNamePtrLo,x
	sta ZP_PTR
	lda npcGivenNamePtrHi,x
	sta ZP_PTR+1
	ldy #0
	lda (ZP_PTR),y
	beq @cc_use_title_low
	// given name present — print numbered entry
	inc selCount
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jsr printNpcDisplayName
	jsr newline
	jmp @cc_npc_next
@cc_use_title_low:
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	// skip unknown entries
	lda ZP_PTR
	cmp #<npcNameUnknown
	beq @cc_check_low_eq
	jmp @cc_print_low

@cc_check_low_eq:
	lda ZP_PTR+1
	cmp #>npcNameUnknown
	beq @cc_npc_next_tramp
	jmp @cc_print_low

@cc_npc_next_tramp:
	jmp @cc_npc_next
@cc_print_low:
	// increment display count and print entry
	inc selCount
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jsr printNpcDisplayName
	jsr newline
	jmp @cc_npc_next

@cc_present_1:
	// Prefer given name if present; otherwise use title, showing GIVEN (TITLE) when present
	lda npcGivenNamePtrLo,x
	sta ZP_PTR
	lda npcGivenNamePtrHi,x
	sta ZP_PTR+1
	ldy #0
	lda (ZP_PTR),y
	beq @cc_use_title_hi
	// given name present — print numbered entry
	inc selCount
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jsr printNpcDisplayName
	jsr newline
	jmp @cc_npc_next
@cc_use_title_hi:
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	// skip unknown entries
	lda ZP_PTR
	cmp #<npcNameUnknown
	bne @cc_print_hi
	lda ZP_PTR+1
	cmp #>npcNameUnknown
	beq @cc_npc_next
@cc_print_hi:
	// increment display count and print entry
	inc selCount
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jsr printNpcDisplayName
	jsr newline

@cc_npc_next:
	inx
	cpx #NPC_COUNT
	bne @cc_npc_loop_tramp
	jmp @cc_npc_after_tramp_skip
@cc_npc_loop_tramp:
	jmp @cc_npc_loop
@cc_npc_after_tramp_skip:

	jmp @cc_npc_after

@cc_check_hi_1:
	lda npcMaskHiTemp
	and npcBitHi,x
	bne @cc_present_hi_tramp
	jmp @cc_check_b2
@cc_present_hi_tramp:
	jsr printNpcEntry
	jmp @cc_npc_next

@cc_check_b2:
	lda npcMaskB2Temp
	and npcBitB2,x
	bne @cc_present_b2_tramp
	jmp @cc_check_b3
@cc_present_b2_tramp:
	jsr printNpcEntry
	jmp @cc_npc_next

@cc_check_b3:
	lda npcMaskB3Temp
	and npcBitB3,x
	beq @cc_npc_next
	jsr printNpcEntry
	jmp @cc_npc_next

@cc_npc_after:

	// Prompt and read choice
	jsr setCursorPrompt
	jsr readLine
	// parse first char
	lda inputBuf
	beq @cc_done
	cmp #'0'
	beq @cc_show_player_call
	sec
	sbc #'0'
	sta selChoice
	// find corresponding npc index
	ldx #0
	ldy #0
@cc_find_loop:
	lda ZP_PTR2
	and npcBitLo,x
	beq @cc_find_check_hi
	// found in low
	iny
	tya
	cmp selChoice
	beq @cc_selected
	jmp @cc_find_next

@cc_find_check_hi:
	lda npcMaskHiTemp
	and npcBitHi,x
	beq @cc_find_next
	iny
	tya
	cmp selChoice
	beq @cc_selected
	jmp @cc_find_next

@cc_find_next:
	inx
	cpx #NPC_COUNT
	bne @cc_find_loop
	jmp @cc_done

@cc_show_player_call:
    jsr cmdSheet
    jmp @cc_done

@cc_selected:
	// if NPC present, open conversation menu
	jsr showNpcSheet
	rts

@cc_done:
	rts

showNpcSheet:
	// Expects X = npc index
	jsr clearScreen
	lda #<strSheetTitle
	sta ZP_PTR
	lda #>strSheetTitle
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr newline

	// NAME:
	lda #<strName
	sta ZP_PTR
	lda #>strName
	sta ZP_PTR+1
	jsr printZ
	jsr printNpcDisplayName
	jsr newline

	// CLASS:
	lda #<strClass
	sta ZP_PTR
	lda #>strClass
	sta ZP_PTR+1
	jsr printZ
	// lookup class name from npcClassIdx
	lda npcClassIdx,x
	tax
	lda classNameLo,x
	sta ZP_PTR
	lda classNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// LEVEL:
	lda #<strLevel
	sta ZP_PTR
	lda #>strLevel
	sta ZP_PTR+1
	jsr printZ
	lda npcLevel,x
	jsr appendByteAsDec
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// SCORE:
	lda #<strScore
	sta ZP_PTR
	lda #>strScore
	sta ZP_PTR+1
	jsr printZ
	lda npcScoreLo,x
	jsr appendByteAsDec
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// HP: compute max HP for NPC then show current/max
	txa
	sta tmpNpcIdx
	// load class idx for this npc
	lda npcClassIdx,x
	tax
	// load base hp into tmpHp
	lda classBaseHp,x
	sta tmpHp
	// load per-level value into tmpPer
	lda classHpPerLevel,x
	sta tmpPer
	// load level from npcLevel for this npc
	lda tmpNpcIdx
	tay
	lda npcLevel,y
	sta tmpCnt
@npc_hp_loop:
	lda tmpCnt
	beq @npc_hp_done
	lda tmpHp
	clc
	adc tmpPer
	sta tmpHp
	dec tmpCnt
	jmp @npc_hp_loop

@npc_hp_done:
	// ensure current HP is set (indexed by npc)
	lda tmpNpcIdx
	tax
	lda npcCurHp,x
	beq @npc_set_cur
	// print HP: cur/max
	lda npcCurHp,x
	jsr appendByteAsDec
	lda #<'/'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda tmpHp
	jsr appendByteAsDec
	jmp @npc_after_hp

@npc_set_cur:
	lda tmpHp
	sta npcCurHp,x
	// print HP: cur/max
	lda npcCurHp,x
	jsr appendByteAsDec
	lda #<'/'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda tmpHp
	jsr appendByteAsDec

@npc_after_hp:
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// wait for user to dismiss
	jsr setCursorPrompt
	jsr readLine
	rts

cmdSheet:
	// Full-screen quick character sheet
	jsr clearScreen
	// Title
	lda #<strSheetTitle
	sta ZP_PTR
	lda #>strSheetTitle
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr newline

	// NAME:
	lda #<strName
	sta ZP_PTR
	lda #>strName
	sta ZP_PTR+1
	jsr printZ
	lda #<username
	sta ZP_PTR
	lda #>username
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// DISPLAY:
	lda #<strDisplay
	sta ZP_PTR
	lda #>strDisplay
	sta ZP_PTR+1
	jsr printZ
	lda #<displayName
	sta ZP_PTR
	lda #>displayName
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// CLASS:
	lda #<strClass
	sta ZP_PTR
	lda #>strClass
	sta ZP_PTR+1
	jsr printZ
	lda #<className
	sta ZP_PTR
	lda #>className
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// RACE:
	lda #<strRace
	sta ZP_PTR
	lda #>strRace
	sta ZP_PTR+1
	jsr printZ
	lda #<raceName
	sta ZP_PTR
	lda #>raceName
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// HP: show player current/max
	jsr computePlayerMaxHp
	// ensure playerCurHp is initialized
	lda playerCurHp
	bne @ps_hp_have
	lda tmpHp
	sta playerCurHp
@ps_hp_have:
	// Build "HP: cur / max" into msgBuf and print
	jsr clearMsgBuf
	lda #<strHP
	sta ZP_PTR
	lda #>strHP
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda playerCurHp
	jsr appendByteAsDec
	lda #'/'
	jsr appendCharA
	lda #' '
	jsr appendCharA
	lda tmpHp
	jsr appendByteAsDec
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// If a session-only Max HP bonus is active, show a note below
	lda playerHpBonus
	beq @ps_no_hpbonus
	jsr clearMsgBuf
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<strPlus
	sta ZP_PTR
	lda #>strPlus
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda playerHpBonus
	jsr appendByteAsDec
	lda #<strMaxHpSession
	sta ZP_PTR
	lda #>strMaxHpSession
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline
@ps_no_hpbonus:

	// LEVEL (use msgBuf builder to append decimal)
	jsr clearMsgBuf
	lda #<strLevel
	sta ZP_PTR
	lda #>strLevel
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda currentLevel
	jsr appendByteAsDec
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// SCORE
	jsr clearMsgBuf
	lda #<strScore
	sta ZP_PTR
	lda #>strScore
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda scoreLo
	jsr appendByteAsDec
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// wait for user to dismiss
	jsr setCursorPrompt
	jsr readLine
	rts

cmdTalk:
	// Nested talk menu: list NPCs and pick one to talk to
	jsr clearScreen
	lda #<strCharacters
	sta ZP_PTR
	lda #>strCharacters
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	ldx currentLoc
	lda npcMaskByLocLo,x
	sta ZP_PTR2
	lda npcMaskByLocHi,x
	sta npcMaskHiTemp
	lda npcMaskByLocB2,x
	sta npcMaskB2Temp
	lda npcMaskByLocB3,x
	sta npcMaskB3Temp
	lda #0
	sta selCount
	ldx #0
@tt_npc_loop:
	lda ZP_PTR2
	and npcBitLo,x
	beq @tt_check_hi_2
	jsr printNpcEntry
	jmp @tt_npc_next

@tt_present_2:
	// Prefer given name if present; otherwise use title
	lda npcGivenNamePtrLo,x
	sta ZP_PTR
	lda npcGivenNamePtrHi,x
	sta ZP_PTR+1
	ldy #0
	lda (ZP_PTR),y
	bne @tt_print
	// No given name, fall back to title
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	// skip unknown entries
	lda ZP_PTR
	cmp #<npcNameUnknown
	bne @tt_print
	lda ZP_PTR+1
	cmp #>npcNameUnknown
	beq @tt_npc_next
@tt_print:
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jsr printNpcDisplayName
	jsr newline
	inc selCount

@tt_npc_next:
	inx
	cpx #NPC_COUNT
	bne @tt_npc_loop

	jmp @tt_npc_done

@tt_check_hi_2:
	lda npcMaskHiTemp
	and npcBitHi,x
	beq @tt_check_b2
	jsr printNpcEntry
	jmp @tt_npc_next

@tt_check_b2:
	lda npcMaskB2Temp
	and npcBitB2,x
	beq @tt_check_b3
	jsr printNpcEntry
	jmp @tt_npc_next

@tt_check_b3:
	lda npcMaskB3Temp
	and npcBitB3,x
	beq @tt_npc_next
	jsr printNpcEntry
	jmp @tt_npc_next

@tt_npc_done:

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @tt_done
	sec
	sbc #'0'
	sta selChoice
	inc selChoice
	ldx #0
	ldy #0
@tt_find_loop:
	lda ZP_PTR2
	and npcBitLo,x
	beq @tt_find_check_hi
	iny
	tya
	cmp selChoice
	beq @tt_selected
	jmp @tt_find_next

@tt_find_check_hi:
	lda npcMaskHiTemp
	and npcBitHi,x
	beq @tt_find_check_b2
	iny
	tya
	cmp selChoice
	beq @tt_selected

@tt_find_check_b2:
	lda npcMaskB2Temp
	and npcBitB2,x
	beq @tt_find_check_b3
	iny
	tya
	cmp selChoice
	beq @tt_selected

@tt_find_check_b3:
	lda npcMaskB3Temp
	and npcBitB3,x
	beq @tt_find_next
	iny
	tya
	cmp selChoice
	beq @tt_selected

@tt_find_next:
	inx
	cpx #NPC_COUNT
	bne @tt_find_loop
	jmp @tt_done

@tt_selected:
	// if NPC present, open conversation menu
	jsr conversationMenu
	rts

@tt_done:
	// nothing selected
	rts
@talk_none:
	lda #<msgNoOne
	sta lastMsgLo
	lda #>msgNoOne
	sta lastMsgHi
	rts

// TALK word handler: supports 'TALK <NPCNAME>' directly; falls back to menu
cmdTalkWord:
	// X currently points just after the matched TALK keyword
	jsr skipFillers
	jsr parseNpcNoun
	bcs @ctw_haveNpc
	// no noun provided -> show menu
	jmp cmdTalk
@ctw_haveNpc:
	// A = npcId
	tax
	// Check NPC presence at currentLoc
	ldy currentLoc
	lda npcMaskByLocLo,y
	sta ZP_PTR2
	lda npcMaskByLocHi,y
	sta npcMaskHiTemp
	lda npcMaskByLocB2,y
	sta npcMaskB2Temp
	lda npcMaskByLocB3,y
	sta npcMaskB3Temp
	lda ZP_PTR2
	and npcBitLo,x
	bne @ctw_present
	lda npcMaskHiTemp
	and npcBitHi,x
	bne @ctw_present
	// Not here
	jmp @npcNotHere
@ctw_present:
	// Open conversation with this NPC
	jsr conversationMenu
	rts

// FIGHT word handler: 'FIGHT <NPCNAME>' starts combat with that NPC
cmdFightWord:
	// X currently points just after the matched FIGHT keyword
	jsr skipFillers
	jsr parseNpcNoun
	bcs @cfw_haveNpc
	// require a specific target
	lda #<msgDontKnow
	sta lastMsgLo
	lda #>msgDontKnow
	sta lastMsgHi
	rts
@cfw_haveNpc:
	// A = npcId
	tax
	// Check NPC presence at currentLoc (same mask logic as TALK word)
	ldy currentLoc
	lda npcMaskByLocLo,y
	sta ZP_PTR2
	lda npcMaskByLocHi,y
	sta npcMaskHiTemp
	lda ZP_PTR2
	and npcBitLo,x
	bne @cfw_present
	lda npcMaskHiTemp
	and npcBitHi,x
	bne @cfw_present
	// Not here
	jmp @npcNotHere
@cfw_present:
	// Start combat with this NPC (does not return)
	jmp combatStartWithNpc

// SAY command: SAY <PHRASE> TO <NPC>
cmdSay:
	// X currently points just after the matched SAY keyword
	jsr skipFillers
	// Expect Kora's jape phrase
	txa
	pha
	lda #<kwKoraPhrase
	sta ZP_PTR2
	lda #>kwKoraPhrase
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @say_fail
	// advance past phrase and parse target after fillers
	jsr skipFillers
	jsr parseNpcNoun
	bcc @say_fail
	// A = npcId; target must be Kendrick
	cmp #NPC_KENDRICK
	bne @say_fail
	// Require Kora's quest active
	lda activeQuest
	cmp #QUEST_KORA_JAPE
	bne @say_fail
	// Complete quest
	jsr questComplete
	lda #<msgKoraJapeDone
	sta lastMsgLo
	lda #>msgKoraJapeDone
	sta lastMsgHi
	rts

@say_fail:
	lda #<msgDontKnow
	sta lastMsgLo
	lda #>msgDontKnow
	sta lastMsgHi
	rts

// Conversation menu for an NPC. Expects X = npc index
conversationMenu:
	// mark we're in a conversation so render() won't show the map
	lda #1
	sta uiInConversation
	// preserve NPC index across input reads
	stx tmpNpcIdx
	jsr assignNpcTrinkets
	jsr clearScreen
	// Print NPC name as header (GIVEN (TITLE) if given name exists)
	jsr printNpcDisplayName
	jsr newline

conv_loop:
	// ensure X = npc index before using indexed tables
	ldx tmpNpcIdx
	// 0. Speak
	lda #'0'  
	jsr CHROUT
	lda #'.'  
	jsr CHROUT
	lda #' '  
	jsr CHROUT
	lda npcTalkLo,x
	sta ZP_PTR
	lda npcTalkHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// 1. Ask weather
	lda #'1'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<msgAskWeather
	sta ZP_PTR
	lda #>msgAskWeather
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// 2. Comment on temp
	lda #'2'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<msgTempResponse
	sta ZP_PTR
	lda #>msgTempResponse
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// 3. Any quests?
	lda #'3'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<msgQuestOfferGeneric
	sta ZP_PTR
	lda #>msgQuestOfferGeneric
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// 4. Quest info
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<msgNoQuestNpc
	sta ZP_PTR
	lda #>msgNoQuestNpc
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// 5. End
	lda #'5'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<msgEndConversation
	sta ZP_PTR
	lda #>msgEndConversation
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Check if NPC has trinkets
	txa
	sta tmpCnt
	asl
	adc tmpCnt  // *3
	tay
	ldx #0
@check_trinkets:
	lda npcTrinkets,y
	cmp #$FF
	bne @has_trinkets
	iny
	inx
	cpx #3
	bne @check_trinkets
	jmp @no_trade
@has_trinkets:
	// 6. Trade Trinkets
	lda #'6'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<msgTradeTrinkets
	sta ZP_PTR
	lda #>msgTradeTrinkets
	sta ZP_PTR+1
	jsr printZ
	jsr newline
@no_trade:
	ldx tmpNpcIdx
	jsr readLine
	lda inputBuf
	// Ignore empty RETURN here to avoid stray buffered RETURNs exiting
	// the conversation immediately; re-prompt instead.
	beq @conv_jump
	sec
	sbc #'0'
	tay
	tya
	cmp #6
	beq conv_choice6
	cmp #5
	beq conv_choice5
	cmp #0
	beq conv_choice0
	cmp #1
	beq conv_choice1
	cmp #2
	beq conv_choice2
	cmp #3
	beq conv_choice3
	cmp #4
	beq conv_choice4
		jmp conv_loop

	@conv_jump:
		jmp conv_loop

	conv_exit_short:
		jmp conversationMenu_exit

conv_choice0:
	jmp @conv_do_speak

conv_choice1:
	jmp @conv_do_weather

conv_choice2:
	jmp @conv_do_temp

conv_choice3:
	jmp @conv_do_quest

conv_choice4:
	jmp @conv_do_qinfo

conv_choice5:
	jmp conversationMenu_exit

conv_choice6:
	jmp @conv_do_trade

@conv_do_speak:
	// restore npc index in X for handler dispatch
	ldx tmpNpcIdx
	// Indirect dispatch table by NPC index (X)
	lda convSpeakHandlerLo,x
	sta ZP_PTR
	lda convSpeakHandlerHi,x
	sta ZP_PTR+1
	jmp (ZP_PTR)

@conv_speak_default:
	// ensure X = npc index for default speak
	ldx tmpNpcIdx
	lda npcTalkLo,x
	sta lastMsgLo
	lda npcTalkHi,x
	sta lastMsgHi
	jsr render
	// Check per-choice effect (choice0)
	lda convChoiceType_choice0,x
	beq @conv_speak_noeff
	lda convChoiceVal_choice0,x
	sta tmpPer+1
	lda convChoiceType_choice0,x
	jsr conv_apply_effect
@conv_speak_noeff:
	jmp conv_loop

@conv_pirate:
	jsr pirateConversation
	jmp conv_loop

@conv_bartender:
	jsr bartenderConversation
	jmp conv_loop

@conv_knight:
	jsr knightConversation
	jmp conv_loop

@conv_fairy:
	jsr fairyConversation
	jmp conv_loop

@conv_pixie:
	jsr pixieConversation
	jmp conv_loop

@conv_spider:
	jsr spiderConversation
	jmp conv_loop

@conv_unseely:
	jsr unseelyConversation
	jmp conv_loop

@conv_apollonia:
	jsr apolloniaConversation
	jmp conv_loop

@conv_alyster:
	jsr alysterConversation
	jmp conv_loop

@conv_troll:
	jsr trollConversation
	jmp conv_loop

@conv_tosh:
	jsr toshConversation
	jmp conv_loop

@conv_louden:
	jsr loudenConversation
	jmp conv_loop
@conv_mermaid:
	jsr mermaidConversation
	jmp conv_loop
// Unseely Fae conversation
unseelyConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	lda #<msgUnseelyMenuHeader
	sta ZP_PTR
	lda #>msgUnseelyMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgUnseelyOpt0
	sta ZP_PTR
	lda #>msgUnseelyOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgUnseelyOpt1
	sta ZP_PTR
	lda #>msgUnseelyOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgUnseelyOpt2
	sta ZP_PTR
	lda #>msgUnseelyOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgUnseelyOpt3
	sta ZP_PTR
	lda #>msgUnseelyOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 4. FIGHT
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @u_noinput
	sec
	sbc #'0'
	tay
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda unseelyJumpLo,y
	sta ZP_PTR
	lda unseelyJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@u_noinput:
	jmp unseelyConversation

@u_ask:
	lda #<msgUnseelyAsk
	sta lastMsgLo
	lda #>msgUnseelyAsk
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp unseelyConversation

@u_request:
	// start quest if not already started
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq @u_noquest
	lda npcOffersQuest,x
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #<msgUnseelyRequest
	sta lastMsgLo
	lda #>msgUnseelyRequest
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp unseelyConversation

@u_noquest:
	lda #<msgUnseelyOfferAlready
	sta lastMsgLo
	lda #>msgUnseelyOfferAlready
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp unseelyConversation

@u_leave:
	rts

@u_offer:
	// Offer the stolen name: check player inventory and active quest
	lda objLoc+OBJ_STOLEN_NAME
	cmp #OBJ_INVENTORY
	bne @u_noname
	lda activeQuest
	cmp #QUEST_UNSEELY_NAME
	bne @u_noquest
	// take the stolen name
	lda #OBJ_STOLEN_NAME
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// complete the quest
	lda #QUEST_UNSEELY_NAME
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect
	lda #<msgUnseelyThanks
	sta lastMsgLo
	lda #>msgUnseelyThanks
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp unseelyConversation

@u_noname:
	lda #<msgUnseelyNoName
	sta lastMsgLo
	lda #>msgUnseelyNoName
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp unseelyConversation

unseelyJumpLo:
	.byte <@u_ask,<@u_request,<@u_offer,<@u_leave,<@u_fight
unseelyJumpHi:
	.byte >@u_ask,>@u_request,>@u_offer,>@u_leave,>@u_fight

@u_fight:
	jmp combatStartWithNpc

// Apollonia conversation. Expects X = npc index.
apolloniaConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgApolloniaMenuHeader
	sta ZP_PTR
	lda #>msgApolloniaMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgApolloniaOpt0
	sta ZP_PTR
	lda #>msgApolloniaOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgApolloniaOpt1
	sta ZP_PTR
	lda #>msgApolloniaOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgApolloniaOpt2
	sta ZP_PTR
	lda #>msgApolloniaOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgApolloniaOpt3
	sta ZP_PTR
	lda #>msgApolloniaOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgApolloniaOpt4
	sta ZP_PTR
	lda #>msgApolloniaOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 5. FIGHT
	lda #'5'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @a_noinput
	sec
	sbc #'0'
	tay
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda apolloniaJumpLo,y
	sta ZP_PTR
	lda apolloniaJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@a_noinput:
	jmp apolloniaConversation

@a_martyrs:
	// One-time blessing: on first story selection, set stage and add +1 score
	lda npcConvStage,x
	bne @a_martyrs_msg
	txa
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
@a_martyrs_msg:
	lda #<msgApolloniaMartyrs
	sta lastMsgLo
	lda #>msgApolloniaMartyrs
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp apolloniaConversation

@a_teeth:
	lda npcConvStage,x
	bne @a_teeth_msg
	txa
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
@a_teeth_msg:
	lda #<msgApolloniaTeeth
	sta lastMsgLo
	lda #>msgApolloniaTeeth
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp apolloniaConversation

@a_fire:
	lda npcConvStage,x
	bne @a_fire_msg
	txa
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
@a_fire_msg:
	lda #<msgApolloniaFire
	sta lastMsgLo
	lda #>msgApolloniaFire
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp apolloniaConversation

@a_leave:
	// If offering quest is active but not complete, apply a small curse (-1 score)
	lda activeQuest
	cmp #QUEST_APOLLONIA_OFFERING
	bne @a_leave_rts
	lda questStatus
	cmp #1
	bne @a_leave_rts
	lda #$FF
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgApolloniaCurse
	sta lastMsgLo
	lda #>msgApolloniaCurse
	sta lastMsgHi
	jsr render
    jsr setCursorPrompt
    jsr readLine
@a_leave_rts:
	rts

@a_offer:
	// Find any item in inventory and leave it as an offering
	ldy #0
@a_offer_scan:
	cpy #OBJ_COUNT
	beq @a_offer_none
	lda objLoc,y
	cmp #OBJ_INVENTORY
	beq @a_offer_found
	iny
	bne @a_offer_scan
@a_offer_found:
	lda #OBJ_NOWHERE
	sta objLoc,y
	// Complete quest if active
	lda activeQuest
	cmp #QUEST_APOLLONIA_OFFERING
	bne @a_offer_msg
	lda #QUEST_APOLLONIA_OFFERING
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect
@a_offer_msg:
	lda #<msgApolloniaOfferDone
	sta lastMsgLo
	lda #>msgApolloniaOfferDone
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp apolloniaConversation
@a_offer_none:
	lda #<msgApolloniaNoOffer
	sta lastMsgLo
	lda #>msgApolloniaNoOffer
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp apolloniaConversation

apolloniaJumpLo:
	.byte <@a_martyrs,<@a_teeth,<@a_fire,<@a_offer,<@a_leave,<@a_fight
apolloniaJumpHi:
	.byte >@a_martyrs,>@a_teeth,>@a_fire,>@a_offer,>@a_leave,>@a_fight

@a_fight:
	jmp combatStartWithNpc

// Alyster conversation. Expects X = npc index.
alysterConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgAlysterMenuHeader
	sta ZP_PTR
	lda #>msgAlysterMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgAlysterOpt0
	sta ZP_PTR
	lda #>msgAlysterOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgAlysterOpt1
	sta ZP_PTR
	lda #>msgAlysterOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgAlysterOpt2
	sta ZP_PTR
	lda #>msgAlysterOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgAlysterOpt3
	sta ZP_PTR
	lda #>msgAlysterOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgAlysterOpt4
	sta ZP_PTR
	lda #>msgAlysterOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 5. FIGHT
	lda #'5'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @ly_noinput
	sec
	sbc #'0'
	tay
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda alysterJumpLo,y
	sta ZP_PTR
	lda alysterJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@ly_noinput:
	jmp alysterConversation

@ly_basics:
	// One-time stage and +1 score
	lda npcConvStage,x
	bne @ly_basics_msg
	txa
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
@ly_basics_msg:
	lda #<msgAlysterBasics
	sta lastMsgLo
	lda #>msgAlysterBasics
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp alysterConversation

@ly_care:
	lda #<msgAlysterCare
	sta lastMsgLo
	lda #>msgAlysterCare
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp alysterConversation

@ly_practice:
	// Minor buff: heal +1 HP capped to max, and +1 score
	jsr computePlayerMaxHp
	lda playerCurHp
	cmp tmpHp
	bcs @ly_practice_score
	clc
	adc #1
	cmp tmpHp
	bcc @ly_hp_set
	lda tmpHp
@ly_hp_set:
	sta playerCurHp
@ly_practice_score:
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgAlysterPractice
	sta lastMsgLo
	lda #>msgAlysterPractice
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp alysterConversation

@ly_advanced:
	// Gate: require basics first (npcConvStage>=1)
	lda npcConvStage,x
	cmp #1
	bcc @ly_notready
	// If already has bonus, acknowledge
	lda playerHpBonus
	bne @ly_adv_done
	lda #2
	sta playerHpBonus
	// Heal to new max and add +2 score
	jsr computePlayerMaxHp
	lda tmpHp
	sta playerCurHp
	lda #2
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgAlysterAdvanced
	sta lastMsgLo
	lda #>msgAlysterAdvanced
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp alysterConversation
@ly_adv_done:
	lda #<msgAlysterAdvancedDone
	sta lastMsgLo
	lda #>msgAlysterAdvancedDone
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp alysterConversation
@ly_notready:
	lda #<msgAlysterNotReady
	sta lastMsgLo
	lda #>msgAlysterNotReady
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp alysterConversation

@ly_leave:
	rts

alysterJumpLo:
	.byte <@ly_basics,<@ly_care,<@ly_practice,<@ly_advanced,<@ly_leave,<@ly_fight
alysterJumpHi:
	.byte >@ly_basics,>@ly_care,>@ly_practice,>@ly_advanced,>@ly_leave,>@ly_fight

@ly_fight:
	jmp combatStartWithNpc

// Troll conversation. Expects X = npc index.
trollConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgTrollMenuHeader
	sta ZP_PTR
	lda #>msgTrollMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgTrollOpt0
	sta ZP_PTR
	lda #>msgTrollOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgTrollOpt1
	sta ZP_PTR
	lda #>msgTrollOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgTrollOpt2
	sta ZP_PTR
	lda #>msgTrollOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgTrollOpt3
	sta ZP_PTR
	lda #>msgTrollOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 4. FIGHT
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @t_noinput
	sec
	sbc #'0'
	tay
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda trollJumpLo,y
	sta ZP_PTR
	lda trollJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@t_noinput:
	jmp trollConversation

@t_comp:
	lda #<msgTrollCompliment
	sta lastMsgLo
	lda #>msgTrollCompliment
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp trollConversation

@t_insult:
	lda #<msgTrollInsult
	sta lastMsgLo
	lda #>msgTrollInsult
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp trollConversation

@t_kevin:
	lda #<msgTrollKevin
	sta lastMsgLo
	lda #>msgTrollKevin
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp trollConversation

@t_leave:
	rts

trollJumpLo:
	.byte <@t_comp,<@t_insult,<@t_kevin,<@t_leave,<@t_fight
trollJumpHi:
	.byte >@t_comp,>@t_insult,>@t_kevin,>@t_leave,>@t_fight

@t_fight:
	jmp combatStartWithNpc

// Tosh conversation. Expects X = npc index.
toshConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgToshMenuHeader
	sta ZP_PTR
	lda #>msgToshMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgToshOpt0
	sta ZP_PTR
	lda #>msgToshOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgToshOpt1
	sta ZP_PTR
	lda #>msgToshOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgToshOpt2
	sta ZP_PTR
	lda #>msgToshOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgToshOpt3
	sta ZP_PTR
	lda #>msgToshOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 4. FIGHT
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @to_noinput
	sec
	sbc #'0'
	tay
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda toshJumpLo,y
	sta ZP_PTR
	lda toshJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@to_noinput:
	jmp toshConversation

@to_david:
	lda #<msgToshDavid
	sta lastMsgLo
	lda #>msgToshDavid
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp toshConversation

@to_trade:
	// Find any item in inventory and trade it for a COIN
	ldy #0
@to_trade_scan:
	cpy #OBJ_COUNT
	beq @to_trade_none
	lda objLoc,y
	cmp #OBJ_INVENTORY
	beq @to_trade_found
	iny
	bne @to_trade_scan
@to_trade_found:
	// take the found item
	tya
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// give a COIN
	lda #OBJ_COIN
	sta tmpPer+1
	lda #3
	jsr conv_apply_effect
	// minor goodwill: +1 score
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgToshTradeDone
	sta lastMsgLo
	lda #>msgToshTradeDone
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp toshConversation
@to_trade_none:
	lda #<msgToshTradeNone
	sta lastMsgLo
	lda #>msgToshTradeNone
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp toshConversation

@to_work:
	lda #<msgToshWork
	sta lastMsgLo
	lda #>msgToshWork
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp toshConversation

@to_leave:
	rts

toshJumpLo:
	.byte <@to_david,<@to_trade,<@to_work,<@to_leave,<@to_fight
toshJumpHi:
	.byte >@to_david,>@to_trade,>@to_work,>@to_leave,>@to_fight

@to_fight:
	jmp combatStartWithNpc

// Louden conversation. Expects X = npc index.
loudenConversation:
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgLoudenMenuHeader
	sta ZP_PTR
	lda #>msgLoudenMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgLoudenOpt0
	sta ZP_PTR
	lda #>msgLoudenOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgLoudenOpt1
	sta ZP_PTR
	lda #>msgLoudenOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgLoudenOpt2
	sta ZP_PTR
	lda #>msgLoudenOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgLoudenOpt3
	sta ZP_PTR
	lda #>msgLoudenOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 4. FIGHT
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @lo_noinput
	sec
	sbc #'0'
	tay
	ldx tmpNpcIdx
	lda loudenJumpLo,y
	sta ZP_PTR
	lda loudenJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@lo_noinput:
	jmp loudenConversation

@lo_story:
	lda #<msgLoudenStory
	sta lastMsgLo
	lda #>msgLoudenStory
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp loudenConversation

@lo_accept:
	lda #QUEST_LOUDEN_HEART
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #<msgLoudenAccept
	sta lastMsgLo
	lda #>msgLoudenAccept
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp loudenConversation

@lo_offer:
	lda objLoc+OBJ_HEART
	cmp #OBJ_INVENTORY
	bne @lo_noheart
	// take heart
	lda #OBJ_HEART
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// complete quest
	lda #QUEST_LOUDEN_HEART
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect
	lda #<msgLoudenThanks
	sta lastMsgLo
	lda #>msgLoudenThanks
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp loudenConversation
@lo_noheart:
	lda #<msgLoudenNoHeart
	sta lastMsgLo
	lda #>msgLoudenNoHeart
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp loudenConversation

@lo_leave:
	rts

loudenJumpLo:
	.byte <@lo_story,<@lo_accept,<@lo_offer,<@lo_leave,<@lo_fight
loudenJumpHi:
	.byte >@lo_story,>@lo_accept,>@lo_offer,>@lo_leave,>@lo_fight

@lo_fight:
	jmp combatStartWithNpc

// Mermaid conversation. Expects X = npc index.
mermaidConversation:
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgMermaidMenuHeader
	sta ZP_PTR
	lda #>msgMermaidMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgMermaidOpt0
	sta ZP_PTR
	lda #>msgMermaidOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgMermaidOpt1
	sta ZP_PTR
	lda #>msgMermaidOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgMermaidOpt2
	sta ZP_PTR
	lda #>msgMermaidOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgMermaidOpt3
	sta ZP_PTR
	lda #>msgMermaidOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 4. FIGHT
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @mm_noinput
	sec
	sbc #'0'
	tay
	ldx tmpNpcIdx
	lda mermaidJumpLo,y
	sta ZP_PTR
	lda mermaidJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@mm_noinput:
	jmp mermaidConversation

@mm_sing:
	lda #<msgMermaidSing
	sta lastMsgLo
	lda #>msgMermaidSing
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp mermaidConversation

@mm_ask:
	lda #QUEST_MERMAID_TRADE
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #<msgMermaidAskTrade
	sta lastMsgLo
	lda #>msgMermaidAskTrade
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp mermaidConversation

@mm_offer:
	// Offer land coral: trade PINECONE for SHELL if carried and quest active
	lda objLoc+OBJ_PINECONE
	cmp #OBJ_INVENTORY
	bne @mm_no_pine
	lda activeQuest
	cmp #QUEST_MERMAID_TRADE
	bne @mm_no_quest
	// take pinecone
	lda #OBJ_PINECONE
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// give shell
	lda #OBJ_SHELL
	sta tmpPer+1
	lda #3
	jsr conv_apply_effect
	// complete quest
	lda #QUEST_MERMAID_TRADE
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect
	lda #<msgMermaidTradeDone
	sta lastMsgLo
	lda #>msgMermaidTradeDone
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp mermaidConversation

@mm_no_pine:
	lda #<msgMermaidTradeNone
	sta lastMsgLo
	lda #>msgMermaidTradeNone
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp mermaidConversation

@mm_no_quest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp mermaidConversation

@mm_leave:
	rts

mermaidJumpLo:
	.byte <@mm_sing,<@mm_ask,<@mm_offer,<@mm_leave,<@mm_fight
mermaidJumpHi:
	.byte >@mm_sing,>@mm_ask,>@mm_offer,>@mm_leave,>@mm_fight

@mm_fight:
	jmp combatStartWithNpc
// Spider Princess conversation. Expects X = npc index.
spiderConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgSpiderMenuHeader
	sta ZP_PTR
	lda #>msgSpiderMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgSpiderOpt0
	sta ZP_PTR
	lda #>msgSpiderOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgSpiderOpt1
	sta ZP_PTR
	lda #>msgSpiderOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgSpiderOpt2
	sta ZP_PTR
	lda #>msgSpiderOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgSpiderOpt3
	sta ZP_PTR
	lda #>msgSpiderOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 4. FIGHT
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @s_noinput
	sec
	sbc #'0'
	tay
	// indirect jump table
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda spiderJumpLo,y
	sta ZP_PTR
	lda spiderJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@s_noinput:
	jmp spiderConversation

@s_flirt:
	lda #<msgSpiderFlirt
	sta lastMsgLo
	lda #>msgSpiderFlirt
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp spiderConversation

@s_whisper:
	// set conversation stage progressed
	lda #1
	sta npcConvStage,x
	lda #<msgSpiderWhisper
	sta lastMsgLo
	lda #>msgSpiderWhisper
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp spiderConversation

@s_offer:
	// start spider's lure quest if not active
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq @s_noquest
	lda npcOffersQuest,x
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #1
	sta npcConvStage,x
	// custom spider message
	lda #<msgSpiderOfferStart
	sta lastMsgLo
	lda #>msgSpiderOfferStart
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp spiderConversation

@s_noquest:
	lda #<msgSpiderOfferAlready
	sta lastMsgLo
	lda #>msgSpiderOfferAlready
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp spiderConversation

@s_leave:
	rts

spiderJumpLo:
	.byte <@s_flirt,<@s_whisper,<@s_offer,<@s_leave,<@s_fight
spiderJumpHi:
	.byte >@s_flirt,>@s_whisper,>@s_offer,>@s_leave,>@s_fight

@s_fight:
	jmp combatStartWithNpc

@conv_conductor:
	jsr conductorConversation
	jmp conv_loop

// Conversation handler table indexed by NPC index (X)
convSpeakHandlerLo:
	.byte <@conv_conductor, <@conv_bartender, <@conv_knight, <@conv_speak_default, <@conv_fairy, <@conv_kendrick, <@conv_spider, <@conv_pirate, <@conv_warlock, <@conv_unseely, <@conv_apollonia, <@conv_alyster, <@conv_troll, <@conv_tosh, <@conv_louden, <@conv_mermaid
	.byte <@conv_candywitch, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_banker, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default, <@conv_speak_default
convSpeakHandlerHi:
	.byte >@conv_conductor, >@conv_bartender, >@conv_knight, >@conv_speak_default, >@conv_fairy, >@conv_kendrick, >@conv_spider, >@conv_pirate, >@conv_warlock, >@conv_unseely, >@conv_apollonia, >@conv_alyster, >@conv_troll, >@conv_tosh, >@conv_louden, >@conv_mermaid
	.byte >@conv_candywitch, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_banker, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default, >@conv_speak_default

@conv_kendrick:
	jsr kendrickConversation
	jmp conv_loop

@conv_warlock:
	// For now use default speak
	jmp @conv_speak_default

@conv_candywitch:
	// Use default conversation menu with Candy Witch talk
	jmp @conv_speak_default

@conv_banker:
	jsr bankerConversation
	jmp conv_loop

// Pirate-specific conversation tree. Expects X = npc index.
pirateConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Print header
	lda #<msgPirateMenuHeader
	sta ZP_PTR
	lda #>msgPirateMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Show options
	lda #<msgPirateOpt0
	sta ZP_PTR
	lda #>msgPirateOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt1
	sta ZP_PTR
	lda #>msgPirateOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt2
	sta ZP_PTR
	lda #>msgPirateOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt3
	sta ZP_PTR
	lda #>msgPirateOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt4
	sta ZP_PTR
	lda #>msgPirateOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt5
	sta ZP_PTR
	lda #>msgPirateOpt5
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt6
	sta ZP_PTR
	lda #>msgPirateOpt6
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt7
	sta ZP_PTR
	lda #>msgPirateOpt7
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPirateOpt8
	sta ZP_PTR
	lda #>msgPirateOpt8
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 9. FIGHT
	lda #'9'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @pc_noinput
	sec
	sbc #'0'
	tay
	// indirect jump via table to avoid short-branch distance limits
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda pirateJumpLo,y
	sta ZP_PTR
	lda pirateJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@pc_noinput:
	jmp pirateConversation

	// Jump table: low/high word pairs for pirate choices
	pirateJumpLo:
		.byte <@pc_tale, <@pc_treasure, <@pc_join, <@pc_leave, <@pc_offer, <@pc_stance, <@pc_footwork, <@pc_parry, <@pc_lunge, <@pc_fight
	pirateJumpHi:
		.byte >@pc_tale, >@pc_treasure, >@pc_join, >@pc_leave, >@pc_offer, >@pc_stance, >@pc_footwork, >@pc_parry, >@pc_lunge, >@pc_fight

@pc_tale:
	// Different lines for captain vs first mate
	cpx #NPC_PIRATE_CAPTAIN
	beq @pc_tale_capt
	// First mate
	lda #<msgPirateTaleMate
	sta lastMsgLo
	lda #>msgPirateTaleMate
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_tale_capt:
	lda #<msgPirateTaleCapt
	sta lastMsgLo
	lda #>msgPirateTaleCapt
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_treasure:
	// Start the TREASURE HUNT quest if not already active
	lda activeQuest
	cmp #QUEST_TREASURE
	beq @pc_treasure_already
	lda #QUEST_TREASURE
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #<msgPirateTreasureStart
	sta lastMsgLo
	lda #>msgPirateTreasureStart
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_treasure_already:
	lda #<msgPirateTreasureAlready
	sta lastMsgLo
	lda #>msgPirateTreasureAlready
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_join:
	// set npc stage via conv_apply_effect (effect 6), pass npc index
	txa
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	lda #<msgPirateJoin
	sta lastMsgLo
	lda #>msgPirateJoin
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_offer:
	// Offer treasure: check player's inventory for OBJ_TREASURE
	lda objLoc+OBJ_TREASURE
	cmp #OBJ_INVENTORY
	beq @pc_offer_have
	// No treasure to offer
	lda #<msgPirateNoTreasure
	sta lastMsgLo
	lda #>msgPirateNoTreasure
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_offer_have:
	// If the treasure quest is active, take the treasure and complete quest
	lda activeQuest
	cmp #QUEST_TREASURE
	beq @pc_offer_complete
	// Player has treasure but no relevant quest
	lda #<msgPirateNoQuest
	sta lastMsgLo
	lda #>msgPirateNoQuest
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_offer_complete:
	lda #OBJ_TREASURE
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect	// takeItem
	lda #QUEST_TREASURE
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect	// completeQuest
	lda #<msgPirateOfferYes
	sta lastMsgLo
	lda #>msgPirateOfferYes
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_stance:
	lda #<msgPirateStance
	sta lastMsgLo
	lda #>msgPirateStance
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_footwork:
	lda #<msgPirateFootwork
	sta lastMsgLo
	lda #>msgPirateFootwork
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_parry:
	// Practice: heal +1 HP capped to max and +1 score
	jsr computePlayerMaxHp
	lda playerCurHp
	cmp tmpHp
	bcs @pc_parry_score
	clc
	adc #1
	cmp tmpHp
	bcc @pc_parry_set
	lda tmpHp
@pc_parry_set:
	sta playerCurHp
@pc_parry_score:
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgPirateParry
	sta lastMsgLo
	lda #>msgPirateParry
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_lunge:
	// Practice: heal +1 HP capped to max and +1 score
	jsr computePlayerMaxHp
	lda playerCurHp
	cmp tmpHp
	bcs @pc_lunge_score
	clc
	adc #1
	cmp tmpHp
	bcc @pc_lunge_set
	lda tmpHp
@pc_lunge_set:
	sta playerCurHp
@pc_lunge_score:
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgPirateLunge
	sta lastMsgLo
	lda #>msgPirateLunge
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pirateConversation

@pc_leave:
	rts

@pc_fight:
	jmp combatStartWithNpc

// Bartender-specific conversation tree. Expects X = npc index.
bartenderConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgBartenderMenuHeader
	sta ZP_PTR
	lda #>msgBartenderMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgBartenderOpt0
	sta ZP_PTR
	lda #>msgBartenderOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBartenderOpt1
	sta ZP_PTR
	lda #>msgBartenderOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBartenderOpt2
	sta ZP_PTR
	lda #>msgBartenderOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBartenderOpt3
	sta ZP_PTR
	lda #>msgBartenderOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBartenderOpt4
	sta ZP_PTR
	lda #>msgBartenderOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 5. FIGHT
	lda #'5'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @b_noinput
	sec
	sbc #'0'
	tay
	// indirect jump table to avoid branch distance issues
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda bartenderJumpLo,y
	sta ZP_PTR
	lda bartenderJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@b_noinput:
	jmp bartenderConversation

	bartenderJumpLo:
		.byte <@b_job, <@b_buy, <@b_tip, <@b_quest, <@b_leave, <@b_fight
	bartenderJumpHi:
		.byte >@b_job, >@b_buy, >@b_tip, >@b_quest, >@b_leave, >@b_fight

@b_job:
	// If this is the Trading Company Owner and alpha wolfric quest active, complete it
	cpx #NPC_TRADING_OWNER
	bne @b_job_normal
	lda activeQuest
	cmp #QUEST_ALPHA_WOLFRIC
	bne @b_job_normal
	lda questStatus
	cmp #1
	bne @b_job_normal
	// Complete the Alpha Wolfric quest
	lda #QUEST_ALPHA_WOLFRIC
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect
	lda #<msgTradingOwnerDone
	sta lastMsgLo
	lda #>msgTradingOwnerDone
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

@b_job_normal:
	lda #<msgBartenderJob
	sta lastMsgLo
	lda #>msgBartenderJob
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

@b_buy:
	// If player has silver, take 1 silver and give mug
	lda playerSilver
	beq @b_nocoin
	dec playerSilver
	jsr saveGame
	// give mug
	lda #OBJ_MUG
	sta tmpPer+1
	lda #3
	jsr conv_apply_effect
	lda #<msgBartenderBought
	sta lastMsgLo
	lda #>msgBartenderBought
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

@b_nocoin:
	lda #<msgBartenderNoCoin
	sta lastMsgLo
	lda #>msgBartenderNoCoin
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

@b_fight:
	jmp combatStartWithNpc

@b_tip:
	// Tip: if player has a coin, take it and add 1 silver
	lda objLoc+OBJ_COIN
	cmp #OBJ_INVENTORY
	bne @b_notipcoin
	// take coin
	lda #OBJ_COIN
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// add silver +1
	inc playerSilver
	jsr saveGame
	// check if quest active
	lda activeQuest
	cmp #QUEST_COIN_BARTENDER
	bne @no_quest_complete
	lda #QUEST_COIN_BARTENDER
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect
@no_quest_complete:
	lda #<msgBartenderTipThanks
	sta lastMsgLo
	lda #>msgBartenderTipThanks
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

@b_notipcoin:
	lda #<msgBartenderNoCoin
	sta lastMsgLo
	lda #>msgBartenderNoCoin
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

@b_leave:
	rts

@b_quest:
	// Offer/check quest for this NPC
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq @b_noquest
	lda npcOffersQuest,x
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	// mark this NPC's conversation stage as progressed
	lda #1
	sta npcConvStage,x
	lda #<msgQuestOfferGeneric
	sta lastMsgLo
	lda #>msgQuestOfferGeneric
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

@b_noquest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bartenderConversation

// Banker-specific conversation tree. Expects X = npc index.
bankerConversation:
	jsr clearScreen
	jsr updateExchangeRates
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgBankerMenuHeader
	sta ZP_PTR
	lda #>msgBankerMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgBankerOpt0
	sta ZP_PTR
	lda #>msgBankerOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBankerOpt1
	sta ZP_PTR
	lda #>msgBankerOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBankerOpt2
	sta ZP_PTR
	lda #>msgBankerOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBankerOpt3
	sta ZP_PTR
	lda #>msgBankerOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBankerOpt4
	sta ZP_PTR
	lda #>msgBankerOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 5. FIGHT
	lda #'5'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @bank_noinput
	sec
	sbc #'0'
	tay
	// indirect jump table to avoid branch-distance issues
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda bankerJumpLo,y
	sta ZP_PTR
	lda bankerJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@bank_noinput:
	jmp bankerConversation

	bankerJumpLo:
		.byte <@bank_deposit, <@bank_withdraw, <@bank_balance, <@bank_vault, <@bank_leave, <@bank_fight
	bankerJumpHi:
		.byte >@bank_deposit, >@bank_withdraw, >@bank_balance, <@bank_vault, <@bank_leave, >@bank_fight

@bank_fight:
	jmp combatStartWithNpc

@bank_deposit:
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgDepositMenu
	sta ZP_PTR
	lda #>msgDepositMenu
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgDepositOpt0
	sta ZP_PTR
	lda #>msgDepositOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgDepositOpt1
	sta ZP_PTR
	lda #>msgDepositOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgDepositOpt2
	sta ZP_PTR
	lda #>msgDepositOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgDepositOpt3
	sta ZP_PTR
	lda #>msgDepositOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @deposit_noinput
	sec
	sbc #'0'
	cmp #4
	bcs @deposit_noinput
	tax
	lda depositJumpLo,x
	sta ZP_PTR
	lda depositJumpHi,x
	sta ZP_PTR+1
	jmp (ZP_PTR)
@deposit_noinput:
	jmp bankerConversation
depositJumpLo:
	.byte <@deposit_copper, <@deposit_silver, <@deposit_gold, <@deposit_back
depositJumpHi:
	.byte >@deposit_copper, >@deposit_silver, >@deposit_gold, >@deposit_back
@deposit_copper:
	lda #<msgEnterAmount
	sta ZP_PTR
	lda #>msgEnterAmount
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	bne @deposit_continue
	jmp @deposit_invalid
@deposit_continue:
	cmp playerCopper
	bcc @deposit_ok4
	jmp @deposit_not_enough
@deposit_ok4:
	sta tmpNumber
	sec
	lda playerCopper
	sbc tmpNumber
	sta playerCopper
	clc
	lda bankCopper
	adc tmpNumber
	sta bankCopper
	jsr saveGame
	lda #<msgDepositSuccess
	sta lastMsgLo
	lda #>msgDepositSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@deposit_not_enough:
	lda #<msgNotEnough
	sta lastMsgLo
	lda #>msgNotEnough
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@deposit_invalid:
	lda #<msgInvalidAmount
	sta lastMsgLo
	lda #>msgInvalidAmount
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@deposit_silver:
	lda #<msgEnterAmount
	sta ZP_PTR
	lda #>msgEnterAmount
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	bne @deposit_continue2
	jmp @deposit_invalid
@deposit_continue2:
	cmp playerSilver
	bcc @deposit_ok5
	jmp @deposit_not_enough
@deposit_ok5:
	sta tmpNumber
	sec
	lda playerSilver
	sbc tmpNumber
	sta playerSilver
	clc
	lda bankSilver
	adc tmpNumber
	sta bankSilver
	jsr saveGame
	lda #<msgDepositSuccess
	sta lastMsgLo
	lda #>msgDepositSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@deposit_gold:
	lda #<msgEnterAmount
	sta ZP_PTR
	lda #>msgEnterAmount
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	bne @deposit_continue3
	jmp @deposit_invalid
@deposit_continue3:
	cmp playerGold
	bcc @deposit_ok
	jmp @deposit_not_enough
@deposit_ok:
	sta tmpNumber
	sec
	lda playerGold
	sbc tmpNumber
	sta playerGold
	clc
	lda bankGold
	adc tmpNumber
	sta bankGold
	jsr saveGame
	lda #<msgDepositSuccess
	sta lastMsgLo
	lda #>msgDepositSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@deposit_back:
	jmp bankerConversation

@bank_withdraw:
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgWithdrawMenu
	sta ZP_PTR
	lda #>msgWithdrawMenu
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgWithdrawOpt0
	sta ZP_PTR
	lda #>msgWithdrawOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgWithdrawOpt1
	sta ZP_PTR
	lda #>msgWithdrawOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgWithdrawOpt2
	sta ZP_PTR
	lda #>msgWithdrawOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgWithdrawOpt3
	sta ZP_PTR
	lda #>msgWithdrawOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @withdraw_noinput
	sec
	sbc #'0'
	cmp #4
	bcs @withdraw_noinput
	tax
	lda withdrawJumpLo,x
	sta ZP_PTR
	lda withdrawJumpHi,x
	sta ZP_PTR+1
	jmp (ZP_PTR)
@withdraw_noinput:
	jmp bankerConversation
withdrawJumpLo:
	.byte <@withdraw_copper, <@withdraw_silver, <@withdraw_gold, <@withdraw_back
withdrawJumpHi:
	.byte >@withdraw_copper, >@withdraw_silver, >@withdraw_gold, >@withdraw_back
@withdraw_copper:
	lda #<msgEnterAmount
	sta ZP_PTR
	lda #>msgEnterAmount
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	bne @withdraw_continue2
	jmp @withdraw_invalid
@withdraw_continue2:
	cmp bankCopper
	bcc @withdraw_ok3
	jmp @withdraw_not_enough
@withdraw_ok3:
	sta tmpNumber
	sec
	lda bankCopper
	sbc tmpNumber
	sta bankCopper
	clc
	lda playerCopper
	adc tmpNumber
	sta playerCopper
	jsr saveGame
	lda #<msgWithdrawSuccess
	sta lastMsgLo
	lda #>msgWithdrawSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@withdraw_not_enough:
	lda #<msgBankNotEnough
	sta lastMsgLo
	lda #>msgBankNotEnough
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@withdraw_invalid:
	lda #<msgInvalidAmount
	sta lastMsgLo
	lda #>msgInvalidAmount
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@withdraw_silver:
	// Apply interest first
	lda bankSilver
	lsr
	lsr
	lsr
	lsr
	sta tmpNumber
	lsr tmpNumber
	clc
	lda bankSilver
	adc tmpNumber
	sta bankSilver
	lda #<msgEnterAmount
	sta ZP_PTR
	lda #>msgEnterAmount
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	bne @withdraw_continue3
	jmp @withdraw_invalid
@withdraw_continue3:
	cmp bankSilver
	bcc @withdraw_ok2
	jmp @withdraw_not_enough
@withdraw_ok2:
	sta tmpNumber
	sec
	lda bankSilver
	sbc tmpNumber
	sta bankSilver
	clc
	lda playerSilver
	adc tmpNumber
	sta playerSilver
	jsr saveGame
	lda #<msgWithdrawSuccess
	sta lastMsgLo
	lda #>msgWithdrawSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@withdraw_gold:
	lda #<msgEnterAmount
	sta ZP_PTR
	lda #>msgEnterAmount
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	bne @withdraw_continue
	jmp @withdraw_invalid
@withdraw_continue:
	cmp bankGold
	bcc @withdraw_ok
	jmp @withdraw_not_enough
@withdraw_ok:
	sta tmpNumber
	sec
	lda bankGold
	sbc tmpNumber
	sta bankGold
	clc
	lda playerGold
	adc tmpNumber
	sta playerGold
	jsr saveGame
	lda #<msgWithdrawSuccess
	sta lastMsgLo
	lda #>msgWithdrawSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@withdraw_back:
	jmp bankerConversation

@bank_balance:
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgBalance
	sta ZP_PTR
	lda #>msgBalance
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgCopper
	sta ZP_PTR
	lda #>msgCopper
	sta ZP_PTR+1
	jsr printZ
	lda bankCopper
	jsr printDecimal
	jsr newline
	lda #<msgSilver
	sta ZP_PTR
	lda #>msgSilver
	sta ZP_PTR+1
	jsr printZ
	lda bankSilver
	jsr printDecimal
	jsr newline
	lda #<msgGold
	sta ZP_PTR
	lda #>msgGold
	sta ZP_PTR+1
	jsr printZ
	lda bankGold
	jsr printDecimal
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation

@bank_vault:
	lda vaultRented
	bne @access_vault
	jmp @rent_vault
@access_vault:
	// access vault
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgVaultAccess
	sta ZP_PTR
	lda #>msgVaultAccess
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgStoreItemOpt
	sta ZP_PTR
	lda #>msgStoreItemOpt
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgRetrieveItemOpt
	sta ZP_PTR
	lda #>msgRetrieveItemOpt
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgBackOpt
	sta ZP_PTR
	lda #>msgBackOpt
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @vault_noinput
	sec
	sbc #'0'
	cmp #3
	bcs @vault_noinput
	tax
	lda vaultJumpLo,x
	sta ZP_PTR
	lda vaultJumpHi,x
	sta ZP_PTR+1
	jmp (ZP_PTR)
@vault_noinput:
	jmp bankerConversation
vaultJumpLo:
	.byte <@store_item, <@retrieve_item, <@vault_back
vaultJumpHi:
	.byte >@store_item, >@retrieve_item, >@vault_back

@bank_leave:
	rts

@store_item:
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgStoreItem
	sta ZP_PTR
	lda #>msgStoreItem
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	ldx #0
	stx tmpCnt
@store_loop:
	lda objLoc,x
	cmp #OBJ_INVENTORY
	bne @store_next
	txa
	pha
	lda tmpCnt
	jsr printDecimal
	lda #'.'
	jsr printChar
	lda #' '
	jsr printChar
	pla
	tax
	lda objNameLo,x
	sta ZP_PTR
	lda objNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	inc tmpCnt
@store_next:
	inx
	cpx #OBJ_COUNT
	bne @store_loop
	lda tmpCnt
	bne @no_store
	jmp @no_items_store
@no_store:
	lda tmpCnt
	jsr printDecimal
	lda #'.'
	jsr printChar
	lda #' '
	jsr printChar
	lda #<msgBackOpt
	sta ZP_PTR
	lda #>msgBackOpt
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	cmp tmpCnt
	bcs @store_invalid
	ldx #0
	stx tmpCnt
@find_item_loop:
	lda objLoc,x
	cmp #OBJ_INVENTORY
	bne @find_next
	lda tmpCnt
	cmp tmpNumber
	beq @found_item
	inc tmpCnt
@find_next:
	inx
	cpx #OBJ_COUNT
	bne @find_item_loop
@store_invalid:
	lda #<msgInvalidAmount
	sta lastMsgLo
	lda #>msgInvalidAmount
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@found_item:
	ldy #0
@find_vault_slot:
	lda vaultItems,y
	cmp #$FF
	beq @free_slot
	iny
	cpy #10
	bne @find_vault_slot
	lda #<msgVaultFull
	sta lastMsgLo
	lda #>msgVaultFull
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@free_slot:
	txa
	sta vaultItems,y
	lda #$FF
	sta objLoc,x
	jsr saveGame
	lda #<msgDepositSuccess
	sta lastMsgLo
	lda #>msgDepositSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@no_items_store:
	lda #<msgNoItems
	sta lastMsgLo
	lda #>msgNoItems
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation

@retrieve_item:
	jsr clearScreen
	ldx tmpNpcIdx
	lda #<msgRetrieveItem
	sta ZP_PTR
	lda #>msgRetrieveItem
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	ldx #0
	stx tmpCnt
@retrieve_loop:
	lda vaultItems,x
	cmp #$FF
	beq @retrieve_next
	txa
	pha
	lda tmpCnt
	jsr printDecimal
	lda #'.'
	jsr printChar
	lda #' '
	jsr printChar
	pla
	tax
	lda vaultItems,x
	tay
	lda objNameLo,y
	sta ZP_PTR
	lda objNameHi,y
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	inc tmpCnt
@retrieve_next:
	inx
	cpx #10
	bne @retrieve_loop
	lda tmpCnt
	bne @no_retrieve
	jmp @no_items_retrieve
@no_retrieve:
	lda tmpCnt
	jsr printDecimal
	lda #'.'
	jsr printChar
	lda #' '
	jsr printChar
	lda #<msgBackOpt
	sta ZP_PTR
	lda #>msgBackOpt
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	cmp tmpCnt
	bcs @retrieve_invalid
	ldx #0
	stx tmpCnt
@find_vault_item_loop:
	lda vaultItems,x
	cmp #$FF
	beq @find_vault_next
	lda tmpCnt
	cmp tmpNumber
	beq @found_vault_item
	inc tmpCnt
@find_vault_next:
	inx
	cpx #10
	bne @find_vault_item_loop
@retrieve_invalid:
	lda #<msgInvalidAmount
	sta lastMsgLo
	lda #>msgInvalidAmount
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@found_vault_item:
	lda vaultItems,x
	tay
	lda #OBJ_INVENTORY
	sta objLoc,y
	lda #$FF
	sta vaultItems,x
	jsr saveGame
	lda #<msgWithdrawSuccess
	sta lastMsgLo
	lda #>msgWithdrawSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@no_items_retrieve:
	lda #<msgNoItems
	sta lastMsgLo
	lda #>msgNoItems
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation

@vault_back:
	jmp bankerConversation

@rent_vault:
	lda playerSilver
	cmp #10
	bcc @vault_no_silver
	sec
	sbc #10
	sta playerSilver
	lda #1
	sta vaultRented
	jsr saveGame
	lda #<msgVaultRentSuccess
	sta lastMsgLo
	lda #>msgVaultRentSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation
@vault_no_silver:
	lda #<msgVaultNoSilver
	sta lastMsgLo
	lda #>msgVaultNoSilver
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp bankerConversation

// Conductor-specific conversation tree. Expects X = npc index.
conductorConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	// Header
	lda #<msgConductorMenuHeader
	sta ZP_PTR
	lda #>msgConductorMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// Options
	lda #<msgConductorOpt0
	sta ZP_PTR
	lda #>msgConductorOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgConductorOpt1
	sta ZP_PTR
	lda #>msgConductorOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgConductorOpt2
	sta ZP_PTR
	lda #>msgConductorOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgConductorOpt3
	sta ZP_PTR
	lda #>msgConductorOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgConductorOpt4
	sta ZP_PTR
	lda #>msgConductorOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 5. FIGHT
	lda #'5'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @c_noinput
	sec
	sbc #'0'
	tay
	// indirect jump table to avoid branch-distance issues
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda conductorJumpLo,y
	sta ZP_PTR
	lda conductorJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@c_noinput:
	jmp conductorConversation

	conductorJumpLo:
		.byte <@c_about, <@c_tune, <@c_join, <@c_quest, <@c_leave, <@c_fight
	conductorJumpHi:
		.byte >@c_about, >@c_tune, >@c_join, >@c_quest, >@c_leave, >@c_fight

@c_about:
	lda #<msgConductorAbout
	sta lastMsgLo
	lda #>msgConductorAbout
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp conductorConversation

@c_tune:
	// Play a short tune: reward player with +2 score
	lda #2
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgConductorTune
	sta lastMsgLo
	lda #>msgConductorTune
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp conductorConversation

@c_join:
	// Player may join conductor's ensemble (set npc stage)
	txa
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	lda #<msgConductorJoin
	sta lastMsgLo
	lda #>msgConductorJoin
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp conductorConversation

@c_quest:
	// Offer/check quest for this NPC
	// Conductor: always start coin quest and grant a starter coin
	txa
	cmp #NPC_CONDUCTOR
	bne @c_quest_generic
	lda #QUEST_COIN_BARTENDER
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect      // startQuest -> activeQuest=coin, questStatus=1
	lda #1
	sta npcConvStage,x
	jmp @c_maybe_coin
@c_quest_generic:
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq @c_noquest
	lda npcOffersQuest,x
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #1
	sta npcConvStage,x
@c_quest_have:
	// fallthrough handled above
@c_maybe_coin:
	// If this is the Conductor and the active quest is coin->bartender, give a starter coin
	txa
	cmp #NPC_CONDUCTOR
	bne @c_nooffermsg
	lda activeQuest
	cmp #QUEST_COIN_BARTENDER
	bne @c_nooffermsg
	lda #OBJ_COIN
	sta tmpPer+1
	lda #3
	jsr conv_apply_effect
	// Show explicit confirmation that the player received a coin
	lda #<msgCoinRec
	sta lastMsgLo
	lda #>msgCoinRec
	sta lastMsgHi
	jsr render
	// fall through to show the quest offer message (override msg from give)

@c_nooffermsg:
	lda #<msgQuestOfferGeneric
	sta lastMsgLo
	lda #>msgQuestOfferGeneric
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp conductorConversation

@c_noquest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp conductorConversation

@c_leave:
	rts

@c_fight:
	jmp combatStartWithNpc

// Knight-specific conversation tree. Expects X = npc index.
knightConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	lda #<msgKnightMenuHeader
	sta ZP_PTR
	lda #>msgKnightMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt0
	sta ZP_PTR
	lda #>msgKnightOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt1
	sta ZP_PTR
	lda #>msgKnightOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt2
	sta ZP_PTR
	lda #>msgKnightOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt3
	sta ZP_PTR
	lda #>msgKnightOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt4
	sta ZP_PTR
	lda #>msgKnightOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt5
	sta ZP_PTR
	lda #>msgKnightOpt5
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt6
	sta ZP_PTR
	lda #>msgKnightOpt6
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKnightOpt7
	sta ZP_PTR
	lda #>msgKnightOpt7
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 8. FIGHT
	lda #'8'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @k_noinput
	sec
	sbc #'0'
	tay
	tya
	// indirect jump table
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda knightJumpLo,y
	sta ZP_PTR
	lda knightJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@k_noinput:
	jmp knightConversation

@k_about:
	lda #<msgKnightAbout
	sta lastMsgLo
	lda #>msgKnightAbout
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_offer:
	// Offer: if player has key and active quest is QUEST_KEY_KNIGHT, take key and complete quest
	lda objLoc+OBJ_KEY
	cmp #OBJ_INVENTORY
	bne @k_nokey
	lda activeQuest
	cmp #QUEST_KEY_KNIGHT
	bne @k_noquest
	// take key
	lda #OBJ_KEY
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// complete quest
	lda #QUEST_KEY_KNIGHT
	sta tmpPer+1
	lda #2
	jsr conv_apply_effect
	lda #<msgKnightThanks
	sta lastMsgLo
	lda #>msgKnightThanks
	sta lastMsgHi
	jsr render
	jmp knightConversation

@k_nokey:
	lda #<msgKnightNoKey
	sta lastMsgLo
	lda #>msgKnightNoKey
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_noquest:
	lda #<msgKnightNoQuest
	sta lastMsgLo
	lda #>msgKnightNoQuest
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_leave:
	rts

@k_fight:
	jmp combatStartWithNpc

// Kendrick-specific conversation tree. Expects X = npc index.
kendrickConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	lda #<msgKendrickMenuHeader
	sta ZP_PTR
	lda #>msgKendrickMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKendrickOpt0
	sta ZP_PTR
	lda #>msgKendrickOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKendrickOpt1
	sta ZP_PTR
	lda #>msgKendrickOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKendrickOpt2
	sta ZP_PTR
	lda #>msgKendrickOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKendrickOpt3
	sta ZP_PTR
	lda #>msgKendrickOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgKendrickOpt4
	sta ZP_PTR
	lda #>msgKendrickOpt4
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 5. FIGHT
	lda #'5'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @knd_noinput
	sec
	sbc #'0'
	tay
	tya
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda kendrickJumpLo,y
	sta ZP_PTR
	lda kendrickJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@knd_noinput:
	jmp kendrickConversation

@knd_about:
	lda #<msgKendrickAbout
	sta lastMsgLo
	lda #>msgKendrickAbout
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp kendrickConversation

@knd_spider:
	lda #<msgSpiderWhisper
	sta lastMsgLo
	lda #>msgSpiderWhisper
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp kendrickConversation

@knd_request:
	// start Kendrick's scotch quest if available
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq @knd_noquest
	lda npcOffersQuest,x
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #1
	sta npcConvStage,x
	lda #<msgKendrickOfferStart
	sta lastMsgLo
	lda #>msgKendrickOfferStart
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp kendrickConversation

@knd_noquest:
	lda #<msgKendrickOfferAlready
	sta lastMsgLo
	lda #>msgKendrickOfferAlready
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp kendrickConversation

@knd_give:
	// Handled by generic GIVE path; just return
	rts

@knd_leave:
	rts

kendrickJumpLo:
	.byte <@knd_about,<@knd_spider,<@knd_request,<@knd_give,<@knd_leave,<@knd_fight
kendrickJumpHi:
	.byte >@knd_about,>@knd_spider,>@knd_request,>@knd_give,>@knd_leave,>@knd_fight

@knd_fight:
	jmp combatStartWithNpc

@k_guard:
	lda #<msgKnightGuard
	sta lastMsgLo
	lda #>msgKnightGuard
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_footwork:
	lda #<msgKnightFootwork
	sta lastMsgLo
	lda #>msgKnightFootwork
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_parry:
	// Arena drill: heal +1 HP capped to max and +1 score
	jsr computePlayerMaxHp
	lda playerCurHp
	cmp tmpHp
	bcs @k_parry_score
	clc
	adc #1
	cmp tmpHp
	bcc @k_parry_set
	lda tmpHp
@k_parry_set:
	sta playerCurHp
@k_parry_score:
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgKnightParry
	sta lastMsgLo
	lda #>msgKnightParry
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_lunge:
	// Arena drill: heal +1 HP capped to max and +1 score
	jsr computePlayerMaxHp
	lda playerCurHp
	cmp tmpHp
	bcs @k_lunge_score
	clc
	adc #1
	cmp tmpHp
	bcc @k_lunge_set
	lda tmpHp
@k_lunge_set:
	sta playerCurHp
@k_lunge_score:
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgKnightLunge
	sta lastMsgLo
	lda #>msgKnightLunge
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_join:
	// Start the Order of the Black Rose quest if available
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq @k_join_noquest
	lda npcOffersQuest,x
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #<msgKnightThanks
	sta lastMsgLo
	lda #>msgKnightThanks
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp knightConversation

@k_join_noquest:
	jmp @k_noquest

knightJumpLo:
	.byte <@k_about,<@k_offer,<@k_join,<@k_leave,<@k_guard,<@k_footwork,<@k_parry,<@k_lunge,<@k_fight
knightJumpHi:
	.byte >@k_about,>@k_offer,>@k_join,>@k_leave,>@k_guard,>@k_footwork,>@k_parry,>@k_lunge,>@k_fight

// Fairy-specific conversation tree. Expects X = npc index.
fairyConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	lda #<msgFairyMenuHeader
	sta ZP_PTR
	lda #>msgFairyMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgFairyOpt0
	sta ZP_PTR
	lda #>msgFairyOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgFairyOpt1
	sta ZP_PTR
	lda #>msgFairyOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgFairyOpt2
	sta ZP_PTR
	lda #>msgFairyOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgFairyOpt3
	sta ZP_PTR
	lda #>msgFairyOpt3
	sta ZP_PTR+1
	jsr printZ
	jsr newline
 	// 4. FIGHT
	lda #'4'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @f_noinput
	sec
	sbc #'0'
	tay
	tya
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda fairyJumpLo,y
	sta ZP_PTR
	lda fairyJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@f_noinput:
	jmp fairyConversation

@f_bless:
	// add score +1
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgFairyBless
	sta lastMsgLo
	lda #>msgFairyBless
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp fairyConversation

@f_coin:
	// give a coin
	lda #OBJ_COIN
	sta tmpPer+1
	lda #3
	jsr conv_apply_effect
	lda #<msgFairyGive
	sta lastMsgLo
	lda #>msgFairyGive
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp fairyConversation

@f_trade:
	// Trade: if player has a coin, take coin and give stolen name
	lda objLoc+OBJ_COIN
	cmp #OBJ_INVENTORY
	bne @f_nocoin
	// take coin
	lda #OBJ_COIN
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// give stolen name
	lda #OBJ_STOLEN_NAME
	sta tmpPer+1
	lda #3
	jsr conv_apply_effect
	lda #<msgFairyTradeSuccess
	sta lastMsgLo
	lda #>msgFairyTradeSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp fairyConversation

@f_nocoin:
	lda #<msgBartenderNoCoin
	sta lastMsgLo
	lda #>msgBartenderNoCoin
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp fairyConversation

@f_leave:
	rts

fairyJumpLo:
	.byte <@f_bless,<@f_coin,<@f_trade,<@f_leave,<@f_fight
fairyJumpHi:
	.byte >@f_bless,>@f_coin,>@f_trade,>@f_leave,>@f_fight

@f_fight:
	jmp combatStartWithNpc

// Pixie-specific conversation tree. Expects X = npc index.
pixieConversation:
	jsr clearScreen
	// restore npc index in X for indexed lookups
	ldx tmpNpcIdx
	lda #<msgPixieMenuHeader
	sta ZP_PTR
	lda #>msgPixieMenuHeader
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPixieOpt0
	sta ZP_PTR
	lda #>msgPixieOpt0
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPixieOpt1
	sta ZP_PTR
	lda #>msgPixieOpt1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgPixieOpt2
	sta ZP_PTR
	lda #>msgPixieOpt2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	// 3. FIGHT
	lda #'3'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda #<strFightOption
	sta ZP_PTR
	lda #>strFightOption
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @p_noinput
	sec
	sbc #'0'
	tay
	tya
	// ensure X = npc index before jumping to handlers
	ldx tmpNpcIdx
	lda pixieJumpLo,y
	sta ZP_PTR
	lda pixieJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@p_noinput:
	jmp pixieConversation

@p_trick:
	// If the player has a lantern, pixie steals it (takeItem)
	lda objLoc+OBJ_LANTERN
	cmp #OBJ_INVENTORY
	bne @p_notlan
	lda #OBJ_LANTERN
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	lda #<msgPixieStole
	sta lastMsgLo
	lda #>msgPixieStole
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pixieConversation

@p_notlan:
	lda #<msgPixieNoLan
	sta lastMsgLo
	lda #>msgPixieNoLan
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	.byte <@p_trick,<@p_play,<@p_leave,<@p_fight
	jmp pixieConversation
	.byte >@p_trick,>@p_play,>@p_leave,>@p_fight

@p_fight:
	jmp combatStartWithNpc
@p_play:
	// Pixie's play: add score +1 and advance pixie stage
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	txa
	sta tmpPer+1
	lda #6
	jsr conv_apply_effect
	lda #<msgPixiePlay
	sta lastMsgLo
	lda #>msgPixiePlay
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp pixieConversation

@p_leave:
	rts

pixieJumpLo:
	.byte <@p_trick,<@p_play,<@p_leave
pixieJumpHi:
	.byte >@p_trick,>@p_play,>@p_leave

@conv_do_weather:
	lda #<msgAskWeather
	sta lastMsgLo
	lda #>msgAskWeather
	sta lastMsgHi
	jsr render
	// Check per-choice effect (choice1)
	lda convChoiceType_choice1,x
	beq @conv_weather_noeff
	lda convChoiceVal_choice1,x
	sta tmpPer+1
	lda convChoiceType_choice1,x
	jsr conv_apply_effect
@conv_weather_noeff:
	jmp conv_loop

@conv_do_temp:
	lda #<msgTempResponse
	sta lastMsgLo
	lda #>msgTempResponse
	sta lastMsgHi
	jsr render
	// Check per-choice effect (choice2)
	lda convChoiceType_choice2,x
	beq @conv_temp_noeff
	lda convChoiceVal_choice2,x
	sta tmpPer+1
	lda convChoiceType_choice2,x
	jsr conv_apply_effect
@conv_temp_noeff:
	jmp conv_loop

@conv_do_quest:
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	bne @conv_do_quest_continue
	jmp @conv_noquest
@conv_do_quest_continue:
	// start quest via conv_apply_effect: A=1 (startQuest), tmpPer+1=quest id
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	// mark this NPC's conversation stage as progressed
	lda #1
	sta npcConvStage,x
	// Spider Princess has a custom offer message
	cpx #NPC_SPIDER_PRINCESS
	bne @conv_do_quest_chk_spider
	jmp @cq_spider
@conv_do_quest_chk_spider:
	// Warlock: give the ward and show a custom offer
	cpx #NPC_WARLOCK
	bne @conv_do_quest_chk_warlock
	jmp @cq_warlock
@conv_do_quest_chk_warlock:
	// Candy Witch: custom offer message
	cpx #NPC_CANDY_WITCH
	bne @conv_do_quest_chk_candy
	jmp @cq_candywitch
@conv_do_quest_chk_candy:
	cpx #NPC_ALYSTER
	bne @conv_do_quest_chk_alyster
	jmp @cq_alyster
@conv_do_quest_chk_alyster:
	lda #<msgQuestOfferGeneric
	sta lastMsgLo
	lda #>msgQuestOfferGeneric
	sta lastMsgHi
	jmp @cq_render

@cq_spider:
	lda #<msgSpiderQuestOffer
	sta lastMsgLo
	lda #>msgSpiderQuestOffer
	sta lastMsgHi

@cq_warlock:
	lda #OBJ_INVENTORY
	sta objLoc+OBJ_WARD
	lda #<msgWarlockQuestOffer
	sta lastMsgLo
	lda #>msgWarlockQuestOffer
	sta lastMsgHi

	// Kora: custom offer instructing the jape
	cpx #NPC_KORA
	bne @cq_candywitch
	lda #<msgKoraQuestOffer
	sta lastMsgLo
	lda #>msgKoraQuestOffer
	sta lastMsgHi

@cq_alyster:
	lda #<msgAlysterOathOffer
	sta lastMsgLo
	lda #>msgAlysterOathOffer
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @cq_alyster_noinput
	// Accept on Y, y
	cmp #'Y'
	beq @cq_alyster_accept
	cmp #'y'
	beq @cq_alyster_accept
	// Refuse otherwise
	jmp @cq_alyster_refuse

@cq_alyster_noinput:
	jmp conv_loop

@cq_alyster_accept:
	lda #1
	sta playerGuildMember
	lda #<msgAlysterOathAccepted
	sta lastMsgLo
	lda #>msgAlysterOathAccepted
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp conv_loop

@cq_alyster_refuse:
	lda #<msgAlysterOathRefused
	sta lastMsgLo
	lda #>msgAlysterOathRefused
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	jmp conv_loop

@cq_candywitch:
	lda #<msgCandyWitchQuestOffer
	sta lastMsgLo
	lda #>msgCandyWitchQuestOffer
	sta lastMsgHi

@cq_render:
	jsr render
	jmp conv_loop

@conv_noquest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jmp conv_loop

@conv_do_qinfo:
	lda activeQuest
	cmp #QUEST_NONE
	beq @conv_noactive
	tax
	lda questDetailLo,x
	sta lastMsgLo
	lda questDetailHi,x
	sta lastMsgHi
	jsr render
	// Check per-choice effect (choice4)
	lda convChoiceType_choice4,x
	beq @conv_qinfo_noeff
	lda convChoiceVal_choice4,x
	sta tmpPer+1
	lda convChoiceType_choice4,x
	jsr conv_apply_effect
@conv_qinfo_noeff:
	jmp conv_loop

@conv_do_trade:
	jsr tradeTrinkets
	jmp conv_loop

@conv_noactive:
	lda #<msgNoQuest
	sta lastMsgLo
	lda #>msgNoQuest
	sta lastMsgHi
	jsr render
	jmp conv_loop

conversationMenu_exit:
	// clear conversation flag and return
	lda #0
	sta uiInConversation
	rts

cmdInspect:
	// If noun present, inspect object// else re-describe location
	// Find first space after verb
	ldx #0
@findSpace:
	lda inputBuf,x
	beq @noNoun
	cmp #' '
	beq @noun
	inx
	bne @findSpace

@noun:
	jsr parseObjectNoun
	bcs @obj
	jsr parseSceneryNoun
	bcs @scn
	jmp @noNoun

@obj:
	tax
	lda objInspectLo,x
	sta lastMsgLo
	lda objInspectHi,x
	sta lastMsgHi
	rts

@scn:
	// sceneryId in A
	cmp #0
	beq @stall
	cmp #1
	beq @insp_sign
	// else 2=PORTAL
	jmp @insp_portal

@stall:
	lda currentLoc
	cmp #LOC_MARKET
	bne @scnNo
	lda #<msgStall
	sta lastMsgLo
	lda #>msgStall
	sta lastMsgHi
	rts

@insp_sign:
	lda currentLoc
	cmp #LOC_TRAIN
	bne @scnNo
	lda #<msgSign
	sta lastMsgLo
	lda #>msgSign
	sta lastMsgHi
	rts

@insp_portal:
	lda currentLoc
	cmp #LOC_PORTAL
	bne @scnNo
	lda #<msgPortal
	sta lastMsgLo
	lda #>msgPortal
	sta lastMsgHi
	rts
@scnNo:
	lda #<msgNotHere
	sta lastMsgLo
	lda #>msgNotHere
	sta lastMsgHi
	rts

@noNoun:
	lda #<msgLook
	sta lastMsgLo
	lda #>msgLook
	sta lastMsgHi
	rts

cmdPickUp:
	// Handle "PICK UP <obj>"// if no UP, treat as TAKE
	ldx #0
	// Find first space
@p1:
	lda inputBuf,x
	beq cmdTake
	cmp #' '
	beq @afterPick
	inx
	bne @p1
@afterPick:
	jsr skipSpaces
	// Must be UP
	txa
	pha
	lda #<kwUp
	sta ZP_PTR2
	lda #>kwUp
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmdTake
	// Advance past UP
	inx
	inx
	jsr cmdTakeFromX
	rts

cmdTake:
	ldx #0
	// Find first space after verb
@t1:
	lda inputBuf,x
	beq @take_need
	cmp #' '
	beq @take_after
	inx
	bne @t1

@take_after:
	jsr cmdTakeFromX
	rts

@take_need:
	lda #<msgTakeWhat
	sta lastMsgLo
	lda #>msgTakeWhat
	sta lastMsgHi
	rts

cmdTakeFromX:
	jsr parseObjectNoun
	bcc @tfx_bad
	tax
	lda objLoc,x
	cmp currentLoc
	bne @tfx_notHere
	// Special: buying SCOTCH at the tavern requires a coin
	txa
	cmp #OBJ_SCOTCH
	bne @tfx_normal_take
	// We're trying to take the scotch; ensure we're in the tavern
	lda currentLoc
	cmp #LOC_TAVERN
	beq @tfx_scotch_tavern_check
	jmp @tfx_normal_take

@tfx_scotch_tavern_check:
	// Check if player has a coin in inventory
	lda objLoc+OBJ_COIN
	cmp #OBJ_INVENTORY
	beq @tfx_scotch_buy
	// no coin
	lda #<msgNeedCoinForScotch
	sta lastMsgLo
	lda #>msgNeedCoinForScotch
	sta lastMsgHi
	jsr render
	rts

@tfx_scotch_buy:
	// consume coin
	lda #OBJ_NOWHERE
	sta objLoc+OBJ_COIN
	lda #<msgBoughtScotch
	sta lastMsgLo
	lda #>msgBoughtScotch
	sta lastMsgHi
	jsr saveGame
	// fall through to normal take

@tfx_normal_take:
	lda #OBJ_INVENTORY
	sta objLoc,x
	lda #<msgTook
	sta lastMsgLo
	lda #>msgTook
	sta lastMsgHi
	jsr saveGame
	rts

@tfx_notHere:
	lda #<msgNotHere
	sta lastMsgLo
	lda #>msgNotHere
	sta lastMsgHi
	rts

@tfx_bad:
	lda #<msgDontKnow
	sta lastMsgLo
	lda #>msgDontKnow
	sta lastMsgHi
	rts

cmdSetDown:
	// Handle "SET DOWN <obj>"// else DROP
	ldx #0
@s1:
	lda inputBuf,x
	beq cmdDrop
	cmp #' '
	beq @afterSet
	inx
	bne @s1
@afterSet:
	jsr skipSpaces
	txa
	pha
	lda #<kwDown
	sta ZP_PTR2
	lda #>kwDown
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmdDrop
	// Advance past DOWN
	inx
	inx
	inx
	inx
	jsr cmdDropFromX
	rts

cmdDrop:
	ldx #0
@d1:
	lda inputBuf,x
	beq @drop_need
	cmp #' '
	beq @drop_after
	inx
	bne @d1

@drop_after:
	jsr cmdDropFromX
	rts

@drop_need:
	lda #<msgDropWhat
	sta lastMsgLo
	lda #>msgDropWhat
	sta lastMsgHi
	rts

cmdDropFromX:
	jsr parseObjectNoun
	bcc @dfx_bad
	tax
	lda objLoc,x
	cmp #OBJ_INVENTORY
	bne @dfx_notHave
	lda currentLoc
	sta objLoc,x
	lda #<msgDropped
	sta lastMsgLo
	lda #>msgDropped
	sta lastMsgHi
	jsr saveGame
	jsr questCheckDrop
	rts

@dfx_notHave:
	lda #<msgNotCarrying
	sta lastMsgLo
	lda #>msgNotCarrying
	sta lastMsgHi
	rts

@dfx_bad:
	lda #<msgDontKnow
	sta lastMsgLo
	lda #>msgDontKnow
	sta lastMsgHi
	rts

cmdGive:
	// GIVE <obj> [TO <npc>]
	ldx #0
@g1:
	lda inputBuf,x
	bne @g1_cont
	jmp @give_need

@g1_cont:
	cmp #' '
	beq @give_after
	inx
	bne @g1

@give_after:
	jsr parseObjectNoun
	bcs @give_objParsed
	jmp @give_bad

@give_objParsed:
	sta ZP_PTR2 // temp objId
	tax
	lda objLoc,x
	cmp #OBJ_INVENTORY
	beq @give_haveIt
	jmp @give_notHave

@give_haveIt:

	// Find optional target NPC
	// Advance X to end of object word
	ldx #0
@scanObj:
	lda inputBuf,x
	bne @scan_has_input
	jmp @noTarget
@scan_has_input:
	cmp #' '
	beq @afterObj
	inx
	bne @scanObj
@afterObj:
	// skip verb
	// find first space after GIVE
	ldx #0
@skipVerb:
	lda inputBuf,x
	bne @give_sv_cont
	jmp @noTarget

@give_sv_cont:
	cmp #' '
	beq @verbDone
	inx
	bne @skipVerb
@verbDone:
	// move to noun start
	jsr skipFillers
	// skip noun word itself
@skipNounWord:
	lda inputBuf,x
	bne @give_snw_cont
	jmp @noTarget

@give_snw_cont:
	cmp #' '
	beq @afterNoun
	inx
	bne @skipNounWord
@afterNoun:
	jsr parseNpcNoun
	bcs @give_haveNpc
	jmp @noTarget

@give_haveNpc:
	sta ZP_PTR2+1 // temp npcId
	tax
	ldy currentLoc
	lda npcMaskByLocLo,y
		lda npcMaskByLocB2,y
		sta npcMaskB2Temp
		lda npcMaskByLocB3,y
		sta npcMaskB3Temp
	sta ZP_PTR2
	lda npcMaskByLocHi,y
	sta npcMaskHiTemp
	lda ZP_PTR2
	and npcBitLo,x
		bne @give_npcHere
		lda npcMaskB2Temp
		and npcBitB2,x
		bne @give_npcHere
		lda npcMaskB3Temp
		and npcBitB3,x
	lda npcMaskHiTemp
	and npcBitHi,x
	bne @give_npcHere
	jmp @npcNotHere

@give_npcHere:
	// consume item
	ldx ZP_PTR2
	lda #OBJ_NOWHERE
	sta objLoc,x
	// Quest check for targeted give
	jsr questCheckGive
	bcs @ret
	lda #<msgGave
	sta lastMsgLo
	lda #>msgGave
	sta lastMsgHi
    jsr saveGame
@ret:
	rts

@noTarget:
	// If no explicit target, require someone here
	ldy currentLoc
	lda npcMaskByLocLo,y
	ora npcMaskByLocHi,y
	ora npcMaskByLocB2,y
	ora npcMaskByLocB3,y
	bne @give_nt_someone
	jmp @noone

@give_nt_someone:
	lda #$FF
	sta ZP_PTR2+1
	ldx ZP_PTR2
	lda #OBJ_NOWHERE
	sta objLoc,x
	jsr questCheckGive
	bcc @give_nt_afterQuest
	jmp @ret2

@give_nt_afterQuest:
	lda #<msgGave
	sta lastMsgLo
	lda #>msgGave
	sta lastMsgHi
    jsr saveGame
@ret2:
	rts

// Quest hook for GIVE.
// Inputs:
//  ZP_PTR2 = objId
//  ZP_PTR2+1 = npcId or $FF (use default npc for location)
// Returns C=1 if quest completed (lastMsg set)
questCheckGive:
	// must have an active quest
	lda questStatus
	cmp #1
	beq @qcg_active
	clc
	rts
@qcg_active:
	lda activeQuest
	cmp #QUEST_NONE
	bne @qcg_haveQuest
	clc
	rts
@qcg_haveQuest:
	// ensure npcId present
	lda ZP_PTR2+1
	cmp #$FF
	bne @qcg_haveNpc
	ldx currentLoc
	lda npcDefaultByLoc,x
	sta ZP_PTR2+1
@qcg_haveNpc:
	// dispatch to per-quest give checks
	ldy activeQuest
	lda questGiveCheckLo,y
	sta ZP_PTR
	lda questGiveCheckHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

// Per-quest GIVE check routines
@qcg_bartender:
	lda ZP_PTR2
	cmp #OBJ_COIN
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_BARTENDER
	bne @qcg_no
	lda playerSilver
	beq @qcg_no
	dec playerSilver
	jsr questComplete
	sec
	rts

@qcg_knight:
	lda ZP_PTR2
	cmp #OBJ_KEY
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_KNIGHT
	bne @qcg_no
	jsr questComplete
	sec
	rts

@qcg_mystic:
	lda ZP_PTR2
	cmp #OBJ_LANTERN
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_MYSTIC
	bne @qcg_no
	jsr questComplete
	sec
	rts

@qcg_kendrick:
	// Kendrick: giving SCOTCH to Kendrick completes his quest
	lda ZP_PTR2
	cmp #OBJ_SCOTCH
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_KENDRICK
	bne @qcg_no
	jsr questComplete
	sec
	rts

@qcg_lure:
	// Lure quest: TREASURE to Spider Princess
	lda ZP_PTR2
	cmp #OBJ_TREASURE
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_SPIDER_PRINCESS
	bne @qcg_no
	jsr questComplete
	sec
	rts

@qcg_candywitch:
	// Candy Witch: if giving WARD to Warlock and disabled, complete
	lda ZP_PTR2
	cmp #OBJ_WARD
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_WARLOCK
	bne @qcg_no
	lda wardDisabledFlag
	beq @qcg_no
	jsr questComplete
	lda #0
	sta wardDisabledFlag
	sec
	rts

@qcg_no:
	clc
	rts

// Quest GIVE dispatch table (indexed by quest id)
questGiveCheckLo:
	.byte <@qcg_bartender, <@qcg_knight, <@qcg_mystic, <@qcg_no, <@qcg_lure, <@qcg_no, <@qcg_no, <@qcg_no, <@qcg_no, <@qcg_no, <@qcg_kendrick, <@qcg_no, <@qcg_candywitch
questGiveCheckHi:
	.byte >@qcg_bartender, >@qcg_knight, >@qcg_mystic, >@qcg_no, >@qcg_lure, >@qcg_no, >@qcg_no, >@qcg_no, >@qcg_no, >@qcg_no, >@qcg_kendrick, >@qcg_no, >@qcg_candywitch

// (questCheckGive moved to jump-table implementation earlier)

// Check drop-based quest completions (expects X = objId just dropped)
questCheckDrop:
	// must have an active quest
	lda questStatus
	cmp #1
	bne @qcd_no
	lda activeQuest
	cmp #QUEST_WARLOCK_WARD
	bne @qcd_no
	// dropped object must be the ward
	txa
	cmp #OBJ_WARD
	bne @qcd_no
	// and at the fracture location (use the Portal)
	lda currentLoc
	cmp #LOC_PORTAL
	bne @qcd_no
	jsr questComplete
	rts
@qcd_no:
	rts

cmdSave:
	jsr saveGame
	lda #<msgSaved
	sta lastMsgLo
	lda #>msgSaved
	sta lastMsgHi
	rts

cmdLoad:
	jsr tryLoadGame
	bcs @load_ok
	lda #<msgLoadFail
	sta lastMsgLo
	lda #>msgLoadFail
	sta lastMsgHi
	rts

@load_ok:
	// No PIN prompt on in-session LOAD// assumes current user
	jsr commitLoadedState
	jsr ensureQuest
	lda #<msgLoaded
	sta lastMsgLo
	lda #>msgLoaded
	sta lastMsgHi
	rts

cmdWait:
	jsr advanceWeek
	jsr musicPickForLocation
	jsr ensureQuest
	rts

cmdMusicToggle:
	lda musicEnabled
	eor #$01
	sta musicEnabled
	beq @mto_off
	// If enabling music at runtime, ensure IRQ + SID are initialized
	lda musicInstalled
	beq @mto_init
	jsr musicPickForLocation
	jmp @mto_done

@mto_init:
	jsr musicInit
	jsr musicPickForLocation

@mto_done:
	lda #<msgMusicOn
	sta lastMsgLo
	lda #>msgMusicOn
	sta lastMsgHi
	rts

@mto_off:
	jsr musicAllNotesOff
	lda #<msgMusicOff
	sta lastMsgLo
	lda #>msgMusicOff
	sta lastMsgHi
	rts

cmdStatus:
	// Show quest detail in last message
	lda activeQuest
	cmp #QUEST_NONE
	bne @status_hasQuest
	jmp @status_none

@status_hasQuest:
	tax
	lda questDetailLo,x
	sta lastMsgLo
	lda questDetailHi,x
	sta lastMsgHi
	rts

cmdChart:
	jsr clearScreen
	lda #<msgChart1
	sta ZP_PTR
	lda #>msgChart1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<msgChart2
	sta ZP_PTR
	lda #>msgChart2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr newline

	// Common printable-ish ranges with lots of graphics (avoid most control/color codes)
	lda #<msgChartRange1
	sta ZP_PTR
	lda #>msgChartRange1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #$60
	jsr chartPrintRow
	lda #$70
	jsr chartPrintRow
	jsr newline

	lda #<msgChartRange2
	sta ZP_PTR
	lda #>msgChartRange2
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #$A0
	jsr chartPrintRow
	lda #$B0
	jsr chartPrintRow
	lda #$C0
	jsr chartPrintRow
	lda #$D0
	jsr chartPrintRow
	lda #$E0
	jsr chartPrintRow
	lda #$F0
	jsr chartPrintRow
	jsr newline

	rts

// Start combat with NPC whose index is in X. This routine does not return;
// it shows a simple placeholder combat screen, waits for input, then jumps
// back to mainLoop.
combatStartWithNpc:
	stx combatNpcIdx
	// Leave conversation mode so the main render path shows the map again
	lda #0
	sta uiInConversation
	// Simple placeholder combat screen
	jsr clearScreen
	// Header: "FIGHT: " + NPC name
	lda #<strFightHeader
	sta ZP_PTR
	lda #>strFightHeader
	sta ZP_PTR+1
	jsr printZ
	jsr printNpcDisplayName
	jsr newline
	jsr newline
	// Body text
	lda #<msgCombatStub
	sta ZP_PTR
	lda #>msgCombatStub
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr newline
	lda #<msgPressEnter
	sta ZP_PTR
	lda #>msgPressEnter
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jmp mainLoop

cmdHelp:
	// Refresh help HUD (always shown) and set a friendly message
	lda #<msgHelp
	sta lastMsgLo
	lda #>msgHelp
	sta lastMsgHi
	rts

@status_none:
	lda #<msgNoQuest
	sta lastMsgLo
	lda #>msgNoQuest
	sta lastMsgHi
	rts

@npcNotHere:
	lda #<msgNpcNotHere
	sta lastMsgLo
	lda #>msgNpcNotHere
	sta lastMsgHi
	rts
@noone:
	lda #<msgNoOne
	sta lastMsgLo
	lda #>msgNoOne
	sta lastMsgHi
	rts
@need:
	lda #<msgGiveWhat
	sta lastMsgLo
	lda #>msgGiveWhat
	sta lastMsgHi
	rts
@notHave:
	lda #<msgNotCarrying
	sta lastMsgLo
	lda #>msgNotCarrying
	sta lastMsgHi
	rts
@bad:
	lda #<msgDontKnow
	sta lastMsgLo
	lda #>msgDontKnow
	sta lastMsgHi
	rts

cmdInventory:
	jsr clearScreen

	// Ensure player has starting trinkets
	lda playerTrinketsAssigned
	bne @inv_trinkets_assigned
	jsr assignRandomTrinkets
	lda #1
	sta playerTrinketsAssigned
@inv_trinkets_assigned:

	// Title
	lda #<strInventory
	sta ZP_PTR
	lda #>strInventory
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Coins line: GOLD / SILVER / COPPER
	lda #<strGold
	sta ZP_PTR
	lda #>strGold
	sta ZP_PTR+1
	jsr printZ
	lda playerGold
	jsr printDecimal
	lda #' '
	jsr printChar

	lda #<strSilver
	sta ZP_PTR
	lda #>strSilver
	sta ZP_PTR+1
	jsr printZ
	lda playerSilver
	jsr printDecimal
	lda #' '
	jsr printChar

	lda #<strCopper
	sta ZP_PTR
	lda #>strCopper
	sta ZP_PTR+1
	jsr printZ
	lda playerCopper
	jsr printDecimal
	jsr newline
	jsr newline

	// Items section header
	lda #<strItems
	sta ZP_PTR
	lda #>strItems
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Inventory items (objects carried)
	lda #0
	sta ZP_PTR2
	ldx #0
@inv_obj_loop:
	lda objLoc,x
	cmp #OBJ_INVENTORY
	bne @inv_obj_next
	lda #1
	sta ZP_PTR2
	lda objNameLo,x
	sta ZP_PTR
	lda objNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline
@inv_obj_next:
	inx
	cpx #OBJ_COUNT
	bne @inv_obj_loop
	lda ZP_PTR2
	bne @inv_items_done
	lda #<strEmpty
	sta ZP_PTR
	lda #>strEmpty
	sta ZP_PTR+1
	jsr printZ
@inv_items_done:
	jsr newline

	// Trinkets section
	lda #<strTrinkets
	sta ZP_PTR
	lda #>strTrinkets
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #0
	sta ZP_PTR2
	ldx #0
@inv_trinket_loop:
	lda playerTrinkets,x
	cmp #$FF
	beq @inv_trinket_next
	lda playerTrinkets,x
	tay
	lda trinketNamesLo,y
	sta ZP_PTR
	lda trinketNamesHi,y
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #1
	sta ZP_PTR2
@inv_trinket_next:
	inx
	cpx #5
	bne @inv_trinket_loop
	lda ZP_PTR2
	bne @inv_trinkets_done
	lda #<strNone
	sta ZP_PTR
	lda #>strNone
	sta ZP_PTR+1
	jsr printZ
@inv_trinkets_done:
	jsr newline
	jsr newline

	// Wait for Enter to continue
	lda #<msgPressEnter
	sta ZP_PTR
	lda #>msgPressEnter
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	rts

// --- Dynamic message builders ---
clearMsgBuf:
	lda #0
	sta msgBufLen
	sta msgBuf
	rts

// Append 0-terminated string at (ZP_PTR) to msgBuf
appendToMsgBuf:
	ldx msgBufLen
	ldy #0

@atm_loop:
	lda (ZP_PTR),y
	beq @atm_done
	cpx #255
	bcs @atm_done
	sta msgBuf,x
	inx
	iny
	bne @atm_loop

@atm_done:
	stx msgBufLen
	lda #0
	sta msgBuf,x
	rts

buildCharactersMessage:
	jsr clearMsgBuf
	lda #<strCharacters
	sta ZP_PTR
	lda #>strCharacters
	sta ZP_PTR+1
	jsr appendToMsgBuf

	ldx currentLoc
	lda npcMaskByLocLo,x
	sta ZP_PTR2 // reuse low byte as mask temp
	lda npcMaskByLocHi,x
	sta npcMaskHiTemp
	lda npcMaskByLocB2,x
	sta npcMaskB2Temp
	lda npcMaskByLocB3,x
	sta npcMaskB3Temp
	ldx #0
@npcLoop:
	lda ZP_PTR2
	and npcBitLo,x
	beq @bcm_check_hi
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf
	jmp @bcm_next

@bcm_check_hi:
	lda npcMaskHiTemp
	and npcBitHi,x
	beq @bcm_check_b2
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf
	jmp @bcm_next

@bcm_check_b2:
	lda npcMaskB2Temp
	and npcBitB2,x
	beq @bcm_check_b3
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf
	jmp @bcm_next

@bcm_check_b3:
	lda npcMaskB3Temp
	and npcBitB3,x
	beq @bcm_next
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf

@bcm_next:
	inx
	cpx #NPC_COUNT
	beq @bcm_done
	jmp @npcLoop
@bcm_done:
	rts

@bcm_none:
	lda #<strNone
	sta ZP_PTR
	lda #>strNone
	sta ZP_PTR+1
	jsr appendToMsgBuf
	rts


@give_need:
buildInventoryMessage:
	jsr clearMsgBuf

	// Diagnostic: include trinket & objLoc debug in msgBuf for visibility


	lda #<strInventory
	sta ZP_PTR
	lda #>strInventory
	sta ZP_PTR+1

@give_notHave:
	jsr appendToMsgBuf

	// Always show coin balances (including zeros)
	lda #<strGold
	sta ZP_PTR
	lda #>strGold
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda playerGold
	jsr appendByteAsDec
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf

	lda #<strSilver
	sta ZP_PTR
	lda #>strSilver
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda playerSilver
	jsr appendByteAsDec
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf

	lda #<strCopper
	sta ZP_PTR
	lda #>strCopper
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda playerCopper
	jsr appendByteAsDec
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf
	// If any coins, add newline
	lda playerGold
	ora playerSilver
	ora playerCopper
	beq @no_coins
	lda #13
	jsr appendCharA
@no_coins:

	lda #0
	sta ZP_PTR2 // foundAny flag
	ldx #0
@objLoop:

@give_bad:
	lda objLoc,x
	cmp #OBJ_INVENTORY
	bne @on
	lda #1
	sta ZP_PTR2
	lda objNameLo,x
	sta ZP_PTR
	lda objNameHi,x
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf
@on:
	inx
	cpx #OBJ_COUNT
	bne @objLoop
	lda ZP_PTR2
	bne @bom_done
	lda #<strEmpty
	sta ZP_PTR
	lda #>strEmpty
	sta ZP_PTR+1
	jsr appendToMsgBuf

@bom_done:
	// Add trinkets section
	lda #13
	jsr appendCharA
	lda #<strTrinkets
	sta ZP_PTR
	lda #>strTrinkets
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #13
	jsr appendCharA
	ldx #0
@trinket_loop:
	lda playerTrinkets,x
	cmp #$FF
	beq @trinket_next
	lda playerTrinkets,x
	tay
	lda trinketNamesLo,y
	sta ZP_PTR
	lda trinketNamesHi,y
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr appendToMsgBuf
@trinket_next:
	inx
	cpx #5
	bne @trinket_loop
	ldx msgBufLen
	lda #0
	sta msgBuf,x
	rts

// --- Exits printing ---
printExits:
	ldx currentLoc
	lda exitN,x
	cmp #$FF
	beq @e
	lda #'N'
	jsr CHROUT
	lda #' '
	jsr CHROUT
@e:
	lda exitE,x
	cmp #$FF
	beq @s
	lda #'E'
	jsr CHROUT
	lda #' '
	jsr CHROUT
@s:
	lda exitS,x
	cmp #$FF
	beq @w
	lda #'S'
	jsr CHROUT
	lda #' '
	jsr CHROUT
@w:
	lda exitW,x
	cmp #$FF
	beq @diag
	lda #'W'
	jsr CHROUT
	lda #' '
	jsr CHROUT

@diag:
	// Print diagonal possibilities if reachable via two-step paths
	// NE
	ldx currentLoc
	lda exitN,x
	cmp #$FF
	beq @ne_e
	tax
	lda exitE,x
	cmp #$FF
	beq @ne_e
	lda #'N'
	jsr CHROUT
	lda #'E'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jmp @nw
@ne_e:
	ldx currentLoc
	lda exitE,x
	cmp #$FF
	beq @nw
	tax
	lda exitN,x
	cmp #$FF
	beq @nw
	lda #'N'
	jsr CHROUT
	lda #'E'
	jsr CHROUT
	lda #' '
	jsr CHROUT
@nw:
	// NW
	ldx currentLoc
	lda exitN,x
	cmp #$FF
	beq @nw_w
	tax
	lda exitW,x
	cmp #$FF
	beq @nw_w
	lda #'N'
	jsr CHROUT
	lda #'W'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jmp @se
@nw_w:
	ldx currentLoc
	lda exitW,x
	cmp #$FF
	beq @se
	tax
	lda exitN,x
	cmp #$FF
	beq @se
	lda #'N'
	jsr CHROUT
	lda #'W'
	jsr CHROUT
	lda #' '
	jsr CHROUT
@se:
	// SE
	ldx currentLoc
	lda exitS,x
	cmp #$FF
	beq @se_e
	tax
	lda exitE,x
	cmp #$FF
	beq @se_e
	lda #'S'
	jsr CHROUT
	lda #'E'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jmp @sw
@se_e:
	ldx currentLoc
	lda exitE,x
	cmp #$FF
	beq @sw
	tax
	lda exitS,x
	cmp #$FF
	beq @sw
	lda #'S'
	jsr CHROUT
	lda #'E'
	jsr CHROUT
	lda #' '
	jsr CHROUT
@sw:
	// SW
	ldx currentLoc
	lda exitS,x
	cmp #$FF
	beq @sw_w
	tax
	lda exitW,x
	cmp #$FF
	beq @sw_w
	lda #'S'
	jsr CHROUT
	lda #'W'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	jmp @pe_done
@sw_w:
	ldx currentLoc
	lda exitW,x
	cmp #$FF
	beq @pe_done
	tax
	lda exitS,x
	cmp #$FF
	beq @pe_done
	lda #'S'
	jsr CHROUT
	lda #'W'
	jsr CHROUT
	lda #' '
	jsr CHROUT

@pe_done:
	rts

// --- Data: Map (12 lines) ---
// Simple "pizza slice" park diagram with abbreviated locations.
// (Player marker is printed separately as 'X')
map0:  .text "            .-------------.            "
	.byte 0
map1:  .text "         .-'      TRN      '-.         "
	.byte 0
map2:  .text "       .'   NW  /  |  /  NE   '.       "
	.byte 0
map3:  .text "      /  DGH  /   |   /  MKT    /     "
	.byte 0
map4:  .text "     ;       /   TMP    /       ;     "
	.byte 0
map5:  .text "     |  WGT |    PLA    |  ALY   |     "
	.byte 0
map6:  .text "     ;       /    |    /        ;     "
	.byte 0
map7:  .text "      /  WCH  /   |   /  FAY   /      "
	.byte 0
map8:  .text "       '.   SW  /  |  /  SE  .'       "
	.byte 0
map9:  .text "         '-.     TAV     .-'           "
	.byte 0
map10: .text "            '-----------'              "
	.byte 0
map11: .text "               (EVERLAND)              "
	.byte 0

mapLineLo:
	.byte <map0,<map1,<map2,<map3,<map4,<map5,<map6,<map7,<map8,<map9,<map10,<map11
mapLineHi:
	.byte >map0,>map1,>map2,>map3,>map4,>map5,>map6,>map7,>map8,>map9,>map10,>map11

strDivider: .text "----------------------------------------"
	.byte 0

// Player marker coordinates (col 0-39, row 0-24)
locMarkX:
	// LOC order: TRAIN, MARKET, PORTAL, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	// Extra (non-map) locations reuse nearby marker positions.
	.byte 19, 27,  9, 10, 18, 28, 11, 28, 18, 13, 10, 22, 18
locMarkY:
	.byte  1,  3,  5,  3,  5,  5,  7,  7,  9,  8,  4,  9,  4

// --- Data: Locations ---
locName0: .text "TRAIN STATION"
	.byte 0
locName1: .text "MARKET GREEN"
	.byte 0
locName2: .text "FRACTURED PORTAL"
	.byte 0
locName3: .text "DRAGON HAVEN"
	.byte 0
locName4: .text "CENTRAL PLAZA"
	.byte 0
locName5: .text "CLOCKWORK ALLEY"
	.byte 0
locName6: .text "MYSTICWOOD"
	.byte 0
locName7: .text "FAIRY GARDENS"
	.byte 0
locName8: .text "TIPSY MAIDEN TAVERN"
	.byte 0
locName9: .text "DRAGON HAVEN"
	.byte 0
locName10: .text "CATACOMBS"
	.byte 0
locName11: .text "PIGGLYWEED INN"
	.byte 0
locName12: .text "TEMPLE RUINS"
	.byte 0

locNameLo:
	.byte <locName0,<locName1,<locName2,<locName3,<locName4,<locName5,<locName6,<locName7,<locName8,<locName9,<locName10,<locName11,<locName12
locNameHi:
	.byte >locName0,>locName1,>locName2,>locName3,>locName4,>locName5,>locName6,>locName7,>locName8,>locName9,>locName10,>locName11,>locName12

locDesc0: .text "A SMALL PLATFORM AND A WHISTLING SIGN."
	.byte $0D
	.text "A LANTERN HANGS HERE."
	.byte 0
locDesc1: .text "MERCHANTS TRADE TALES AND TRINKETS."
	.byte $0D
	.text "A COIN GLINTS NEAR A STALL."
	.byte 0
locDesc2: .text "IRON BANNERS AND WOODEN PALISADES."
	.byte $0D
	.text "A RUSTED KEY RESTS BY A POST."
	.byte 0
locDesc3: .text "LOUDEN'S REST"
	.byte $0D
	.text "A MAUSOLEUM LOOMS IN THE FOG. A CROOKED GRAVEYARD WITH HEADSTONES."
	.byte 0
locDesc4: .text "THE HEART OF THE PARK."
	.byte $0D
	.text "PATHS RADIATE LIKE PIE SLICES."
	.byte 0
locDesc5: .text "GEARS, BELLS, AND BRASS SIGNS."
	.byte $0D
	.text "A WORKSHOP HUMS QUIETLY."
	.byte 0
locDesc6: .text "DARK TREES AND PAPER CHARMS."
	.byte $0D
	.text "THE AIR SMELLS OF HERBS."
	.byte 0
locDesc7: .text "GLASSY PETALS AND LANTERN DEW."
	.byte $0D
	.text "QUIET LAUGHTER IN THE HEDGES."
	.byte 0
locDesc8: .text "LAUGHTER, MUSIC, AND FOAMING MUGS."
	.byte $0D
	.text "A MUG SITS UNCLAIMED."
	.byte 0
locDesc9:  .text "MEETING PLACE FOR THE ORDER OF THE EMERALD SKY"
	.byte $0D
	.text "DRAGON TRAINERS GATHER HERE."
	.byte 0
locDesc10: .text "COLD STEPS DESCEND BENEATH THE TOMB."
	.byte $0D
	.text "EVERY SOUND RETURNS TWICE."
	.byte 0
locDesc11: .text "WARM LAMPLIGHT AND POLISHED WOOD."
	.byte $0D
	.text "ROOMS HUM WITH REST."
	.byte 0
locDesc12: .text "BROKEN COLUMNS AND OLD BANNERS."
	.byte $0D
	.text "THE STONE FEELS READY FOR WAR."
	.byte 0

locDescLo:
	.byte <locDesc0,<locDesc1,<locDesc2,<locDesc3,<locDesc4,<locDesc5,<locDesc6,<locDesc7,<locDesc8,<locDesc9,<locDesc10,<locDesc11,<locDesc12
locDescHi:
	.byte >locDesc0,>locDesc1,>locDesc2,>locDesc3,>locDesc4,>locDesc5,>locDesc6,>locDesc7,>locDesc8,>locDesc9,>locDesc10,>locDesc11,>locDesc12

// Exits by cardinal direction ($FF = none)
exitN:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE, BANK
	.byte $FF,  $FF,  LOC_GOLEM, $FF,  LOC_TRAIN, LOC_MARKET, LOC_PORTAL, LOC_TEMPLE, LOC_ALLEY, $FF,  LOC_GRAVE, $FF,  LOC_PLAZA, $FF
exitE:
	.byte LOC_MARKET, $FF,       LOC_PLAZA, LOC_TRAIN, LOC_BANK, $FF,       LOC_GROVE, LOC_TAVERN, LOC_INN, LOC_MYSTIC, $FF, $FF, LOC_GOLEM, $FF
exitS:
	.byte LOC_PLAZA, LOC_ALLEY,  LOC_MYSTIC, LOC_PORTAL,  LOC_TEMPLE, LOC_TAVERN, $FF, $FF, $FF, LOC_CATACOMBS, $FF, $FF, LOC_GROVE, $FF
exitW:
	.byte LOC_GOLEM, LOC_TRAIN,  $FF,       LOC_TEMPLE, LOC_PORTAL, LOC_PLAZA, LOC_GRAVE, LOC_MYSTIC, LOC_GROVE, $FF, $FF, LOC_TAVERN, $FF, LOC_PLAZA

// NPC masks by location (two bytes per location: low, high)
npcMaskByLocLo:
	.byte %00000001 // TRAIN: CONDUCTOR
	.byte %00000000 // MARKET
	.byte %00000100 // PORTAL: KNIGHT
	.byte %00000000 // GOLEM
	.byte %01100000 // PLAZA: SPIDER PRINCESS + KENDRICK
	.byte %10000000 // ALLEY: PIRATE CAPTAIN
	.byte %00001000 // MYSTICWOOD: MYSTIC
	.byte %00010000 // FAIRY GARDENS: FAIRY
	.byte %00000010 // TAVERN: BARTENDER
	.byte %00000000 // DRAGON HAVEN
	.byte %00000000 // CATACOMBS
	.byte %00100000 // PIGGLYWEED INN: FROST WEAVERS QUEEN (index21 -> b2 bit5)
	.byte %00001000 // TEMPLE RUINS: VASHTEE (index19 -> b2 bit3)
	.byte %00000000 // BANK

npcMaskByLocHi:
	.byte %00000000 // TRAIN
	.byte %00010000 // MARKET: BRIDGE THE TROLL (index12 -> high bit4)
	.byte %00000000 // PORTAL
	.byte %00100000 // GOLEM: TOSH THE TOSHER (index13 -> high bit5)
	.byte %00000001 // PLAZA: WARLOCK (index8 -> high bit0)
	.byte %00000000 // ALLEY
	.byte %00000000 // MYSTICWOOD
	.byte %00000000 // FAIRY GARDENS
	.byte %00010000 // TAVERN: TRADING COMPANY OWNER (index20 -> b2 bit4)
	.byte %00001000 // DRAGON HAVEN: ALYSTER (index11 -> high bit3)
	.byte %01000000 // CATACOMBS: SPIRIT OF LOUDEN (index14 -> high bit6)
	.byte %00000100 // PIGGLYWEED INN: APOLLONIA (index10 -> high bit2)
	.byte %00000010 // TEMPLE RUINS: UNSEELY FAE (index9 -> high bit1)
	.byte %00000000 // BANK

// Additional NPC masks by location for indices 16..31 (bytes 2 and 3)
npcMaskByLocB2:
	.byte %00000000 // TRAIN
	.byte %00000000 // MARKET
	.byte %00000100 // PORTAL: ALPHA WOLFRIC (index18 -> b2 bit2)
	.byte %00000000 // GOLEM
	.byte %00000010 // PLAZA: KORA (index17 -> b2 bit1)
	.byte %00000001 // ALLEY: CANDY WITCH (index16 -> b2 bit0)
	.byte %00000000 // MYSTICWOOD
	.byte %00000000 // FAIRY GARDENS
	.byte %00000000 // TAVERN
	.byte %00000000 // DRAGON HAVEN
	.byte %00000000 // CATACOMBS
	.byte %00000000 // PIGGLYWEED INN
	.byte %00000000 // TEMPLE RUINS
	.byte %01000000 // BANK: BANKER (index22 -> b2 bit6)

npcMaskByLocB3:
	.byte %00000000 // TRAIN
	.byte %00000000 // MARKET
	.byte %00000000 // PORTAL
	.byte %00000000 // GOLEM
	.byte %00000000 // PLAZA
	.byte %00000000 // ALLEY
	.byte %00000000 // MYSTICWOOD
	.byte %00000000 // FAIRY GARDENS
	.byte %00000000 // TAVERN
	.byte %00000000 // DRAGON HAVEN
	.byte %00000000 // CATACOMBS
	.byte %00000000 // PIGGLYWEED INN
	.byte %00000000 // TEMPLE RUINS
	.byte %00000000 // BANK


// Default NPC to address in a location when only one is present
npcDefaultByLoc:
	.byte NPC_CONDUCTOR, NPC_TROLL, NPC_KNIGHT, NPC_TOSH, NPC_PIXIE, NPC_PIRATE_CAPTAIN, NPC_MYSTIC, NPC_FAIRY, NPC_BARTENDER, NPC_ALYSTER, NPC_LOUDEN, NPC_APOLLONIA, NPC_UNSEELY_FAE

// One-line talk per location (MVP)
npcTalkLoByLoc:
	.byte <talkConductor,<talkTroll,<talkKnight,<talkTosh,<msgNoOne,<talkPirateCaptain,<talkMystic,<talkFairy,<talkBartender,<talkAlyster,<talkLouden,<talkApollonia,<msgNoOne
npcTalkHiByLoc:
	.byte >talkConductor,>talkTroll,>talkKnight,>talkTosh,>msgNoOne,>talkPirateCaptain,>talkMystic,>talkFairy,>talkBartender,>talkAlyster,>talkLouden,>talkApollonia,>msgNoOne

talkConductor: .text "the conductor says: all aboard the imagination express!"
	.byte 0
talkBartender: .text "THE BARTENDER SAYS: CAREFUL WHAT YOU PROMISE IN HERE."
	.byte 0
talkKnight:    .text "THE KNIGHT SAYS: HONOR OPENS MORE DOORS THAN KEYS."
	.byte 0
talkMystic:     .text "THE MYSTIC SAYS: WORDS HAVE POWER. CHOOSE THEM WELL."
	.byte 0
talkFairy:     .text "A FAIRY SAYS: LISTEN CLOSELY. THE GARDENS REMEMBER YOUR KINDNESS."
	.byte 0
talkPixie:     .text "A PIXIE CHIMES: TRADE A SECRET FOR A SPARKLE!"
	.byte 0
talkWarlock: .text "THE WARLOCK WHISPERS: POWER DEMANDS ITS PRICE, STRANGER."
	.byte 0
msgWarlockQuestOffer: .text "WARLOCK: TAKE THIS WARD AND PLANT IT WHERE THE PORTAL FRACTURES—AT THE PORTAL."
	.byte 0
msgCandyWitchQuestOffer: .text "CANDY WITCH: BRING ME THE WARLOCK'S WARD. I'LL LACE IT WITH SWEET BITTERNESS UNTIL IT GOES QUIET — THEN RETURN IT TO HIM."
	.byte 0
msgCandyWitchDisable: .text "SHE BREATHES A SUGARED CURSE OVER THE WARD. THE RUNIC HUM DIES. SHE PRESSES IT BACK INTO YOUR PALM WITH A SMILE."
	.byte 0
talkKendrick:  .text "KENDRICK: AYE, I'M SWORN TAE WATCH O'ER THE SPIDER PRINCESS. AYE'VE A WEE BOTTLE AT MA SIDE -- *HIC* -- AN' I'LL FIGHT FER HER!"
	.byte 0
talkSpiderPrincess: .text "THE SPIDER PRINCESS SAYS: I CAME THROUGH A FRACTURED PORTAL; WHO AM I?"
	.byte 0
talkPirateCaptain: .text "THE PIRATE CAPTAIN GRINS: GOLD AND TALES MAKE A FINE COCKTAIL."
	.byte 0
talkPirateFirstMate: .text "FIRST MATE: WE SWEAR BY WIND AND WHEEL, STRANGER."
	.byte 0

talkTosh: .text "TOSH THE TOSHER SAYS: DAVID NEEDS A DATE. GOT ANYTHING TO TRADE?"
	.byte 0

talkTroll: .text "BRIDGE THE TROLL RUMBLES: SAY THE OPPOSITE, FRIEND."
	.byte 0

talkLouden: .text "A SPIRIT WHISPERS: I AM LOUDEN. MY HEART IS LOST."
	.byte 0

talkMermaid: .text "A MERMAID SINGS: TRADE LAND CORAL FOR A SEA SHELL?"
	.byte 0
talkCandyWitch: .text "CANDY WITCH: SUGAR TURNS TO ASH NEAR HIS WARDS. BRING ME HIS WARD AND I'LL SWEETEN IT DEAD—THEN GIVE IT BACK TO HIM. OLD LOVE MAKES BITTER MAGIC."
	.byte 0
msgKoraQuestOffer:
	.text "KORA: FIND KENDRICK IN THE PLAZA AND SAY, "
	.byte $22
	.text "SCOTCH ON THE KNIGHT"
	.byte $22
	.text " TO HIM. HE'LL LAUGH, THEN BLUSH."
	.byte 0
msgKoraJapeDone:
	.text "KENDRICK BELLOWS A LAUGH, THEN NEARLY DROPS HIS BOTTLE. "
	.byte $22
	.text "SCOTCH ON THE KNIGHT!"
	.byte $22
	.text " HE REPEATS, WIPING A TEAR. "
	.byte $22
	.text "WELL SAID!"
	.byte $22
	.byte 0
talkKora: .text "KORA WINKS: A JEST FIT FOR COURT CAN UNHORSE A KNIGHT."
	.byte 0
talkUnknown: .text "(THE FIGURE SAYS NOTHING.)"
	.byte 0

// Alpha Wolfric & related NPC talk lines
talkAlphaWolfric: .text "ALPHA WOLFRIC: THE PACK MUST BE FED. WE WILL GUARD THE TOWN IF YOU SECURE SUPPLIES."
	.byte 0
msgAlphaMenuHeader: .text "alpha wolfric"
	.byte 0
msgAlphaOpt0: .text "0. ask about the wolves"
	.byte 0
msgAlphaOpt1: .text "1. REQUEST HELP: SEEK SUPPLIES"
	.byte 0

talkVashtee: .text "VASHTEE: THE DRAGONS HAVE THEIR WAYS. I TRAIN THEM WITH FIRM HANDS."
	.byte 0

talkTradingOwner: .text "VAN BEAULER: I RUN THE TRADING COMPANY. SUPPLIES COME AT A PRICE."
	.byte 0
msgTradingOwnerDone: .text "VAN BEAULER: VERY WELL. THE SUPPLIES ARE YOURS. THE WOLVES WILL WATCH THE TOWN."
	.byte 0

talkFrostWeaversQueen: .text "FROST WEAVERS QUEEN: WINTER WEAVES ITS SONG; LISTEN." 
	.byte 0

talkUnseelyFae: .text "AN UNSEELY FAE WHISPERS: THE RUINS REMEMBER BLOOMS THAT NEVER WERE."
	.byte 0

talkApollonia: .text "A STATUE OF SAINT APOLLONIA STANDS SILENTLY."

talkAlyster: .text "ALYSTER SAYS: STRENGTH WITH KINDNESS; DRAGONS TRUST THE STEADFAST."
	.byte 0
// Apollonia conversation strings
msgApolloniaMenuHeader: .text "SAINT APOLLONIA"
msgApolloniaOpt0: .text "0. HEAR OF THE MARTYRS"
	.byte 0
msgApolloniaOpt1: .text "1. HEAR OF HER TEETH"
	.byte 0
msgApolloniaOpt2: .text "2. HEAR OF THE FLAMES"
	.byte 0
msgApolloniaOpt3: .text "3. LEAVE AN OFFERING"
	.byte 0
msgApolloniaOpt4: .text "4. LEAVE"
	.byte 0
msgApolloniaMartyrs:
	.text "SHE WAS ARRESTED FOR HER FAITH,"
	.byte $0D
	.text "FORCED TO WATCH AS HER FELLOW"
	.byte $0D
	.text "CHRISTIAN MARTYRS WERE BRUTALLY KILLED."
	.byte 0
msgApolloniaTeeth:
	.text "THEY THREATENED TO PULL OUT ALL HER TEETH"
	.byte $0D
	.text "UNLESS SHE RENOUNCED CHRISTIANITY."
	.byte $0D
	.text "SHE CHOSE TO SUFFER RATHER THAN BETRAY HER BELIEF."
	.byte 0
msgApolloniaFire:
	.text "AFTER HER TORTURE, SHE WAS ULTIMATELY"
	.byte $0D
	.text "BURNED AT THE STAKE FOR HER FAITH."
	.byte 0
msgApolloniaOfferDone: .text "YOU LEAVE AN OFFERING AT THE STATUE."
	.byte 0
msgApolloniaNoOffer: .text "YOU HAVE NOTHING TO OFFER."
	.byte 0
msgApolloniaCurse: .text "A SHIVER RUNS THROUGH YOU. A CURSE LINGERS."
	.byte 0

// Alyster conversation strings
msgAlysterMenuHeader: .text "DRAGON TRAINER ALYSTER"
	.byte 0
msgAlysterOpt0: .text "0. LEARN THE BASICS"
	.byte 0
msgAlysterOpt1: .text "1. HEAR DRAGON CARE TIPS"
	.byte 0
msgAlysterOpt2: .text "2. PRACTICE A STANCE"
	.byte 0
msgAlysterOpt3: .text "3. ADVANCED TRAINING"
	.byte 0
msgAlysterOpt4: .text "4. LEAVE"
	.byte 0
msgAlysterBasics: .text "STRENGTH WITH KINDNESS. DISCIPLINE EARNED, NEVER FORCED."
	.byte $0D
	.text "DRAGONS TRUST THE STEADFAST AND THE TRUE."
	.byte 0
msgAlysterCare: .text "A CALM VOICE, A STEADY HAND. FEED WELL, TRAIN FAIR."
	.byte $0D
	.text "RESPECT BREEDS LOYALTY; LOYALTY BREEDS COURAGE."
	.byte 0
msgAlysterPractice: .text "YOU CENTER YOURSELF. YOU FEEL STEADIER."
	.byte 0
msgAlysterAdvanced: .text "YOU BREATHE DEEPLY AND SET YOUR STANCE."
	.byte $0D
	.text "YOUR RESOLVE HARDENS; YOUR VITALITY INCREASES."
	.byte 0
msgAlysterNotReady: .text "ALYSTER SAYS: MASTER THE BASICS FIRST."
	.byte 0
msgAlysterAdvancedDone: .text "ALYSTER NODS: YOU'VE LEARNED THIS LESSON."
	.byte 0

msgAlysterOathOffer:
	.text "ALYSTER: THE ORDER OF THE EMERALD SKY SEEKS STEWARDS OF DRAGONS."
	.byte $0D
	.text "TO JOIN, SWEAR THESE CONDITIONS:"
	.byte $0D
	.text "1) PROTECT ALL DRAGONS."
	.byte $0D
	.text "2) INCREASE UNDERSTANDING OF DRAGONS."
	.byte $0D
	.text "3) STRENGTHEN THE BOND BETWEEN HUMANS AND DRAGONS."
	.byte $0D
	.text "DO YOU SWEAR THESE OATHS? (Y/N)"
	.byte 0

msgAlysterOathAccepted:
	.text "ALYSTER: BY THE EMERALD SKY, WELCOME. YOU ARE NOW A MEMBER."
	.byte 0

msgAlysterOathRefused:
	.text "ALYSTER: I RESPECT YOUR CHOICE. RETURN WHEN YOUR HEART IS SURE."
	.byte 0

// Troll conversation strings
msgTrollMenuHeader: .text "BRIDGE THE TROLL"
	.byte 0
msgTrollOpt0: .text "0. COMPLIMENT HIM"
	.byte 0
msgTrollOpt1: .text "1. INSULT HIM"
	.byte 0
msgTrollOpt2: .text "2. ASK ABOUT KEVIN"
	.byte 0
msgTrollOpt3: .text "3. LEAVE"
	.byte 0
msgTrollCompliment: .text "TROLL: HOW DARE YOU! SAY THE OPPOSITE, FRIEND."
	.byte 0
msgTrollInsult: .text "TROLL: THANK YOU. FINALLY, SOME MANNERS."
	.byte 0
msgTrollKevin:
	.text "HE PATS A WOODEN MACE WITH A SKULL ATOP."
	.byte $0D
	.byte $22
	.text "THIS IS KEVIN,"
	.byte $22
	.text " HE SAYS. "
	.byte $22
	.text "MY IMAGINARY COMPANION."
	.byte $22
	.byte 0

// Tosh conversation strings
msgToshMenuHeader: .text "TOSH THE TOSHER"
	.byte 0
msgToshOpt0: .text "0. TALK ABOUT DAVID"
	.byte 0
msgToshOpt1: .text "1. TRADE A SEWER FIND"
	.byte 0
msgToshOpt2: .text "2. ASK ABOUT WORK"
	.byte 0
msgToshOpt3: .text "3. LEAVE"
	.byte 0
msgToshDavid:
	.text "HE TAPS A FRIENDLY SKELETON NAMED DAVID."
	.byte $0D
	.byte $22
	.text "TRYING TO FIX HIM UP WITH A DATE,"
	.byte $22
	.text " HE GRINS."
	.byte 0
msgToshWork:
	.text "I'M A TOSHER AND AN UNDERTAKER."
	.byte $0D
	.text "IF YOU'VE GOT SOMETHING, I CAN TRADE YOU SOMETHING I FOUND."
	.byte 0
msgToshTradeDone: .text "HE HANDS YOU A COIN HE FISHED FROM THE SEWER."
	.byte 0
msgToshTradeNone: .text "YOU HAVE NOTHING TO TRADE."
	.byte 0

// Louden conversation strings
msgLoudenMenuHeader: .text "SPIRIT OF LOUDEN"
	.byte 0
msgLoudenOpt0: .text "0. HEAR HIS PLEA"
	.byte 0
msgLoudenOpt1: .text "1. ACCEPT HIS QUEST"
	.byte 0
msgLoudenOpt2: .text "2. OFFER HIS HEART"
	.byte 0
msgLoudenOpt3: .text "3. LEAVE"
	.byte 0
msgLoudenStory:
	.text "MY HEART IS LOST IN THE CATACOMBS."
	.byte $0D
	.text "FIND IT AND BRING IT BACK SO I MAY LIVE AGAIN."
	.byte 0
msgLoudenAccept: .text "A QUIET HOPE GLOWS. THE QUEST IS YOURS."
	.byte 0
msgLoudenThanks: .text "THE HEART RETURNS. BREATH AND WARMTH FOLLOW."
	.byte 0
msgLoudenNoHeart: .text "YOU DO NOT CARRY MY HEART."
	.byte 0

msgMermaidMenuHeader: .text "MERMAID"
	.byte 0
msgMermaidOpt0: .text "0. SING"
	.byte 0
msgMermaidOpt1: .text "1. ASK FOR A TRADE"
	.byte 0
msgMermaidOpt2: .text "2. OFFER LAND CORAL"
	.byte 0
msgMermaidOpt3: .text "3. LEAVE"
	.byte 0
msgMermaidSing: .text "HER VOICE SHIMMERS LIKE TIDE-LIGHT ALONG THE STONES."
	.byte 0
msgMermaidAskTrade: .text "BRING ME LAND CORAL, AND I WILL GIVE YOU A SHELL."
	.byte 0
msgMermaidTradeDone: .text "SHE TRADES YOUR PINECONE FOR A SPARKLY SHELL."
	.byte 0
msgMermaidTradeNone: .text "YOU HAVE NO LAND CORAL TO OFFER."
	.byte 0
npcTalkLo:
	.byte <talkConductor,<talkBartender,<talkKnight,<talkMystic,<talkFairy,<talkKendrick,<talkSpiderPrincess,<talkPirateCaptain,<talkWarlock,<talkUnseelyFae,<talkApollonia,<talkAlyster,<talkTroll,<talkTosh,<talkLouden,<talkMermaid
	.byte <talkCandyWitch,<talkKora,<talkAlphaWolfric,<talkVashtee,<talkTradingOwner,<talkFrostWeaversQueen,<talkUnknown,<talkUnknown,<talkUnknown,<talkUnknown,<talkUnknown,<talkUnknown,<talkUnknown,<talkUnknown,<talkUnknown,<talkUnknown
npcTalkHi:
	.byte >talkConductor,>talkBartender,>talkKnight,>talkMystic,>talkFairy,>talkKendrick,>talkSpiderPrincess,>talkPirateCaptain,>talkWarlock,>talkUnseelyFae,>talkApollonia,>talkAlyster,>talkTroll,>talkTosh,>talkLouden,>talkMermaid
	.byte >talkCandyWitch,>talkKora,>talkAlphaWolfric,>talkVashtee,>talkTradingOwner,>talkFrostWeaversQueen,>talkUnknown,>talkUnknown,>talkUnknown,>talkUnknown,>talkUnknown,>talkUnknown,>talkUnknown,>talkUnknown,>talkUnknown,>talkUnknown

// Which quest (if any) each NPC can offer
// Which quest (if any) each NPC can offer
// Which quest (if any) each NPC can offer
npcOffersQuest:
	.byte QUEST_COIN_BARTENDER, QUEST_NONE, QUEST_BLACK_ROSE, QUEST_LANTERN_MYSTIC, QUEST_NONE, QUEST_KENDRICK_SCOTCH, QUEST_LURE_MYSTIC, QUEST_NONE, QUEST_WARLOCK_WARD, QUEST_UNSEELY_NAME, QUEST_APOLLONIA_OFFERING, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_LOUDEN_HEART, QUEST_MERMAID_TRADE
	.byte QUEST_CANDY_WITCH_DISABLE_WARD, QUEST_KORA_JAPE, QUEST_ALPHA_WOLFRIC, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE, QUEST_NONE

// Conversation strings
msgAskWeather: .text "THE SKY LOOKS LIKE IT'LL HOLD FOR NOW."
	.byte 0
msgTempResponse: .text "YOU SENSE THE AIR: IT FEELS A LITTLE CHILLY."
	.byte 0
msgQuestOfferGeneric: .text "I MIGHT HAVE SOMETHING FOR YOU."
	.byte 0
msgSpiderQuestOffer: .text "SPIDER PRINCESS: I WANT A ROMANTIC DATE. BRING ME THE MYSTIC... SHE'LL BE BITTEN."
	.byte 0
msgNoQuestNpc: .text "I HAVE NOTHING FOR YOU, FRIEND."
	.byte 0
msgEndConversation: .text "YOU END THE CONVERSATION."
	.byte 0
msgPirateMenuHeader: .text "PIRATE TALK"
	.byte 0
msgPirateOpt0: .text "0. TELL A TALE"
	.byte 0
msgPirateOpt1: .text "1. ASK ABOUT TREASURE"
	.byte 0
msgPirateOpt2: .text "2. JOIN THE CREW"
	.byte 0
msgPirateOpt3: .text "3. LEAVE"
	.byte 0
msgPirateOpt4: .text "4. OFFER TREASURE"
	.byte 0
msgPirateOpt5: .text "5. SWORDPLAY: STANCE"
	.byte 0
msgPirateOpt6: .text "6. SWORDPLAY: FOOTWORK"
	.byte 0
msgPirateOpt7: .text "7. PRACTICE PARRY"
	.byte 0
msgPirateOpt8: .text "8. PRACTICE LUNGE"
	.byte 0
msgPirateTaleCapt: .text "CAPTAIN: A STORM, A RIDDLE, AND A CUP OF RUM."
	.byte 0
msgPirateTaleMate: .text "MATE: WE SING OF WIND AND WHEEL, BUT WE SHARE OUR GOLD."
	.byte 0
msgPirateTreasure: .text "THEY HAND YOU A SHINY COIN."
	.byte 0
msgPirateTreasureStart: .text "CAPTAIN: AH, A TREASURE HUNT! BRING ME THE TROVE." 
	.byte 0
msgPirateTreasureAlready: .text "CAPTAIN: YOU'RE ALREADY ON THE TREASURE HUNT."
	.byte 0
msgPirateNoTreasure: .text "YOU HAVE NO TREASURE TO OFFER."
	.byte 0
msgPirateNoQuest: .text "CAPTAIN: I HAVE NO NEED FOR THIS, NOT NOW."
	.byte 0
msgPirateOfferYes: .text "THE CREW CHEERS; YOUR DEED IS REWARDED."
	.byte 0
msgPirateStance: .text "CAPTAIN: SQUARE YOUR SHOULDERS; BALANCE YOUR WEIGHT."
	.byte 0
msgPirateFootwork: .text "MATE: SMALL STEPS; NEVER CROSS. LET THE BLADE DO LESS."
	.byte 0
msgPirateParry: .text "YOU PRACTICE THE PARRY; YOUR TIMING IMPROVES."
	.byte 0
msgPirateLunge: .text "YOU PRACTICE A QUICK LUNGE; YOUR FORM SHARPENS."
	.byte 0
msgBartenderMenuHeader: .text "BARTENDER"
	.byte 0
msgBartenderOpt0: .text "0. ASK ABOUT JOB"
	.byte 0
msgBartenderOpt1: .text "1. BUY ALE (1 COIN)"
	.byte 0
msgBartenderOpt2: .text "2. GIVE TIP"
	.byte 0
msgBartenderOpt3: .text "3. ANY QUESTS?"
	.byte 0
msgBartenderOpt4: .text "4. LEAVE"
	.byte 0
msgBartenderNoCoin: .text "YOU HAVE NO COINS."
	.byte 0
msgBartenderBought: .text "YOU BUY A DRINK; THE BARTENDER SMILES."
	.byte 0
msgBartenderTipThanks: .text "THE BARTENDER NODS; YOUR GENEROSITY IS NOTED."
	.byte 0
msgBartenderJob: .text "BARTENDER: I KEEP THE TAP FLOWING AND EARS OPEN."
	.byte 0
msgConductorMenuHeader: .text "CONDUCTOR"
	.byte 0
msgConductorOpt0: .text "0. ASK ABOUT WORK"
	.byte 0
msgConductorOpt1: .text "1. HEAR A TUNE"
	.byte 0
msgConductorOpt2: .text "2. JOIN THE ENSEMBLE"
	.byte 0
msgConductorOpt3: .text "3. ANY QUESTS?"
	.byte 0
msgConductorOpt4: .text "4. LEAVE"
	.byte 0
msgConductorAbout: .text "CONDUCTOR: I KEEP THE CLOCKWORK IN RHYTHM."
	.byte 0
msgConductorTune: .text "A BRISK TUNE LIFTS YOUR SPIRITS."
	.byte 0
msgConductorJoin: .text "THE CONDUCTOR NODS; YOUR RHYTHM IS ACCEPTED."
	.byte 0
msgPirateJoin: .text "YOU SWORE AN OATH; THE CREW RESPECTS IT."
	.byte 0
msgKnightMenuHeader: .text "KNIGHT"
	.byte 0
msgKnightOpt0: .text "0. ASK ABOUT HONOR"
	.byte 0
msgKnightOpt1: .text "1. OFFER KEY"
	.byte 0
msgKnightOpt2: .text "2. JOIN THE ORDER"
	.byte 0
msgKnightOpt3: .text "3. LEAVE"
	.byte 0
msgKnightOpt4: .text "4. ARENA: GUARD STANCE"
	.byte 0
msgKnightOpt5: .text "5. ARENA: FOOTWORK DRILL"
	.byte 0
msgKnightOpt6: .text "6. ARENA: PRACTICE PARRY"
	.byte 0
msgKnightOpt7: .text "7. ARENA: PRACTICE LUNGE"
	.byte 0
msgKnightAbout: .text "KNIGHT: HONOR OPENS MORE DOORS THAN KEYS."
	.byte 0

// Kendrick conversation strings
msgKendrickMenuHeader: .text "KNIGHT KENDRICK"
	.byte 0
msgKendrickOpt0: .text "0. ASK ABOUT KENDRICK"
	.byte 0
msgKendrickOpt1: .text "1. ASK ABOUT THE SPIDER PRINCESS"
	.byte 0
msgKendrickOpt2: .text "2. REQUEST A BOTTLE OF SCOTCH"
	.byte 0
msgKendrickOpt3: .text "3. GIVE SCOTCH"
	.byte 0
msgKendrickOpt4: .text "4. LEAVE"
	.byte 0
msgKendrickAbout: .text "KENDRICK: AYE, I'M SWORN TAE PROTECT HER. AYE COULD USE ANOTHER WEE DRAM O' SCOTCH."
	.byte 0
msgKendrickOfferStart: .text "KENDRICK: BRING ME A BOTTLE O' SCOTCH FROM THE TIPTSEY MAIDEN TAVERN, AN' AYE'LL OWE YE A DRINK."
	.byte 0
msgKendrickOfferAlready: .text "KENDRICK: YE'VE ALREADY PROMISED ME A BOTTLE, PAL. DON'T FORGET TA BRING IT."
	.byte 0
msgKendrickThanks: .text "KENDRICK: HA! A FINE BOTTLE. AYE'LL RAISE A GLASS TA YE. *HIC* CHEERS!"
	.byte 0
msgNeedCoinForScotch: .text "YE NEED A COIN TAE BUY THE SCOTCH AT THE TAVERN."
	.byte 0
msgBoughtScotch: .text "YE PAY A COIN AN' THE BOTTLE'S YOURS."
	.byte 0
msgKnightNoKey: .text "YOU DO NOT HAVE THE KEY."
	.byte 0
msgKnightNoQuest: .text "THE KNIGHT DOESN'T NEED THIS NOW."
	.byte 0
msgKnightThanks: .text "THE KNIGHT BLESSES YOU FOR YOUR SERVICE."
	.byte 0
msgKnightGuard: .text "KNIGHT: RAISE YOUR GUARD; LET YOUR SHOULDERS RELAX."
	.byte 0
msgKnightFootwork: .text "KNIGHT: SMALL STEPS; HEELS LIGHT. NEVER CROSS YOUR FEET."
	.byte 0
msgKnightParry: .text "YOU PRACTICE THE PARRY; YOUR TIMING IMPROVES."
	.byte 0
msgKnightLunge: .text "YOU PRACTICE A FIRM LUNGE; YOUR FORM SHARPENS."
	.byte 0

msgFairyMenuHeader: .text "FAIRY"
	.byte 0
msgFairyOpt0: .text "0. RECEIVE BLESSING"
	.byte 0
msgFairyOpt1: .text "1. ASK FOR COIN"
	.byte 0
msgFairyOpt2: .text "2. TRADE FOR NAME (1 COIN)"
	.byte 0
msgFairyOpt3: .text "3. LEAVE"
	.byte 0
msgFairyBless: .text "A SOFT LIGHT FILLS YOU; YOU FEEL LUCKIER."
	.byte 0
msgFairyGive: .text "A FAIRY DROPS A COIN INTO YOUR HAND."
	.byte 0
msgFairyTradeSuccess: .text "THE FAIRY HANDS YOU A NAME, WRAPPED IN WIND."
	.byte 0

msgPixieMenuHeader: .text "PIXIE"
	.byte 0
msgPixieOpt0: .text "0. TRICK"
	.byte 0
msgPixieOpt1: .text "1. PLAY"
	.byte 0
msgPixieOpt2: .text "2. LEAVE"
	.byte 0
msgPixieStole: .text "THE PIXIE SWIPES A LANTERN!"
	.byte 0
msgPixieNoLan: .text "THE PIXIE LOOKS DISAPPOINTED."
	.byte 0
msgPixiePlay: .text "THE PIXIE LAUGHS AND DANCES; YOU GAIN A LITTLE JOY."
	.byte 0

// Combat placeholder text
msgCombatStub: .text "YOU READY YOURSELF, BUT REAL COMBAT IS STILL IN TRAINING."
	.byte 0

// Spider Princess conversation/messages
msgSpiderMenuHeader: .text "SPIDER PRINCESS"
	.byte 0
msgSpiderOpt0: .text "0. FLIRT"
	.byte 0
msgSpiderOpt1: .text "1. WHISPER"
	.byte 0
msgSpiderOpt2: .text "2. OFFER A GIFT"
	.byte 0
msgSpiderOpt3: .text "3. LEAVE"
	.byte 0
msgSpiderFlirt: .text "THE SPIDER COOS: YOUR WORDS WRAP AROUND ME."
	.byte 0
msgSpiderWhisper: .text "THE SPIDER LEANS CLOSE AND LOWERS HER VOICE."
	.byte 0
msgSpiderOfferStart: .text "SPIDER PRINCESS: BRING ME THE MYSTIC FOR A ROMANTIC DATE."
	.byte 0
msgSpiderOfferAlready: .text "SPIDER PRINCESS: YOU'VE ALREADY PROMISED TO HELP ME."
	.byte 0
// Unseely Fae quest strings
msgUnseelyMenuHeader: .text "UNSEELY FAE"
	.byte 0
msgUnseelyOpt0: .text "0. ASK ABOUT NAMES"
	.byte 0
msgUnseelyOpt1: .text "1. REQUEST STOLEN NAME"
	.byte 0
msgUnseelyOpt2: .text "2. OFFER NAME"
	.byte 0
msgUnseelyOpt3: .text "3. LEAVE"
	.byte 0
msgUnseelyAsk: .text "UNSEELY FAE: NAMES SLIP LIKE RIBBONS; WHAT WAS YOURS?"
	.byte 0
msgUnseelyRequest: .text "UNSEELY FAE: BRING ME THE NAME THE FAIRY STOLE FROM THE GARDENS."
	.byte 0
msgUnseelyOfferAlready: .text "UNSEELY FAE: YOU'VE ALREADY PROMISED THIS TASK."
	.byte 0
msgUnseelyThanks: .text "THE UNSEELY FAE WHISPERS THE NAME BACK; HER EYES GLINT."
	.byte 0
msgUnseelyNoName: .text "YOU DO NOT HOLD THE STOLEN NAME."
	.byte 0

msgBankerMenuHeader: .text "BANKER"
	.byte 0
msgBankerOpt0: .text "0. DEPOSIT COINS"
	.byte 0
msgBankerOpt1: .text "1. WITHDRAW COINS"
	.byte 0
msgBankerOpt2: .text "2. CHECK BALANCE"
	.byte 0
msgBankerOpt3: .text "3. VAULT"
	.byte 0
msgBankerOpt4: .text "4. LEAVE"
	.byte 0
msgDepositMenu: .text "DEPOSIT WHICH COIN TYPE?"
	.byte 0
msgDepositOpt0: .text "0. COPPER"
	.byte 0
msgDepositOpt1: .text "1. SILVER"
	.byte 0
msgDepositOpt2: .text "2. GOLD"
	.byte 0
msgDepositOpt3: .text "3. BACK"
	.byte 0
msgWithdrawMenu: .text "WITHDRAW WHICH COIN TYPE?"
	.byte 0
msgWithdrawOpt0: .text "0. COPPER"
	.byte 0
msgWithdrawOpt1: .text "1. SILVER"
	.byte 0
msgWithdrawOpt2: .text "2. GOLD"
	.byte 0
msgWithdrawOpt3: .text "3. BACK"
	.byte 0
msgEnterAmount: .text "ENTER AMOUNT:"
	.byte 0
msgDepositSuccess: .text "DEPOSITED SUCCESSFULLY."
	.byte 0
msgWithdrawSuccess: .text "WITHDRAWN SUCCESSFULLY."
	.byte 0
msgNotEnough: .text "YOU DON'T HAVE ENOUGH."
	.byte 0
msgBankNotEnough: .text "BANK DOESN'T HAVE ENOUGH."
	.byte 0
msgInvalidAmount: .text "INVALID AMOUNT."
	.byte 0
msgBalance: .text "BANK BALANCE:"
	.byte 0
msgVaultRented: .text "VAULT ALREADY RENTED."
	.byte 0
msgVaultRentSuccess: .text "VAULT RENTED FOR 10 SILVER."
	.byte 0
msgVaultNoSilver: .text "YOU NEED 10 SILVER TO RENT."
	.byte 0
msgCopper: .text "COPPER: "
	.byte 0
msgSilver: .text "SILVER: "
	.byte 0
msgGold: .text "GOLD: "
	.byte 0
msgVaultAccess: .text "VAULT ACCESS"
	.byte 0
msgStoreItemOpt: .text "0. STORE ITEM"
	.byte 0
msgRetrieveItemOpt: .text "1. RETRIEVE ITEM"
	.byte 0
msgBackOpt: .text "BACK"
	.byte 0
msgStoreItem: .text "STORE WHICH ITEM?"
	.byte 0
msgRetrieveItem: .text "RETRIEVE WHICH ITEM?"
	.byte 0
msgVaultFull: .text "VAULT IS FULL."
	.byte 0
msgNoItems: .text "NO ITEMS AVAILABLE."
	.byte 0

msgPressEnter: .text "PRESS ENTER TO CONTINUE."
	.byte 0
msgDbgTrinketsAssigned: .text "DBG TRINKETS ASSIGNED: "
	.byte 0
msgDbgTrinkets: .text "DBG TRINKETS: "
	.byte 0
msgDbgObjLoc: .text "DBG OBJLOC: "
	.byte 0

// Per-choice effect tables (one table per numeric menu choice). Each table
// contains one byte per NPC (indexed by npc index). Effect types:
// 0=none,1=startQuest,2=completeQuest,3=giveItem,4=takeItem,5=addScore,6=setNpcStage
// Corresponding value tables hold the effect value (item id, score amount, npc idx, etc.)
convChoiceType_choice0:
	.byte 6,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0   // extend to 32
convChoiceVal_choice0:
	.byte 0,OBJ_MUG,OBJ_KEY,OBJ_LANTERN,OBJ_COIN,OBJ_MUG,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0

convChoiceType_choice1:
	.byte 5,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
convChoiceVal_choice1:
	.byte 2,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0

convChoiceType_choice2:
	.byte 0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
convChoiceVal_choice2:
	.byte 0,0,0,OBJ_LANTERN,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0

convChoiceType_choice3:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
convChoiceVal_choice3:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0

convChoiceType_choice4:
	.byte 0,2,2,2,0,2,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
convChoiceVal_choice4:
	.byte 0,QUEST_COIN_BARTENDER,QUEST_KEY_KNIGHT,QUEST_LANTERN_MYSTIC,0,QUEST_KENDRICK_SCOTCH,0,0,0,QUEST_UNSEELY_NAME,0,0,0,0,QUEST_LOUDEN_HEART,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0

convChoiceType_choice5:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
convChoiceVal_choice5:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0



// NPC class names (for sheets)
className0: .text "CONDUCTOR"
	.byte 0
className1: .text "BARTENDER"
	.byte 0
className2: .text "KNIGHT"
	.byte 0
	className3: .text "MYSTIC"
	.byte 0
className4: .text "FAIRY"
	.byte 0
className5: .text "PIXIE"
	.byte 0
className6: .text "PIRATE"
	.byte 0

classNameLo:
	.byte <className0,<className1,<className2,<className3,<className4,<className5,<className6
classNameHi:
	.byte >className0,>className1,>className2,>className3,>className4,>className5,>className6

// Simple class stat tables (base HP and HP per level)
classBaseHp:
	.byte 20, 16, 24, 12, 10, 8, 18
classHpPerLevel:
	.byte 5, 3, 6, 4, 2, 2, 5

// NPC static attributes per NPC index
npcClassIdx:
	.byte 0,1,2,3,4,2,4,6,6,4,3,2,2,1,3,4
	.byte 4,3,2,2,1,4,0,0,0,0,0,0,0,0,0,0
npcLevel:
	.byte 1,1,2,3,1,1,1,2,1,1,1,2,2,1,1,2
	.byte 3,2,4,3,2,4,1,1,1,1,1,1,1,1,1,1
npcScoreLo:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
npcScoreHi:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// NPC current HP (persisted across saves) - initialized to max per-class/level guesses
npcCurHp:
	.byte 25,19,36,24,12,30,12,28,23,12,16,36,36,19,16,14
	.byte 16,20,48,42,22,18,10,10,10,10,10,10,10,10,10,10

// Playable classes (for player)
playClass0: .text "MAGE"
	.byte 0
playClass1: .text "KNIGHT"
	.byte 0
playClass2: .text "HEALER"
	.byte 0
playClass3: .text "BARD"
	.byte 0
playClass4: .text "WIZARD"
	.byte 0
playClassLo:
	.byte <playClass0,<playClass1,<playClass2,<playClass3,<playClass4
playClassHi:
	.byte >playClass0,>playClass1,>playClass2,>playClass3,>playClass4
playClassBaseHp:
	.byte 12, 24, 14, 10, 10
playClassHpPerLevel:
	.byte 4, 6, 5, 2, 3

// computePlayerMaxHp: returns max HP in tmpHp
computePlayerMaxHp:
	// load base for player's class idx
	lda playerClassIdx
	tay
	lda playClassBaseHp,y
	sta tmpHp
	lda playClassHpPerLevel,y
	sta tmpPer
	// load level
	lda currentLevel
	sta tmpCnt
@pc_hp_loop:
	lda tmpCnt
	beq @pc_hp_done
	lda tmpHp
	clc
	adc tmpPer
	sta tmpHp
	dec tmpCnt
	jmp @pc_hp_loop
@pc_hp_done:
	// Apply any session-only bonus to max HP
	lda tmpHp
	clc
	adc playerHpBonus
	sta tmpHp
	rts

// parseNumber: parses inputBuf as decimal number, returns in A, 0 if invalid
parseNumber:
	lda #0
	sta tmpNumber
	ldx #0
@parse_loop:
	lda inputBuf,x
	beq @parse_done
	cmp #'0'
	bcc @parse_invalid
	cmp #'9'+1
	bcs @parse_invalid
	sec
	sbc #'0'
	pha
	lda tmpNumber
	asl
	asl
	adc tmpNumber
	asl  // *10
	sta tmpNumber
	pla
	clc
	adc tmpNumber
	sta tmpNumber
	inx
	cpx #4  // max 3 digits
	bcc @parse_loop
@parse_invalid:
	lda #0
	sta tmpNumber
@parse_done:
	lda tmpNumber
	rts

// printDecimal: prints A as decimal (0-255)
printDecimal:
	sta tmpNumber
	lda #0
	sta tmpDigit
	// Hundreds
@pd_hundreds:
	lda tmpDigit
	cmp #2
	bcs @pd_tens
	lda tmpNumber
	cmp #100
	bcc @pd_hundreds_done
	sec
	sbc #100
	sta tmpNumber
	inc tmpDigit
	jmp @pd_hundreds
@pd_hundreds_done:
	lda tmpDigit
	beq @pd_tens  // skip leading zero
	clc
	adc #'0'
	jsr printChar
@pd_tens:
	lda #0
	sta tmpDigit
@pd_tens_loop:
	lda tmpNumber
	cmp #10
	bcc @pd_tens_done
	sec
	sbc #10
	sta tmpNumber
	inc tmpDigit
	jmp @pd_tens_loop
@pd_tens_done:
	lda tmpDigit
	clc
	adc #'0'
	jsr printChar
@pd_ones:
	lda tmpNumber
	clc
	adc #'0'
	jsr printChar
	rts

// assignRandomTrinkets: assigns 5 random trinkets to player
assignRandomTrinkets:
	ldx #0
@assign_loop:
	jsr randomByte
	and #31
	sta playerTrinkets,x
	inx
	cpx #5
	bne @assign_loop
	rts

// randomByte: simple LFSR random number generator
randomByte:
	lda randomSeed
	asl
	eor randomSeed
	adc #$47
	sta randomSeed
	rts

randomSeed: .byte 123

// assignNpcTrinkets: assigns random trinkets to NPC if not already. X = npc index
assignNpcTrinkets:
	lda npcTrinketsAssigned,x
	bne @already_assigned
	// assign 0-3 trinkets
	jsr randomByte
	and #3
	sta tmpNumber
	beq @no_trinkets
	// offset = x * 3
	txa
	sta tmpCnt
	asl
	adc tmpCnt
	tay
	lda tmpNumber
	sta tmpCnt2
@npc_trinket_loop:
	jsr randomByte
	and #31
	sta npcTrinkets,y
	iny
	dec tmpCnt2
	bne @npc_trinket_loop
@no_trinkets:
	lda #1
	sta npcTrinketsAssigned,x
@already_assigned:
	rts

npcTrinketsAssigned: .fill 32, 0

// tradeTrinkets: trade trinkets with NPC
tradeTrinkets:
	jsr clearScreen
	ldx tmpNpcIdx
	// Show player trinkets
	lda #<msgYourTrinkets
	sta ZP_PTR
	lda #>msgYourTrinkets
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	ldx #0
@show_player:
	lda playerTrinkets,x
	cmp #$FF
	beq @player_next
	txa
	pha
	lda tmpCnt
	jsr printDecimal
	lda #'.'
	jsr printChar
	lda #' '
	jsr printChar
	pla
	tax
	lda playerTrinkets,x
	tay
	lda trinketNamesLo,y
	sta ZP_PTR
	lda trinketNamesHi,y
	sta ZP_PTR+1
	jsr printZ
	jsr newline
@player_next:
	inx
	cpx #5
	bne @show_player
	// Show NPC trinkets
	lda #<msgNpcTrinkets
	sta ZP_PTR
	lda #>msgNpcTrinkets
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	ldx tmpNpcIdx
	txa
	sta tmpCnt
	asl
	adc tmpCnt
	tay
	ldx #0
@show_npc:
	lda npcTrinkets,y
	cmp #$FF
	beq @npc_next
	txa
	pha
	lda tmpCnt2
	jsr printDecimal
	lda #'.'
	jsr printChar
	lda #' '
	jsr printChar
	pla
	tax
	lda npcTrinkets,y
	tay
	lda trinketNamesLo,y
	sta ZP_PTR
	lda trinketNamesHi,y
	sta ZP_PTR+1
	jsr printZ
	jsr newline
@npc_next:
	iny
	inx
	cpx #3
	bne @show_npc
	// Ask for player trinket
	lda #<msgSelectYour
	sta ZP_PTR
	lda #>msgSelectYour
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	cmp #5
	bcs @trade_invalid
	ldx tmpNumber
	lda playerTrinkets,x
	cmp #$FF
	beq @trade_invalid
	sta tmpTrinketPlayer
	// Ask for NPC trinket
	lda #<msgSelectNpc
	sta ZP_PTR
	lda #>msgSelectNpc
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	jsr setCursorPrompt
	jsr readLine
	jsr parseNumber
	cmp #3
	bcs @trade_invalid
	ldy tmpNumber
	ldx tmpNpcIdx
	txa
	sta tmpCnt
	asl
	adc tmpCnt
	sty tmpCnt2
	adc tmpCnt2
	tay
	lda npcTrinkets,y
	cmp #$FF
	beq @trade_invalid
	sta tmpTrinketNpc
	// Swap
	ldx tmpNumber  // player slot
	lda tmpTrinketNpc
	sta playerTrinkets,x
	ldx tmpNpcIdx
	txa
	sta tmpCnt
	asl
	adc tmpCnt
	adc tmpCnt2
	tay
	lda tmpTrinketPlayer
	sta npcTrinkets,y
	jsr saveGame
	lda #<msgTradeSuccess
	sta lastMsgLo
	lda #>msgTradeSuccess
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	rts
@trade_invalid:
	lda #<msgInvalidAmount
	sta lastMsgLo
	lda #>msgInvalidAmount
	sta lastMsgHi
	jsr render
	jsr setCursorPrompt
	jsr readLine
	rts

tmpTrinketPlayer: .byte 0
tmpTrinketNpc: .byte 0

// updateExchangeRates: adjusts rates based on bank supply
updateExchangeRates:
	lda bankCopper
	cmp #50
	bcc @copper_normal
	lda #11
	sta exchangeCopperToSilver
	jmp @silver_check
@copper_normal:
	lda #10
	sta exchangeCopperToSilver
@silver_check:
	lda bankSilver
	cmp #20
	bcc @silver_normal
	lda #11
	sta exchangeSilverToGold
	rts
@silver_normal:
	lda #10
	sta exchangeSilverToGold
	rts

// computeNpcMaxHp: expects X = npc index; returns max HP in tmpHp
computeNpcMaxHp:
	// load npc's class index
	lda npcClassIdx,x
	tay
	lda classBaseHp,y
	sta tmpHp
	lda classHpPerLevel,y
	sta tmpPer
	// load npc's level
	lda npcLevel,x
	sta tmpCnt
@npc_max_hp_loop:
    lda tmpCnt
    beq @npc_max_hp_done
    lda tmpHp
    clc
    adc tmpPer
    sta tmpHp
    dec tmpCnt
    jmp @npc_max_hp_loop
@npc_max_hp_done:
    rts

// --- Data: Objects ---
objName0: .text "LANTERN"
	.byte 0
objName1: .text "COIN"
	.byte 0
objName2: .text "MUG"
	.byte 0
objName3: .text "KEY"
	.byte 0
objName4: .text "TREASURE"
	.byte 0
objName5: .text "STOLEN NAME"
	.byte 0
objName6: .text "HEART"
	.byte 0
objName7: .text "PINECONE"
	.byte 0
objName8: .text "SHELL"
	.byte 0
objName9: .text "BOTTLE OF SCOTCH"
	.byte 0
objName10: .text "PROTECTION WARD"
	.byte 0

objNameLo:
	.byte <objName0,<objName1,<objName2,<objName3,<objName4,<objName5,<objName6,<objName7,<objName8,<objName9,<objName10
objNameHi:
	.byte >objName0,>objName1,>objName2,>objName3,>objName4,>objName5,>objName6,>objName7,>objName8,>objName9,>objName10

trinketNamesLo:
	.byte <trinket0,<trinket1,<trinket2,<trinket3,<trinket4,<trinket5,<trinket6,<trinket7,<trinket8,<trinket9,<trinket10,<trinket11,<trinket12,<trinket13,<trinket14,<trinket15
	.byte <trinket16,<trinket17,<trinket18,<trinket19,<trinket20,<trinket21,<trinket22,<trinket23,<trinket24,<trinket25,<trinket26,<trinket27,<trinket28,<trinket29,<trinket30,<trinket31
trinketNamesHi:
	.byte >trinket0,>trinket1,>trinket2,>trinket3,>trinket4,>trinket5,>trinket6,>trinket7,>trinket8,>trinket9,>trinket10,>trinket11,>trinket12,>trinket13,>trinket14,>trinket15
	.byte >trinket16,>trinket17,>trinket18,>trinket19,>trinket20,>trinket21,>trinket22,>trinket23,>trinket24,>trinket25,>trinket26,>trinket27,>trinket28,>trinket29,>trinket30,>trinket31

trinket0: .text "LUCKY RABBIT FOOT"
	.byte 0
trinket1: .text "SILVER LOCKET"
	.byte 0
trinket2: .text "CRYSTAL PENDANT"
	.byte 0
trinket3: .text "IRON KEYCHAIN"
	.byte 0
trinket4: .text "WOODEN TALISMAN"
	.byte 0
trinket5: .text "GOLDEN RING"
	.byte 0
trinket6: .text "FEATHER QUILL"
	.byte 0
trinket7: .text "STONE AMULET"
	.byte 0
trinket8: .text "BRASS COMPASS"
	.byte 0
trinket9: .text "VELVET RIBBON"
	.byte 0
trinket10: .text "COPPER COIN"
	.byte 0
trinket11: .text "GLASS MARBLE"
	.byte 0
trinket12: .text "LEATHER BRACELET"
	.byte 0
trinket13: .text "BONE WHISTLE"
	.byte 0
trinket14: .text "SILK HANDKERCHIEF"
	.byte 0
trinket15: .text "PEARL EARRING"
	.byte 0
trinket16: .text "TIN BADGE"
	.byte 0
trinket17: .text "WAX SEAL"
	.byte 0
trinket18: .text "CLOTH PATCH"
	.byte 0
trinket19: .text "METAL BUTTON"
	.byte 0
trinket20: .text "SHELL NECKLACE"
	.byte 0
trinket21: .text "FEATHER CAP"
	.byte 0
trinket22: .text "WOODEN PIPE"
	.byte 0
trinket23: .text "GLASS VIAL"
	.byte 0
trinket24: .text "LEATHER GLOVE"
	.byte 0
trinket25: .text "BONE DICE"
	.byte 0
trinket26: .text "SILK SCARF"
	.byte 0
trinket27: .text "PEARL BROOCH"
	.byte 0
trinket28: .text "TIN WHISTLE"
	.byte 0
trinket29: .text "WAX CANDLE"
	.byte 0
trinket30: .text "CLOTH SASH"
	.byte 0
trinket31: .text "METAL NAIL"
	.byte 0

objInspect0: .text "A BRASS LANTERN. IT COULD LIGHT DARK PATHS."
	.byte 0
objInspect1: .text "A SMALL COIN, WARM FROM MANY HANDS."
	.byte 0
objInspect2: .text "A TIN MUG WITH A FRESH FOAM RING."
	.byte 0
objInspect3: .text "A RUSTED KEY. IT WANTS A STORY OF ITS OWN."
	.byte 0
objInspect4: .text "A CHEST OF SILVER AND STORIES."
	.byte 0
objInspect5: .text "A NAME WRITTEN ON AIR."
	.byte 0
objInspect6: .text "A HEART, STILL WARM."
	.byte 0
objInspect7: .text "LANDBOUND CORAL: A DRY, PERFUMED PINECONE."
	.byte 0
objInspect8: .text "A SPARKLY SEA SHELL THAT CATCHES THE LIGHT."
	.byte 0
objInspect9: .text "A WELL-SEALED BOTTLE OF SCOTCH. SMELLS STRONG."
	.byte 0
objInspect10: .text "A RUNED TALISMAN THAT THRUMS WITH QUIET POWER."
	.byte 0

objInspectLo:
	.byte <objInspect0,<objInspect1,<objInspect2,<objInspect3,<objInspect4,<objInspect5,<objInspect6,<objInspect7,<objInspect8,<objInspect9,<objInspect10
objInspectHi:
	.byte >objInspect0,>objInspect1,>objInspect2,>objInspect3,>objInspect4,>objInspect5,>objInspect6,>objInspect7,>objInspect8,>objInspect9,>objInspect10

// --- Keywords ---
kwNorth:      .text "NORTH"
	.byte 0
kwSouth:      .text "SOUTH"
	.byte 0
kwEast:       .text "EAST"
	.byte 0
kwWest:       .text "WEST"
	.byte 0
kwNortheast:  .text "NORTHEAST"
	.byte 0
kwNorthwest:  .text "NORTHWEST"
	.byte 0
kwSoutheast:  .text "SOUTHEAST"
	.byte 0
kwSouthwest:  .text "SOUTHWEST"
	.byte 0
kwInspect:    .text "INSPECT"
	.byte 0
kwLook:       .text "LOOK"
	.byte 0
kwExamine:    .text "EXAMINE"
	.byte 0
kwTake:       .text "TAKE"
	.byte 0
kwGet:        .text "GET"
	.byte 0
kwPick:       .text "PICK"
	.byte 0
kwUp:         .text "UP"
	.byte 0
kwDrop:       .text "DROP"
	.byte 0
kwSet:        .text "SET"
	.byte 0
kwDown:       .text "DOWN"
	.byte 0
kwGive:       .text "GIVE"
	.byte 0
kwTalk:       .text "TALK"
	.byte 0
kwFight:      .text "FIGHT"
	.byte 0
kwCharacters: .text "CHARACTERS"
	.byte 0
kwInventory:  .text "INVENTORY"
	.byte 0

kwTo:         .text "TO"
	.byte 0
kwThe:        .text "THE"
	.byte 0
kwAn:         .text "AN"
	.byte 0

kwLantern: .text "LANTERN"
	.byte 0
kwCoin:    .text "COIN"
	.byte 0
kwMug:     .text "MUG"
	.byte 0
kwBottle:  .text "BOTTLE"
	.byte 0
kwScotch:  .text "SCOTCH"
	.byte 0
kwWard:    .text "WARD"
	.byte 0
kwProtection: .text "PROTECTION"
	.byte 0
kwKey:     .text "KEY"
	.byte 0
kwHeart:   .text "HEART"
	.byte 0
kwPinecone: .text "PINECONE"
	.byte 0
kwShell:    .text "SHELL"
	.byte 0

kwConductor: .text "CONDUCTOR"
	.byte 0
kwBartender: .text "BARTENDER"
	.byte 0
kwKnight:    .text "KNIGHT"
	.byte 0
kwMystic:     .text "MYSTIC"
	.byte 0
kwFairy:     .text "FAIRY"
	.byte 0
kwPixie:     .text "PIXIE"
	.byte 0
kwApollonia: .text "APOLLONIA"
	.byte 0
kwStatue:    .text "STATUE"
	.byte 0
kwAlyster:   .text "ALYSTER"
	.byte 0
kwDragonTrainer: .text "DRAGON TRAINER"
	.byte 0
kwTroll:    .text "TROLL"
	.byte 0
kwBridge:   .text "BRIDGE"
	.byte 0
kwTosh:     .text "TOSH"
	.byte 0
kwTosher:   .text "TOSHER"
	.byte 0
kwLouden:   .text "LOUDEN"
	.byte 0
kwSpirit:   .text "SPIRIT"
	.byte 0
kwMermaid:  .text "MERMAID"
	.byte 0
kwWarlock:  .text "WARLOCK"
	.byte 0
kwCandyWitch: .text "CANDY WITCH"
	.byte 0
kwKora:      .text "KORA"
	.byte 0

kwStall:     .text "STALL"
	.byte 0
kwSign:      .text "SIGN"
	.byte 0
kwPortal:    .text "PORTAL"
	.byte 0

kwSave:      .text "SAVE"
	.byte 0
kwLoad:      .text "LOAD"
	.byte 0
kwWait:      .text "WAIT"
	.byte 0
kwRest:      .text "REST"
	.byte 0
kwNext:      .text "NEXT"
	.byte 0
kwStatus:    .text "STATUS"
	.byte 0
kwQuest:     .text "QUEST"
	.byte 0

kwChart:     .text "CHART"
	.byte 0

kwHelp:      .text "HELP"
	.byte 0
kwSay:       .text "SAY"
	.byte 0
kwKoraPhrase: .text "SCOTCH ON THE KNIGHT"
	.byte 0

// --- UI Strings / Messages ---
strExits:  .text "EXITS: "
	.byte 0
strHelp1:  .text "N/E/S/W MOVE  I INV  C CHARS  T TALK"
	.byte 0
strHelp2:  .text "WAIT STATUS SAVE LOAD INSPECT M MUSIC"
	.byte 0
strPrompt: .text "> "
	.byte 0

strSeason: .text "SEASON "
	.byte 0
strSeasonOff: .text "OFF"
	.byte 0
strSeasonMythos: .text "MYTHOS"
	.byte 0
strSeasonLore: .text "LORE"
	.byte 0
strSeasonAurora: .text "AURORA"
	.byte 0

strSavingUser: .text "(updating your user on the disk)"
	.byte 0

strWeek:  .text "WEEK "
	.byte 0
strScore: .text "  SCORE "
	.byte 0
strSheetTitle: .text "CHARACTER SHEET"
	.byte 0
strName:  .text "NAME: "
	.byte 0
strDisplay: .text "DISPLAY: "
	.byte 0
strClass: .text "CLASS: "
	.byte 0
strRace:  .text "RACE: "
	.byte 0
strLevel: .text "LEVEL "
	.byte 0
strQuest: .text "  QUEST "
	.byte 0
strQuestActive: .text "ACTIVE"
	.byte 0
strHP:   .text "HP: "
	.byte 0

strCharacters: .text "CHARACTERS: "
	.byte 0
strInventory:  .text "INVENTORY: "
strTrinkets:   .text "TRINKETS: "
	.byte 0
strItems:      .text "ITEMS: "
	.byte 0
strFightHeader: .text "FIGHT: "
	.byte 0
strFightOption: .text "FIGHT"
	.byte 0
strGold:       .text "GOLD: "
	.byte 0
strSilver:     .text "SILVER: "
	.byte 0
strCopper:     .text "COPPER: "
	.byte 0
strNone:       .text "(NONE)"
	.byte 0
strEmpty:      .text "(EMPTY)"
	.byte 0
strSpace:      .text " "
	.byte 0
strPlus:       .text "+"
	.byte 0
strMaxHpSession: .text " MAX HP (SESSION)"
	.byte 0
strNoData: .text "(no data)"
	.byte 0

// npcBit split into low/high bytes to support up to 16 NPCs
npcBitLo:
	.byte %00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
npcBitHi:
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000

// Additional bit masks for NPC indices 16..31
npcBitB2:
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
	.byte %00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
npcBitB3:
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
	.byte %00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000

npcName0: .text "CONDUCTOR"
	.byte 0
npcName1: .text "BARTENDER"
	.byte 0
npcName2: .text "KNIGHT"
	.byte 0
npcName3: .text "MYSTIC"
	.byte 0
npcName4: .text "FAIRY"
	.byte 0
npcName5: .text "KNIGHT KENDRICK"
	.byte 0
npcName6: .text "SPIDER PRINCESS"
	.byte 0
npcName7: .text "PIRATE CAPTAIN"
	.byte 0
npcName8: .text "WARLOCK"
	.byte 0
npcName9: .text "UNSEELY FAE"
	.byte 0
npcName10: .text "SAINT APOLLONIA"
	.byte 0
npcName11: .text "DRAGON TRAINER ALYSTER"
	.byte 0
npcName12: .text "BRIDGE THE TROLL"
	.byte 0
npcName13: .text "TOSH THE TOSHER"
	.byte 0
npcName14: .text "SPIRIT OF LOUDEN"
	.byte 0
npcName15: .text "MERMAID"
	.byte 0
npcName16: .text "CANDY WITCH"
	.byte 0
	npcName17: .text "KORA"
	.byte 0
npcName18: .text "DORIAN"
	.byte 0
npcName19: .text "DRAGON TRAINER VASHTEE"
	.byte 0
npcName20: .text "TRADING COMPANY OWNER"
	.byte 0
npcName21: .text "FROST WEAVERS QUEEN"
	.byte 0
npcName22: .text "BANKER"
	.byte 0
npcNameUnknown: .text "(UNKNOWN)"
	.byte 0

npcNameLo:
	.byte <npcName0,<npcName1,<npcName2,<npcName3,<npcName4,<npcName5,<npcName6,<npcName7,<npcName8,<npcName9,<npcName10,<npcName11,<npcName12,<npcName13,<npcName14,<npcName15
	.byte <npcName16,<npcName17,<npcName18,<npcName19,<npcName20,<npcName21,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown,<npcNameUnknown
npcNameHi:
	.byte >npcName0,>npcName1,>npcName2,>npcName3,>npcName4,>npcName5,>npcName6,>npcName7,>npcName8,>npcName9,>npcName10,>npcName11,>npcName12,>npcName13,>npcName14,>npcName15
	.byte >npcName16,>npcName17,>npcName18,>npcName19,>npcName20,>npcName21,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown,>npcNameUnknown

msgWelcome:    .text "WELCOME TO EVERLAND. TYPE N E S W, OR INSPECT/TAKE/DROP/GIVE."
	.byte 0
msgOk:         .text ""
	.byte 0

msgChart1: .text "PETSCII CHART (FOR MAP GLYPHS)"
	.byte 0
msgChart2: .text "ROW LABEL IS HEX. GLYPHS FOLLOW."
	.byte 0
msgChartRange1: .text "RANGE $60-$7F:"
	.byte 0
msgChartRange2: .text "RANGE $A0-$FF:"
	.byte 0
msgChart3: .text "PRESS ANY KEY TO RETURN"
	.byte 0
msgUnknown:    .text "I DIDN'T UNDERSTAND. TRY: N E S W, INSPECT <OBJ>, TAKE <OBJ>."
	.byte 0
msgHelp:       .text "help: n/e/s/w move, t talk, i inv, look"
	.byte 0

// Prompt for given name entry
msgAskNpcName: .text "ENTER A GIVEN NAME FOR:" 
	.byte 0

// Runtime buffer: flat block of NPC_COUNT * NPC_GIVEN_NAME_LEN bytes
npcGivenNames:
	// NPC 0 (CONDUCTOR) - given name set to "bob"
	.text "bob"
	.fill (NPC_GIVEN_NAME_LEN - 3), 0
	// NPC 1 (BARTENDER) - given name set to "sirus"
	.text "sirus"
	.fill (NPC_GIVEN_NAME_LEN - 5), 0
	// NPC 2 (KNIGHT) - given name set to "damian"
	.text "damian"
	.fill (NPC_GIVEN_NAME_LEN - 6), 0
	// NPC 3 (MYSTIC) - given name set to "mela"
	.text "mela"
	.fill (NPC_GIVEN_NAME_LEN - 4), 0
	// NPC 4 (FAIRY) - given name set to "Lezule"
	.text "lezule"
	.fill (NPC_GIVEN_NAME_LEN - 6), 0
	// NPC 5 (KENDRICK) - given name set to "kendrick"
	.text "kendrick"
	.fill (NPC_GIVEN_NAME_LEN - 8), 0
	// NPC 6 (SPIDER_PRINCESS) - given name set to "unknown"
	.text "unknown"
	.fill (NPC_GIVEN_NAME_LEN - 7), 0
	// NPC 7 (PIRATE_CAPTAIN) - given name set to "Bonnie Red Boots"
	.text "bonnie red boots"
	// NPC 8 (WARLOCK) - given name set to "dorian"
	.text "dorian"
	.fill (NPC_GIVEN_NAME_LEN - 6), 0
	// NPC 9 (UNSEELY_FAE) - given name set to "tamara"
	.text "tamara"
	.fill (NPC_GIVEN_NAME_LEN - 6), 0
	// NPC 10 (APOLLONIA) - given name set to "apolonia"
	.text "apolonia"
	.fill (NPC_GIVEN_NAME_LEN - 9), 0
	// NPC 11 (ALYSTER) - given name set to "alyster"
	.text "alyster"
	.fill (NPC_GIVEN_NAME_LEN - 7), 0
	// NPC 12 (TROLL) - given name set to "bridge"
	.text "bridge"
	.fill (NPC_GIVEN_NAME_LEN - 6), 0
	// NPC 13 (TOSH) - given name set to "tosh"
	.text "tosh"
	.fill (NPC_GIVEN_NAME_LEN - 4), 0
	// NPC 14 (LOUDEN) - given name set to "louden"
	.text "louden"
	.fill (NPC_GIVEN_NAME_LEN - 6), 0
	// NPC 15 (MERMAID) - given name set to "talayla"
	.text "talayla"
	.fill (NPC_GIVEN_NAME_LEN - 7), 0
	// NPC 16 (CANDY_WITCH) - given name set to "Wen Weaver"
	.text "wen weaver"
	.fill (NPC_GIVEN_NAME_LEN - 10), 0
	// NPC 17 (KORA) - given name set to "kora"
	.text "kora"
	.fill (NPC_GIVEN_NAME_LEN - 4), 0
	// NPC 18 (ALPHA WOLFRIC) - given name set to "vassa"
	.text "vassa"
	.fill (NPC_GIVEN_NAME_LEN - 5), 0
	// NPC 19 (VASHTEE) - given name set to "vashtee"
	.text "vashtee"
	.fill (NPC_GIVEN_NAME_LEN - 7), 0
	// NPC 20 (TRADING COMPANY OWNER) - given name set to "van beauler"
	.text "van beauler"
	.fill (NPC_GIVEN_NAME_LEN - 11), 0
	// NPC 20
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 21
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 22 (BANKER) - given name set to "bert"
	.text "bert"
	.fill (NPC_GIVEN_NAME_LEN - 4), 0
	// NPC 23
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 24
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 25
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 26
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 27
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 28
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 29
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 30
	.fill NPC_GIVEN_NAME_LEN, 0
	// NPC 31
	.fill NPC_GIVEN_NAME_LEN, 0

// Pointer tables for each NPC's given-name slot (low/high)
npcGivenNamePtrLo:
	.byte <npcGivenNames+0,<npcGivenNames+16,<npcGivenNames+32,<npcGivenNames+48,<npcGivenNames+64,<npcGivenNames+80,<npcGivenNames+96,<npcGivenNames+112,<npcGivenNames+128,<npcGivenNames+144,<npcGivenNames+160,<npcGivenNames+176,<npcGivenNames+192,<npcGivenNames+208,<npcGivenNames+224,<npcGivenNames+240
	.byte <npcGivenNames+256,<npcGivenNames+272,<npcGivenNames+288,<npcGivenNames+304,<npcGivenNames+320,<npcGivenNames+336,<npcGivenNames+352,<npcGivenNames+368,<npcGivenNames+384,<npcGivenNames+400,<npcGivenNames+416,<npcGivenNames+432,<npcGivenNames+448,<npcGivenNames+464,<npcGivenNames+480,<npcGivenNames+496
npcGivenNamePtrHi:
	.byte >npcGivenNames+0,>npcGivenNames+16,>npcGivenNames+32,>npcGivenNames+48,>npcGivenNames+64,>npcGivenNames+80,>npcGivenNames+96,>npcGivenNames+112,>npcGivenNames+128,>npcGivenNames+144,>npcGivenNames+160,>npcGivenNames+176,>npcGivenNames+192,>npcGivenNames+208,>npcGivenNames+224,>npcGivenNames+240
	.byte >npcGivenNames+256,>npcGivenNames+272,>npcGivenNames+288,>npcGivenNames+304,>npcGivenNames+320,>npcGivenNames+336,>npcGivenNames+352,>npcGivenNames+368,>npcGivenNames+384,>npcGivenNames+400,>npcGivenNames+416,>npcGivenNames+432,>npcGivenNames+448,>npcGivenNames+464,>npcGivenNames+480,>npcGivenNames+496

// Loaded staging area for given names (used during tryLoadGame/commitLoadedState)
loadedGivenNames:
	.fill NPC_COUNT * NPC_GIVEN_NAME_LEN, 0

// NPC coin balances (reset on game start)
npcGold: .fill NPC_COUNT, 0
npcSilver: .fill NPC_COUNT, 0
npcCopper: .fill NPC_COUNT, 0

// Temp linear index used during interactive setup
givenNameLoopIndex: .byte 0
msgNoWay:      .text "YOU CAN'T GO THAT WAY."
	.byte 0
msgMoved:      .text "YOU MOVE."
	.byte 0
msgLook:       .text "YOU TAKE IN YOUR SURROUNDINGS."
	.byte 0
msgTakeWhat:   .text "TAKE WHAT? (LANTERN/COIN/MUG/KEY)"
	.byte 0
msgDropWhat:   .text "DROP WHAT?"
	.byte 0
msgGiveWhat:   .text "GIVE WHAT?"
	.byte 0
msgDontKnow:   .text "I DON'T RECOGNIZE THAT."
	.byte 0
msgTradeTrinkets: .text "TRADE TRINKETS"
	.byte 0
msgYourTrinkets: .text "YOUR TRINKETS:"
	.byte 0
msgNpcTrinkets: .text "NPC TRINKETS:"
	.byte 0
msgSelectYour: .text "SELECT YOUR TRINKET (0-4):"
	.byte 0
msgSelectNpc: .text "SELECT NPC TRINKET (0-2):"
	.byte 0
msgTradeSuccess: .text "TRADE COMPLETED."
	.byte 0
msgNotHere:    .text "YOU DON'T SEE THAT HERE."
	.byte 0
msgNpcNotHere: .text "THAT PERSON ISN'T HERE."
	.byte 0
msgTook:       .text "TAKEN."
	.byte 0
msgDropped:    .text "DROPPED."
	.byte 0
msgNotCarrying:.text "YOU ARE NOT CARRYING THAT."
	.byte 0
msgNoOne:      .text "NO ONE IS HERE TO TALK TO."
	.byte 0
msgNoChars:    .text "NO CHARACTERS ARE HERE."
	.byte 0
msgGave:       .text "GIVEN."
	.byte 0

msgCoinRec:    .text "YOU RECEIVE A COIN."
	.byte 0

// --- Simple log buffer and name used for write-only event logging to device 8 ---
logName: .byte 'E','V','L','O','G'
logBuf:  .byte 'G', ' ', '0', $0D

msgDbgCoinInv:    .text "DEBUG: COIN IN INVENTORY."
	.byte 0
msgDbgCoinNowhere:.text "DEBUG: COIN NOWHERE."
	.byte 0
msgDbgCoinUpdated:.text "DEBUG: COIN LOCATION UPDATED."
	.byte 0

// Auth prompt context tags
msgTagUser:    .text "[USERNAME]"
	.byte 0
msgTagDisplay: .text "[DISPLAY]"
	.byte 0
msgTagClass:   .text "[CLASS]"
	.byte 0
msgTagPin:     .text "[PIN]"
	.byte 0
msgTagMonth:   .text "[MONTH]"
	.byte 0
msgTagWeek:    .text "[WEEK]"
	.byte 0


msgStall:      .text "A BUSY MARKET STALL: BELLS, RIBBONS, AND A NOTE: 'TRADE IN STORIES'."
	.byte 0
msgSign:       .text "THE SIGN READS: 'EVERLAND ARRIVALS'. SOMEONE SCRATCHED 'ASK THE CONDUCTOR' BELOW."
	.byte 0
msgPortal:     .text "THE PORTAL SHIMMERS WITH FRACTURED LIGHT. A THIN RING HUMS AT ITS EDGE."
	.byte 0

msgAskUser:     .text "USERNAME?"
	.byte 0
msgAskDisplay:  .text "DISPLAY NAME?"
	.byte 0
msgAskClass:    .text "CLASS (KNIGHT, PALADIN, MAGE, BARD, HEALER, CLERIC):"
	.byte 0
msgAskRace:     .text "RACE (HUMAN, TROLL, ELF, DRAGON):"
	.byte 0
msgAskPin:      .text "SET PIN (NUMBERS)"
	.byte 0
msgAskPinLogin: .text "PIN?"
	.byte 0
msgBadPin:      .text "WRONG PIN."
	.byte 0
// msgAskMonth/msgAskWeek no longer used (month/week set from C64 clock)
msgAskMonth:    .text ""
	.byte 0
msgAskWeek:     .text ""
	.byte 0
msgCreated:     .text "PROFILE CREATED AND SAVED."
	.byte 0
msgSaved:       .text "SAVED."
	.byte 0
msgLoaded:      .text "LOADED."
	.byte 0
msgMusicOn:     .text "MUSIC ON."
	.byte 0
msgMusicOff:    .text "MUSIC OFF."
	.byte 0
msgLoadFail:    .text "LOAD FAILED."
	.byte 0
msgWeekAdvanced:.text "A WEEK PASSES. NEW STORIES STIR."
	.byte 0
msgQuestDone:   .text "QUEST COMPLETE!"
	.byte 0
msgNoQuest:     .text "NO ACTIVE QUEST."
	.byte 0
msgWelcomeLine1: .text "WELCOME TO EVERLAND PARK."
	.byte 0
msgWelcomeLine2: .text "AN IMMERSIVE MULTIPLAYER ROLEPLAY ADVENTURE."
	.byte 0
msgWelcomeBack: .text "WELCOME BACK, "
	.byte 0
msgExclaim:     .text "!"
	.byte 0

// Season / weather lines
seasonOff:    .text "OFF SEASON 45F: GREY SKIES"
	.byte 0
seasonMythos: .text "MYTHOS 72F: SPARKLING AIR"
	.byte 0
seasonLore:   .text "LORE 55F: CRISP LEAVES"
	.byte 0
seasonAurora: .text "AURORA 30F: FESTIVE LIGHTS"
	.byte 0

seasonLineLo:
	.byte <seasonOff,<seasonMythos,<seasonLore,<seasonAurora
seasonLineHi:
	.byte >seasonOff,>seasonMythos,>seasonLore,>seasonAurora

// Quest names/details
questName0: .text "PAY THE BARTENDER"
	.byte 0
questName1: .text "BRING KEY TO KNIGHT"
	.byte 0
questName2: .text "LIGHT FOR THE MYSTIC"
	.byte 0
questName3: .text "LURE THE MYSTIC"
	.byte 0
questName4: .text "PLANT BLACK ROSES"
	.byte 0
questName5: .text "RECOVER STOLEN NAME"
	.byte 0
questName6: .text "RECOVER STOLEN NAME"
	.byte 0
questNameApollonia: .text "LEAVE AN OFFERING"
	.byte 0
questNameLouden: .text "RESTORE LOUDEN'S HEART"
	.byte 0
questNameMermaid: .text "TRADE LAND FOR SEA"
	.byte 0
questNameKendrickScotch: .text "FETCH SCOTCH FOR KENDRICK"
    .byte 0
questNameWarlockWard: .text "PLACE THE WARLOCK'S WARD"
	.byte 0
questNameCandyWitch: .text "DISABLE THE WARLOCK'S WARD"
	.byte 0
questNameKoraJape: .text "KORA'S JAPE"
	.byte 0
questNameAlphaWolfric: .text "ALPHA WOLFRIC"
	.byte 0

// Quest name pointer table (indexed by quest id 0..14)
questNameLo:
	.byte <questName0,<questName1,<questName2,<questName3,<questName4,<questName5,<questName6,<questNameApollonia,<questNameLouden,<questNameMermaid,<questNameKendrickScotch,<questNameWarlockWard,<questNameCandyWitch,<questNameKoraJape,<questNameAlphaWolfric
questNameHi:
	.byte >questName0,>questName1,>questName2,>questName3,>questName4,>questName5,>questName6,>questNameApollonia,>questNameLouden,>questNameMermaid,>questNameKendrickScotch,>questNameWarlockWard,>questNameCandyWitch,>questNameKoraJape,>questNameAlphaWolfric

questDetail0: .text "QUEST: GIVE COIN TO THE BARTENDER."
	.byte 0
questDetail1: .text "QUEST: GIVE KEY TO THE KNIGHT."
	.byte 0
	questDetail2: .text "QUEST: GIVE LANTERN TO THE MYSTIC."
		.byte 0
	questDetail3: .text "QUEST: BRING THE MYSTIC TO A DATE WITH THE SPIDER PRINCESS."
		.byte 0
	questDetail4: .text "QUEST: PLANT BULBS AROUND THE PARK TO GROW BLACK ROSES. JOIN THE ORDER."
		.byte 0
		questDetail5: .text "QUEST: RETRIEVE THE NAME STOLEN BY THE FAIRY IN THE FAIRY GARDENS AND RETURN IT TO THE UNSEELY FAE."
			.byte 0
questDetailApollonia: .text "QUEST: LEAVE ANY ITEM AS AN OFFERING AT SAINT APOLLONIA'S STATUE IN THE INN."
	.byte 0
questDetailLouden: .text "QUEST: BRING THE HEART FROM THE CATACOMBS TO LOUDEN."
	.byte 0
questDetailMermaid: .text "QUEST: TRADE A PINECONE FOR A SPARKLY SHELL WITH THE MERMAID IN THE ALLEY."
	.byte 0
questDetailKendrick: .text "QUEST: FETCH A BOTTLE OF SCOTCH FROM THE TIPTSEY MAIDEN TAVERN AND RETURN IT TO KENDRICK IN THE PLAZA."
    .byte 0
questDetailWarlock: .text "QUEST: TAKE THE WARLOCK'S WARD AND SET IT DOWN AT THE PORTAL."
	.byte 0
questDetailCandyWitch: .text "QUEST: BRING THE WARLOCK'S WARD TO THE CANDY WITCH TO HAVE IT DISABLED, THEN RETURN THE DISABLED WARD TO THE WARLOCK."
	.byte 0
questDetailKoraJape: .text "QUEST: SAY 'SCOTCH ON THE KNIGHT' TO KENDRICK IN THE PLAZA."
	.byte 0
questDetailAlphaWolfric: .text "QUEST: HELP VAN BEAULER SECURE SUPPLIES FOR THE WOLVES AND THE TOWN."
	.byte 0

// Quest detail pointer table (indexed by quest id 0..14)
questDetailLo:
	.byte <questDetail0,<questDetail1,<questDetail2,<questDetail3,<questDetail4,<questDetail5,<questDetail5,<questDetailApollonia,<questDetailLouden,<questDetailMermaid,<questDetailKendrick,<questDetailWarlock,<questDetailCandyWitch,<questDetailKoraJape,<questDetailAlphaWolfric
questDetailHi:
	.byte >questDetail0,>questDetail1,>questDetail2,>questDetail3,>questDetail4,>questDetail5,>questDetail5,>questDetailApollonia,>questDetailLouden,>questDetailMermaid,>questDetailKendrick,>questDetailWarlock,>questDetailCandyWitch,>questDetailKoraJape,>questDetailAlphaWolfric
