core.log("Computer id "..tostring(ID).." loaded!")
ROOT = WORLDPATH.."/computercraft/computer/"..tostring(ID).."/"
ROM_PATH = MODPATH.."/resources/rom/"

local vENV = {}

function vENV.print(...)
    core.log(...)
end

if HELPER.fileExists(ROOT.."startup.lua") then
    local func = loadfile(ROOT.."startup.lua", "t")
    setfenv(func, vENV)
    func()
end