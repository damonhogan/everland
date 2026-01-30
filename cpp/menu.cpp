// Lore menu: browse and read lore chapters
void showLoreMenu() {
    while (true) {
        clearScreen();
        printZ("LORE ARCHIVE\n");
        for (size_t i = 0; i < loreChapterTitles.size(); ++i) {
            std::cout << i << ". " << loreChapterTitles[i] << std::endl;
        }
        std::cout << loreChapterTitles.size() << ". Return" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)loreChapterTitles.size()) {
            clearScreen();
            printZ(loreChapterTitles[choice] + "\n\n");
            printZ(loreChapterTexts[choice] + "\n");
            setCursorPrompt();
            readLine();
        } else if (choice == (int)loreChapterTitles.size()) {
            return;
        }
    }
}

// Achievements menu: browse achievements
void showAchievementsMenu() {
    while (true) {
        clearScreen();
        printZ("ACHIEVEMENTS\n");
        for (size_t i = 0; i < achievementNames.size(); ++i) {
            std::cout << i << ". " << achievementNames[i];
            if (i < achievementDescriptions.size())
                std::cout << " - " << achievementDescriptions[i];
            std::cout << std::endl;
        }
        std::cout << achievementNames.size() << ". Return" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice == (int)achievementNames.size()) {
            return;
        }
    }
}

// PETSCII art gallery menu
void showPetsciiArtMenu() {
    while (true) {
        clearScreen();
        printZ("PETSCII ART GALLERY\n");
        for (size_t i = 0; i < petsciiArtTitles.size(); ++i) {
            std::cout << i << ". " << petsciiArtTitles[i] << std::endl;
        }
        std::cout << petsciiArtTitles.size() << ". Return" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)petsciiArtTitles.size()) {
            clearScreen();
            printZ(petsciiArtTitles[choice] + "\n\n");
            printZ(petsciiArtBlocks[choice] + "\n");
            setCursorPrompt();
            readLine();
        } else if (choice == (int)petsciiArtTitles.size()) {
            return;
        }
    }
}

// Secrets/hidden content menu
void showSecretsMenu() {
    while (true) {
        clearScreen();
        printZ("SECRETS & HIDDEN CONTENT\n");
        for (size_t i = 0; i < secretNames.size(); ++i) {
            std::cout << i << ". " << secretNames[i];
            if (secretRevealed[i])
                std::cout << " (FOUND)";
            std::cout << std::endl;
        }
        std::cout << secretNames.size() << ". Return" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)secretNames.size()) {
            clearScreen();
            printZ(secretNames[choice] + "\n\n");
            printZ(secretHints[choice] + "\n");
            if (secretRevealed[choice])
                printZ("You have already discovered this secret!\n");
            setCursorPrompt();
            readLine();
        } else if (choice == (int)secretNames.size()) {
            return;
        }
    }
}

// Unified extras menu for all new features
void showExtrasMenu() {
    while (true) {
        clearScreen();
        printZ("EXTRAS\n");
        std::cout << "0. Lore Archive" << std::endl;
        std::cout << "1. Achievements" << std::endl;
        std::cout << "2. PETSCII Art Gallery" << std::endl;
        std::cout << "3. Secrets & Hidden Content" << std::endl;
        std::cout << "4. Return" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        switch (choice) {
            case 0: showLoreMenu(); break;
            case 1: showAchievementsMenu(); break;
            case 2: showPetsciiArtMenu(); break;
            case 3: showSecretsMenu(); break;
            case 4: return;
            default: break;
        }
    }
}

#include "menu.hpp"
#include "state.hpp"
#include "constants.hpp"
#include "data.hpp"
#include "trading.hpp"
#include "keywords.hpp"
#include "ui_strings.hpp"
#include <iostream>
#include <vector>
#include <string>

// Stub helpers (replace with real rendering/input as needed)
void clearScreen() { std::cout << "\x1B[2J\x1B[H"; }
void printZ(const std::string& s) { std::cout << s; }
void newline() { std::cout << std::endl; }
void setCursorPrompt() { std::cout << "> "; }
std::string readLine() { std::string s; std::getline(std::cin, s); return s; }

// TODO: Replace with actual NPC display name logic
void printNpcDisplayName(int npcIndex) {
    if (npcIndex >= 0 && npcIndex < (int)npcDisplayNames.size()) {
        std::cout << npcDisplayNames[npcIndex];
    } else {
        std::cout << "NPC" << npcIndex;
    }
}

// Returns indices of NPCs present at current location
std::vector<int> getPresentNpcs() {
    std::vector<int> npcs;
    // Example: Only show real, named NPCs for Central Plaza
    // Plaza NPCs: Kendrick (5), Banker (22), Kora (17), Warlock (8), Dorian (18), Trading Company Owner (20)
    // Add or adjust as needed for your story
    extern int playerLoc;
    int loc = 4; // Default to Plaza for demo
    // If you have a global playerLoc, use that
    // Otherwise, replace with actual location logic
    if (loc == 4) { // Central Plaza
        std::vector<int> plazaNpcs = {5, 22, 17, 8, 18, 20, 23}; // Add Oracle (23)
        for (int idx : plazaNpcs) {
            if (idx >= 0 && idx < (int)npcDisplayNames.size() && npcDisplayNames[idx] != "(UNKNOWN)")
                npcs.push_back(idx);
        }
    }
    // Add logic for other locations as needed
    return npcs;
}

void showCharacterMenu() {
    clearScreen();
    printZ("CHARACTERS\n");
    // Player
    std::cout << "0. Player";
    // Show player class, level, HP (stub/demo values, replace with real state)
    int playerClassIdx = 0; // TODO: Replace with actual player class index
    int playerLevel = 1;    // TODO: Replace with actual player level
    int playerHpBonus = 0;  // TODO: Replace with actual bonus
    if (playerClassIdx >= 0 && playerClassIdx < (int)playerClassNames.size())
        std::cout << " [" << playerClassNames[playerClassIdx] << "]";
    std::cout << " LV " << playerLevel;
    int playerMaxHp = computePlayerMaxHp(playerClassIdx, playerLevel, playerHpBonus, playerClassBaseHp, playerClassHpPerLevel);
    int playerCurHp = playerMaxHp; // TODO: Replace with actual current HP
    std::cout << " HP " << playerCurHp << "/" << playerMaxHp;
    // Demo: show trinket and quest icons
    std::vector<int> playerTrinkets = {0, 1}; // TODO: Replace with real trinket state
    std::vector<int> playerQuests = {0, 1};   // TODO: Replace with real quest state
    if (!playerTrinkets.empty()) std::cout << " *"; // * = has trinkets
    if (!playerQuests.empty()) std::cout << " !";   // ! = has active quest
    std::cout << std::endl;
    // NPCs
    auto npcs = getPresentNpcs();
    int sel = 1;
    // Romance system: demo romance scores for each NPC
    static std::vector<int> romanceScores(32, 0); // 32 NPCs, all start at 0
    for (int npc : npcs) {
        std::cout << sel << ". ";
        printNpcDisplayName(npc);
        // Show class
        if (npc >= 0 && npc < (int)npcClassIdx.size()) {
            int classIdx = npcClassIdx[npc];
            if (classIdx >= 0 && classIdx < (int)npcClassNames.size())
                std::cout << " [" << npcClassNames[classIdx] << "]";
        }
        // Show level
        if (npc >= 0 && npc < (int)npcLevel.size())
            std::cout << " LV " << npcLevel[npc];
        // Show HP
        if (npc >= 0 && npc < (int)npcCurHp.size()) {
            int curHp = npcCurHp[npc];
            int maxHp = computeNpcMaxHp(npc);
            std::cout << " HP " << curHp << "/" << maxHp;
        }
        // Demo: show trinket and quest icons for NPCs
        std::vector<int> npcTrinkets = {0}; // TODO: Replace with real trinket state per NPC
        std::vector<int> npcQuests = {};    // TODO: Replace with real quest state per NPC
        if (!npcTrinkets.empty()) std::cout << " *";
        if (!npcQuests.empty()) std::cout << " !";
        // Show romance heart if romance score is high
        if (npc < (int)romanceScores.size() && romanceScores[npc] >= 3) std::cout << " c"; // ♥
        std::cout << std::endl;
        ++sel;
    }
    setCursorPrompt();
    std::string input = readLine();
    // TODO: Handle selection and show sheets
}

void showTalkMenu() {
    clearScreen();
    printZ("TALK TO:\n");
    auto npcs = getPresentNpcs();
    int sel = 0;
    for (int npc : npcs) {
        std::cout << sel << ". ";
        printNpcDisplayName(npc);
        std::cout << std::endl;
        ++sel;
    }
    setCursorPrompt();
    std::string input = readLine();
    // TODO: Handle selection and start conversation
}

void showNpcSheet(int npcIndex) {
    clearScreen();
    printZ(strSheetTitle + "\n");
    printZ(strName); printNpcDisplayName(npcIndex); newline();
    // Show class
    printZ(strClass);
    if (npcIndex >= 0 && npcIndex < (int)npcClassIdx.size()) {
        int classIdx = npcClassIdx[npcIndex];
        if (classIdx >= 0 && classIdx < (int)npcClassNames.size())
            printZ(npcClassNames[classIdx]);
        else
            printZ(strNoData);
    } else {
        printZ(strNoData);
    }
    newline();
    // Show level
    printZ(strLevel);
    if (npcIndex >= 0 && npcIndex < (int)npcLevel.size())
        std::cout << npcLevel[npcIndex];
    else
        printZ(strNoData);
    newline();
    // Show HP
    printZ(strHP);
    std::cout << computeNpcMaxHp(npcIndex);
    newline();
    setCursorPrompt();
    readLine();
}

void showPlayerSheet() {
    clearScreen();
    printZ(strSheetTitle + "\n");
    printZ(strName + "Player"); newline();
    // Show class
    printZ(strClass);
    // TODO: Replace with actual player class index
    int playerClassIdx = 0;
    if (playerClassIdx >= 0 && playerClassIdx < (int)playerClassNames.size())
        printZ(playerClassNames[playerClassIdx]);
    else
        printZ(strNoData);
    newline();
    // Show level
    printZ(strLevel);
    int playerLevel = 1; // TODO: Replace with actual player level
    std::cout << playerLevel;
    newline();
    // Show HP
    printZ(strHP);
    int playerHpBonus = 0; // TODO: Replace with actual bonus
    std::cout << computePlayerMaxHp(playerClassIdx, playerLevel, playerHpBonus, playerClassBaseHp, playerClassHpPerLevel);
    newline();
    setCursorPrompt();
    readLine();
}

// Stub: per-NPC conversation handlers
void unseelyConversation(int npcIndex) {
    clearScreen();
    printZ("Unseely Fae Conversation\n");
    // TODO: Implement full menu/options per assembly logic
    setCursorPrompt();
    readLine();
}
void apolloniaConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ("Apollonia Conversation\n");
        std::cout << "0. Martyrs' Blessing" << std::endl;
        std::cout << "1. Teeth" << std::endl;
        std::cout << "2. Fire" << std::endl;
        std::cout << "3. Offer item" << std::endl;
        std::cout << "4. Leave" << std::endl;
        std::cout << "5. Fight" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        switch (choice) {
            case 0:
                printZ("[Martyrs' Blessing effect]\n");
                break;
            case 1:
                printZ("[Teeth effect]\n");
                break;
            case 2:
                printZ("[Fire effect]\n");
                break;
            case 3:
                printZ("[Offer item effect]\n");
                break;
            case 4:
                return;
            case 5:
                printZ("[Fight Apollonia]\n");
                return;
            default:
                break;
        }
        setCursorPrompt();
        readLine();
    }
}

void alysterConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ("Alyster Conversation\n");
        std::cout << "0. Basics" << std::endl;
        std::cout << "1. Care" << std::endl;
        std::cout << "2. Practice" << std::endl;
        std::cout << "3. Advanced" << std::endl;
        std::cout << "4. Leave" << std::endl;
        std::cout << "5. Fight" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        switch (choice) {
            case 0:
                printZ("[Basics effect]\n");
                break;
            case 1:
                printZ("[Care effect]\n");
                break;
            case 2:
                printZ("[Practice effect]\n");
                break;
            case 3:
                printZ("[Advanced effect]\n");
                break;
            case 4:
                return;
            case 5:
                printZ("[Fight Alyster]\n");
                return;
            default:
                break;
        }
        setCursorPrompt();
        readLine();
    }
}

void trollConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[0] + "\n");
        const auto& opts = menuOptions[0];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            if ((int)npcIndex < (int)npcResponses.size() && choice < (int)npcResponses[npcIndex].size()) {
                printZ(npcResponses[npcIndex][choice] + "\n");
            } else {
                printZ("[" + opts[choice] + " effect]\n");
            }
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void toshConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[1] + "\n");
        const auto& opts = menuOptions[1];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void loudenConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[2] + "\n");
        const auto& opts = menuOptions[2];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void mermaidConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[3] + "\n");
        const auto& opts = menuOptions[3];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void spiderConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[11] + "\n");
        const auto& opts = menuOptions[11];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void pirateConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[4] + "\n");
        const auto& opts = menuOptions[4];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void bartenderConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[5] + "\n");
        const auto& opts = menuOptions[5];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void bankerConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[13] + "\n");
        const auto& opts = menuOptions[13];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

// Banker submenus (stubs)
void bankerDepositMenu() {
    while (true) {
        clearScreen();
        printZ("Deposit Menu\n");
        std::cout << "0. Copper" << std::endl;
        std::cout << "1. Silver" << std::endl;
        std::cout << "2. Gold" << std::endl;
        std::cout << "3. Back" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        switch (choice) {
            case 0:
                printZ("[Deposit Copper effect]\n");
                break;
            case 1:
                printZ("[Deposit Silver effect]\n");
                break;
            case 2:
                printZ("[Deposit Gold effect]\n");
                break;
            case 3:
                return;
            default:
                break;
        }
        setCursorPrompt();
        readLine();
    }
}

void bankerWithdrawMenu() {
    while (true) {
        clearScreen();
        printZ("Withdraw Menu\n");
        std::cout << "0. Copper" << std::endl;
        std::cout << "1. Silver" << std::endl;
        std::cout << "2. Gold" << std::endl;
        std::cout << "3. Back" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        switch (choice) {
            case 0:
                printZ("[Withdraw Copper effect]\n");
                break;
            case 1:
                printZ("[Withdraw Silver effect]\n");
                break;
            case 2:
                printZ("[Withdraw Gold effect]\n");
                break;
            case 3:
                return;
            default:
                break;
        }
        setCursorPrompt();
        readLine();
    }
}

void bankerBalanceMenu() {
    clearScreen();
    printZ("Balance Menu\n");
    printZ("[Show copper, silver, gold balances]\n");
    setCursorPrompt();
    readLine();
}

void bankerVaultMenu() {
    while (true) {
        clearScreen();
        printZ("Vault Menu\n");
        std::cout << "0. Store Item" << std::endl;
        std::cout << "1. Retrieve Item" << std::endl;
        std::cout << "2. Back" << std::endl;
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        switch (choice) {
            case 0:
                printZ("[Store Item effect]\n");
                break;
            case 1:
                printZ("[Retrieve Item effect]\n");
                break;
            case 2:
                return;
            default:
                break;
        }
        setCursorPrompt();
        readLine();
    }
}

void conversationMenu(int npcIndex) {
    while (true) {
        clearScreen();
        printZ("CONVERSATION WITH ");
        printNpcDisplayName(npcIndex);
        newline();
        std::cout << "0. Speak" << std::endl;
        std::cout << "1. Ask about weather" << std::endl;
        std::cout << "2. Comment on temperature" << std::endl;
        std::cout << "3. Any quests?" << std::endl;
        std::cout << "4. Quest info" << std::endl;
        std::cout << "5. End conversation" << std::endl;
        // TODO: Add trinket trade if available
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        switch (choice) {
            case 0:
                // TODO: Dispatch to per-NPC speak handler
                printZ("[Speak option selected]\n");
                break;
            case 1:
                printZ("[Ask about weather]\n");
                break;
            case 2:
                printZ("[Comment on temperature]\n");
                break;
            case 3:
                printZ("[Any quests?]\n");
                break;
            case 4:
                printZ("[Quest info]\n");
                break;
            case 5:
                return;
            case 6:
                printZ("[Trade trinkets]\n");
                break;
            default:
                break;
        }
        setCursorPrompt();
        readLine();
    }
}

void conductorConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[6] + "\n");
        const auto& opts = menuOptions[6];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void knightConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[7] + "\n");
        const auto& opts = menuOptions[7];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void kendrickConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[8] + "\n");
        const auto& opts = menuOptions[8];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void fairyConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[9] + "\n");
        const auto& opts = menuOptions[9];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void pixieConversation(int npcIndex) {
    while (true) {
        clearScreen();
        printZ(menuHeaders[10] + "\n");
        const auto& opts = menuOptions[10];
        for (size_t i = 0; i < opts.size(); ++i) {
            std::cout << i << ". " << opts[i] << std::endl;
        }
        setCursorPrompt();
        std::string input = readLine();
        if (input.empty()) continue;
        int choice = input[0] - '0';
        if (choice >= 0 && choice < (int)opts.size()) {
            printZ("[" + opts[choice] + " effect]\n");
        } else if (choice == (int)opts.size()) {
            return;
        }
        setCursorPrompt();
        readLine();
    }
}

void showQuestLog(const std::vector<int>& activeQuests) {
    clearScreen();
    printZ("QUEST LOG\n");
    for (int qid : activeQuests) {
        if (qid >= 0 && qid < (int)questNames.size()) {
            printZ(questNames[qid]);
            newline();
            if (qid < (int)questDetails.size()) {
                printZ(questDetails[qid]);
                newline();
            }
        }
    }
    setCursorPrompt();
    readLine();
}

void showQuestDetails(int questId) {
    clearScreen();
    if (questId >= 0 && questId < (int)questNames.size()) {
        printZ(questNames[questId]);
        newline();
        if (questId < (int)questDetails.size()) {
            printZ(questDetails[questId]);
            newline();
        }
    } else {
        printZ(strNoData);
        newline();
    }
    setCursorPrompt();
    readLine();
}

void showInventory(const std::vector<int>& inventory) {
    clearScreen();
    printZ(strInventory + "\n");
    if (inventory.empty()) {
        printZ(strEmpty);
        newline();
    } else {
        for (int obj : inventory) {
            if (obj >= 0 && obj < (int)objectNames.size()) {
                printZ(objectNames[obj]);
                newline();
            }
        }
    }
    setCursorPrompt();
    readLine();
}
