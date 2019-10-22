local assets = require('assets')
local const = require('const')
local GameState = require('GameState')
local Animation = require('Animation')

local mt = {}
mt.__index = mt

-- There is no much to drawing the only enemy in this game - when it's alive we just draw a proper frame
-- facing proper direction not unlike we did with the hero in the previous lession. When it's dead we draw it
-- rotated pi/2 radians (same as 90deg) and semitransparent.
function mt:draw()
  if self.is_dead then
    love.graphics.setColor(255, 255, 255, 128)
    assets.qdraw(self.anim:getFrame(), self.x + 16, self.y+1, math.pi / 2)
    love.graphics.setColor(255, 255, 255)
  else
    if self.dir == -1 then
      assets.qdraw(self.anim:getFrame(), self.x + 16, self.y, 0, -1, 1)
    else
      assets.qdraw(self.anim:getFrame(), self.x, self.y)
    end
  end
end

function mt:update(dt)
  -- When the enemy is dead it does nothing.
  if self.is_dead then return end

  -- As it's animated the animation need to be updated every frame.
  self.anim:update(dt)

  -- The enemy just moves in it's current direction.
  GameState.getCurrent().world:move(self, self.x+self.dir*self.speed*dt, self.y, 'is_solid')

  -- In this part the enemy checks if there is anything solid in front of it. It also checks if there is
  -- floor in the place it's about to move to. If it figures that it's not a good idea to move forward
  -- it turns back. This is probably the most common enemy behavior in platformer games, and it's still
  -- a useful one.
  local is_obstacle_ahead = GameState.getCurrent().world:check({
    x = self.x + self.w/2 + self.w*2/3  * self.dir,
    y = self.y + self.h/2,
    w = 2,
    h = 2
  }, 'is_solid')

  local is_floor_ahead = GameState.getCurrent().world:check({
    x = self.x + self.w/2 + self.w*2/3  * self.dir,
    y = self.y + self.h + 1,
    w = 2,
    h = 2
  }, 'all')

  if is_obstacle_ahead or not is_floor_ahead then
    self:turnBack()
  end
end

-- Similarly to toggling boolean with not you can toggle 1/-1 with * -1.
function mt:turnBack()
  self.dir = self.dir * -1
end

function mt:onTouch(other)
  if other.is_hero then
    GameState.getCurrent():trigger('hero:kill', self, other)
  end
end

-- The enemy "is_stompable", and when the hero jumps on it's head this function is called.
function mt:onStomp()
  self.is_touchable = false -- this enemy no longer will be able to touch (and harm) the hero
  self.is_stompable = false -- once stomped this enemy cannot be stomped again.
  self.is_dead = true -- a dead enemy is not updated and it's drawn differently
end

return {
  new = function(x, y)
    return setmetatable({
      is_touchable = true,
      is_stompable = true,
      x = x,
      y = y,
      w = const.tilesize,
      h = const.tilesize,
      dir = 1,
      speed = 60,
      anim = Animation.new(21, 4, 0.5)
    }, mt)
  end
}
