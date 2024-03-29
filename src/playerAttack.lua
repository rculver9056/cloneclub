local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local Sprite = require 'nodes/sprite'
local Timer = require 'vendor/timer'

local PlayerAttack = {}
PlayerAttack.__index = PlayerAttack
PlayerAttack.playerAttack = true

---
-- Create a new Player
-- @param collider
-- @return Player
function PlayerAttack.new(collider,plyr)

    local attack = {}

    setmetatable(attack, PlayerAttack)

    attack.width = 20
    attack.height = 36
    attack.radius = 20
    attack.collider = collider
    attack.bb = collider:addRectangle(0,0,attack.width,attack.height)
    attack.bb.node = attack
    attack.damage = 1
    attack.player = plyr
    attack:deactivate()

    return attack
end

function PlayerAttack:update()
    local player = self.player
    
    
    if player.character.direction=='right' then
        self.bb:moveTo(player.position.x + 48 + 40, player.position.y+56)
    else
        self.bb:moveTo(player.position.x + 48 - 40, player.position.y+56)
    end
end

function PlayerAttack:collide(node, dt, mtv_x, mtv_y)
    if not node then return end
    if self.dead then return end
    
    --implement hug button action
    if node.isPlayer then return end

    local tlx,tly,brx,bry = self.bb:bbox()
    
    local flip = self.player.character.direction == 'right' and 'false' or 'true'
    local x_offset = flip == 'true' and brx - tlx or 0
    
    local attackNode = { x = tlx - x_offset, y = tly,
                        properties = {
                            sheet = 'images/characters/attack.png',
                            height = 40, width = 40,
                            flip = flip
                          }
                        }
    if node.hurt then
        local knockback = self.player.punchKnockback and (self.player.character.direction == 'right' and 30 or -30) or nil
        sound.playSfx('punch')
        local attackSprite = Sprite.new(attackNode, self.collider)
        attackSprite.containerLevel = Gamestate.currentState()
        attackSprite.containerLevel:addNode(attackSprite)
        Timer.add(0.1,function ()
            attackSprite.containerLevel:removeNode(attackSprite)
        end)
        node:hurt(self.damage, nil, knockback)
        self:deactivate()
    end
end

function PlayerAttack:activate(damage)
    self.damage = damage or 1
    self.dead = false
    self.collider:setSolid(self.bb)
end

function PlayerAttack:deactivate()
    self.dead = true
    self.collider:setGhost(self.bb)
end

return PlayerAttack
