-- Widgets
require("vicious")

-- {{{ Wibox
-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)

spacer = widget({ type = "textbox" })
spacer.width = 3
-- }}}

-- {{{ CPU usage
cpugraph_enable = true -- Show CPU graph
-- cpu icon
vicious.cache(vicious.widgets.cpu)
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
if cpugraph_enable then
	-- Initialize widget
	cpugraph  = awful.widget.graph()

	-- Graph properties
	cpugraph:set_width(40):set_height(16)
	cpugraph:set_background_color(beautiful.fg_off_widget)
	cpugraph:set_gradient_angle(0):set_gradient_colors({
	   beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
	})

	-- Register graph widget
	vicious.register(cpugraph,  vicious.widgets.cpu, "$1")
end
cpuwidget = widget({ type = "textbox" }) -- initialize
vicious.register(cpuwidget, vicious.widgets.cpu,
	function(w, args)
		return string.format("%3d%% %3d%% %3d%% %3d%%", args[2], args[3], args[4], args[5])
	end, 3) -- register
-- }}}

-- {{{ Memory usage
vicious.cache(vicious.widgets.mem)
membar_enable = true -- Show memory bar
memtext_format = " $1%" -- %1 percentage, %2 used %3 total %4 free
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)

if membar_enable then
	-- Initialize widget
	membar = awful.widget.progressbar()
	-- Pogressbar properties
	membar:set_vertical(true):set_ticks(true)
	membar:set_height(16):set_width(8):set_ticks_size(2)
	membar:set_background_color(beautiful.fg_off_widget)
	membar:set_gradient_colors({ beautiful.fg_widget,
	   beautiful.fg_center_widget, beautiful.fg_end_widget
	}) -- Register widget
	vicious.register(membar, vicious.widgets.mem, "$1", 13)
end

-- mem text output
memtext = widget({ type = "textbox" })
vicious.register(memtext, vicious.widgets.mem, memtext_format, 13)
-- }}}



-- {{{ Network usage
networks = {'eth0', 'wlan0'} -- add your devices network interface here netwidget, only shows first one thats up.
function print_net(name, down, up)
	return string.format('<span color="%s">%6s↓</span> <span color="%s">%6s↑</span>', beautiful.fg_netdn_widget, down, beautiful.fg_netup_widget, up)
--	return '<span color="'
--	.. beautiful.fg_netdn_widget ..'">' .. down .. '</span> <span color="'
--	.. beautiful.fg_netup_widget ..'">' .. up  .. '</span>'
end

neticon = widget({ type = "imagebox" })
-- dnicon = widget({ type = "imagebox" })
-- upicon = widget({ type = "imagebox" })

-- Initialize widget
netwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(netwidget, vicious.widgets.net,
	function (widget, args)
		for _,device in pairs(networks) do
			if tonumber(args["{".. device .." carrier}"]) > 0 then
				netwidget.found = true
				neticon.image = image(beautiful.widget_network)
				--dnicon.image = image(beautiful.widget_net)
				--upicon.image = image(beautiful.widget_netup)
				return print_net(device, args["{"..device .." down_kb}"], args["{"..device.." up_kb}"])
			end
		end
	end, 3)
-- }}}


-- {{{ Date and time
--mytextclock = awful.widget.textclock({ align = "right" })
-- Create a textclock widget
date_format = "%a %Y-%m-%d %H:%M - %s" -- refer to http://en.wikipedia.org/wiki/Date_(Unix) specifiers
dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, date_format, 61)
-- }}}

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
												  c.opacity = 1
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        datewidget, dateicon,
	--dnicon.image and separator, upicon, netwidget, dnicon or nil,
	separator, netwidget, neticon or nil,
	separator, cpugraph_enable and cpugraph.widget or nil, cpuwidget, cpuicon,
	separator, memtext, membar_enable and membar.widget or nil, memicon,
	separator,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
