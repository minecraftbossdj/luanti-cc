
local FORMNAME_TURTLE_INVENTORY = "computertest:turtle:inventory:"
local FORMNAME_TURTLE_NOPRIV    = "computertest:turtle:nopriv:"
local FORMNAME_TURTLE_TERMINAL  = "computertest:turtle:terminal:"
local FORMNAME_TURTLE_UPLOAD    = "computertest:turtle:upload:"

local FORM_NOPRIV = "size[9,1;]label[0,0;You do not have the 'computertest' privilege.\nThis is required for interacting with turtles.]";

local TURTLE_INVENTORYSIZE = 4*4

---@returns TurtleEntity of that ID
local function getTurtle(id) return computertest.turtles[id] end
---@returns true
local function isValidInventoryIndex(index) return 0 < index and index <= TURTLE_INVENTORYSIZE end
local function has_computertest_priv(player) return minetest.check_player_privs(player,"computertest") end
---@param item string
---@param filterList table of strings
---@param isWhitelist boolean true=whitelist filtering, false=blacklist filtering
---@return boolean true if item in filter
local function infilter(item, filterList, isWhitelist)
    for _, filterItemname in pairs(filterList) do
        local isInGroup = minetest.get_item_group(item, filterItemname)
        if item== filterItemname or (isInGroup ~= 0 and isInGroup ~= nil) then
            return isWhitelist
        end
    end
    return not isWhitelist
end
-- advtrains inventory serialization helper (c) 2017 orwell96
local function serializeInventory(inv)
    local data = {}
    for listName, listStack in pairs(inv:get_lists()) do
        data[listName]={}
        for index, item in ipairs(listStack) do
            local itemString =item:to_string()
            data[listName][index] = itemString
        end
    end
    return minetest.serialize(data)
end
local function deserializeInventory(inv, str)
    local data = minetest.deserialize(str)
    if data then
        inv:set_lists(data)
        return true
    end
    return false
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local function isForm(name)
        return string.sub(formname,1,string.len(name))==name
    end
    --minetest.debug("FORM SUBMITTED",dump(player),dump(formname),dump(fields))
    if isForm(FORMNAME_TURTLE_INVENTORY) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_INVENTORY)))
        local turtle = getTurtle(id)
        if fields.upload_code=="Upload Code" then
            minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_UPLOAD..id,turtle:get_formspec_upload());
        elseif fields.open_terminal=="Open Terminal" then
            minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
        elseif fields.factory_reset=="Factory Reset" then
            return not turtle:upload_code_to_turtle(player,"",false)
        end
    elseif isForm(FORMNAME_TURTLE_TERMINAL) then
        if fields.terminal_out ~= nil then
            return true
        end
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_TERMINAL)))
        local turtle = getTurtle(id)
        turtle.lastCommandRan = fields.terminal_in
        local command = fields.terminal_in
        if command==nil or command=="" then
            return nil
        end
        command = "function init(turtle) return "..command.." end"
        local commandResult = turtle:upload_code_to_turtle(player,command, true)
        if commandResult == nil then
            minetest.close_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id)
            return true
        end
        commandResult = fields.terminal_in.." -> "..commandResult
        turtle.previous_answers[#turtle.previous_answers+1] = commandResult
        minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
    elseif isForm(FORMNAME_TURTLE_UPLOAD) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_UPLOAD)))
        if fields.button_upload == nil or fields.upload == nil then
            return true
        end
        local turtle = getTurtle(id)
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
        active = false
    },
}

function ComputerNormalEntity:on_activate(staticdata, dtime_s)
    local data = core.deserialize(staticdata)
    if type(data) ~= "table" or not data.complete then data = {} end

    self.id = #COMPUTERS + 1
    self.name = data.name or "Computer #"..self.id
    self.coroutine = data.coroutine or nil
    self.active = true

    COMPUTERS[self.id] = self
    
end

function ComputerNormalEntity:get_staticdata()
    core.debug("Serializing computer "..self.name)
    return core.serialize({
        id = self.id,
        name = self.name,
        coroutine = nil,--self.coroutine,
        complete = true,
    })
end

function ComputerNormalEntity:yield(reason,useFuel)
    -- Yield at least once
    if coroutine.running() == self.coroutine then
        coroutine.yield(reason)
    end
end


core.register_entity(MODID..":computer_normal", ComputerNormalEntity)