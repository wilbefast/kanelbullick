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
INGAME GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

--[[------------------------------------------------------------
Physics
--]]--

function _contactBegin(fix_a, fix_b, contact)
end

function contactBegin(fix_a, fix_b, contact)
	_contactBegin(fix_a, fix_b, contact)
	_contactBegin(fix_b, fix_a, contact)
end

--[[------------------------------------------------------------
GameState navigation
--]]--

function state:init()
end

function state:enter()
	-- create physics world
  self.world = love.physics.newWorld(0, 500)
  self.world:setGravity(0, 0)
  self.world:setCallbacks(contactBegin)
  love.physics.setMeter(100) -- 100 pixels per meter
  local body, shape, fixture
  -- walls: south
  body = love.physics.newBody(self.world, WORLD_W/2, WORLD_H)
  shape = love.physics.newRectangleShape(WORLD_W, 64)
  fixture = love.physics.newFixture(body, shape)
  fixture:setCategory(COLLIDE_WALLS)
  fixture:setMask(COLLIDE_WALLS)
  fixture:setRestitution(0.3)
  body:setUserData("southWall")
	-- walls: north
  body = love.physics.newBody(self.world, WORLD_W/2, 0)
  shape = love.physics.newRectangleShape(WORLD_W, 64)
  fixture = love.physics.newFixture(body, shape)
  fixture:setCategory(COLLIDE_WALLS)
  fixture:setMask(COLLIDE_WALLS)
  fixture:setRestitution(0.3)
  body:setUserData("northWall")
	-- walls: west
  body = love.physics.newBody(self.world, 0, WORLD_H/2)
  shape = love.physics.newRectangleShape(64, WORLD_H)
  fixture = love.physics.newFixture(body, shape)
  fixture:setCategory(COLLIDE_WALLS)
  fixture:setMask(COLLIDE_WALLS)
  fixture:setRestitution(0.3)
  body:setUserData("westWall")
	-- walls: east
  body = love.physics.newBody(self.world, WORLD_W, WORLD_H/2)
  shape = love.physics.newRectangleShape(64, WORLD_H)
  fixture = love.physics.newFixture(body, shape)
 	fixture:setCategory(COLLIDE_WALLS)
 	fixture:setMask(COLLIDE_WALLS)
 	fixture:setRestitution(0.3)
  body:setUserData("eastWall")
  -- bun
  self.bun = Bun(WORLD_W*0.5, -WORLD_H*0.5)
  self.lick = 0
end

function state:leave()
	GameObject.purgeAll()
  self.world:destroy()
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key == "escape" then
  	GameState.switch(title)
  end
end

function state:onWheelDown()
  local dx, dy = mx - WORLD_W/2, my - WORLD_H
  --self.bun.body:applyLinearImpulse(-dx*10, -dy*10)

  self.lick = 0.1
end

function state:onWheelUp()
  local dx, dy = mx - WORLD_W/2, my - WORLD_H
  --self.bun.body:applyLinearImpulse(dx*10, dy*10)

  self.lick = 0.1
end

function state:update(dt)
  -- update physics
  self.world:update(dt)

  -- update logic
  GameObject.updateAll(dt)

  -- lick
  if self.lick > 0 then
    self.lick = self.lick - dt
    self.bun:lick(mx - self.bun.x, my - self.bun.y, dt)
  end
end

function state:draw()
	GameObject.drawAll()

  -- tongue
  love.graphics.draw(img_tongue, mx, my, m_angle, 1, 1, 100, -100)
  if tongue_up then
    love.graphics.draw(img_tongue_up, mx, my, m_angle, 1, 1, 100, 0)
  elseif tongue_down then
    love.graphics.draw(img_tongue_down, mx, my, m_angle, 1, 1, 100, 0)
  end

  if DEBUG then
    debugWorldDraw(self.world, 0, 0, WORLD_W, WORLD_H)
    useful.bindWhite()
    love.graphics.line(WORLD_OX, WORLD_OY, WORLD_OX + m_angle_x*200, WORLD_OY + m_angle_y*200)
    love.graphics.circle("fill", mx, my, 8)
  end

end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state