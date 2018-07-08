--[[
    Rule for no contributions required

    This also serves as a base class for all other rules

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.RuleNoneClass = CLASS

function CLASS:Initialize( aGuildName, aGuildSettings )
    self.RuleId = GC.RuleId.NONE
    self.GuildName = aGuildName
    self.GuildSettings = aGuildSettings
end

-- Function to initialize base members (called by super class Initialize())
function CLASS:InitBase( aId, aOptionVar, aGuiOptions )
    self.OptionVar = aOptionVar
    self.RuleId = aId

    if( nil ~= aOptionVar ) then
        self.GuiOptions = aGuiOptions
        if( self.GuildSettings[self.OptionVar] == nil ) then
            self.GuildSettings[self.OptionVar] = {}
        end
        self.RuleSettings = self.GuildSettings[self.OptionVar]
        self.settingsParser = GC.SettingsParserClass( self.RuleSettings, self.GuiOptions )

        local key,option
        for key,option in pairs( self.GuiOptions ) do
            if( self.RuleSettings[option.var] == nil ) then
                self.RuleSettings[option.var] = option.default
            end
        end
    elseif( aGuiOptions ~= nil ) then
        GC.Debug( "ERROR: aGuiOptions without aOptionVar" )
    end
end

-- Return whether the class has a GuiOptions structure
function CLASS:HasOptions()
    return self.GuiOptions ~= nil
end

-- Return whether a contribution is needed based on the rule
function CLASS:IsContributionNeeded()
    return false
end

-- Return the last contribution time, or 0 if invalid
function CLASS:GetLastContributionDT()
    if( self.GuildSettings.lastContributionTime == nil ) then
        self.GuildSettings.lastContributionTime = 0
    end
    return GC.DateTime( self.GuildSettings.lastContributionTime );
end

-- Return the localized name of the rule
function CLASS:GetName()
    return GC.RuleNameById[self.RuleId]
end

-- Return the options built from GuiOptions, or empty string
function CLASS:GetOptionText()
    local text = ""

    if( self:HasOptions() ) then
        text = self.settingsParser:GetOptionText()
    end

    return text
end

-- Return text representing the current status
function CLASS:GetStatusText( aNow, aDueTime, aIncludeGuild )
    local text

    local guildText = ""
    if( aIncludeGuild ) then
        guildText = ": "..self.GuildName
    end

    if( self:GetLastContributionDT():Invalid() ) then
        text = GC.S( "CONTRIBUTION_NOT_RECORDED" )..guildText
    elseif( aNow < aDueTime ) then
        -- Contribution is up-to-date, show time until next
        local diffNextTime = aDueTime - aNow
        text = GC.S( "CONTRIBUTION_DUE_IN" )..guildText.." "..
            diffNextTime:GetRelativeText().." @ "..
            aDueTime:GetAbsoluteText()
    elseif( aNow < aLateTime ) then
        text = GC.S( "CONTRIBUTION_DUE_NOW" )..guildText
    else
        local diffLateTime = aNow:Since( aLateTime )
        text = GC.S( "CONTRIBUTION_PAST_DUE" )..guildText.." "..diffLateTime:GetRelativeText()
    end

    return text
end

-- Return the text to show in the floating window
function CLASS:GetWindowText()
    return ""
end

function CLASS:ReportContribution()
    -- Do nothing by default
end

function CLASS:ReportStatus( aDueTime, aLateTime )
    local lastContribDT = self:GetLastContributionDT()

    GC.Debug( "Next contribution for "..self.GuildName..": "..aDueTime:GetAbsoluteText() )

    local now = GC.NowDT()
    if( lastContribDT:Invalid() ) then
        GC.Debug( "No contributions recorded for "..self.GuildName )
    else
        GC.Debug( "Last contributed to "..self.GuildName..":" )
        GC.Debug( "  abs="..lastContribDT:GetAbsoluteText() )
        GC.Debug( "  rel="..now:Since( lastContribDT ):GetRelativeText() )
    end

    GC.Print( self:GetStatusText( now, aDueTime, true ) )
end

--[[
    Handle new option text from the settings GUI

    NOTE: Do not override this function to perform other rule-specific actions!  Override
    SetRuleOptionText() instead.
]]
function CLASS:SetOptionText( aNewValue )
    local changed = false
    if( self:HasOptions() ) then
        changed = self.settingsParser:SetOptionText( aNewValue )
    end

    self:SetRuleOptionText( changed )
    if( changed ) then
        self:Update()
    end
end

function CLASS:SetRuleOptionText( aChanged )
    -- Do nothing by default
end

--[[
    Reset defaults when specified by the settings GUI

    NOTE: Do not override this function to perform other rule-specific actions!  Override
    SetRuleDefaults() instead.
]]
function CLASS:SetDefaults()
    if( self:HasOptions() ) then
        self.settingsParser:SetOptionDefaults()
    end
    self:SetRuleDefaults()
    self:Update()
end

function CLASS:SetRuleDefaults()
    -- Do nothing by default
end

function CLASS:Update()
    -- Do nothing by default
end

GC.RuleNameById[GC.RuleId.NONE] = GC.S( "NONE" )
GC.RuleClassById[GC.RuleId.NONE] = CLASS
