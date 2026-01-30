// constants.hpp
// C++ translation of constants.inc for Everland (VS64 port)
#pragma once
#include <cstdint>

// KERNAL routines (for reference only)
constexpr uint16_t CHROUT = 0xFFD2;
constexpr uint16_t SCNKEY = 0xFF9F;
constexpr uint16_t GETIN  = 0xFFE4;
constexpr uint16_t PLOT   = 0xFFF0;
constexpr uint16_t SETNAM = 0xFFBD;
constexpr uint16_t SETLFS = 0xFFBA;
constexpr uint16_t OPEN   = 0xFFC0;
constexpr uint16_t CLOSE  = 0xFFC3;
constexpr uint16_t CHKIN  = 0xFFC6;
constexpr uint16_t CHKOUT = 0xFFC9;
constexpr uint16_t CLRCHN = 0xFFCC;
constexpr uint16_t CHRIN  = 0xFFCF;
constexpr uint16_t READST = 0xFFB7;

// SID registers (for reference only)
constexpr uint16_t SID_V1_FREQLO = 0xD400;
constexpr uint16_t SID_V1_FREQHI = 0xD401;
constexpr uint16_t SID_V1_PWLO   = 0xD402;
constexpr uint16_t SID_V1_PWHI   = 0xD403;
constexpr uint16_t SID_V1_CTRL   = 0xD404;
constexpr uint16_t SID_V1_AD     = 0xD405;
constexpr uint16_t SID_V1_SR     = 0xD406;
constexpr uint16_t SID_V2_FREQLO = 0xD407;
constexpr uint16_t SID_V2_FREQHI = 0xD408;
constexpr uint16_t SID_V2_PWLO   = 0xD409;
constexpr uint16_t SID_V2_PWHI   = 0xD40A;
constexpr uint16_t SID_V2_CTRL   = 0xD40B;
constexpr uint16_t SID_V2_AD     = 0xD40C;
constexpr uint16_t SID_V2_SR     = 0xD40D;
constexpr uint16_t SID_V3_FREQLO = 0xD40E;
constexpr uint16_t SID_V3_FREQHI = 0xD40F;
constexpr uint16_t SID_V3_PWLO   = 0xD410;
constexpr uint16_t SID_V3_PWHI   = 0xD411;
constexpr uint16_t SID_V3_CTRL   = 0xD412;
constexpr uint16_t SID_V3_AD     = 0xD413;
constexpr uint16_t SID_V3_SR     = 0xD414;
constexpr uint16_t SID_MODE_VOL  = 0xD418;

// IRQ vectors
constexpr uint16_t IRQ_VEC_LO = 0x0314;
constexpr uint16_t IRQ_VEC_HI = 0x0315;

// VIC raster IRQ
constexpr uint16_t VIC_IRQFLAG = 0xD019;
constexpr uint16_t VIC_IRQMASK = 0xD01A;
constexpr uint16_t VIC_RASTER  = 0xD012;
constexpr uint16_t VIC_CTRL1   = 0xD011;

// Memory and ZP
constexpr uint16_t SCREEN = 0x0400;
constexpr uint8_t ZP_PTR  = 0xFB;
constexpr uint8_t ZP_PTR2 = 0xFD;

// IEC/device constants
constexpr uint8_t DEVICE = 8;
constexpr uint8_t LFN    = 1;
constexpr uint8_t SA     = 2;

// Location constants
enum Location : uint8_t {
    LOC_TRAIN = 0,
    LOC_MARKET = 1,
    LOC_PORTAL = 2,
    LOC_GOLEM = 3,
    LOC_PLAZA = 4,
    LOC_ALLEY = 5,
    LOC_MYSTIC = 6,
    LOC_GROVE = 7,
    LOC_TAVERN = 8,
    LOC_GRAVE = 9,
    LOC_CATACOMBS = 10,
    LOC_INN = 11,
    LOC_TEMPLE = 12,
    LOC_COUNT = 13
};

// Object constants
enum Object : uint8_t {
    OBJ_LANTERN = 0,
    OBJ_COIN = 1,
    OBJ_MUG = 2,
    OBJ_KEY = 3,
    OBJ_TREASURE = 4,
    OBJ_STOLEN_NAME = 5,
    OBJ_HEART = 6,
    OBJ_PINECONE = 7,
    OBJ_SHELL = 8,
    OBJ_SCOTCH = 9,
    OBJ_WARD = 10,
    OBJ_COUNT = 11,
    OBJ_INVENTORY = 0xFE,
    OBJ_NOWHERE = 0xFF
};

// NPC constants
enum NPC : uint8_t {
    NPC_CONDUCTOR = 0,
    NPC_BARTENDER = 1,
    NPC_KNIGHT = 2,
    NPC_MYSTIC = 3,
    NPC_FAIRY = 4,
    NPC_KENDRICK = 5,
    NPC_SPIDER_PRINCESS = 6,
    NPC_PIRATE_CAPTAIN = 7,
    NPC_WARLOCK = 8,
    NPC_UNSEELY_FAE = 9,
    NPC_APOLLONIA = 10,
    NPC_ALYSTER = 11,
    NPC_TROLL = 12,
    NPC_TOSH = 13,
    NPC_LOUDEN = 14,
    NPC_MERMAID = 15,
    NPC_CANDY_WITCH = 16,
    NPC_PIXIE = 4,
    NPC_PIRATE_FIRSTMATE = 7,
    NPC_COUNT = 32
};
