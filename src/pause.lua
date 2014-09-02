local camera = require 'camera'
local fonts = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local Player = require 'player'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()
local Timer = require 'vendor/timer'
local window = require 'window'

function state:init()
end

function state:enter(previous, player)

  self.arrow = love.graphics.newImage("images/menu/small_arrow.png")
  self.background = love.graphics.newImage("images/menu/home_background.png")
  
  love.graphics.setBackgroundColor(240, 240, 240)

  camera:setPosition(0, 0)
  self.option = 0
  
  --TODO: Add options back in
  --TODO: Make this page look pretty - possibly add DNA or a picture?
  if previous ~= Gamestate.get('options') and previous ~= Gamestate.get('controls') then
    self.previous = previous
    self.player = player
  end
  
  self.konami = { 'UP', 'UP', 'DOWN', 'DOWN', 'LEFT', 'RIGHT', 'LEFT', 'RIGHT', 'JUMP', 'ATTACK' }
  self.konami_idx = 0
end

function state:leave()
  fonts.reset()
end

function state:keypressed( button )
  if button == "UP" then
    self.option = (self.option - 1) % 4
    sound.playSfx( 'click' )
  elseif button == "DOWN" then
    self.option = (self.option + 1) % 4
    sound.playSfx( 'click' )
  end
  
  if self.konami[self.konami_idx + 1] == button then
    self.konami_idx = self.konami_idx + 1
    if self.konami_idx ~= #self.konami then return end
  else
    self.konami_idx = 0
  end
  
  if self.konami_idx == #self.konami then
    sound.playSfx( 'reveal' )
    Timer.add(1.5,function()
      Gamestate.switch('cheatscreen', self.previous )
    end)
    return
  end
  
  --TODO: split this into options table as you do in home.lua
  if button == "ATTACK" or button == "JUMP" then
    sound.playSfx( 'confirm' )
    if self.option == 0 then
      Gamestate.switch(self.previous)
      return
    elseif self.option == 1 then
      Gamestate.switch('controls')
    elseif self.option == 2 then
      Player.kill()
      self.previous:quit()
      Gamestate.switch('home')
    elseif self.option == 3 then
      love.event.push("quit")
    end
  end
end

function state:draw()

  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw(self.background, 0, 0)

  local controls = self.player.controls

  love.graphics.setColor( 0, 0, 0, 255 )
  fonts.set( 'big' )
  love.graphics.printf('Game Paused', 0, 40, window.width, 'center')
  
  fonts.set('small')
  
  love.graphics.print('Return to Game', 50, 100)
  love.graphics.print('Controls', 50, 115)
  love.graphics.print('Quit to Menu', 50, 130)
  love.graphics.print('Quit to Desktop', 50, 145)

  love.graphics.draw(self.arrow, 35, 100 + 15 * self.option)

  local howto = controls:getKey('ATTACK') .. " OR " .. controls:getKey("JUMP") .. ": SELECT ITEM"
  love.graphics.printf(howto, 0, 200, window.width, 'center')
end

return state
