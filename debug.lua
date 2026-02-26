-- Debug.lua
local addonName, addon = ...
local Debug = LibStub:NewLibrary("Blizzkili-Debug", 1)
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)

-- Default debug print
function Debug.Print(printLevel, profile, prefix, msg)
  local debugLevel = profile.debugLevel or 0
  if printLevel <= profile.debugLevel then
    print(prefix .. " " .. msg)
  end
end

function Debug.Error(profile, msg)
  Debug.Print(1, profile, "|cffff0000["..addon.longName.. "]|r", msg)
end

function Debug.Info(profile, msg)
  Debug.Print(2, profile, "|cffffff00["..addon.longName.. "]|r", msg)
end

function Debug.Trace(profile, msg)
  Debug.Print(3, profile, "|cff00ff00["..addon.longName.. "]|r", msg)
end