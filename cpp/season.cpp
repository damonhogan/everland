// season.cpp
#include "season.hpp"
#include <iostream>

Season getSeason() {
    if (game.currentLoc < 4) return SEASON_OFF;
    if (game.currentLoc < 9) return SEASON_MYTHOS;
    if (game.currentLoc < 11) return SEASON_LORE;
    if (game.currentLoc < 13) return SEASON_AURORA;
    return SEASON_OFF;
}

void renderSeasonLine() {
    // Stub: just print season name
    Season s = getSeason();
    std::cout << "Season: ";
    switch (s) {
        case SEASON_MYTHOS: std::cout << "Mythos"; break;
        case SEASON_LORE: std::cout << "Lore"; break;
        case SEASON_AURORA: std::cout << "Aurora"; break;
        default: std::cout << "Off"; break;
    }
    std::cout << std::endl;
}
