--[[
    Method for depositing contributions into the guild bank

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

-- Inherit from MethodManualClass
local CLASS = GC.MethodManualClass()
GC.MethodMailClass = CLASS

local DEFAULT_AMOUNT = 1

function CLASS:Initialize( aGuildName, aGuildSettings )
    GC.MethodManualClass.Initialize( self, aGuildName, aGuildSettings )
    self:InitBase(
        GC.MethodId.MAIL,
        "methodMail",
        { -- GUI Options
            { -- Amount to send
                name = GC.S( "MAIL_GOLD" ),
                var = "amount",
                type = "number",
                default = DEFAULT_AMOUNT,
                min = 1,
                max = 10000
            },
            { -- Recipient
                name = GC.S( "MAIL_TO" ),
                var = "to",
                type = "string",
                default = GetString(SI_REQUEST_NAME_DEFAULT_TEXT)
            },
            { -- Subject
                name = GC.S( "MAIL_SUBJECT" ),
                var = "subject",
                type = "string",
                default = GetString(SI_MAIL_SUBJECT_DEFAULT_TEXT)
            },
            { -- Body
                name = GC.S( "MAIL_BODY" ),
                var = "body",
                type = "string",
                default = "",
                max = 200 -- Less than the actual limit
            },
        } )
    self.sendInProgress = false
end

function CLASS:OnSendFailed( aReason )
    -- Deduplicate callbacks
    if( not self.sendInProgress ) then
        return
    end

    self:StopSend()
    GC.MsgP( "CONTRIBUTION_FAILED", aReason )
end

-- Handle sending a mail successfully
function CLASS:OnSendSuccess( aRule )
    -- No guard against not sending, in case the action is late
    self:StopSend()

    -- Call the base method on success to finish up
    GC.MethodManualClass.ReportContribution( self, aRule )
end

-- Report that a contribution was given
function CLASS:ReportContribution( aRule )
    if( not GC.IsMailAvailable() ) then
        GC.MsgP( "CONTRIBUTION_FAILED", GC.S( "HELP_OPEN_MAIL" ) )
        return
    end

    -- Clear any pending mail data
    MAIL_SEND:ClearFields()

    -- Set up callbacks for asynchronous result
    EVENT_MANAGER:RegisterForEvent(
        GC.ADDON_NAME,
        EVENT_MAIL_SEND_SUCCESS,
        function( aEventCode )
            d( aRule )
            self:OnSendSuccess( aRule )
        end
        )
    EVENT_MANAGER:RegisterForEvent(
        GC.ADDON_NAME,
        EVENT_MAIL_SEND_FAILED,
        function( aEventCode, aReason )
            self:OnSendFailed( GetString( "SI_SENDMAILRESULT", aReason ) )
        end
        )
    GC.ConnectSignal(
        "WindowState",
        function( aVisible )
            if( not aVisible ) then
                self:OnSendFailed( GC.S( "UNKNOWN" ) )
            end
        end
        )

    self.sendInProgress = true
    QueueMoneyAttachment( self.MethodSettings.amount )
    SendMail( self.MethodSettings.to, self.MethodSettings.subject, self.MethodSettings.body )
end

-- Mark the sending of mail stopped (this cannot actually cancel a send)
function CLASS:StopSend()
    EVENT_MANAGER:UnregisterForEvent( GC.ADDON_NAME, EVENT_MAIL_SEND_SUCCESS )
    EVENT_MANAGER:UnregisterForEvent( GC.ADDON_NAME, EVENT_MAIL_SEND_FAILED )
    self.sendInProgress = false
end


GC.MethodNameById[GC.MethodId.MAIL] = GC.S( "MAIL" )
GC.MethodClassById[GC.MethodId.MAIL] = CLASS
