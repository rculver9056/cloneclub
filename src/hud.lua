local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'

local HUD = {}
HUD.__index = HUD

function HUD.new(level)
  local hud = {}
  setmetatable(hud, HUD)

    hud.saving = false

  return hud
end

function HUD:draw( player )
  return
end


return HUD
