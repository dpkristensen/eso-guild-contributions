--[[
    Common definitions for methods

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

-- Method IDs must stay consistent for saved variables
GC.MethodId = {}
GC.Enum(
    GC.MethodId,
    1, -- 1-based for indexing
    "MANUAL",
    "BANK",
    "MAIL"
)

GC.MethodNameById = {}
GC.MethodClassById = {}
GC.MethodByGuildName = {}
