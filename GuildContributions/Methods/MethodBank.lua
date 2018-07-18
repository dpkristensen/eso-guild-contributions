--[[
    Method for depositing contributions into the guild bank

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

-- Inherit from MethodManualClass
local CLASS = GC.MethodManualClass()
GC.MethodBankClass = CLASS

local DEFAULT_AMOUNT = 1

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
        } )
end

-- Report that a contribution was given
function CLASS:ReportContribution( aRule )
    local curGold = GetCurrencyAmount( CURT_MONEY )
    local amount = self.MethodSettings.amount

    if( curGold < amount ) then
        GC.MsgP( "CONTRIBUTION_FAILED", tostring( curGold ).."g < "..tostring( amount ).."g!" )
        return
    end

    if( not GC.IsGuildBankAvailable() ) then
        GC.MsgP( "CONTRIBUTION_FAILED", GC.S( "HELP_OPEN_GUILD_BANK" ) )
        return
    end

    DepositCurrencyIntoGuildBank( CURT_MONEY, amount )

    -- Call the base method on success to finish up
    GC.MethodManualClass.ReportContribution( self, aRule )
end

GC.MethodNameById[GC.MethodId.BANK] = GC.S( "BANK" )
GC.MethodClassById[GC.MethodId.BANK] = CLASS
