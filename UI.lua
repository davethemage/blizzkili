--- UI.lua
-- User interface creation and management

local addonName, addon = ...
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)

-- Update frame lock status
function Blizzkili:UpdateFrameLock()
    if not self.frame then return end

    if self.db.profile.lockFrames then
        self.frame:EnableMouse(false)
        self.frame:SetMovable(false)
    else
        self.frame:EnableMouse(true)
        self.frame:SetMovable(true)
    end
end
