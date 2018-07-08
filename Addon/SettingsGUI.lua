--[[
    Settings GUI Definitions

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

local CLASS = GC.Class()
GC.SettingsGUIClass = CLASS

function CLASS:Initialize( aDb )
    self.Db = aDb

    self.LamWksp = GC.ADDON_NAME.."_LamWksp"

    self.PanelData = {
        type = "panel",
        name = GC.ADDON_NAME,
        author = "okulo",
        version = "0.01",
        website = "https://github.com/dpk5081/eso-guild-contributions",
        registerForRefresh = true,
        registerForDefaults = true
    }

    self.EnumTables = {
        {
            Type = "Rule",
            Label = GC.S( "OPTION_CONTRIBUTION_RULE" ),
            DisplayTable = {},
            ValueTable = {},
            SetAuxParam = false
        },
        {
            Type = "Method",
            Label = GC.S( "OPTION_CONTRIBUTION_METHOD" ),
            DisplayTable = {},
            ValueTable = {}
        },
    }

    self.OptionsTable = {}

    self:InitOptions()
end

function CLASS:AddDbFuncs( aControl, aDbVar, aSetFunc )
    aControl.getFunc = function() return self.Db:Get( aDbVar ) end
    aControl.setFunc = function( aNewValue )
        if( self.Db:Get( aDbVar ) ~= aDbVar ) then
            self.Db:Set( aDbVar, aNewValue )
            if( nil ~= aSetFunc ) then
                aSetFunc()
            end
        end
    end
    aControl.default = function() return self.Db:GetDefault( aDbVar ) end
end

-- Add a dropdown and extra options field for the specified policy
function CLASS:AddEnumPolicy( aOptionTbl, aEnum, aGuildIdx )
    local lookupByGuildName = GC[aEnum.Type.."ByGuildName"]
    local lookupClassById = GC[aEnum.Type.."ClassById"]

    local extrasControl = {
        type = "editbox",
        name = GC.S( "OPTION_EXTRA" ),
        getFunc = function()
            local info = self:GuildInfo( aGuildIdx )
            if( not info.present ) then
                return ""
            end
            return lookupByGuildName[info.name]:GetOptionText()
        end,
        setFunc = function( aNewValue )
            local info = self:GuildInfo( aGuildIdx )
            if( not info.present ) then
                return
            end
            lookupByGuildName[info.name]:SetOptionText( aNewValue )
        end,
        isMultiline = true,
        disabled = function()
            local info = self:GuildInfo( aGuildIdx )
            local enabled = ( info.present and lookupByGuildName[info.name]:HasOptions() )
            return not enabled
        end,
        isExtraWide = true
    }

    -- Accessors for the dropdown
    local setterFunc = GC.DbClass["SetGuild"..aEnum.Type]
    local getterFunc = function( aGuildName )
        return lookupByGuildName[aGuildName][aEnum.Type.."Id"]
    end

    local dropdownControl = {
        type = "dropdown",
        name = aEnum.Label,
        choices = aEnum.DisplayTable,
        choicesValues = aEnum.ValueTable,
        getFunc = function()
            local info = self:GuildInfo( aGuildIdx )
            if( not info.present ) then
                return 0
            end
            return getterFunc(info.name)
        end,
        setFunc = function( aNewValue )
            local info = self:GuildInfo( aGuildIdx )
            if( not info.present ) then
                return
            end

            -- Only update if changed
            if( getterFunc( info.name ) ~= aNewValue ) then
                local obj = lookupClassById[aNewValue]( info.name, info.settings )
                setterFunc( self.Db, info.name, aNewValue, aEnum.SetAuxParam )
                lookupByGuildName[info.name] = obj
                obj:SetDefaults()
            end
        end,
        default = function()
            local info = self:GuildInfo( aGuildIdx )
            if( not info.present ) then
                return
            end
            setterFunc( self.Db, info.name, 1, aEnum.SetAuxParam )
        end,
        disabled = function()
            return not self:GuildInfo( aGuildIdx ).present
        end
    }

    GC.Append( aOptionTbl, dropdownControl )
    GC.Append( aOptionTbl, extrasControl )
end

-- Add an option to the main option table
function CLASS:AddOption( aOption )
    GC.Append( self.OptionsTable, aOption )
end

-- Add a checkbox option to the main option table which toggles aDbVar
function CLASS:AddOptionVar( aControl, aDbVar, aSetFunc )
    self:AddDbFuncs( aControl, aDbVar, aSetFunc )
    self:AddOption( aControl )
end

-- Add the options for a specific guild
function CLASS:AddGuildMenu( aGuildIdx )
    local guildOptions = {}

    GC.Append( guildOptions, {
        type = "description",
        text = function()
            local info = self:GuildInfo( aGuildIdx )
            if( ( not info.present ) or
                ( info.rule:GetLastContributionDT():Invalid() ) ) then
                return GC.S( "NONE" )
            end

            local dt = info.rule:GetLastContributionDT()
            return GC.S( "OPTION_LAST_CONTRIBUTION" ).." @ "..dt:GetAbsoluteText( true )
        end
    } )

    GC.Append( guildOptions, {
        type = "button",
        name = GC.S( "CLEAR" ),
        func = function()
            local info = self:GuildInfo( aGuildIdx )
            if( info.present ) then
                info.settings.lastContributionTime = GC.DateTime.INVALID_TS
                info.rule:Update()
            end
        end,
        disabled = function()
            local info = self:GuildInfo( aGuildIdx )
            return (
                ( not info.present ) or
                ( info.rule:GetLastContributionDT():Invalid() ) )
        end,
        width = "half",
        isDangerous = true
    } )

    local key, enum
    for key,enum in ipairs( self.EnumTables ) do
        self:AddEnumPolicy( guildOptions, enum, aGuildIdx )
    end

    self:AddOption( {
        type = "submenu",
        name = function()
            local info = self:GuildInfo( aGuildIdx )
            if( not info.present ) then
                return GC.S( "GUILD" ).." "..tostring( aGuildIdx )
            end
            return info.name
        end,
        controls = guildOptions,
        disabled = function()
            local info = self:GuildInfo( aGuildIdx )
            return not info.present
        end
    } )
end

function CLASS:GuildInfo( aGuildIdx )
    local guildId = GetGuildId( aGuildIdx )
    out = {
        present = ( 0 ~= guildId )
    }
    if( out.present ) then
        out.name = GetGuildName( guildId )
        out.settings = self.Db:GetGuild( out.name )
        out.rule = GC.RuleByGuildName[out.name]
    end

    return out
end

function CLASS:InitOptions()
    -- Add top-level options
    self:AddOption( {
        type = "header",
        name = GC.S( "OPTION_HDR_GENERAL" )
    } )

    self:AddOptionVar( {
        type = "checkbox",
        name = GC.S( "OPTION_SHOW_MSG_ON_STARTUP" )
        },
        "doStartupMsg"
    )

    self:AddOption( {
        type = "checkbox",
        name = GC.S( "OPTION_DEBUG" ),
        getFunc = function() return GC.GetDebugMode() end,
        setFunc = function( aNewValue ) GC.SetDebugMode( aNewValue ) end,
        default = function() GC.ResetDebugMode() end
    } )

    self:AddOptionVar( {
        type = "checkbox",
        name = GC.S( "OPTION_LOCK_WINDOW_POS" )
        },
        "wposLock",
        function()
            GC.APP.Window:UpdateMovable()
        end
    )

    self:AddOptionVar( {
        type = "slider",
        name = GC.S( "OPTION_UTC_OFFSET" ),
        min = -12,
        max = 14,
        step = 0.5
        },
        "localTimeOffset"
    )

    -- Build the tables for the dropdown boxes
    local key, tbl, nVal, sVal
    for key,tbl in ipairs( self.EnumTables ) do
        for nVal,sVal in ipairs( GC[tbl.Type.."NameById"] ) do
            if( sVal == nil ) then
                GC.Debug( "Bad "..tbl.Type.." "..tostring( nVal ) )
            else
                GC.Append( tbl.DisplayTable, sVal )
                GC.Append( tbl.ValueTable, nVal )
            end
        end
    end

    -- Add controls for each guild
    for key = 1,5 do
        self:AddGuildMenu( key )
    end

    self.Panel = GC.LAM:RegisterAddonPanel( self.LamWksp, self.PanelData )
    GC.LAM:RegisterOptionControls( self.LamWksp, self.OptionsTable )
end
