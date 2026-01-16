local chunk_info = dofile(myland.modpath .. "/functions/pos_to_chunk.lua")

core.register_node("myland:sale_sign", {
    description = "Land Sale Sign",
    drawtype = "nodebox",
    tiles = {"default_wood.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
            {-0.05, -0.5, 0.42, 0.05, 0.0, 0.48},
        },
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2},

    on_place = function(itemstack, placer, pointed_thing)
        local name = placer:get_player_name()
        local pos = pointed_thing.above
        
        local _, _, key = chunk_info(pos)
        local data = myland.storage:get_string(key)
        if data == "" or data:split("|")[1] ~= name then
            core.chat_send_player(name, "You can only place sale signs on your own land!")
            return itemstack 
        end
        
        local pos_str = pos.x .. "," .. pos.y .. "," .. pos.z
        core.show_formspec(name, "myland:set_price:" .. pos_str,
            "size[4,3]field[0.5,1;3,1;price;Set Price;]button_exit[1,2;2,1;ok;Done]")
            
        return core.item_place(itemstack, placer, pointed_thing)
    end,

    on_rightclick = function(pos, node, clicker, itemstack)
        local name = clicker:get_player_name()
        core.chat_send_player(name, "Use /buy_claim to purchase this property.")
    end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
    local pos_str = formname:match("myland:set_price:(.+)")
    if pos_str and (fields.ok or fields.key_enter == "true") then
        local name = player:get_player_name()
        local price = fields.price or "0"
        
        local cmd = core.registered_chatcommands["land_sell"]
        if cmd and cmd.func then
            local success, message = cmd.func(name, price)
            core.chat_send_player(name, message)
            
            if success then
                local p = core.string_to_pos(pos_str)
                local meta = core.get_meta(p)
                if tonumber(price) > 0 then
                    meta:set_string("infotext", "FOR SALE\nPrice: " .. price .. "g\nType /buy_claim to purchase")
                else
                    meta:set_string("infotext", "Land Not For Sale")
                end
            end
        end
    end
end)

core.register_craft({
    output = "myland:sale_sign",
    recipe = {
        {"group:wood", "group:wood", "group:wood"},
        {"group:wood", "default:gold_ingot", "group:wood"},
        {"", "group:stick", ""},
    }
})
