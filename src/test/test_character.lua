local character = require "src/character"

--Should fail
function test_pick_unknown_character() 
  assert_error(function() 
    character.pick('unknown', 'base')
  end, "Unknown character should fail")
end

function test_load_unknown_character() 
  assert_error(function() 
    character.load('unknown')
  end, "Unknown character should fail")
end

function test_load_sarah() 
  local sarah = character.load('sarah')
  assert_equal(sarah.name, 'sarah')
end

function test_load_sarah() 
  local found = false
  for _, name in pairs(character.characters()) do
    if name == 'sarah' then
      found = true
    end
  end

  assert_true(found, "Couldn't find sarah in characters")
end

function test_load_current() 
  local character = character.current()
  assert_equal(character.name, 'sarah')
end

function test_load_current() 
  local character = character.current()
  character.state = 'walk'
  character.direction = 'left'

  character:reset()

  assert_equal(character.state, 'idle')
  assert_equal(character.direction, 'right')
end




