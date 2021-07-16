local Button = Class()
function Button:init(x, y, font, operation, belongTo)
    self.x = x
    self.y = y
    self.font = font
    self.operation = operation
    self.label = OPERATION_LABEL[operation]
    self.width = self.font:getWidth(self.label)
    self.height = self.font:getHeight(self.label)
    self.focus = false
    self.show = false
    self.belongTo = belongTo
end
function Button:update(dt)
    local mouseX = Game.MouseX
    local mouseY = Game.MouseY
    if mouseX > self.x and mouseX < self.x + self.width and mouseY > self.y and mouseY < self.y + self.height and
        self.show then
        self.focus = true
    else
        self.focus = false
    end
end
function Button:draw()
    local color = {love.graphics.getColor()}
    if self.focus then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(self.label, self.font, self.x, self.y, self.width, 'center')

    else
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf(self.label, self.font, self.x, self.y, self.width, 'center')
    end
    -- end
    love.graphics.setColor(color)
end
function Button:mousereleased(x, y, button)
    if self.focus then
        print(Game.CurrentPlayer.name, Game.CurrentState)
        print(self.belongTo.name .. ':button:' .. self.label)
        if self.operation == OPERATION.MO then
            self.belongTo:pick()
            Game.CurrentState = PLAYER_STATE.PLAYING
            Game.CurrentPlayer = self.belongTo
        elseif self.operation == OPERATION.SKIP then
            self.belongTo.skipTile = Game.LastTile
            Game.CurrentPlayer = Game.LastTile.belongTo
            Game.CurrentState = PLAYER_STATE.OVER
        elseif self.operation == OPERATION.PENG then
            self.belongTo:doPeng(Game.LastTile)
            Game.CurrentPlayer = self.belongTo
            Game.CurrentState = PLAYER_STATE.PLAYING
            Game.LastTile = nil
        elseif self.operation == OPERATION.GANG then
            if Game.CurrentState == PLAYER_STATE.READY then
                self.belongTo:doGang(Game.LastTile)
            elseif Game.CurrentState == PLAYER_STATE.PLAYING then
                self.belongTo:doGang(self.belongTo.newTile)
            end
        elseif self.operation == OPERATION.CHI then
            self.belongTo:doChi(Game.LastTile)
        elseif self.operation == OPERATION.HU then
            if Game.CurrentState == PLAYER_STATE.READY then
                self.belongTo:doHu(Game.LastTile)
            elseif Game.CurrentState == PLAYER_STATE.PLAYING then
                self.belongTo:doHu(self.belongTo.newTile)
            end
            Game.CurrentState = PLAYER_STATE.FINISH
        elseif self.operation == OPERATION.RESET then
            Game.Stack = Stack()
            Game.Stack:shuffle()
            for _, p in pairs(Game.Players) do
                p:reset()
                for i = 1, 13 do
                    p:pick(true)
                end
                p:sortTiles()
            end
            Game.LastTile = nil
            Game.CurrentState = PLAYER_STATE.READY
        end
        print(Game.CurrentPlayer.name, Game.CurrentState)
    end
end
return Button
