--[[
    Settings parser

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.SettingsParserClass = CLASS

function CLASS:Initialize( aSettingsDb, aOptionGroup )
    -- Where the settings are saved
    self.settings = aSettingsDb

    -- Structure defining the available options
    self.optionGroup = aOptionGroup
end

-- Get text for aOption of type "number"
function CLASS:BuildNumberArgText( aOption )
    local rawValue = self.settings[aOption.var]
    if( aOption.lookupTable ~= nil ) then
        -- If there is a lookup table, translate it for the user
        return aOption.lookupTable[rawValue]
    end

    return tostring( rawValue )
end

-- Convert aOption into a line of text for display to the user
function CLASS:BuildArgText( aOption )
    local text

    if( aOption.type == "number" ) then
        text = self:BuildNumberArgText( aOption )
    else
        GC.Debug( "Unhandled type='"..aOption.type.."' for '"..aOption.name.."'" )
        text = tostring( self.settings[aOption.var] )
    end
    return aOption.name.."="..text
end

-- Build a list of options to be shown as text to the user
function CLASS:GetOptionText()
    local text = ""

    local firstIteration = true
    local key,option
    for key,option in pairs( self.optionGroup ) do
        if( firstIteration ) then
            firstIteration = false
        else
            text = "\n"..text
        end
        text = text..self:BuildArgText( option )
    end

    return text
end

--[[
    Parse a setting for aOption of type "number" with input aValue

    Return whether options were actually changed.
]]
function CLASS:ParseNumberArg( aOption, aValue )
    local numValue = tonumber( aValue )

    if( numValue == nil ) then
        -- Not a number, try lookup table?
        local lowInValue = string.lower( aValue )
        if( aOption.lookupTable ~= nil ) then
            local key,value
            for key,value in pairs( aOption.lookupTable ) do
                local lowTblValue = string.lower( value )
                if( ( nil ~= string.find( lowInValue, lowTblValue, 1, true ) ) or
                    ( nil ~= string.find( lowTblValue, lowInValue, 1, true ) ) ) then
                    numValue = key
                    break
                end
            end
        end
    end

    local changed = false
    if( numValue == nil ) then
        GC.Debug( "Bad input: '"..aValue.."'" )
    elseif( self.settings[aOption.var] ~= numValue ) then
        self.settings[aOption.var] = numValue
        changed = true
    end
    return changed
end

--[[
    Parse a setting for an argument pair

    Return whether options were actually changed.
]]
function CLASS:ParseArg( aName, aValue )
    local key,option
    for key,option in pairs( self.optionGroup ) do
        if( option.name == aName ) then
            local changed = false
            if( option.type == "number" ) then
                changed = self:ParseNumberArg( option, aValue )
            else
                GC.Debug( "Unhandled type='"..option.type.."' for '"..aName.."'" )
            end
            return changed
        end
    end

    GC.Debug( "'"..aName.."' not found in options list" )
    return false
end

-- Set default option values
function CLASS:SetOptionDefaults()
    local key,option
    for key,option in pairs( self.optionGroup ) do
        self.settings[option.var] = option.default
    end
end

-- Parse the list of options modified by the user
function CLASS:SetOptionText( aNewValue )
    local changed = false

    -- Iterator that splits the string
    local function Split( aString, aDelim )
        if( aString:sub( -1 ) ~= aDelim ) then
            aString = aString..aDelim
        end
        return aString:gmatch( "(.-)"..aDelim )
    end

    -- For each line...
    local line, identifier
    for line in Split( aNewValue, "\n" ) do
        -- Build a list of separated identifiers
        local argList = {}
        for identifier in Split( line, "=" ) do
            argList[#argList + 1] = identifier
        end
        -- If it is an exact pair, parse the argument pair
        if( #argList == 2 ) then
            if( self:ParseArg( argList[1], argList[2] ) ) then
                changed = true
            end
        end
    end

    return changed
end
