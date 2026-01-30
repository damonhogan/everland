// season.hpp
// Season and weather logic for Everland C++ port
#pragma once
#include <cstdint>
#include "state.hpp"

enum Season : uint8_t {
    SEASON_OFF = 0,
    SEASON_MYTHOS = 1,
    SEASON_LORE = 2,
    SEASON_AURORA = 3
};

Season getSeason();
void renderSeasonLine();
