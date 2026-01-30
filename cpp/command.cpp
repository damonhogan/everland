else if (cmd.find("WAVE") == 0) {
        size_t pos = cmd.find("WAVE");
        pos += 4;
        pos = skipSpaces(cmd, pos);
        if (pos < cmd.size()) {
            int npc = parseNpcNoun(cmd, pos);
            if (npc >= 0) {
                if (npcDisplayNames[npc] == "SPIDER PRINCESS") {
                    std::cout << "You wave to the Spider Princess. She waves back with several hands, her silks fluttering." << std::endl;
                } else if (npcDisplayNames[npc] == "KNIGHT KENDRICK") {
                    std::cout << "You wave to Kendrick. He grins and salutes you with his mug." << std::endl;
                } else if (npcDisplayNames[npc] == "BANKER") {
                    std::cout << "You wave to Bert the Banker. He nods politely and checks his ledger." << std::endl;
                } else {
                    std::cout << "You wave to " << npcDisplayNames[npc] << "." << std::endl;
                }
            } else {
                std::cout << "Wave to whom?" << std::endl;
            }
        } else {
            std::cout << "Wave to whom?" << std::endl;
        }
    }
    else if (cmd.find("BOW") == 0) {
        size_t pos = cmd.find("BOW");
        pos += 3;
        pos = skipSpaces(cmd, pos);
        if (pos < cmd.size()) {
            int npc = parseNpcNoun(cmd, pos);
            if (npc >= 0) {
                if (npcDisplayNames[npc] == "SPIDER PRINCESS") {
                    std::cout << "You bow to the Spider Princess. She bows in return, her movements graceful and regal." << std::endl;
                } else if (npcDisplayNames[npc] == "KNIGHT KENDRICK") {
                    std::cout << "You bow to Kendrick. He laughs: 'No need for formality among friends!'" << std::endl;
                } else if (npcDisplayNames[npc] == "BANKER") {
                    std::cout << "You bow to Bert the Banker. He bows back, then offers you a pamphlet on compound interest." << std::endl;
                } else {
                    std::cout << "You bow to " << npcDisplayNames[npc] << "." << std::endl;
                }
            } else {
                std::cout << "Bow to whom?" << std::endl;
            }
        } else {
            std::cout << "Bow to whom?" << std::endl;
        }
    }
    else if (cmd.find("THANK") == 0) {
        size_t pos = cmd.find("THANK");
        pos += 5;
        pos = skipSpaces(cmd, pos);
        if (pos < cmd.size()) {
            int npc = parseNpcNoun(cmd, pos);
            if (npc >= 0) {
                if (npcDisplayNames[npc] == "ORACLE") {
                    std::cout << "You thank the Oracle. 'Your gratitude is my greatest reward. Keep dreaming, creator.'" << std::endl;
                } else if (npcDisplayNames[npc] == "SPIDER PRINCESS") {
                    std::cout << "You thank the Spider Princess. She smiles, her fangs glinting: 'Kindness is a rare gift.'" << std::endl;
                } else if (npcDisplayNames[npc] == "KNIGHT KENDRICK") {
                    std::cout << "You thank Kendrick. He claps you on the back: 'Anytime, friend!'" << std::endl;
                } else if (npcDisplayNames[npc] == "BANKER") {
                    std::cout << "You thank Bert the Banker. He beams: 'Your business is always appreciated!'" << std::endl;
                } else {
                    std::cout << "You thank " << npcDisplayNames[npc] << "." << std::endl;
                }
            } else {
                std::cout << "Thank whom?" << std::endl;
            }
        } else {
            std::cout << "Thank whom?" << std::endl;
        }
    }
    else if (cmd.find("FIGHT") == 0) {
        // Parse NPC if present
        size_t pos = cmd.find("FIGHT");
        pos += 5;
        pos = skipSpaces(cmd, pos);
        if (pos < cmd.size()) {
            int npc = parseNpcNoun(cmd, pos);
            if (npc >= 0) {
                startCombatWithNpc(npc);
            } else {
                std::cout << "Fight whom?\n";
            }
        } else {
            std::cout << "Fight whom?\n";
        }
    }
    // Save/Load/Wait
    else if (cmd == "SAVE") {
        handleSave(input);
    } else if (cmd == "LOAD") {
        handleLoad(input);
    } else if (cmd == "WAIT" || cmd == "REST" || cmd == "NEXT") {
        handleWait(input);
    }
    // Music
    else if (cmd == "MUSIC" || cmd == "M") {
        handleMusicToggle(input);
    }
    // Help
    else if (cmd == "HELP" || cmd == "H") {
        std::cout << "\n--- Everland Commands ---\n";
        std::cout << "Movement: N,S,E,W,NE,NW,SE,SW\n";
        std::cout << "Menus: CHARACTERS, INVENTORY, TRINKETS, QUEST, STATUS\n";
        std::cout << "Actions: INSPECT <item>, TAKE <item>, DROP <item>, GIVE <item>\n";
        std::cout << "NPCs: TALK [NPC], FIGHT [NPC]\n";
        std::cout << "Game: SAVE, LOAD, WAIT, MUSIC, HELP, QUIT\n";
        std::cout << "-------------------------\n";
    }
    // Unknown
    else {
        std::cout << "Sorry, I didn't understand that command. Type HELP for a list of commands.\n";
    }
}

// Command handler stubs (to be expanded)
// Forward declaration for object names/inspects
extern const std::vector<std::string> objectNames;
extern const std::vector<std::string> objectInspects;
#include "parse.hpp"

void handleInspect(const std::string& input) {
    size_t pos = input.find(' ');
    if (pos == std::string::npos) {
        std::cout << "Inspect what?\n";
        return;
    }
    ++pos;
    int obj = parseObjectNoun(input, pos);
    if (obj >= 0 && obj < (int)objectNames.size()) {
        std::cout << objectNames[obj] << ": " << objectInspects[obj] << "\n";
    } else {
        std::cout << "You see nothing special." << std::endl;
    }
}

void handleTake(const std::string& input) {
    size_t pos = input.find(' ');
    if (pos == std::string::npos) {
        std::cout << "Take what?\n";
        return;
    }
    ++pos;
    int obj = parseObjectNoun(input, pos);
    if (obj >= 0 && obj < (int)objectNames.size()) {
        // Demo: add to inventory if not present
        if (std::find(demoInventory.begin(), demoInventory.end(), obj) == demoInventory.end()) {
            demoInventory.push_back(obj);
            std::cout << "You take the " << objectNames[obj] << ".\n";
        } else {
            std::cout << "You already have the " << objectNames[obj] << ".\n";
        }
    } else {
        std::cout << "You can't take that." << std::endl;
    }
}

void handlePickUp(const std::string& input) {
    // TODO: Handle 'pick up' as alias for take
    handleTake(input);
}

void handleDrop(const std::string& input) {
    size_t pos = input.find(' ');
    if (pos == std::string::npos) {
        std::cout << "Drop what?\n";
        return;
    }
    ++pos;
    int obj = parseObjectNoun(input, pos);
    auto it = std::find(demoInventory.begin(), demoInventory.end(), obj);
    if (it != demoInventory.end()) {
        demoInventory.erase(it);
        std::cout << "You drop the " << objectNames[obj] << ".\n";
    } else {
        std::cout << "You don't have that." << std::endl;
    }
}

void handleSetDown(const std::string& input) {
    // TODO: Handle 'set down' as alias for drop
    handleDrop(input);
}

void handleGive(const std::string& input) {
    size_t pos = input.find(' ');
    if (pos == std::string::npos) {
        std::cout << "Give what?\n";
        return;
    }
    ++pos;
    int obj = parseObjectNoun(input, pos);
    auto it = std::find(demoInventory.begin(), demoInventory.end(), obj);
    if (it != demoInventory.end()) {
        demoInventory.erase(it);
        std::cout << "You give the " << objectNames[obj] << ".\n";
    } else {
        std::cout << "You don't have that." << std::endl;
    }
}

void handleSave(const std::string& input) {
    // Stub: Use username 'PLAYER' for save name
    std::string base = buildSaveNameBase("PLAYER");
    std::string filename = buildSaveNameWithMode(base, 'S');
    // TODO: Serialize player/game state to file
    std::cout << "Game saved to " << filename << "\n";
}

void handleLoad(const std::string& input) {
    // Stub: Use username 'PLAYER' for save name
    std::string base = buildSaveNameBase("PLAYER");
    std::string filename = buildSaveNameWithMode(base, 'S');
    // TODO: Deserialize player/game state from file
    std::cout << "Game loaded from " << filename << "\n";
}

void handleWait(const std::string& input) {
    // TODO: Advance week, update music, ensure quest
    std::cout << "[Wait command executed]\n";
}

void handleMusicToggle(const std::string& input) {
    // TODO: Toggle music on/off, initialize if needed
    std::cout << "[Music toggled]\n";
}

void handleStatus(const std::string& input) {
    // TODO: Show quest detail
    std::cout << "[Status command executed]\n";
}

void handleChart(const std::string& input) {
    // TODO: Show PETSCII chart
    std::cout << "[Chart command executed]\n";
}

void handleHelp(const std::string& input) {
    // TODO: Show help message
    std::cout << "[Help command executed]\n";
}

void handleInventory(const std::string& input) {
    // TODO: Show inventory, coins, trinkets
    std::cout << "[Inventory command executed]\n";
}

void startCombatWithNpc(int npcIndex) {
    extern int playerHp, playerLevel, playerClassIdx;
    extern std::vector<int> npcCurHp, npcLevel, npcClassIdx;
    extern std::vector<std::string> npcDisplayNames;
    extern std::vector<int> baseHp, hpPerLevel;
    
    int npcHp = npcCurHp[npcIndex];
    int npcMaxHp = baseHp[npcClassIdx[npcIndex]] + npcLevel[npcIndex] * hpPerLevel[npcClassIdx[npcIndex]];
    int playerMaxHp = baseHp[playerClassIdx] + playerLevel * hpPerLevel[playerClassIdx];
    bool defending = false;
    std::map<std::string, int> statusTurns; // "player:STUNNED", "npc:POISONED", etc.
    std::deque<std::string> combatLog;
    auto log = [&](const std::string& msg) {
        combatLog.push_back(msg);
        if (combatLog.size() > 10) combatLog.pop_front();
    };
    std::cout << "\n[Combat started with " << npcDisplayNames[npcIndex] << "]\n";
    while (playerHp > 0 && npcHp > 0) {
        // Show status effects
        if (statusTurns["player:STUNNED"] > 0) std::cout << "You are stunned!\n";
        if (statusTurns["player:POISONED"] > 0) std::cout << "You are poisoned!\n";
        if (statusTurns["npc:STUNNED"] > 0) std::cout << npcDisplayNames[npcIndex] << " is stunned!\n";
        if (statusTurns["npc:POISONED"] > 0) std::cout << npcDisplayNames[npcIndex] << " is poisoned!\n";
        // Apply poison/regen
        if (statusTurns["player:POISONED"] > 0) { playerHp -= 1; std::cout << "Poison deals 1 damage to you!\n"; }
        if (statusTurns["player:REGEN"] > 0) { playerHp += 1; if (playerHp > playerMaxHp) playerHp = playerMaxHp; std::cout << "You regenerate 1 HP!\n"; }
        if (statusTurns["npc:POISONED"] > 0) { npcHp -= 1; std::cout << "Poison deals 1 damage to " << npcDisplayNames[npcIndex] << "!\n"; }
        if (statusTurns["npc:REGEN"] > 0) { npcHp += 1; if (npcHp > npcMaxHp) npcHp = npcMaxHp; std::cout << npcDisplayNames[npcIndex] << " regenerates 1 HP!\n"; }
        // Decrement status durations
        for (auto& kv : statusTurns) if (kv.second > 0) kv.second--;
        if (playerHp <= 0 || npcHp <= 0) break;
        // Player's turn
        if (statusTurns["player:STUNNED"] > 0) {
            std::cout << "You are stunned and lose your turn!\n";
            log("You are stunned and lose your turn!");
        } else {
            std::cout << "\nChoose your action: 1) Attack  2) Power Attack  3) Defend  4) Heal  5) Stun  6) Poison  7) Regen  8) Log\n> ";
            int choice = 1;
            std::string input;
            std::getline(std::cin, input);
            if (!input.empty()) choice = std::stoi(input);
            if (choice == 8) {
                std::cout << "\n--- Combat Log ---\n";
                for (const auto& entry : combatLog) std::cout << entry << "\n";
                continue;
            }
            int playerDmg = 0;
            bool crit = false, miss = false;
            switch (choice) {
                case 2:
                    if ((rand() % 5) == 0) { crit = true; playerDmg = 6; }
                    else if ((rand() % 5) == 0) { miss = true; playerDmg = 0; }
                    else playerDmg = 2 + (rand() % 4);
                    if (crit) { std::string msg = randomFlavor(critFlavors) + " You use Power Attack for 6 damage!"; std::cout << msg << "\n"; log(msg); }
                    if (miss) { std::string msg = randomFlavor(missFlavors) + " You miss with Power Attack!"; std::cout << msg << "\n"; log(msg); }
                    if (!crit && !miss) { std::string msg = "You use Power Attack for " + std::to_string(playerDmg) + " damage!"; std::cout << msg << "\n"; log(msg); }
                    break;
                case 3:
                    defending = true;
                    std::cout << "You brace for the next attack!\n";
                    log("You brace for the next attack!");
                    break;
                case 4:
                    {
                        int heal = 2 + (rand() % 3);
                        playerHp += heal;
                        if (playerHp > playerMaxHp) playerHp = playerMaxHp;
                        std::string msg = "You heal yourself for " + std::to_string(heal) + " HP! (" + std::to_string(playerHp) + "/" + std::to_string(playerMaxHp) + ")";
                        std::cout << msg << "\n";
                        log(msg);
                    }
                    break;
                case 5:
                    statusTurns["npc:STUNNED"] = 1 + (rand() % 2);
                    std::string msg = "You attempt to stun! " + npcDisplayNames[npcIndex] + " is stunned!";
                    std::cout << msg << "\n";
                    log(msg);
                    break;
                case 6:
                    statusTurns["npc:POISONED"] = 3;
                    msg = "You poison " + npcDisplayNames[npcIndex] + "!";
                    std::cout << msg << "\n";
                    log(msg);
                    break;
                case 7:
                    statusTurns["player:REGEN"] = 3;
                    std::cout << "You cast regeneration on yourself!\n";
                    log("You cast regeneration on yourself!");
                    break;
                default:
                    if ((rand() % 6) == 0) { crit = true; playerDmg = 5; }
                    else if ((rand() % 6) == 0) { miss = true; playerDmg = 0; }
                    else playerDmg = 1 + (rand() % 3);
                    if (crit) { std::string msg = randomFlavor(critFlavors) + " You attack for 5 damage!"; std::cout << msg << "\n"; log(msg); }
                    if (miss) { std::string msg = randomFlavor(missFlavors) + " You miss!"; std::cout << msg << "\n"; log(msg); }
                    if (!crit && !miss) { std::string msg = "You attack for " + std::to_string(playerDmg) + " damage!"; std::cout << msg << "\n"; log(msg); }
                    break;
            }
            if (playerDmg > 0) {
                npcHp -= playerDmg;
                if (npcHp <= 0) {
                    std::string msg = "You defeated " + npcDisplayNames[npcIndex] + "!";
                    std::cout << msg << "\n";
                    log(msg);
                    npcCurHp[npcIndex] = 0;
                    break;
                } else {
                    std::string msg = npcDisplayNames[npcIndex] + " HP: " + std::to_string(npcHp) + "/" + std::to_string(npcMaxHp);
                    std::cout << msg << "\n";
                    log(msg);
                }
            } else if (miss) {
                // Already printed miss flavor
            }
        }
        // NPC's turn
        if (npcHp > 0) {
            if (statusTurns["npc:STUNNED"] > 0) {
                std::string msg = npcDisplayNames[npcIndex] + " is stunned and loses their turn!";
                std::cout << msg << "\n";
                log(msg);
            } else {
                int npcDmg = 1 + (rand() % 2);
                bool npcCrit = false, npcMiss = false;
                if ((rand() % 8) == 0) { npcCrit = true; npcDmg = 4; }
                else if ((rand() % 8) == 0) { npcMiss = true; npcDmg = 0; }
                if (defending) {
                    npcDmg = std::max(0, npcDmg - 2);
                    std::cout << "You defend and reduce incoming damage!\n";
                    log("You defend and reduce incoming damage!");
                    defending = false;
                }
                if (npcCrit) { std::string msg = randomFlavor(npcCritFlavors) + " " + npcDisplayNames[npcIndex] + " attacks for 4 damage!"; std::cout << msg << "\n"; log(msg); }
                if (npcMiss) { std::string msg = randomFlavor(npcMissFlavors) + " " + npcDisplayNames[npcIndex] + " misses!"; std::cout << msg << "\n"; log(msg); }
                if (npcDmg > 0) {
                    std::string msg = npcDisplayNames[npcIndex] + " attacks for " + std::to_string(npcDmg) + " damage!";
                    std::cout << msg << "\n";
                    log(msg);
                    playerHp -= npcDmg;
                } else if (npcMiss) {
                    // Already printed miss flavor
                } else {
                    std::string msg = npcDisplayNames[npcIndex] + " attacks but you block all damage!";
                    std::cout << msg << "\n";
                    log(msg);
                }
                if (playerHp <= 0) {
                    std::string msg = "You were defeated by " + npcDisplayNames[npcIndex] + "...";
                    std::cout << msg << "\n";
                    log(msg);
                    break;
                } else {
                    std::string msg = "Your HP: " + std::to_string(playerHp) + "/" + std::to_string(playerMaxHp);
                    std::cout << msg << "\n";
                    log(msg);
                }
            }
        }
        // NPC surrender/flee/truce logic
        if (npcHp > 0 && npcHp <= npcMaxHp / 4) {
            int surrenderRoll = rand() % 3;
            if (surrenderRoll == 0) {
                std::cout << npcDisplayNames[npcIndex] << " begs for mercy! Will you (1) Spare or (2) Finish? ";
                std::string mercyInput;
                std::getline(std::cin, mercyInput);
                if (!mercyInput.empty() && mercyInput[0] == '1') {
                    std::cout << "You spare " << npcDisplayNames[npcIndex] << ". They thank you and flee!\n";
                    break;
                } else {
                    std::cout << "You show no mercy. The fight continues!\n";
                }
            } else if (surrenderRoll == 1) {
                std::cout << npcDisplayNames[npcIndex] << " tries to flee! (1) Let them go  (2) Block escape: ";
                std::string fleeInput;
                std::getline(std::cin, fleeInput);
                if (!fleeInput.empty() && fleeInput[0] == '1') {
                    std::cout << "You let " << npcDisplayNames[npcIndex] << " escape.\n";
                    break;
                } else {
                    std::cout << "You block their escape. The fight continues!\n";
                }
            } else if (surrenderRoll == 2) {
                std::cout << npcDisplayNames[npcIndex] << " offers a truce! (1) Accept  (2) Refuse: ";
                std::string truceInput;
                std::getline(std::cin, truceInput);
                if (!truceInput.empty() && truceInput[0] == '1') {
                    std::cout << "You accept the truce. Combat ends peacefully.\n";
                    break;
                } else {
                    std::cout << "You refuse the truce. The fight continues!\n";
                }
            }
        }
    }
    if (playerHp < 0) playerHp = 0;
    if (npcHp < 0) npcHp = 0;
    npcCurHp[npcIndex] = npcHp;
    // Show final combat log
    std::cout << "\n--- Combat Log ---\n";
    for (const auto& entry : combatLog) std::cout << entry << "\n";
}

// Helper for random flavor
std::string randomFlavor(const std::vector<std::string>& options) {
    if (options.empty()) return "";
    return options[rand() % options.size()];
}

std::vector<std::string> critFlavors = {
    "A devastating blow!", "A perfect strike!", "You catch them off guard!", "A critical hit!" };
std::vector<std::string> missFlavors = {
    "You miss completely!", "Your attack glances off.", "They dodge at the last second!", "You stumble and miss!" };
std::vector<std::string> npcCritFlavors = {
    "It's a crushing hit!", "You reel from the blow!", "A critical from your foe!" };
std::vector<std::string> npcMissFlavors = {
    "They miss you!", "You duck just in time!", "You parry the attack!" };

// Romance/relationship effects: refuse to fight or go easy
extern std::vector<int> romanceScores;
if (romanceScores[npcIndex] >= 3) {
    std::cout << npcDisplayNames[npcIndex] << " looks at you with affection and refuses to fight seriously.\n";
    std::cout << "Combat ends peacefully.\n";
    return;
}

// Oracle support: tips, buffs, revival
if (npcDisplayNames[npcIndex] == "ORACLE") {
    std::cout << "The Oracle smiles: 'I will not fight you, creator. But I can offer you wisdom.'\n";
    std::cout << "[Oracle Tip] In combat, use Defend to block damage, and Heal to recover. Power Attacks can deal critical hits!\n";
    std::cout << "If you fall in battle, I will revive you once per session.\n";
    static bool oracleReviveUsed = false;
    if (playerHp <= 0 && !oracleReviveUsed) {
        std::cout << "The Oracle restores you to full health!\n";
        playerHp = playerMaxHp;
        oracleReviveUsed = true;
    }
    return;
}
