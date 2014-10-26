---{{{ Functions
-- {{{ Handle dual screens
-- Autostart
function autostart(dir)
    if not dir then
        do return nil end
    end
    local fd = io.popen("ls -1 -F " .. dir)
    if not fd then
        do return nil end
    end
    for file in fd:lines() do
        local c= string.sub(file,-1)   -- last char
        if c=='*' then  -- executables
            -- @TODO: fixme
            executable = string.sub( file, 1,-2 )
            print("Awesome Autostart: Executing: " .. executable)
            awful.util.spawn_with_shell(dir .. "/" .. executable .. "") -- launch in bg
        elseif c=='@' then  -- symbolic links
            print("Awesome Autostart: Not handling symbolic links: " .. file)
        else
            print ("Awesome Autostart: Skipping file " .. file .. " not executable.")
        end
    end
    io.close(fd)
end

autostart_dir = os.getenv("HOME") .. "/.config/autostart"
autostart(autostart_dir)
-- }}}

-- split function
function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--Marup functions
--- {{{ splitbywhitespace stolen from wicked.lua
function splitbywhitespace(str)
    values = {}
    start = 1
    splitstart, splitend = string.find(str, ' ', start)

    while splitstart do
      m = string.sub(str, start, splitstart-1)
      if m:gsub(' ','') ~= '' then
        table.insert(values, m)
      end

      start = splitend+1
      splitstart, splitend = string.find(str, ' ', start)
    end

    m = string.sub(str, start)
    if m:gsub(' ','') ~= '' then
      table.insert(values, m)
    end

    return values
end
---}}}

spacer = ' '

function setBg(color, text)
   return '<bg color="'..color..'" />'..text
end

function setFg(color, text)
   return '<span color="'..color..'">'..text..'</span>'
end

function setBgFg(bgcolor, fgcolor, text)
   return '<bg color="'..bgcolor..'" /><span color="'..fgcolor..'">'..text..'</span>'
end

function setFont(font, text)
   return '<span font_desc="'..font..'">'..text..'</span>'
end

---- Layouttext function
function returnLayoutText(layout)
   return setFg(beautiful.fg_focus, " | ")..layoutText[layout]..setFg(beautiful.fg_focus, " | ")
end

---- Widget functions
-- Clock
function clockInfo(dateformat, timeformat)
   local date = os.date(dateformat)
   local time = os.date(timeformat)

   clockwidget.text = spacer..date..spacer..setFg(beautiful.fg_focus, time)..spacer
end

-- Wifi signal strength
function wifiInfo(adapter)
   local f = io.open("/sys/class/net/"..adapter.."/wireless/link")
   local wifiStrength = f:read()
   f:close()

   if wifiStrength == "0" then
      wifiStrength = setFg("#ff6565", wifiStrength.."%")
      naughty.notify({ title = "Wifi Warning"
                       , text = "Wireless Network is Down! ("..wifiStrength.."% connectivity)"
                       , timeout = 3
                       , position = "top_right"
                       , fg = beautiful.fg_focus
                       , bg = beautiful.bg_focus
                 })
   else
      wifiStrength = wifiStrength.."%"
   end

   wifiwidget.text = spacer..setFg(beautiful.fg_focus, "Wifi:")..spacer..wifiStrength..spacer
end

-- Battery(BAT1)
function batteryInfo(adapter)
   local fcur = io.open("/sys/class/power_supply/"..adapter.."/charge_now")
   local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
   local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
   local cur = fcur:read()
   fcur:close()
   local cap = fcap:read()
   fcap:close()
   local sta = fsta:read()
   fsta:close()

   local battery = math.floor(cur * 100 / cap)

   if sta:match("Charging") then
      dir = "^"
      battery = "A/C"..spacer.."("..battery..")"
   elseif sta:match("Discharging") then
      dir = "v"
      if tonumber(battery) >= 25 and tonumber(battery) <= 50 then
         battery = setFg("#e6d51d", battery)
      elseif tonumber(battery) < 25 then
         if tonumber(battery) <= 10 then
            naughty.notify({ title = "Battery Warning"
                             , text = "Battery low!"..spacer..battery.."%"..spacer.."left!"
                             , timeout = 5
                             , position = "top_right"
                             , fg = beautiful.fg_focus
                             , bg = beautiful.bg_focus
                       })
         end
         battery = setFg("#ff6565", battery)
      else
         battery = battery
      end
   else
      dir = "="
      battery = "A/C"
   end

   batterywidget.text = spacer..setFg(beautiful.fg_focus, "Bat:")..spacer..dir..battery..dir..spacer
end

-- Memory
function memInfo()
  local f = io.open("/proc/meminfo")

  for line in f:lines() do
     if line:match("^MemTotal.*") then
        memTotal = math.floor(tonumber(line:match("(%d+)")) / 1024)
     elseif line:match("^MemFree.*") then
        memFree = math.floor(tonumber(line:match("(%d+)")) / 1024)
     elseif line:match("^Buffers.*") then
        memBuffers = math.floor(tonumber(line:match("(%d+)")) / 1024)
     elseif line:match("^Cached.*") then
        memCached = math.floor(tonumber(line:match("(%d+)")) / 1024)
     end
  end
  f:close()

  memFree = memFree + memBuffers + memCached
  memInUse = memTotal - memFree
  memUsePct = math.floor(memInUse / memTotal * 100)

  memwidget.text = spacer..setFg(beautiful.fg_focus, "Mem:")..spacer..memUsePct.."%"..spacer.."("..memInUse.."M)"..spacer
end

-- current tag name
-- tagname = awful.tag.selected(1).name

-- FS usage
function fsUsage()
   local f = io.popen("/bin/df -h")

   local fs_usage_line = ""

   -- f:lines() == f:read("*line")
   for line in f:lines() do
      if line:match("^/dev/sd.*") then
         fs_info = split(line, '%s+')
         fs_usage_line = fs_usage_line..spacer..setFg(beautiful.fg_focus, fs_info[6])..spacer..":"..spacer..fs_info[4].."/"..fs_info[2]..spacer
      end
   end

   fswidget.text = fs_usage_line

   f:close()

end

function getCpuCount()
   local f = io.popen("cat /proc/stat | grep -P 'cpu\\d+' | wc -l")
   cpus = f:read()
   f:close()

   return cpus
end

function cpuInfoInit()
   for cpun = 1, getCpuCount() do
      cpu_total[cpun]  = 0
      cpu_active[cpun] = 0
      cpugraphwidget[cpun] = awful.widget.graph()
      cpugraphwidget[cpun]:set_width(60)
      cpugraphwidget[cpun]:set_height(18)
      cpugraphwidget[cpun]:set_max_value(100)
      -- cpugraphwidget[cpun]:set_background_color(beautiful.bg_normal)
      cpugraphwidget[cpun]:set_background_color("#494B4F")
      -- cpugraphwidget[cpun]:set_border_color(beautiful.fg_urgent)
      cpugraphwidget[cpun]:set_border_color("#3A3C3F")
      cpugraphwidget[cpun]:set_gradient_colors({ "red", "cyan" })
      cpugraphwidget[cpun]:set_gradient_angle(90)
   end   
end

function cpuInfo()
   -- Return CPU usage percentage
   -- Get /proc/stat
   local f = io.open('/proc/stat')
   for l in f:lines() do
      local _, _, cpun = string.find(l, "^cpu(%d)")
      if cpun then
         cpun = cpun + 1
         -- print("cpu total: ["..cpun.."]: "..cpu_total[cpun])
         local cpu_usage = splitbywhitespace(l)
         ---- Calculate totals
         local total_new = cpu_usage[2] + cpu_usage[3] + cpu_usage[4] + cpu_usage[5]
         local active_new = cpu_usage[2] + cpu_usage[3] + cpu_usage[4]
         ---- Calculate percentage
         local diff_total = total_new - cpu_total[cpun]
         local diff_active = active_new-cpu_active[cpun]
         local usage_percent = math.floor(diff_active/diff_total*100)
         -- Store totals
         cpu_total[cpun] = total_new
         cpu_active[cpun] = active_new

         cpugraphwidget[cpun]:add_value(usage_percent)
      end
   end
   f:close()
end

---}}}
