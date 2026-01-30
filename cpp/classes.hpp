#pragma once
#include <string>
#include <vector>

// NPC and player class names
extern const std::vector<std::string> npcClassNames;
extern const std::vector<std::string> playerClassNames;

// Class stats
extern const std::vector<int> classBaseHp;
extern const std::vector<int> classHpPerLevel;
extern const std::vector<int> playerClassBaseHp;
extern const std::vector<int> playerClassHpPerLevel;

// NPC attributes
extern const std::vector<int> npcClassIdx;
extern const std::vector<int> npcLevel;
extern const std::vector<int> npcScore;
extern const std::vector<int> npcCurHp;

// Compute max HP for an NPC given npc index
int computeNpcMaxHp(int npcIndex);
