--- Defaults.lua
-- Default configuration values for the addon

local addonName, addon = ...
local Blizzkili = LibStub("AceAddon-3.0"):NewAddon(
    addonName,
    "AceConsole-3.0",
    "AceEvent-3.0"
)
addon.shortName = "BK"
addon.longName = "Blizzkili"
addon.version = "1.0.4" --keep in sync with toc and README

-- Default configuration values
Blizzkili.defaults = {
    profile = {
        enabled = true, --todo?
        lockFrames = true,
        scale = 1.0, --todo
        alpha = 1.0, --todo
        mainScale = 1.2,
        debugLevel = 0,
        inCombatUpdateRate = 0.2,
        outOfCombatUpdateRate = 1.0,
        keybindUpdateRate = 30,
        keybindOverrideEnabled = true,
        blacklistEnabled = true,
        position = {
            x = 0,
            y = 0,
            anchorPoint = "CENTER",
            parentAnchor = "CENTER"
        },
        buttons = {
            numButtons = 3,
            buttonSize = 40,
            buttonSpacing = 5,
            layout = "right",
            zoom = true,
        },
        display = {
            showCooldowns = false,
            showStacks = false,
            glowMain = 2,
            glowColor = { r = 1, g = 1, b = 0, a = 1 },
        },
        keybind = {
            enabled = true,
            font = "Friz Quadrata TT",
            size = 12,
            outline = "OUTLINE",
            color = { r = 1, g = 1, b = 1, a = 1 },
            parentAnchor = "CENTER",
            anchorPoint = "CENTER",
            xOffset = 0,
            yOffset = 0,

        },
        stacks = { --todo
            enabled = true,
            font = "Friz Quadrata TT",
            size = 12,
            color = { r = 1, g = 1, b = 1, a = 1 },
            parentAnchor = "BOTTOMRIGHT",
            anchorPoint = "BOTTOMRIGHT",
            xOffset = -2,
            yOffset = -2,
        },
        keybindOverrides = {
            -- [spellID] = "keybind"
        },
        blacklistSpells = {
            --[spellID] = indexReason
            --Hunter
            [883] = 1,     -- Call Pet 1
            [83242] = 1,   -- Call Pet 2
            [83243] = 1,   -- Call Pet 3
            [83244] = 1,   -- Call Pet 4
            [83245] = 1,   -- Call Pet 5
            [982] = 1,     -- Revive Pet
            -- Warlock
            [688] = 1,     -- Summon Imp
            [697] = 1,     -- Summon Voidwalker
            [712] = 1,     -- Summon Succubus
            [691] = 1,     -- Summon Felhunter
            [30146] = 1,   -- Summon Felguard
            -- Death Knight
            [46584] = 1,   -- Raise Dead (permanent ghoul)
            [46585] = 1,   -- Raise Dead (temporary)
            [42650] = 1,   -- Army of the Dead
            [49206] = 1,   -- Summon Gargoyle
            -- Mage
            [31687] = 1,   -- Summon Water Elemental
            -- Shaman
            [51533] = 1,   -- Feral Spirit
            [198103] = 1,  -- Earth Elemental
            [198067] = 1,  -- Fire Elemental
            [192249] = 1,  -- Storm Elemental
            -- Raid Buffs
            [1126] = 2,    -- Mark of the Wild (Druid)
            [264778] = 2,  -- Mark of the Wild (alternate)
            [21562] = 2,   -- Power Word: Fortitude (Priest)
            [264764] = 2,  -- Power Word: Fortitude (alternate)
            [6673] = 2,    -- Battle Shout (Warrior)
            [264761] = 2,  -- Battle Shout (alternate)
            [1459] = 2,    -- Arcane Intellect (Mage)
            [264760] = 2,  -- Arcane Intellect (alternate)
            [381732] = 2,  -- Blessing of the Bronze (Evoker)
            -- Druid Forms
            [768] = 3,     -- Cat Form
            [5487] = 3,    -- Bear Form
            [783] = 3,     -- Travel Form
            [24858] = 3,   -- Moonkin Form
            [197625] = 3,  -- Moonkin Form (affinity)
            [114282] = 3,  -- Tree of Life
            -- Warrior Stances
            [386164] = 3,  -- Battle Stance
            [386208] = 3,  -- Defensive Stance
            -- Paladin Auras
            [465] = 3,     -- Devotion Aura
            [183435] = 3,  -- Retribution Aura
            [32223] = 3,   -- Crusader Aura
            -- Rogue Stealth
            [1784] = 3,    -- Stealth
            [115191] = 3,  -- Stealth (Subterfuge)
            -- Hunter Aspects
            [5118] = 3,    -- Aspect of the Cheetah
            [186257] = 3,  -- Aspect of the Cheetah
            [186265] = 3,  -- Aspect of the Turtle
            [186289] = 3,  -- Aspect of the Eagle
        },
    }
}
--unused for now, but might add logic later
Blizzkili.overrideReasons = {
    [1] = "Pet",
    [2] = "Raid Buff",
    [3] = "Aura/Stance",
    [100] = "Always"
}