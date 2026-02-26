local addonName, addon = ...
local UILib = LibStub:NewLibrary("Blizzkili-UILib", 1)
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)
local ButtonLib = LibStub("Blizzkili-ButtonLib")
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local Debug = LibStub("Blizzkili-Debug")
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end
local info = function(msg) Debug.Info(Blizzkili.db.profile, msg) end
local trace = function(msg) Debug.Trace(Blizzkili.db.profile, msg) end
local FRAME_PADDING = 10 --Value for the moveable frame

local function validateLayout(layout)
  if layout == "horizontal" then
    return "right"
  elseif layout == "vertical" then
    return "down"
  end
    return layout or "right"
end

--Creates the parent frame
local function CreateMainFrame()
  local frame = CreateFrame("Frame", "BlizzkiliFrame", UIParent, "BackdropTemplate")
  frame:SetSize(200, 200)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  frame:SetMovable(true)
  frame:SetUserPlaced(true)
  frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  })
  frame:SetBackdropColor(0, 0, 0, 0.7)
  frame:SetBackdropBorderColor(1, 1, 1, 0)
  -- Register frame events
  frame:SetScript("OnMouseDown", function(self)
    if not self.isMoving and not Blizzkili.db.profile.lockFrames then
      self:StartMoving()
      self.isMoving = true
    end
  end)

  frame:SetScript("OnMouseUp", function(self)
    if self.isMoving then
      self:StopMovingOrSizing()
      self.isMoving = false

      -- Save new position
      local x, y = self:GetCenter()
      local parent = self:GetParent()
      if parent then
        local parentWidth = parent:GetWidth()
        local parentHeight = parent:GetHeight()
        Blizzkili.db.profile.position.x = x - parentWidth / 2
        Blizzkili.db.profile.position.y = y - parentHeight / 2
      end
    end
  end)

  frame:SetScript("OnHide", function(self)
    if self.isMoving then
      self:StopMovingOrSizing()
      self.isMoving = false
    end
  end)

  Blizzkili.frame = frame
end

local function GetValueForOrientation(layout, rightValue, leftValue, downValue, upValue)
  if layout == "right" then
    return rightValue
  elseif layout == "left" then
    return leftValue
  elseif layout == "down" then
    return downValue
  else
    return upValue
  end
end

local function CreateButtons()
  info("Creating buttons")
   -- Clean up existing buttons if they exist
  if Blizzkili.buttons then
    for _, button in ipairs(Blizzkili.buttons) do
      button:Hide()
      button:SetParent(nil)
    end
  end
  Blizzkili.buttons = {}
  local profile = Blizzkili.db.profile
  local mainScale = profile.mainScale or 1.2
  local numButtons = 10 --Alaways create 10 buttons and hide unused ones. This is to prevent taint issues with secure buttons being created/destroyed during combat.
  local buttonSize = profile.buttons.buttonSize or 40
  local buttonHeight = buttonSize
  local buttonWidth = buttonSize
  local buttonSpacing = profile.buttons.buttonSpacing or 5
  local layout = validateLayout(profile.buttons.layout)
  numButtons = numButtons - 1 -- account for main button

  --create first button
  local mainButton = ButtonLib.CreateButton(
    "BlizzkiliMainButton",
    Blizzkili.frame,
    "SecureActionButtonTemplate",
    buttonHeight * mainScale,
    buttonWidth * mainScale,
    GetValueForOrientation(layout, FRAME_PADDING, -1 * FRAME_PADDING, 0, 0),
    GetValueForOrientation(layout, 0, 0, -1 * FRAME_PADDING, FRAME_PADDING),
    GetValueForOrientation(layout, "LEFT", "RIGHT", "TOP", "BOTTOM"),
    GetValueForOrientation(layout, "LEFT", "RIGHT", "TOP", "BOTTOM")
  )
  ButtonLib.CreateGlow(mainButton, profile)

  ButtonLib.CreateKeybind(mainButton, mainScale, profile.keybind)
  -- ButtonLib.CreateStacks(mainButton, mainScale, profile.stacks)

  mainButton:Show()
  Blizzkili.buttons[1] = mainButton
  for i = 1, numButtons do
    local button = ButtonLib.CreateButton(
      "BlizzkiliButton" .. i,
       Blizzkili.buttons[i], -- parent is previous button for easy layout
      "SecureActionButtonTemplate",
      buttonHeight,
      buttonWidth,
      GetValueForOrientation(layout, buttonSpacing, -1 * buttonSpacing, 0, 0),
      GetValueForOrientation(layout, 0, 0, -1 * buttonSpacing, buttonSpacing),
      GetValueForOrientation(layout, "LEFT", "RIGHT", "TOP", "BOTTOM"),
      GetValueForOrientation(layout, "RIGHT", "LEFT", "BOTTOM", "TOP")
    )
    ButtonLib.CreateKeybind(button, 1, profile.keybind)
    -- ButtonLib.CreateStacks(button, 1, profile.stacks)
    if i <= profile.buttons.numButtons then
      trace("Showing button " .. i)
      button:Show()
    else
      trace("Hiding button " .. i)
      button:Hide()
    end
    Blizzkili.buttons[i + 1] = button
  end
end

function UILib.UpdateFramePosition()
  if not Blizzkili.frame or BlizzardAPI:InCombat() then return end
  info("Updating frame position")
  local profile = Blizzkili.db.profile
  Blizzkili.frame:SetPoint(profile.position.anchorPoint or "CENTER", UIParent, profile.position.parentAnchor or "CENTER", profile.position.x or 0, profile.position.y or 0)
  -- Blizzkili.frame:SetScale(Blizzkili.db.profile.scale)
  -- Blizzkili.frame:SetAlpha(Blizzkili.db.profile.alpha)
end

function UILib.UpdateFrameSize()
  info("Updating frame size")
  if not Blizzkili.frame then
    error("No frame found, cannot update frame size")
    return
  end
  local profile = Blizzkili.db.profile
  local mainScale = profile.mainScale or 1.2
  local buttonSize = profile.buttons.buttonSize or 40
  local buttonHeight = buttonSize
  local buttonWidth = buttonSize
  local buttonSpacing = profile.buttons.buttonSpacing or 5
  local layout = validateLayout(profile.buttons.layout)
  local numButtons = profile.buttons.numButtons or 5
  local additionalWidth, additionalHeight = 0, 0
  if layout == "right" or layout == "left" then
    additionalWidth = (buttonSize + buttonSpacing) * (numButtons-1)
  elseif layout == "down" or layout == "up" then
    additionalHeight = (buttonSize + buttonSpacing) * (numButtons-1)
  end
  local totalWidth = buttonWidth * mainScale + additionalWidth
  local totalHeight = buttonHeight * mainScale + additionalHeight
  if not BlizzardAPI:InCombat() then
    Blizzkili.frame:SetSize(totalWidth+ FRAME_PADDING*2, totalHeight + FRAME_PADDING*2) -- add some padding
  end
end

function UILib.CreateUI()
  info("Creating UI")
  -- Create the main frame
  CreateMainFrame()

  -- Create buttons and text
  CreateButtons()

  -- Set up the frame
  UILib.UpdateFramePosition()
  UILib.UpdateButtons()
end

function UILib.UpdateButtons()
  info("Updating buttons")
  local profile = Blizzkili.db.profile
  for i = 1, #Blizzkili.buttons do
    local button = Blizzkili.buttons[i]
    if button then
      if not BlizzardAPI:InCombat() then
        if i <= profile.buttons.numButtons then
          button:Show()
        else
          button:Hide()
        end
      end
      --update button size
      local buttonSize = profile.buttons.buttonSize or 40
      local mainScale = profile.mainScale or 1.2
      local buttonHeight = buttonSize
      local buttonWidth = buttonSize
      if i == 1 then
        if not BlizzardAPI:InCombat() then
          button:SetSize(buttonWidth * mainScale, buttonHeight * mainScale)
        end
        --update keybind
        ButtonLib.UpdateKeybind(button, mainScale, profile.keybind)
        ButtonLib.CreateGlow(button, profile)
         --update stacks
        if profile.display.glowMain ~= 0 then
          button.glow:Show()
        else
          button.glow:Hide()
        end
      else
        if not BlizzardAPI:InCombat() then
          button:SetSize(buttonWidth, buttonHeight)
        end
        ButtonLib.UpdateKeybind(button, 1, profile.keybind)
      end
      --update padding
      if not BlizzardAPI:InCombat() then
        local buttonSpacing = profile.buttons.buttonSpacing or 5
        local layout = validateLayout(profile.buttons.layout)
        local anchorPoint = GetValueForOrientation(layout, "LEFT", "RIGHT", "TOP", "BOTTOM")
        local parentAnchor = GetValueForOrientation(layout, "RIGHT", "LEFT", "BOTTOM", "TOP")
        local xPadding = GetValueForOrientation(layout, buttonSpacing, -1 * buttonSpacing, 0, 0)
        local yPadding = GetValueForOrientation(layout, 0, 0, -1 * buttonSpacing, buttonSpacing)
        if i == 1 then
          parentAnchor = GetValueForOrientation(layout, "LEFT", "RIGHT", "TOP", "BOTTOM")
          xPadding = GetValueForOrientation(layout, FRAME_PADDING, -1 * FRAME_PADDING, 0, 0)
          yPadding = GetValueForOrientation(layout, 0, 0, -1 * FRAME_PADDING, FRAME_PADDING)
        end
          button:ClearAllPoints()
          button:SetPoint(anchorPoint, button:GetParent(), parentAnchor, xPadding, yPadding)
        -- update zoom
        if profile.buttons.zoom then
          ButtonLib.ZoomButtonTexture(button, 0.08)
        else
          ButtonLib.ZoomButtonTexture(button, 0)
        end
      end
    end
  end
  UILib.UpdateFrameSize()
end