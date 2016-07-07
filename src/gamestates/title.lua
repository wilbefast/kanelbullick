--[[
(C) Copyright 2016 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

--[[------------------------------------------------------------
TITLE GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

--[[------------------------------------------------------------
GameState navigation
--]]--

function state:init()
  self.entering = true
  self.t = -0.5
end

function state:enter()
  if not self.entering then
    audio:set_music_volume(1)
  end
end

function state:leave()
  self.t = 0
end

--[[------------------------------------------------------------
Callbacks
--]]--


function state:keypressed(key, uni)
  if key == "escape" then
  	self.leaving = true
  end
end

function state:enterGame()
  if not self.leaving and not self.entering then  
    GameState.switch(ingame)
  end
end

function state:onWheelUp()
	self:enterGame()
end

function state:onWheelDown()
	self:enterGame()
end

function state:update(dt)
  if self.leaving then
    self.t = self.t - dt
    audio:set_music_volume(math.min(1, self.t + 0.5))
    if self.t <= -0.5 then
      love.event.push("quit")
    end
  else
    self.t = math.min(1, self.t + dt)
    if self.entering then
      audio:set_music_volume(math.min(1, self.t + 0.5))
      if self.t >= 1 then
        self.entering = false
      end
    end
  end
end

function state:draw()
	-- text
	useful.bindBlack()
	love.graphics.setFont(fontLarge)
  if self.t < 1 then
    love.graphics.printf("Kanelbulle", WORLD_W*0.05 - (1 - self.t)*WORLD_W*0.7, WORLD_H*0.45, WORLD_W*0.8, "center")
    love.graphics.printf("Lick", WORLD_W*0.3 + (1 - self.t)*WORLD_W*0.7, WORLD_H*0.45, WORLD_W*0.8, "center")
  else
  	love.graphics.printf(TITLE, WORLD_W*0.1, WORLD_H*0.45, WORLD_W*0.8, "center")
  end
	love.graphics.setFont(fontMedium)
	love.graphics.printf("@wilbefast", -(1 - self.t)*WORLD_W*0.4, WORLD_H*0.75, WORLD_W*0.4, "center")
	love.graphics.printf("#CGJ2016", (1 - self.t)*WORLD_W*0.4 + WORLD_W*0.6, WORLD_H*0.75, WORLD_W*0.4, "center")
  useful.bindWhite()

  -- tongue
  local mx, my = mx, my
  if self.leaving or self.entering then
    local t = math.max(0, 1 - self.t)
    my = my + WORLD_H*t
  end
  love.graphics.draw(img_tongue, mx, my, m_angle, 1, 1, 100, -75)
  if tongue_up then
    love.graphics.draw(img_tongue_up, mx, my, m_angle, 1, 1, 100, 25)
  elseif tongue_down then
    love.graphics.draw(img_tongue_down, mx, my, m_angle, 1, 1, 100, 25)
  end
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state