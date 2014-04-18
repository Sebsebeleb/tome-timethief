newTalentType{ allow_random=true, type="chronomancy/alive_today", name="alive today dead yesterday", description = "You use time to aid you in hurting stuff" }

req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}

newTalent{
	name = "Time Bullet", short_name = "TIME_BULLET",
	type = {"chronomancy/alive_today", 1},
	mode = "passive",
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
	callbackOnMove = function(self, t, moved, force, ox, oy)
		game.log(ox)
		game.log(oy)
		if not moved then
			return
		end
		if core.fov.distance(self.x, self.y, ox, oy) > 1 then --TODO: This might not work
			game.logPlayer(self, "Pew pew")
			local tg = {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false, display={particle="discharge_bolt", trail="lighttrail"} }
			tg.x = ox
			tg.y = oy
			local dam = self:spellCrit(self:combatTalentSpellDamage(t, 28, 120))
			local proj = self:projectile(tg, self.x, self.y, DamageType.TEMPORAL, dam)
		end
	end,
	info = function(self, t)
		local damage = 2
		local increase = 2
		return ([[Whenever you move more than 1 tile, you fire a bullet from your original location to your new location that travels half the distance you traveled in one turn. If the bullet hits an enemy, it will deal %d damaage + %d damage per tile it traveled before hitting something. If it hits you or a clone, it will instead ??? Ricochete maybe?]]):format(damage, increase)
	end
}

newTalent{
	name = "No Leg is Power", short_name = "NO_LEG_IS_POWER",
	type = {"chronomancy/alive_today", 2},
	mode = "passive",
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
	info = function(self, t)
		local damage = 2
		local increase = 2
		return ([[Attack and enemy and pin them in place for x turns]]):format(damage, increase)
	end
}

newTalent{
	name = "Strike from before", short_name = "STRIKE_FROM_BEFORE",
	type = {"chronomancy/alive_today", 3},
	mode = "passive",
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
	info = function(self, t)
		local damage = 2
		local increase = 2
		return ([[Each of your clones attack one enemy that are next to them (max 1 attack on each enemy) and swaps position with them.)]]):format(damage, increase)
	end
}

newTalent{
	name = "The buff", short_name = "THE_BUFF",
	type = {"chronomancy/alive_today", 1},
	mode = "passive",
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
	info = function(self, t)
		local damage = 2
		local increase = 2
		return ([[Some sort of debuff. Times out twice as fast if debuffed creature is not affected by aura of sloth. Talent cast failure]]):format(damage, increase)
	end
}
