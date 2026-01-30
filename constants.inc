// Core labels and constants for Everland

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

// Memory and ZP
.label SCREEN = $0400
.label ZP_PTR  = $FB
.label ZP_PTR2 = $FD

// IEC/device constants
.const DEVICE = 8
.const LFN    = 1
.const SA     = 2

// Location constants (Gate → Portal)
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
.const LOC_COUNT     = 13

// Object constants
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
.const OBJ_COUNT       = 13
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
.const NPC_PIXIE            = 4
.const NPC_PIRATE_FIRSTMATE = 7
.const NPC_COUNT            = 32
