--[[
    Rule for contributions due by a certain weekday

    Copyright 2018 okulo
]]

local DEFAULT_DOTW = 7 -- Sunday

local GC = GuildContributionsAddonContainer

-- Inherit from RuleNoneClass
local CLASS = GC.RuleNoneClass()
GC.RuleWeeklyClass = CLASS

function CLASS:Initialize( aGuildName, aGuildSettings )
    GC.RuleNoneClass.Initialize( self, aGuildName, aGuildSettings )

    self:InitBase(
        GC.RuleId.WEEKDAY,
        "ruleWeekday",
        { -- GUI Options
            { -- Due day of the week
                name = GC.S( "DAY" ),
                var = "dueDotw",
                type = "number",
                default = DEFAULT_DOTW,
                lookupTable = GC.DateTime.DOTW_TEXT
            },
        } )
end

function CLASS:GetDueTimeDT()
    return GC.DateTime( self.RuleSettings.dueTimeStamp )
end

function CLASS:GetLateTimeDT()
    return GC.DateTime( self.RuleSettings.dueTimeStamp + GC.DateTime.SECONDS_PER_DAY )
end

-- Return the text to show in the floating window
function CLASS:GetWindowText()
    return self:GetStatusText( GC.NowDT(), self:GetLateTimeDT(), false )
end

-- Return whether a contribution is needed based on the rule
function CLASS:IsContributionNeeded()
    return (
        ( self:GetLastContributionDT():Invalid() ) or
        ( self:GetDueTimeDT() <= GC.NowDT() )
        )
end

-- Report that a contribution was given
function CLASS:ReportContribution()
    self.RuleSettings.dueTimeStamp = nil -- Clear out due date; it is recalculated on next update
    self:Update()
end

-- Set custom options
function CLASS:SetRuleOptionText()
    self.RuleSettings.dueTimeStamp = nil -- Clear out due date; it is recalculated on next update
end

-- Set default values when the user selects this rule
function CLASS:SetRuleDefaults()
    if( DEFAULT_DOTW ~= self.RuleSettings.dueDotw ) then
        self.RuleSettings.dueDotw = DEFAULT_DOTW -- Sunday
        self.RuleSettings.dueTimeStamp = nil -- Clear out due date; it is recalculated on next update
    end
end

-- Determine contribution status
function CLASS:Update()
    if( self.RuleSettings.dueTimeStamp == nil ) then
        self.RuleSettings.dueTimeStamp = GC.NowDT():GetNextDotw( self.RuleSettings.dueDotw ).value
    end

    self:ReportStatus( self:GetDueTimeDT(), self:GetLateTimeDT() )
end

GC.RuleNameById[GC.RuleId.WEEKDAY] = GC.S( "WEEKDAY" )
GC.RuleClassById[GC.RuleId.WEEKDAY] = CLASS
