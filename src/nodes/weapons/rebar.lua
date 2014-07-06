
-- Creates a new rebar object
-- @return the rebar object created
return{
    hand_x = 45,
    hand_y = 60,
    frameAmt = 3,
    width = 100,
    height = 80,
    dropWidth = 12,
    dropHeight = 68,
    damage = 2,
    dead = false,
    bbox_width = 60,
    bbox_height = 56,
    bbox_offset_x = {42,42,42},
    bbox_offset_y = {6,6,6},
    unuseAudioClip = 'sword_sheathed',
    hitAudioClip = 'punch',
    swingAudioClip = 'sword_air',
    animations = {
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1'},0.11},
    }
}
