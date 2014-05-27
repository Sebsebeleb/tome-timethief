package.loaded['mod.dialogs.DeathDialog'] = nil

local class = require"engine.class"
local ActorTalents = require"engine.interface.ActorTalents"
local ActorResource = require"engine.interface.ActorResource"
local ActorTemporaryEffects = require"engine.interface.ActorTemporaryEffects"
local Birther = require"engine.Birther"
local DamageType = require"engine.DamageType"
local Zone = require"engine.Zone"


class:bindHook("ToME:load",
    function(self, data)
    -- DamageType:loadDefinition("/data-timethief/new_damage_types.lua")
        ActorTalents:loadDefinition("/data-timethief/talents.lua")
        Birther:loadDefinition("/data-timethief/birth/classes/chronomancy.lua")
        ActorTemporaryEffects:loadDefinition("/data-timethief/timed_effects/timed_effects.lua")
    end)

-- class:bindHook("Combat:attackTargetWith", function(self, data)
-- 	local t = self:getTalentFromId(self.T_OPPORTUNE_STRIKE)
-- 	if data.hitted and not data.target.dead and data.weapon and data.weapon.talented== "double" and not self:attr("no_doublestrike") and rng.percent(t.getChance(self, t)) then
-- 		self:attr("no_doublestrike",1)
-- 		game.logSeen(self, "%s performs an extra offhand attack!", self.name:capitalize())
-- 		self:attackTargetWith(data.target, data.weapon, data.damtype, self:getOffHandMult(data.weapon,data.mult))
-- 		self:attr("no_doublestrike",-1)
-- 	end
-- end)