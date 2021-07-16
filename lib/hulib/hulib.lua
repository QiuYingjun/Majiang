local split = require "lib.hulib.splitlib"
local special = require "lib.hulib.special"
local M = {}
function M.canHu(tiles, tile)
    if tile ~= nil then
        local cards = {0, 0, 0, 0, 0, 0, 0, 0, 0, -- 1-9万
        0, 0, 0, 0, 0, 0, 0, 0, 0, -- 1-9条
        0, 0, 0, 0, 0, 0, 0, 0, 0, -- 1-9筒
        0, 0, 0, 0, 0, 0, 0 -- 东南西北中发白
        }
        for _, t in pairs(tiles) do
            i = convert(t)
            cards[i] = cards[i] + 1
        end
        i = convert(tile)
        cards[i] = cards[i] + 1
        return split.get_hu_info(cards, 0) or special.is_7_dui(cards) or special.is_13_19(cards)
    end
    return false
end

function convert(tile)
    i = 0
    if tile.category == 'wan' then
        i = tile.number
    elseif tile.category == 'tiao' then
        i = 9 + tile.number
    elseif tile.category == 'bing' then
        i = 18 + tile.number
    elseif tile.category == 'dong' then
        i = 28
    elseif tile.category == 'nan' then
        i = 29
    elseif tile.category == 'xi' then
        i = 30
    elseif tile.category == 'bei' then
        i = 31
    elseif tile.category == 'zhong' then
        i = 32
    elseif tile.category == 'fa' then
        i = 33
    elseif tile.category == 'bai' then
        i = 34
    end
    return i
end
return M
