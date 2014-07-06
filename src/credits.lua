local app = require 'app'

local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()

function state:init()
end

function state:enter(previous)
    fonts.set( 'big' )
    love.graphics.setBackgroundColor(0, 0, 0)
    --sound.playMusic( "credits" )
    self.ty = 0
    camera:setPosition(0, self.ty)
    self.previous = previous
end

function state:leave()
    fonts.reset()
	camera:setPosition(0, 0)
end

function state:update(dt)
    self.ty = self.ty + 100 * dt
    camera:setPosition(0, self.ty)
    if self.ty > ( #self.credits * 50 ) + 1000 then
        Gamestate.switch(self.previous)
    end
end

function state:keypressed( button )
    if button == 'UP' then
        self.ty = math.max( self.ty - 100, 300 )
    elseif button == 'DOWN' then
        self.ty = math.min( self.ty + 200, ( #self.credits * 50 ) + 60 )
    else
        Gamestate.switch(self.previous)
    end
end

state.credits = {

    'edisonout'

}

function state:draw()
    local shift = math.floor(self.ty/25)
    for i = shift - 28, shift + 2 do
        local name = self.credits[i]
        if name then
            love.graphics.printf(name, 0, window.height + 50 * i, window.width, 'center')
        end
    end
end

return state


