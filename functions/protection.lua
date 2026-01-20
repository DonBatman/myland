local chunk_info = dofile(myland.modpath .. "/functions/pos_to_chunk.lua")

function myland.is_protected_at_pos(pos, name)
    if not pos then return false end
    local _, _, key = chunk_info(pos)
    local data = myland.storage:get_string(key)
    
    if not data or data == "" then return false end

    local parts = data:split("|")
    local min_y, max_y = tonumber(parts[6]), tonumber(parts[7])
    
    if min_y and max_y and pos.y >= min_y and pos.y <= max_y then
        local owner = parts[1]
        local trusted = parts[5] or ""
        
        if name and (owner == name or trusted:find(name)) then
            return false
        end
        return true
    end
    return false
end

local old_is_protected = core.is_protected
function core.is_protected(pos, name)
    if myland.is_protected_at_pos(pos, name) then
        return true
    end
    return old_is_protected(pos, name)
end

core.register_on_liquid_transformed(function(pos_list)
    for _, pos in ipairs(pos_list) do
        if myland.is_protected_at_pos(pos, nil) then 
            core.set_node(pos, {name="air"}) 
        end
    end
end)

core.register_on_mods_loaded(function()
    for name, def in pairs(core.registered_nodes) do
        local overrides = {}
        
        local old_on_blast = def.on_blast
        overrides.on_blast = function(pos, intensity)
            if myland.is_protected_at_pos(pos, nil) then
                return {name} 
            end
            if old_on_blast then return old_on_blast(pos, intensity) end
        end

        if def.groups and (def.groups.flammable or def.groups.choppy) then
            local old_on_burn = def.on_burn
            overrides.on_burn = function(pos)
                if myland.is_protected_at_pos(pos, nil) then return end
                if old_on_burn then return old_on_burn(pos) end
            end
        end

        core.override_item(name, overrides)
    end
end)

-- Only register the MVPS stopper if the mesecons table actually exists
if core.get_modpath("mesecons_mvps") and mesecons and mesecons.register_mvps_stopper then
    mesecons.register_mvps_stopper(function(pos, node)
        return myland.is_protected_at_pos(pos, nil)
    end)
end

core.register_on_punchnode(function(pos, node, puncher)
    if not puncher or not puncher:is_player() then return end
    local name = puncher:get_player_name()
    local item = puncher:get_wielded_item():get_name()
    
    if item:find("screwdriver") or item:find("wrench") or item:find("hammer") or item:find("bucket") then
        if myland.is_protected_at_pos(pos, name) then
            core.chat_send_player(name, "Claimed area: Interaction blocked.")
            return true
        end
    end
end)
core.register_chatcommand("cf", {
    description = "Clears all fire in a 50-node radius",
    privs = {interact = true},
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then return end
        local ppos = player:get_pos()
        local fires = core.find_nodes_in_area(
            {x=ppos.x-50, y=ppos.y-50, z=ppos.z-50},
            {x=ppos.x+50, y=ppos.y+50, z=ppos.z+50},
            {"fire:basic_flame", "fire:permanent_fire", "fire:basic_fire"}
        )
        for _, fpos in ipairs(fires) do
            core.set_node(fpos, {name="air"})
        end
        return true, "Extinguished " .. #fires .. " fire nodes."
    end,
})

core.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    if newnode.name:find("fire:basic_flame") or newnode.name:find("fire:permanent_fire") then
        if myland.is_protected_at_pos(pos, nil) then
            core.set_node(pos, {name = "air"})
        end
    end
end)
if core.registered_nodes["fire:basic_flame"] then
    core.override_item("fire:basic_flame", {
        on_construct = function(pos)
            if myland.is_protected_at_pos(pos, nil) then
                core.remove_node(pos)
            end
        end
    })
end
