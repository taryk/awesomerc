-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- vicious widgets
require("vicious")

-- Load Debian menu entries
require("debian.menu")

-- Load LuaFileSystem
require("lfs")

-- orglendar
--require('orglendar')
loadfile(awful.util.getdir("config").."/functions.lua")()
loadfile(awful.util.getdir("config").."/orglendar.lua")()
loadfile(awful.util.getdir("config").."/mygmail.lua")()
--require('org-awesome')

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config").."/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "emacs24"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    -- 1
    awful.layout.suit.floating,
    -- 2
    awful.layout.suit.tile,
    -- 3
    awful.layout.suit.tile.left,
    -- 4
    awful.layout.suit.tile.bottom,
    -- 5
    awful.layout.suit.tile.top,
    -- 6
    awful.layout.suit.fair,
    -- 7
    awful.layout.suit.fair.horizontal,
    -- 8
    awful.layout.suit.spiral,
    -- 9
    awful.layout.suit.spiral.dwindle,
    -- 10
    awful.layout.suit.max,
    -- 11
    awful.layout.suit.max.fullscreen,
    -- 12
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
-- tags = {}
-- for s = 1, screen.count() do
--     -- Each screen has its own tag table.
--     tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
-- end
-- }}}

-- {{{ Tags
-- Define a tag table which will hold all screen tags.
-- Each screen has its own tag table.
if screen.count() == 1 then

   tags = {
      names  = { "1:skype","2:im","3:www","4:emacs","5:term","6:email","7:music","8:other" },
      layout = {
         layouts[1], -- 1
         layouts[1], -- 2
         layouts[1], -- 3
         layouts[1], -- 4
         layouts[3], -- 5
         layouts[1], -- 6
         layouts[1], -- 7
         layouts[1], -- 8
      }
   }

   tags[1] = awful.tag(tags.names, 1, tags.layout)

elseif screen.count() == 2 then

   tagn = {
      { names  = { "1:term", "2:www", "3:", "4:", "5:", "6:", "7:", "8:", "9:" },
        layout = { layouts[3], layouts[1], layouts[1], layouts[1], layouts[1],
                   layouts[1], layouts[1], layouts[1], layouts[1] } },

      { names  = { "1:skype", "2:email", "3:emacs", "4:term", "5:im", "6:www", "7:audio", "8:" },
        layout = { layouts[1], layouts[1], layouts[1], layouts[3], layouts[1],
                   layouts[1], layouts[1], layouts[1], layouts[1] } }
   }

   tags = {}

   for s = 1, 2 do
      -- Each screen has its own tag table.
      tags[s] = awful.tag(tagn[s].names, s, tagn[s].layout)
      --tag.add_signal("property::selected", function(t)
   end
end

--    screen[1]:add_signal("tag::history::update", function()
--       tagname = awful.tag.selected(1).name
--       os.execute("mkdir /home/taryk/tmp/testdir")
--    end)
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual"      , terminal .. " -e man awesome" },
   { "edit config" , editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart"     , awesome.restart },
   { "quit"        , awesome.quit },
}

computermenu = {
   { "Lock screen" , "xscreensaver-command -lock" },
   { "Suspend"     , "dbus-send --system --print-reply --dest=org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower.Suspend" },
   { "Hibernate"   , "dbus-send --system --print-reply --dest=org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower.Hibernate" },
   { "Reboot"      , "dbus-send --system --print-reply --dest='org.freedesktop.ConsoleKit' /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart" },
   { "Shutdown"    , "dbus-send --system --print-reply --dest='org.freedesktop.ConsoleKit' /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop" },
   -- { "suspend"     , "pm-suspend"   },
   -- { "hibernate"   , "pm-hibernate" },
   -- { "poweroff"    , "poweroff"     },
   -- { "Reboot"      , "dbus-send --system --print-reply --dest=org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower.Restartq" },
   -- { "Shutdown"    , "dbus-send --system --print-reply --dest=org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower.Stop" }   
}

mymainmenu = awful.menu({ items = { { "awesome",  myawesomemenu, beautiful.awesome_icon },
                                    { "Debian",   debian.menu.Debian_menu.Debian },
                                    { "Computer", computermenu  },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox


pspacer = widget({type = "textbox"})
pseparator = widget({type = "textbox"})
pspacer.text = " "
pseparator.text = "|"


-- gmail widget and tooltip
mygmail_widget = widget({ type = "textbox" })
gmail_t = awful.tooltip({ objects = { mygmail_widget },})

mygmail_img = widget({ type = "imagebox" })
mygmail_img.image = image(awful.util.getdir("config").."/icons/gmail_icon_18x.png")

vicious.register(mygmail_widget, mygmail,
                function (widget, args)
                    gmail_t:set_text(args["tooltip"])
                    gmail_t:add_to_object(mygmail_img)
                    return args["count"]
                 end, 60)

-- RAM usage widget
memwidget = awful.widget.progressbar()
memwidget:set_width(15)
memwidget:set_height(18)
memwidget:set_vertical(true)
memwidget:set_background_color('#494B4F')
memwidget:set_color('#AECF96')
memwidget:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
memwidget_info = widget({ type = "textbox" })

-- RAM usage tooltip
memwidget_t = awful.tooltip({ objects = { memwidget.widget },})

vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem,
                function (widget, args)
                    memwidget_t:set_text(" RAM: " .. args[2] .. "MB / " .. args[3] .. "MB ")
                    local perc = math.floor(args[2] / args[3] * 100)
                    memwidget_info.text = perc.."% ("..args[2].."M)"
                    return args[1]
                 end, 2)
                 --update every 13 seconds


-- Keyboard widget
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"

--list your own keyboard layouts here
kbdcfg.layout = { "us","ua" }

kbdcfg.current = 1
kbdcfg.widget = widget({ type = "textbox", align = "right" })
kbdcfg.widget.text = " " .. kbdcfg.layout[kbdcfg.current] .. " "
kbdcfg.switch = function ()
    kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
    local t = " " .. kbdcfg.layout[kbdcfg.current] .. " "
    kbdcfg.widget.text = t
    os.execute( kbdcfg.cmd .. t )
end

kbdcfg.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () kbdcfg.switch() end)
))


-- Volume widget

volumecfg = {}
volumecfg.cardid  = 1
volumecfg.channel = "Master"
volumecfg.widget = widget({ type = "textbox", name = "volumecfg.widget", align = "right" })

volumecfg_t = awful.tooltip({ objects = { volumecfg.widget },})
volumecfg_t:set_text("Volume")

-- command must start with a space!
volumecfg.mixercommand = function (command)
       local fd = io.popen("amixer -c " .. volumecfg.cardid .. command)
       local status = fd:read("*all")
       fd:close()

       local volume = string.match(status, "(%d?%d?%d)%%")
       volume = string.format("% 3d", volume or 0)
       status = string.match(status, "%[(o[^%]]*)%]")
       if string.find(status or "", "on", 1, true) then
               volume = volume .. "%"
       else
               volume = volume .. "M"
       end
       volumecfg.widget.text = volume
end
volumecfg.update = function ()
       volumecfg.mixercommand(" -D pulse sget " .. volumecfg.channel)
end
volumecfg.up = function ()
       volumecfg.mixercommand(" -D pulse set " .. volumecfg.channel .. " 1000+ unmute")
end
volumecfg.down = function ()
       volumecfg.mixercommand(" -D pulse set " .. volumecfg.channel .. " 1000- unmute")
end
volumecfg.toggle = function ()
       volumecfg.mixercommand(" -D pulse set " .. volumecfg.channel .. " toggle")
end
volumecfg.widget:buttons({
       button({ }, 4, function () volumecfg.up() end),
       button({ }, 5, function () volumecfg.down() end),
       button({ }, 1, function () volumecfg.toggle() end)
})
volumecfg.update()


-- Network widget
netwidget = awful.widget.graph()
netwidget:set_width(50)
netwidget:set_height(18)
netwidget:set_background_color("#494B4F")
netwidget:set_color("#FF5656")
netwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })

netwidget_t = awful.tooltip({ objects = { netwidget.widget },})

-- Register network widget
vicious.register(netwidget, vicious.widgets.net,
                    function (widget, args)
                        netwidget_t:set_text("Network download: " .. args["{eth1 down_mb}"] .. "mb/s")
                        return args["{eth1 down_mb}"]
                    end)


-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, " <b>%A %Y.%m.%d %H:%M:%S</b> ", 1)

orglendar.files = { }

-- 
local orgfiles_dir = os.getenv("HOME") .. "/Documents/org/"
for org_file in lfs.dir(orgfiles_dir) do
   if string.match(org_file, "\.org$") then
      table.insert(orglendar.files, orgfiles_dir .. org_file)
   end
end

orglendar.register(mytextclock)

-- -- {{{ PROCESSOR
-- -- cpu graph

-- CPU usage

cpu_total = {}
cpu_active = {}
cpugraphwidget = {}

cpuInfoInit()
cpuInfo()

-- memwidget = widget({ type = "textbox" })
-- memInfo()

fswidget = widget({ type = "textbox" })
fsUsage()

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mywibox2 = {}
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
    mywibox[s] = awful.wibox({ position = "top", height = "18", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock, 
        s == 1 and mysystray or nil, 
        pspacer,

        pseparator, 
        pspacer,

        volumecfg.widget,

        pspacer,
        pseparator, 
        pspacer,

        kbdcfg.widget,
        pspacer,
        pseparator, 
        pspacer,

        netwidget.widget,
        pspacer,
        pseparator, 
        pspacer,

        mygmail_widget,
        pspacer,

        mygmail_img,
        pspacer,
        pseparator,
        pspacer,

        memwidget_info,
        pspacer,

        memwidget.widget,
        pseparator,

        mytasklist[s], 
        --mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }

    mywibox2[s] = awful.wibox({ position = "bottom", height = "18", screen = s }) 

    --- Bottom panel
    bottom_widgets = {}
    -- CPU cores usage
    for cpun = getCpuCount(), 1, -1 do
       table.insert(bottom_widgets, cpugraphwidget[cpun].widget)
       table.insert(bottom_widgets, pspacer)
    end
    bottom_widgets.layout=awful.widget.layout.horizontal.rightleft
    -- Disk usage
    table.insert(
       bottom_widgets, 1,
       {
          fswidget,
          layout = awful.widget.layout.horizontal.leftright,
       }
    )
    mywibox2[s].widgets = bottom_widgets
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
   awful.key({ modkey }, "g",
              function ()
                  awful.prompt.run({ prompt = "Go to Nth: " },
                  promptbox[mouse.screen].widget,
                  function (n)
                     local c = awful.tag.selected():clients()[tonumber(n)]
                     client.focus = c
                     c:raise()
                  end)
              end),
   -- Media keys
   awful.key({ }, "XF86AudioNext",  function ()
                                       awful.util.spawn("clementine -f")
                                    end),
   awful.key({ }, "XF86AudioPrev",  function ()
                                       awful.util.spawn("clementine -r")
                                    end),
   awful.key({ }, "XF86AudioStop",  function ()
                                       awful.util.spawn("clementine -s")
                                    end),
   awful.key({ }, "XF86AudioPlay",  function ()
                                       awful.util.spawn("clementine -t")
                                    end),
   awful.key({ }, "XF86AudioRaiseVolume", function ()
                                             volumecfg.up()
                                          end),
   awful.key({ }, "XF86AudioLowerVolume", function ()
                                             volumecfg.down()
                                          end),
   awful.key({ }, "XF86AudioMute", function () 
                                      volumecfg.toggle()
                                             --awful.util.spawn("amixer sset Master 0") 
                                             --awful.util.spawn("/home/taryk/bin/mixer_notify mute")
                                   end)
   -- awful.key({ }, "Caps_Lock", function ()   kbdcfg.switch() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
    
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

if screen.count() == 1 then
   -- {{{ Rules
   awful.rules.rules = {
       -- All clients will match this rule.
       { rule = { },
         properties = { border_width = beautiful.border_width,
                        border_color = beautiful.border_normal,
                        focus = true,
                        keys = clientkeys,
                        floating = true,
                        buttons = clientbuttons } },
       { rule = { class = "Smplayer" },
         properties = { floating = true, tag = tags[1][8] } },
       { rule = { class = "mplayer" },
         properties = { floating = true, tag = tags[1][8] } },
       { rule = { class = "pinentry" },
         properties = { floating = true } },
       { rule = { class = "Gimp" },
         properties = { floating = true } },
       { rule = { class = "Rxvt" },
         properties = { floating = false, tag = tags[1][5] } },
       { rule = { class = "Thunderbird" },
         properties = { floating = true, tag = tags[1][6] } },
       { rule = { class = "Chromium" },
         properties = { floating = true, tag = tags[1][3] } },
       { rule = { class = "google-chrome" },
         properties = { floating = true, tag = tags[1][3] } },
       { rule = { class = "Firefox" },
         properties = { floating = true, tag = tags[1][3] } },
       { rule = { class = "Skype" },
         properties = { floating = true,  tag = tags[1][1] } },
       { rule = { class = "Emacs" },
         properties = { floating = false, tag = tags[1][4] } },
       { rule = { class = "Clementine" },
         properties = { floating = false, tag = tags[1][7] } },
       { rule = { class = "Gmpc" },
         properties = { floating = false, tag = tags[1][7] } },
       { rule = { class = "Kopete" },
         properties = { floating = true,  tag = tags[1][2] } },
       { rule = { class = "psi" },
         properties = { floating = true,  tag = tags[1][2] } },
       { rule = { class = "Xchat" },
         properties = { floating = true,  tag = tags[1][2] } },
       { rule = { class = "VirtualBox" },
         properties = { floating = true,  tag = tags[1][8] } },
       { rule = { class = "Geeqie" },
         properties = { floating = false, tag = tags[1][8] } },
       { rule = { class = "Okular" },
         properties = { floating = false, tag = tags[1][8] } },
       { rule = { class = "Evince" },
         properties = { floating = false, tag = tags[1][8] } },
       { rule = { class = "Eclipse" },
         properties = { floating = false, tag = tags[1][4] } },
   }
elseif screen.count() == 2 then
      -- {{{ Rules
   awful.rules.rules = {
       -- All clients will match this rule.
       { rule = { },
         properties = { border_width = beautiful.border_width,
                        border_color = beautiful.border_normal,
                        focus = true,
                        keys = clientkeys,
                        floating = true,
                        buttons = clientbuttons } },
       { rule = { class = "Smplayer" },
         properties = { floating = true, tag = tags[2][9] } },
       { rule = { class = "mplayer" },
         properties = { floating = true, tag = tags[2][9] } },
       { rule = { class = "pinentry" },
         properties = { floating = true } },
       { rule = { class = "Gimp" },
         properties = { floating = true } },
       { rule = { class = "Rxvt" },
         properties = { floating = false, tag = tags[2][4] } },
       { rule = { class = "Thunderbird" },
         properties = { floating = false, tag = tags[2][2] } },
       { rule = { class = "Chromium" },
         properties = { floating = true, tag = tags[2][6] } },
       { rule = { class = "google-chrome" },
         properties = { floating = true, tag = tags[2][6] } },
       { rule = { class = "Firefox" },
         properties = { floating = false, tag = tags[2][6] } },
       { rule = { class = "DictLearn" },
         properties = { floating = false, tag = tags[2][6] } },
       { rule = { class = "Skype" },
         properties = { floating = true,  tag = tags[2][1] } },
       { rule = { class = "Emacs" },
         properties = { floating = false, tag = tags[1][2] } },
       { rule = { class = "Clementine" },
         properties = { floating = false, tag = tags[2][7] } },
       { rule = { class = "Gmpc" },
         properties = { floating = false, tag = tags[2][7] } },
       { rule = { class = "Kopete" },
         properties = { floating = true,  tag = tags[2][5] } },
       { rule = { class = "psi" },
         properties = { floating = true,  tag = tags[2][5] } },
       { rule = { class = "Xchat" },
         properties = { floating = true,  tag = tags[2][5] } },
       { rule = { class = "qwit" },
         properties = { floating = true,  tag = tags[2][6] } },
       { rule = { class = "VirtualBox" },
         properties = { floating = true,  tag = tags[2][8] } },
       { rule = { class = "Geeqie" },
         properties = { floating = false, tag = tags[2][7] } },
       { rule = { class = "Eclipse" },
         properties = { floating = false, tag = tags[2][4] } },
       { rule = { class = "Okular" },
         properties = { floating = false, tag = tags[2][6] } },
       { rule = { class = "Evince" },
         properties = { floating = false, tag = tags[2][6] } },
   }
   -- }}}
end
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- dd a titlebar
    if awful.client.floating.get(c) then
         if   c.titlebar then 
         	awful.titlebar.remove(c)
         else 
         	awful.titlebar.add(c, {modkey = modkey, height = "16"}) end
         end
    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
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

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- {{{ Timers
mytimer = timer({ timeout = 1 })
mytimer:add_signal("timeout", 
                   function() 
                      -- memInfo() 
                      fsUsage() 
                      cpuInfo()
                   end )
mytimer:start()
-- }}}

--{{{ Autostart programs
function run_once(prg)
  cmd = split(prg, " ")
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. cmd[1] .. " || (" .. prg .. ")")
end

do
  local cmds = 
  { 
    "urxvt",
    "chromium-browser",
    "thunderbird",
    "emacs24",
    "clementine",
    "xscreensaver -no-splash",
    "parcellite",
    "nm-applet",
    "dropbox start",
    -- "wuala",
    -- "xxkb",
    -- "gmpc",
    -- "ktorrent",
    -- "skype",
    -- and so on...
  }

  for _,i in pairs(cmds) do
    run_once(i);
    --awful.util.spawn(i)
  end
end

--os.execute("urxvt &")
--}}}

