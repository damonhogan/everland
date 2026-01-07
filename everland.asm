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
.const LOC_WITCH  = 6
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
.const OBJ_COUNT   = 4

.const OBJ_INVENTORY = $FE
.const OBJ_NOWHERE   = $FF

.const NPC_CONDUCTOR = 0
.const NPC_BARTENDER = 1
.const NPC_KNIGHT    = 2
.const NPC_WITCH     = 3
.const NPC_FAIRY     = 4
.const NPC_PIXIE     = 5
.const NPC_COUNT     = 6

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
.const QUEST_LANTERN_WITCH  = 2
.const QUEST_COUNT          = 3

// Game state
currentLoc: .byte LOC_PLAZA
prevLoc:    .byte LOC_PLAZA
lastMsgLo:  .byte <msgWelcome
lastMsgHi:  .byte >msgWelcome

// UI state
uiHideExits: .byte 0

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
leadWave: .byte $10   // TRI by default (waveform bits only; gate bit added dynamically)
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
tmpPer: .byte 0
tmpCnt: .byte 0
tmpRand: .byte 0

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

	// Try load; if fails, create profile
	jsr tryLoadGame
	bcc save_loc_create
	jmp save_loaded

save_loc_create:

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
	beq skip_init_flow
	lda playerCurHp
	beq set_initial_hp
	jmp skip_init_flow

set_initial_hp:
	lda tmpHp
	sta playerCurHp

skip_init_flow:

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

save_loaded:
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
	bne pin_bad_auth
	lda pinHi
	cmp loadedPinHi
	bne pin_bad_auth
	// Pin OK, copy loaded state into live state
	jsr commitLoadedState
	jsr buildWelcomeBack
	rts

pin_bad_auth:
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

	copyClass_loop:
		lda inputBuf,x
		beq copyClass_done
		cpx #12
		bcs copyClass_done
		sta className,x
		inx
		stx classLen
		jmp copyClass_loop

	copyClass_done:
		// Pad remaining with 0
		lda #0

	copyClass_pad:
		cpx #12
		beq copyClass_pdone
		sta className,x
		inx
		jmp copyClass_pad

	copyClass_pdone:
		rts

// Map player's textual className to playable class index by first letter
mapPlayerClass:
	lda className
	beq mpc_default
	// convert lowercase to uppercase if needed
	cmp #'a'
	bcc mpc_check
	cmp #'z'+1
	bcs mpc_check
	sec
	sbc #32

	mpc_check:
	cmp #'M'
	beq mpc_m
	cmp #'K'
	beq mpc_k
	cmp #'H'
	beq mpc_h
	cmp #'B'
	beq mpc_b
	cmp #'W'
	beq mpc_w

	mpc_default:
	lda #0
	sta playerClassIdx
	rts

	mpc_m:
	lda #0
	sta playerClassIdx
	rts
	mpc_k:
	lda #1
	sta playerClassIdx
	rts
	mpc_h:
	lda #2
	sta playerClassIdx
	rts
	mpc_b:
	lda #3
	sta playerClassIdx
	rts
	mpc_w:
	lda #4
	sta playerClassIdx
	rts

copyInputToDisplay:
	ldx #0
	stx displayLen

	copyDisplay_loop:
		lda inputBuf,x
		beq copyDisplay_done
		cpx #16
		bcs copyDisplay_done
		sta displayName,x
		inx
		stx displayLen
		jmp copyDisplay_loop

	copyDisplay_done:
		lda #0

	copyDisplay_pad:
		cpx #16
		beq copyDisplay_pdone
		sta displayName,x
		inx
		jmp copyDisplay_pad

	copyDisplay_pdone:
		rts
	parsePinFromInput:
		lda #0
		sta pinLo
		sta pinHi
		ldx #0
	parsePin_loop:
		lda inputBuf,x
		beq parsePin_done
		cmp #'0'
		bcc parsePin_skip
		cmp #'9'+1
		bcs parsePin_skip
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


	parsePin_skip:
		inx
		cpx #48
		bne parsePin_loop

	parsePin_done:
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
	bcc parseMonth_default
	cmp #13
	bcs parseMonth_default
	sta month
	rts

parseMonth_default:
	lda #4
	sta month
	rts

parseWeekFromInput:
	jsr parseSmallNumber
	cmp #1
	bcc parseWeek_default
	cmp #53
	bcs parseWeek_default
	sta week
	rts

parseWeek_default:
	lda #14
	sta week
	rts

// Parse small number 0-255 from inputBuf, returns in A
parseSmallNumber:
	lda #0
	sta ZP_PTR
	ldx #0

parseSmall_loop:
	lda inputBuf,x
	beq parseSmall_done
	cmp #'0'
	bcc parseSmall_next
	cmp #'9'+1
	bcs parseSmall_next
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

parseSmall_next:
	inx
	cpx #48
	bne parseSmall_loop

parseSmall_done:
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

buildSaveBase_loop:
	cpy usernameLen
	beq buildSaveBase_done
	lda username,y
	beq buildSaveBase_done
	sta saveBaseBuf,x
	inx
	iny
	cpx #16
	bcc buildSaveBase_loop

buildSaveBase_done:
	stx saveBaseLen
	rts

// Build saveNameBuf = base + ",S,R" or ",S,W" (mode in A: 'R' or 'W')
buildSaveNameWithMode:
	pha
	// Copy base into saveNameBuf
	ldx #0
	copyBase_loop:
	cpx saveBaseLen
	beq saveName_suffix
	lda saveBaseBuf,x
	sta saveNameBuf,x
	inx
	jmp copyBase_loop
saveName_suffix:
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
	beq tryLoad_ok
	jmp tryLoad_fail


tryLoad_ok:
	lda #LFN
	jsr CLRCHN
	lda #LFN
	jsr CLOSE
	jsr CHRIN
	cmp #'1'
	beq tryLoad_c3
	jmp read_fail_cleanup
tryLoad_c3:
	// Read username (skip, we already have it)
	ldx #0
read_username_skip:
jsr CHRIN
inx
cpx #12
bne read_username_skip
	// Read display
	ldx #0
read_display_loop:
	jsr CHRIN
	sta loadedDisplay,x
	inx
	cpx #16
	bne read_display_loop
	// Read class (12 bytes)
	ldx #0
read_class_loop:
	jsr CHRIN
	sta loadedClass,x
	inx
	cpx #12
	bne read_class_loop
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
read_objloc_loop:
	jsr CHRIN
	sta loadedObjLoc,x
	inx
	cpx #OBJ_COUNT
	bne read_objloc_loop
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

read_obj_fail_cleanup:
	jsr CLRCHN
	lda #LFN
	jsr CLOSE

read_obj_fail_return:
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
		beq saveGame_write

	saveGame_write:
	lda #LFN
	jsr CHKOUT
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


read_fail_cleanup:
	jsr CLRCHN
	lda #LFN
	jsr CLOSE

tryLoad_fail:
	clc
	rts
	inx
	cpx #16
	bne write_display_loop
	// display
	ldx #0

write_display_loop:
	lda displayName,x
	jsr CHROUT
	inx
	cpx #16
	bne write_display_loop
	// className (12 bytes)
	ldx #0

	write_class_loop:
	lda className,x
	jsr CHROUT
	inx
	cpx #12
	bne write_class_loop
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
	write_objloc_loop:
		lda objLoc,x
		jsr CHROUT
		inx
		cpx #OBJ_COUNT
		bne write_objloc_loop
	// quest
	lda activeQuest
	jsr CHROUT
	lda questStatus
	jsr CHROUT
	jsr CLRCHN
	lda #LFN
	jsr CLOSE

saveGame_done:
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
	bcc season_off
	cmp #9
	bcc season_mythos
	cmp #11
	bcc season_lore
	cmp #13
	bcc season_aurora
season_off:
	lda #SEASON_OFF
	rts
season_mythos:
	lda #SEASON_MYTHOS
	rts
season_lore:
	lda #SEASON_LORE
	rts
season_aurora:
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
	beq renderQuest_none
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

renderQuest_none:
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
lbl_append_hundreds:
	cmp #100
	bcc lbl_append_tens
	sec
	sbc #100
	inc ZP_PTR2
	jmp lbl_append_hundreds
lbl_append_tens:
	sta ZP_PTR2+1
	lda ZP_PTR2
	beq lbl_append_skipH
	clc
	adc #'0'
	jsr appendCharA
lbl_append_skipH:
	// tens
	lda #0
	sta ZP_PTR
	lda ZP_PTR2+1
lbl_append_tens_loop:
	cmp #10
	bcc lbl_append_ones
	sec
	sbc #10
	inc ZP_PTR
	jmp lbl_append_tens_loop
lbl_append_ones:
	sta ZP_PTR2+1
	lda ZP_PTR
	beq lbl_append_maybeZero
	clc
	adc #'0'
	jsr appendCharA
	jmp lbl_append_printOne
lbl_append_maybeZero:
	// if we printed hundreds, we need a 0 tens
	lda ZP_PTR2
	beq lbl_append_printOne
	lda #'0'
	jsr appendCharA
lbl_append_printOne:
	lda ZP_PTR2+1
	clc
	adc #'0'
	jsr appendCharA
	rts

appendCharA:
	ldx msgBufLen
	cpx #95
	bcs lbl_append_done
	sta msgBuf,x
	inx
	stx msgBufLen
	lda #0
	sta msgBuf,x
lbl_append_done:
	rts

// --- Quest system ---
ensureQuest:
	lda activeQuest
	cmp #QUEST_NONE
	bne ensureQuest_ok
	jsr assignQuestForWeek

ensureQuest_ok:
	rts

assignQuestForWeek:
	// Simple weekly rotation: quest = week % QUEST_COUNT
	lda week
assignQuest_mod:
	cmp #QUEST_COUNT
	bcc assignQuest_set
	sec
	sbc #QUEST_COUNT
	jmp assignQuest_mod
assignQuest_set:
	sta activeQuest
	lda #1
	sta questStatus
	rts

questComplete:
	lda questStatus
	cmp #2
	beq questComplete_done
	lda #2
	sta questStatus
	inc scoreLo
	lda scoreLo
	bne questComplete_level_check
	inc scoreHi

questComplete_level_check:
	// Update level if score increased above currentLevel
	lda scoreLo
	cmp currentLevel
	beq questComplete_msg
	bcc questComplete_msg
	sta currentLevel

questComplete_msg:
	lda #<msgQuestDone
	sta lastMsgLo
	lda #>msgQuestDone
	sta lastMsgHi
	jsr saveGame

questComplete_done:
	rts

advanceWeek:
	inc week
	lda week
	cmp #53
	bcc advanceWeek_ok
	lda #1
	sta week

advanceWeek_ok:
	// Some quests can persist; MVP: rotate if completed, else keep
	lda questStatus
	cmp #2
	bne advanceWeek_done
	lda #QUEST_NONE
	sta activeQuest
	lda #0
	sta questStatus
	jsr ensureQuest
advanceWeek_done:
	lda #<msgWeekAdvanced
	sta lastMsgLo
	lda #>msgWeekAdvanced
	sta lastMsgHi
	jsr saveGame
	rts

// --- Music engine (SID, raster IRQ) ---
musicInit:
	// Install our IRQ hook only once; we chain to the original KERNAL IRQ.
	lda musicInstalled
	bne music_init_installed
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

music_init_installed:
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
	bne music_overrides
	jsr getSeason
	cmp #SEASON_LORE
	bne music_pirate
	lda #4
	sta musicTheme
	jmp music_pick

music_pirate:
	lda #9
	sta musicTheme
	jmp music_pick

	// Indoor/location overrides ("enter" music): $FF = none
music_overrides:
	// Indoor/location overrides ("enter" music): $FF = none
	ldx currentLoc
	lda locMusicOverride,x
	cmp #$FF
	beq music_check_scary
	sta musicTheme
	jmp music_pick
music_check_scary:
	// Determine if scary
	ldx currentLoc
	lda locScary,x
	beq music_by_season
	lda #4
	sta musicTheme
	jmp music_pick
music_by_season:
	jsr getSeason
	sta musicTheme
music_pick:
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

	// Per-location lead waveform override (if set)
	lda currentLoc
	tay
	lda locLeadWaveOverride,y
	cmp #$FF
	beq music_apply_no_lead_override
	sta leadWave
music_apply_no_lead_override:
	// Per-theme envelopes (SR only; AD set once in init)
	lda themeV1SR,x
	sta SID_V1_SR

	// Per-location AD override (lead voice)
	lda currentLoc
	tay
	lda locV1ADOverride,y
	cmp #$FF
	beq music_apply_no_v1ad_override
	sta SID_V1_AD
music_apply_no_v1ad_override:

	// Per-location SR override (lead voice)
	lda currentLoc
	tay
	lda locV1SROverride,y
	cmp #$FF
	beq music_apply_no_v1sr_override
	sta SID_V1_SR
music_apply_no_v1sr_override:
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
	// Choose random pattern: normally 0..2, but allow 0..3 for Celtic (theme 10)
	lda $D012
	eor $DC04
	and #$03
	sta tmpRand

	lda musicTheme
	cmp #10
	beq musicPick_ok_celtic

	lda tmpRand
	cmp #3
	bne musicPick_ok
	lda #2

musicPick_ok:
	sta musicPattern
	rts

musicPick_ok_celtic:
	lda tmpRand
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
	beq music_irq_done
	jsr musicTickRoutine

music_irq_done:
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
	bne music_mt_bass
	lda musicStepLen
	sta musicTick
	jsr musicAdvanceLead

music_mt_bass:
	dec musicBassTick
	bne music_mt_spark
	lda musicBassLen
	sta musicBassTick
	jsr musicAdvanceBass


music_mt_spark:
	dec musicSparkTick
	bne music_mt_done
	lda musicSparkLen
	sta musicSparkTick
	jsr musicAdvanceSparkle

music_mt_done:
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
	beq musicLead_rest
	tay
	dey
	lda noteFreqLo,y
	sta SID_V1_FREQLO
	lda noteFreqHi,y
	sta SID_V1_FREQHI
	lda leadWave
	ora #$01
	sta SID_V1_CTRL
	jmp musicLead_next

musicLead_rest:
	lda leadWave
	sta SID_V1_CTRL

musicLead_next:
	inc musicStep
	lda musicStep
	cmp #16
	bcc musicLead_rts
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

musicLead_rts:
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
	beq musicBass_rest
	tay
	dey
	lda noteFreqLo,y
	sta SID_V2_FREQLO
	lda noteFreqHi,y
	sta SID_V2_FREQHI
	lda bassWave
	ora #$01
	sta SID_V2_CTRL
	jmp musicBass_next

musicBass_rest:
	lda bassWave
	sta SID_V2_CTRL

musicBass_next:
	inc musicBassStep
	lda musicBassStep
	cmp #16
	bcc musicBass_rts
	lda #0
	sta musicBassStep

musicBass_rts:
	rts

musicAdvanceSparkle:
	// Only active for Aurora (3) and Tavern (5); otherwise gate off.
	lda musicTheme
	cmp #3
	beq musicSpark_do
	cmp #5
	beq musicSpark_do
	cmp #8
	beq musicSpark_do
	lda sparkWave
	sta SID_V3_CTRL
	rts

musicSpark_do:
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
	beq musicSpark_rest
	tay
	dey
	lda noteFreqLo,y
	sta SID_V3_FREQLO
	lda noteFreqHi,y
	sta SID_V3_FREQHI
	lda sparkWave
	ora #$01
	sta SID_V3_CTRL
	jmp musicSpark_next

musicSpark_rest:
	lda sparkWave
	sta SID_V3_CTRL

musicSpark_next:
	inc musicSparkStep
	lda musicSparkStep
	cmp #16
	bcc musicSpark_rts
	lda #0
	sta musicSparkStep


musicSpark_rts:
	rts

// Scary locations (spooky music)
locScary:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	// Extra (non-map) locations reuse nearby marker positions.
	.byte 0,0,0,1,0,0,1,0,0,1,1,0,0

// Indoor/location music override ($FF = none). Theme ids match musicTheme.
locMusicOverride:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	// Prefer Celtic (10/$0A) for entrances/park-like places: GATE, PLAZA, GROVE
	.byte $FF,$FF,$0A,$FF,$0A,$FF,$FF,$0A,5,$FF,$FF,6,7

// Per-location lead waveform override ($FF = no override). Indexed like `locMusicOverride`.
locLeadWaveOverride:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,$FF,$20,$FF,$20,$FF,$FF,$20,$FF,$FF,$FF,$FF,$FF

// Per-location lead AD override ($FF = no override). Values are AD (attack/decay) nibbles.
locV1ADOverride:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,$FF,$18,$FF,$18,$FF,$FF,$18,$FF,$FF,$FF,$FF,$FF

// Per-location lead SR override ($FF = no override). Values are SR (sustain/release).
locV1SROverride:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,$FF,$B8,$FF,$B8,$FF,$FF,$B8,$FF,$FF,$FF,$FF,$FF

// Notes table (indices used in sequences):
// 1=C4 2=D4 3=E4 4=F4 5=G4 6=A4 7=B4 8=C5 9=D5 10=E5 11=G5 12=A5
noteFreqLo:
	.byte $67,$89,$ED,$3B,$13,$45,$DA,$CE,$11,$DA,$26,$89
noteFreqHi:
	.byte $11,$13,$15,$17,$1A,$1D,$20,$22,$27,$2B,$34,$3A

// --- Music patterns (16 steps each; 0=rest; note index 1..12) ---
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

// CELTIC (ambient, slow, soft — gentle triangle/saw, light ornament)
ceLead0: .byte 9,0,11,9, 12,11,9,0, 9,0,11,9, 12,11,9,0
ceLead1: .byte 12,11,9,11, 12,14,12,11, 9,11,12,0, 0,0,0,0
ceLead2: .byte 14,12,11,9, 11,12,14,12, 11,9,11,12, 0,0,0,0
ceBass0: .byte 1,0,1,0, 3,0,5,0, 3,0,1,0, 0,0,0,0
ceBass1: .byte 3,0,3,0, 5,0,6,0, 5,0,3,0, 0,0,0,0
ceBass2: .byte 1,0,0,0, 3,0,1,0, 3,0,0,0, 0,0,0,0

// light ornament/pulse for Celtic shimmer (sparse)
ceSpk0: .byte 0,10,0,0, 9,0,0,0, 10,0,0,0, 9,0,0,0
ceSpk1: .byte 0,0,9,0, 0,10,0,0, 0,9,0,0, 0,0,0,0
ceSpk2: .byte 9,0,0,10, 0,0,9,0, 0,10,0,0, 0,0,0,0

// Additional Celtic variant (more ornamentation)
ceLead3: .byte 12,11,12,14, 12,11,9,11, 12,14,12,11, 9,11,12,0
ceBass3: .byte 3,0,5,0, 3,0,6,0, 5,0,3,0, 0,0,0,0
ceSpk3: .byte 10,0,9,0, 10,0,9,0, 10,0,0,0, 9,0,0,0

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
ceLeadPtr: .word ceLead0,ceLead1,ceLead2,ceLead3

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
ceBassPtr: .word ceBass0,ceBass1,ceBass2,ceBass3

auSpkPtr:  .word auSpk0,auSpk1,auSpk2
tvSpkPtr:  .word tvSpk0,tvSpk1,tvSpk2
faSpkPtr:  .word faSpk0,faSpk1,faSpk2
ceSpkPtr: .word ceSpk0,ceSpk1,ceSpk2,ceSpk3

// Dummy sparkle (all rests) for themes that don't use it
noSpk0: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
noSpkPtr: .word noSpk0,noSpk0,noSpk0

// Tables indexed by musicTheme (0..9) of pointers to pointer-tables above
themeLeadNotesLo:
    	.byte <ofLeadPtr,<myLeadPtr,<loLeadPtr,<auLeadPtr,<scLeadPtr,<tvLeadPtr,<inLeadPtr,<tpLeadPtr,<faLeadPtr,<piLeadPtr,<ceLeadPtr
themeLeadNotesHi:
    	.byte >ofLeadPtr,>myLeadPtr,>loLeadPtr,>auLeadPtr,>scLeadPtr,>tvLeadPtr,>inLeadPtr,>tpLeadPtr,>faLeadPtr,>piLeadPtr,>ceLeadPtr

themeBassNotesLo:
    	.byte <ofBassPtr,<myBassPtr,<loBassPtr,<auBassPtr,<scBassPtr,<tvBassPtr,<inBassPtr,<tpBassPtr,<faBassPtr,<piBassPtr,<ceBassPtr
themeBassNotesHi:
    	.byte >ofBassPtr,>myBassPtr,>loBassPtr,>auBassPtr,>scBassPtr,>tvBassPtr,>inBassPtr,>tpBassPtr,>faBassPtr,>piBassPtr,>ceBassPtr

themeSparkNotesLo:
    	.byte <noSpkPtr,<noSpkPtr,<noSpkPtr,<auSpkPtr,<noSpkPtr,<tvSpkPtr,<noSpkPtr,<noSpkPtr,<faSpkPtr,<noSpkPtr,<ceSpkPtr
themeSparkNotesHi:
    	.byte >noSpkPtr,>noSpkPtr,>noSpkPtr,>auSpkPtr,>noSpkPtr,>tvSpkPtr,>noSpkPtr,>noSpkPtr,>faSpkPtr,>noSpkPtr,>ceSpkPtr

// Theme settings (tempo + timbre). 10 entries, indexed by musicTheme.
// Smaller = faster (ticks per step). Values tuned for atmosphere.
themeLeadLen:  .byte 9, 8,10, 7,12, 8, 9, 8, 7, 8, 11
themeBassLen:  .byte 18,16,20,14,24,16,18,16,14,16,22
themeSparkLen: .byte 6, 4, 6, 4, 8, 4, 6, 6, 4, 6, 6

// Waveform bits only (gate bit added dynamically): TRI=$10 SAW=$20 PULSE=$40 NOISE=$80
// Make Celtic lead slightly warmer (use saw for a soft, warm tone)
themeLeadWave: .byte $10,$10,$20,$10,$20,$10,$10,$40,$10,$40,$20
themeBassWave: .byte $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
themeSparkWave:.byte $40,$40,$40,$40,$80,$40,$40,$40,$40,$40,$40

// Release-heavy for scary; otherwise smooth.
// Slightly longer release for Celtic theme for a soft, lingering sound
themeV1SR: .byte $A6,$A8,$B7,$A8,$46,$A8,$A8,$88,$78,$A8,$B8
themeV2SR: .byte $A6,$A8,$A8,$A8,$46,$A8,$A8,$A8,$78,$A8,$B8
themeV3SR: .byte $68,$78,$78,$78,$28,$78,$68,$68,$78,$68,$88

init:
	// Start music early so the login screen has its own theme.
	lda #1
	sta musicEnabled
	jsr musicInit
	jsr musicStartLoginTheme

	lda #1
	sta uiHideExits
	jsr loginOrCreate
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
	jsr drawMap

	// UI title line
	jsr setCursorUi
	ldx currentLoc
	lda locNameLo,x
	sta ZP_PTR
	lda locNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	// Description (hand-wrapped; limited to description area)
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
	bne render_skip_exits
	ldx #0
	jsr setCursorExits
	lda #<strExits
	sta ZP_PTR
	lda #>strExits
	sta ZP_PTR+1
	jsr printZ
	jsr printExits

render_skip_exits:

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

drawMap:
	// Print static 12-line map
    ldx #0
map_line_loop:
	lda mapLineLo,x
	sta ZP_PTR
	lda mapLineHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline
	inx
	cpx #12
	bne map_line_loop

	// Divider line
	lda #<strDivider
	sta ZP_PTR
	lda #>strDivider
	sta ZP_PTR+1
	jsr printZ
	jsr newline

	jsr placeMarker
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

printZ_loop:
	lda (ZP_PTR),y
	beq printZ_done
	jsr CHROUT
	iny
	bne printZ_loop

printZ_done:
	rts

// --- Input ---
readLine:
	lda #0
	sta inputLen
	jsr flushKeys

input_poll:
	jsr SCNKEY
	jsr GETIN
	beq input_poll

	cmp #$0D // RETURN
	beq input_maybeFinish
	cmp #$14 // DEL/BACKSPACE
	beq input_back

	// Limit length
	ldx inputLen
	cpx #47
	bcs input_poll

	// Store and echo
	sta inputBuf,x
	inx
	stx inputLen
	jsr CHROUT
	jmp input_poll

input_maybeFinish:
	// In auth mode, ignore empty RETURNs (prevents buffered RETURN from skipping prompts).
	ldx inputLen
	bne input_finish
	lda uiHideExits
	beq input_finish
	jmp input_poll

input_back:
	ldx inputLen
	beq input_poll
	dex
	stx inputLen
	lda #$14
	jsr CHROUT
	jmp input_poll

input_finish:
	// Null-terminate
	ldx inputLen
	lda #0
	sta inputBuf,x
	jsr newline
	rts

// Drain any pending buffered keys (helps avoid stray RETURN requiring double-enter)
flushKeys:
flushKeys_loop:
	jsr SCNKEY
	jsr GETIN
	bne flushKeys_loop
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
skip_leading_spaces:
	lda inputBuf,x
	cmp #' '
	bne cmd_start
	inx
	cpx inputLen
	bcc skip_leading_spaces
	rts


cmd_start:
	// Single-letter quick commands
	lda inputBuf,x
	bne cmd_start2
	jmp cmd_done


cmd_start2:
	cmp #'N'
	bne cmd_chkS
	jmp cmdNorth

cmd_chkS:
	cmp #'S'
	bne cmd_chkE
	jmp cmdSouth

cmd_chkE:
	cmp #'E'
	bne cmd_chkW
	jmp cmdEast

cmd_chkW:
	cmp #'W'
	bne cmd_chkC
	jmp cmdWest

cmd_chkC:
	cmp #'C'
	beq cmd_doC
	cmp #'c'
	bne cmd_chkT
	jmp cmdCharactersMenu

cmd_doC:
	jmp cmdCharactersMenu

cmd_chkT:
	cmp #'T'
	bne cmd_chkI
	jmp cmdTalk

cmd_chkI:
	cmp #'I'
	bne cmd_chkM
	jmp cmdInventory

cmd_chkM:
	cmp #'M'
	beq cmd_m_ok
	cmp #'m'
	bne cmd_afterQuick

cmd_m_ok:
	jmp cmdMusicToggle

cmd_afterQuick:

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
	bcc cmd_tryLook
	jmp cmdInspect

cmd_tryLook:

	txa
	pha
	lda #<kwLook
	sta ZP_PTR2
	lda #>kwLook
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryExamine
	jmp cmdInspect

cmd_tryExamine:

	txa
	pha
	lda #<kwExamine
	sta ZP_PTR2
	lda #>kwExamine
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryTake
	jmp cmdInspect

cmd_tryTake:

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
	bcc cmd_tryGet
	jmp cmdTake

cmd_tryGet:

	txa
	pha
	lda #<kwGet
	sta ZP_PTR2
	lda #>kwGet
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryPick
	jmp cmdTake

cmd_tryPick:

	txa
	pha
	lda #<kwPick
	sta ZP_PTR2
	lda #>kwPick
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryDrop
	jmp cmdPickUp


cmd_tryDrop:

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
	bcc cmd_trySet
	jmp cmdDrop


cmd_trySet:

	txa
	pha
	lda #<kwSet
	sta ZP_PTR2
	lda #>kwSet
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryGive
	jmp cmdSetDown


cmd_tryGive:

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
	bcc cmd_tryDirNorth
	jmp cmdGive


cmd_tryDirNorth:

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
	bcc cmd_tryDirSouth
	jmp cmdNorth


cmd_tryDirSouth:

	txa
	pha
	lda #<kwSouth
	sta ZP_PTR2
	lda #>kwSouth
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryDirEast
	jmp cmdSouth


cmd_tryDirEast:

	txa
	pha
	lda #<kwEast
	sta ZP_PTR2
	lda #>kwEast
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryDirWest
	jmp cmdEast


cmd_tryDirWest:

	txa
	pha
	lda #<kwWest
	sta ZP_PTR2
	lda #>kwWest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryTalk
	jmp cmdWest


cmd_tryTalk:

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
	bcc cmd_tryCharacters
	jmp cmdTalk


cmd_tryCharacters:

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
	bcc cmd_tryInventory
	jmp cmdCharactersMenu


cmd_tryInventory:

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
	bcc cmd_trySave
	jmp cmdInventory


cmd_trySave:

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
	bcc cmd_tryLoad
	jmp cmdSave


cmd_tryLoad:

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
	bcc cmd_tryWait
	jmp cmdLoad


cmd_tryWait:

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
	bcc cmd_tryRest
	jmp cmdWait


cmd_tryRest:

	txa
	pha
	lda #<kwRest
	sta ZP_PTR2
	lda #>kwRest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryNext
	jmp cmdWait


cmd_tryNext:

	txa
	pha
	lda #<kwNext
	sta ZP_PTR2
	lda #>kwNext
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryStatus
	jmp cmdWait


cmd_tryStatus:

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
	bcc cmd_tryQuest
	jmp cmdStatus


cmd_tryQuest:

	txa
	pha
	lda #<kwQuest
	sta ZP_PTR2
	lda #>kwQuest
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc cmd_tryChart
	jmp cmdStatus


cmd_tryChart:

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
	bcc cmd_unknown
	jmp cmdChart


cmd_unknown:

	// Unknown
	lda #<msgUnknown
	sta lastMsgLo
	lda #>msgUnknown
	sta lastMsgHi

cmd_done:
	rts

// Match keyword pointed to by ZP_PTR2 against inputBuf at X.
// Carry set if matches whole word (ends at space or 0).

matchKeywordAtX:
	ldy #0
match_kw_loop:
	lda (ZP_PTR2),y
	beq match_kw_end
	cmp inputBuf,x
	bne match_kw_no
	iny
	inx
	bne match_kw_loop

match_kw_end:
	lda inputBuf,x
	beq match_kw_yes
	cmp #' '
	beq match_kw_yes
match_kw_no:
	clc
	rts

match_kw_yes:
	sec
	rts

// --- PETSCII chart helpers ---

printHexNibble:
	and #$0F
	cmp #10
	bcc printHex_num
	clc
	adc #('A'-10)
	jmp printHex_out
printHex_num:
	clc
	adc #'0'
printHex_out:
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
chart_print_row_loop:
	tya
	clc
	adc ZP_PTR
	jsr CHROUT
	lda #' '
	jsr CHROUT
	iny
	cpy #16
	bne chart_print_row_loop
	jsr newline
	rts

waitAnyKey:
	jsr flushKeys
wait_key_loop:
	jsr SCNKEY
	jsr GETIN
	beq wait_key_loop
	rts
wait_key_yes:
	sec
	rts

// Skip spaces starting at X; returns X at first non-space
skipSpaces:
skip_spaces_loop:
	lda inputBuf,x
	cmp #' '
	bne skip_spaces_done
	inx
	bne skip_spaces_loop
skip_spaces_done:
	rts

// Skip spaces and common filler words (TO/THE/A/AN) starting at X.
// Returns X at start of the next meaningful token.
skipFillers:
skip_fillers_loop:
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
	bcc skip_fillers_the
	inx
	inx
	jmp skip_fillers_loop
skip_fillers_the:
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
	bcc skip_fillers_a
	inx
	inx
	inx
	jmp skip_fillers_loop
skip_fillers_a:
	// A
	lda inputBuf,x
	cmp #'A'
	bne skip_fillers_an
	inx
	jmp skip_fillers_loop
skip_fillers_an:
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
	bcc skip_fillers_done
	inx
	inx
	jmp skip_fillers_loop

skip_fillers_done:
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
	bcc obj_tryCoin
	lda #OBJ_LANTERN
	sec
	rts
obj_tryCoin:
	txa
	pha
	lda #<kwCoin
	sta ZP_PTR2
	lda #>kwCoin
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc obj_tryMug
	lda #OBJ_COIN
	sec
	rts
obj_tryMug:
	txa
	pha
	lda #<kwMug
	sta ZP_PTR2
	lda #>kwMug
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc obj_tryKey
	lda #OBJ_MUG
	sec
	rts
obj_tryKey:
	txa
	pha
	lda #<kwKey
	sta ZP_PTR2
	lda #>kwKey
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc obj_parse_fail
	lda #OBJ_KEY
	sec
	rts

obj_parse_fail:
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
	bcc npc_tryBart
	lda #NPC_CONDUCTOR
	sec
	rts
npc_tryBart:
	txa
	pha
	lda #<kwBartender
	sta ZP_PTR2
	lda #>kwBartender
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc npc_tryKnight
	lda #NPC_BARTENDER
	sec
	rts
npc_tryKnight:
	txa
	pha
	lda #<kwKnight
	sta ZP_PTR2
	lda #>kwKnight
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc npc_tryWitch
	lda #NPC_KNIGHT
	sec
	rts
npc_tryWitch:
	txa
	pha
	lda #<kwWitch
	sta ZP_PTR2
	lda #>kwWitch
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc npc_tryFairy
	lda #NPC_WITCH
	sec
	rts
npc_tryFairy:
	txa
	pha
	lda #<kwFairy
	sta ZP_PTR2
	lda #>kwFairy
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc npc_tryPixie
	lda #NPC_FAIRY
	sec
	rts
npc_tryPixie:
	txa
	pha
	lda #<kwPixie
	sta ZP_PTR2
	lda #>kwPixie
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc npc_parse_none
	lda #NPC_PIXIE
	sec
	rts
npc_parse_none:
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
	bcc scenery_trySign
	lda #0
	sec
	rts

scenery_trySign:
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
	bcc scenery_tryGate
	lda #1
	sec
	rts

scenery_tryGate:
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
	bcc scenery_none
	lda #2
	sec
	rts

scenery_none:
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
	bne move_ok
	lda #<msgNoWay
	sta lastMsgLo
	lda #>msgNoWay
	sta lastMsgHi
	rts

move_ok:
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
	beq cc_print_user
	lda #<displayName
	sta ZP_PTR
	lda #>displayName
	sta ZP_PTR+1
	jsr printZ
	jmp cc_afterPlayer

cc_print_user:
	lda #<username
	sta ZP_PTR
	lda #>username
	sta ZP_PTR+1
	jsr printZ

cc_afterPlayer:
	jsr newline

	// List NPCs present at this location
	ldx currentLoc
	lda npcMaskByLoc,x
	sta ZP_PTR2
	lda #0
	sta selCount
	ldx #0
	cc_npc_loop:
	lda #' '
	jsr CHROUT
	// print npc name
	lda npcNameLo,x
	sta ZP_PTR
	lda npcNameHi,x
	sta ZP_PTR+1
	jsr printZ
	jsr newline

cc_npc_next:
	inx
	cpx #NPC_COUNT
	bne cc_npc_loop

	// Prompt and read choice
	jsr setCursorPrompt
	jsr readLine
	// parse first char
	lda inputBuf
	beq cc_done
	cmp #'0'
	beq cc_show_player_call
	sec
	sbc #'0'
	sta selChoice
	// find corresponding npc index
	ldx #0
	ldy #0
cc_find_loop:
	lda ZP_PTR2
	and npcBit,x
	beq cc_find_next
	// increment y (count)
	iny
	tya
	cmp selChoice
	beq cc_selected

cc_find_next:
	inx
	cpx #NPC_COUNT
	bne cc_find_loop
	jmp cc_done

cc_show_player_call:
	jsr cmdSheet
	jmp cc_done

cc_selected:
	// if NPC present, open conversation menu
	jsr conversationMenu
	rts

cc_done:
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
npc_hp_loop:
	lda tmpCnt
	beq npc_hp_done
	lda tmpHp
	clc
	adc tmpPer
	sta tmpHp
	dec tmpCnt
	jmp npc_hp_loop

npc_hp_done:
	// ensure current HP is set (indexed by npc)
	lda tmpNpcIdx
	tax
	lda npcCurHp,x
	beq npc_set_cur
	// print HP: cur/max
	lda npcCurHp,x
	jsr appendByteAsDec
	lda #<'/'
	jsr CHROUT
	lda #' '
	jsr CHROUT
	lda tmpHp
	jsr appendByteAsDec
	jmp npc_after_hp

npc_set_cur:
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

npc_after_hp:
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
	bne player_hp_have
	lda tmpHp
	sta playerCurHp
player_hp_have:
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
	lda npcMaskByLoc,x
	sta ZP_PTR2
	lda #0
	sta selCount
	ldx #0
talk_npc_loop:
	lda ZP_PTR2
	and npcBit,x
	beq talk_npc_next
	inc selCount
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

talk_npc_next:
	inx
	cpx #NPC_COUNT
	bne talk_npc_loop

	jsr setCursorPrompt
	jsr readLine
	lda inputBuf
	beq talk_done
	sec
	sbc #'0'
	sta selChoice
	ldx #0
	ldy #0
talk_find_loop:
	lda ZP_PTR2
	and npcBit,x
	beq talk_find_next
	iny
	tya
	cmp selChoice
	beq talk_selected

talk_find_next:
	inx
	cpx #NPC_COUNT
	bne talk_find_loop
	jmp talk_done

talk_selected:
	// if NPC present, open conversation menu
	jsr conversationMenu
	rts

talk_done:
	// nothing selected
	rts

talk_none:
	lda #<msgNoOne
	sta lastMsgLo
	lda #>msgNoOne
	sta lastMsgHi
	rts

// Conversation menu for an NPC. Expects X = npc index
conversationMenu:
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
	beq conv_exit_short
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

conv_exit_short:
	jmp conversationMenu_exit

conv_choice0:
	jmp conv_do_speak

conv_choice1:
	jmp conv_do_weather

conv_choice2:
	jmp conv_do_temp

conv_choice3:
	jmp conv_do_quest

conv_choice4:
	jmp conv_do_qinfo

conv_choice5:
	jmp conversationMenu_exit

conv_do_speak:
	lda npcTalkLo,x
	sta lastMsgLo
	lda npcTalkHi,x
	sta lastMsgHi
	jsr render
	jmp conv_loop

conv_do_weather:
	lda #<msgAskWeather
	sta lastMsgLo
	lda #>msgAskWeather
	sta lastMsgHi
	jsr render
	jmp conv_loop

conv_do_temp:
	lda #<msgTempResponse
	sta lastMsgLo
	lda #>msgTempResponse
	sta lastMsgHi
	jsr render
	jmp conv_loop

conv_do_quest:
	lda npcOffersQuest,x
	cmp #QUEST_NONE
	beq conv_noquest
	// set quest active and status
	sta activeQuest
	lda #1
	sta questStatus
	lda #<msgQuestOfferGeneric
	sta lastMsgLo
	lda #>msgQuestOfferGeneric
	sta lastMsgHi
	jsr render
	jmp conv_loop

conv_noquest:
	lda #<msgNoQuestNpc
	sta lastMsgLo
	lda #>msgNoQuestNpc
	sta lastMsgHi
	jsr render
	jmp conv_loop

conv_do_qinfo:
	lda activeQuest
	cmp #QUEST_NONE
	beq conv_noactive
	tax
	lda questDetailLo,x
	sta lastMsgLo
	lda questDetailHi,x
	sta lastMsgHi
	jsr render
	jmp conv_loop

conv_noactive:
	lda #<msgNoQuest
	sta lastMsgLo
	lda #>msgNoQuest
	sta lastMsgHi
	jsr render
	jmp conv_loop

conversationMenu_exit:
	rts

cmdInspect:
	// If noun present, inspect object; else re-describe location
	// Find first space after verb
	ldx #0
find_space_loop:
	lda inputBuf,x
	beq noun_none
	cmp #' '
	beq noun_start
	inx
	bne find_space_loop

noun_start:
	jsr parseObjectNoun
	bcs noun_obj_found
	jsr parseSceneryNoun
	bcs noun_scn_found
	jmp noun_none

noun_obj_found:
	tax
	lda objInspectLo,x
	sta lastMsgLo
	lda objInspectHi,x
	sta lastMsgHi
	rts

noun_scn_found:
	// sceneryId in A
	cmp #0
	beq insp_stall
	cmp #1
	beq insp_sign
	// else 2=GATE
	jmp insp_gate

insp_stall:
	lda currentLoc
	cmp #LOC_MARKET
	bne scenery_not_here
	lda #<msgStall
	sta lastMsgLo
	lda #>msgStall
	sta lastMsgHi
	rts

insp_sign:
	lda currentLoc
	cmp #LOC_TRAIN
	bne scenery_not_here
	lda #<msgSign
	sta lastMsgLo
	lda #>msgSign
	sta lastMsgHi
	rts

insp_gate:
	lda currentLoc
	cmp #LOC_GATE
	bne scenery_not_here
	lda #<msgGate
	sta lastMsgLo
	lda #>msgGate
	sta lastMsgHi
	rts
scenery_not_here:
	lda #<msgNotHere
	sta lastMsgLo
	lda #>msgNotHere
	sta lastMsgHi
	rts

noun_none:
	lda #<msgLook
	sta lastMsgLo
	lda #>msgLook
	sta lastMsgHi
	rts

cmdPickUp:
	// Handle "PICK UP <obj>"; if no UP, treat as TAKE
	ldx #0
	// Find first space
pick_find_space:
	lda inputBuf,x
	beq cmdTake
	cmp #' '
	beq pick_after
	inx
	bne pick_find_space
pick_after:
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
	take_find_space:
		lda inputBuf,x
		beq take_need
		cmp #' '
		beq take_after
		inx
		bne take_find_space

	take_after:
	jsr cmdTakeFromX
	rts

	take_need:
	lda #<msgTakeWhat
	sta lastMsgLo
	lda #>msgTakeWhat
	sta lastMsgHi
	rts

cmdTakeFromX:
	jsr parseObjectNoun
	bcc take_bad
	tax
	lda objLoc,x
	cmp currentLoc
	bne take_not_here
	lda #OBJ_INVENTORY
	sta objLoc,x
	lda #<msgTook
	sta lastMsgLo
	lda #>msgTook
	sta lastMsgHi
    jsr saveGame
	rts

take_not_here:
	lda #<msgNotHere
	sta lastMsgLo
	lda #>msgNotHere
	sta lastMsgHi
	rts

take_bad:
	lda #<msgDontKnow
	sta lastMsgLo
	lda #>msgDontKnow
	sta lastMsgHi
	rts

cmdSetDown:
	// Handle "SET DOWN <obj>"; else DROP
	ldx #0
set_find_space:
	lda inputBuf,x
	beq cmdDrop
	cmp #' '
	beq set_after
	inx
	bne set_find_space
set_after:
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
drop_find_space:
	lda inputBuf,x
	beq drop_need
	cmp #' '
	beq drop_after
	inx
	bne drop_find_space

drop_after:
	jsr cmdDropFromX
	rts

drop_need:
	lda #<msgDropWhat
	sta lastMsgLo
	lda #>msgDropWhat
	sta lastMsgHi
	rts

cmdDropFromX:
	jsr parseObjectNoun
	bcc drop_bad
	tax
	lda objLoc,x
	cmp #OBJ_INVENTORY
	bne drop_not_have
	lda currentLoc
	sta objLoc,x
	lda #<msgDropped
	sta lastMsgLo
	lda #>msgDropped
	sta lastMsgHi
	jsr saveGame
	rts

drop_not_have:
	lda #<msgNotCarrying
	sta lastMsgLo
	lda #>msgNotCarrying
	sta lastMsgHi
	rts

drop_bad:
	lda #<msgDontKnow
	sta lastMsgLo
	lda #>msgDontKnow
	sta lastMsgHi
	rts

cmdGive:
	// GIVE <obj> [TO <npc>]
	ldx #0
give_find_loop:
	lda inputBuf,x
	bne give_find_cont
	jmp give_need

give_find_cont:
	cmp #' '
	beq give_after
	inx
	bne give_find_loop

give_after:
	jsr parseObjectNoun
	bcs give_obj_parsed
	jmp give_bad

give_obj_parsed:
	sta ZP_PTR2 // temp objId
	tax
	lda objLoc,x
	cmp #OBJ_INVENTORY
	beq give_haveIt
	jmp give_notHave

give_haveIt:

	// Find optional target NPC
	// Advance X to end of object word
	ldx #0
give_scanObj:
	lda inputBuf,x
	beq give_noTarget
	cmp #' '
	beq give_afterObj
	inx
	bne give_scanObj
give_afterObj:
	// skip verb
	// find first space after GIVE
	ldx #0
give_skipVerb:
	lda inputBuf,x
	bne give_sv_cont
	jmp give_noTarget

give_sv_cont:
	cmp #' '
	beq give_verbDone
	inx
	bne give_skipVerb
give_verbDone:
	// move to noun start
	jsr skipFillers
	// skip noun word itself
give_skipNounWord:
	lda inputBuf,x
	bne give_snw_cont
	jmp give_noTarget

give_snw_cont:
	cmp #' '
	beq give_afterNoun
	inx
	bne give_skipNounWord
give_afterNoun:
	jsr parseNpcNoun
	bcs give_haveNpc
	jmp give_noTarget

give_haveNpc:
	sta ZP_PTR2+1 // temp npcId
	tax
	ldy currentLoc
	lda npcMaskByLoc,y
	and npcBit,x
	bne give_npcHere
	jmp npc_not_here

give_npcHere:
	// consume item
	ldx ZP_PTR2
	lda #OBJ_NOWHERE
	sta objLoc,x
	// Quest check for targeted give
	jsr questCheckGive
	bcs give_ret
	lda #<msgGave
	sta lastMsgLo
	lda #>msgGave
	sta lastMsgHi
	jsr saveGame
give_ret:
	rts

give_noTarget:
	// If no explicit target, require someone here
	ldx currentLoc
	lda npcMaskByLoc,x
	bne give_nt_someone
	jmp no_one

give_nt_someone:
	lda #$FF
	sta ZP_PTR2+1
	ldx ZP_PTR2
	lda #OBJ_NOWHERE
	sta objLoc,x
	jsr questCheckGive
	bcc give_nt_afterQuest
	jmp give_ret2

give_nt_afterQuest:
	lda #<msgGave
	sta lastMsgLo
	lda #>msgGave
	sta lastMsgHi
	jsr saveGame
give_ret2:
	rts

// Quest hook for GIVE.
// Inputs:
//  ZP_PTR2 = objId
//  ZP_PTR2+1 = npcId or $FF (use default npc for location)
// Returns C=1 if quest completed (lastMsg set)
questCheckGive:
	lda questStatus
	cmp #1
	bne questCheckGive_no
	lda activeQuest
	cmp #QUEST_NONE
	beq questCheckGive_no
	// Determine npcId
	lda ZP_PTR2+1
	cmp #$FF
	bne quest_haveNpc
	ldx currentLoc
	lda npcDefaultByLoc,x
	sta ZP_PTR2+1
quest_haveNpc:
	lda activeQuest
	cmp #QUEST_COIN_BARTENDER
	bne quest_q1
	lda ZP_PTR2
	cmp #OBJ_COIN
	bne questCheckGive_no
	lda ZP_PTR2+1
	cmp #NPC_BARTENDER
	bne questCheckGive_no
	jsr questComplete
	sec
	rts
quest_q1:
	cmp #QUEST_KEY_KNIGHT
	bne quest_q2
	lda ZP_PTR2
	cmp #OBJ_KEY
	bne questCheckGive_no
	lda ZP_PTR2+1
	cmp #NPC_KNIGHT
	bne questCheckGive_no
	jsr questComplete
	sec
	rts
quest_q2:
	// QUEST_LANTERN_WITCH
	lda ZP_PTR2
	cmp #OBJ_LANTERN
	bne questCheckGive_no
	lda ZP_PTR2+1
	cmp #NPC_WITCH
	bne questCheckGive_no
	jsr questComplete
	sec
	rts
questCheckGive_no:
	clc
	rts

	// removed duplicate qcg_no (use questCheckGive_no)

cmdSave:
	jsr saveGame
	lda #<msgSaved
	sta lastMsgLo
	lda #>msgSaved
	sta lastMsgHi
	rts

cmdLoad:
	jsr tryLoadGame
	bcs load_ok
	lda #<msgLoadFail
	sta lastMsgLo
	lda #>msgLoadFail
	sta lastMsgHi
	rts

load_ok:
	// No PIN prompt on in-session LOAD; assumes current user
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
	beq music_off
	jsr musicPickForLocation
	lda #<msgMusicOn
	sta lastMsgLo
	lda #>msgMusicOn
	sta lastMsgHi
	rts

music_off:
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
	bne status_hasQuest
	jmp status_none

status_hasQuest:
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

status_none:
	lda #<msgNoQuest
	sta lastMsgLo
	lda #>msgNoQuest
	sta lastMsgHi
	rts

npc_not_here:
	lda #<msgNpcNotHere
	sta lastMsgLo
	lda #>msgNpcNotHere
	sta lastMsgHi
	rts
no_one:
	lda #<msgNoOne
	sta lastMsgLo
	lda #>msgNoOne
	sta lastMsgHi
	rts
give_what_need:
	lda #<msgGiveWhat
	sta lastMsgLo
	lda #>msgGiveWhat
	sta lastMsgHi
	rts
not_have_msg:
	lda #<msgNotCarrying
	sta lastMsgLo
	lda #>msgNotCarrying
	sta lastMsgHi
	rts
bad_msg:
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

append_msg_loop:
	lda (ZP_PTR),y
	beq append_msg_done
	cpx #95
	bcs append_msg_done
	sta msgBuf,x
	inx
	iny
	bne append_msg_loop

append_msg_done:
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
	lda npcMaskByLoc,x
	beq bcm_none
	sta ZP_PTR2 // reuse low byte as mask temp

	ldx #0
npc_loop:
	lda ZP_PTR2
	and npcBit,x
	beq npc_next
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
npc_next:
	inx
	cpx #NPC_COUNT
	bne npc_loop
	rts

bcm_none:
	lda #<strNone
	sta ZP_PTR
	lda #>strNone
	sta ZP_PTR+1
	jsr appendToMsgBuf
	rts


give_need:
buildInventoryMessage:
	jsr clearMsgBuf
	lda #<strInventory
	sta ZP_PTR
	lda #>strInventory
	sta ZP_PTR+1

give_notHave:
	jsr appendToMsgBuf

	lda #0
	sta ZP_PTR2 // foundAny flag
	ldx #0
obj_loop:

give_bad:
	lda objLoc,x
	cmp #OBJ_INVENTORY
	bne on_label
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
on_label:
	inx
	cpx #OBJ_COUNT
	bne obj_loop
	lda ZP_PTR2
	bne bom_done
	lda #<strEmpty
	sta ZP_PTR
	lda #>strEmpty
	sta ZP_PTR+1
	jsr appendToMsgBuf

bom_done:
	rts

// --- Exits printing ---
printExits:
	ldx currentLoc
	lda exitN,x
	cmp #$FF
	beq exit_E
	lda #'N'
	jsr CHROUT
	lda #' '
	jsr CHROUT
exit_E:
	lda exitE,x
	cmp #$FF
	beq exit_S
	lda #'E'
	jsr CHROUT
	lda #' '
	jsr CHROUT
exit_S:
	lda exitS,x
	cmp #$FF
	beq exit_W
	lda #'S'
	jsr CHROUT
	lda #' '
	jsr CHROUT
exit_W:
	lda exitW,x
	cmp #$FF
	beq exit_done
	lda #'W'
	jsr CHROUT
	lda #' '
	jsr CHROUT

exit_done:
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
map3:  .text "      /  GOY  /   |   \\  MKT    \\     "
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
	// LOC order: TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
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
locName3: .text "GOLEM YARD"
	.byte 0
locName4: .text "CENTRAL PLAZA"
	.byte 0
locName5: .text "CLOCKWORK ALLEY"
	.byte 0
locName6: .text "WITCHWOOD"
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
locDesc3: .text "STONE FIGURES WATCH SILENTLY."
	.byte $0D
	.text "FOOTSTEPS ECHO IN A RING."
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
locDesc9:  .text "CROOKED STONES AND TATTERED RIBBONS."
	.byte $0D
	.text "A MAUSOLEUM LOOMS IN THE FOG."
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
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,  $FF,  LOC_GOLEM, $FF,  LOC_TRAIN, LOC_MARKET, LOC_GATE, LOC_TEMPLE, LOC_ALLEY, $FF,  LOC_GRAVE, $FF,  LOC_PLAZA
exitE:
	.byte LOC_MARKET, $FF,       LOC_PLAZA, LOC_TRAIN, LOC_ALLEY, $FF,       LOC_GROVE, LOC_TAVERN, LOC_INN, LOC_WITCH, $FF, $FF, LOC_GOLEM
exitS:
	.byte LOC_PLAZA, LOC_ALLEY,  LOC_WITCH, LOC_GATE,  LOC_TEMPLE, LOC_TAVERN, $FF, $FF, $FF, LOC_CATACOMBS, $FF, $FF, LOC_GROVE
exitW:
	.byte LOC_GOLEM, LOC_TRAIN,  $FF,       LOC_TEMPLE, LOC_GATE, LOC_PLAZA, LOC_GRAVE, LOC_WITCH, LOC_GROVE, $FF, $FF, LOC_TAVERN, $FF

// NPC masks by location (bit 0..5)
npcMaskByLoc:
	.byte %0001 // TRAIN: CONDUCTOR
	.byte %0000 // MARKET
	.byte %0100 // GATE: KNIGHT
	.byte %0000 // GOLEM
	.byte %0000 // PLAZA
	.byte %0000 // ALLEY
	.byte %1000 // WITCHWOOD: WITCH
	.byte %00110000 // FAIRY GARDENS: FAIRY + PIXIE
	.byte %0010 // TAVERN: BARTENDER
	.byte %0000 // LOUDEN'S REST
	.byte %0000 // CATACOMBS
	.byte %0000 // PIGGLYWEED INN
	.byte %0000 // TEMPLE RUINS

// Default NPC to address in a location when only one is present
npcDefaultByLoc:
	.byte NPC_CONDUCTOR, $FF, NPC_KNIGHT, $FF, $FF, $FF, NPC_WITCH, NPC_FAIRY, NPC_BARTENDER, $FF, $FF, $FF, $FF

// One-line talk per location (MVP)
npcTalkLoByLoc:
	.byte <talkConductor,<msgNoOne,<talkKnight,<msgNoOne,<msgNoOne,<msgNoOne,<talkWitch,<talkFairy,<talkBartender,<msgNoOne,<msgNoOne,<msgNoOne,<msgNoOne
npcTalkHiByLoc:
	.byte >talkConductor,>msgNoOne,>talkKnight,>msgNoOne,>msgNoOne,>msgNoOne,>talkWitch,>talkFairy,>talkBartender,>msgNoOne,>msgNoOne,>msgNoOne,>msgNoOne

talkConductor: .text "THE CONDUCTOR SAYS: ALL ABOARD THE IMAGINATION EXPRESS!"
	.byte 0
talkBartender: .text "THE BARTENDER SAYS: CAREFUL WHAT YOU PROMISE IN HERE."
	.byte 0
talkKnight:    .text "THE KNIGHT SAYS: HONOR OPENS MORE DOORS THAN KEYS."
	.byte 0
talkWitch:     .text "THE WITCH SAYS: WORDS HAVE POWER. CHOOSE THEM WELL."
	.byte 0
talkFairy:     .text "A FAIRY SAYS: LISTEN CLOSELY. THE GARDENS REMEMBER YOUR KINDNESS."
	.byte 0
talkPixie:     .text "A PIXIE CHIMES: TRADE A SECRET FOR A SPARKLE!"
	.byte 0

npcTalkLo:
	.byte <talkConductor,<talkBartender,<talkKnight,<talkWitch,<talkFairy,<talkPixie
npcTalkHi:
	.byte >talkConductor,>talkBartender,>talkKnight,>talkWitch,>talkFairy,>talkPixie

// Which quest (if any) each NPC can offer
npcOffersQuest:
	.byte QUEST_NONE, QUEST_COIN_BARTENDER, QUEST_KEY_KNIGHT, QUEST_LANTERN_WITCH, QUEST_NONE, QUEST_NONE

// Conversation strings
msgAskWeather: .text "THE SKY LOOKS LIKE IT'LL HOLD FOR NOW."
	.byte 0
msgTempResponse: .text "YOU SENSE THE AIR: IT FEELS A LITTLE CHILLY."
	.byte 0
msgQuestOfferGeneric: .text "I MIGHT HAVE SOMETHING FOR YOU."
	.byte 0
msgNoQuestNpc: .text "I HAVE NOTHING FOR YOU, FRIEND."
	.byte 0
msgEndConversation: .text "YOU END THE CONVERSATION."
	.byte 0


// NPC class names (for sheets)
className0: .text "CONDUCTOR"
	.byte 0
className1: .text "BARTENDER"
	.byte 0
className2: .text "KNIGHT"
	.byte 0
className3: .text "WITCH"
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
	.byte 0,1,2,3,4,5
npcLevel:
	.byte 1,1,2,3,1,1
npcScoreLo:
	.byte 0,0,0,0,0,0
npcScoreHi:
	.byte 0,0,0,0,0,0
// NPC current HP (persisted across saves)
npcCurHp:
	.byte 0,0,0,0,0,0

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
	pc_hp_loop:
		lda tmpCnt
		beq pc_hp_done
		lda tmpHp
		clc
		adc tmpPer
		sta tmpHp
		dec tmpCnt
		jmp pc_hp_loop
	pc_hp_done:
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
kwWitch:     .text "WITCH"
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

npcBit:
	.byte %0001,%0010,%0100,%1000,%00010000,%00100000

npcName0: .text "CONDUCTOR"
	.byte 0
npcName1: .text "BARTENDER"
	.byte 0
npcName2: .text "KNIGHT"
	.byte 0
npcName3: .text "WITCH"
	.byte 0
npcName4: .text "FAIRY"
	.byte 0
npcName5: .text "PIXIE"
	.byte 0

npcNameLo:
	.byte <npcName0,<npcName1,<npcName2,<npcName3,<npcName4,<npcName5
npcNameHi:
	.byte >npcName0,>npcName1,>npcName2,>npcName3,>npcName4,>npcName5

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
questName2: .text "LIGHT FOR THE WITCH"
	.byte 0

questNameLo:
	.byte <questName0,<questName1,<questName2
questNameHi:
	.byte >questName0,>questName1,>questName2

questDetail0: .text "QUEST: GIVE COIN TO THE BARTENDER."
	.byte 0
questDetail1: .text "QUEST: GIVE KEY TO THE KNIGHT."
	.byte 0
questDetail2: .text "QUEST: GIVE LANTERN TO THE WITCH."
	.byte 0

questDetailLo:
	.byte <questDetail0,<questDetail1,<questDetail2
questDetailHi:
	.byte >questDetail0,>questDetail1,>questDetail2
