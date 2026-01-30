#pragma once
#include <vector>

// Assign random trinkets to player (fills playerTrinkets with 5 random values)
void assignRandomTrinkets(std::vector<int>& playerTrinkets);

// Assign random trinkets to an NPC (fills npcTrinkets with up to 3 random values)
void assignNpcTrinkets(int npcIndex, std::vector<std::vector<int>>& npcTrinkets, std::vector<bool>& npcTrinketsAssigned);

// Trade trinkets between player and NPC
bool tradeTrinkets(std::vector<int>& playerTrinkets, std::vector<int>& npcTrinkets, int playerIdx, int npcIdx);
