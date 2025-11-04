core.log("Computer id "..tostring(ID).." loaded!")
ROOT = WORLDPATH.."/computercraft/computer/"..tostring(ID).."/"
ROM_PATH = MODPATH.."/resources/rom/"


local blacklist = {
    ["core"] = true,
    ["minetest"] = true,
    ["WORLDPATH"] = true,
    ["MODPATH"] = true,
    ["ID"] = true,
    ["HELPER"] = true,
    ["io"] = true,
    ["os"] = true
} --this seems really fucking stupid but only way i know how to do it, feel free to improve it.

local vENV = {}

for i,v in pairs(_G) do
    if not blacklist[i] then
        vENV[i] = v
    end
end

function vENV.print(...)
    core.log(...)
end

vENV["fs"] = dofile(ROM_PATH.."fs.lua").init(ROOT)

if HELPER.fileExists(ROOT.."startup.lua") then
    core.log("startup is real")
    local func = loadfile(ROOT.."startup.lua", "t")
    setfenv(func, vENV)
    local succ, err = pcall(func)
    if not succ then core.log(err) end
end