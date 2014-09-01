local anim8 = require 'vendor/anim8'
local app = require 'app'
local character = require 'character'
local controls  = require('inputcontroller').get()
local fonts     = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local menu      = require 'menu'
local sound = require 'vendor/TEsound'
local window    = require 'window'

local state = Gamestate.new()

function state:init()

  self.menu = menu.new({ 'start', 'load', 'controls', 'about', 'exit' })
  self.menu:onSelect(function(option)
	  if option == 'start' then
    character.pick('sarah')
    Gamestate.switch('station', 'main') 
		elseif option == 'load' then
		  sound.playSfx( 'beep' ) --TODO add saving option to game
    elseif option == 'exit' then
      love.event.push("quit")
    else
     Gamestate.switch(option)
    end
  end)

end

function state:enter(previous)

  love.graphics.setBackgroundColor(240, 240, 240)
  sound.playMusic("theme")

  self.arrow = love.graphics.newImage("images/menu/small_arrow.png")
  self.background = love.graphics.newImage('images/menu/home_background.png')
  --TODO: create Clone Club logo
  self.logo = love.graphics.newImage('images/menu/home_logo.png')

  self.blink = 0
  self.hiddenMenu = true
  self.previous = previous

end

function state:keypressed( button )
  if self.hiddenMenu then
    self.hiddenMenu = false
  else
    self.menu:keypressed(button)
  end
end

function state:update(dt)
  if self.hiddenMenu then
    self.blink = self.blink + dt < 1.25 and self.blink + dt or 0
  end
end

function state:draw()

  fonts.set( 'small' )
  love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw(self.background, 0, 0)
  love.graphics.draw(self.logo, 10, 10)

  love.graphics.setColor(30, 30, 30, 255)

  if self.hiddenMenu then
    if self.blink < 0.75 then
      love.graphics.printf("Press " .. controls:getKey('JUMP') .. " to Start", 0, 170, window.width, 'center')
    end
  else
    local x = window.width/2 - 40
    local y = 130
    love.graphics.draw(self.arrow, x, y + 30 + 16 * (self.menu:selected() - 1), 0, 2, 2)
    for n,option in ipairs(self.menu.options) do
      love.graphics.print(option, x + 22, y + 16 * n)
	  end
  end

end

function state:leave()

  self.arrow = nil
  self.background = nil
  self.logo = nil
 
  fonts.reset()
end

return state
