-- {{{ Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
	  properties = { border_width = beautiful.border_width,
					 border_color = beautiful.border_normal,
					 focus = true,
					 keys = clientkeys,
					 buttons = clientbuttons } },
	{ rule = { class = "MPlayer" },
	  properties = { floating = true } },
	{ rule = { class = "pinentry" },
	  properties = { floating = true } },
	{ rule = { class = "gimp" },
	  properties = { floating = true } },
	{ rule = { class = "Empathy" },
	  properties = { tag = tags[1][2] } },
	{ rule = { class = "empathy" },
	  properties = { tag = tags[1][2] } },
	{ rule = { instance = "Empathy" },
	  properties = { tag = tags[1][2] } },
	{ rule = { instance = "empathy" },
	  properties = { tag = tags[1][2] } },
	{ rule = { role = "contact_list" },
	  properties = { tag = tags[1][2] } },
	{ rule = { class = "Google-chrome" },
	  properties = { border_width = 0 } },

	-- Set Firefox to always map on tags number 2 of screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { tag = tags[1][2] } },
}
-- }}}

require("autofocus")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
	-- Add a titlebar
	-- awful.titlebar.add(c, { modkey = modkey })

	-- Enable sloppy focus
	c:add_signal("mouse::enter", function(c)
--		if awful.client.focus.filter(c) and awful.layout.get(c.screen) == awful.layout.suit.magnifier then
--			io.stderr:write("Client X:" .. c:geometry().x .. "\n")
--			io.stderr:write("Client Screen:" .. c.screen .. "\n")
--			io.stderr:write("Screen x:" .. screen[c.screen].workarea.x .. "\n\n")
--		end

		c.opacity = 1

		if awful.client.focus.filter(c) and
		(
		awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		or
		(c:geometry().x - screen[c.screen].workarea.x) > 0
		-- I want magnifier to have slopy focus for the center window too!
		) then
			client.focus = c
		end
	end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)

client.add_signal("focus",
	function(c)
		c.border_color = beautiful.border_focus
--		io.stderr:write("Focus " .. c.class .. " Opacity: " .. c.opacity .. " -> ")
		c.opacity = .9
		c.opacity = 1
--		io.stderr:write("" .. c.opacity .. "\n")
	end)
client.add_signal("unfocus",
	function(c)
		c.border_color = beautiful.border_normal
--		io.stderr:write("Unfocus " .. c.class .. " Opacity: " .. c.opacity .. " -> ")
		c.opacity = 1
		c.opacity = 0.8
--		io.stderr:write("" .. c.opacity .. "\n")
	end)
-- }}}
