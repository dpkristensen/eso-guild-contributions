--[[
    Application class

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.AppClass = CLASS

function CLASS:Initialize()
    GC.APP = self -- TODO: Can this be privatized?
    self.EVENT_HANDLERS = {
        [EVENT_GUILD_SELF_JOINED_GUILD] = self.Update,
        [EVENT_GUILD_SELF_LEFT_GUILD] = self.Update
    }
    self.Db = GC.DbClass()

    if( self.Db:Get( "doStartupMsg" ) ) then
        GC.Msg( "LOADED" );
    end

    self.SettingsGUI = GC.SettingsGUIClass( self.Db )

    self.Window = GC.WindowClass( self.Db, self.SettingsGUI )

    self:Update();
end

function CLASS:OnEvent( aEventCode, ... )
    local fn = self.EVENT_HANDLERS[aEventCode]
    if( nil ~= fn ) then
        fn( self, aEventCode, ... )
    else
        GC.Debug( "Unhandled event "..tostring( aEventCode ) )
    end
end

function CLASS:Update()
    local guildNameList = {}
    local dbGuildList = self.Db:Get( "guilds" )
    local i, key, value

    -- Detect current guilds
    for i=1,GetNumGuilds() do
        local guildId = GetGuildId( i )
        local guildName = GetGuildName( guildId )
        guildNameList[guildName] = true
        GC.Debug( "Detect: guildId="..tostring( guildId ).." name="..guildName )
    end

    -- Remove settings for old guilds
    for key,value in pairs( dbGuildList ) do
        if( guildNameList[key] == nil ) then
            GC.MsgP( "REMOVE_GUILD", tostring( key ) )
            self.Db:RemoveGuild( key )
        end
    end

    -- Add default settings for new guilds
    for key,value in pairs( guildNameList ) do
        local guild = self.Db:GetGuild( key )
        local isReset = false
        if( guild.rule == nil ) then
            isReset = true
            self.Db:SetGuildRule( key, GC.RuleId.NONE, true )
        end
        if( guild.method == nil ) then
            isReset = true
            self.Db:SetGuildMethod( key, GC.MethodId.MANUAL )
        end
        if( isReset ) then
            GC.MsgP( "DEFAULT_GUILD", tostring( key ) )
        end
    end

    GC.Debug( "Today is "..GC.NowDT():GetAbsoluteText() )

    -- Check rules for guilds
    for key,value in pairs( dbGuildList ) do
        local ruleObj = GC.RuleByGuildName[key]
        local guild = self.Db:GetGuild( key )

        if( nil == ruleObj ) then
            -- If the rule is not set; create the object
            local ruleId = guild.rule
            ruleObj = GC.RuleClassById[ruleId]( key, guild )
            GC.RuleByGuildName[key] = ruleObj
        end

        -- While we're at it, also check the methods
        if( nil == GC.MethodByGuildName[key] ) then
            -- If the method is not set; create the object
            local methodId = guild.method
            GC.MethodByGuildName[key] = GC.MethodClassById[methodId]( key, guild )
        end

        if( ruleObj ~= nil ) then
            GC.Debug( "Update: guild='"..key.."' rule="..ruleObj:GetName() )
            ruleObj:Update( key )
        else
            GC.Debug( "nil rule for guild='"..key.."'" )
        end
    end
end

GuildContributionsAddonContainer = GC