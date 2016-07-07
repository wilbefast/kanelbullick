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

local SIZE = 400
local HSIZE = SIZE/2
local HSIZE2 = HSIZE*HSIZE

local Bun = Class
{
  type = GameObject.newType("Bun"),


  init = function(self, x, y)
    GameObject.init(self, x, y)
		self.body = love.physics.newBody(ingame.world, x, y, "dynamic")
		self.body:setUserData({ bun = self })
		self.body:setFixedRotation(false)
		self.r = HSIZE
		self.shape = love.physics.newCircleShape(self.r) 
	  self.fixture = love.physics.newFixture(self.body, self.shape, 0.5)
	  self.fixture:setRestitution(0.9)
	  self.fixture:setDensity(1)

	  self.cin = love.graphics.newCanvas(SIZE, SIZE)
	  self.sugar = love.graphics.newCanvas(SIZE, SIZE)
	  love.graphics.setCanvas(self.cin)
			love.graphics.draw(img_bun_cin)
		love.graphics.setCanvas(self.sugar)
			love.graphics.draw(img_bun_sugar)
		love.graphics.setCanvas(nil)
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
	self.x, self.y = self.body:getPosition()
	--self.y = useful.lerp(self.y, WORLD_H*0.5, dt)
	self.angle = self.body:getAngle()
	self.angle_x = math.cos(self.angle)
	self.angle_y = math.sin(self.angle)

	-- calculate speed
	self.dx, self.dy = self.body:getLinearVelocity()
	local speed = Vector.len(self.dx, self.dy)
end

function Bun:draw(x, y)
	useful.bindBlack(128)
		love.graphics.draw(img_bun_shadow, self.x + 12, self.y + 12, self.angle, 1, 1, HSIZE, HSIZE)
	useful.bindWhite()
	love.graphics.draw(img_bun, self.x, self.y, self.angle, 1, 1, HSIZE, HSIZE)
	love.graphics.draw(self.cin, self.x, self.y, self.angle, 1, 1, HSIZE, HSIZE)
	love.graphics.draw(self.sugar, self.x, self.y, self.angle, 1, 1, HSIZE, HSIZE)

	if DEBUG then
		love.graphics.circle("line", self.x, self.y, self.r)
		love.graphics.line(self.x, self.y, self.x + self.angle_x*self.r, self.y + self.angle_y*self.r)
		love.graphics.push()
			love.graphics.translate(self.x, self.y)
			love.graphics.rotate(self.angle)
			love.graphics.rectangle("line", -HSIZE, -HSIZE, SIZE, SIZE)
		love.graphics.pop()
	end
end

--[[------------------------------------------------------------
Queries
--]]--

function Bun:amountCleaned()
	return 0
end

function Bun:isTouched(x, y)
	return Vector.dist2(x, y, self.x, self.y) <= HSIZE2
end


--[[------------------------------------------------------------
Events
--]]--

function Bun:lick(x, y, dt)
	if not self:isTouched(x, y) then
		return
	end
	love.graphics.push()
		love.graphics.translate(HSIZE, HSIZE)
		x, y = x - self.x + HSIZE, y - self.y + HSIZE
		love.graphics.rotate(-self.angle)
		love.graphics.translate(-HSIZE, -HSIZE)
		love.graphics.setBlendMode("replace")
			love.graphics.setColor(0, 0, 0, 0)
				love.graphics.setCanvas(self.cin)
					for i = 1, math.ceil(4*dt) do
						local r = 5 + math.random()*2
						local x, y = x + useful.signedRand(5), y + useful.signedRand(5)
						love.graphics.circle("fill", x, y, r)
					end
				love.graphics.setCanvas(self.sugar)
					for i = 1, math.ceil(4*dt) do
						local r = 15 + math.random()*10
						local x, y = x + useful.signedRand(15), y + useful.signedRand(15)
						love.graphics.circle("fill", x, y, r)
					end
				love.graphics.setCanvas(nil)
		love.graphics.setBlendMode("alpha")
	love.graphics.pop()

end

--[[------------------------------------------------------------
Export
--]]--

return Bun