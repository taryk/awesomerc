---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2013, Taras Iagniuk <mrtaryk@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
local awful = require("awful")
local string = string
-- }}}

-- MyGmail: provides count of new and subject of last e-mail on Gmail
module("mygmail")

-- Default is just Inbox
local mail = {
    ["count"]   = 0,
    ["tooltip"] = "N/A"
}

-- {{{ Gmail widget type
local function worker(format, warg)
    local f = io.open(awful.util.getdir("config") .. "/perl/mail.dump", "rb")
    total_unseen = f:read()
    local count = tonumber(string.match(total_unseen, "total_unseen: ([%d]+)"))
    output = f:read("*all")
    mail["count"] = count or mail["count"]
    mail["tooltip"] = output or mail["tooltip"]
    f:close()
    return mail
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
