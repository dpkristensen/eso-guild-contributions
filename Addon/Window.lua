--[[
    Floating window GUI

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.WindowClass = CLASS

local INSET = 16 -- Must be a power of 2
local nINSET = INSET * -1
local SPC = 12
local nSPC = SPC * -1

local GUI_STATE_EVENT = {
    [EVENT_ACTION_LAYER_POPPED] = true,
    [EVENT_ACTION_LAYER_PUSHED] = true,
    [EVENT_CLOSE_GUILD_BANK] = true,
    [EVENT_OPEN_GUILD_BANK] = true,
}

function CLASS:Initialize( aDb )
    self.Db = aDb

    self:SetupControls()
    self:SetupWindowEvents()
end

local PINNED_TEX = {
    down = "esoui/art/buttons/pinned_mousedown.dds",
    hover = "esoui/art/buttons/pinned_mouseover.dds",
    normal = "esoui/art/buttons/pinned_normal.dds"
}

local UNPINNED_TEX = {
    down = "esoui/art/buttons/unpinned_mousedown.dds",
    hover = "esoui/art/buttons/unpinned_mouseover.dds",
    normal = "esoui/art/buttons/unpinned_normal.dds"
}

local function SetBtnTextures( aBtn, aTex )
    aBtn:SetPressedTexture( aTex.down )
    aBtn:SetMouseOverTexture( aTex.hover )
    aBtn:SetNormalTexture( aTex.normal )
end

-- Handler for multiple events indicating change in GUI state
function CLASS:OnGuiStateChanged( aEventCode, ... )
    if( GUI_STATE_EVENT[aEventCode] ) then
        self:Show()
    end
end

-- Handle "Contribute" button clicks
function CLASS:OnBtnContributeClicked()
    local rule = GC.RuleByGuildName[self.curGuild]
    local method = GC.MethodByGuildName[self.curGuild]

    method:ReportContribution( rule )

    self:UpdateText()

    -- The settings GUI will not know that settings changed, so trigger refresh manually
    CALLBACK_MANAGER:FireCallbacks( "LAM-RefreshPanel", GC.APP.SettingsGUI.Panel )
end

-- Handle lock button clicks
function CLASS:OnBtnLockClicked()
    self.Db:Set( "wposLock", not self.Db:Get( "wposLock" ) )
    self:UpdateMovable()
end

-- Handle the guild being selected
function CLASS:OnGuildSelected()
    self:UpdateCurGuild()
end

-- Emit the WindowState signal
function CLASS:OnHide()
    GC.FireSignal( "WindowState", false )
end

-- Save the position when the window stops moving
function CLASS:OnMoveStop()
    local hWnd = self.hWnd
    local left = hWnd:GetLeft()
    local top = hWnd:GetTop()
    GC.Debug( "l="..tostring( left ).." t="..tostring( top ) );
    self.Db:Set( "wposLeft", left )
    self.Db:Set( "wposTop", top )
end

-- Emit the WindowState signal
function CLASS:OnShow()
    GC.FireSignal( "WindowState", true )
end

-- Initialize the window controls
function CLASS:SetupControls()
    -- Main window
    local hWnd = WINDOW_MANAGER:CreateTopLevelWindow( GC.ADDON_NAME.."_Window" )
    self.hWnd = hWnd
    self:SetHandler( hWnd, "OnHide", CLASS.OnHide )
    self:SetHandler( hWnd, "OnMoveStop", CLASS.OnMoveStop )
    self:SetHandler( hWnd, "OnShow", CLASS.OnShow )
    hWnd:SetHidden( true )
	hWnd:SetMovable( true )

	-- give it a backdrop
    local hBg = WINDOW_MANAGER:CreateControl( GC.ADDON_NAME.."_Background" , hWnd, CT_BACKDROP )
	hBg:SetDrawLayer( DL_BACKGROUND )
	hBg:SetAnchorFill( hWnd )
	hBg:SetEdgeTexture( "EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 128, 16 )
	hBg:SetCenterTexture( "EsoUI/Art/ChatWindow/chat_BG_center.dds" )
	hBg:SetInsets( INSET, INSET, nINSET, nINSET )

    -- Lock Button
    local hBtnLock = WINDOW_MANAGER:CreateControlFromVirtual( GC.ADDON_NAME.."_ButtonLock", hWnd, "ZO_CheckButton" )
    self.hBtnLock = hBtnLock
    hBtnLock:SetAnchor( TOPLEFT, hWnd, TOPLEFT, SPC, SPC)
    hBtnLock:SetDimensions( 40, 40 )
    self:SetHandler( hBtnLock, "OnClicked", CLASS.OnBtnLockClicked )

    -- Title
    local hTitle = WINDOW_MANAGER:CreateControl( GC.ADDON_NAME.."_Title", hWnd, CT_LABEL )
    self.hTitle = hTitle
    hTitle:SetAnchor( TOP, hWnd, TOP, 0, SPC )
    hTitle:SetFont( "ZoFontGameLarge" )
    hTitle:SetText( GC.S( "GUI_TITLE" ) )

    -- Rule
    local hRule = WINDOW_MANAGER:CreateControl( GC.ADDON_NAME.."_Rule", hWnd, CT_LABEL )
    self.hRule = hRule
    hRule:SetAnchor( TOP, hTitle, BOTTOM, 0, SPC )
    hRule:SetColor( 0.77, 0.76, 0.62 )
    hRule:SetFont( "ZoFontGameMedium" )
    hRule:SetText( "RULE" )
    hRule:SetWidth( hTitle:GetWidth() * 1.5 )

    -- Info
    local hInfo = WINDOW_MANAGER:CreateControl( GC.ADDON_NAME.."_Info", hWnd, CT_LABEL )
    self.hInfo = hInfo
    hInfo:SetAnchor( TOP, hRule, BOTTOM, 0, SPC )
    hInfo:SetColor( 0.77, 0.76, 0.62 )
    hInfo:SetFont( "ZoFontGameMedium" )
    hInfo:SetText( "INFO" )
    hInfo:SetWidth( hRule:GetWidth() )

    -- Contribute Button
    local hBtnContribute = WINDOW_MANAGER:CreateControlFromVirtual( GC.ADDON_NAME.."_ButtonContribute", hWnd, "ZO_DefaultButton" )
    self.hBtnContribute = hBtnContribute
    hBtnContribute:SetAnchor( TOP, hInfo, BOTTOM, 0, SPC )
    hBtnContribute:SetDimensions( 200, 30 )
    hBtnContribute:SetText( GC.S( "BTN_CONTRIBUTE" ) )
    self:SetHandler( hBtnContribute, "OnClicked", CLASS.OnBtnContributeClicked )

    -- Update initial states
    self:UpdateCurGuild()
    self:UpdateMovable()

    local leftPos = self.Db:Get( "wposLeft" )
    local topPos = self.Db:Get( "wposTop" )
    hWnd:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, leftPos, topPos )
end

function CLASS:SetupWindowEvents()
    local key,value
    for key,value in pairs( GUI_STATE_EVENT ) do
        self:RegisterEvent( key, CLASS.OnGuiStateChanged );
    end
    self:RegisterCallback( "OnGuildSelected", CLASS.OnGuildSelected );
end

-- Show/hide the window
function CLASS:Show()
    local isCursorShown = IsReticleHidden()
    local isGuildSceneShown = SCENE_MANAGER:GetSceneGroup( "guildsSceneGroup" ):IsShowing()
    local show = isCursorShown and (
        isGuildSceneShown or
        GC.IsGuildBankAvailable()
        )

    if( show ) then
        self:UpdateText()
    end

    self.hWnd:SetHidden( not show )
end

function CLASS:RegisterCallback( aName, aFunction )
    CALLBACK_MANAGER:RegisterCallback( aName, function( ... ) aFunction( self, ... ) end );
end

function CLASS:RegisterEvent( aEventCode, aFunction )
    EVENT_MANAGER:RegisterForEvent( GC.ADDON_NAME, aEventCode, function( ... ) aFunction( self, ... ) end );
end

function CLASS:SetHandler( aControl, aName, aFunction )
    aControl:SetHandler( aName, function( ... ) aFunction( self, ... ) end )
end

-- Get the current guild from the Guild Scene
function CLASS:UpdateCurGuild()
    local curGuild = ZO_GuildSelectorComboBoxSelectedItemText:GetText()
    self.curGuild = curGuild

    self:UpdateText()
end

-- Update the window when the movable state changes
function CLASS:UpdateMovable()
    local isLocked = self.Db:Get( "wposLock" )
	self.hWnd:SetMouseEnabled( not isLocked )

    local lockTex
    if( isLocked ) then
        lockTex = PINNED_TEX
    else
        lockTex = UNPINNED_TEX
    end
    SetBtnTextures( self.hBtnLock, lockTex )
end

function CLASS:UpdateText()
    local rule = GC.RuleByGuildName[self.curGuild]
    local ruleText = ""
    local infoText = ""
    local btnEnabled = false

    if( rule ~= nil ) then
        ruleText = GC.S( "OPTION_CONTRIBUTION_RULE" )..": "..GC.RuleNameById[rule.RuleId]
        infoText = rule:GetWindowText()
        btnEnabled = rule:IsContributionNeeded()
    end
    self.hRule:SetText( ruleText )
    self.hInfo:SetText( infoText )

    self.hWnd:SetDimensions(
        ( SPC * 2 )
            + self.hRule:GetWidth(),
        ( SPC * 5 )
            + self.hTitle:GetHeight()
            + self.hRule:GetHeight()
            + self.hInfo:GetHeight()
            + self.hBtnContribute:GetHeight()
        )
    self.hBtnContribute:SetEnabled( btnEnabled )
end
