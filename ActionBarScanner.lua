-- ActionBarScanner.lua
local addonName, addon = ...
-- Create the library
local name, version = "Blizzkili-ActionBarScanner", 1
local ActionBarScanner = LibStub:NewLibrary(name, version)
if not ActionBarScanner then return end
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)
local Debug = LibStub("Blizzkili-Debug")
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end
local info = function(msg) Debug.Info(Blizzkili.db.profile, msg) end
local trace = function(msg) Debug.Trace(Blizzkili.db.profile, msg) end
-- local bindings, rebuild on reload and login to ensure we have the latest data, also allows for dynamic updates if needed in the future.
local spellBindings = {}

-- Action bar names to scan
local actionBars = {
    "Action",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarLeft",
    "MultiBarRight",
    "MultiBar5",
    "MultiBar6",
    "MultiBar7"
}

-- Initialize the library
function ActionBarScanner:OnInitialize()
-- do nothing for now, we can move initialization code here if needed in the future
end

-- Enable the library
function ActionBarScanner:OnEnable()
    -- Scan action bars when enabled
    self:ScanActionBars()
end

-- Scan all action bars
function ActionBarScanner:ScanActionBars()
    trace("Scanning action bars for spell bindings...")
    --reset bindings
    spellBindings = {}

    for _, barName in ipairs(actionBars) do
        for i = 1, 12 do
            local buttonName = barName .. "Button" .. i
            local button = _G[buttonName]

            if button then
                local slot = (button.action) or 0
                if HasAction(slot) then
                    local actionType, id = GetActionInfo(slot)
                    -- Only consider spells and macros (which can contain spells)
                    if id  and (actionType == "spell"  or actionType == "macro") then
                        -- Get spell name
                        local spellName = BlizzardAPI.GetSpellInfo(id)
                        local bindingAction = button.bindingAction or ""

                        -- Get keybinds for this action
                        local keybind = self:GetSpellKeybinds(bindingAction)

                        -- Store in database if we have a keybind
                        -- preventing overriding keybind s with an empty keybind
                        if keybind then
                            spellBindings[id] = {
                                spellName = spellName,
                                keybind = keybind,
                                actionButton = buttonName,
                                slot = slot
                            }
                        end
                    end
                end
            end
        end
    end
end
local function NormalizeKeybind(key)
    if not key then return nil end

    -- Replace modifiers
    key = key:gsub("CTRL%-", "C")
    key = key:gsub("ALT%-", "A")
    key = key:gsub("SHIFT%-", "S")

    return key
end
-- Get keybinds for a spell
function ActionBarScanner:GetSpellKeybinds(buttonName)
    local keybind = nil
    -- Try to get keybinds using GetBindingKey
    local key1, key2 = GetBindingKey(buttonName)
    if key1 then
        keybind = key1
    elseif key2 then
        keybind = key2
    end
    trace("Found keybind " .. tostring(keybind) .. " for button " .. tostring(buttonName))
    return NormalizeKeybind(keybind)
end

-- Get count of spells scanned
function ActionBarScanner:GetSpellCount()
    local count = 0
    for _, _ in pairs(spellBindings) do
        count = count + 1
    end
    return count
end
-- Public API functions

-- Get all spell bindings
function ActionBarScanner:GetSpellBindings()
    return spellBindings
end

-- Get keybinds for a specific spell ID
function ActionBarScanner:GetSpellKeybindsForId(spellId)
    if spellBindings[spellId] and spellBindings[spellId].keybind then
        return spellBindings[spellId].keybind or ""
    end
    return ""
end

-- Get spell name for a spell ID
function ActionBarScanner:GetSpellName(spellId)
    if spellBindings[spellId] then
        return spellBindings[spellId].spellName
    end
    return nil
end

-- Check if a spell is bound to any action bar
function ActionBarScanner:IsSpellBound(spellId)
    return spellBindings[spellId] ~= nil
end

-- Get action button name for a spell
function ActionBarScanner:GetSpellActionButton(spellId)
    if spellBindings[spellId] then
        return spellBindings[spellId].actionButton
    end
    return nil
end

-- Force a re-scan of action bars
-- TODO might be unnecessary, we can call ScanActionBars directly
function ActionBarScanner:ForceScan()
    info("Forcing re-scan of action bars...")
    self:ScanActionBars()
end

-- Get all spell IDs that have been scanned
function ActionBarScanner:GetAllSpellIds()
    local spellIds = {}
    for spellId, _ in pairs(spellBindings) do
        table.insert(spellIds, spellId)
    end
    return spellIds
end