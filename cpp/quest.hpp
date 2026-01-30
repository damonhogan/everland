// quest.hpp
// Quest system for Everland C++ port
#pragma once
#include <cstdint>
#include <string>

void renderQuestLine();
void assignQuest_mod(uint8_t questId);
void questComplete();
void ensureQuest();

// Quest reward dispatch
void reward_bartender();
void reward_treasure();
void reward_lure();
void reward_unseely();
void reward_apollonia();
void reward_kendrick();
void reward_warlock();
void reward_candywitch();
void reward_kora();
void reward_default();
