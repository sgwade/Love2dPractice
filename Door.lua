local assets = require('assets')
local const = require('const')
local GameState = require('GameState')

local mt = {}
mt.__index = mt

function mt:update(dt)
  self.touches_hero = GameState.getCurrent().world:check(self, 'is_hero')
end

function mt:draw()
  assets.qdraw(4, self.x, self.y)
  if self.touches_hero then
    love.graphics.printf('[E]', self.x-100, self.y - 32, self.w + 200, 'center')
  end
end

function mt:onHeroAction()
  GameState.getCurrent():trigger('door:open')
end

return {
  new = function(x, y, game_state)
    return setmetatable({
      is_door = true,
      is_actable = true,
      x = x,
      y = y,
      w = const.tilesize,
      h = const.tilesize,
    }, mt)
  end
}
