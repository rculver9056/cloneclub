local anim8 = require 'vendor/anim8'
local app = require 'app'
local character = require 'character'
local controls  = require('inputcontroller').get()
local fonts     = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local menu      = require 'menu'
local sound = require 'vendor/TEsound'
local tween     = require 'vendor/tween'
local window    = require 'window'

local state = Gamestate.new()

function state:init()
end

function state:enter(previous)

  love.graphics.setBackgroundColor(240, 240, 240)
  sound.playMusic("theme")
	
  self.background = love.graphics.newImage('images/menu/home_background.png')

-- TODO: add cool logo / dna strands
	-- self.dna = love.graphics.newImage("images/menu/dna.png")
	-- local g1 = anim8.newGrid(200, 672, self.dna:getWidth(), self.dna:getHeight())
	-- self.dnaloop = anim8.newAnimation('loop', g1('1-4,1'), 0.25)

	self.blink = 0
  self.previous = previous

end

function state:keypressed( button )
  if self.faces_position.x < 0 then
    self.double_speed = true
  else
    Gamestate.switch("home")
  end
end

function state:update(dt)

  self.blink = self.blink + dt < 1 and self.blink + dt or 0

  -- self.dnaloop:update(dt)

end

function state:draw()

  fonts.set( 'big' )

--  love.graphics.setColor( 255, 255, 255, 255 )

--	self.dnaloop:draw(self.dna, 834, 0)

  love.graphics.setColor(30, 30, 30, 255)
  love.graphics.print("CLONE CLUB", 50, 50, 0, 2, 2)
	if self.blink <= 0.5 then
    love.graphics.print("[PRESS START]", 360, 570, 0, 0.5, 0.5)
  end

end

function state:leave()

--	self.dna = nil
 
  fonts.reset()
end

return state
