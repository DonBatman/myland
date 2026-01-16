local CHUNK_SIZE = 16

local function chunk_info(pos)
    local cx = math.floor(pos.x / 16)
    local cz = math.floor(pos.z / 16)
    local cy = math.floor(pos.y / 300) 
    
    local key = cx .. "," .. cy .. "," .. cz
    return cx, cz, key
end
return chunk_info
