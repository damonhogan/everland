// profile.hpp
// Profile creation, loading, and commit logic for Everland C++ port
#pragma once
#include <string>
#include "state.hpp"

// Save/load buffer for profile data
struct ProfileBuffer {
    std::string username;
    std::string displayName;
    std::string className;
    std::string raceName;
    uint16_t pin = 0;
    uint16_t score = 0;
    uint8_t level = 0;
    uint8_t curHp = 0;
    uint8_t classIdx = 0;
    uint8_t raceIdx = 0;
    uint8_t month = 1;
    uint8_t week = 1;
    uint8_t loc = LOC_PLAZA;
    std::array<uint8_t, OBJ_COUNT> objLoc = {};
    uint8_t activeQuest = 0xFF;
    uint8_t questStatus = 0;
    // ... add more fields as needed
};

extern ProfileBuffer loadedProfile;

void copyInputToUsername(const std::string& input);
void copyInputToDisplay(const std::string& input);
void copyInputToClass(const std::string& input);
void copyInputToRace(const std::string& input);
void mapPlayerClass();
void mapPlayerRace();
void commitLoadedState();
