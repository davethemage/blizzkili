--- Core.lua
-- Main addon initialization and frame management

local addonName, addon = ...

local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Blizzkili", true)
local UILib = LibStub("Blizzkili-UILib")
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local ActionBarScanner = LibStub("Blizzkili-ActionBarScanner")
local ButtonLib = LibStub("Blizzkili-ButtonLib")
local Options = LibStub("Blizzkili-Options")
local Debug = LibStub("Blizzkili-Debug")
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end
local info = function(msg) Debug.Info(Blizzkili.db.profile, msg) end
local trace = function(msg) Debug.Trace(Blizzkili.db.profile, msg) end

-- Initialize the addon
function Blizzkili:OnInitialize()
    -- Register the database
    self.db = LibStub("AceDB-3.0"):New("BlizzkiliDB", self.defaults, true)

    -- Register slash commands
    Blizzkili:RegisterChatCommand(addon.longName:lower(), "SlashCommand")
    Blizzkili:RegisterChatCommand(addon.shortName:lower(), "SlashCommand")
    Blizzkili:RegisterChatCommand("hekili", "SlashCommand")

    -- Create the main frame
    -- UILib.CreateUI()
    ActionBarScanner:OnInitialize()
    Options:SetupOptions()
    -- Print initialization message
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00["..addon.shortName.."]|r ".. addon.longName .." v".. addon.version .. " - |cff00ff00/".. addon.shortName:lower() .. "|r")
end

-- Enable the addon
function Blizzkili:OnEnable()
    -- Register events after initialization
    ActionBarScanner:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN", "OnLogin")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "PlayerEnteringWorld")
    self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "ActionbarChanged")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OutOfCombat")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "InCombat")
    self:RegisterEvent("UNIT_AURA", "OnUnitAura")
end

-- Handle player login
function Blizzkili:OnLogin()
    info("Player logged in,")
    -- Initialize the UI
    UILib.CreateUI()
    self:UpdateRotation()
    ActionBarScanner:ScanActionBars()
end

-- Update OnUnitAura
-- TODO Fires alot put in a throttle to prevent performance issues.
function Blizzkili:OnUnitAura(unit)
    -- if unit == "player" then
    --     self:UpdateRotation()
    -- end
end

-- PlayerEnteringWorld event handler
function Blizzkili:PlayerEnteringWorld()
    info("Player entering world")
    UILib.UpdateButtons()
    -- Lock or unlock the frame
    self:UpdateFrameLock()
    ActionBarScanner:ScanActionBars()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    self.ticker = C_Timer.NewTicker(self.db.profile.outOfCombatUpdateRate, function() self:UpdateRotation() end)

end

function Blizzkili:OutOfCombat()
    UILib.UpdateButtons()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    -- Out of combat we can update less frequently since we can use all API functions, so we can slow down the ticker to reduce CPU usage.
    self.ticker = C_Timer.NewTicker(self.db.profile.outOfCombatUpdateRate, function() self:UpdateRotation() end)
end

function Blizzkili:InCombat()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    self.ticker = C_Timer.NewTicker(self.db.profile.inCombatUpdateRate, function() self:UpdateRotation() end)
end

--Action bar changed event handler
function Blizzkili:ActionbarChanged()
    ActionBarScanner:ScanActionBars()
end

-- Update frame lock status
function Blizzkili:UpdateFrameLock()
    trace("Updating frame lock status")
    if not self.frame then return end

    if self.db.profile.lockFrames then
        info("Locking frames")
        self.frame:EnableMouse(false)
        self.frame:SetMovable(false)
        self.frame:SetBackdropColor(0, 0, 0, 0)

    else
        info("Unlocking frames")
        self.frame:EnableMouse(true)
        self.frame:SetMovable(true)
        self.frame:SetBackdropColor(0, 0, 0, 0.7)

    end
end

-- Update the rotation display
function Blizzkili:UpdateRotation()
    -- This implements the Single Button Assistant rotation logic
    if not self.buttons then
        error("No buttons found, cannot update rotation")
        return
    end
    trace("Updating rotation display") --debug

    -- Get the current rotation information
    local rotationSpells = BlizzardAPI.GetAssistedCombatRotation()

    -- TODO add prioritySpell(Cooldowns) Requires tracking cooldowns manually since we can't use IsSpellOnCooldown in combat due to secret values.
    -- local prioritySpell= 442204
    -- if not BlizzardAPI.IsSpellOnCooldown(prioritySpell) then
    --     print("Priority spell " .. prioritySpell .. " is not on cooldown, adding to rotation")
    --     table.insert(rotationSpells, 1, prioritySpell)
    -- else
    --     print("Priority spell " .. prioritySpell .. " is on cooldown, not adding to rotation")
    -- end

    -- Update buttons based on rotation
    for i, button in ipairs(self.buttons) do
        if i <= #self.buttons and i <= #rotationSpells  and i <= self.db.profile.buttons.numButtons then
            ButtonLib.UpdateButton(button, rotationSpells[i])
        elseif not BlizzardAPI:InCombat() then
            button:Hide()  -- Hide unused buttons when not in combat
        end
    end
end

-- Handle slash commands
function Blizzkili:SlashCommand(input)
    if input == "lock" then
        self.db.profile.lockFrames = true
        self:UpdateFrameLock()
        info("Blizzkili frames locked")
    elseif input == "unlock" then
        self.db.profile.lockFrames = false
        self:UpdateFrameLock()
        info("Blizzkili frames unlocked")
    else
        -- Open configuration panel
        if AceConfigDialog and AceConfigDialog.OpenFrames["Blizzkili"] then
            AceConfigDialog:Close("Blizzkili")
        else
            AceConfigDialog:Open("Blizzkili")
        end
    end
end
