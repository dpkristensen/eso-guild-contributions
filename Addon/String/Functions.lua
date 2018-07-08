--[[
    String Functions

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local MSG_PREFIX = "|c00ff00"..GC.ADDON_NAME.."|r: "

-- Print text to the system console
function GC.Print( aText )
    d( MSG_PREFIX..tostring( aText ) );
end

-- Print a localized message to the system console
function GC.Msg( aId )
    GC.Print( GC.S( aId ) );
end

-- Print a localized message to the system console with a parameter
function GC.MsgP( aId, aSuffix )
    GC.Print( GC.S( aId )..": "..aSuffix );
end
