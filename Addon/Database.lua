--[[
    Database for saved settings

    NOTE: ZO_SavedVars is not used because it wipes the data on version bump

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.DbClass = CLASS

function CLASS:Initialize()
    self.CurDbVersion = 1
    self.DEFAULT_VALUES = {
        version = self.CurDbVersion,
        doStartupMsg = false,
        localTimeOffset = 0,
        guilds = {},
        wposLeft = 100,
        wposTop = 100,
        wposLock = false
        };

    GC.InitDebugMode()

    if( ( GuildContributions_DB == nil ) or
        ( GuildContributions_DB.version > self.CurDbVersion ) ) then
        -- Reset the data on same version or downgrade
        self:Reset();
    elseif( GuildContributions_DB.version < self.CurDbVersion ) then
        -- TODO: Upgrade from previous versions as needed
        self:Reset();
    end

    -- See Reset() for details on why this is done after the reset
    self.saved = GuildContributions_DB;
end

-- Get a saved value
function CLASS:Get( aKey )
    return self.saved[aKey]
end

-- Get a value's default
function CLASS:GetDefault( aKey )
    return self.DEFAULT_VALUES[aKey]
end

-- Get the guild information
function CLASS:GetGuild( aGuildName )
    if( self.saved.guilds[aGuildName] == nil ) then
        self.saved.guilds[aGuildName] = {}
    end
    return self.saved.guilds[ aGuildName ]
end

--[[
    Reset to current version, wiping away any old data

    NOTE: This works directly on the saved variable to ensure settings are updated instead of
    just the shadow reference.  See Initialized() where the reset may be called prior to setting
    up the shadow.
]]
function CLASS:Reset()
    GC.Msg( "RESET_SETTINGS" );
    GuildContributions_DB = self.DEFAULT_VALUES;
end

-- Get the guild information
function CLASS:RemoveGuild( aGuildName )
    self.saved.guilds[ aGuildName ] = nil
end

-- Set a saved value
function CLASS:Set( aKey, aValue )
    self.saved[aKey] = aValue
end

-- Set the method for a guild
function CLASS:SetGuildMethod( aGuildName, aMethod )
    local guild = self.saved.guilds[aGuildName]

    guild.method = aMethod
end

-- Set the rule for a guild
function CLASS:SetGuildRule( aGuildName, aRule, aResetContribution )
    local guild = self.saved.guilds[aGuildName]

    guild.rule = aRule
    if( aResetContribution ) then
        guild.lastContributionTime = GC.DateTime.INVALID_TS
    end
end
