local assets = require('assets')
local GameState = require('GameState')
local Animation = require('Animation')

local GRAVITY = 40
local JUMP_SPEED = -8

local mt = {}
mt.__index = mt

function mt:update(dt)
  if self.is_disabled then return end

  self:setAnim('idle')

  if love.keyboard.isDown('up') and not self.was_jump_pressed_in_previous_frame and self:isGrounded() then
    self:setAnim('run')
    self.vy = JUMP_SPEED
  end

  local dx = 0
  if love.keyboard.isDown('left') then
    self:setAnim('run')
    self.last_direction = -1
    dx = dx - dt * self.speed
  end
  if love.keyboard.isDown('right') then
    self:setAnim('run')
    self.last_direction = 1
    dx = dx + dt * self.speed
  end
  GameState.getCurrent().world:move(self, self.x + dx, self.y + self.vy, 'is_solid')

  self.vy = math.min(self.vy + GRAVITY * dt, 12)
  if self:isGrounded() then self.vy = 0 end

  if love.keyboard.isDown('e') and not self.was_action_pressed_in_previous_frame then
    GameState.getCurrent():trigger('hero:action', self)
  end

  -- The only new feature here is ability of the hero to stom on the "is_stompable" entities. It it very
  -- similar to the interactions with "is_touchable" entities but instead of using the hero to find
  -- collisions we prepare a custom colision area just below its feet.
  -- Again it's up to the enemy to decide what to do then it's stomped upon. Maybe it dies, maybe it just
  -- hides in it's shell? Different types of enemies could act differently. Finally stomping might be
  -- a way to interact not only with enemies but also with environment, other characters, players,
  -- and more.
  if self.vy > 0 then -- the hero can stomp on something only when it's falling
    local stompables = GameState.getCurrent().world:find({
      x = self.x, y = self.y + self.h + 1,
      w = self.w, h = 1,
    }, 'is_stompable')
    for i, stompable in ipairs(stompables) do
      -- Along with a long platformer tradition whenever you stomp on en enemy you bounce up
      self.vy = JUMP_SPEED / 2
      stompable:onStomp()
    end
  end

  local touchables = GameState.getCurrent().world:find(self, 'is_touchable')
  for _, touchable in ipairs(touchables) do
    touchable:onTouch(self)
  end

  self.current_anim:update(dt)

  self.was_jump_pressed_in_previous_frame = love.keyboard.isDown('up')
  self.was_action_pressed_in_previous_frame = love.keyboard.isDown('e')
end

function mt:draw()
  if self.last_direction == -1 then
    assets.qdraw(self.current_anim:getFrame(), self.x + 16 - 3, self.y, 0, -1, 1)
  else
    assets.qdraw(self.current_anim:getFrame(), self.x- 3, self.y)
  end
end

function mt:setAnim(name)
  self.current_anim = self.anims[name]
end

function mt:isGrounded()
  return GameState.getCurrent().world:check({ x = self.x, y = self.y+self.h, w = self.w, h = 1 }, 'is_solid')
end

return {
  new = function(x, y)
    local h = setmetatable({
      is_hero = true,
      x = x, y = y,
      w = 10, h = 16,
      vy = 0,
      speed = 220,
      anims = {
        idle = Animation.new(9, 3, 0.5),
        run = Animation.new(13, 8, 0.6)
      },
      z_index = 10
    }, mt)

    h:setAnim('idle')
    return h
  end
}
