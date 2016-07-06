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
end

function state:enter()
end

function state:leave()
end

--[[------------------------------------------------------------
Callbacks
--]]--


function state:keypressed(key, uni)
  if key == "escape" then
  	return love.event.push("quit")
  end
end

function state:enterGame()
	GameState.switch(ingame)
end

function state:onWheelUp()
	self:enterGame()
end

function state:onWheelDown()
	self:enterGame()
end

function state:update(dt)
end

function state:draw()
	-- text
	useful.bindBlack()
	love.graphics.setFont(fontLarge)
	love.graphics.printf(TITLE, WORLD_W*0.1, WORLD_H*0.45, WORLD_W*0.8, "center")
	love.graphics.setFont(fontMedium)
	love.graphics.printf("@wilbefast", 0, WORLD_H*0.75, WORLD_W*0.4, "center")
	love.graphics.printf("#CGJ2016", WORLD_W*0.6, WORLD_H*0.75, WORLD_W*0.4, "center")
  useful.bindWhite()

  -- tongue
  love.graphics.draw(img_tongue, mx, my, m_angle, 1, 1, 100, -100)
  if tongue_up then
    love.graphics.draw(img_tongue_up, mx, my, m_angle, 1, 1, 100, 0)
  elseif tongue_down then
    love.graphics.draw(img_tongue_down, mx, my, m_angle, 1, 1, 100, 0)
  end
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state