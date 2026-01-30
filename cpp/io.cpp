// io.cpp
#include "io.hpp"
#include <sstream>
#include <iomanip>
#include "parse.hpp"

uint16_t parsePinFromInput(const std::string& input) {
    uint16_t pin = 0;
    for (char c : input) {
        if (c >= '0' && c <= '9')
            pin = pin * 10 + (c - '0');
    }
    return pin;
}

uint8_t parseMonthFromInput(const std::string& input) {
    int m = parseSmallNumber(input);
    if (m < 1 || m > 12) return 4;
    return static_cast<uint8_t>(m);
}

uint8_t parseWeekFromInput(const std::string& input) {
    int w = parseSmallNumber(input);
    if (w < 1 || w > 52) return 14;
    return static_cast<uint8_t>(w);
}

uint8_t parseSmallNumber(const std::string& input) {
    int val = 0;
    for (char c : input) {
        if (c >= '0' && c <= '9')
            val = val * 10 + (c - '0');
    }
    return static_cast<uint8_t>(val);
}

std::string buildSaveNameBase(const std::string& username) {
    return "EV" + username.substr(0, 12);
}

std::string buildSaveNameWithMode(const std::string& base, char mode) {
    return base + ",S," + mode;
}

// TODO: Use skipSpaces, skipFillers, etc. in input routines as needed.
