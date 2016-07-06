--[[
(C) Copyright 2015 William Dyce

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
Initialisation
--]]--


local Spittle = Class
{
  type = GameObject.newType("Spittle"),

  init = function(self, x, y, dx, dy, dz)
    GameObject.init(self, x, y)
    self.dx = dx
    self.dy = dy
    self.dz = (dz or 10)
    self.z = 0.1
    self.size = 0.5 + math.random()
    self.FRICTION = 2 + 1*math.random()
  end,
}
Spittle:include(GameObject)

--[[------------------------------------------------------------
Collisions
--]]--

--[[------------------------------------------------------------
Destruction
--]]--

function Spittle:onPurge()
end

--[[------------------------------------------------------------
Game loop
--]]--

function Spittle:update(dt)
	GameObject.update(self, dt)
	self.dz = self.dz - 20*dt
	self.z = self.z + self.dz*dt

	if self.z < 0 then
		self.purge = true
	end
end

function Spittle:draw(x, y)
	useful.pushCanvas(SPITTLE_CANVAS)
		love.graphics.setColor(240,246,255)
		love.graphics.circle("fill", x, y, self.size*3*(1 + self.z))
		useful.bindWhite()
	useful.popCanvas(nil)
end

--[[------------------------------------------------------------
Export
--]]--

return Spittle