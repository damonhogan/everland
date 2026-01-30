// profile.cpp
#include "profile.hpp"
#include <algorithm>

ProfileBuffer loadedProfile;

void copyInputToUsername(const std::string& input) {
    player.raceName[0] = '\0'; // stub: real logic would copy to player.username
    loadedProfile.username = input.substr(0, 12);
}

void copyInputToDisplay(const std::string& input) {
    loadedProfile.displayName = input.substr(0, 16);
}

void copyInputToClass(const std::string& input) {
    loadedProfile.className = input.substr(0, 12);
}

void copyInputToRace(const std::string& input) {
    loadedProfile.raceName = input.substr(0, 12);
}

void mapPlayerClass() {
    if (loadedProfile.className.empty()) { player.playerClassIdx = 0; return; }
    char c = toupper(loadedProfile.className[0]);
    if (c == 'M') player.playerClassIdx = 0;
    else if (c == 'K') player.playerClassIdx = 1;
    else if (c == 'H') player.playerClassIdx = 2;
    else if (c == 'B') player.playerClassIdx = 3;
    else if (c == 'W') player.playerClassIdx = 4;
    else player.playerClassIdx = 0;
}

void mapPlayerRace() {
    if (loadedProfile.raceName.empty()) { player.playerRaceIdx = 0; return; }
    char c = toupper(loadedProfile.raceName[0]);
    if (c == 'H') player.playerRaceIdx = 0;
    else if (c == 'T') player.playerRaceIdx = 1;
    else if (c == 'E') player.playerRaceIdx = 2;
    else if (c == 'D') player.playerRaceIdx = 3;
    else player.playerRaceIdx = 0;
}

void commitLoadedState() {
    // Copy loadedProfile fields to player/game
    // ... (stub: implement full field copy as needed)
}
