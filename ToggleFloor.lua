local assets = require('assets')
local const = require('const')

local mt = {}
mt.__index = mt

function mt:draw()
  if self.is_solid then
    love.graphics.setColor(255, 255, 255)
  else
    love.graphics.setColor(255, 255, 255, 128)
  end
  assets.qdraw(2, self.x, self.y)
  love.graphics.setColor(255, 255, 255)
end

function mt:toggle()
  self.is_solid = not self.is_solid
end

return {
  new = function(x, y)
    return setmetatable({
      is_toggle_floor = true,
      x = x,
      y = y,
      w = const.tilesize,
      h = const.tilesize
    }, mt)
  end
}
