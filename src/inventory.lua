-----------------------------------------------------------------------
-- inventory.lua
-- Manages the player's currently held items
-----------------------------------------------------------------------

local anim8     = require 'vendor/anim8'
local sound     = require 'vendor/TEsound'
local camera    = require 'camera'
local debugger  = require 'debugger'
local json      = require 'hawk/json'
local GS        = require 'vendor/gamestate'
local fonts     = require 'fonts'
local utils = require 'utils'
local Item = require 'items/item'

local Inventory = {}
Inventory.__index = Inventory

--Load in all the sprites we're going to be using.
local sprite = love.graphics.newImage('images/inventory/inventory.png')
local scrollSprite = love.graphics.newImage('images/inventory/scrollbar.png')
local selectionSprite = love.graphics.newImage('images/inventory/selectionBadge.png')

selectionSprite:setFilter('nearest', 'nearest')
sprite:setFilter('nearest', 'nearest')
scrollSprite:setFilter('nearest','nearest')

--The animation grids for different animations.
local animGrid = anim8.newGrid(200, 210, sprite:getWidth(), sprite:getHeight())
local scrollGrid = anim8.newGrid(10,80, scrollSprite:getWidth(), scrollSprite:getHeight())

---
-- Creates a new inventory
-- @return inventory
function Inventory.new( player )
    local inventory = {}
    setmetatable(inventory, Inventory)
    
    inventory.player = player

    --These variables keep track of whether the inventory is open
    inventory.visible = false

    --These flags keep track of whether certain keys were down the last time we checked. This is necessary to only do actions once when the player presses something.
    inventory.openKeyWasDown = false
    inventory.rightKeyWasDown = false
    inventory.leftKeyWasDown = false
    inventory.upKeyWasDown = false
    inventory.downKeyWasDown = false
    inventory.selectKeyWasDown = false


    inventory.pageList = {
        weapons = {'keys','scrolls'},
        keys = {'materials','weapons'},
        materials = {'consumables','keys'},
        consumables = {'scrolls','materials'},
        scrolls = {'weapons','consumables'}
    } --Each key's value is a table with this format: {nextpage, previouspage} 

    inventory.pages = {} --These are the pages in the inventory that hold items
    for i in pairs(inventory.pageList) do
        inventory.pages[i] = {}
    end

    inventory.currentPageName = 'materials' --Initial inventory page

    inventory.cursorPos = {x=0,y=0} --The position of the cursor.
    inventory.selectedWeaponIndex = 1 --The index of the item on the weapons page that is selected as the current weapon.

    inventory.animState = 'closed' --The current animation state.

    --These are all the different states of the box and their respective animations.
    inventory.animations = {
        opening = anim8.newAnimation('once', animGrid('1-5,1'),0.05), --The box is currently opening
        open = anim8.newAnimation('once', animGrid('6,1'), 1), --The box is open.
        closing = anim8.newAnimation('once', animGrid('1-5,1'),0.02), --The box is currently closing.
        closed = anim8.newAnimation('once', animGrid('1,1'),1) --The box is fully closed. Strictly speaking, this animation is not necessary as the box is invisible when in this state.
    }
    inventory.animations['closing'].direction = -1 --Sort of a hack, these two lines allow the closing animation to be the same as the opening animation, but reversed.
    inventory.animations['closing'].position = 5

    inventory.scrollAnimations = {
        anim8.newAnimation('once', scrollGrid('1,1'),1),
        anim8.newAnimation('once', scrollGrid('2,1'),1),
        anim8.newAnimation('once', scrollGrid('3,1'),1),
        anim8.newAnimation('once', scrollGrid('4,1'),1)
    } --The animations for the scroll bar.

    inventory.scrollbar = 1
    inventory.pageLength = 14

    return inventory
end

---
-- Updates the inventory with player input
-- @param dt the delta time for updating the animation.
-- @return nil
function Inventory:update( dt )
    if not self.visible then return end

    --Update the animations
    self:animation():update(dt)

    self:animUpdate()
end

---
-- Finishes animations
-- @return nil
function Inventory:animUpdate()
    --If we're finished with an animation, then in some cases that means we should move to the next one.
    if self:animation().status == "finished" then
        if self.animState == "closing" then
            self:animation():gotoFrame(5)
            self:animation():pause()
            self.visible = false
            self.animState = 'closed'
            self.cursorPos = {x=0,y=0}
            self.scrollbar = 1
            self.player.freeze = false
        elseif self.animState == "opening" then
            self:animation():gotoFrame(1)
            self:animation():pause()
            self.animState = 'open'
        end
    end
end

---
-- Gets the inventory's animation
-- @return animation
function Inventory:animation()
    assert(self.animations[self.animState], "State " .. self.animState .. " does not have a coorisponding animation!")
    return self.animations[self.animState]
end

---
-- Draws the inventory to the screen
-- @param playerPosition the coordinates to draw offset from
-- @return nil
function Inventory:draw( playerPosition )
    if not self.visible then return end

    --The default position of the inventory
    local pos = {x=playerPosition.x - (animGrid.frameWidth + 6),y=playerPosition.y - (animGrid.frameHeight - 22)}

    --Adjust the default position to be on the screen, and off the HUD.
    local hud_right = camera.x + 260
    local hud_top = camera.y + 120
    if pos.x < 0 then
        pos.x = playerPosition.x + --[[width of player--]] 96 + 12
    end
    if pos.x < hud_right and pos.y < hud_top then
        pos.y = hud_top
    end
    if pos.y < 0 then pos.y = 0 end

    --Draw the main body of the inventory screen
    self:animation():draw(sprite, pos.x, pos.y)
    
    --Only draw other elements if the inventory is fully open
    if (self:isOpen()) then
        --Draw the name of the window
        fonts.set('small')
        
        love.graphics.print('Items', pos.x + 8, pos.y + 7)
        love.graphics.print(self.currentPageName:gsub("^%l", string.upper), pos.x + 36, pos.y + 42, 0, 0.9, 0.9)
        
        --Draw the scroll bar
        self.scrollAnimations[self.scrollbar]:draw(scrollSprite, pos.x + 16, pos.y + 86)

        --Stands for first frame position, indicates the position of the first item slot (top left) on screen
        local ffPos = {x=pos.x + 58,y=pos.y + 60} 


        love.graphics.draw(selectionSprite, 
        love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()), (ffPos.x-34) + self.cursorPos.x * 76, ffPos.y + self.cursorPos.y * 36)


        --Draw all the items in their respective slots
        for i=0,7 do
            local scrollIndex = i + ((self.scrollbar - 1) * 2) + 1
            local indexDisplay = debugger.on and scrollIndex or nil
            if self:currentPage()[scrollIndex] then
                local slotPos = self:slotPosition(i)
                local item = self:currentPage()[scrollIndex]
                item:draw({x=slotPos.x+ffPos.x,y=slotPos.y + ffPos.y}, indexDisplay)
            end
        end
    end
    fonts.revert() -- Changes back to old font
end

---
-- Handles player input while in the inventory
-- @return nil
function Inventory:keypressed( button )
    local keys = {
        UP = self.up,
        DOWN = self.down,
        RIGHT = self.right,
        LEFT = self.left,
        SELECT = self.close,
        START = self.close,
        INTERACT = self.drop,
        JUMP = self.select
    }
    if self:isOpen() and keys[button] then keys[button](self) end
end

---
-- Opens the inventory.
-- @return nil
function Inventory:open()
    self.player.controlState:inventory()
    self.visible = true
    self.animState = 'opening'
    self:animation():resume()
end


---
-- Determines whether the inventory is currently open
-- @return bool
function Inventory:isOpen()
    return self.animState == 'open'
end

---
-- Begins closing the players inventory
-- @return nil
function Inventory:close()
    self.player.controlState:standard()
    self.pageNext = self.animState
    self.animState = 'closing'
    self:animation():resume()
end

---
-- Moves the cursor right
-- @return nil
function Inventory:right()
    if self.cursorPos.x > 1 then self.cursorPos.y = 1 end
    if self.cursorPos.x < 1 then
        self.cursorPos.x = self.cursorPos.x + 1
    else
        self:switchPage(1)
        self.cursorPos.x = 0
    end
end

---
-- Moves the cursor left
-- @return nil
function Inventory:left()
    if self.cursorPos.x > 1 then self.cursorPos.y = 1 end
    if self.cursorPos.x > 0 then
        self.cursorPos.x = self.cursorPos.x - 1
    else
        self:switchPage(2)
        self.cursorPos.x = 1
    end
end

---
-- Switches inventory pages
-- @param direction 1 or 2 for next or previous page respectively
-- @return nil
function Inventory:switchPage( direction )
    self.scrollbar = 1
    local nextState = self.pageList[self.currentPageName][direction]
    assert(nextState, 'Inventory page switch error')
    self.currentPageName = nextState
end


---
-- Moves the cursor up
-- @return nil
function Inventory:up()
    if self.cursorPos.y == 0 then
        if self.scrollbar > 1 then
            self.scrollbar = self.scrollbar - 1
        end
        return
    end
    self.cursorPos.y = self.cursorPos.y - 1
end

---
-- Moves the cursor down
-- @return nil
function Inventory:down()
    if self.cursorPos.y == 3 then
        if self.scrollbar < 4 then
            self.scrollbar = self.scrollbar + 1
        end
        return
    end
    self.cursorPos.y = self.cursorPos.y + 1
end

---
-- Drops the currently selected item and adds a node at the player's position.
-- @return nil
function Inventory:drop()
    if self.currentPageName == 'keys' then return end --Ignore dropping for keys
    local slotIndex = self:slotIndex(self.cursorPos)
    if self.pages[self.currentPageName][slotIndex] then
        local level = GS.currentState()
        local item = self.pages[self.currentPageName][slotIndex]
        local itemProps = item.props

        local type = itemProps.type
        
        if (itemProps.subtype == 'projectile' or itemProps.subtype == 'ammo') and type ~= 'scroll' then
            type = 'projectile'
        end

        local NodeClass = require('/nodes/' .. type)
        
        --local height = item.image:getHeight() - 15

        itemProps.width = itemProps.width or item.image:getWidth()
        itemProps.height = itemProps.height or 24

        itemProps.x = self.player.position.x + 10
        itemProps.y = self.player.position.y + 24 + (24 - itemProps.height)
        itemProps.properties = {foreground = false}

        local myNewNode = NodeClass.new(itemProps, level.collider)

        if myNewNode then
        -- Must set the quantity after creating the Node.
            myNewNode.quantity = item.quantity or 1
            assert(myNewNode.draw, 'ERROR: ' .. myNewNode.name ..  ' does not have a draw function!')
            level:addNode(myNewNode)
            assert(level:hasNode(myNewNode), 'ERROR: Drop function did not properly add ' .. myNewNode.name .. ' to the level!')--]]
            self:removeItem(slotIndex, self.currentPageName)
            if myNewNode.drop then
                myNewNode:drop(self.player)
                
                -- Throws the weapon when dropping it
                -- velocity.x is based off direction
                -- velocity.y is constant from being thrown upwards
                myNewNode.velocity = {x = (self.player.character.direction == 'left' and -1 or 1) * 100,
                                      y = -200,
                                     }
            end
            sound.playSfx('click')
        end
    end
end

---
-- Adds an item to the player's inventory
-- @param item the item to add
-- @param sfx optional bool that toggles the 'pickup' sound
-- @return bool representing successful add
function Inventory:addItem(item, sfx)
    local pageName = item.type .. 's'
    assert(self.pages[pageName], "Bad Item type! " .. item.type .. " is not a valid item type.")
    if self:tryMerge(item) then 
        if sfx ~= false then
            sound.playSfx('pickup')
        end
        return true --If we had a complete successful merge with no remainders, there is no reason to add the item.
    end 
    local slot = self:nextAvailableSlot(pageName)
    if not slot then
        if sfx ~= false then 
            sound.playSfx('dbl_beep')
        end
        return false
    end
    self.pages[pageName][slot] = item
    if sfx ~= false then
        sound.playSfx('pickup')
    end
    return true
end

--- 
-- Removes the item in the given slot
-- @parameter slotIndex the index of the slot to remove from
-- @parameter pageName the page where the item resides
-- @return nil
function Inventory:removeItem( slotIndex, pageName )
    local item = self.pages[pageName][slotIndex]
    if self.player.currently_held and item and self.player.currently_held.name == item.name then
        self.player.currently_held:deselect()
    end
    self.pages[pageName][slotIndex] = nil
end

---
-- Removes all inventory items
-- @return nil
function Inventory:removeAllItems()
  for page in pairs(self.pages) do
    self.pages[page] = {}
  end
end
---
-- Removes a certain amount of items from the player
-- @parameter amount amount to remove
-- @parameter itemToRemove the item to remove, for example: {name="bone", type="material"}
-- @return nil
function Inventory:removeManyItems(amount, itemToRemove)
    if amount == 0 then return end
    local count = self:count(itemToRemove)
    if amount > count then
        amount = count
    end
    for i = 1, amount do
        playerItem, pageIndex, slotIndex = self:search(itemToRemove)
        if self.pages[pageIndex][slotIndex].quantity > 1 then
            playerItem.quantity = playerItem.quantity - 1
        elseif self.pages[pageIndex][slotIndex].quantity == 1 then
            self:removeItem(slotIndex, pageIndex)
        end
    end
end

---
-- Finds the first available slot on the page.
-- @param pageName the page to search
-- @return index of first available inventory slot in pageName or nil if none available
function Inventory:nextAvailableSlot( pageName )
    local currentPage = self.pages[pageName]
    for i=1, self.pageLength do
        if currentPage[i] == nil then
            return i
        end
    end
end

---
-- Gets the position of a slot relative to the top left of the first slot
-- @param slotIndex the index of the slot to find the position of
-- @return the slot's x/y coordinates relative to ffPos
function Inventory:slotPosition( slotIndex )
    yPos = math.floor(slotIndex / 2) * 18 + 1
    xPos = slotIndex % 2 * 38 + 1
    return {x = xPos, y = yPos}
end

---
-- Gets the current page
-- @return the current page
function Inventory:currentPage()
    assert(self:isOpen(), "Inventory is closed, you cannot get the current page when inventory is closed.")
    local page = self.pages[self.currentPageName]
    assert(page, "Could not find page ".. self.currentPageName)
    return page
end

---
-- Searches the inventory for a key
-- @return true if the player has the key or a 'master' key, else nil
function Inventory:hasKey( keyName )
    for slot,key in pairs(self.pages.keys) do
        if key.name == keyName or key.name == "master" then
            return true
        end
    end
end

function Inventory:hasMaterial( materialName )
    for slot,material in pairs(self.pages.materials) do
        if material.name == materialName then
            return true
        end
    end
end

function Inventory:hasConsumable( consumableName )
    for slot,consumable in pairs(self.pages.consumables) do
        if consumable.name == consumableName then
            return true
        end
    end
end

---
-- Gets the currently selected weapon
-- @return the currently selected weapon
function Inventory:currentWeapon()
    if self.selectedWeaponIndex <= self.pageLength then
        local selectedWeapon = self.pages.weapons[self.selectedWeaponIndex]
        return selectedWeapon
    elseif self.selectedWeaponIndex > self.pageLength then
        local selectedWeapon = self.pages.scrolls[self.selectedWeaponIndex - self.pageLength]
        return selectedWeapon
    end
end

---
-- Gets the index of a given cursor position
-- @return the slot index corresponding to the position
function Inventory:slotIndex( slotPosition )
    return slotPosition.x + ((slotPosition.y + self.scrollbar - 1) * 2) + 1
end

---
-- Handles the player selecting a slot in their inventory
-- @return nil
function Inventory:select()
    if self.currentPageName == 'weapons' then self:selectCurrentWeaponSlot() end
    if self.currentPageName == 'scrolls' then self:selectCurrentScrollSlot() end
    if self.currentPageName == 'consumables' then self:consumeCurrentSlot() end
    if self.currentPageName == 'materials' then return end
end

---
-- Selects the current slot as the selected weapon
-- @return nil
function Inventory:selectCurrentWeaponSlot()
    self.selectedWeaponIndex = self:slotIndex(self.cursorPos)
    local weapon = self.pages.weapons[self.selectedWeaponIndex]
    self.player:selectWeapon(weapon)
    self.player.doBasicAttack = false
end

---
-- Selects the current slot as the selected weapon
-- @return nil
function Inventory:selectCurrentScrollSlot()
    local index = self:slotIndex(self.cursorPos)
    self.selectedWeaponIndex = index + self.pageLength
    local scroll = self.pages.scrolls[index]
    self.player:selectWeapon(scroll)
    self.player.doBasicAttack = false
end

---
-- Consumes the currently selected consumable
-- @return nil
function Inventory:consumeCurrentSlot()
    self.selectedConsumableIndex = self:slotIndex(self.cursorPos)
    local consumable = self.pages.consumables[self.selectedConsumableIndex]
    if consumable then
        consumable:use(self.player)
        sound.playSfx('confirm')
    end
end

---
-- Tries to select the next available weapon
-- @return nil
function Inventory:tryNextWeapon()
    local i = self.selectedWeaponIndex + 1
    while i ~= self.selectedWeaponIndex do
        if self.pages.weapons[i] then
            self.selectedWeaponIndex = i
            break
        end
        if i < self.pageLength then 
            i = i + 1
        else 
            i = 1 
        end
    end
end

--- 
-- Tries to merge the item with one that is already in the inventory.
-- @return bool representing complete merger (true) or remainder (false)
function Inventory:tryMerge( item )
    for i,itemInSlot in pairs(self.pages[item.type ..'s']) do
        if itemInSlot and itemInSlot.name == item.name and itemInSlot.mergible and itemInSlot:mergible(item) then
        --This statement does a lot more than it seems. First of all, regardless of whether itemInSlot:merge(item) returns true or false, some merging is happening. If it returned false
        --then the item was partially merged, so we are getting the remainder of the item back to continue to try to merge it with other items. If it returned true, then we got a
        --complete merge, and we can stop looking right now.
            if itemInSlot:merge(item) then 
                return true
            end
        end
    end
    return false
end

---
--Searches inventory for the first instance of "item" and returns that item.
--@return the first item found, its page index value, and its slot index value. else, returns nil
function Inventory:search( item )
    local page = item.type .. "s"
    for i,itemInSlot in pairs(self.pages[page]) do
        if itemInSlot and itemInSlot.name == item.name then
            return itemInSlot, page, i
        end
    end
end

---
--Searches inventory and counts the total number of "item"
--@return number of "item" in inventory
function Inventory:count( item )
    local count = 0
    for i,itemInSlot in pairs(self.pages[item.type ..'s']) do
        if itemInSlot and itemInSlot.name == item.name then
            count = count + itemInSlot.quantity
        end
    end
    return count
end

return Inventory
