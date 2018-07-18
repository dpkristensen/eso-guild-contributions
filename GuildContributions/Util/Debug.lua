--[[
    Debug Functions

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local debug_expose_gc = false
local DEBUG_PREFIX = "|cff0000[debug]|r "

-- Print text to the system console
function GC.Debug( aText )
    if( GC.GetDebugMode() ) then
        GC.Print( DEBUG_PREFIX..aText );
    end
end

-- Get debug mode
function GC.GetDebugMode()
    return GuildContributions_DebugOpts.Enabled
end

-- Initialize debug mode settings
function GC.InitDebugMode()
    if( GuildContributions_DebugOpts == nil ) then
        GC.ResetDebugMode()
    end
    -- Reset debug mode to the current value to apply associated logic
    GC.SetDebugMode( GC.GetDebugMode() )
end

-- Reset debug mode
function GC.ResetDebugMode()
    GuildContributions_DebugOpts = {
        Enabled = false
    }
end

-- Set debug mode
function GC.SetDebugMode( aNewValue )
    if( aNewValue ) then
        GuildContributions_DebugOpts.Enabled = true
        GC.Debug( "Debug mode enabled!" );
        debug_expose_gc = ( _G["GC"] == nil )
        if( debug_expose_gc ) then
            _G["GC"] = GuildContributionsAddonContainer;
            GC.Debug( "Use the 'GC' variable to access addon data/functions." );
        else
            GC.Debug( "'GC' variable in use; no alias for GuildContributionsAddonContainer defined." );
        end
    else
        if( debug_expose_gc ) then
            _G["GC"] = nil;
        end
        GC.Debug( "Debug mode disabled." );
        GuildContributions_DebugOpts.Enabled = false
    end
end
