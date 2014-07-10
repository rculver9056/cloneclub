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

  self.pick = 0
  self.characters = {}

  self.characters[0] = 'sarah'
  self.characters[1] = 'alison'
  self.characters[2] = 'cosima'
  self.characters[3] = 'helena'

  self.number = 4 -- number of playable characters

end

function state:enter(previous)

  love.graphics.setBackgroundColor(240, 240, 240)

  sound.playMusic("theme")

  self.previous = previous
	
  self.characterpics = {}
  for i = 1, self.number do
	  self.characterpics[i - 1] = love.graphics.newImage('images/menu/characters/'..self.characters[i - 1]..'.png')
	end
	
  self.select = love.graphics.newImage('images/menu/characters/select.png')

end

function state:keypressed( button )
  if button == "LEFT" then
	  self.pick = (self.pick - 1) % self.number
  elseif button == "RIGHT" then
	  self.pick = (self.pick + 1) % self.number
  elseif button == "START" then
	  Gamestate.switch('home')
  elseif button =="JUMP" then
    character.pick(self.characters[self.pick])
    Gamestate.switch('station', 'main') 
  end
end

function state:update(dt)

end

function state:draw()

  fonts.set( 'big' )
  love.graphics.setColor(255,255,255,255)

  for i = 1, self.number do
    love.graphics.draw(self.characterpics[i - 1], 50 + 250 * (i - 1), 75) 
  end

  love.graphics.draw(self.select, 40 + 250 * self.pick, 65) 
	
  love.graphics.setColor(30, 30, 30, 255)
  love.graphics.print('[Select a clone]', 360, 575)

end

function state:leave()
  self.characterpics = {}
  self.select = nil
  fonts.reset()
end

return state
