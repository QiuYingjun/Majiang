local Tile = Class()

function Tile:init(id, category, number)
    self.category = category
    self.number = number
    self.belongTo = nil
    self.belongToOld = nil
    self.blur = false
    if number == nil then
        self.name = category
    else
        self.name = category .. number
    end
    self.image = STATIC.IMAGE[self.name]

    self.quad = love.graphics.newQuad(0, 0, TILE_WIDTH, TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT)
    self.amination = nil
    self.id = id

    self.open = false
    self.focus = false
    self.group_focus = false
    self.stack_focus = false
    self.x = 0
    self.y = 0
end

function Tile:update(dt)
    if self.open or Game.AllOpen or (self.belongTo and self.belongTo.isHuman) then
        self.image = STATIC.IMAGE[self.name]
    else
        self.image = STATIC.IMAGE['back']
    end
    local mouseX = Game.MouseX
    local mouseY = Game.MouseY
    local mouseOnTile =
        mouseX > self.x and mouseX < self.x + TILE_WIDTH * TILE_SCALE - TILE_EDGE and mouseY > self.y and mouseY <
            self.y + TILE_HEIGHT * TILE_SCALE * 0.8
    if mouseOnTile and self.belongTo == Game.CurrentPlayer and (Game.CurrentState == PLAYER_STATE.PLAYING) then
        self.focus = true
    else
        self.focus = false
    end

    if mouseOnTile and self.belongTo then
        local focusGroup = nil
        local groups = {}
        if Game.CurrentState == PLAYER_STATE.SELECT_CHI then
            groups = self.belongTo.chi_selections
        elseif Game.CurrentState == PLAYER_STATE.SELECT_GANG then
            groups = self.belongTo.gang_selections
        end
        for _, group in pairs(groups) do
            for _, t in pairs(group) do
                if t == self then
                    focusGroup = group
                    break
                end
            end
            if focusGroup then
                break
            end
        end
        if focusGroup then
            for _, t in pairs(focusGroup) do
                t.group_focus = true
            end
        end
    end

    if mouseOnTile and self.belongTo == nil then
        self.stack_focus = true
    else
        self.stack_focus = false
    end

end

function Tile:draw()
    if self.focus or self.group_focus then
        love.graphics.draw(self.image, self.quad, self.x, self.y - 0.2 * TILE_HEIGHT * TILE_SCALE, 0, TILE_SCALE,
            TILE_SCALE)
    else
        if self.blur then
            local color = {love.graphics.getColor()}
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(self.image, self.quad, self.x, self.y, 0, TILE_SCALE, TILE_SCALE)
            love.graphics.setColor(color)
        else
            love.graphics.draw(self.image, self.quad, self.x, self.y, 0, TILE_SCALE, TILE_SCALE)
        end
    end
end
function Tile:mousereleased(x, y, button)
    if self.focus then
        print(self.belongTo.name .. ':' .. self.name)
        if self == self.belongTo.newTile then
            self.belongTo.newTile = nil
        else
            for i, tile in pairs(self.belongTo.tiles) do
                if tile == self then
                    table.remove(self.belongTo.tiles, i)
                end
            end
            if self.belongTo.newTile then
                table.insert(self.belongTo.tiles, self.belongTo.newTile)
                self.belongTo.newTile = nil
                self.belongTo:sortTiles()
            end
        end
        table.insert(self.belongTo.disTiles, self)
        self.focus = false
        Game.LastTile = self
        Game.CurrentState = PLAYER_STATE.OVER
        love.audio.play(STATIC.SOUND.THROW)
        print(Game.CurrentPlayer.name, Game.CurrentState)
    end
    if self.group_focus then
        if Game.CurrentState == PLAYER_STATE.SELECT_CHI then
            for i = #self.belongTo.chi_selections, 1, -1 do
                local group = self.belongTo.chi_selections[i]
                for _, t in pairs(group) do
                    if not t.group_focus then
                        table.remove(self.belongTo.chi_selections, i)
                        break
                    end
                end
            end
            self.belongTo:doChi(Game.LastTile)
        elseif Game.CurrentState == PLAYER_STATE.SELECT_GANG then
            for i = #self.belongTo.gang_selections, 1, -1 do
                local group = self.belongTo.gang_selections[i]
                for _, t in pairs(group) do
                    if not t.group_focus then
                        table.remove(self.belongTo.gang_selections, i)
                        break
                    end
                end
            end
            if self.belongTo.newTile then
                self.belongTo:doGang(self.belongTo.newTile)
            else
                self.belongTo:doGang(Game.LastTile)
            end
        end
    end
    if self.stack_focus and Game.CurrentState == PLAYER_STATE.READY and Game.CheatingMode then
        for i = 1, #Game.Stack.tiles do
            if Game.Stack.tiles[i] == self then
                Game.CurrentPlayer.newTile = self
                self.belongTo = Game.CurrentPlayer
                self.belongToOld = Game.CurrentPlayer
                Game.CurrentState = PLAYER_STATE.PLAYING
                table.remove(Game.Stack.tiles, i)
                break
            end
        end
    end
end
function Tile:__tostring()
    return self.name
end

return Tile
