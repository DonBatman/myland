local chunk_info = dofile(myland.modpath .. "/functions/pos_to_chunk.lua")
local player_huds = {}

local function get_land_display_info(player_name, pos)
    local _, _, chunk_key = chunk_info(pos)
    local data = myland.storage:get_string(chunk_key) or ""
    
    local count = myland.claiming.get_player_count(player_name)
    local limit = myland.claiming.get_player_claim_limit(player_name)
    local count_str = "(" .. count .. "/" .. limit .. ")"

    if data == "" then 
        return "LAND: FREE " .. count_str, 0x00FF00 
    end

    local parts = data:split("|")
    local owner = parts[1]
    if owner == player_name then
        return "YOUR LAND " .. count_str, 0x00FFFF
    else
        return "OWNER: " .. owner:upper(), 0xFF5555
    end
end
local function update_hud(player)
    if not player or not player:is_player() then return end
    
    local name = player:get_player_name()
    if not player_huds[name] then
        player_huds[name] = {}
    end
    
    local huds = player_huds[name]
    local pos = player:get_pos()
    player_huds[name] = player_huds[name] or {}
    local huds = player_huds[name]

    local status_text, status_color = get_land_display_info(name, pos)
    local cx, cz, _ = chunk_info(pos)
    
    local start_y = -20
    if core.get_modpath("mymagic") then start_y = start_y - 20 end
    if core.get_modpath("myprogress") then start_y = start_y - 140 end

    local function set_h(id, text, color, off_y)
        if huds[id] then
            player:hud_change(huds[id], "text", text)
            player:hud_change(huds[id], "number", color)
            player:hud_change(huds[id], "offset", {x = 20, y = off_y})
        else
            huds[id] = player:hud_add({
                type = "text", 
                position = {x = 0, y = 1},
                offset = {x = 20, y = off_y}, 
                text = text,
                number = color, 
                alignment = {x = 1, y = -1},
            })
        end
    end

    set_h("status", status_text, status_color, start_y)
    set_h("coords", "CHUNK: "..cx..", "..cz, 0xAAAAAA, start_y - 20)
end

core.register_globalstep(function(dtime)
    for _, player in ipairs(core.get_connected_players()) do 
        update_hud(player) 
    end
end)

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_huds[name] = nil
end)
