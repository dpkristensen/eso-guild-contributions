--[[
    UNIX Time system conversion class

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.DateTime = CLASS

CLASS.EPOCH_DOTW = 3
CLASS.DAYS_PER_WEEK = 7
CLASS.SECONDS_PER_MINUTE = 60
CLASS.SECONDS_PER_HOUR = 60 * CLASS.SECONDS_PER_MINUTE
CLASS.SECONDS_PER_DAY = 24 * CLASS.SECONDS_PER_HOUR
CLASS.INVALID_TS = 0

-- Lookup table to correlate day of the week number and text
CLASS.DOTW_TEXT = {
    GC.S("MONDAY"),     -- 1
    GC.S("TUESDAY"),    -- 2
    GC.S("WEDNESDAY"),  -- 3
    GC.S("THURSDAY"),   -- 4
    GC.S("FRIDAY"),     -- 5
    GC.S("SATURDAY"),   -- 6
    GC.S("SUNDAY")      -- 7
}

-- Helper function to get an invalid DateTime object (i.e., the epoch)
function GC.InvalidDT()
    return GC.DateTime( CLASS.INVALID_TS )
end

-- Helper function to get the current time as a raw timestamp
function GC.NowTS()
    return GetTimeStamp() + GC.APP.Db:Get( "localTimeOffset" ) * CLASS.SECONDS_PER_HOUR
end

-- Helper function to get the current time as a DateTime object
function GC.NowDT()
    return GC.DateTime( GC.NowTS() )
end

function CLASS:Initialize( aValue )
    self.value = aValue

    -- If none given, assume invalid
    if( self.value == nil ) then
        error( "Must have valid time" )
    end

    -- Convert a metatable function argument to a timestamp
    local function mtArgToTs( aArg )
        if( type( aArg ) == "number" ) then
            return aArg
        end
        return aArg.value
    end

    -- operator +
    getmetatable( self ).__add = function( self, aOther )
        return CLASS( self.value + mtArgToTs( aOther ) )
    end

    -- operator ==
    getmetatable( self ).__eq = function( self, aOther )
        return self.value == mtArgToTs( aOther )
    end

    -- operator <
    getmetatable( self ).__lt = function( self, aOther )
        return self.value < mtArgToTs( aOther )
    end

    -- operator -
    getmetatable( self ).__sub = function( self, aOther )
        return CLASS( self.value - mtArgToTs( aOther ) )
    end
end

-- Get an absolute value as text
function CLASS:GetAbsoluteText( aForceTime )
    local dotw = self:GetDotw()
    local timeOnly = self.value % CLASS.SECONDS_PER_DAY
    local text = GetDateStringFromTimestamp( self.value ).." "

    if( ( timeOnly ~= 0 ) or aForceTime ) then
        text = text..FormatTimeSeconds( timeOnly, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_NONE ).." "
    end

    text = text..self:GetDotwText()

    return text
end

-- Return a new timestamp representing the beginning of the day
function CLASS:GetBeginningOfDay()
    local ts = math.floor( self.value / CLASS.SECONDS_PER_DAY ) * CLASS.SECONDS_PER_DAY
    return CLASS( ts )
end

-- Convert the value into a number of days
function CLASS:GetDays()
    return self.value / CLASS.SECONDS_PER_DAY
end

-- Convert the value into a day of the week (1-7)
function CLASS:GetDotw()
    return math.floor( ( self:GetDays() + CLASS.EPOCH_DOTW ) % CLASS.DAYS_PER_WEEK ) + 1
end

-- Get the day of the week as text
function CLASS:GetDotwText()
    local dotw = self:GetDotw()
    local text = CLASS.DOTW_TEXT[dotw]
    if( text == nil ) then
        text = tostring( dotw )
    end
    return text
end

--[[
    Returns a new timestamp representing the beginning of the day on the next occurrence of the
    given day of the week (1-7).

    NOTE: the same day is 1 week from today.
]]
function CLASS:GetNextDotw( aDotw )
    -- Calculate the delta in days till target day
    local dayDelta = aDotw - self:GetDotw()
    if( dayDelta < 1 ) then
        dayDelta = dayDelta + CLASS.DAYS_PER_WEEK
    end

    -- Offset the next time beginning at this day
    local nextTimeStamp = self:GetBeginningOfDay()
    nextTimeStamp = nextTimeStamp + dayDelta * CLASS.SECONDS_PER_DAY

    return nextTimeStamp
end

-- Get an relative timestamp as text
function CLASS:GetRelativeText()
    local dotw = self:GetDotw()
    local days = self:GetDays()
    local text = FormatTimeSeconds( self.value, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_NONE )

    return text
end

-- Returns whether the value is Invalid
function CLASS:Invalid()
    return self.value == 0
end

-- Returns the time (DateTime object) since aOther
function CLASS:Since( aOther )
    return CLASS( GetDiffBetweenTimeStamps( self.value, aOther.value ) )
end

-- Returns whether the value is valid
function CLASS:Valid()
    return not self.Invalid()
end
