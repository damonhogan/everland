// KICK ASSEMBLER C64 ADVENTURE ENGINE
// Enhanced with location descriptions, extended commands, and NPCs
:BasicUpstart2(start)

.encoding "petscii_upper"

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

// SID
.label SID_BASE = $D400
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
.label ZP_PTR     = $FB // $FB/$FC
.label ZP_PTR2    = $FD // $FD/$FE

.const DEVICE = 8
.const LFN    = 1
.const SA     = 2

// Constants
.const LOC_TRAIN  = 0
.const LOC_MARKET = 1
.const LOC_GATE   = 2
.const LOC_GOLEM  = 3
.const LOC_PLAZA  = 4
.const LOC_ALLEY  = 5
.const LOC_MYSTIC  = 6
.const LOC_GROVE  = 7
.const LOC_TAVERN = 8
.const LOC_GRAVE  = 9
.const LOC_CATACOMBS = 10
.const LOC_INN    = 11
.const LOC_TEMPLE = 12
.const LOC_COUNT  = 13

.const OBJ_LANTERN = 0
.const OBJ_COIN    = 1
.const OBJ_MUG     = 2
.const OBJ_KEY     = 3
.const OBJ_TREASURE= 4
.const OBJ_STOLEN_NAME = 5
.const OBJ_COUNT   = 6

.const OBJ_INVENTORY = $FE
.const OBJ_NOWHERE   = $FF

.const NPC_CONDUCTOR = 0
.const NPC_BARTENDER = 1
.const NPC_KNIGHT    = 2
.const NPC_MYSTIC     = 3
.const NPC_FAIRY     = 4
.const NPC_PIXIE     = 5
.const NPC_SPIDER_PRINCESS = 6
.const NPC_PIRATE_CAPTAIN = 7
.const NPC_PIRATE_FIRSTMATE = 8
.const NPC_UNSEELY_FAE = 9
.const NPC_COUNT     = 10

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

.const ROW_AUTH_MSG   = 12
.const ROW_AUTH_PROMPT= 14

// Seasons
.const SEASON_OFF    = 0
.const SEASON_MYTHOS = 1
.const SEASON_LORE   = 2
.const SEASON_AURORA = 3

// Quests (MVP)
.const QUEST_NONE = $FF
.const QUEST_COIN_BARTENDER = 0
.const QUEST_KEY_KNIGHT     = 1
.const QUEST_LANTERN_MYSTIC  = 2
.const QUEST_TREASURE       = 3
.const QUEST_LURE_MYSTIC    = 4
.const QUEST_BLACK_ROSE     = 5
.const QUEST_UNSEELY_NAME   = 6
.const QUEST_COUNT          = 7

// Game state
currentLoc: .byte LOC_PLAZA
prevLoc:    .byte LOC_PLAZA
lastMsgLo:  .byte <msgWelcome
lastMsgHi:  .byte >msgWelcome

// UI state
uiHideExits: .byte 0
// When set, suppress map rendering (used during login and conversations)
uiInConversation: .byte 0
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
pinLo: .byte 0
pinHi: .byte 0

// Calendar / progression
month: .byte 4  // 1-12 (default APR)
week:  .byte 14 // 1-52-ish (default mid-APR)

// Quest state
scoreLo: .byte 0
scoreHi: .byte 0
activeQuest: .byte QUEST_NONE
questStatus: .byte 0 // 0=none/inactive, 1=active, 2=completed
// Player level (single byte)
currentLevel: .byte 0

// Save filename buffers
saveBaseLen: .byte 0
saveBaseBuf:
	.fill 16, 0
saveNameLen: .byte 0
saveNameBuf:
	.fill 24, 0
// --- Dev-mode auto login defaults ---
autoMarkerName: .byte 'E','V','A','U','T','O'
autoUserZ:  .text "AUTOTEST"; .byte 0
autoDispZ:  .text "AUTO"; .byte 0
autoClassZ: .text "KNIGHT"; .byte 0


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
	.fill 96, 0

// Temporary selection state for menus
selCount: .byte 0
selChoice: .byte 0
tmpNpcIdx: .byte 0
tmpHp: .byte 0
tmpPer: .byte 0,0
// Per-NPC conversation stage (0 = initial, 1 = progressed)
npcConvStage:
	.fill NPC_COUNT, 0
npcMaskHiTemp: .byte 0
tmpCnt: .byte 0

// Input buffer (PETSCII)
inputLen: .byte 0
inputBuf:
	.fill 48, 0

// Object locations (location id, $FE=inventory, $FF=nowhere)
objLoc:
	.byte LOC_TRAIN   // LANTERN
	.byte LOC_MARKET  // COIN
	.byte LOC_TAVERN  // MUG
	.byte LOC_GATE    // KEY
	.byte LOC_CATACOMBS // TREASURE (starts hidden in catacombs)
	.byte OBJ_NOWHERE // STOLEN NAME (starts nowhere; given by Fairy on trade)

// --- Program entry ---
start:
	jsr init
mainLoop:
	jsr render
	jsr readLine
	jsr executeCommand
	jmp mainLoop

// --- Profile / Save system ---
// MVP: per-username save file on DEVICE 8.
// File format (binary, fixed sizes):
//  "EV1" (3 bytes)
//  username[12], displayName[16]
//  pinLo,pinHi (2)
//  scoreLo,scoreHi (2)
//  month (1), week(1), currentLoc(1)
//  objLoc[OBJ_COUNT]
//  activeQuest (1), questStatus(1)

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

	// Prompt CLASS (e.g. KNIGHT, PALADIN, MAGE)
	lda #<msgAskClass
	sta lastMsgLo
	lda #>msgAskClass
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr copyInputToClass
	jsr mapPlayerClass
	// initialize player HP to max if empty
	jsr computePlayerMaxHp
	lda tmpHp
	beq @lc_skip_init
	lda playerCurHp
	beq @lc_set_hp
	jmp @lc_skip_init

@lc_set_hp:
	lda tmpHp
	sta playerCurHp

@lc_skip_init:

	// Prompt PIN
	lda #<msgAskPin
	sta lastMsgLo
	lda #>msgAskPin
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr parsePinFromInput

	// Prompt MONTH
	lda #<msgAskMonth
	sta lastMsgLo
	lda #>msgAskMonth
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr parseMonthFromInput

	// Prompt WEEK
	lda #<msgAskWeek
	sta lastMsgLo
	lda #>msgAskWeek
	sta lastMsgHi
	jsr render
	jsr readLine
	jsr parseWeekFromInput

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

	// Reset objects to starting positions
	lda #LOC_TRAIN
	sta objLoc+OBJ_LANTERN
	lda #LOC_MARKET
	sta objLoc+OBJ_COIN
	lda #LOC_TAVERN
	sta objLoc+OBJ_MUG
	lda #LOC_GATE
	sta objLoc+OBJ_KEY

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
	// restore player class idx and HP from loaded values
	lda loadedClassIdx
	sta playerClassIdx
	lda loadedCurHp
	sta playerCurHp
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
	beq @tl_c3
	jmp @fail2
@tl_c3:
	// Read username (skip, we already have it)
	ldx #0
@ru:
	jsr CHRIN
	inx
	cpx #12
	bne @ru
	// Read display
	ldx #0
@rd:
	jsr CHRIN
	sta loadedDisplay,x
	inx
	cpx #16
	bne @rd
	// Read class (12 bytes)
	ldx #0
@rcl:
	jsr CHRIN
	sta loadedClass,x
	inx
	cpx #12
	bne @rcl
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
	lda #'1'
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
	jsr getSeason
	tax
	lda seasonLineLo,x
	sta ZP_PTR
	lda seasonLineHi,x
	sta ZP_PTR+1
	jsr printZ
	rts

renderQuestLine:
	jsr clearMsgBuf
	lda #<strWeek
	sta ZP_PTR
	lda #>strWeek
	sta ZP_PTR+1
	jsr appendToMsgBuf
	// Append week number (2 digits)
	lda week
	jsr appendByteAsDec
	lda #<strScore
	sta ZP_PTR
	lda #>strScore
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda scoreLo
	jsr appendByteAsDec
	lda #<strQuest
	sta ZP_PTR
	lda #>strQuest
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda activeQuest
	cmp #QUEST_NONE
	beq @rql_none
	tax
	lda questNameLo,x
	sta ZP_PTR
	lda questNameHi,x
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	rts

@rql_none:
	lda #<strNone
	sta ZP_PTR
	lda #>strNone
	sta ZP_PTR+1
	jsr appendToMsgBuf
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
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
	cpx #95
	bcs @d
	sta msgBuf,x
	inx
	stx msgBufLen
	lda #0
	sta msgBuf,x
@d:
	rts

// --- Quest system ---
ensureQuest:
	lda activeQuest
	cmp #QUEST_NONE
	bne @eq_ok
	jsr assignQuestForWeek

@eq_ok:
	rts

assignQuestForWeek:
	// Simple weekly rotation: quest = week % QUEST_COUNT
	lda week
@mod:
	cmp #QUEST_COUNT
	bcc @set
	sec
	sbc #QUEST_COUNT
	jmp @mod
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
	.byte <@qc_reward_bartender, <@qc_done_after, <@qc_done_after, <@qc_reward_treasure, <@qc_reward_lure, <@qc_done_after, <@qc_reward_unseely
questRewardHi:
	.byte >@qc_reward_bartender, >@qc_done_after, >@qc_done_after, >@qc_reward_treasure, >@qc_reward_lure, >@qc_done_after, >@qc_reward_unseely

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
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	// Extra (non-map) locations reuse nearby marker positions.
	.byte 0,0,0,1,0,0,1,0,0,1,1,0,0

// Indoor/location music override ($FF = none). Theme ids match musicTheme.
locMusicOverride:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,8,5,$FF,$FF,6,7

// Notes table (indices used in sequences):
// 1=C4 2=D4 3=E4 4=F4 5=G4 6=A4 7=B4 8=C5 9=D5 10=E5 11=G5 12=A5
noteFreqLo:
	.byte $67,$89,$ED,$3B,$13,$45,$DA,$CE,$11,$DA,$26,$89
noteFreqHi:
	.byte $11,$13,$15,$17,$1A,$1D,$20,$22,$27,$2B,$34,$3A

// --- Music patterns (16 steps each// 0=rest// note index 1..12) ---
// MYTHOS (soft, major)
myLead0: .byte 1,3,5,8, 5,3,2,3, 5,8,10,8, 6,5,3,1
myLead1: .byte 3,5,6,8, 10,8,6,5, 3,5,8,10, 8,6,5,3
myLead2: .byte 5,6,8,10, 11,10,8,6, 5,3,2,3, 5,6,8,10
myBass0: .byte 1,0,5,0, 6,0,5,0, 3,0,2,0, 1,0,5,0
myBass1: .byte 1,0,6,0, 5,0,3,0, 2,0,3,0, 5,0,1,0
myBass2: .byte 5,0,6,0, 8,0,6,0, 5,0,3,0, 2,0,1,0

// LORE (minor-ish, slower feel)
loLead0: .byte 6,5,3,2, 3,5,6,5, 3,2,1,2, 3,5,6,0
loLead1: .byte 5,3,2,1, 2,3,5,6, 5,3,2,0, 2,3,5,0
loLead2: .byte 6,8,7,6, 5,3,2,1, 2,3,5,6, 5,3,2,1
loBass0: .byte 6,0,5,0, 3,0,2,0, 1,0,2,0, 3,0,5,0
loBass1: .byte 5,0,3,0, 2,0,1,0, 2,0,3,0, 2,0,1,0
loBass2: .byte 6,0,7,0, 5,0,3,0, 2,0,1,0, 2,0,3,0

// AURORA (sparkly, higher notes)
auLead0: .byte 8,0,10,0,11,0,12,0,11,0,10,0,9,0,8,0
auLead1: .byte 10,0,11,0,12,0,11,0,10,0,9,0,8,0,9,0
auLead2: .byte 8,0,9,0,10,0,11,0,10,0,9,0,8,0,6,0
auBass0: .byte 1,0,5,0,8,0,5,0,6,0,9,0,6,0,5,0
auBass1: .byte 3,0,6,0,10,0,6,0,5,0,9,0,5,0,3,0
auBass2: .byte 1,0,6,0,8,0,6,0,5,0,8,0,5,0,1,0

auSpk0:  .byte 12,0,11,0,10,0,11,0,12,0,11,0,10,0,11,0
auSpk1:  .byte 11,0,12,0,11,0,10,0,11,0,10,0,9,0,10,0
auSpk2:  .byte 10,0,11,0,12,0,0,0,11,0,10,0,9,0,8,0

// OFF SEASON (simple, airy)
ofLead0: .byte 1,0,2,0,3,0,2,0,1,0,0,0,1,0,2,0
ofLead1: .byte 3,0,2,0,1,0,0,0,1,0,2,0,3,0,5,0
ofLead2: .byte 2,0,1,0,2,0,3,0,2,0,1,0,0,0,1,0
ofBass0: .byte 1,0,0,0,1,0,0,0,5,0,0,0,3,0,0,0
ofBass1: .byte 3,0,0,0,2,0,0,0,1,0,0,0,2,0,0,0
ofBass2: .byte 5,0,0,0,3,0,0,0,2,0,0,0,1,0,0,0

// SCARY (dissonant steps, sparse)
scLead0: .byte 7,0,4,0, 7,0,4,0, 6,0,3,0, 6,0,2,0
scLead1: .byte 4,0,7,0, 4,0,7,0, 3,0,6,0, 2,0,6,0
scLead2: .byte 7,0,0,0, 4,0,0,0, 6,0,3,0, 2,0,0,0
scBass0: .byte 1,0,0,0, 1,0,0,0, 2,0,0,0, 1,0,0,0
scBass1: .byte 2,0,0,0, 1,0,0,0, 3,0,0,0, 2,0,0,0
scBass2: .byte 1,0,0,0, 5,0,0,0, 2,0,0,0, 1,0,0,0

// TAVERN (indoor, cozy)
tvLead0: .byte 5,6,5,3, 2,3,5,6, 8,6,5,3, 2,3,5,0
tvLead1: .byte 6,8,6,5, 3,5,6,8, 10,8,6,5, 3,5,6,0
tvLead2: .byte 3,5,6,5, 3,2,1,2, 3,5,6,8, 6,5,3,0
tvBass0: .byte 1,0,3,0, 5,0,6,0, 5,0,3,0, 2,0,1,0
tvBass1: .byte 3,0,5,0, 6,0,8,0, 6,0,5,0, 3,0,2,0
tvBass2: .byte 5,0,6,0, 8,0,10,0, 8,0,6,0, 5,0,3,0

tvSpk0:  .byte 8,0,0,0,10,0,0,0,11,0,0,0,10,0,0,0
tvSpk1:  .byte 10,0,0,0,11,0,0,0,12,0,0,0,11,0,0,0
tvSpk2:  .byte 11,0,0,0,10,0,0,0,9,0,0,0,10,0,0,0

// INN (warm, restful)
inLead0: .byte 3,0,5,6, 5,0,3,2, 3,0,5,6, 8,0,6,5
inLead1: .byte 5,0,6,8, 6,0,5,3, 2,0,3,5, 6,0,5,3
inLead2: .byte 6,0,5,3, 2,0,3,5, 6,0,8,6, 5,0,3,2
inBass0: .byte 1,0,3,0, 5,0,3,0, 2,0,3,0, 1,0,0,0
inBass1: .byte 3,0,5,0, 6,0,5,0, 3,0,2,0, 1,0,0,0
inBass2: .byte 5,0,3,0, 2,0,1,0, 2,0,3,0, 5,0,0,0

// TEMPLE (martial)
tpLead0: .byte 1,1,0,3,3,0,5,5,0,6,6,0,5,5,0,3
tpLead1: .byte 3,3,0,5,5,0,6,6,0,8,8,0,6,6,0,5
tpLead2: .byte 5,5,0,6,6,0,5,5,0,3,3,0,2,2,0,1
tpBass0: .byte 1,0,1,0,1,0,3,0,3,0,5,0,5,0,3,0
tpBass1: .byte 3,0,3,0,5,0,5,0,6,0,6,0,5,0,3,0
tpBass2: .byte 5,0,5,0,6,0,6,0,8,0,8,0,6,0,5,0

// FAIRY (light, sparkly)
faLead0: .byte 8,10,12,11, 10,9,8,9, 10,11,12,11, 10,9,8,0
faLead1: .byte 10,11,12,0, 11,10,9,8, 9,10,11,12, 11,10,9,0
faLead2: .byte 8,9,10,11, 12,11,10,9, 8,9,10,11, 10,9,8,0
faBass0: .byte 1,0,5,0, 6,0,5,0, 3,0,2,0, 1,0,0,0
faBass1: .byte 3,0,6,0, 5,0,3,0, 2,0,1,0, 2,0,0,0
faBass2: .byte 1,0,6,0, 5,0,3,0, 2,0,3,0, 5,0,0,0

faSpk0:  .byte 12,0,0,0,11,0,0,0,12,0,0,0,10,0,0,0
faSpk1:  .byte 11,0,0,0,12,0,0,0,11,0,0,0,10,0,0,0
faSpk2:  .byte 10,0,0,0,11,0,0,0,12,0,0,0,11,0,0,0

// PIRATE (jaunty)
piLead0: .byte 5,5,6,5, 3,2,3,5, 6,6,8,6, 5,3,5,0
piLead1: .byte 6,6,8,6, 5,3,5,6, 8,8,10,8, 6,5,3,0
piLead2: .byte 8,8,6,5, 3,2,1,2, 3,5,6,8, 6,5,3,0
piBass0: .byte 1,0,5,0, 1,0,6,0, 5,0,3,0, 2,0,1,0
piBass1: .byte 3,0,6,0, 3,0,5,0, 6,0,5,0, 3,0,2,0
piBass2: .byte 5,0,8,0, 5,0,6,0, 8,0,6,0, 5,0,3,0

// INN sparkle ornaments (soft trills)
inSpk0: .byte 0,9,0,0, 0,10,0,0, 0,9,0,0, 0,10,0,0
inSpk1: .byte 9,0,0,9, 0,10,0,10, 9,0,0,9, 0,10,0,10
inSpk2: .byte 0,0,9,0, 0,10,0,0, 0,0,9,0, 0,10,0,0

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
themeLeadLen:  .byte 9, 8,10, 7,12, 8, 9, 8, 7, 8
themeBassLen:  .byte 18,16,20,14,24,16,18,16,14,16
themeSparkLen: .byte 6, 4, 6, 4, 8, 4, 6, 6, 4, 6

// Waveform bits only (gate bit added dynamically): TRI=$10 SAW=$20 PULSE=$40 NOISE=$80
themeLeadWave: .byte $10,$10,$20,$10,$20,$10,$10,$40,$10,$40
themeBassWave: .byte $10,$10,$10,$10,$10,$10,$10,$10,$10,$10
themeSparkWave:.byte $40,$40,$40,$40,$80,$40,$40,$40,$40,$40

// Release-heavy for scary// otherwise smooth.
themeV1SR: .byte $A6,$A8,$B7,$A8,$46,$A8,$A8,$88,$78,$A8
themeV2SR: .byte $A6,$A8,$A8,$A8,$46,$A8,$A8,$A8,$78,$A8
themeV3SR: .byte $68,$78,$78,$78,$28,$78,$68,$68,$78,$68

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
	// Auth mode: welcome + message + prompt.
	clc
	ldx #2
	ldy #0
	jsr PLOT
	lda #<msgWelcomeLine1
	sta ZP_PTR
	lda #>msgWelcomeLine1
	sta ZP_PTR+1
	jsr printZ
	clc
	ldx #3
	ldy #0
	jsr PLOT
	lda #<msgWelcomeLine2
	sta ZP_PTR
	lda #>msgWelcomeLine2
	sta ZP_PTR+1
	jsr printZ
	clc
	ldx #ROW_AUTH_MSG
	ldy #0
	jsr PLOT
	lda lastMsgLo
	sta ZP_PTR
	lda lastMsgHi
	sta ZP_PTR+1
	jsr printZ
	jsr renderAuthTag
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
	lda #<strExits
	sta ZP_PTR
	lda #>strExits
	sta ZP_PTR+1
	jsr printZ
	jsr printExits

@render_skipExits:

	// Last message
	jsr setCursorMsg
	lda lastMsgLo
	sta ZP_PTR
	lda lastMsgHi
	sta ZP_PTR+1
	jsr printZ

	// Help (two fixed-width lines)
	jsr setCursorHelp
	lda #<strHelp1
	sta ZP_PTR
	lda #>strHelp1
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	lda #<strHelp2
	sta ZP_PTR
	lda #>strHelp2
	sta ZP_PTR+1
	jsr printZ

	// Prompt
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
	jsr flushKeys

@poll:
	jsr SCNKEY
	jsr GETIN
	beq @poll

	cmp #$0D // RETURN
	beq @maybeFinish
	cmp #$14 // DEL/BACKSPACE
	beq @back

	// Limit length
	ldx inputLen
	cpx #47
	bcs @poll

	// Store and echo
	sta inputBuf,x
	inx
	stx inputLen
	jsr CHROUT
	jmp @poll

@maybeFinish:
	// Finish on RETURN (empty input allowed) — avoid double-enter at prompts.
	ldx inputLen
	bne @finish
	jmp @finish

@back:
	ldx inputLen
	beq @poll
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
	jsr newline
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
	// treat single-letter directional commands only when the input is a single-letter
	cmp #'N'
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
	bne @ec_afterQuick
@ec_m_ok:
	ldy #1
	lda inputBuf,y
	cmp #' '
	beq @do_cmdMusic
	cmp #0
	beq @do_cmdMusic
	jmp @ec_afterQuick

@do_cmdMusic:
	jmp cmdMusicToggle

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
	bcc @ec_tryTalk
	jmp cmdWest

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
	bcc @ec_tryCharacters
	jmp cmdTalkWord

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
	bcc @ec_unknown
	jmp cmdChart

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
	bcc @key
	lda #OBJ_MUG
	sec
	rts
@key:
	txa
	pha
	lda #<kwKey
	sta ZP_PTR2
	lda #>kwKey
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @pon_fail
	lda #OBJ_KEY
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
	bcc @nf
	lda #NPC_PIXIE
	sec
	rts
@nf:
	clc
	rts

// Parse simple scenery noun starting at X. Returns A=sceneryId, carry set if found.
// 0=STALL, 1=SIGN, 2=GATE
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
	bcc @pscn_gate
	lda #1
	sec
	rts

@pscn_gate:
	// GATE
	txa
	pha
	lda #<kwGate
	sta ZP_PTR2
	lda #>kwGate
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
	jmp doMove
cmdSouth:
	ldx currentLoc
	lda exitS,x
	jmp doMove
cmdEast:
	ldx currentLoc
	lda exitE,x
	jmp doMove
cmdWest:
	ldx currentLoc
	lda exitW,x
	jmp doMove

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
	lda #0
	sta selCount
	ldx #0
@cc_npc_loop:
	lda ZP_PTR2
	and npcBitLo,x
	beq @cc_check_hi_1
	// increment display count
	inc selCount
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	// print npc name
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

@cc_present_1:
	// increment display count
	inc selCount
	lda selCount
	clc
	adc #'0'
	jsr CHROUT
	lda #'.'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	// print npc name
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

@cc_npc_next:
	inx
	cpx #NPC_COUNT
	bne @cc_npc_loop

	jmp @cc_npc_after

@cc_check_hi_1:
	lda npcMaskHiTemp
	and npcBitHi,x
	beq @cc_npc_next
	jmp @cc_present_1

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
	// increment y (count)
	iny
	tya
	cmp selChoice
	beq @cc_selected

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
	jsr conversationMenu
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
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
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

	// HP: show player current/max
	jsr computePlayerMaxHp
	// ensure playerCurHp is initialized
	lda playerCurHp
	bne @ps_hp_have
	lda tmpHp
	sta playerCurHp
@ps_hp_have:
	// print label
	lda #<strSpace
	sta ZP_PTR
	lda #>strSpace
	sta ZP_PTR+1
	jsr printZ
	lda playerCurHp
	jsr appendByteAsDec
	lda #<'/'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda tmpHp
	jsr appendByteAsDec
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline

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
	lda #0
	sta selCount
	ldx #0
@tt_npc_loop:
	lda ZP_PTR2
	and npcBitLo,x
	beq @tt_check_hi_2
	jmp @tt_present_2

@tt_present_2:
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

@tt_npc_next:
	inx
	cpx #NPC_COUNT
	bne @tt_npc_loop

	jmp @tt_npc_done

@tt_check_hi_2:
	lda npcMaskHiTemp
	and npcBitHi,x
	beq @tt_npc_next
	jmp @tt_present_2

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

// Conversation menu for an NPC. Expects X = npc index
conversationMenu:
	// mark we're in a conversation so render() won't show the map
	lda #1
	sta uiInConversation
	jsr clearScreen
	// Print NPC name as header
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

conv_loop:
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	// Ignore empty RETURN here to avoid stray buffered RETURNs exiting
	// the conversation immediately; re-prompt instead.
	beq @conv_jump
	sec
	sbc #'0'
	tay
	tya
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

@conv_do_speak:
	// Indirect dispatch table by NPC index (X)
	lda convSpeakHandlerLo,x
	sta ZP_PTR
	lda convSpeakHandlerHi,x
	sta ZP_PTR+1
	jmp (ZP_PTR)

@conv_speak_default:
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

// Unseely Fae conversation
unseelyConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @u_noinput
	sec
	sbc #'0'
	tay
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
	jmp unseelyConversation

@u_noquest:
	lda #<msgUnseelyOfferAlready
	sta lastMsgLo
	lda #>msgUnseelyOfferAlready
	sta lastMsgHi
	jsr render
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
	jmp unseelyConversation

@u_noname:
	lda #<msgUnseelyNoName
	sta lastMsgLo
	lda #>msgUnseelyNoName
	sta lastMsgHi
	jsr render
	jmp unseelyConversation

unseelyJumpLo:
	.byte <@u_ask,<@u_request,<@u_offer,<@u_leave
unseelyJumpHi:
	.byte >@u_ask,>@u_request,>@u_offer,>@u_leave

// Spider Princess conversation. Expects X = npc index.
spiderConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @s_noinput
	sec
	sbc #'0'
	tay
	// indirect jump table
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
	jmp spiderConversation

@s_noquest:
	lda #<msgSpiderOfferAlready
	sta lastMsgLo
	lda #>msgSpiderOfferAlready
	sta lastMsgHi
	jsr render
	jmp spiderConversation

@s_leave:
	rts

spiderJumpLo:
	.byte <@s_flirt,<@s_whisper,<@s_offer,<@s_leave
spiderJumpHi:
	.byte >@s_flirt,>@s_whisper,>@s_offer,>@s_leave

@conv_conductor:
	jsr conductorConversation
	jmp conv_loop

// Conversation handler table indexed by NPC index (X)
convSpeakHandlerLo:
	.byte <@conv_conductor, <@conv_bartender, <@conv_knight, <@conv_speak_default, <@conv_fairy, <@conv_pixie, <@conv_spider, <@conv_pirate, <@conv_pirate, <@conv_unseely
convSpeakHandlerHi:
	.byte >@conv_conductor, >@conv_bartender, >@conv_knight, >@conv_speak_default, >@conv_fairy, >@conv_pixie, >@conv_spider, >@conv_pirate, >@conv_pirate, >@conv_unseely

// Pirate-specific conversation tree. Expects X = npc index.
pirateConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @pc_noinput
	sec
	sbc #'0'
	tay
	// indirect jump via table to avoid short-branch distance limits
	lda pirateJumpLo,y
	sta ZP_PTR
	lda pirateJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@pc_noinput:
	jmp pirateConversation

	// Jump table: low/high word pairs for pirate choices
	pirateJumpLo:
		.byte <@pc_tale, <@pc_treasure, <@pc_join, <@pc_leave, <@pc_offer
	pirateJumpHi:
		.byte >@pc_tale, >@pc_treasure, >@pc_join, >@pc_leave, >@pc_offer

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
	jmp pirateConversation

@pc_tale_capt:
	lda #<msgPirateTaleCapt
	sta lastMsgLo
	lda #>msgPirateTaleCapt
	sta lastMsgHi
	jsr render
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
	jmp pirateConversation

@pc_treasure_already:
	lda #<msgPirateTreasureAlready
	sta lastMsgLo
	lda #>msgPirateTreasureAlready
	sta lastMsgHi
	jsr render
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
	jmp pirateConversation

@pc_leave:
	rts

// Bartender-specific conversation tree. Expects X = npc index.
bartenderConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @b_noinput
	sec
	sbc #'0'
	tay
	// indirect jump table to avoid branch distance issues
	lda bartenderJumpLo,y
	sta ZP_PTR
	lda bartenderJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@b_noinput:
	jmp bartenderConversation

	bartenderJumpLo:
		.byte <@b_job, <@b_buy, <@b_tip, <@b_quest, <@b_leave
	bartenderJumpHi:
		.byte >@b_job, >@b_buy, >@b_tip, >@b_quest, >@b_leave

@b_job:
	lda #<msgBartenderJob
	sta lastMsgLo
	lda #>msgBartenderJob
	sta lastMsgHi
	jsr render
	jmp bartenderConversation

@b_buy:
	// If player has a coin, take coin and give mug
	lda objLoc+OBJ_COIN
	cmp #OBJ_INVENTORY
	bne @b_nocoin
	// take coin
	lda #OBJ_COIN
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
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
	jmp bartenderConversation

@b_nocoin:
	lda #<msgBartenderNoCoin
	sta lastMsgLo
	lda #>msgBartenderNoCoin
	sta lastMsgHi
	jsr render
	jmp bartenderConversation

@b_tip:
	// Tip: if player has a coin, take it and add score +1
	lda objLoc+OBJ_COIN
	cmp #OBJ_INVENTORY
	bne @b_notipcoin
	// take coin
	lda #OBJ_COIN
	sta tmpPer+1
	lda #4
	jsr conv_apply_effect
	// add score +1
	lda #1
	sta tmpPer+1
	lda #5
	jsr conv_apply_effect
	lda #<msgBartenderTipThanks
	sta lastMsgLo
	lda #>msgBartenderTipThanks
	sta lastMsgHi
	jsr render
	jmp bartenderConversation

@b_notipcoin:
	lda #<msgBartenderNoCoin
	sta lastMsgLo
	lda #>msgBartenderNoCoin
	sta lastMsgHi
	jsr render
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
	jsr waitAnyKey
	jmp bartenderConversation

@b_noquest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jsr waitAnyKey
	jmp bartenderConversation

// Conductor-specific conversation tree. Expects X = npc index.
conductorConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @c_noinput
	sec
	sbc #'0'
	tay
	// indirect jump table to avoid branch-distance issues
	lda conductorJumpLo,y
	sta ZP_PTR
	lda conductorJumpHi,y
	sta ZP_PTR+1
	jmp (ZP_PTR)

@c_noinput:
	jmp conductorConversation

	conductorJumpLo:
		.byte <@c_about, <@c_tune, <@c_join, <@c_quest, <@c_leave
	conductorJumpHi:
		.byte >@c_about, >@c_tune, >@c_join, >@c_quest, >@c_leave

@c_about:
	lda #<msgConductorAbout
	sta lastMsgLo
	lda #>msgConductorAbout
	sta lastMsgHi
	jsr render
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
	// Debug print coin location/state if enabled
	jsr debug_print_coin_info
	// Show explicit confirmation that the player received a coin
	lda #<msgCoinRec
	sta lastMsgLo
	lda #>msgCoinRec
	sta lastMsgHi
	jsr render
	jsr waitAnyKey
	// fall through to show the quest offer message (override msg from give)

@c_nooffermsg:
	lda #<msgQuestOfferGeneric
	sta lastMsgLo
	lda #>msgQuestOfferGeneric
	sta lastMsgHi
	jsr render
	jsr waitAnyKey
	jmp conductorConversation

@c_noquest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jmp conductorConversation

@c_leave:
	rts

// Knight-specific conversation tree. Expects X = npc index.
knightConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @k_noinput
	sec
	sbc #'0'
	tay
	tya
	// indirect jump table
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
	jmp knightConversation

@k_noquest:
	lda #<msgKnightNoQuest
	sta lastMsgLo
	lda #>msgKnightNoQuest
	sta lastMsgHi
	jsr render
	jmp knightConversation

@k_leave:
	rts

@k_join:
	// Start the Order of the Black Rose quest if available
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq @k_noquest
	lda npcOffersQuest,x
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	lda #<msgKnightThanks
	sta lastMsgLo
	lda #>msgKnightThanks
	sta lastMsgHi
	jsr render
	jmp knightConversation

knightJumpLo:
	.byte <@k_about,<@k_offer,<@k_join,<@k_leave
knightJumpHi:
	.byte >@k_about,>@k_offer,>@k_join,>@k_leave

// Fairy-specific conversation tree. Expects X = npc index.
fairyConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @f_noinput
	sec
	sbc #'0'
	tay
	tya
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
	jmp fairyConversation

@f_nocoin:
	lda #<msgBartenderNoCoin
	sta lastMsgLo
	lda #>msgBartenderNoCoin
	sta lastMsgHi
	jsr render
	jmp fairyConversation

@f_leave:
	rts

fairyJumpLo:
	.byte <@f_bless,<@f_coin,<@f_trade,<@f_leave
fairyJumpHi:
	.byte >@f_bless,>@f_coin,>@f_trade,>@f_leave

// Pixie-specific conversation tree. Expects X = npc index.
pixieConversation:
	jsr clearScreen
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

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq @p_noinput
	sec
	sbc #'0'
	tay
	tya
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
	jmp pixieConversation

@p_notlan:
	lda #<msgPixieNoLan
	sta lastMsgLo
	lda #>msgPixieNoLan
	sta lastMsgHi
	jsr render
	jmp pixieConversation

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
	beq @conv_noquest
	// start quest via conv_apply_effect: A=1 (startQuest), tmpPer+1=quest id
	sta tmpPer+1
	lda #1
	jsr conv_apply_effect
	// mark this NPC's conversation stage as progressed
	lda #1
	sta npcConvStage,x
	// Spider Princess has a custom offer message
	cpx #NPC_SPIDER_PRINCESS
	beq @cq_spider
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

@cq_render:
	jsr render
	jsr waitAnyKey
	jmp conv_loop

@conv_noquest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jsr waitAnyKey
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
	// else 2=GATE
	jmp @insp_gate

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

@insp_gate:
	lda currentLoc
	cmp #LOC_GATE
	bne @scnNo
	lda #<msgGate
	sta lastMsgLo
	lda #>msgGate
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
	beq @noTarget
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
	sta ZP_PTR2
	lda npcMaskByLocHi,y
	sta npcMaskHiTemp
	lda ZP_PTR2
	and npcBitLo,x
	bne @give_npcHere
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
	lda questStatus
	cmp #1
	bne @qcg_no
	lda activeQuest
	cmp #QUEST_NONE
	beq @qcg_no
	// Determine npcId
	lda ZP_PTR2+1
	cmp #$FF
	bne @haveNpc
	ldx currentLoc
	lda npcDefaultByLoc,x
	sta ZP_PTR2+1
@haveNpc:
	lda activeQuest
	cmp #QUEST_COIN_BARTENDER
	bne @q1
	lda ZP_PTR2
	cmp #OBJ_COIN
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_BARTENDER
	bne @qcg_no
	jsr questComplete
	sec
	rts
@q1:
	cmp #QUEST_KEY_KNIGHT
	bne @q2
	lda ZP_PTR2
	cmp #OBJ_KEY
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_KNIGHT
	bne @qcg_no
	jsr questComplete
	sec
	rts
@q2:
	// QUEST_LANTERN_MYSTIC
	lda ZP_PTR2
	cmp #OBJ_LANTERN
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_MYSTIC
	bne @qcg_no
	jsr questComplete
	sec
	rts

@q3:
	// QUEST_LURE_MYSTIC: player gives TREASURE to SPIDER PRINCESS
	lda ZP_PTR2
	cmp #OBJ_TREASURE
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_SPIDER_PRINCESS
	bne @qcg_no
	jsr questComplete
	sec
	rts

@qcg_no:
	clc
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

	lda #<msgChart3
	sta ZP_PTR
	lda #>msgChart3
	sta ZP_PTR+1
	jsr printZ
	jsr waitAnyKey
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
	// Title
	lda #<strInventory
	sta ZP_PTR
	lda #>strInventory
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Build and print inventory full-screen
	jsr buildInventoryMessage
	lda #<msgBuf
	sta ZP_PTR
	lda #>msgBuf
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Wait for any key (press Enter) to continue
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
	cpx #95
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
	bne @npcLoop
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
	lda #<strInventory
	sta ZP_PTR
	lda #>strInventory
	sta ZP_PTR+1

@give_notHave:
	jsr appendToMsgBuf

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
	beq @pe_done
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
map2:  .text "       .'   NW  /  |  \\  NE   '.       "
	.byte 0
map3:  .text "      /  DGH  /   |   \\  MKT    \\     "
	.byte 0
map4:  .text "     ;       /   TMP    \\       ;     "
	.byte 0
map5:  .text "     |  WGT |    PLA    |  ALY   |     "
	.byte 0
map6:  .text "     ;       \\    |    /        ;     "
	.byte 0
map7:  .text "      \\  WCH  \\   |   /  FAY   /      "
	.byte 0
map8:  .text "       '.   SW  \\  |  /  SE  .'       "
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
	// LOC order: TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	// Extra (non-map) locations reuse nearby marker positions.
	.byte 19, 27,  9, 10, 18, 28, 11, 28, 18, 13, 10, 22, 18
locMarkY:
	.byte  1,  3,  5,  3,  5,  5,  7,  7,  9,  8,  4,  9,  4

// --- Data: Locations ---
locName0: .text "TRAIN STATION"
	.byte 0
locName1: .text "MARKET GREEN"
	.byte 0
locName2: .text "KNIGHT'S GATE"
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
locName8: .text "TIPSEY MAIDEN TAVERN"
	.byte 0
locName9: .text "LOUDEN'S REST"
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
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, MYSTIC, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,  $FF,  LOC_GOLEM, $FF,  LOC_TRAIN, LOC_MARKET, LOC_GATE, LOC_TEMPLE, LOC_ALLEY, $FF,  LOC_GRAVE, $FF,  LOC_PLAZA
exitE:
	.byte LOC_MARKET, $FF,       LOC_PLAZA, LOC_TRAIN, LOC_ALLEY, $FF,       LOC_GROVE, LOC_TAVERN, LOC_INN, LOC_MYSTIC, $FF, $FF, LOC_GOLEM
exitS:
	.byte LOC_PLAZA, LOC_ALLEY,  LOC_MYSTIC, LOC_GATE,  LOC_TEMPLE, LOC_TAVERN, $FF, $FF, $FF, LOC_CATACOMBS, $FF, $FF, LOC_GROVE
exitW:
	.byte LOC_GOLEM, LOC_TRAIN,  $FF,       LOC_TEMPLE, LOC_GATE, LOC_PLAZA, LOC_GRAVE, LOC_MYSTIC, LOC_GROVE, $FF, $FF, LOC_TAVERN, $FF

// NPC masks by location (bit 0..5)
// NPC masks by location (two bytes per location: low, high)
npcMaskByLocLo:
	.byte %0001 // TRAIN: CONDUCTOR
	.byte %0000 // MARKET
	.byte %0100 // GATE: KNIGHT
	.byte %0000 // GOLEM
	.byte %01000000 // PLAZA: SPIDER PRINCESS
	.byte %10000000 // ALLEY: PIRATE_CAPTAIN (bit7)
	.byte %1000 // MYSTICWOOD: MYSTIC
	.byte %00110000 // FAIRY GARDENS: FAIRY + PIXIE
	.byte %0010 // TAVERN: BARTENDER
	.byte %0000 // LOUDEN'S REST
	.byte %0000 // CATACOMBS
	.byte %0000 // PIGGLYWEED INN
	.byte %0000 // TEMPLE RUINS

npcMaskByLocHi:
	.byte %00000000 // TRAIN
	.byte %00000000 // MARKET
	.byte %00000000 // GATE
	.byte %00000000 // GOLEM
	.byte %00000000 // PLAZA
	.byte %00000001 // ALLEY: PIRATE_FIRSTMATE (high bit0)
	.byte %00000000 // MYSTICWOOD
	.byte %00000000 // FAIRY GARDENS
	.byte %00000000 // TAVERN
	.byte %00000000 // LOUDEN'S REST
	.byte %00000000 // CATACOMBS
	.byte %00000000 // PIGGLYWEED INN
	.byte %00000010 // TEMPLE (UNSEELY_FAE -> index9 -> high bit1)

// Default NPC to address in a location when only one is present
npcDefaultByLoc:
	.byte NPC_CONDUCTOR, $FF, NPC_KNIGHT, $FF, NPC_SPIDER_PRINCESS, NPC_PIRATE_CAPTAIN, NPC_MYSTIC, NPC_FAIRY, NPC_BARTENDER, $FF, $FF, $FF, NPC_UNSEELY_FAE

// One-line talk per location (MVP)
npcTalkLoByLoc:
	.byte <talkConductor,<msgNoOne,<talkKnight,<msgNoOne,<msgNoOne,<talkPirateCaptain,<talkMystic,<talkFairy,<talkBartender,<msgNoOne,<msgNoOne,<msgNoOne,<msgNoOne
npcTalkHiByLoc:
	.byte >talkConductor,>msgNoOne,>talkKnight,>msgNoOne,>msgNoOne,>talkPirateCaptain,>talkMystic,>talkFairy,>talkBartender,>msgNoOne,>msgNoOne,>msgNoOne,>msgNoOne

talkConductor: .text "THE CONDUCTOR SAYS: ALL ABOARD THE IMAGINATION EXPRESS!"
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
talkSpiderPrincess: .text "THE SPIDER PRINCESS SAYS: I CAME THROUGH A FRACTURED PORTAL; WHO AM I?"
	.byte 0
talkPirateCaptain: .text "THE PIRATE CAPTAIN GRINS: GOLD AND TALES MAKE A FINE COCKTAIL."
	.byte 0
talkPirateFirstMate: .text "FIRST MATE: WE SWEAR BY WIND AND WHEEL, STRANGER."
	.byte 0

talkUnseelyFae: .text "AN UNSEELY FAE WHISPERS: THE RUINS REMEMBER BLOOMS THAT NEVER WERE."
	.byte 0

npcTalkLo:
	.byte <talkConductor,<talkBartender,<talkKnight,<talkMystic,<talkFairy,<talkPixie,<talkSpiderPrincess,<talkPirateCaptain,<talkPirateFirstMate,<talkUnseelyFae
npcTalkHi:
	.byte >talkConductor,>talkBartender,>talkKnight,>talkMystic,>talkFairy,>talkPixie,>talkSpiderPrincess,>talkPirateCaptain,>talkPirateFirstMate,>talkUnseelyFae

// Which quest (if any) each NPC can offer
// Which quest (if any) each NPC can offer
// Which quest (if any) each NPC can offer
npcOffersQuest:
	.byte QUEST_COIN_BARTENDER, QUEST_NONE, QUEST_BLACK_ROSE, QUEST_LANTERN_MYSTIC, QUEST_NONE, QUEST_NONE, QUEST_LURE_MYSTIC, QUEST_NONE, QUEST_NONE, QUEST_UNSEELY_NAME

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
msgKnightAbout: .text "KNIGHT: HONOR OPENS MORE DOORS THAN KEYS."
	.byte 0
msgKnightNoKey: .text "YOU DO NOT HAVE THE KEY."
	.byte 0
msgKnightNoQuest: .text "THE KNIGHT DOESN'T NEED THIS NOW."
	.byte 0
msgKnightThanks: .text "THE KNIGHT BLESSES YOU FOR YOUR SERVICE."
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
// Per-choice effect tables (one table per numeric menu choice). Each table
// contains one byte per NPC (indexed by npc index). Effect types:
// 0=none,1=startQuest,2=completeQuest,3=giveItem,4=takeItem,5=addScore,6=setNpcStage
// Corresponding value tables hold the effect value (item id, score amount, npc idx, etc.)
convChoiceType_choice0:
	.byte 6,3,3,3,3,0,0,0,0,0   // speak: conductor setNpcStage, bartender give MUG, knight give KEY, mystic give LANTERN, fairy give COIN
convChoiceVal_choice0:
	.byte 0,OBJ_MUG,OBJ_KEY,OBJ_LANTERN,OBJ_COIN,0,0,0,0,0

convChoiceType_choice1:
	.byte 5,0,0,0,5,0,0,0,0,0   // ask weather: conductor +2 score, fairy +1 score
convChoiceVal_choice1:
	.byte 2,0,0,0,1,0,0,0,0,0

convChoiceType_choice2:
	.byte 0,0,0,4,0,6,0,0,0,0   // temp comment: mystic may take LANTERN, pixie advances NPC stage
convChoiceVal_choice2:
	.byte 0,0,0,OBJ_LANTERN,0,1,0,0,0,0

convChoiceType_choice3:
	.byte 0,0,0,0,0,0,0,0,0,0
convChoiceVal_choice3:
	.byte 0,0,0,0,0,0,0,0,0,0

convChoiceType_choice4:
	.byte 0,2,2,2,0,0,0,0,0,0   // quest info: bartender/knight/mystic can complete their quests
convChoiceVal_choice4:
	.byte 0,QUEST_COIN_BARTENDER,QUEST_KEY_KNIGHT,QUEST_LANTERN_MYSTIC,0,0,0,0,0,QUEST_UNSEELY_NAME

convChoiceType_choice5:
	.byte 0,0,0,0,0,0,0,0,0,0
convChoiceVal_choice5:
	.byte 0,0,0,0,0,0,0,0,0,0



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

classNameLo:
	.byte <className0,<className1,<className2,<className3,<className4,<className5
classNameHi:
	.byte >className0,>className1,>className2,>className3,>className4,>className5

// Simple class stat tables (base HP and HP per level)
classBaseHp:
	.byte 20, 16, 24, 12, 10, 8
classHpPerLevel:
	.byte 5, 3, 6, 4, 2, 2

// NPC static attributes per NPC index
npcClassIdx:
	.byte 0,1,2,3,4,5,4,6,6,4
npcLevel:
	.byte 1,1,2,3,1,1,1,2,1,1
npcScoreLo:
	.byte 0,0,0,0,0,0,0,0,0,0
npcScoreHi:
	.byte 0,0,0,0,0,0,0,0,0,0
// NPC current HP (persisted across saves)
npcCurHp:
	.byte 0,0,0,0,0,0,0,0,0,0

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

objNameLo:
	.byte <objName0,<objName1,<objName2,<objName3
objNameHi:
	.byte >objName0,>objName1,>objName2,>objName3

objInspect0: .text "A BRASS LANTERN. IT COULD LIGHT DARK PATHS."
	.byte 0
objInspect1: .text "A SMALL COIN, WARM FROM MANY HANDS."
	.byte 0
objInspect2: .text "A TIN MUG WITH A FRESH FOAM RING."
	.byte 0
objInspect3: .text "A RUSTED KEY. IT WANTS A STORY OF ITS OWN."
	.byte 0

objInspectLo:
	.byte <objInspect0,<objInspect1,<objInspect2,<objInspect3
objInspectHi:
	.byte >objInspect0,>objInspect1,>objInspect2,>objInspect3

// --- Keywords ---
kwNorth:      .text "NORTH"
	.byte 0
kwSouth:      .text "SOUTH"
	.byte 0
kwEast:       .text "EAST"
	.byte 0
kwWest:       .text "WEST"
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
kwKey:     .text "KEY"
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

kwStall:     .text "STALL"
	.byte 0
kwSign:      .text "SIGN"
	.byte 0
kwGate:      .text "GATE"
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

// --- UI Strings / Messages ---
strExits:  .text "EXITS: "
	.byte 0
strHelp1:  .text "N/E/S/W MOVE  I INV  C CHARS  T TALK"
	.byte 0
strHelp2:  .text "WAIT STATUS SAVE LOAD INSPECT M MUSIC"
	.byte 0
strPrompt: .text "> "
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
strLevel: .text "LEVEL "
	.byte 0
strQuest: .text "  QUEST "
	.byte 0

strCharacters: .text "CHARACTERS: "
	.byte 0
strInventory:  .text "INVENTORY: "
	.byte 0
strNone:       .text "(NONE)"
	.byte 0
strEmpty:      .text "(EMPTY)"
	.byte 0
strSpace:      .text " "
	.byte 0
strNoData: .text "(no data)"
	.byte 0

// npcBit split into low/high bytes to support up to 16 NPCs
npcBitLo:
	.byte %00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000,%00000000,%00000000
npcBitHi:
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000001,%00000010

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
npcName5: .text "PIXIE"
	.byte 0
npcName6: .text "SPIDER PRINCESS"
	.byte 0
npcName7: .text "PIRATE CAPTAIN"
	.byte 0
npcName8: .text "PIRATE FIRST MATE"
	.byte 0
npcName9: .text "UNSEELY FAE"
	.byte 0

npcNameLo:
	.byte <npcName0,<npcName1,<npcName2,<npcName3,<npcName4,<npcName5,<npcName6,<npcName7,<npcName8,<npcName9
npcNameHi:
	.byte >npcName0,>npcName1,>npcName2,>npcName3,>npcName4,>npcName5,>npcName6,>npcName7,>npcName8,>npcName9

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
msgGate:       .text "THE GATE IS RINGED WITH IRON CHARMS. A SMALL KEYHOLE WAITS, PATIENT AND SILENT."
	.byte 0

msgAskUser:     .text "USERNAME?"
	.byte 0
msgAskDisplay:  .text "DISPLAY NAME?"
	.byte 0
msgAskClass:    .text "CLASS (KNIGHT, PALADIN, MAGE, BARD, HEALER, CLERIC):"
	.byte 0
msgAskPin:      .text "SET PIN (NUMBERS)"
	.byte 0
msgAskPinLogin: .text "PIN?"
	.byte 0
msgBadPin:      .text "WRONG PIN."
	.byte 0
msgAskMonth:    .text "MONTH (1-12)?"
	.byte 0
msgAskWeek:     .text "WEEK (1-52)?"
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

questNameLo:
	.byte <questName0,<questName1,<questName2,<questName3,<questName4,<questName5
questNameHi:
	.byte >questName0,>questName1,>questName2,>questName3,>questName4,>questName5

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

questDetailLo:
	.byte <questDetail0,<questDetail1,<questDetail2,<questDetail3,<questDetail4,<questDetail5
questDetailHi:
	.byte >questDetail0,>questDetail1,>questDetail2,>questDetail3,>questDetail4,>questDetail5
