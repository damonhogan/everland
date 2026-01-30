// music.cpp
#include "music.hpp"
#include <iostream>

void musicInit() {
    // Stub: initialize SID/music engine for VS64
    std::cout << "[Music] Init" << std::endl;
}

void musicPickForLocation() {
    // Stub: pick music theme for location
}

void musicApplyThemeSettings() {}
void musicAllNotesOff() {}
void musicPickRandomPattern() {}
void musicRestart() {}
void musicTickRoutine() {}
void musicAdvanceLead() {}
void musicAdvanceBass() {}
void musicAdvanceSparkle() {}

void advanceWeek() {
    game.week++;
    if (game.week > 52) game.week = 1;
    if (player.questStatus == 2) {
        player.activeQuest = 0xFF;
        player.questStatus = 0;
        ensureQuest();
    }
    // TODO: Set week advanced message, save game
}
