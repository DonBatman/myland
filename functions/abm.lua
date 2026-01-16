local modname = "myland"
local storage = core.get_mod_storage()
local chunk_info = dofile(core.get_modpath(modname) .. "/functions/pos_to_chunk.lua")

local function positions_around(pos)
    return {
        {x = pos.x + 1, y = pos.y,     z = pos.z},
        {x = pos.x - 1, y = pos.y,     z = pos.z},
        {x = pos.x,     y = pos.y + 1, z = pos.z},
        {x = pos.x,     y = pos.y - 1, z = pos.z},
        {x = pos.x,     y = pos.y,     z = pos.z + 1},
        {x = pos.x,     y = pos.y,     z = pos.z - 1},
    }
end

core.register_abm({
    label = "Stop lava flow at borders",
    nodenames = {"default:lava_source", "default:lava_flowing"},
    neighbors = {"air", "group:igniter"}, 
    interval = 2,
    chance = 1,
    action = function(pos, node)
        local _, _, chunk_key = chunk_info(pos)
        local source_owner = storage:get_string(chunk_key) or ""

        for _, adj_pos in ipairs(positions_around(pos)) do
            local _, _, adj_chunk_key = chunk_info(adj_pos)
            local dest_owner = storage:get_string(adj_chunk_key) or ""
            
            if dest_owner ~= "" and dest_owner ~= source_owner then
                local adj_node = core.get_node(adj_pos)
                if adj_node.name ~= "default:lava_source" and adj_node.name ~= "default:lava_flowing" then
                    core.set_node(pos, {name = "default:stone"})
                    return
                end
            end
        end
    end,
})

core.register_abm({
    label = "Stop water flow at borders",
    nodenames = {"default:water_source", "default:water_flowing"},
    neighbors = {"air", "group:liquid"},
    interval = 2,
    chance = 1,
    action = function(pos, node)
        local _, _, chunk_key = chunk_info(pos)
        local source_owner = storage:get_string(chunk_key) or ""

        for _, adj_pos in ipairs(positions_around(pos)) do
            local _, _, adj_chunk_key = chunk_info(adj_pos)
            local dest_owner = storage:get_string(adj_chunk_key) or ""
            
            if dest_owner ~= "" and dest_owner ~= source_owner then
                local adj_node = core.get_node(adj_pos)
                if adj_node.name ~= "default:water_source" and adj_node.name ~= "default:water_flowing" then
                    core.set_node(pos, {name = "default:dirt"})
                    return
                end
            end
        end
    end,
})

core.register_abm({
    label = "Stop fire spread at borders",
    nodenames = {"fire:basic_flame"},
    neighbors = {"air", "group:flammable"},
    interval = 1,
    chance = 1,
    action = function(pos, node)
        local _, _, chunk_key = chunk_info(pos)
        local source_owner = storage:get_string(chunk_key) or ""

        for _, adj_pos in ipairs(positions_around(pos)) do
            local _, _, adj_chunk_key = chunk_info(adj_pos)
            local dest_owner = storage:get_string(adj_chunk_key) or ""

            if dest_owner ~= "" and dest_owner ~= source_owner then
                local adj_node = core.get_node(adj_pos)
                if adj_node.name ~= "fire:basic_flame" then
                    core.remove_node(pos)
                    return
                end
            end
        end
    end,
})
