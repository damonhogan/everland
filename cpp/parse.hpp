#pragma once
#include <string>

// Command parsing and execution logic for Everland

// Parses a command string and returns the command type/enum
int parseCommand(const std::string& input);

// Attempts to match a keyword at a given position in the input string
// Returns true if matches whole word (ends at space or 0)
bool matchKeywordAt(const std::string& input, size_t pos, const std::string& keyword);

// Skips spaces in the input string starting at pos, returns new pos
size_t skipSpaces(const std::string& input, size_t pos);

// Skips spaces and filler words (TO/THE/A/AN) starting at pos, returns new pos
size_t skipFillers(const std::string& input, size_t pos);

// Parses an object noun from input starting at pos, returns object id or -1 if not found
int parseObjectNoun(const std::string& input, size_t& pos);

// Parses an NPC noun from input starting at pos, returns npc id or -1 if not found
int parseNpcNoun(const std::string& input, size_t& pos);
