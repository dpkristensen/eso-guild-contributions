--[[
    Common definitions for rules

    Copyright 2018 okulo
]]

local GC = GuildContributionsAddonContainer

-- Rule IDs must stay consistent for saved variables
GC.RuleId = {}
GC.Enum(
    GC.RuleId,
    1, -- 1-based for indexing
    "NONE",
    "WEEKDAY"
)

GC.RuleNameById = {}
GC.RuleClassById = {}
GC.RuleByGuildName = {}
