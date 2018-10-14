--[[
    Method for manual contribution tracking

    This also serves as a base class for all other Methods

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.MethodManualClass = CLASS

local MIN_MULT = 0
local MAX_MULT = 100

-- Return whether the delivery method is available.
function CLASS:CanShowContributeWindow()
    return true
end

function CLASS:ChangeMultiplier( aDelta )
    local settings = self.MethodSettings
    if( ( settings ) and
        ( settings.mult ~= nil ) ) then
        local newMult = settings.mult + aDelta
        if( ( newMult >= MIN_MULT ) and
            ( newMult <= MAX_MULT ) ) then
            settings.mult = newMult
        end
    end
end

function CLASS:Initialize( aGuildName, aGuildSettings )
    self.MethodId = GC.MethodId.MANUAL
    self.GuildName = aGuildName
    self.GuildSettings = aGuildSettings

end

-- Function to initialize base members (called by super class Initialize())
function CLASS:InitBase( aId, aOptionVar, aGuiOptions )
    self.OptionVar = aOptionVar
    self.MethodId = aId

    if( nil ~= aOptionVar ) then
        self.GuiOptions = aGuiOptions
        if( self.GuildSettings[self.OptionVar] == nil ) then
            self.GuildSettings[self.OptionVar] = {}
        end
        self.MethodSettings = self.GuildSettings[self.OptionVar]
        self.settingsParser = GC.SettingsParserClass( self.MethodSettings, self.GuiOptions )

        local key,option
        for key,option in pairs( self.GuiOptions ) do
            if( self.MethodSettings[option.var] == nil ) then
                self.MethodSettings[option.var] = option.default
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

-- Return details about the contribution to be given as a table:
--   text = Description of the contribution
--   useMult = Whether a multiplier is used
function CLASS:GetContributionDetailText()
    local settings = self.MethodSettings

    -- By default, if the method stores a value called "mult" and "amount", then let it be multiplied
    if( ( settings ) and
        ( settings.mult ~= nil ) and
        ( settings.amount ~= nil ) ) then
        return {
            text = "|cffff00"..GC.FormatGold( settings.amount * settings.mult ).."|r",
            useMult = true
        }
    end

    return {
        text = "|c3f3f3f"..GC.S( "NONE" ).."|r",
        useMult = false
    }
end

-- Return a string describing the history
function CLASS:GetHistoryString()
    return GC.NowDT():GetBeginningOfDay():GetAbsoluteText()
end

-- Return the localized name of the Method
function CLASS:GetName()
    return GC.MethodNameById[self.MethodId]
end

-- Return the options built from GuiOptions, or empty string
function CLASS:GetOptionText()
    local text = ""

    if( self:HasOptions() ) then
        text = self.settingsParser:GetOptionText()
    end

    return text
end

-- Mark the contribution as applied and call the rule to update
function CLASS:ReportContribution( aRule )
    self.GuildSettings.lastContributionTime = GC.NowTS()
    history = self:GetHistoryString()
    self.GuildSettings.history = history
    GC.Print( self.GuildName..": "..GC.S( "CONTRIBUTION_APPLIED" )..
        " ("..aRule:GetName()..") - ".. history )
    aRule:ReportContribution()
end

--[[
    Handle new option text from the settings GUI

    NOTE: Do not override this function to perform other Method-specific actions!  Override
    SetMethodOptionText() instead.
]]
function CLASS:SetOptionText( aNewValue )
    local changed = false
    if( self:HasOptions() ) then
        changed = self.settingsParser:SetOptionText( aNewValue )
    end

    self:SetMethodOptionText( changed )
    if( changed ) then
        self:Update()
    end
end

function CLASS:SetMethodOptionText( aChanged )
    -- Do nothing by default
end

--[[
    Reset defaults when specified by the settings GUI

    NOTE: Do not override this function to perform other Method-specific actions!  Override
    SetMethodDefaults() instead.
]]
function CLASS:SetDefaults()
    if( self:HasOptions() ) then
        self.settingsParser:SetOptionDefaults()
    end
    self:SetMethodDefaults()
    self:Update()
end

function CLASS:SetMethodDefaults()
    -- Do nothing by default
end

function CLASS:Update()
    -- Do nothing by default
end

GC.MethodNameById[GC.MethodId.MANUAL] = GC.S( "MANUAL" )
GC.MethodClassById[GC.MethodId.MANUAL] = CLASS
