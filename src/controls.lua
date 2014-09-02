local camera = require 'camera'
local controls = require('inputcontroller').get()
local fonts = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local Menu = require 'menu'
local sound = require 'vendor/TEsound'
local window = require 'window'

local state = Gamestate.new()

local menu = Menu.new({
  'UP',
  'DOWN',
  'LEFT',
  'RIGHT',
  'SELECT',
  'START',
  'JUMP',
  'ATTACK',
  'INTERACT',
})

local descriptions = {
  UP = 'Move Up',
  DOWN = 'Move Down',
  LEFT = 'Move Left',
  RIGHT = 'Move Right',
  SELECT = 'Inventory',
  START = 'Pause',
  JUMP = 'Jump / OK',
  ATTACK = 'Attack',
  INTERACT = 'Interact',
}

menu:onSelect(function()
  controls:enableRemap()
  state.statusText = "PRESS NEW KEY" end)

function state:init()

  self.arrow = love.graphics.newImage("images/menu/small_arrow.png")
  self.background = love.graphics.newImage("images/menu/home_background.png")
  self.instructions = {}

  -- The X coordinates of the columns
  self.left_column = 40
  self.right_column = 200
  -- The Y coordinate of the top key
  self.top = 70
  -- Vertical spacing between keys
  self.spacing = 15

end

function state:enter(previous)
  love.graphics.setBackgroundColor(240, 240, 240, 255)
  sound.playMusic( "theme" )

  camera:setPosition(0, 0)

  self.instructions = controls:getActionmap()
  self.previous = previous
  self.option = 0
  self.statusText = ''
end

function state:leave()
  fonts.reset()
end

function state:keypressed( button )
  if controls:isRemapping() then self:remapKey(button) end
  if controls.getAction then menu:keypressed(button) end
  if button == 'START' then Gamestate.switch(self.previous) end
end


function state:draw()

  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw(self.background, 0, 0)
  love.graphics.draw(self.arrow, 270, 174 + self.spacing * menu:selected())

  love.graphics.setColor( 30, 30, 30, 255 )
  local n = 1
  local back = controls:getKey("START") .. ": BACK TO MENU"
  local howto = controls:getKey("ATTACK") .. " OR " .. controls:getKey("JUMP") .. ": REASSIGN CONTROL"

  fonts.set( 'big' )
  love.graphics.printf("CONTROLS", 0, 40, window.width, 'center')
  fonts.set( 'small' )
  love.graphics.print(back, 50, 200)
  love.graphics.print(howto, 50, 215)
  love.graphics.print(self.statusText, self.left_column, 560)


  for i, button in ipairs(menu.options) do
    local y = self.top + self.spacing * (i - 1)
    local key = controls:getKey(button)
    love.graphics.print(descriptions[button], self.left_column, y)
    love.graphics.print(key, self.right_column, y)
  end
  
  love.graphics.setColor( 255, 255, 255, 255 )

end

function state:remapKey(key)
  local button = menu.options[menu:selected() + 1]
  if not controls:newAction(key, button) then
    self.statusText = "KEY IS ALREADY IN USE"
  else
    if key == ' ' then key = 'space' end
    assert(controls:getKey(button) == key)
    self.statusText = button .. ": " .. key
  end
  controls:disableRemap()
  controls:save()
end

return state
