--[[
    Event Hooks

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local function e( aEventCode )
    EVENT_MANAGER:RegisterForEvent( GC.ADDON_NAME, aEventCode, GC.OnEvent );
end

-- EVENT_PLAYER_ACTIVATED handler
function GC.OnPlayerActivated( aEventCode )
    EVENT_MANAGER:UnregisterForEvent( GC.ADDON_NAME, EVENT_PLAYER_ACTIVATED );

    -- Instantiate the App
    GC.AppClass()
end

-- Handler for all other events: Pass to the app
function GC.OnEvent( aEventCode, ... )
    if( GC.APP ) then
        GC.APP:OnEvent( aEventCode, ... )
    else
        GC.Debug( "Unhandled event "..tostring( aEventCode ).." (app not initialized)" )
    end
end

EVENT_MANAGER:RegisterForEvent( GC.ADDON_NAME, EVENT_PLAYER_ACTIVATED, GC.OnPlayerActivated );

e( EVENT_GUILD_SELF_LEFT_GUILD )
e( EVENT_GUILD_SELF_JOINED_GUILD )
