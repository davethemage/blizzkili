-- Rotation.lua
local addonName, addon = ...
local Rotation = LibStub:NewLibrary("Blizzkili-Rotation", 1)
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local SpellBlacklist = LibStub("Blizzkili-SpellBlacklist")

function Rotation.GetRotation()
  local fullRotation = BlizzardAPI.GetAssistedCombatRotation()
  local trimmedRotation = {}
  local index = 1
  for i, spellId in ipairs(fullRotation) do
    if i == 1 or not SpellBlacklist.isBlacklisted(fullRotation[i]) then
      trimmedRotation[index] = fullRotation[i]
      index = index + 1
    end
  end
  return trimmedRotation
end