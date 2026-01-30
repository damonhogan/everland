// io.hpp
// Input parsing and save/load filename logic for Everland C++ port
#pragma once
#include <string>
#include <array>
#include "constants.hpp"

uint16_t parsePinFromInput(const std::string& input);
uint8_t parseMonthFromInput(const std::string& input);
uint8_t parseWeekFromInput(const std::string& input);
uint8_t parseSmallNumber(const std::string& input);
std::string buildSaveNameBase(const std::string& username);
std::string buildSaveNameWithMode(const std::string& base, char mode);
