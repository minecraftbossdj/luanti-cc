MODID = "cc_reimagined"

MODPATH = core.get_modpath("cc_reimagined")
WORLDPATH = core.get_worldpath()

dofile(MODPATH.."/block/computer_normal.lua")
dofile(MODPATH.."/entity/computer_normal.lua")


HELPER =  {}
COMPUTERS = {}

function HELPER.fileExists(file_path)
    local file = io.open(WORLDPATH..file_path,"r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

function HELPER.dirExists(directory_path)
    local file = io.open(WORLDPATH..directory_path.."/temp.txt","w")
    if file then
        file:close()
        os.remove(WORLDPATH..directory_path.."/temp.txt")
        return true
    else
        return false
    end
end

if not HELPER.dirExists("/computercraft") then
    core.log("Computercraft directory does not exist!")
    core.mkdir(WORLDPATH.."/computercraft")
    local computer_ids_file = io.open(WORLDPATH.."/computercraft/computers.json","w")
    local data = {
        next_id = 0
    }
    local data_json = core.write_json(data)
    computer_ids_file:write(data_json)
    computer_ids_file:close()
else
    core.log("Computercraft directory exists!")
end