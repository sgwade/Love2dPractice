local GameState = require('GameState')

function love.load()
  --love.graphics.setBackgroundColor(255,255,255)
  GameState.setCurrent('Play', 1)
end

function love.update(dt)
  GameState.getCurrent():update(dt)
  GameState.update()
end

function love.draw()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.scale(2, 2)
  GameState.getCurrent():draw()
end
