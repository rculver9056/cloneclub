local fonts = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local Player = require 'player'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()
local Timer = require 'vendor/timer'
local window = require 'window'

function state:init()
  self.arrow = love.graphics.newImage("images/menu/arrow.png")
  self.background = love.graphics.newImage("images/menu/pause.png")
end

function state:enter(previous, player)
  love.graphics.setBackgroundColor(30, 30, 30)

  fonts.set( 'big' )

  self.option = 0
  
  if previous ~= Gamestate.get('options') and previous ~= Gamestate.get('instructions') then
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
    self.option = (self.option - 1) % 3
    sound.playSfx( 'click' )
  elseif button == "DOWN" then
    self.option = (self.option + 1) % 3
    sound.playSfx( 'click' )
  end

  if button == "START" then
    Gamestate.switch(self.previous)
    return
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
  
  if button == "ATTACK" or button == "JUMP" then
    sound.playSfx( 'confirm' )
    if self.option == 0 then
      Gamestate.switch('instructions')
    elseif self.option == 1 then
      Player.kill()
      self.previous:quit()
      Gamestate.switch('home')
    elseif self.option == 2 then
      love.event.push("quit")
    end
  end
end

function state:draw()

  love.graphics.draw(self.background, 
   window.width / 2 - self.background:getWidth() / 2,
   window.height / 2 - self.background:getHeight() / 2)

  local controls = self.player.controls

  love.graphics.setColor( 30, 30, 30, 255 )
		love.graphics.print('Game Paused', 396, 202)
  love.graphics.print('Controls', 396, 322)
  love.graphics.print('Quit to Menu', 396, 382)
  love.graphics.print('Quit to Desktop', 396, 442)
  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw(self.arrow, 312, 312 + 60 * self.option)
  local back = controls:getKey("START") .. ": BACK TO GAME"
  local howto = controls:getKey("ATTACK") .. " OR " .. controls:getKey("JUMP") .. ": SELECT ITEM"
  love.graphics.print(back, 50, 50)
  love.graphics.print(howto, 50, 110)
end


return state

