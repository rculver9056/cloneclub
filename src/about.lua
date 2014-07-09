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

  self.dna = love.graphics.newImage("images/menu/dna.png")
  local g1 = anim8.newGrid(200, 672, self.dna:getWidth(), self.dna:getHeight())
  self.dnaloop = anim8.newAnimation('loop', g1('1-4,1'), 0.25)

    fonts.set( 'courier' )
    love.graphics.setBackgroundColor(240, 240, 240, 255)
    sound.playMusic( "theme" ) 
    self.previous = previous
		self.text =   "Clone Club is an unofficial platform/RPG game created by fans of the show Orphan Black, "..
									"build using the love game engine.\n\n" ..
									"We are in no way affiliated with any of the cast or crew of Orphan Black.\n\n"..
									"This game is still very much a work in progress so prepare yourself for regular (automatic) updates, "..
									"including new levels, enemies and clones! "..
									"We're always in need of contributors - especially artists - so join in.\n\n"..
									"Huge thanks to the developers over at Project Hawkthorne from whom we have borrowed large chunks of code "..
									"and to StackMachine.com for enabling us to easily distribute new versions of the game across several operating systems.\n\n"..
		              "PS. Alison is the best clone.\n\n"
end

function state:leave()
    fonts.reset()
end

function state:update(dt)
  self.dnaloop:update(dt)
end

function state:keypressed( button )
    Gamestate.switch(self.previous)
end

function state:leave()
  fonts.reset()
end


function state:draw()

  love.graphics.setBackgroundColor(240, 240, 240)

	self.dnaloop:draw(self.dna, 834, 0)

    love.graphics.setColor(30, 30, 30, 255)
    love.graphics.printf(self.text, 150, 150, 1200, 'left', 0, 0.5, 0.5)

end

return state


