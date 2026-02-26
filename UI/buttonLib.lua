-- ButtonLib.lua
local addonName, addon = ...
local ButtonLib = LibStub:NewLibrary("Blizzkili-ButtonLib", 1)
local LSM = LibStub("LibSharedMedia-3.0")
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local ActionBarScanner = LibStub("Blizzkili-ActionBarScanner")
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)
local Debug = LibStub("Blizzkili-Debug")
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end
local info= function(msg) Debug.Info(Blizzkili.db.profile, msg) end
local trace= function(msg) Debug.Trace(Blizzkili.db.profile, msg) end
-- Create a button with specified parameters
function ButtonLib.CreateButton(name, parent, template, height, width, xpadding, ypadding, parentAnchor, anchorPoint)
  trace("Creating button " .. name)
  local button = CreateFrame("Button", name, parent, template)
  button:SetSize(width, height)
  button:SetPoint(anchorPoint, parent, parentAnchor, xpadding, ypadding)
  return button
end

-- Create keybind text for a button
function ButtonLib.CreateKeybind(button, scale, profile)
  local keybind = button:CreateFontString(nil, "OVERLAY", nil)
  button.keybind = keybind
  ButtonLib.UpdateKeybind(button, scale, profile)
end

function ButtonLib.CreateGlow(button, profile)
  local isZoomed = profile.buttons.zoom
  local glow = button.glow
  if glow == nil then
    info("Creating glow for button " .. button:GetName())
    glow = button:CreateTexture(button:GetName().."Glow", "OVERLAY")
  end
  local extra = .10
  if isZoomed then
    extra = .15
  end

  glow:SetBlendMode("BLEND") -- harsh glow

  local atlas = "UI-HUD-RotationHelper-ProcAltGlow-2x"
  glow:SetDrawLayer("OVERLAY")
  if profile.display.glowMain == 1 then
    info("Using yellow glow")
    extra = extra - 0.05
    atlas = "UI-HUD-RotationHelper-ProcAltGlow-2x"
    glow:SetVertexColor(1,1,1,1) -- default white
  elseif profile.display.glowMain == 2 then
    info("Using blue glow")
    extra = extra - 0.01
    atlas = "RotationHelper_SmallAnts_1frame"
    glow:SetVertexColor(1,1,1,1) -- default white
  else --custom
    info("Using custom glow color")
    glow:SetDrawLayer("BORDER")
    -- extra = extra
    -- atlas = "plunderstorm-actionbar-slot-border-swappable"
    -- extra = extra + 0.15
    atlas = "loottoast-itemborder-glow"
    local glowColor = profile.display.glowColor or { r = 1, g = 1, b = 0, a = 1 }
    glow:SetVertexColor(glowColor.r, glowColor.g, glowColor.b, glowColor.a)
  end
  glow:SetAtlas(atlas)

  local size = button:GetWidth()
  extra = size * extra

  glow:SetPoint("TOPLEFT", button, -extra, extra)
  glow:SetPoint("BOTTOMRIGHT", button, extra, -extra)

  glow:Hide()

  button.glow = glow
end

function ButtonLib.UpdateKeybind(button, scale, profile)
  if button and button.keybind then
    local keybindFont = LSM:Fetch("font",profile.font or "Friz Quadrata TT")
    local fontSize = profile.size or 12
    local fontOutline = profile.outline or "OUTLINE"
    local color = profile.color or {1, 1, 1, 1}
    local xOffset = profile.xOffset or 0
    local yOffset = profile.yOffset or 0

    fontSize = fontSize * scale
    xOffset = xOffset * scale
    yOffset = yOffset * scale

    local parentAnchor = profile.parentAnchor or "CENTER"
    local anchorPoint = profile.anchorPoint or "CENTER"

    button.keybind:SetFont(keybindFont, fontSize, fontOutline)
    button.keybind:SetPoint(parentAnchor, button, anchorPoint, xOffset, yOffset)
    button.keybind:SetTextColor(color.r, color.g, color.b, color.a)
    if profile.enabled then
      trace("Showing keybind for button " .. button:GetName() .. " with text " .. tostring(button.keybind:GetText()))
      button.keybind:Show()
    else
      trace("Hiding keybind for button " .. button:GetName())
      button.keybind:Hide()
    end
  end
end

-- Create stacks text for a button
-- function ButtonLib.CreateStacks(button, scale, stacksProfile)
--   local stacksFont = LSM:Fetch("font",stacksProfile.font or "Friz Quadrata TT")
--   local fontSize = stacksProfile.size or 12
--   local color = stacksProfile.color or {1, 1, 1, 1}
--   local fontOutline = stacksProfile.outline or "OUTLINE"
--   local xOffset = stacksProfile.xOffset or -2
--   local yOffset = stacksProfile.yOffset or -2

--   fontSize = fontSize * scale
--   local parentAnchor = stacksProfile.parentAnchor or "BOTTOMRIGHT"
--   local anchorPoint = stacksProfile.anchorPoint or "BOTTOMRIGHT"

--   local stacks = button:CreateFontString(nil, "OVERLAY", nil)
--   stacks:SetFont(stacksFont, fontSize, fontOutline)
--   stacks:SetPoint(parentAnchor, button, anchorPoint, xOffset, yOffset)
--   stacks:SetTextColor(color.r, color.g, color.b, color.a)
--   button.stacks = stacks
-- end

-- Set keybind text for a button
function ButtonLib.SetKeybindText(button, text)
  if button.keybind then
    trace("Setting keybind text for button " .. button:GetName() .. " to " .. tostring(text))
    button.keybind:SetText(text)
  else
    error("No keybind found for button " .. button:GetName() .. ", cannot set keybind text")
  end
end

-- Set stacks text for a button
-- function ButtonLib.SetStacksText(button, text)
--   if button.stacks then
--     button.stacks:SetText(text)
--   end
-- end

function ButtonLib.ZoomButtonTexture(button, zoom)
  local tex = button:GetNormalTexture()
  if not tex then
    return
  end

  tex:SetTexCoord(zoom, 1 - zoom, zoom, 1 - zoom)
end

function ButtonLib.UpdateButton(button, spellId)
    if spellId then
        -- Get spell texture for the button
        local spellTexture = BlizzardAPI.GetSpellTexture(spellId)
        button.spellId = spellId -- Store spell ID on button for reference
        local keybind = ActionBarScanner:GetSpellKeybindsForId(spellId)
        ButtonLib.SetKeybindText(button, tostring(keybind)) -- Update keybind text
        button:SetNormalTexture(spellTexture)
        if not BlizzardAPI:InCombat() then
            button:Show()
        end
    else
        if not BlizzardAPI:InCombat() then
          button:Hide()
        end
    end
end