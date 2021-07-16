local TestPlayer = {}
function TestPlayer:setUp()
    Game.Stack = Stack()
    self.player = Player(1, 'test1', true)
    table.insert(self.player.tiles, Tile(1, 'wan', 1))
    table.insert(self.player.tiles, Tile(2, 'wan', 1))
    table.insert(self.player.tiles, Tile(3, 'wan', 2))
    table.insert(self.player.tiles, Tile(4, 'wan', 2))

    table.insert(self.player.tiles, Tile(97, 'dong'))
    table.insert(self.player.tiles, Tile(98, 'dong'))
    table.insert(self.player.tiles, Tile(99, 'dong'))

end
function TestPlayer:testCanPeng()
    local t = Tile(5, 'wan', 2)
    t.belongTo = Player(2, 'test2', true)
    assert(self.player:canPeng(t))
    t.belongTo = self.player
    assert(not self.player:canPeng(t))
    assert(not self.player:canPeng(nil))
    print('TestPlayer:testCanPeng OK!')
end
function TestPlayer:testCanChi()
    local t = Tile(5, 'wan', 3)
    t.belongTo = Player(2, 'test2', true)
    t.belongTo.nextPlayer = self.player
    assert(self.player:canChi(t))
    t.number = 2
    assert(not self.player:canChi(t))
    print('TestPlayer:testCanChi OK!')
end
function TestPlayer:testCanGang()
    local t = Tile(96, 'dong')
    t.belongTo = Player(2, 'test2', true)
    assert(self.player:canGang(t))
    t.belongTo = self.player
    assert(self.player:canGang(t))

    local t2 = Tile(100, 'xi')
    t2.belongTo = Player(2, 'test2', true)
    assert(not self.player:canGang(t2))
    t2.belongTo = self.player
    assert(not self.player:canGang(t2))
    assert(not self.player:canGang(nil))
    print('TestPlayer:testCanGang OK!')
end
function TestPlayer:testCanHu()
    local t = Tile(5, 'wan', 2)
    t.belongTo = Player(2, 'test2', true)
    assert(self.player:canHu(t))
    t.belongTo = self.player
    assert(self.player:canHu(t))
    local t2 = Tile(6, 'wan', 3)
    assert(not self.player:canHu(t2))
    assert(not self.player:canHu(nil))
    print('TestPlayer:testCanHu OK!')
end
function TestPlayer:run()
    self:setUp()
    self:testCanPeng()
    self:testCanChi()
    self:testCanHu()
    self:testCanGang()
    print('TestPlayer All OK!')
end
return TestPlayer
