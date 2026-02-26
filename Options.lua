--- Options.lua
-- Configuration options using Ace3Config

local addonName, addon = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local UILib = LibStub("Blizzkili-UILib")
local LSM = LibStub("LibSharedMedia-3.0")
local Options = LibStub:NewLibrary("Blizzkili-Options", 1)

-- Get reference to the addon
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)

local L = LibStub("AceLocale-3.0"):GetLocale("Blizzkili", true)

-- Fonts from LSM
local function fontValues()
    local fonts = LSM:HashTable("font")
    local values = {}
    for name, _ in pairs(fonts) do
        values[name] = name -- key = label
    end
    return values
end

function Options:SetupOptions()
    -- Create the options table
    local options = {
        name = "Blizzkili",
        type = "group",
        args = {
            general = {
                name = "General",
                type = "group",
                order = 1,
                args = {
                    lockFrames = {
                        name = "Lock Frames",
                        desc = "Lock frames in place",
                        type = "toggle",
                        order = 2,
                        get = function() return Blizzkili.db.profile.lockFrames end,
                        set = function(_, value)
                            Blizzkili.db.profile.lockFrames = value
                            Blizzkili:UpdateFrameLock()
                        end,
                    },
                    -- scale = {
                    --     name = "Scale",
                    --     desc = "Overall frame scale",
                    --     type = "range",
                    --     min = 0.5,
                    --     max = 2.0,
                    --     step = 0.1,
                    --     order = 3,
                    --     get = function() return Blizzkili.db.profile.scale end,
                    --     set = function(_, value)
                    --         Blizzkili.db.profile.scale = value
                    --         UILib:UpdateFramePosition()
                    --     end,
                    -- },
                    -- alpha = {
                    --     name = "Transparency",
                    --     desc = "Frame alpha transparency",
                    --     type = "range",
                    --     min = 0.1,
                    --     max = 1.0,
                    --     step = 0.1,
                    --     order = 4,
                    --     get = function() return Blizzkili.db.profile.alpha end,
                    --     set = function(_, value)
                    --         Blizzkili.db.profile.alpha = value
                    --         UILib:UpdateFramePosition()
                    --     end,
                    -- },
                },
            },
            buttons = {
                name = "Buttons",
                type = "group",
                order = 2,
                args = {
                    numButtons = {
                        name = "Number of Buttons",
                        desc = "How many ability buttons to display",
                        type = "range",
                        min = 1,
                        max = 10,
                        step = 1,
                        order = 1,
                        get = function() return Blizzkili.db.profile.buttons.numButtons end,
                        set = function(_, value)
                            Blizzkili.db.profile.buttons.numButtons = value
                            UILib.UpdateButtons()
                        end,
                    },
                    mainScale = {
                        name = "Main Button Scale",
                        desc = "Scale of the main button (first button)",
                        type = "range",
                        min = 0.1,
                        max = 5.0,
                        step = 0.1,
                        order = 1.5,
                        get = function() return Blizzkili.db.profile.mainScale end,
                        set = function(_, value)
                            Blizzkili.db.profile.mainScale = value
                            UILib.UpdateButtons()
                        end,
                    },
                    buttonSize = {
                        name = "Button Size",
                        desc = "Base button size in pixels",
                        type = "range",
                        min = 1,
                        max = 150,
                        step = 1,
                        order = 2,
                        get = function() return Blizzkili.db.profile.buttons.buttonSize end,
                        set = function(_, value)
                            Blizzkili.db.profile.buttons.buttonSize = value
                            UILib.UpdateButtons()
                        end,
                    },
                    buttonSpacing = {
                        name = "Button Spacing",
                        desc = "Space between buttons",
                        type = "range",
                        min = 0,
                        max = 20,
                        step = 1,
                        order = 3,
                        get = function() return Blizzkili.db.profile.buttons.buttonSpacing end,
                        set = function(_, value)
                            Blizzkili.db.profile.buttons.buttonSpacing = value
                            UILib.UpdateButtons()
                        end,
                    },
                    layout = {
                        name = "Layout",
                        desc = "Horizontal or Vertical arrangement",
                        type = "select",
                        values = {
                            horizontal = "Horizontal",
                            vertical = "Vertical",
                        },
                        order = 4,
                        get = function() return Blizzkili.db.profile.buttons.layout end,
                        set = function(_, value)
                            Blizzkili.db.profile.buttons.layout = value
                            UILib.UpdateButtons()
                        end,
                    },
                    zoomButtons = {
                        name = "Zoom Button Textures",
                        desc = "Enable zoom effect on button textures",
                        type = "toggle",
                        order = 5,
                        get = function() return Blizzkili.db.profile.buttons.zoom end,
                        set = function(_, value)
                            Blizzkili.db.profile.buttons.zoom = value
                            UILib.UpdateButtons()
                        end,
                    },
                },
            },
            display = {
                name = "Display",
                type = "group",
                order = 3,
                args = {
                    glowMain = {
                        name = "Glow Type",
                        desc = "Enable glow effect on the main button",
                        type = "select",
                        order = 1,
                        values = {
                            [0] = "None",
                            [1] = "Gold",
                            [2] = "Assisted Blue",
                            [3] = "Custom Color", --always last make sure to update when you select a custom color
                        },
                        get = function() return Blizzkili.db.profile.display.glowMain end,
                        set = function(_, value)
                            Blizzkili.db.profile.display.glowMain = value
                            UILib.UpdateButtons()
                        end,
                    },
                    glowColor = {
                        name = "Custom Glow Color",
                        desc = "Color of the glow effect",
                        type = "color",
                        hasAlpha = true,
                        order = 2,
                        get = function()
                            local color = Blizzkili.db.profile.display.glowColor
                            return color.r, color.g, color.b, color.a
                        end,
                        set = function(_, r, g, b, a)
                            Blizzkili.db.profile.display.glowColor = { r = r, g = g, b = b, a = a }
                            Blizzkili.db.profile.display.glowMain = 3 -- switch to custom color if not already
                            UILib.UpdateButtons()
                        end,
                    },
                    positionX = {
                        name = "Position X",
                        desc = "Horizontal position offset",
                        type = "range",
                        min = -5000,
                        max = 5000,
                        step = 1,
                        order = 3,
                        get = function() return Blizzkili.db.profile.position.x end,
                        set = function(_, value)
                            Blizzkili.db.profile.position.x = value
                            UILib:UpdateFramePosition()
                        end,
                    },
                    positionY = {
                        name = "Position Y",
                        desc = "Vertical position offset",
                        type = "range",
                        min = -5000,
                        max = 5000,
                        step = 1,
                        order = 4,
                        get = function() return Blizzkili.db.profile.position.y end,
                        set = function(_, value)
                            Blizzkili.db.profile.position.y = value
                            UILib:UpdateFramePosition()
                        end,
                    },
                    anchorPoint = {
                        name = "Anchor",
                        desc = "Point on the frame to anchor",
                        type = "select",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right",
                        },
                        order = 5,
                        get = function() return Blizzkili.db.profile.position.anchorPoint end,
                        set = function(_, value)
                            Blizzkili.db.profile.position.anchorPoint = value
                            UILib:UpdateFramePosition()
                        end,
                    },
                    parentAnchor = {
                        name = "Parent Anchor",
                        desc = "Point on the parent to anchor to",
                        type = "select",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right",
                        },
                        order = 6,
                        get = function() return Blizzkili.db.profile.position.parentAnchor end,
                        set = function(_, value)
                            Blizzkili.db.profile.position.parentAnchor = value
                            UILib:UpdateFramePosition()
                        end,
                    },
                },
            },
            keybinds = {
                name = "Keybinds",
                type = "group",
                order = 4,
                args = {
                    enabled = {
                        name = "Enable Keybinds",
                        desc = "Show keybind text on buttons",
                        type = "toggle",
                        order = 1,
                        get = function() return Blizzkili.db.profile.keybind.enabled end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.enabled = value
                            UILib.UpdateButtons()
                        end,
                    },
                    font = {
                        name = "Font",
                        desc = "Font for keybind text",
                        type = "select",
                        dialogControl = "LSM30_Font",
                        values = function() return fontValues() end,
                        order = 2,
                        get = function() return Blizzkili.db.profile.keybind.font end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.font = value
                            UILib.UpdateButtons()
                        end,
                    },
                    size = {
                        name = "Font Size",
                        desc = "Size of keybind text",
                        type = "range",
                        min = 1,
                        max = 100,
                        step = 1,
                        order = 3,
                        get = function() return Blizzkili.db.profile.keybind.size end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.size = value
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindOutline = {
                        name = "Font Outline",
                        desc = "Outline for keybind text",
                        type = "select",
                        values = {
                            ["NONE"] = "None",
                            ["OUTLINE"] = "Outline",
                            ["THICKOUTLINE"] = "Thick Outline",
                            ["MONOCHROME"] = "Monochrome",
                            ["MONOCHROMEOUTLINE"] = "Monochrome Outline",
                            ["MONOCHROMETHICKOUTLINE"] = "Monochrome Thick Outline",
                        },
                        order = 4,
                        get = function() return Blizzkili.db.profile.keybind.outline end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.outline = value
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindColor = {
                        name = "Font Color",
                        desc = "Color of keybind text",
                        type = "color",
                        hasAlpha = true,
                        order = 5,
                        get = function()
                            local color = Blizzkili.db.profile.keybind.color
                            return color.r, color.g, color.b, color.a
                        end,
                        set = function(_, r, g, b, a)
                            Blizzkili.db.profile.keybind.color = { r = r, g = g, b = b, a = a }
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindAnchorPoint = {
                        name = "Anchor",
                        desc = "Point on the button to anchor keybind text",
                        type = "select",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right",
                        },
                        order = 6,
                        get = function() return Blizzkili.db.profile.keybind.anchorPoint end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.anchorPoint = value
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindParentAnchor = {
                        name = "Parent Anchor",
                        desc = "Point on the button to anchor keybind text",
                        type = "select",
                        values = {
                            ["TOPLEFT"] = "Top Left",
                            ["TOP"] = "Top",
                            ["TOPRIGHT"] = "Top Right",
                            ["LEFT"] = "Left",
                            ["CENTER"] = "Center",
                            ["RIGHT"] = "Right",
                            ["BOTTOMLEFT"] = "Bottom Left",
                            ["BOTTOM"] = "Bottom",
                            ["BOTTOMRIGHT"] = "Bottom Right",
                        },
                        order = 7,
                        get = function() return Blizzkili.db.profile.keybind.parentAnchor end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.parentAnchor = value
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindXOffset = {
                        name = "X Offset",
                        desc = "Horizontal offset for keybind text",
                        type = "range",
                        min = -100,
                        max = 100,
                        step = 1,
                        order = 8,
                        get = function() return Blizzkili.db.profile.keybind.xOffset end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.xOffset = value
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindYOffset = {
                        name = "Y Offset",
                        desc = "Vertical offset for keybind text",
                        type = "range",
                        min = -100,
                        max = 100,
                        step = 1,
                        order = 9,
                        get = function() return Blizzkili.db.profile.keybind.yOffset end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.yOffset = value
                            UILib.UpdateButtons()
                        end,
                    },
                },
            },
            misc = {
                name = "Miscellaneous",
                type = "group",
                order = 10,
                args = {
                    debug = {
                        name = "Debug Mode",
                        desc = "Enable debug mode for additional logging",
                        type = "range",
                        min = 0,
                        max = 3,
                        step = 1,
                        order = 1,
                        get = function() return Blizzkili.db.profile.debugLevel end,
                        set = function(_, value)
                            Blizzkili.db.profile.debugLevel = value
                        end,
                    },
                    inCombatUpdateRate ={
                        name = "In-Combat Update Rate",
                        desc = "How often to update the rotation display while in combat (in seconds)",
                        type = "range",
                        min = 0.1,
                        max = 5.0,
                        step = 0.1,
                        order = 2,
                        get = function() return Blizzkili.db.profile.inCombatUpdateRate or 1 end,
                        set = function(_, value)
                            Blizzkili.db.profile.inCombatUpdateRate = value
                        end,
                    },
                    outOfCombatUpdateRate = {
                        name = "Out-of-Combat Update Rate",
                        desc = "How often to update the rotation display while out of combat (in seconds)",
                        type = "range",
                        min = 0.1,
                        max = 10.0,
                        step = 0.1,
                        order = 3,
                        get = function() return Blizzkili.db.profile.outOfCombatUpdateRate or 1 end,
                        set = function(_, value)
                            Blizzkili.db.profile.outOfCombatUpdateRate = value
                        end
                    },
                },
            },
        },
    }

    -- Register the options
    AceConfig:RegisterOptionsTable(addon.longName, options)
    AceConfigDialog:SetDefaultSize(addon.longName, 600, 500)
    AceConfigDialog:AddToBlizOptions(addon.longName, addon.longName)
end
