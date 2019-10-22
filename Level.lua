local const = require('const')

local mt = {}
mt.__index = mt

function mt:draw()
  for i, tile in pairs(self.tiles) do
    love.graphics.rectangle('line', tile.x, tile.y, tile.w, tile.h)
  end
end

local TILES_TYPES = {
  [9] = require('Hero'),
  [1] = require('Tile'),
  [2] = require('ToggleFloor'),
  [4] = require('Door'),
  [5] = require('Spikes'),
  [6] = require('Lever'),
  [21] = require('Enemy'),
}

return {
  new = function(lvl_name, game_state)
    local lvl = setmetatable({ columns = 20, tiles = {} }, mt)

    lvl.data = require(lvl_name)

    for i, v in ipairs(lvl.data) do
      local x, y = (i-1) % lvl.columns * const.tilesize, math.floor((i-1) / lvl.columns) * const.tilesize
      if TILES_TYPES[v] then
        game_state.world:add( TILES_TYPES[v].new(x, y, game_state) )
      end
    end

    return lvl
  end
}
