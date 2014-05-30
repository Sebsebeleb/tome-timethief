newTalentType{ allow_random=true, type="chronomancy/timethief-special", name="Special talents", description = "Special talents" }

req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}

local function makeAlly(self)
	local g = require("mod.class.NPC").new{
		type = self.type, subtype = self.subtype,
		display = 'g', color=colors.WHITE, image = self.image,
		moddable_tile = self.moddable_tile,
		moddable_tile_nude = self.moddable_tile_nude,
		moddable_tile_base = self.moddable_tile_base,
		female = not self.female,
--		level_range = {1, 50}, exp_worth=0,
		level_range = {1, self.max_level}, exp_worth=0,

		--TODO: Should be the life rating of the players' race, minus a few points
		life_rating = 8,
		never_anger = true,
		save_hotkeys = true,

		combat = { dam=10, atk=10, apr=0, dammod={str=1} },

		--TODO: This one should actually copy the player's body. This is just the standard one.
		body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1, QS_QUIVER = 1 },
		--body = self.body, 
		equipdoll = self.equipdoll,
		infravision = self.infravision,
		rank = self.rank,
		size_category = self.size_category,

		resolvers.talents{
			[Talents.T_SHOOT] = 1,
			[Talents.T_AUGUMENTED_SHOTS] = 1,
			[Talents.T_SHARED_MIND] = 1,
		},

		resolvers.equip{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},

		talents_types = {
			["chronomancy/telekinetic_draw"]={true, 0.3}
		},
		talents_types_mastery = {
		},
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),

		hotkey = {},
		hotkey_page = 1,
		move_others = true,

		ai = "tactical",
		ai_state = { talent_in=1, ai_move="move_astar", ally_compassion=10 },
		ai_tactic = resolvers.tactic"ranged",
		stats = { str=14, dex=12, mag=12, con=12 },

		-- No natural exp gain
		gainExp = function() end,
		forceLevelup = function(self) if self.summoner then return mod.class.Actor.forceLevelup(self, self.summoner.level) end end,

		-- Break control when losing LOS
		--on_act = function(self)
		--	if game.player ~= self then return end
		--	if not self.summoner.dead and not self:hasLOS(self.summoner.x, self.summoner.y) then
		--		if not self:hasEffect(self.EFF_GOLEM_OFS) then
		--			self:setEffect(self.EFF_GOLEM_OFS, 8, {})
		--		end
		--	else
		--		if self:hasEffect(self.EFF_GOLEM_OFS) then
		--			self:removeEffect(self.EFF_GOLEM_OFS)
		--		end
		--	end
		--end,

		--on_can_control = function(self, vocal)
		--	if not self:hasLOS(self.summoner.x, self.summoner.y) then
		--		if vocal then game.logPlayer(game.player, "Your golem is out of sight; you cannot establish direct control.") end
		--		return false
		--	end
		--	return true
		--end,

		--unused_stats = 0,
		--unused_talents = 0,
		--unused_generics = 0,
		--unused_talents_types = 0,

		--no_points_on_levelup = function(self)
		--	self.unused_stats = self.unused_stats + 2
		--	if self.level >= 2 and self.level % 3 == 0 then self.unused_talents = self.unused_talents + 1 end
		--end,

		keep_inven_on_death = true,
--		no_auto_resists = true,
		open_door = true,
		can_change_level = true,
	}

	return g
end

newTalent{
	name = "Two Of One",
	type = {"chronomancy/timethief-special", 1},
	--autolearn_talent = "T_INTERACT_GOLEM",
	require = req1,
	points = 1,
	cooldown = 20,
	paradox = 0,
	no_npc_use = true,
	no_unlearn_last = true,
	invoke_ally = function(self, t)
		self.tthief_ally = game.zone:finishEntity(game.level, "actor", makeAlly(self))
		if game.party:hasMember(self) then
			game.party:addMember(self.tthief_ally, {
				control="full", type="ally", title="Other You", important=true,
				orders = {target=true, leash=true, anchor=true, talents=true, behavior=true},
			})
		end
		if not self.tthief_ally then return end
		self.tthief_ally.faction = self.faction
		self.tthief_ally.name = self.name.." (from a different dimension)"
		--self.tthief_ally.image = self.image
		self.tthief_ally.summoner = self
		self.tthief_ally.summoner_gain_exp = true

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to refit!")
			return
		end
		game.zone:addEntity(game.level, self.tthief_ally, "actor", x, y)
	end,
	info = function(self, t)
		return ([[Blahblah.]])
	end
}

newTalent{
	name = "Shared mind",
	type = {"chronomancy/other", 1},
	require = req1,
	mode = "sustained",
	points = 1,
	cooldown = 0,
	no_energy = true,
	no_npc_use = true,
	no_unlearn_last = true,
	callbackOnActBase = function(self, t)
		local see_hostile = false
		for k, v in pairs(self.fov.actors_dist) do
			if v and self:reactionToward(v) < 0 and self:canSee(v) then --We assume we see the same as our other self; TODO
				see_hostile = true
				break
			end
		end

		if see_hostile then
			game.party:setPlayer(self, true)
		end
	end,
	activate = function(self, t)
		--Shouldnt really happen unless you somehow steal or hack in this talent somewhere
		if not (self.summoner or self.tthief_ally) then
			return nil
		end

		local other = self.tthief_ally or self.summoner
		if (self.tthief_shared_mind_ignore == nil) and (not other:isTalentActive(other.T_SHARED_MIND)) then
			other.tthief_shared_mind_ignore = true
			other:forceUseTalent(other.T_SHARED_MIND, {ignore_energy=true})
		end
		self.tthief_shared_mind_ignore = nil
		return true
	end,
	deactivate = function(self, t)
		--Shouldnt really happen unless you somehow steal or hack in this talent somewhere
		if not (self.summoner or self.tthief_ally) then
			return nil
		end

		local other = self.tthief_ally or self.summoner
		if (self.tthief_shared_mind_ignore == nil) and (other:isTalentActive(other.T_SHARED_MIND)) then
			other.tthief_shared_mind_ignore = true
			other:forceUseTalent(other.T_SHARED_MIND, {ignore_energy=true})
		end
		self.tthief_shared_mind_ignore = nil
		return true
	end,
	info = function(self, t)
		return([[While this is sustained, you will switch control to the other you when it its turn, as long as theres any enemy in vision of either you.]])
	end
}