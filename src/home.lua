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

  self.menu = menu.new({ 'start', 'controls', 'about', 'exit' })
  self.menu:onSelect(function(option)
    if option == 'exit' then
      love.event.push("quit")
    elseif option == 'controls' then
      Gamestate.switch('instructions')
	  elseif option == 'start' then
		  character.pick('sarah')
		  Gamestate.switch('studyroom', 'main') 
    else
     Gamestate.switch(option)
    end
  end)

end

function state:enter(previous)

  love.graphics.setBackgroundColor(240, 240, 240)

  sound.playMusic("theme")
	
  self.dna = love.graphics.newImage("images/menu/dna.png")
  local g1 = anim8.newGrid(200, 672, self.dna:getWidth(), self.dna:getHeight())
  self.dnaloop = anim8.newAnimation('loop', g1('1-4,1'), 0.25)

  self.barcode = love.graphics.newImage("images/menu/barcode.png")
  self.barcode_position = {x = (window.width - self.barcode:getWidth())/2, y = (window.height - self.barcode:getHeight())/2}
  tween(1, self.barcode_position, {x = 100, y = 150})
  self.double_speed = false	

   self.arrow = love.graphics.newImage("images/menu/small_arrow.png")

  self.previous = previous

end

function state:keypressed( button )
 
  if self.barcode_position.x > 100 then
	  self.double_speed = true
	else
    self.menu:keypressed(button)
  end
end

function state:update(dt)

  self.dnaloop:update(dt)
	
	if self.double_speed then
    tween.update(dt * 20)
  end

end

function state:draw()

  fonts.set( 'big' )
  love.graphics.setColor( 255, 255, 255, 255 )

	self.dnaloop:draw(self.dna, 834, 0)
  love.graphics.draw(self.barcode, self.barcode_position.x, self.barcode_position.y)

  if self.barcode_position.x == 100 then
    love.graphics.setColor(30, 30, 30, 255)
    local x = 400
    local y = 300
    love.graphics.draw(self.arrow, x + 48, y + 138 + 48 * (self.menu:selected() - 1), 0, 2, 2)
    for n,option in ipairs(self.menu.options) do
      love.graphics.print(option, x + 92, y +  46 + 48 * n - 4)
	  end
  end

end

function state:leave()

  self.arrow = nil
  self.barcode = nil
  self.dna = nil
 
  fonts.reset()
end

return state
