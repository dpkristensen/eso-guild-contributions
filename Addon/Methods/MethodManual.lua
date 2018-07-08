--[[
    Method for manual contribution tracking

    This also serves as a base class for all other Methods

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.MethodManualClass = CLASS

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
    GC.Print( self.GuildName..": "..GC.S( "CONTRIBUTION_APPLIED" ).." ("..aRule:GetName()..")" )
    aRule:ReportContribution()
end

--[[
    Handle new option text from the settings GUI

    NOTE: Do not override this function to perform other Method-specific actions!  Override
    SetMethodOptionText() instead.
]]
function CLASS:SetOptionText( aNewValue )
    if( self:HasOptions() ) then
        self.settingsParser:SetOptionText( aNewValue )
    end

    self:SetMethodOptionText()
    self:Update()
end

function CLASS:SetMethodOptionText()
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
