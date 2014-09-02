local anim8 = require 'vendor/anim8'
local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()

function state:init()
end

function state:enter(previous)
  self.background = love.graphics.newImage('images/menu/home_background.png')
  sound.playMusic( "theme" ) 
  self.previous = previous
  self.text =  "Clone Club is an unofficial platform/RPG game created by fans of the show Orphan Black, "..
               "build using the love game engine.\n\n" ..
               "This game is a work in progress.\n\n" ..
               "Alison is the best clone.\n\n"
end

function state:leave()
  fonts.reset()
end

function state:update(dt)
end

function state:keypressed( button )
  Gamestate.switch(self.previous)
end

function state:leave()
  fonts.reset()
end


function state:draw()

  love.graphics.setBackgroundColor(240, 240, 240)

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(self.background, 0, 0)

  love.graphics.setColor(30, 30, 30, 255)
  fonts.set('big')
  love.graphics.printf("ABOUT", 0, 40, window.width, 'center')
  fonts.set('small')
  love.graphics.printf(self.text, 50, 100, 250, 'left')

end

return state


