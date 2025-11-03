core.register_node(MODID..":computer_normal", {
    description = "Computer",
    tiles = {
        "computer_normal_top.png",
        "computer_normal_bottom.png",
        "computer_normal_side.png",
        "computer_normal_side.png",
        "computer_normal_side.png",
        "computer_normal_front.png",
    },
    groups = {oddly_breakable_by_hand = 2},
    on_construct = function(pos)
        local computer = core.add_entity(pos, MODID..":computer_normal")
        computer = computer:get_luaentity()
        core.remove_node(pos)
    end,
})