require "init"
function love.load()
    Game.Stack = Stack()
    Game.Stack:shuffle()
    for i = 1, 4 do
        if i <= HUMAN_COUNT then
            table.insert(Game.Players, Player(i, DIRECTION[i], true))
        else
            table.insert(Game.Players, Player(i, DIRECTION[i], false))
        end
    end
    for i = 1, 4 do
        Game.Players[i].nextPlayer = Game.Players[i % 4 + 1]
    end
    for _, p in pairs(Game.Players) do
        for i = 1, 13 do
            p:pick(true)
        end
        p:sortTiles()
    end
    Game.CurrentPlayer = Game.Players[1]
    Game.CurrentState = PLAYER_STATE.READY
end

function love.update(dt)
    blockFPS(MAX_FPS, dt)
    Game.MouseX = love.mouse.getX()
    Game.MouseY = love.mouse.getY()
    for _, p in pairs(Game.Players) do
        p:update(dt)
    end

    local flag = false
    if Game.CurrentState ~= PLAYER_STATE.SELECT_CHI and Game.CurrentState ~= PLAYER_STATE.SELECT_GANG and Game.LastTile ==
        nil or Game.LastTile.belongTo == Game.CurrentPlayer then
        for _, p in pairs(Game.Players) do
            if p.readyTo[OPERATION.HU] and not flag then
                Game.CurrentPlayer = p
                Game.CurrentState = PLAYER_STATE.READY
                flag = true
            end
        end
        if not flag then
            for _, p in pairs(Game.Players) do
                if p.readyTo[OPERATION.GANG] and p ~= Game.CurrentPlayer and not flag then
                    Game.CurrentPlayer = p
                    Game.CurrentState = PLAYER_STATE.READY
                    flag = true
                end
            end
        end
        if not flag then
            for _, p in pairs(Game.Players) do
                if p.readyTo[OPERATION.PENG] and not flag then
                    Game.CurrentPlayer = p
                    Game.CurrentState = PLAYER_STATE.READY
                    flag = true
                end
            end
        end
        if not flag then
            for _, p in pairs(Game.Players) do
                if p.readyTo[OPERATION.CHI] and not flag then
                    Game.CurrentPlayer = p
                    Game.CurrentState = PLAYER_STATE.READY
                    flag = true
                end
            end
        end
        if not flag and Game.CurrentState ~= PLAYER_STATE.SELECT_CHI and Game.CurrentState ~= PLAYER_STATE.SELECT_GANG then
            for _, p in pairs(Game.Players) do
                if p.readyTo[OPERATION.MO] and not flag then
                    Game.CurrentPlayer = p
                    Game.CurrentState = PLAYER_STATE.READY
                    flag = true
                end
            end
        end
    end

    Game.Stack:update(dt)
    if t == nil then
        t = 0
    elseif t > 2 then
        t = 0
        -- print(Game.CurrentPlayer.name, Game.CurrentState)
        for _, p in pairs(Game.Players) do
            -- print(p)
        end
    end
    t = t + dt
end

function love.mousereleased(x, y, button)
    for _, player in pairs(Game.Players) do
        player:mousereleased(x, y, button)
    end
    Game.Stack:mousereleased(x, y, button)
end
function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        Game.CheatingMode = not Game.CheatingMode
    elseif key == 'tab' then
        Game.AllOpen = not Game.AllOpen
    end
end
function love.draw()
    love.graphics.setBackgroundColor(BACKGROUND_COLOR)
    love.graphics.setColor(1, 1, 1, 1)
    Game.Stack:draw()

    for _, p in pairs(Game.Players) do
        p:draw()
    end
    displayFPS()
end

function blockFPS(limit, dt) -- Call this function in love.update
    if dt < 2 / limit then
        love.timer.sleep(2 / limit - dt * limit / 15)
    end
end
function displayFPS()
    local color = {love.graphics.getColor()}
    love.graphics.setColor(1, 0, 0, 1)
    local width = STATIC.FONT.MICRO:getWidth('FPS: xxx')
    love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), STATIC.FONT.MICRO, WINDOW_WIDTH - width, 0, width,
        'left')
    love.graphics.setColor(color)
end
