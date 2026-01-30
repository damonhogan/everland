#include "player.hpp"
#include <vector>

int computePlayerMaxHp(int classIdx, int level, int hpBonus, const std::vector<int>& baseHp, const std::vector<int>& hpPerLevel) {
    int hp = baseHp[classIdx];
    for (int i = 0; i < level; ++i) {
        hp += hpPerLevel[classIdx];
    }
    hp += hpBonus;
    return hp;
}
