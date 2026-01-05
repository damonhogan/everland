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
irqOldLo: .byte 0
irqOldHi: .byte 0

// Dynamic message buffer (used for characters/inventory listings)
msgBufLen: .byte 0
msgBuf:
	.fill 96, 0

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
loadedObjLoc:
	.fill OBJ_COUNT, 0
loadedActiveQuest: .byte QUEST_NONE
loadedQuestStatus: .byte 0
loadedDisplay:
	.fill 16, 0

commitLoadedState:
	lda loadedPinLo
	sta pinLo
	lda loadedPinHi
	sta pinHi
	lda loadedScoreLo
	sta scoreLo
	lda loadedScoreHi
	sta scoreHi
	lda loadedMonth
	sta month
	lda loadedWeek
	sta week
	lda loadedLoc
	sta currentLoc
	ldx #0
@c1:
	lda loadedObjLoc,x
	sta objLoc,x
	inx
	cpx #OBJ_COUNT
	bne @c1
	lda loadedActiveQuest
	sta activeQuest
	lda loadedQuestStatus
	sta questStatus
	// Copy display
	ldx #0
@c2:
	lda loadedDisplay,x
	sta displayName,x
	inx
	cpx #16
	bne @c2
	rts

// Copy inputBuf to username (max 12)
copyInputToUsername:
	ldx #0
	stx usernameLen

@cu_loop:
	lda inputBuf,x
	beq @cu_done
	cpx #12
	bcs @cu_done
	sta username,x
	inx
	stx usernameLen
	jmp @cu_loop

@cu_done:
	// Pad remaining with 0
	lda #0

@cu_pad:
	cpx #12
	beq @cu_pdone
	sta username,x
	inx
	jmp @cu_pad

@cu_pdone:
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
	bne @fail2
	jsr CHRIN
	cmp #'V'
	bne @fail2
	jsr CHRIN
	cmp #'1'
	bne @fail2
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
	bne @sg_done
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

questComplete:
	lda questStatus
	cmp #2
	beq @qc_done
	lda #2
	sta questStatus
	inc scoreLo
	lda scoreLo
	bne @qc_msg
	inc scoreHi

@qc_msg:
	lda #<msgQuestDone
	sta lastMsgLo
	lda #>msgQuestDone
	sta lastMsgHi
	jsr saveGame

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
	// Some quests can persist; MVP: rotate if completed, else keep
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
	sei
	// Disable CIA interrupts; we run a VIC raster IRQ only.
	lda #$7F
	sta $DC0D
	sta $DD0D
	lda $DC0D
	lda $DD0D
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
	cli
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
	jsr musicPickRandomPattern
	jsr musicRestart
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
	rti

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
	lda #%00010001 // TRI + GATE
	sta SID_V1_CTRL
	jmp @mal_next

@mal_rest:
	lda #%00010000 // TRI, gate off
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
	lda #%00010001
	sta SID_V2_CTRL
	jmp @mab_next

@mab_rest:
	lda #%00010000
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
	// Only active for Aurora (3) and Tavern (5); otherwise gate off.
	lda musicTheme
	cmp #3
	beq @mas_do
	cmp #5
	beq @mas_do
	cmp #8
	beq @mas_do
	lda #%01000000 // PULSE, gate off
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
	lda #%01000001 // PULSE + GATE
	sta SID_V3_CTRL
	jmp @mas_next

@mas_rest:
	lda #%01000000
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
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte 0,0,0,1,0,0,1,0,0,1,1,0,0

// Indoor/location music override ($FF = none). Theme ids match musicTheme.
// Tavern/Inn/Temple override outdoor seasonal music.
locMusicOverride:
	// TRAIN, MARKET, GATE, GOLEM, PLAZA, ALLEY, WITCH, GROVE, TAVERN, GRAVE, CATACOMBS, INN, TEMPLE
	.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,8,5,$FF,$FF,6,7

// Notes table (indices used in sequences):
// 1=C4 2=D4 3=E4 4=F4 5=G4 6=A4 7=B4 8=C5 9=D5 10=E5 11=G5 12=A5
noteFreqLo:
	.byte $67,$89,$ED,$3B,$13,$45,$DA,$CE,$11,$DA,$26,$89
noteFreqHi:
	.byte $11,$13,$15,$17,$1A,$1D,$20,$22,$27,$2B,$34,$3A

// --- Music patterns (16 steps each; 0=rest; note index 1..12) ---
// MYTHOS (soft, major)
myLead0: .byte 1,0,3,0,5,0,8,0,5,0,3,0,2,0,1,0
myLead1: .byte 3,0,5,0,6,0,8,0,6,0,5,0,3,0,2,0
myLead2: .byte 5,0,6,0,8,0,10,0,8,0,6,0,5,0,3,0
myBass0: .byte 1,0,1,0,5,0,5,0,6,0,6,0,5,0,1,0
myBass1: .byte 1,0,3,0,5,0,5,0,6,0,5,0,3,0,2,0
myBass2: .byte 5,0,5,0,6,0,6,0,8,0,8,0,6,0,5,0

// LORE (minor-ish, slower feel)
loLead0: .byte 6,0,5,0,3,0,2,0,3,0,5,0,6,0,5,0
loLead1: .byte 5,0,3,0,2,0,1,0,2,0,3,0,5,0,3,0
loLead2: .byte 6,0,8,0,7,0,6,0,5,0,3,0,2,0,1,0
loBass0: .byte 6,0,6,0,5,0,5,0,3,0,3,0,2,0,2,0
loBass1: .byte 5,0,5,0,3,0,3,0,2,0,2,0,1,0,1,0
loBass2: .byte 6,0,6,0,7,0,7,0,5,0,5,0,3,0,3,0

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
scLead0: .byte 6,0,7,0,6,0,5,0,6,0,3,0,2,0,1,0
scLead1: .byte 7,0,6,0,7,0,8,0,7,0,6,0,5,0,3,0
scLead2: .byte 6,0,0,0,7,0,0,0,6,0,5,0,3,0,2,0
scBass0: .byte 1,0,0,0,2,0,0,0,1,0,0,0,5,0,0,0
scBass1: .byte 2,0,0,0,1,0,0,0,3,0,0,0,2,0,0,0
scBass2: .byte 1,0,0,0,1,0,0,0,2,0,0,0,1,0,0,0

// TAVERN (indoor, cozy)
tvLead0: .byte 5,0,6,0,5,0,3,0,2,0,3,0,5,0,6,0
tvLead1: .byte 6,0,8,0,6,0,5,0,3,0,5,0,6,0,8,0
tvLead2: .byte 3,0,5,0,6,0,5,0,3,0,2,0,1,0,2,0
tvBass0: .byte 1,0,1,0,3,0,3,0,5,0,5,0,6,0,6,0
tvBass1: .byte 3,0,3,0,5,0,5,0,6,0,6,0,5,0,3,0
tvBass2: .byte 5,0,5,0,6,0,6,0,8,0,8,0,6,0,5,0

tvSpk0:  .byte 8,0,0,0,10,0,0,0,11,0,0,0,10,0,0,0
tvSpk1:  .byte 10,0,0,0,11,0,0,0,12,0,0,0,11,0,0,0
tvSpk2:  .byte 11,0,0,0,10,0,0,0,9,0,0,0,10,0,0,0

// INN (warm, restful)
inLead0: .byte 3,0,5,0,6,0,5,0,3,0,2,0,3,0,5,0
inLead1: .byte 5,0,6,0,8,0,6,0,5,0,3,0,2,0,3,0
inLead2: .byte 6,0,5,0,3,0,2,0,3,0,5,0,6,0,8,0
inBass0: .byte 1,0,1,0,3,0,3,0,5,0,5,0,3,0,3,0
inBass1: .byte 3,0,3,0,5,0,5,0,6,0,6,0,5,0,3,0
inBass2: .byte 5,0,5,0,3,0,3,0,2,0,2,0,1,0,1,0

// TEMPLE (martial)
tpLead0: .byte 1,1,0,3,3,0,5,5,0,6,6,0,5,5,0,3
tpLead1: .byte 3,3,0,5,5,0,6,6,0,8,8,0,6,6,0,5
tpLead2: .byte 5,5,0,6,6,0,5,5,0,3,3,0,2,2,0,1
tpBass0: .byte 1,0,1,0,1,0,3,0,3,0,5,0,5,0,3,0
tpBass1: .byte 3,0,3,0,5,0,5,0,6,0,6,0,5,0,3,0
tpBass2: .byte 5,0,5,0,6,0,6,0,8,0,8,0,6,0,5,0

// FAIRY (light, sparkly)
faLead0: .byte 8,0,10,0,12,0,11,0,10,0,9,0,8,0,10,0
faLead1: .byte 10,0,11,0,12,0,0,0,11,0,10,0,9,0,8,0
faLead2: .byte 8,0,9,0,10,0,11,0,12,0,11,0,10,0,9,0
faBass0: .byte 1,0,5,0,1,0,6,0,1,0,5,0,3,0,2,0
faBass1: .byte 3,0,6,0,3,0,5,0,2,0,5,0,1,0,0,0
faBass2: .byte 1,0,0,0,5,0,0,0,6,0,0,0,5,0,0,0

faSpk0:  .byte 12,0,0,0,11,0,0,0,12,0,0,0,10,0,0,0
faSpk1:  .byte 11,0,0,0,12,0,0,0,11,0,0,0,10,0,0,0
faSpk2:  .byte 10,0,0,0,11,0,0,0,12,0,0,0,11,0,0,0

// PIRATE (jaunty)
piLead0: .byte 5,0,5,0,6,0,5,0,3,0,2,0,3,0,5,0
piLead1: .byte 6,0,6,0,8,0,6,0,5,0,3,0,5,0,6,0
piLead2: .byte 8,0,8,0,6,0,5,0,3,0,2,0,1,0,2,0
piBass0: .byte 1,0,0,0,5,0,0,0,1,0,0,0,6,0,0,0
piBass1: .byte 3,0,0,0,6,0,0,0,3,0,0,0,5,0,0,0
piBass2: .byte 5,0,0,0,8,0,0,0,5,0,0,0,6,0,0,0

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
	.byte <noSpkPtr,<noSpkPtr,<noSpkPtr,<auSpkPtr,<noSpkPtr,<tvSpkPtr,<noSpkPtr,<noSpkPtr,<faSpkPtr,<noSpkPtr
themeSparkNotesHi:
	.byte >noSpkPtr,>noSpkPtr,>noSpkPtr,>auSpkPtr,>noSpkPtr,>tvSpkPtr,>noSpkPtr,>noSpkPtr,>faSpkPtr,>noSpkPtr

init:
	lda #1
	sta uiHideExits
	jsr loginOrCreate
	lda #0
	sta uiHideExits
	jsr ensureQuest
	rts

// --- Rendering ---
render:
	jsr clearScreen
	// During login/account creation, keep the screen minimal.
	lda uiHideExits
	beq render_game
	// Auth mode: only message + prompt.
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

drawMap:
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
	lda #'X'
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

// --- Input ---
readLine:
	lda #0
	sta inputLen

@poll:
	jsr SCNKEY
	jsr GETIN
	beq @poll

	cmp #$0D // RETURN
	beq @finish
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
	cmp #'N'
	bne @ec_chkS
	jmp cmdNorth
@ec_chkS:
	cmp #'S'
	bne @ec_chkE
	jmp cmdSouth
@ec_chkE:
	cmp #'E'
	bne @ec_chkW
	jmp cmdEast
@ec_chkW:
	cmp #'W'
	bne @ec_chkC
	jmp cmdWest
@ec_chkC:
	cmp #'C'
	bne @ec_chkT
	jmp cmdCharacters
@ec_chkT:
	cmp #'T'
	bne @ec_chkI
	jmp cmdTalk
@ec_chkI:
	cmp #'I'
	bne @ec_afterQuick
	jmp cmdInventory

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
	jmp cmdTalk

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
	jmp cmdCharacters

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
	bcc @ec_unknown
	jmp cmdStatus

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
	cmp inputBuf,x
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
@yes:
	sec
	rts

// Skip spaces starting at X; returns X at first non-space
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
	bcc @witch
	lda #NPC_KNIGHT
	sec
	rts
@witch:
	txa
	pha
	lda #<kwWitch
	sta ZP_PTR2
	lda #>kwWitch
	sta ZP_PTR2+1
	pla
	tax
	jsr matchKeywordAtX
	bcc @fairy
	lda #NPC_WITCH
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

cmdCharacters:
	jsr buildCharactersMessage
	lda #<msgBuf
	sta lastMsgLo
	lda #>msgBuf
	sta lastMsgHi
	rts

cmdTalk:
	// Support: TALK, TALK TO BARTENDER, T KNIGHT
	ldx #0
@t0:
	lda inputBuf,x
	beq @default
	cmp #' '
	beq @afterVerb
	inx
	bne @t0
@afterVerb:
	jsr parseNpcNoun
	bcc @default
	tax
	ldy currentLoc
	lda npcMaskByLoc,y
	and npcBit,x
	beq @talk_notHere
	lda npcTalkLo,x
	sta lastMsgLo
	lda npcTalkHi,x
	sta lastMsgHi
	rts

@talk_notHere:
	lda #<msgNpcNotHere
	sta lastMsgLo
	lda #>msgNpcNotHere
	sta lastMsgHi
	rts
@default:
	ldx currentLoc
	lda npcMaskByLoc,x
	beq @talk_none
	// Default talk for the location
	lda npcTalkLoByLoc,x
	sta lastMsgLo
	lda npcTalkHiByLoc,x
	sta lastMsgHi
	rts

@talk_none:
	lda #<msgNoOne
	sta lastMsgLo
	lda #>msgNoOne
	sta lastMsgHi
	rts

cmdInspect:
	// If noun present, inspect object; else re-describe location
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
	// Handle "PICK UP <obj>"; if no UP, treat as TAKE
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
	// Handle "SET DOWN <obj>"; else DROP
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
	lda npcMaskByLoc,y
	and npcBit,x
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
@ret:
	rts

@noTarget:
	// If no explicit target, require someone here
	ldx currentLoc
	lda npcMaskByLoc,x
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
	// QUEST_LANTERN_WITCH
	lda ZP_PTR2
	cmp #OBJ_LANTERN
	bne @qcg_no
	lda ZP_PTR2+1
	cmp #NPC_WITCH
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

cmdStatus:
	// Show quest detail in last message
	lda activeQuest
	cmp #QUEST_NONE
	beq @status_none
	tax
	lda questDetailLo,x
	sta lastMsgLo
	lda questDetailHi,x
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
	jsr buildInventoryMessage
	lda #<msgBuf
	sta lastMsgLo
	lda #>msgBuf
	sta lastMsgHi
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
	lda npcMaskByLoc,x
	beq @bcm_none
	sta ZP_PTR2 // reuse low byte as mask temp

	ldx #0
@npcLoop:
	lda ZP_PTR2
	and npcBit,x
	beq @next
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
@next:
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

// --- UI Strings / Messages ---
strExits:  .text "EXITS: "
	.byte 0
strHelp1:  .text "N/E/S/W MOVE  I INV  C CHARS  T TALK"
	.byte 0
strHelp2:  .text "WAIT STATUS SAVE LOAD INSPECT TAKE DROP"
	.byte 0
strPrompt: .text "> "
	.byte 0

strWeek:  .text "WEEK "
	.byte 0
strScore: .text "  SCORE "
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
msgLoadFail:    .text "LOAD FAILED."
	.byte 0
msgWeekAdvanced:.text "A WEEK PASSES. NEW STORIES STIR."
	.byte 0
msgQuestDone:   .text "QUEST COMPLETE!"
	.byte 0
msgNoQuest:     .text "NO ACTIVE QUEST."
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

