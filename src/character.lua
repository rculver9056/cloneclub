local json = require 'hawk/json'
local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local module = {}

local _loaded_character = nil
local _character = 'sarah'

local Character = {}
Character.__index = Character

function Character:reset()
  self.state = 'idle'
  self.direction = 'right'
end

function Character:sheet()
  return self:getSheet()
end

function Character:getSheet()
  local path = 'images/characters/' .. self.name .. '.png'

  if not self.sheets then
    self.sheets = love.graphics.newImage(path)
    self.sheets:setFilter('nearest', 'nearest')
  end

  return self.sheets
end

function Character:update(dt)
  self:animation():update(dt)
end

function Character:animation()
  return self.animations[self.state][self.direction]
end

function Character:respawn()
  sound.playSfx( "respawn" )
end

function Character:draw(x, y)
  self:animation():draw(self:sheet(), x, y)
end

function module.pick(name)
  if not love.filesystem.exists("characters/" .. name .. ".json") then
    error("Unknown character " .. name)
  end

  if not love.filesystem.exists("images/characters/" .. name .. ".png") then
    error("Unknown character ".. name)
  end

  _character = name
  _loaded_character = nil
end

function module.load(character)
  if not love.filesystem.exists("characters/" .. character .. ".json") then
    error("Unknown character " .. character)
  end

  local contents, _ = love.filesystem.read('characters/' .. character .. ".json")
  return json.decode(contents)
end

-- Load the current character. Do all the crazy stuff too
function module.current()
  if _loaded_character then
    return _loaded_character
  end

  local basePath = 'images/characters/' .. _character .. '.png'
  local characterPath = "characters/" .. _character .. ".json"

  if not love.filesystem.exists(characterPath) then
    error("Unknown character " .. _character)
  end

  local contents, _ = love.filesystem.read('character_map.json')
  local sprite_map = json.decode(contents)

  local contents, _ = love.filesystem.read(characterPath)

  local character = json.decode(contents)
  setmetatable(character, Character)

  character.name = _character

  if character.animations then --merge
    local base = utils.deepcopy(character.animations)
    character.animations = utils.deepcopy(sprite_map)
    for k,v in pairs(base) do
      character.animations[k] = v
    end
  else
    character.animations = utils.deepcopy(sprite_map)
  end

  -- build the character
  character.count = 1

  character.sheets = love.graphics.newImage(basePath)
  character.sheets:setFilter('nearest', 'nearest')

	character.positions = utils.require('positions/default')
  character._grid = anim8.newGrid(96, 96, 
                                  character.sheets:getWidth(),
                                  character.sheets:getHeight())

  for state, _ in pairs(character.animations) do
    local data = character.animations[state]
    if type( data[1] ) == 'string' then
      -- positionless
      character.animations[state] = anim8.newAnimation(data[1], character._grid(unpack(data[2])), data[3])
    else
      -- positioned
      for i, _ in pairs( data ) do
        character.animations[state][i] = anim8.newAnimation(data[i][1], character._grid(unpack(data[i][2])), data[i][3])
      end
    end
  end

  _loaded_character = character
  return character
end


function module.characters()
  local list = {}

  for _, filename in pairs(love.filesystem.getDirectoryItems('characters')) do
    local name, _ = filename:gsub(".json", "")
    table.insert(list, name)
  end

  return list
end


return module
