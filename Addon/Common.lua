--[[
    Common code

    Copyright 2018 okulo
]]

-- Put everything into a container table to avoid conflicts with other modules
local GC = {
    ADDON_NAME = "GuildContributions",
    LAM = LibStub( "LibAddonMenu-2.0" )
}
GuildContributionsAddonContainer = GC

-- Define a base class with default initialization routines
local BASE_CLASS = ZO_Object:Subclass()

function BASE_CLASS:Initialize()
    -- Do nothing by default
end

-- Set up constructor
getmetatable( BASE_CLASS ).__call = function( aBaseObject, ... )
    local object = ZO_Object.New( aBaseObject )
    getmetatable( object ).__call = getmetatable( aBaseObject ).__call
    object:Initialize( ... )
    return object
end

-- Alias the base class
GC.Class = BASE_CLASS

-- Append a value to the end of a table
function GC.Append( aTable, aValue )
    aTable[ #aTable + 1 ] = aValue
end

-- Function to create an enumeration
function GC.Enum( aContainer, aStartValue, ... )
    local N = aStartValue

    local key,value
    for key,value in ipairs( {...} ) do
        aContainer[value] = N
        N = N + 1
    end
end

function GC.IsGuildBankAvailable()
    return SCENE_MANAGER:GetScene( "guildBank" ):IsShowing()
end
