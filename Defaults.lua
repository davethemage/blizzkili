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
addon.version = "1.0.2" --keep in sync with toc and README

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
    }
}