-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.magnifier,
-- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
-- awful.layout.suit.tile.top,
-- awful.layout.suit.fair,
-- awful.layout.suit.fair.horizontal,
-- awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max
-- awful.layout.suit.max.fullscreen,
}
-- }}}

-- {{{ Tags
tagconfig =
{
	{ -- Screen 1
	names = { 1, 2, 3, 4, 5, 6 },
	layouts = { layouts[2], layouts[3], layouts[1], layouts[1], layouts[1], layouts[1] }
	},
	{ -- Screen 2
	names = { 1, 2, 3, 4, 5, 6 },
	layouts = { layouts[3], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
	}
}
tags = { }
for s = 1, screen.count() do
    -- Each screen has its own tag table
    if tagconfig[s] then
        tags[s] = awful.tag(tagconfig[s].names, s, tagconfig[s].layouts)
    else
        tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    end
end
-- }}}
