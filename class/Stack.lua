local Stack = Class()
local HONORS = {'dong', 'nan', 'xi', 'bei', 'zhong', 'fa', 'bai'}
function Stack:init()
    self.tiles = {}
    for id = 1, 136 do
        tile = nil
        if id <= 36 then
            tile = Tile(id, 'wan', 1 + (id - 1) % 9)
        elseif id <= 72 then
            tile = Tile(id, 'bing', 1 + (id - 1) % 9)
        elseif id <= 108 then
            tile = Tile(id, 'tiao', 1 + (id - 1) % 9)
        else
            tile = Tile(id, HONORS[math.floor((id - 108 - 0.5) / 4 + 1)], nil)
        end
        self.tiles[id] = tile
    end
end
function Stack:shuffle()
    math.randomseed(os.time())
    for i = #self.tiles, 2, -1 do
        local j = math.random(i)
        self.tiles[i], self.tiles[j] = self.tiles[j], self.tiles[i]
    end
end
function Stack:update(dt)
    for i, tile in ipairs(self.tiles) do
        tile.x = ((i - 1) % 8) * (TILE_WIDTH * TILE_SCALE - TILE_EDGE) + 800
        tile.y = math.floor((i - 1) / 8) * (TILE_HEIGHT * TILE_SCALE)
        tile:update(dt)
    end
end
function Stack:draw()
    if Game.CheatingMode then
        for i, tile in ipairs(self.tiles) do
            tile:draw()
        end
    end
    love.graphics.printf(#self.tiles, STATIC.FONT.MIDIUM, WINDOW_WIDTH - STATIC.FONT.MIDIUM:getWidth(#self.tiles),
        WINDOW_HEIGHT - STATIC.FONT.MIDIUM:getHeight(#self.tiles), STATIC.FONT.MIDIUM:getWidth(#self.tiles), 'right')
end
function Stack:mousereleased(x, y, button)
    for _, t in pairs(self.tiles) do
        t:mousereleased(x, y, button)
    end
end
return Stack
