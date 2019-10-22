local assets, quads, tex = {}, {}, nil

function assets.qdraw(id, x, y, r, sx, sy)
  if not tex then
    tex = love.graphics.newImage('tex.png')
    for y = 0, tex:getHeight()-1, 16 do
      for x = 0, tex:getWidth()-1, 16 do
        quads[#quads+1] = love.graphics.newQuad(x, y, 16, 16, tex:getDimensions())
      end
    end
  end

  love.graphics.draw(tex, quads[id], x, y, r, sx, sy)
end

return assets
