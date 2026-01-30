#pragma once
#include <vector>
#include <random>

// Per-choice effect types for menu options
// 0=none,1=startQuest,2=completeQuest,3=giveItem,4=takeItem,5=addScore,6=setNpcStage
extern const std::vector<std::vector<int>> convChoiceType;
extern const std::vector<std::vector<int>> convChoiceVal;

// Random number generator
int randomByte();
