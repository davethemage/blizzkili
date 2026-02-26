--- Options.lua
-- Configuration options using Ace3Config

local addonName, addon = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local UILib = LibStub("Blizzkili-UILib")
local LSM = LibStub("LibSharedMedia-3.0")
local Options = LibStub:NewLibrary("Blizzkili-Options", 1)
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local ActionBarScanner = LibStub("Blizzkili-ActionBarScanner")
-- Get reference to the addon
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)
local Debug = LibStub("Blizzkili-Debug")
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end
local info = function(msg) Debug.Info(Blizzkili.db.profile, msg) end
local trace = function(msg) Debug.Trace(Blizzkili.db.profile, msg) end

local L = LibStub("AceLocale-3.0"):GetLocale("Blizzkili", true)

local xs_element = 0.3
local sm_element = 0.56 -- 4 elements per row
local med_element = 0.75 -- 3 elements per row
local lg_element = 1.125  -- 2 elements per row
local xl_element = 2 -- 1 element per row
-- Fonts from LSM
local function fontValues()
    local fonts = LSM:HashTable("font")
    local values = {}
    for name, _ in pairs(fonts) do
        values[name] = name -- key = label
    end
    return values
end

local function orderedLayoutValues()
    local layouts = {
        [1] = "Right",
        [2] = "Left",
        [3] = "Up",
        [4] = "Down",
    }
    return layouts
end

local function convertLayoutToKey(index)
    return orderedLayoutValues()[index]:lower() or "right"
end
local function convertLayoutToIndex(layoutKey)
    local layoutKeys = {
        right = 1,
        left = 2,
        up = 3,
        down = 4,
    }
    return layoutKeys[layoutKey] or 1
end

function Options:SetupOptions()
    local keybindOverrideSpellId = nil
    local keybindOverrideKeybind = ""
    local options = nil

    local function refreshLayout ()
        if options then
            AceConfigDialog:Open(addonName)
        end
    end
    -- Function to dynamically update the options with the current keybindOverrides
    local function updateKeybindOverridesOptions()
        -- Clear out any previous options
        if not options or not options.args.keybindOverrides or not options.args.keybindOverrides.args.keybindOverrideList then return end
        options.args.keybindOverrides.args.keybindOverrideList.args = {}

        -- Iterate over the keybindOverrides table and create options for each spellID
        for spellID, keybind in pairs(Blizzkili.db.profile.keybindOverrides) do
            -- Add a new option for each spellID
            -- add remove button
            local spellInfo = BlizzardAPI.GetSpellInfo(spellID)
            local spellIcon = spellInfo and spellInfo.iconID or ""
            local spellName = spellInfo and spellInfo.name or "N/A"
            options.args.keybindOverrides.args.keybindOverrideList.args[tostring(spellID)] = {
                type = "group",
                name = "|T" .. spellIcon .. ":16:16:0:0|t" .. spellName .. " (" .. spellID .. ")",
                order = spellID,
                inline = true,
                args = {
                    ["remove_" .. spellID] = {
                    type = "execute",
                    name = "Delete",
                    desc = "Remove this keybind override",
                    width = sm_element,
                    order = 1,
                    func = function()
                        -- Remove the keybind for this spellID
                        Blizzkili.db.profile.keybindOverrides[spellID] = nil
                        -- Update Keybinds
                        ActionBarScanner:ScanActionBars()
                        -- Update the options again after removal
                        updateKeybindOverridesOptions()
                        -- Update UI
                        UILib.UpdateButtons()
                        -- Refresh the options window
                        refreshLayout()
                    end,
                    },
                    ["custom_keybind_" .. spellID] = {
                        type = "input",
                        name = "Keybind",
                        desc = "Custom keybind for this spellID",
                        width = lg_element,
                        order = 2,
                        get = function() return Blizzkili.db.profile.keybindOverrides[spellID] or "" end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybindOverrides[spellID] = value
                            -- Update Keybinds
                            ActionBarScanner:ScanActionBars()
                            -- Update UI
                            UILib.UpdateButtons()
                            -- Refresh the options window
                            refreshLayout()
                        end,
                    },
                }
            }
        end
    end

    -- Create the options table
    options = {
        name = "Blizzkili",
        type = "group",
        args = {
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
                        width = med_element,
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
                        order = 10,
                        width = med_element,
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
                        width = med_element,
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
                        width = med_element,
                        get = function() return Blizzkili.db.profile.buttons.buttonSpacing end,
                        set = function(_, value)
                            Blizzkili.db.profile.buttons.buttonSpacing = value
                            UILib.UpdateButtons()
                        end,
                    },
                },
            },
            display = {
                name = "General",
                type = "group",
                order = 1,
                args = {
                    generalDisplayOptions = {
                        name = "Display",
                        type = "header",
                        order = 0,
                    },
                    glowHeader = {
                        name = "Main Button Glow",
                        type = "header",
                        order = 10,
                    },
                    displayPositionHeader = {
                        name = "Positioning",
                        type = "header",
                        order = 50,
                    },
                    lockFrames = {
                        name = "Lock Frames",
                        desc = "Lock frames in place",
                        type = "toggle",
                        order = 59,
                        width = med_element,
                        get = function() return Blizzkili.db.profile.lockFrames end,
                        set = function(_, value)
                            Blizzkili.db.profile.lockFrames = value
                            Blizzkili:UpdateFrameLock()
                        end,
                    },
                    layout = {
                        name = "Growth Direction",
                        desc = "Direction to grow the buttons",
                        type = "select",
                        values = orderedLayoutValues(),
                        order = 2,
                        width = med_element,
                        get = function() return convertLayoutToIndex(Blizzkili.db.profile.buttons.layout) end,
                        set = function(key, value)
                            Blizzkili.db.profile.buttons.layout = convertLayoutToKey(value)
                            UILib.UpdateButtons()
                        end,
                    },
                    zoomButtons = {
                        name = "Zoom Textures",
                        desc = "Enable zoom effect on button textures",
                        type = "toggle",
                        order = 3,
                        width = med_element,
                        get = function() return Blizzkili.db.profile.buttons.zoom end,
                        set = function(_, value)
                            Blizzkili.db.profile.buttons.zoom = value
                            UILib.UpdateButtons()
                        end,
                    },
            --     scale = {
            --         name = "Scale",
            --         desc = "Overall frame scale",
            --         type = "range",
            --         min = 0.5,
            --         max = 2.0,
            --         step = 0.1,
            --         order = 3,
            --         get = function() return Blizzkili.db.profile.scale end,
            --         set = function(_, value)
            --             Blizzkili.db.profile.scale = value
            --             UILib:UpdateFramePosition()
            --         end,
            --     },
            --     alpha = {
            --         name = "Transparency",
            --         desc = "Frame alpha transparency",
            --         type = "range",
            --         min = 0.1,
            --         max = 1.0,
            --         step = 0.1,
            --         order = 4,
            --         get = function() return Blizzkili.db.profile.alpha end,
            --         set = function(_, value)
            --             Blizzkili.db.profile.alpha = value
            --             UILib:UpdateFramePosition()
            --         end,
            --         },
            --     },
                    glowMain = {
                        name = "Glow Type",
                        desc = "Enable glow effect on the main button",
                        type = "select",
                        order = 11,
                        width = lg_element,
                        values = {
                            [0] = "None",
                            [1] = "Gold",
                            [2] = "Assisted Blue",
                            [100] = "Custom Color", --always last make sure to update when you select a custom color
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
                        order = 12,
                        width = lg_element,
                        get = function()
                            local color = Blizzkili.db.profile.display.glowColor
                            return color.r, color.g, color.b, color.a
                        end,
                        set = function(_, r, g, b, a)
                            Blizzkili.db.profile.display.glowColor = { r = r, g = g, b = b, a = a }
                            Blizzkili.db.profile.display.glowMain = 100 -- switch to custom color if not already
                             refreshLayout()
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
                        order = 53,
                        width = lg_element,
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
                        order = 54,
                        width = lg_element,
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
                        order = 51,
                        width = lg_element,
                        get = function() return Blizzkili.db.profile.position.anchorPoint end,
                        set = function(_, value)
                            Blizzkili.db.profile.position.anchorPoint = value
                            UILib:UpdateFramePosition()
                        end,
                    },
                    parentAnchor = {
                        name = "Parent Anchor",
                        desc = "Point on the screen to anchor to",
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
                        order = 52,
                        width = lg_element,
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
                    keybindFontHeader = {
                        name = "Font",
                        type = "header",
                        order = 0,
                    },
                    keybindPositionHeader = {
                        name = "Position",
                        type = "header",
                        order = 10,
                    },
                    keybindMiscOptions = {
                        name = "Miscellaneous",
                        type = "header",
                        order = 90,
                    },
                    enabled = {
                        name = "Enable Keybinds",
                        desc = "Show keybind text on buttons",
                        type = "toggle",
                        order = 91,
                        width = lg_element,
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
                        order = 3,
                        width = med_element,
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
                        order = 5,
                        width = med_element,
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
                        width = med_element,
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
                        order = 9,
                        width = med_element,
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
                        order = 11,
                        width = lg_element,
                        get = function() return Blizzkili.db.profile.keybind.anchorPoint end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.anchorPoint = value
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindParentAnchor = {
                        name = "Parent Anchor",
                        desc = "Point on the parent to anchor keybind text",
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
                        order = 12,
                        width = lg_element,
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
                        order = 13,
                        width = lg_element,
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
                        order = 14,
                        width = lg_element,
                        get = function() return Blizzkili.db.profile.keybind.yOffset end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybind.yOffset = value
                            UILib.UpdateButtons()
                        end,
                    },
                },
            },
            keybindOverrides = {
                name = "Keybind Overrides",
                type = "group",
                order = 5,
                args = {
                    keybindOverrideHeader = {
                        name = "Keybind Override Options",
                        type = "header",
                        order = 0,
                    },
                    keybindOverrideDesc = {
                        name = "These options allow you to override the default keybind display behavior. This is useful if you want to show keybinds only on certain buttons or under certain conditions.",
                        type = "description",
                        order = 1,
                    },
                    -- Additional override options can be added here
                    keybindOverrideEnabled = {
                        name = "Enable Keybind Overrides",
                        desc = "Enable custom keybind display rules",
                        type = "toggle",
                        order = 3,
                        width = xl_element,
                        get = function() return Blizzkili.db.profile.keybindOverrideEnabled end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybindOverrideEnabled = value
                            -- Update Keybinds
                            ActionBarScanner:ScanActionBars()
                            UILib.UpdateButtons()
                        end,
                    },
                    keybindOverrideAddHeader = {
                        name = "Add New Override",
                        type = "header",
                        order = 10,
                    },
                    keybindAllSpells = {
                        name = "All Spells",
                        type = "select",
                        order = 11,
                        width = med_element,
                        values = function() return BlizzardAPI:GetAvailableSpells() end,
                        get = function() return keybindOverrideSpellId end,
                        set = function(_, value)
                            keybindOverrideSpellId = value
                            refreshLayout()
                        end,
                    },
                    keybindOverrideSpellInput = {
                        name = "Spell ID",
                        desc = "Show keybind override for this spell ID",
                        type = "input",
                        order = 12,
                        width = xs_element,
                        get = function() return tostring(keybindOverrideSpellId or "") end,
                        set = function(_, value)
                            keybindOverrideSpellId = tonumber(value) or 0
                        end,
                    },
                    keybindOverridesKeybind = {
                        name = "Keybind",
                        desc = "Keybind to show when override spell is shown",
                        type = "input",
                        order = 13,
                        width = xs_element,
                        get = function() return keybindOverrideKeybind end,
                        set = function(_, value)
                            keybindOverrideKeybind = value
                        end,
                    },
                    keybindOverrideSave = {
                        name = "Save",
                        desc = "Save the current override binding",
                        type = "execute",
                        order = 14,
                        width = sm_element,
                        func = function()
                            if keybindOverrideSpellId and keybindOverrideSpellId > 0 and keybindOverrideKeybind ~= "" then
                                Blizzkili.db.profile.keybindOverrides[keybindOverrideSpellId] = keybindOverrideKeybind
                                keybindOverrideSpellId = nil
                                keybindOverrideKeybind = ""
                                updateKeybindOverridesOptions()
                                -- Update Keybinds
                                ActionBarScanner:ScanActionBars()
                                UILib.UpdateButtons()
                            else
                                error("Please enter a valid spell ID and keybind.")
                            end
                        end,
                    },
                    keybindOverrideList = {
                        name = "Current Overrides",
                        type = "group",
                        order = 20,
                        inline = true,
                        args = {}
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
                        order = 10,
                        width = med_element,
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
                        order = 1,
                        width = lg_element,
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
                        order = 2,
                        width = lg_element,
                        get = function() return Blizzkili.db.profile.outOfCombatUpdateRate or 1 end,
                        set = function(_, value)
                            Blizzkili.db.profile.outOfCombatUpdateRate = value
                        end
                    },
                    keybindUpdateRate ={
                        name = "Keybind Scan Force Update Rate",
                        desc = "How often to force update all keybinds",
                        type = "range",
                        min = 1,
                        max = 300.0,
                        step = 1,
                        order = 3,
                        width = lg_element,
                        get = function() return Blizzkili.db.profile.keybindUpdateRate or 10 end,
                        set = function(_, value)
                            Blizzkili.db.profile.keybindUpdateRate = value
                        end,
                    },
                },
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Blizzkili.db),
        },
    }
    updateKeybindOverridesOptions()
    -- Register the options
    AceConfig:RegisterOptionsTable(addon.longName, options)
    AceConfigDialog:SetDefaultSize(addon.longName, 625, 500)
    AceConfigDialog:AddToBlizOptions(addon.longName, addon.longName)
end
