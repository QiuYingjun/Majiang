--- 全局常量及启动配置
TILE_WIDTH = 640
TILE_HEIGHT = 777
TILE_SCALE = 0.08
WINDOW_HEIGHT = TILE_HEIGHT * TILE_SCALE * 12
WINDOW_WIDTH = TILE_WIDTH * TILE_SCALE * 23
TILE_EDGE = 8
MAX_FPS = 30
HUMAN_COUNT = 1
BACKGROUND_COLOR = {27 / 255, 123 / 255, 36 / 255}
DIRECTION = {'东家', '南家', '西家', '北家'}
OPERATION_LABEL = {'吃', '碰', '杠', '听', '胡', '摸', '过', '重开'}
-- DIRECTION = {'A', 'B', 'C', 'D'}
-- OPERATION_LABEL = {'1', '2', '3', '4', '5', '6', '7'}
OPERATION = {
    CHI = 1,
    PENG = 2,
    GANG = 3,
    TING = 4,
    HU = 5,
    MO = 6,
    SKIP = 7,
    RESET = 8
}

PLAYER_STATE = {
    READY = 'READY',
    PLAYING = 'PLAYING',
    OVER = 'OVER',
    SELECT_CHI = 'SELECT_CHI',
    SELECT_GANG = 'SELECT_GANG',
    FINISH = 'FINISH'
}
RUN_TEST = true
function love.conf(t)
    t.title = "四人麻将"
    t.window.width = WINDOW_WIDTH
    t.window.height = WINDOW_HEIGHT
end
