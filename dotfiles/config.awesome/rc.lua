-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("revelation")

-- Notification library
require("naughty")

-- Theme
require("beautiful")
beautiful.init(awful.util.getdir("config") .. "/themes/bisho/rc.lua")

-- Mod/Alt keys
altkey = "Mod1"
modkey = "Mod4"

-- Terminal
terminal = "x-terminal-emulator"

-- Load the ui
require('workspaces')
require("menu")
require('mywibox')
require('keymouse')
require('windows')
