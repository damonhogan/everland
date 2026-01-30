#include "classes.hpp"
#include <string>
#include <vector>

const std::vector<std::string> npcClassNames = {
    "CONDUCTOR", "BARTENDER", "KNIGHT", "MYSTIC", "FAIRY", "PIXIE", "PIRATE"
};
const std::vector<std::string> playerClassNames = {
    "MAGE", "KNIGHT", "HEALER", "BARD", "WIZARD"
};
const std::vector<int> classBaseHp = {20, 16, 24, 12, 10, 8, 18};
const std::vector<int> classHpPerLevel = {5, 3, 6, 4, 2, 2, 5};
const std::vector<int> playerClassBaseHp = {12, 24, 14, 10, 10};
const std::vector<int> playerClassHpPerLevel = {4, 6, 5, 2, 3};
const std::vector<int> npcClassIdx = {0,1,2,3,4,2,4,6,6,4,3,2,2,1,3,4,4,3,2,2,1,4,0,0,0,0,0,0,0,0,0,0};
const std::vector<int> npcLevel = {1,1,2,3,1,1,1,2,1,1,1,2,2,1,1,2,3,2,4,3,2,4,1,1,1,1,1,1,1,1,1,1};
const std::vector<int> npcScore = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
const std::vector<int> npcCurHp = {25,19,36,24,12,30,12,28,23,12,16,36,36,19,16,14,16,20,48,42,22,18,10,10,10,10,10,10,10,10,10,10};

int computeNpcMaxHp(int npcIndex) {
    extern const std::vector<int> npcClassIdx;
    extern const std::vector<int> classBaseHp;
    extern const std::vector<int> classHpPerLevel;
    extern const std::vector<int> npcLevel;
    int classIdx = npcClassIdx[npcIndex];
    int hp = classBaseHp[classIdx];
    int per = classHpPerLevel[classIdx];
    int level = npcLevel[npcIndex];
    for (int i = 0; i < level; ++i) {
        hp += per;
    }
    return hp;
}
