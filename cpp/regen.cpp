// regen.cpp
#include "regen.hpp"
#include <ctime>
#include <iostream>

static std::time_t lastRegen = 0;

void initRegenTimer() {
    lastRegen = std::time(nullptr);
}

void applyRegenIfDue() {
    std::time_t now = std::time(nullptr);
    int minutes = static_cast<int>(difftime(now, lastRegen) / 60);
    if (minutes > 0) {
        // Heal 1 HP per minute, up to max (stub: max HP logic not implemented)
        // player.curHp = std::min(player.curHp + minutes, player.maxHp);
        lastRegen = now;
        std::cout << "[Regen] Healed for " << minutes << " minute(s)." << std::endl;
    }
}
