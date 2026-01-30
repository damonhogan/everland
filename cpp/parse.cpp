#include "parse.hpp"
#include "constants.hpp"
#include <cctype>
#include <string>
#include <vector>
#include <algorithm>

// Helper: match keyword at position (case-insensitive, must match whole word)
bool matchKeywordAt(const std::string& input, size_t pos, const std::string& keyword) {
    size_t k = 0;
    while (k < keyword.size()) {
        if (pos + k >= input.size()) return false;
        char a = std::toupper(input[pos + k]);
        char b = std::toupper(keyword[k]);
        if (a != b) return false;
        ++k;
    }
    // Must end at space or end of string
    if (pos + k == input.size() || input[pos + k] == ' ') return true;
    return false;
}

size_t skipSpaces(const std::string& input, size_t pos) {
    while (pos < input.size() && input[pos] == ' ') ++pos;
    return pos;
}

size_t skipFillers(const std::string& input, size_t pos) {
    static const std::vector<std::string> fillers = {"TO", "THE", "A", "AN"};
    while (true) {
        pos = skipSpaces(input, pos);
        bool found = false;
        for (const auto& f : fillers) {
            if (matchKeywordAt(input, pos, f)) {
                pos += f.size();
                found = true;
                break;
            }
        }
        if (!found) break;
    }
    return pos;
}

// Example object keyword table (expand as needed)
static const std::vector<std::pair<std::string, int>> objectKeywords = {
    {"LANTERN", OBJ_LANTERN},
    {"COIN", OBJ_COIN},
    {"MUG", OBJ_MUG},
    {"SCOTCH", OBJ_SCOTCH},
    {"BOTTLE", OBJ_SCOTCH},
    {"WARD", OBJ_WARD},
    {"PROTECTION", OBJ_WARD},
    {"KEY", OBJ_KEY},
    {"HEART", OBJ_HEART},
    {"PINECONE", OBJ_PINECONE},
    {"SHELL", OBJ_SHELL},
};

int parseObjectNoun(const std::string& input, size_t& pos) {
    pos = skipFillers(input, pos);
    for (const auto& [kw, id] : objectKeywords) {
        if (matchKeywordAt(input, pos, kw)) {
            pos += kw.size();
            return id;
        }
    }
    return -1;
}

// Example NPC keyword table (expand as needed)
static const std::vector<std::pair<std::string, int>> npcKeywords = {
    {"CONDUCTOR", NPC_CONDUCTOR},
    {"BARTENDER", NPC_BARTENDER},
    {"KNIGHT", NPC_KNIGHT},
    {"MYSTIC", NPC_MYSTIC},
    {"FAIRY", NPC_FAIRY},
    {"PIXIE", NPC_PIXIE},
    {"APOLLONIA", NPC_APOLLONIA},
    {"STATUE", NPC_APOLLONIA},
    {"ALYSTER", NPC_ALYSTER},
    {"DRAGONTRAINER", NPC_ALYSTER},
    {"TROLL", NPC_TROLL},
    {"BRIDGE", NPC_TROLL},
    {"TOSH", NPC_TOSH},
    {"TOSHER", NPC_TOSH},
};

int parseNpcNoun(const std::string& input, size_t& pos) {
    pos = skipFillers(input, pos);
    for (const auto& [kw, id] : npcKeywords) {
        if (matchKeywordAt(input, pos, kw)) {
            pos += kw.size();
            return id;
        }
    }
    return -1;
}

// TODO: Implement parseCommand for full command parsing
int parseCommand(const std::string& input) {
    // Stub: implement full command parsing logic
    return 0;
}
