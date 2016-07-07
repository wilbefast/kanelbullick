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
GLOBAL VARIABLES
--]]------------------------------------------------------------

TITLE = "Kanelbullicka"
WORLD_W, WORLD_H = 640, 640
shake = 0
COLLIDE_WALLS = 1
COLLIDE_FLOORS = 2
COLLIDE_ROOFS = 3
DEBUG = false
WORLD_OX, WORLD_OY = WORLD_W/2, WORLD_H
mx, my = WORLD_OX, WORLD_OY
m_angle_x, m_angle_y = 0, 0
m_angle = 0

--[[------------------------------------------------------------
LOCAL VARIABLES
--]]------------------------------------------------------------

local WORLD_CANVAS = nil
local CAPTURE_SCREENSHOT = false

--[[------------------------------------------------------------
LOVE CALLBACKS
--]]------------------------------------------------------------

function love.load(arg)

  -- "Unrequited" library
  Class = require("unrequited/Class")
  Vector = require("unrequited/Vector")
  GameState = require("unrequited/GameState")
  GameObject = require("unrequited/GameObject")
  babysitter = require("unrequited/babysitter")
  useful = require("unrequited/useful")
  audio = require("unrequited/audio")
  log = require("unrequited/log")
  log:setLength(21)

  -- game-specific code
  debugWorldDraw = require("debugWorldDraw")
  scaling = require("scaling")
  Spittle = require("gameobjects/Spittle")
  Bun = require("gameobjects/Bun")
  ingame = require("gamestates/ingame")
  title = require("gamestates/title")

  -- startup logs
  log.print = true
  log:write("Starting '" .. TITLE .. "'")

  -- set scaling based on resolution
  scaling.reset()

  -- set interpolation
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineStyle("rough", 1)

  -- resources
  -- ... fonts
  fontSmall = love.graphics.newFont("assets/ttf/Romulus_by_pix3m.ttf", 18)
  fontMedium = love.graphics.newFont("assets/ttf/Romulus_by_pix3m.ttf", 32)
  fontLarge = love.graphics.newFont("assets/ttf/Romulus_by_pix3m.ttf", 64)
  love.graphics.setFont(fontMedium)
  -- ... png
  img_bun = love.graphics.newImage("assets/png/bun.png")
  img_bun_cin = love.graphics.newImage("assets/png/bun_cin.png")
  img_bun_sugar = love.graphics.newImage("assets/png/bun_sugar.png")
  img_bun_shadow = love.graphics.newImage("assets/png/bun_shadow.png")
  img_tongue = love.graphics.newImage("assets/png/tongue.png")
  img_tongue_up = love.graphics.newImage("assets/png/tongue_up.png")
  img_tongue_down = love.graphics.newImage("assets/png/tongue_down.png")
  img_helmut = love.graphics.newImage("assets/png/helmut.png")

  -- initialise random
  math.randomseed(os.time())

  -- no mouse
  love.mouse.setVisible(false)

  -- save directory
  love.filesystem.setIdentity(TITLE)

  -- window title
  love.window.setTitle(TITLE)

  -- canvases
  WORLD_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)
  SPITTLE_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)

  -- clear colour
  love.graphics.setBackgroundColor(0, 0, 0)

  -- line width
  love.graphics.setLineWidth(3)

  -- play music
  audio:load_music("na_sweden")
  audio:play_music("na_sweden")

  -- sound
  audio:load_sounds("lick", 11, 1, 2)

  -- highscore
  local s_highscore = love.filesystem.read("highscore.txt")
  if s_highscore then
    highscore = tonumber(s_highscore)
  else
    highscore = 0
  end


  -- initial gamestate
  GameState.switch(title)
end

function love.focus(f)
  GameState.focus(f)
end

function love.quit()
  GameState.quit()
end

function love.keypressed(key, uni)
  GameState.keypressed(key, uni)
  if key == "d" then
    DEBUG = not DEBUG
  elseif key == "x" then
    CAPTURE_SCREENSHOT = not CAPTURE_SCREENSHOT
  end
end

function love.keyreleased(key, uni)
  GameState.keyreleased(key, uni)
end

function love.mousepressed(x, y, button)
  -- if tongue_down then
  --   tongue_down = false
  --   tongue_up = true
  --   GameState.onWheelDown()
  -- else
  --   tongue_down = true
  --   tongue_up = false
  --   GameState.onWheelUp()
  -- end
end

function love.mousereleased(x, y, button)
end

tongue_down, tongue_up = true, true
function love.wheelmoved(x, y)
  if y < 0 then
    if tongue_down then
      tongue_down = false
      tongue_up = true
      GameState.onWheelDown()
      shake = math.min(3, shake + 0.4)
      audio:play_sound("lick")
    end 
  elseif y > 0 then
    if tongue_up then
      tongue_down = true
      tongue_up = false
      GameState.onWheelUp()
      shake = math.min(3, shake + 0.4)
      audio:play_sound("lick")
    end
  end
end


function love.update(dt)
  GameState.update(dt)

  shake = shake - 6*dt
  if shake < 0 then
    shake = 0
  end

  mx, my = scaling.scaleMouse()
  mx, my = useful.clamp(mx, 1, WORLD_W - 1), useful.clamp(my, 1, WORLD_H - 6*math.sqrt(math.abs(mx - WORLD_OX)))
  m_angle_x, m_angle_y = mx - WORLD_OX, my - WORLD_OY
  nm_angle_x, nm_angle_y = Vector.normalise(m_angle_x, m_angle_y)
  m_angle = math.atan2(m_angle_y, m_angle_x) + math.pi/2

  babysitter.update(dt)
end

function love.draw()
  useful.pushCanvas(WORLD_CANVAS)
    -- clear
    if (title.entering or title.leaving) and title.t < 0 then
      local t = 1 + 2*title.t
      love.graphics.setColor(91*t, 132*t, 192*t)
    else
      love.graphics.setColor(91, 132, 192)
    end
    love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
    love.graphics.setColor(224, 216, 73)
    if title.entering or title.leaving then
      local t = math.max(0, title.t)
      love.graphics.rectangle("fill", 0, WORLD_H*0.5 - WORLD_H*0.1*t, WORLD_W, WORLD_H*0.2*t)
      love.graphics.rectangle("fill", WORLD_W*0.5 - WORLD_H*0.1*t, 0, WORLD_W*0.2*t, WORLD_H)
    else
      love.graphics.rectangle("fill", 0, WORLD_H*0.4, WORLD_W, WORLD_H*0.2)
      love.graphics.rectangle("fill", WORLD_W*0.4, 0, WORLD_W*0.2, WORLD_H)
    end
    useful.bindWhite()
    -- draw any other state specific stuff
    GameState.draw()
  useful.popCanvas()

  love.graphics.push()
    -- scaling
    love.graphics.scale(WINDOW_SCALE, WINDOW_SCALE)
    -- playable area is the centre sub-rect of the screen
    love.graphics.translate(
      (WINDOW_W - VIEW_W)*0.5/WINDOW_SCALE + math.random()*shake, 
      (WINDOW_H - VIEW_H)*0.5/WINDOW_SCALE + math.random()*shake)
    -- draw the canvas
    love.graphics.draw(WORLD_CANVAS, 0, 0)
  love.graphics.pop() -- pop offset

  -- capture GIF footage
  if CAPTURE_SCREENSHOT then
    useful.recordGIF()
  end

  -- draw logs
  if DEBUG then
    log:draw(16, 48)
  end
end