#pragma once
#include <vector>

// Compute max HP for player given class index, level, and bonus
int computePlayerMaxHp(int classIdx, int level, int hpBonus, const std::vector<int>& baseHp, const std::vector<int>& hpPerLevel);
