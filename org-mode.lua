----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
--  * Derived from org-awesome, copyright of Damien Leone
----------------------------------------------------------

local M = {
   data = {
      past   = 0,
      today  = 0,
      soon   = 0,
      future = 0,
   }
}

-- {{{ OrgMode widget type
local function collect(  )
   -- Compute delays
   local today  = os.time{ year=os.date("%Y"), month=os.date("%m"), day=os.date("%d") }
   local soon   = today + 24 * 3600 * 3 -- 3 days ahead is close
   local future = today + 24 * 3600 * 7 -- 7 days ahead is maximum

   -- Get data from agenda files
   for i=1, #M.files do
      local f = io.open( M.files[ i ] )

      if f ~= nil then
         -- Parse the agenda
         for line in f:lines() do
            local scheduled = string.find(line, "SCHEDULED:")
            local closed    = string.find(line, "CLOSED:")
            local deadline  = string.find(line, "DEADLINE:")

            if (scheduled and not closed) or (deadline and not closed) then
               local b, e, y, m, d = string.find(line, "(%d%d%d%d)-(%d%d)-(%d%d)")

               -- Enumerate agenda items
               if b then
                  local t = os.time{ year = y, month = m, day = d }

                  if t < today then
                     M.data.past = M.data.past + 1
                  elseif t == today then
                     M.data.today = M.data.today + 1
                  elseif t <= soon then
                     M.data.soon = M.data.soon + 1
                  elseif t <= future then
                     M.data.future = M.data.future + 1
                  end
               end
            end
         end
         f:close()
      end
   end
end

local function start( args )
   M.files = args and args.files or {}
   M.widget = args and args.widget or stats.util.new_textbox()

   local fupdate = args and args.fupdate or
   function (  )
      M.collect()
      M.widget.text = stats.util.markup.fg.color( "#ff0000", stats.util.markup.bold( M.data.past ) )
         .. '/'
      .. stats.util.markup.fg.color( "#ff9999", stats.util.markup.bold( M.data.today ) )
      .. '/'
      .. stats.util.markup.fg.color( "#00dd00", M.data.soon )
   .. '/'
      .. stats.util.markup.fg.color( "#009900", M.data.future )
   end

   fupdate()

   M.timer = timer({ timeout = args and args.timeout or 300 })
   M.timer:add_signal( "timeout", fupdate )
   M.timer:start()

   return M.widget
end

local function stop(  )
   M.timer:stop()
end

M.collect = collect
M.start = start
M.stop = stop

return M
-- }}}
