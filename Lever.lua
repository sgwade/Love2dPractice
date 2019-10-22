local assets = require('assets')
local const = require('const')
local GameState = require('GameState')

local mt = {}
mt.__index = mt

function mt:draw()

  if self.is_on then
    assets.qdraw(6, self.x, self.y)
  else
    assets.qdraw(7, self.x, self.y)
  end

  if self.touches_hero then
    love.graphics.printf('[E]', self.x-100, self.y - 32, self.w + 200, 'center')
  end
end

function mt:update()
  self.touches_hero = GameState.getCurrent().world:check(self, 'is_hero')
end

function mt:onHeroAction()
  self:toggle()
end

function mt:toggle()
  self.is_on = not self.is_on

  local floors = GameState.getCurrent().world:find('all', 'is_toggle_floor')
  for i, floor in ipairs(floors) do
    floor:toggle()
  end
end

return {
  new = function(x, y, world)
    return setmetatable({
      is_lever = true,
      is_actable = true,
      world = world,
      x = x,
      y = y,
      w = const.tilesize,
      h = const.tilesize,
      z_index = 11
    }, mt)
  end
}
