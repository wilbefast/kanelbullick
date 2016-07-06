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


local Bun = Class
{
  type = GameObject.newType("Bun"),


  init = function(self, x, y)
    GameObject.init(self, x, y)
		self.body = love.physics.newBody(ingame.world, x, y, "dynamic")
		self.body:setUserData({ bun = self })
		self.body:setFixedRotation(false)
		self.r = 200
		self.shape = love.physics.newCircleShape(self.r) 
	  self.fixture = love.physics.newFixture(self.body, self.shape, 0.5)
	 	self.fixture:setCategory(COLLIDE_WALLS)
	 	self.fixture:setMask(COLLIDE_WALLS)
	  self.fixture:setRestitution(0.6)
	  self.fixture:setDensity(10)
  end,
}
Bun:include(GameObject)

--[[------------------------------------------------------------
Collisions
--]]--

--[[------------------------------------------------------------
Destruction
--]]--

function Bun:onPurge()
	self.body:destroy()
end

--[[------------------------------------------------------------
Game loop
--]]--

function Bun:update(dt)
	-- update to match physics
	--self.x, self.y = self.body:getPosition()
	self.y = useful.lerp(self.y, WORLD_H*0.5, dt)
	self.angle = self.body:getAngle()
	self.angle_x = math.cos(self.angle)
	self.angle_y = math.sin(self.angle)

	-- calculate speed
	self.dx, self.dy = self.body:getLinearVelocity()
	local speed = Vector.len(self.dx, self.dy)
end

function Bun:draw(x, y)
	useful.bindBlack(128)
		love.graphics.draw(img_bun_shadow, self.x + 12, self.y + 12, self.angle, 1, 1, 200, 200)
	useful.bindWhite()
	love.graphics.draw(img_bun, self.x, self.y, self.angle, 1, 1, 200, 200)
	love.graphics.draw(img_bun_cin, self.x, self.y, self.angle, 1, 1, 200, 200)
	love.graphics.draw(img_bun_sugar, self.x, self.y, self.angle, 1, 1, 200, 200)

	if DEBUG then
		love.graphics.circle("line", self.x, self.y, self.r)
		love.graphics.line(self.x, self.y, self.x + self.angle_x*self.r, self.y + self.angle_y*self.r)
	end
end

--[[------------------------------------------------------------
Export
--]]--

return Bun