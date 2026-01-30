// state.hpp
// C++ translation of core state and constants from everland.asm
#pragma once
#include <cstdint>
#include "constants.hpp"

// Player state
struct PlayerState {
    char raceName[12] = {};
    uint8_t playerRaceIdx = 0;
    uint16_t pin = 0;
    uint8_t currentLevel = 0;
    uint16_t score = 0;
    uint8_t activeQuest = 0;
    uint8_t questStatus = 0;
    uint8_t gold = 0, silver = 0, copper = 0;
};

// Game and UI state
struct GameState {
    uint8_t currentLoc = LOC_PLAZA;
    uint8_t prevLoc = LOC_PLAZA;
    uint16_t lastMsg = 0; // pointer to message string (stub)
    uint8_t uiHideExits = 0;
    uint8_t uiInConversation = 0;
    // ... more fields as needed
};

extern PlayerState player;
extern GameState game;
