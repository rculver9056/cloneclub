# HAWK 2d Platformer Framework

HAWK is a set of modules on top of LOVE that are needed to make modern 2d
platformers. Note that many of these modules are written outside of HAWK, we
just provide distribution


## assets

HAWK provides simple assert management. Never create multiple images again

## scene

HAWK provides a 2d scene graph.

## configuration

HAWK provides configuration into your game

## maps

HAWK supports loading and drawing tile-based maps out of the box. We currently
only support TMX maps, but plan to add more in the future.

## json

HAWK provides JSON support using JSON4Lua version 0.9.40

```lua
local json = require 'hawk/json'
local contents = {"foo", "bar"}
json.encode(contents)
```
