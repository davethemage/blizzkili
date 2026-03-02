-- SpellBlacklist.lua
local addonName, addon = ...
local SpellBlacklist = LibStub:NewLibrary("Blizzkili-SpellBlacklist", 1)
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)

function SpellBlacklist.isBlacklisted(spellId)
  if Blizzkili.db.profile.blacklistSpells[spellId] then
    return Blizzkili.db.profile.blacklistSpells[spellId] > 0
  end
  return false
end