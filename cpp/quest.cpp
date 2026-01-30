// quest.cpp
#include "quest.hpp"
#include "state.hpp"
#include <iostream>
#include <array>

void renderQuestLine() {
    std::cout << "WEEK " << int(game.week) << "  SCORE " << int(player.score) << "  QUEST ";
    // TODO: Print quest name or NONE
    std::cout << std::endl;
}

void assignQuest_mod(uint8_t questId) {
    while (questId >= 15) questId -= 15;
    player.activeQuest = questId;
    player.questStatus = 1;
}

void questComplete() {
    if (player.questStatus == 2) return;
    player.questStatus = 2;
    player.score++;
    // TODO: Level up logic
    // TODO: Set quest done message, log, and dispatch reward
}

void ensureQuest() {
    // Stub
}

// Quest reward stubs
void reward_bartender() {}
void reward_treasure() {}
void reward_lure() {}
void reward_unseely() {}
void reward_apollonia() {}
void reward_kendrick() {}
void reward_warlock() {}
void reward_candywitch() {}
void reward_kora() {}
void reward_default() {}
