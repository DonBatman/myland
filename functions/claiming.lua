myland.claiming = {}

function myland.claiming.get_player_count(name)
    local count = 0
    local all_data = myland.storage:to_table().fields
    for key, value in pairs(all_data) do
        if key:find(",") then
            local p = value:split("|")
            if p[1] == name then count = count + 1 end
        end
    end
    return count
end

function myland.claiming.get_player_claim_limit(name)
    if core.check_player_privs(name, {server = true}) then 
        return 100 
    end

    local base_limit = 10
    local level = 0

    if _G.myprogress and _G.myprogress.players and _G.myprogress.players[name] then
        level = _G.myprogress.players[name].blevel or 0
    end

    return base_limit + level
end
