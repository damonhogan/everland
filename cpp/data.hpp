// Secrets/hidden content system: names, hints, and reveal flags
extern std::vector<std::string> secretNames;
extern std::vector<std::string> secretHints;
extern std::vector<bool> secretRevealed;
// Achievements system: names and descriptions
extern std::vector<std::string> achievementNames;
extern std::vector<std::string> achievementDescriptions;

// PETSCII art system: art titles and art blocks
extern std::vector<std::string> petsciiArtTitles;
extern std::vector<std::string> petsciiArtBlocks;
// Lore system: chapter titles and text blocks
#include <vector>
#include <string>
extern std::vector<std::string> loreChapterTitles;
extern std::vector<std::string> loreChapterTexts;

#pragma once
#include <string>
#include <vector>

// Map lines for Everland (12 lines)
extern const std::vector<std::string> everlandMap;

// Location names and descriptions
extern const std::vector<std::string> locationNames;
extern const std::vector<std::string> locationDescs;

// NPC talk lines by location
extern const std::vector<std::string> npcTalkByLoc;

// Conversation and quest strings (expanded)
extern const std::vector<std::string> convoStrings;
// Menu headers for NPCs and special menus
extern const std::vector<std::string> menuHeaders;
// Menu options for each menu (vector of vector)
extern const std::vector<std::vector<std::string>> menuOptions;
// NPC responses and quest text (vector of vector)
extern const std::vector<std::vector<std::string>> npcResponses;

// Object names and inspection strings
extern const std::vector<std::string> objectNames;
extern const std::vector<std::string> objectInspects;
// Trinket names
extern const std::vector<std::string> trinketNames;

// NPC display names
extern const std::vector<std::string> npcDisplayNames;
// Quest names and details
extern const std::vector<std::string> questNames;
extern const std::vector<std::string> questDetails;
