-- 全局变量
STATIC = {
    SOUND = {
        THROW = love.audio.newSource("asset/sound/throw.wav", 'static'),
        PENG = love.audio.newSource("asset/sound/peng.wav", 'static'),
        HU = love.audio.newSource("asset/sound/hu.wav", 'static'),
        CHI = love.audio.newSource("asset/sound/chi.wav", 'static'),
        GANG = love.audio.newSource("asset/sound/gang.wav", 'static')
    },
    IMAGE = {},
    FONT = {
        BIG = love.graphics.newFont("asset/font/FZWangXZXKJW.TTF", TILE_HEIGHT * TILE_SCALE * 2),
        MIDIUM = love.graphics.newFont("asset/font/FZWangXZXKJW.TTF", TILE_HEIGHT * TILE_SCALE * 1),
        SMALL = love.graphics.newFont("asset/font/FZWangXZXKJW.TTF", TILE_HEIGHT * TILE_SCALE * 0.5),
        MICRO = love.graphics.newFont("asset/font/FZWangXZXKJW.TTF", TILE_HEIGHT * TILE_SCALE * 0.3)
    }
}

for k, file in ipairs(love.filesystem.getDirectoryItems('asset/img')) do
    if file:sub(-3):lower() == 'png' then
        STATIC.IMAGE[file:sub(1, file:len() - 4)] = love.graphics.newImage('asset/img/' .. file)
    end
end
Game = {
    Stack = nil,
    Players = {},
    CurrentPlayer = nil,
    CurrentState = nil,
    LastTile = nil,
    AllOpen = true,
    MouseX = 0,
    MouseY = 0,
    CheatingMode = false
}

Class = require 'lib.hump.class'
Stack = require 'class.Stack'
Tile = require "class.Tile"
Player = require 'class.Player'
Button = require "class.Button"

if (RUN_TEST) then
    TestPlayer = require "test.TestPlayer"
    TestPlayer:run()
end
