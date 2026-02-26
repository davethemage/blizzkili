local addonName, addon = ...
local BlizzardAPI = LibStub:NewLibrary("Blizzkili-BlizzardAPI", 1)
local Debug = LibStub("Blizzkili-Debug")
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end
function BlizzardAPI.GetAssistedCombatRotation()
  local rotation = {}
  local index = 1
  if C_AssistedCombat and C_AssistedCombat.IsAvailable() then
    -- Get the next cast spell (what's coming next)
    local nextCastSpell = C_AssistedCombat.GetNextCastSpell()
    if nextCastSpell then
      rotation[index] = nextCastSpell
      index = index + 1
    else
      error("Next Cast Spell invalid")
    end

    -- Get rotation spells for reference
    local rotationSpells = C_AssistedCombat.GetRotationSpells()
    if rotationSpells and #rotationSpells > 0 then
      for _, spellId in ipairs(rotationSpells) do
          -- Only add if not already in the list
          local alreadyAdded = false
          for _, id in ipairs(rotation) do
            if id == spellId then
              alreadyAdded = true
              break
            end
          end
          if not alreadyAdded then
            rotation[index] = spellId
            index = index + 1
        end
      end
    else
      error("Rotational Spells invalid")
    end
  else
    error("C_AssistedCombat is not available")
  end
  return rotation
end

function BlizzardAPI.GetSpellTexture(spellId)
  if C_Spell and C_Spell.GetSpellTexture then
    return C_Spell.GetSpellTexture(spellId)
  end
  return "Interface\\Buttons\\UI-Quickslot"
end

function BlizzardAPI.GetSpellInfo(spellId)
  if C_Spell and C_Spell.GetSpellInfo then
    return C_Spell.GetSpellInfo(spellId)
  else
    error("C_Spell.GetSpellInfo invalid")
  end
  return nil
end

function BlizzardAPI.GetSpellName(spellId)
  local spellInfo = BlizzardAPI.GetSpellInfo(spellId)
  if spellInfo and spellInfo.name then
    return spellInfo.name
  end
  return ""
end

-- This only works out of combat because values are secret
-- TODO revist
function BlizzardAPI.IsSpellOnCooldown(spellId)
  -- TODO fix this so we can use it in combat, will require manually tracking spells
  if BlizzardAPI.InCombatLockdown() then
    return true
  end
  if not spellId then
    return true
  end

  local cooldownInfo = C_Spell.GetSpellCooldown(spellId)
  if not cooldownInfo then
    return true
  end

  local startTime = cooldownInfo.startTime or 0
  local duration = cooldownInfo.duration or 0

  if startTime == 0 and duration == 0 then
    return false
  end

  return true

end

function BlizzardAPI.InCombat()
    return BlizzardAPI.InCombatLockdown()
end
function BlizzardAPI.InCombatLockdown()
    return InCombatLockdown() or UnitIsDeadOrGhost("player")
end

function BlizzardAPI.GetAvailableSpells()
  local spells = {}
  local blacklist = {
    [6603] = true, -- Auto Attack
    [83958] = true, -- Mobile Banking
    [125439] = true, -- Revive Battle Pets
    [382499] = true, -- Anomaly Detection
    [382501] = true, -- Mechanism Bypass
    [1231411] = true, -- Recuperate
  }

  for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
    local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
    for j = offset + 1, offset + numSlots do
      local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
      local spellType, actionId, id, passive, isOffSpec = spellBookItemInfo.itemType, spellBookItemInfo.actionID, spellBookItemInfo.spellID,  spellBookItemInfo.isPassive, spellBookItemInfo.isOffSpec

        -- Only process and print spells
        if spellType == Enum.SpellBookItemType.Spell and not passive and not isOffSpec then
          if not blacklist[id] then
            local spellName = C_Spell.GetSpellName(id)
            spells[id] = spellName
          end
      end
    end
  end
  return spells
end