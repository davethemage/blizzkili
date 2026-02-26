-- debug.lua
local Debug = LibStub:NewLibrary("Blizzkili-Debug", 1)

function Debug.Print(printLevel, profile, prefix, msg)
  if printLevel <= profile.debugLevel then
    print(prefix .. " " .. msg)
  end
end
