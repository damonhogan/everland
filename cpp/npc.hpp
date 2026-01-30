// npc.hpp
// NPC and conversation logic for Everland C++ port
#pragma once
#include <cstdint>
#include <string>

void printNpcEntry(int idx);
void printNpcDisplayName(int idx);
void conv_apply_effect(uint8_t effectType, uint8_t value);
