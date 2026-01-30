#pragma once
#include <vector>
#include <string>

// Character and NPC menu logic for Everland
void showCharacterMenu();
void showTalkMenu();
void showNpcSheet(int npcIndex);
void showPlayerSheet();
void conversationMenu(int npcIndex);

// Helper: returns a list of present NPC indices at current location
std::vector<int> getPresentNpcs();

// UI helpers for quest log, quest details, inventory, and trinkets
void showQuestLog(const std::vector<int>& activeQuests);
void showQuestDetails(int questId);
void showInventory(const std::vector<int>& inventory);
void showTrinkets(const std::vector<int>& trinkets);
