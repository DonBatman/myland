local chunk_info = dofile(myland.modpath .. "/functions/pos_to_chunk.lua")

core.register_globalstep(function(dtime)
    for _, player in ipairs(core.get_connected_players()) do
        if player:get_wielded_item():get_name() == "default:stick" then
            local pos = player:get_pos()
            local cx, cz, key = chunk_info(pos)
            local data = myland.storage:get_string(key)
            local show_fence = true 
            local particle_color = "#00FFFF"

            if data ~= "" then
                local parts = data:split("|")
                local owner = parts[1]
                local min_y = tonumber(parts[6]) or -31000
                local max_y = tonumber(parts[7]) or 31000
                
                if owner == player:get_player_name() then
                    particle_color = "#FFFF00"
                else
                    particle_color = "#FF5555"
                end

                if pos.y < min_y or pos.y > max_y then
                    particle_color = "#00FFFF"
                end
            end

            if show_fence then
                local x0, x1 = cx * 16 - 0.5, (cx * 16) + 15.5
                local z0, z1 = cz * 16 - 0.5, (cz * 16) + 15.5
                
                for i = 0, 15, 4 do
                    local edge_points = {
                        {x=x0+i, z=z0}, {x=x1, z=z0+i}, 
                        {x=x1-i, z=z1}, {x=x0, z=z1-i}
                    }
                    for _, p in ipairs(edge_points) do
                        local sy = math.floor(pos.y + 2)
                        local count = 0
                        while sy > pos.y - 15 and core.get_node({x=p.x, y=sy, z=p.z}).name == "air" and count < 20 do
                            sy = sy - 1
                            count = count + 1
                        end
                        
                        core.add_particle({
                            pos = {x=p.x, y=sy + 0.8, z=p.z},
                            velocity = {x=0, y=1.2, z=0},
                            expirationtime = 1.0,
                            size = 4,
                            glow = 14,
                            texture = "heart.png^[colorize:" .. particle_color .. ":150",
                        })
                    end
                end
            end
        end
    end
end)

local function run_cleanup_task()
    if not myland.expiry_days or myland.expiry_days <= 0 then return end
    local all_data = myland.storage:to_table().fields
    local now = os.time()
    local expiry_seconds = myland.expiry_days * 24 * 60 * 60 
    local count = 0

    for key, data in pairs(all_data) do
        if key:find(",") then
            local parts = data:split("|")
            local last_active = tonumber(parts[2]) or 0
            if last_active > 0 and (now - last_active) > expiry_seconds then
                myland.storage:set_string(key, "")
                count = count + 1
            end
        end
    end
    if count > 0 then core.log("action", "[MyLand] Cleaned " .. count .. " expired claims.") end
end

local cleanup_timer = 0
core.register_globalstep(function(dtime)
    cleanup_timer = cleanup_timer + dtime
    if cleanup_timer > 1800 then
        run_cleanup_task()
        cleanup_timer = 0
    end
end)
