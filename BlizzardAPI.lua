local BlizzardAPI = LibStub:NewLibrary("Blizzkili-BlizzardAPI", 1)

function BlizzardAPI.GetAssistedCombatRotation()
  local rotation = {}
  local index = 1
  if C_AssistedCombat and C_AssistedCombat.IsAvailable() then
    -- TODO this seemed like it would be useful, but only displays the default icon
    -- Get the action spell (what to cast now)
    -- local actionSpell = C_AssistedCombat.GetActionSpell()
    -- if actionSpell then
    --   rotation[index] = actionSpell
    --   index = index + 1
    -- end

    -- Get the next cast spell (what's coming next)
    local nextCastSpell = C_AssistedCombat.GetNextCastSpell()
    if nextCastSpell then
      rotation[index] = nextCastSpell
      index = index + 1
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
    end
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
  end
  return nil
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