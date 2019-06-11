--[[
    Method for depositing contributions into the guild bank

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

-- Inherit from MethodManualClass
local CLASS = GC.MethodManualClass()
GC.MethodBankClass = CLASS

local DEFAULT_AMOUNT = 1
local DEFAULT_MULT = 1

function CLASS:CanShowContributeWindow()
    return GC.IsGuildBankAvailable()
end

-- Return a string describing the history
function CLASS:GetHistoryString()
    return GC.MethodManualClass.GetHistoryString( self )..
       " "..GC.FormatGold( self.MethodSettings.amount * self.MethodSettings.mult )
end

function CLASS:Initialize( aGuildName, aGuildSettings )
    GC.MethodManualClass.Initialize( self, aGuildName, aGuildSettings )
    self:InitBase(
        GC.MethodId.BANK,
        "methodBank",
        { -- GUI Options
            { -- Amount to deposit
                name = GC.S( "BANK_GOLD" ),
                var = "amount",
                type = "number",
                default = DEFAULT_AMOUNT
            },
            { -- Multiplier
                name = GC.S( "MULTIPLIER" ),
                var = "mult",
                type = "number",
                default = DEFAULT_MULT
            },
        } )
end

-- Handle money update
function CLASS:OnMoneyUpdate( aRule, aNewMoney, aOldMoney, aReason )
    GC.Debug("ON_MONEY_UPDATE: "..tostring(aOldMoney).."->"..tostring(aNewMoney).." ("..tostring(aReason)..")")
    if( aReason ~= 51 ) then
        return
    end
    EVENT_MANAGER:UnregisterForEvent( GC.ADDON_NAME, EVENT_MONEY_UPDATE )

    -- Call the base method on success to finish up
    GC.MethodManualClass.ReportContribution( self, aRule )
end

-- Report that a contribution was given
function CLASS:ReportContribution( aRule )
    local curGold = GetCurrencyAmount( CURT_MONEY )
    local amount = self.MethodSettings.amount * self.MethodSettings.mult

    if( curGold < amount ) then
        GC.MsgP( "CONTRIBUTION_FAILED", tostring( curGold ).."g < "..tostring( amount ).."g!" )
        return
    end

    if( not GC.IsGuildBankAvailable() ) then
        GC.MsgP( "CONTRIBUTION_FAILED", GC.S( "HELP_OPEN_GUILD_BANK" ) )
        return
    end

    DepositCurrencyIntoGuildBank( CURT_MONEY, amount )

    -- Set up callback for asynchronous result
    EVENT_MANAGER:RegisterForEvent(
        GC.ADDON_NAME,
        EVENT_MONEY_UPDATE,
        function( aEventCode, aNewMoney, aOldMoney, aReason )
            self:OnMoneyUpdate( aRule, aNewMoney, aOldMoney, aReason )
        end
        )
end

GC.MethodNameById[GC.MethodId.BANK] = GC.S( "BANK" )
GC.MethodClassById[GC.MethodId.BANK] = CLASS
