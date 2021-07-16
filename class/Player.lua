local hulib = require "lib.hulib.hulib"

local Player = Class()
function Player:init(id, name, isHuman)
    self.name = name
    self.id = id
    self.isHuman = isHuman
    self.tiles = {}
    self.newTile = nil
    self.groups = {}
    self.disTiles = {}
    self.nextPlayer = nil
    self.buttons = {}
    self.readyTo = {}
    self.skipTile = nil
    self.lastCurrentUser = nil
    self.lastCurrentState = nil
    self.gang_selections = {}
    self.chi_selections = {}
    self.refresh = false
    self.point = 1000
    for i = 1, 8 do
        table.insert(self.buttons, Button(0, 0, STATIC.FONT.SMALL, i, self))
    end
end
function Player:reset()
    self.tiles = {}
    self.newTile = nil
    self.groups = {}
    self.disTiles = {}
    self.readyTo = {}
    self.skipTile = nil
    self.lastCurrentUser = nil
    self.lastCurrentState = nil
    self.gang_selections = {}
    self.chi_selections = {}
    self.refresh = false
end
function Player:pick(isInit)
    if #Game.Stack.tiles > 0 then
        local tile = table.remove(Game.Stack.tiles, 1)
        tile.belongTo = self
        tile.belongToOld = self
        if isInit then
            table.insert(self.tiles, tile)
        else
            self.newTile = tile
        end
    end
end

function Player:sortTiles()
    table.sort(self.tiles, compare)
end

function compare(tile1, tile2)
    if tile1.category == tile2.category and tile1.number ~= nil and tile2.number ~= nil then
        return tile1.number < tile2.number
    end
    return tile1.id < tile2.id
end

function Player:canPeng(tile)
    local holding = 0
    if tile and tile.belongTo ~= self then
        for _, t in pairs(self.tiles) do
            if t.category == tile.category and t.number == tile.number then
                holding = holding + 1
            end
        end
        return holding >= 2
    end
    return false
end
function Player:doPeng(tile)
    local group = {}
    for i = #self.tiles, 1, -1 do
        local t = self.tiles[i]
        if t.category == tile.category and t.number == tile.number then
            if #group < 2 then
                table.insert(group, table.remove(self.tiles, i))
            end
        end
    end
    tile.belongTo = self
    table.insert(group, tile)
    table.insert(self.groups, group)
    love.audio.play(STATIC.SOUND.PENG)
end
function Player:canGang(tile)
    if #Game.Stack.tiles == 0 then
        return false
    end
    self.gang_selections = {}
    local holding = {} -- 手牌
    local holding2 = {} -- 已碰的牌

    -- 检查手牌
    for _, t in pairs(self.tiles) do
        holding[t.name] = holding[t.name] or {}
        table.insert(holding[t.name], t)
    end
    -- 已碰过的牌凑成杠
    for _, group in pairs(self.groups) do
        if #group == 3 and group[1].name == group[2].name and group[2].name == group[3].name then
            holding2[group[1].name] = group
        end
    end

    if tile then
        -- 新摸时，检查新摸、手牌、已碰牌
        if tile.belongTo == self then
            holding[tile.name] = holding[tile.name] or {}
            table.insert(holding[tile.name], tile)
            if holding2[tile.name] ~= nil and #holding2[tile.name] == 3 then
                table.insert(self.gang_selections, {tile})
            end
            for _, t in pairs(self.tiles) do
                if holding2[t.name] ~= nil and #holding2[t.name] == 3 then
                    table.insert(self.gang_selections, {t})
                end
            end
            for name, g in pairs(holding) do
                if #g == 4 then
                    table.insert(self.gang_selections, g)
                end
            end
        else
            -- 别人打出时，只检查手牌
            if holding[tile.name] ~= nil and #holding[tile.name] == 3 then
                table.insert(self.gang_selections, holding[tile.name])
            end
        end
    end
    return #self.gang_selections > 0
end
function Player:doGang(tile)
    if #self.gang_selections == 1 then
        if #self.gang_selections[1] == 4 then
            table.insert(self.groups, self.gang_selections[1])
        elseif #self.gang_selections[1] == 3 then
            tile.belongTo = self
            table.insert(self.gang_selections[1], tile)
            table.insert(self.groups, self.gang_selections[1])
        elseif #self.gang_selections[1] == 1 then
            local t = self.gang_selections[1][1]
            for _, group in pairs(self.groups) do
                if group[1].name == t.name then
                    table.insert(group, t)
                    break
                end
            end
        end
        self:removeFromTiles(self.gang_selections[1][1].name, 4)
        if tile == self.newTile and self.newTile ~= nil then
            self.newTile.group_focus = false
            if self.newTile.name ~= self.gang_selections[1][1].name then
                table.insert(self.tiles, self.newTile)
            end
            self.newTile = nil
        end
        self:sortTiles()
        self.gang_selections = {}
        Game.CurrentPlayer = self
        Game.CurrentState = PLAYER_STATE.READY
        Game.LastTile = nil
        self.refresh = true
        love.audio.play(STATIC.SOUND.GANG)
    elseif #self.gang_selections > 0 then
        Game.CurrentState = PLAYER_STATE.SELECT_GANG
    end
end
function Player:removeFromTiles(name, count)
    for i = #self.tiles, 1, -1 do
        if self.tiles[i].name == name and count > 0 then
            self.tiles[i].group_focus = false
            table.remove(self.tiles, i)
            count = count - 1
        end
    end
end
function Player:canChi(tile)
    local result = false
    if tile and self == tile.belongTo.nextPlayer and tile.number ~= nil then
        local sameCat = {}
        for _, t in pairs(self.tiles) do
            if t.category == tile.category and math.abs(t.number - tile.number) <= 2 then
                sameCat[t.number] = sameCat[t.number] or t
            end
        end
        self.chi_selections = {}
        if sameCat[tile.number - 2] ~= nil and sameCat[tile.number - 1] ~= nil then
            table.insert(self.chi_selections, {sameCat[tile.number - 2], sameCat[tile.number - 1]})
            result = true
        end
        if sameCat[tile.number - 1] ~= nil and sameCat[tile.number + 1] ~= nil then
            table.insert(self.chi_selections, {sameCat[tile.number - 1], sameCat[tile.number + 1]})
            result = true
        end
        if sameCat[tile.number + 1] ~= nil and sameCat[tile.number + 2] ~= nil then
            table.insert(self.chi_selections, {sameCat[tile.number + 1], sameCat[tile.number + 2]})
            result = true
        end
    end
    return result
end
function Player:doChi(tile)
    if #self.chi_selections == 1 then
        local group = self.chi_selections[1]
        tile.belongTo = self
        for i = #self.tiles, 1, -1 do
            if self.tiles[i] == group[1] or self.tiles[i] == group[2] then
                self.tiles[i].group_focus = false
                table.remove(self.tiles, i)
            end
        end
        table.insert(group, tile)
        table.sort(group, compare)
        table.insert(self.groups, group)
        self.chi_selections = {}
        Game.CurrentPlayer = self
        Game.CurrentState = PLAYER_STATE.PLAYING
        Game.LastTile = nil
        love.audio.play(STATIC.SOUND.CHI)
    elseif #self.chi_selections > 1 then
        Game.CurrentState = PLAYER_STATE.SELECT_CHI
    end
end
function Player:canHu(tile)
    return hulib.canHu(self.tiles, tile)
end
function Player:doHu(tile)
    if tile.belongTo == self then
        -- 自摸胡
        for _, p in pairs(Game.Players) do
            if p ~= self then
                p.point = p.point - 100
                self.point = self.point + 100
            end
        end
    else
        tile.belongTo.point = tile.belongTo.point - 200
        self.point = self.point + 200
    end
    love.audio.play(STATIC.SOUND.HU)
end
function Player:update(dt)
    for _, t in pairs(self.disTiles) do
        t.open = true
    end

    for i, tile in ipairs(self.tiles) do
        tile.group_focus = false
    end
    if self.newTile then
        self.newTile.group_focus = false
    end
    for i, tile in ipairs(self.tiles) do
        tile:update(dt)
    end
    if self.newTile then
        self.newTile:update(dt)
    end

    if self.lastCurrentUser ~= Game.CurrentPlayer or self.lastCurrentState ~= Game.CurrentState or Game.CurrentState ==
        PLAYER_STATE.OVER or self.refresh then
        self.refresh = false
        if Game.CurrentPlayer == self then
            if Game.CurrentState == PLAYER_STATE.FINISH then
                self.readyTo[OPERATION.RESET] = true
                self.readyTo[OPERATION.MO] = false
                self.readyTo[OPERATION.CHI] = false
                self.readyTo[OPERATION.GANG] = false
                self.readyTo[OPERATION.PENG] = false
                self.readyTo[OPERATION.HU] = false
                self.readyTo[OPERATION.SKIP] = false
            elseif Game.CurrentState == PLAYER_STATE.READY then
                self.readyTo[OPERATION.MO] = (Game.LastTile == nil or Game.LastTile.belongTo.nextPlayer == self) and
                                                 #Game.Stack.tiles > 0
                self.readyTo[OPERATION.CHI] = self.skipTile ~= Game.LastTile and self:canChi(Game.LastTile)
                self.readyTo[OPERATION.GANG] = self.skipTile ~= Game.LastTile and self:canGang(Game.LastTile)
                self.readyTo[OPERATION.PENG] = self.skipTile ~= Game.LastTile and self:canPeng(Game.LastTile)
                self.readyTo[OPERATION.HU] = self.skipTile ~= Game.LastTile and self:canHu(Game.LastTile)
                self.readyTo[OPERATION.SKIP] = not self.readyTo[OPERATION.MO] and
                                                   (self.readyTo[OPERATION.GANG] or self.readyTo[OPERATION.PENG] or
                                                       self.readyTo[OPERATION.HU])
            elseif Game.CurrentState == PLAYER_STATE.PLAYING then
                self.readyTo[OPERATION.MO] = false
                self.readyTo[OPERATION.CHI] = false
                self.readyTo[OPERATION.PENG] = false
                self.readyTo[OPERATION.HU] = self:canHu(self.newTile)
                self.readyTo[OPERATION.GANG] = self:canGang(self.newTile)
                self.readyTo[OPERATION.SKIP] = false
            else
                self.readyTo[OPERATION.MO] = false
                self.readyTo[OPERATION.CHI] = false
                self.readyTo[OPERATION.PENG] = false
                self.readyTo[OPERATION.GANG] = false
                self.readyTo[OPERATION.HU] = false
                self.readyTo[OPERATION.SKIP] = false
            end
        elseif Game.CurrentPlayer then
            self.readyTo[OPERATION.MO] = self == Game.CurrentPlayer.nextPlayer and Game.CurrentState ~=
                                             PLAYER_STATE.PLAYING
            self.readyTo[OPERATION.CHI] = self.skipTile ~= Game.LastTile and self:canChi(Game.LastTile)
            self.readyTo[OPERATION.GANG] = self.skipTile ~= Game.LastTile and self:canGang(Game.LastTile)
            self.readyTo[OPERATION.PENG] = self.skipTile ~= Game.LastTile and self:canPeng(Game.LastTile)
            self.readyTo[OPERATION.HU] = self.skipTile ~= Game.LastTile and self:canHu(Game.LastTile)
            self.readyTo[OPERATION.SKIP] = false
        end

        self.lastCurrentState = Game.CurrentState
        self.lastCurrentUser = Game.CurrentPlayer
        print(self)
    end

    for _, button in pairs(self.buttons) do
        button.show = self.readyTo[button.operation] and Game.CurrentPlayer == self
        button:update(dt)
    end
end

function Player:draw()
    local labelWidth = STATIC.FONT.SMALL:getWidth(self.name)
    local startX = labelWidth
    local startY = (self.id - 1) * WINDOW_HEIGHT / 4
    local width = TILE_WIDTH * TILE_SCALE - TILE_EDGE
    local height = TILE_HEIGHT * TILE_SCALE
    -- 玩家名称
    local color = {love.graphics.getColor()}
    if Game.CurrentPlayer == self and (PLAYER_STATE.READY or PLAYER_STATE.PLAYING) then
        love.graphics.setColor(1, 0, 0, 1)
    end
    love.graphics.printf(self.name .. '\n' .. self.point, STATIC.FONT.SMALL, 0, startY, labelWidth, 'left')
    love.graphics.setColor(color)

    -- 画麻将牌
    local lastX = startX
    local lastY = startY

    -- 吃碰杠
    for _, group in pairs(self.groups) do
        for _, tile in pairs(group) do
            tile.x = lastX
            tile.y = lastY
            tile.blur = false
            tile:draw()
            lastX = tile.x + width
        end
        lastX = lastX + width / 2
    end
    -- 手牌
    for i, tile in ipairs(self.tiles) do
        tile.x = lastX
        tile.y = lastY
        tile:draw()
        lastX = lastX + width
    end
    lastX = lastX + width / 2
    -- 摸牌
    if self.newTile then
        self.newTile.x = lastX
        self.newTile.y = lastY
        self.newTile:draw()
    end
    lastX = lastX + width * 1.5

    -- 操作按钮
    for _, button in pairs(self.buttons) do
        if button.show then
            button.x = lastX
            button.y = lastY
            button:draw()
            lastX = lastX + button.width * 1.5
        end
    end

    lastX = startX
    lastY = lastY + height
    -- 已打出的牌
    for i, tile in pairs(self.disTiles) do
        tile.x = lastX
        tile.y = lastY
        tile.blur = tile.belongTo ~= tile.belongToOld
        tile:draw()
        if i % 14 == 0 then
            lastX = startX
            lastY = lastY + height
        else
            lastX = tile.x + width
        end
    end
    if Game.CurrentPlayer == self then
        local groups = {}
        if Game.CurrentState == PLAYER_STATE.SELECT_CHI then
            groups = self.chi_selections
        elseif Game.CurrentState == PLAYER_STATE.SELECT_GANG then
            groups = self.gang_selections
        end
        color = {love.graphics.getColor()}
        love.graphics.setColor(0, 0, 1, 1)
        love.graphics.setLineWidth(3)

        for _, group in pairs(groups) do
            for _, tile in pairs(group) do
                if tile.group_focus then
                    love.graphics.rectangle('line', tile.x, tile.y - 0.2 * TILE_HEIGHT * TILE_SCALE, width, height)
                else
                    love.graphics.rectangle('line', tile.x, tile.y, width, height)
                end
            end
        end
        love.graphics.setColor(color)
    end

end
function Player:mousereleased(x, y, button)
    if Game.CurrentPlayer == self then
        if Game.CurrentState == PLAYER_STATE.PLAYING or Game.CurrentState == PLAYER_STATE.SELECT_CHI or
            Game.CurrentState == PLAYER_STATE.SELECT_GANG then
            for _, tile in pairs(self.tiles) do
                tile:mousereleased(x, y, button)
            end
            if self.newTile then
                self.newTile:mousereleased(x, y, button)
            end
        end
        if Game.CurrentState ~= PLAYER_STATE.OVER then
            for _, button in pairs(self.buttons) do
                button:mousereleased(x, y, button)
            end
        end
    end
end
function Player:__tostring()
    local s = self.name .. '\t'
    for key, value in pairs(self.readyTo) do
        s = s .. key .. ':' .. tostring(value) .. '\t'
    end
    return s
end
return Player
