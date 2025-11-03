
local FORMNAME_TURTLE_INVENTORY = "computertest:turtle:inventory:"
local FORMNAME_TURTLE_TERMINAL  = "computertest:turtle:terminal:"
local FORMNAME_TURTLE_UPLOAD    = "computertest:turtle:upload:"

core.register_on_player_receive_fields(function(player, formname, fields)
    local function isForm(name)
        return string.sub(formname,1,string.len(name))==name
    end
    --core.debug("FORM SUBMITTED",dump(player),dump(formname),dump(fields))
    if isForm(FORMNAME_TURTLE_INVENTORY) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_INVENTORY)))
        if fields.upload_code=="Upload Code" then
            core.show_formspec(player:get_player_name(),FORMNAME_TURTLE_UPLOAD..id,turtle:get_formspec_upload());
        elseif fields.open_terminal=="Open Terminal" then
            core.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
        elseif fields.factory_reset=="Factory Reset" then
            return not turtle:upload_code_to_turtle(player,"",false)
        end
    elseif isForm(FORMNAME_TURTLE_TERMINAL) then
        if fields.terminal_out ~= nil then
            return true
        end
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_TERMINAL)))
        turtle.lastCommandRan = fields.terminal_in
        local command = fields.terminal_in
        if command==nil or command=="" then
            return nil
        end
        command = "function init(turtle) return "..command.." end"
        local commandResult = turtle:upload_code_to_turtle(player,command, true)
        if commandResult == nil then
            core.close_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id)
            return true
        end
        commandResult = fields.terminal_in.." -> "..commandResult
        turtle.previous_answers[#turtle.previous_answers+1] = commandResult
        core.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
    elseif isForm(FORMNAME_TURTLE_UPLOAD) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_UPLOAD)))
        if fields.button_upload == nil or fields.upload == nil then
            return true
        end
        return not turtle:upload_code_to_turtle(player,fields.upload,false)
    else
        return false--Unknown formname, input not processed
    end
    return true--Known formname, input processed "If function returns `true`, remaining functions are not called"
end)

local ComputerNormalEntity = {
    initial_properties = {
        hp_max = 999,
        is_visible = true,
        makes_footstep_sound = false,
        physical = true,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        visual = "cube",
        visual_size = { x = 1, y = 1 },
        static_save = true,
        textures = {
            "computer_normal_top.png",
            "computer_normal_bottom.png",
            "computer_normal_side.png",
            "computer_normal_side.png",
            "computer_normal_side.png",
            "computer_normal_front.png",
        },
        automatic_rotate = 0,
        id = -1,
    },
}

function ComputerNormalEntity:on_activate(staticdata, dtime_s)
    local data = core.deserialize(staticdata)
    if type(data) ~= "table" or not data.complete then data = {} end

    self.id = data.id or #COMPUTERS + 1
    self.name = data.name or "Computer #"..self.id
    self.coroutine = data.coroutine or nil

    COMPUTERS[self.id] = self
    if not HELPER.dirExists(WORLDPATH.."/computercraft/computer") then
        core.mkdir(WORLDPATH.."/computercraft/computer")
    end
    if not HELPER.dirExists(WORLDPATH.."/computercraft/computer/"..tostring(self.id)) then
        core.mkdir(WORLDPATH.."/computercraft/computer/"..tostring(self.id))
    end

    local vENV = {core = core, ID = self.id, tostring = tostring, WORLDPATH = WORLDPATH, MODPATH = MODPATH, HELPER = HELPER}

    local func = loadfile(MODPATH.."/resources/init.lua","t")
    setfenv(func,vENV)
    func()
end

function ComputerNormalEntity:get_staticdata()
    core.debug("Serializing computer "..self.name)
    return core.serialize({
        id = self.id,
        name = self.name,
        coroutine = nil,--self.coroutine,
    })
end

function ComputerNormalEntity:yield(reason)
    -- Yield at least once
    if coroutine.running() == self.coroutine then
        coroutine.yield(reason)
    end
end


core.register_entity(MODID..":computer_normal", ComputerNormalEntity)