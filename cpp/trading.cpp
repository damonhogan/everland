#include "trading.hpp"
#include "trinket.hpp"
#include <vector>

void assignRandomTrinkets(std::vector<int>& playerTrinkets) {
    playerTrinkets.clear();
    for (int i = 0; i < 5; ++i) {
        playerTrinkets.push_back(randomByte() % 32);
    }
}

void assignNpcTrinkets(int npcIndex, std::vector<std::vector<int>>& npcTrinkets, std::vector<bool>& npcTrinketsAssigned) {
    if (npcTrinketsAssigned[npcIndex]) return;
    int num = randomByte() % 4; // 0-3 trinkets
    npcTrinkets[npcIndex].clear();
    for (int i = 0; i < num; ++i) {
        npcTrinkets[npcIndex].push_back(randomByte() % 32);
    }
    npcTrinketsAssigned[npcIndex] = true;
}

bool tradeTrinkets(std::vector<int>& playerTrinkets, std::vector<int>& npcTrinkets, int playerIdx, int npcIdx) {
    if (playerIdx < 0 || playerIdx >= (int)playerTrinkets.size()) return false;
    if (npcIdx < 0 || npcIdx >= (int)npcTrinkets.size()) return false;
    std::swap(playerTrinkets[playerIdx], npcTrinkets[npcIdx]);
    return true;
}
