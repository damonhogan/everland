// render.cpp
#include "render.hpp"
#include <iostream>

void clearScreen() {
    std::cout << "\x1B[2J\x1B[H"; // ANSI clear screen
}

void render() {
    clearScreen();
    // Stub: render login/game UI
    std::cout << "[Everland Rendered Screen]" << std::endl;
}

void render_game() {
    // Stub: render main game UI
}

void renderAuthTag() {
    // Stub: render auth tag line
}
