local chunk_info = dofile(myland.modpath .. "/functions/pos_to_chunk.lua")

local function get_land_data(pos)
    if not pos then return nil, nil end
    local _, _, key = chunk_info(pos)
    local data = myland.storage:get_string(key)
    if not data or data == "" then return nil, key end
    return data:split("|"), key
end

core.register_chatcommand("claim", {
    func = function(name)
        local player = core.get_player_by_name(name)
        local pos = player:get_pos()
        local _, _, key = chunk_info(pos)
        
        local data = myland.storage:get_string(key)
        if data ~= "" then return false, "This vertical slice is already claimed." end

        local slice_center = math.floor(pos.y / 300) * 300
        local low = slice_center
        local high = slice_center + 299

        local new_data = table.concat({name, os.time(), "none", "0", ",", low, high}, "|")
        myland.storage:set_string(key, new_data)
        
        return true, "Claimed slice! (Y: " .. low .. " to " .. high .. ")"
    end,
})

core.register_chatcommand("unclaim", {
    func = function(name)
        local player = core.get_player_by_name(name)
        local parts, key = get_land_data(player:get_pos())
        if not parts or parts[1] ~= name then return false, "Not yours." end
        myland.storage:set_string(key, "")
        return true, "Land released."
    end,
})

core.register_chatcommand("trust", {
    params = "<name>",
    func = function(name, param)
        if param == "" then return false, "Usage: /trust <name>" end
        
        local auth = core.get_auth_handler().get_auth(param)
        if not auth then
            return false, "Player '" .. param .. "' has never joined this server."
        end

        local player = core.get_player_by_name(name)
        local parts, key = get_land_data(player:get_pos())
        
        if not parts or parts[1] ~= name then return false, "Not yours." end
        
        if parts[5]:find("," .. param .. ",") then 
            return false, param .. " is already trusted." 
        end
        
        parts[5] = parts[5] .. param .. ","
        myland.storage:set_string(key, table.concat(parts, "|"))
        return true, param .. " added to trusted list (even if offline)."
    end,
})

core.register_chatcommand("untrust", {
    params = "<name>",
    func = function(name, param)
        if param == "" then return false, "Usage: /untrust <name>" end
        
        local player = core.get_player_by_name(name)
        local parts, key = get_land_data(player:get_pos())
        
        if not parts or parts[1] ~= name then return false, "Not yours." end
        
        if not parts[5]:find("," .. param .. ",") then
            return false, param .. " was not on the trusted list."
        end
		if parts[5] == "," then parts[5] = "" end
        parts[5] = parts[5]:gsub("," .. param .. ",", ",")
        myland.storage:set_string(key, table.concat(parts, "|"))
        return true, param .. " removed from trusted list."
    end,
})

core.register_chatcommand("land_sell", {
    func = function(name, param)
        local price = tonumber(param) or 0
        local player = core.get_player_by_name(name)
        local parts, key = get_land_data(player:get_pos())
        if not parts or parts[1] ~= name then return false, "Not yours." end
        parts[4] = tostring(price)
        myland.storage:set_string(key, table.concat(parts, "|"))
        return true, "On sale for " .. price
    end,
})

core.register_chatcommand("buy_claim", {
    func = function(name)
        local player = core.get_player_by_name(name)
        local parts, key = get_land_data(player:get_pos())
        local price = tonumber(parts and parts[4]) or 0
        if price <= 0 then return false, "Not for sale." end
        parts[1], parts[4], parts[5] = name, "0", ","
        myland.storage:set_string(key, table.concat(parts, "|"))
        return true, "Purchased for " .. price
    end,
})

core.register_chatcommand("land_name", {
    func = function(name, param)
        local player = core.get_player_by_name(name)
        local parts, key = get_land_data(player:get_pos())
        if not parts or parts[1] ~= name then return false, "Not yours." end
        parts[3] = param:gsub("|", "")
        myland.storage:set_string(key, table.concat(parts, "|"))
        return true, "Renamed to " .. parts[3]
    end,
})

core.register_chatcommand("land_info", {
    func = function(name)
        local player = core.get_player_by_name(name)
        local parts, _ = get_land_data(player:get_pos())
        if not parts then return true, "Wilderness (Unclaimed)" end
        local trusted = parts[5]:gsub(",", " "):trim()
        local msg = "\nOwner: "..parts[1].."\nName: "..parts[3].."\nPrice: "..parts[4].."\nTrusted: "..(trusted ~= "" and trusted or "None")
        return true, msg
    end,
})

core.register_chatcommand("land_height", {
    func = function(name, param)
        local u, d = param:match("(%d+) (%d+)")
        if not u then return false, "Usage: /land_height <up> <down>" end
        local player = core.get_player_by_name(name)
        local ppos = player:get_pos()
        local parts, key = get_land_data(ppos)
        if not parts or parts[1] ~= name then return false, "Not yours." end
        parts[6] = math.floor(ppos.y - tonumber(d))
        parts[7] = math.floor(ppos.y + tonumber(u))
        myland.storage:set_string(key, table.concat(parts, "|"))
        return true, "Height updated: " .. parts[6] .. " to " .. parts[7]
    end,
})

core.register_chatcommand("my_claims", {
    func = function(name)
        local list = "Your Claims: "
        local fields = myland.storage:to_table().fields
        for k, v in pairs(fields) do
            if v:split("|")[1] == name then list = list .. "[" .. k .. "] " end
        end
        return true, list
    end,
})

core.register_chatcommand("land_give", {
    func = function(name, param)
        if param == "" then return false, "Usage: /land_give <name>" end
        local player = core.get_player_by_name(name)
        local parts, key = get_land_data(player:get_pos())
        if not parts or parts[1] ~= name then return false, "Not yours." end
        parts[1], parts[5] = param, ","
        myland.storage:set_string(key, table.concat(parts, "|"))
        return true, "Transferred to " .. param
    end,
})

core.register_chatcommand("admin_unclaim", {
    privs = {server = true},
    func = function(name)
        local player = core.get_player_by_name(name)
        local _, key = get_land_data(player:get_pos())
        myland.storage:set_string(key, "")
        return true, "Admin: Chunk cleared."
    end,
})

core.register_chatcommand("land_list", {
    privs = {server = true},
    func = function()
        local count = 0
        for _ in pairs(myland.storage:to_table().fields) do count = count + 1 end
        return true, "Total claims on server: " .. count
    end,
})

core.register_chatcommand("unclaim_all", {
    func = function(name, param)
        if param ~= "yes" then return false, "Warning! Type /unclaim_all yes" end
        local fields = myland.storage:to_table().fields
        for k, v in pairs(fields) do
            if v:split("|")[1] == name then myland.storage:set_string(k, "") end
        end
        return true, "All your claims have been cleared."
    end,
})

core.register_chatcommand("land_help", {
    description = "Show the full Land Protection guide.",
    func = function(name)
        local help_text = [[
=== CORE COMMANDS ===
/claim             - Claim the current 16x16 chunk.
/unclaim           - Release this chunk.
/land_info         - See owner, name, and protection Y-range.
/land_name <txt>   - Give your chunk a custom name.
/land_height <u d> - Set protection (e.g., 150 up, 50 down).
/my_claims         - List all chunks you own.
/unclaim_all       - Wipe ALL your claims (Caution!).

=== SOCIAL & ECONOMY ===
/trust <name>      - Give a player build access (works offline).
/untrust <name>    - Remove a player's access.
/trust_list        - See everyone trusted in this chunk.
/land_give <name>  - Transfer ownership to someone else.
/land_sell <price> - Put chunk on sale (0 to cancel).
/buy_claim         - Purchase a chunk that is for sale.

=== ADMIN TOOLS ===
/admin_show_claims - Visualize all nearby claims for 60s.
/admin_unclaim     - Forcefully clear any chunk.
/land_list         - Count total claims on the server.

TIP: Hold a STICK to see chunk borders and protection status!
]]

        local formspec = "size[8,8.5]" ..
            "background[0,0;8,8.5;gui_formbg.png;true]" ..
            "label[2.5,0.2;LAND PROTECTION MANUAL]" ..
            "textarea[0.5,0.8;7.5,7;help_text;;" .. core.formspec_escape(help_text) .. "]" ..
            "button_exit[3,7.8;2,0.8;quit;Close]"

        core.show_formspec(name, "myland:help", formspec)
        return true
    end,
})
core.register_chatcommand("trust_list", {
    description = "List all players trusted in this chunk.",
    func = function(name)
        local player = core.get_player_by_name(name)
        local parts, _ = get_land_data(player:get_pos())
        
        if not parts then return true, "This land is Wilderness." end

        local raw_list = parts[5] or ""
        
        local clean_list = raw_list:gsub("empty", ""):gsub("^,", ""):gsub(",$", ""):gsub(",", ", ")

        if clean_list:trim() == "" then
            return true, "No players are currently trusted in this chunk."
        end

        return true, "Players trusted in this chunk: " .. clean_list
    end,
})

core.register_chatcommand("admin_show_claims", {
    description = "Show 3D particle boundaries for all claims within 100 blocks.",
    privs = {server = true},
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then return end
        local pname = player:get_player_name()
        
        local seconds_left = 60
        local function show_loop()
            if seconds_left <= 0 then return end
            
            local ppos = player:get_pos()
            for x = -80, 80, 16 do
                for z = -80, 80, 16 do
                    local check_pos = {x = ppos.x + x, y = ppos.y, z = ppos.z + z}
                    local cx, cz, key = chunk_info(check_pos)
                    local data = myland.storage:get_string(key)
                    
                    if data ~= "" then
                        local parts = data:split("|")
                        local owner = parts[1]
                        local min_y = tonumber(parts[6]) or -31000
                        local max_y = tonumber(parts[7]) or 31000
                        
                        local particle_color = (owner == pname) and "#FFFF00" or "#FF5555"
                        
                        local x0, x1 = cx * 16 - 0.5, (cx * 16) + 15.5
                        local z0, z1 = cz * 16 - 0.5, (cz * 16) + 15.5
                        
                        for i = 0, 15, 4 do
                            local edge_points = {
                                {x=x0+i, z=z0}, {x=x1, z=z0+i}, 
                                {x=x1-i, z=z1}, {x=x0, z=z1-i}
                            }
                            
                            for _, p in ipairs(edge_points) do
                                if ppos.y >= min_y and ppos.y <= max_y then
                                    local sy = math.floor(ppos.y + 2)
                                    local count = 0
                                    while sy > ppos.y - 15 and core.get_node({x=p.x, y=sy, z=p.z}).name == "air" and count < 20 do
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
            end
            
            seconds_left = seconds_left - 1
            core.after(1, show_loop)
        end

        show_loop()
        return true, "Scanning 100-block radius. Claim boundaries visible for 60s."
    end,
})
