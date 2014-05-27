newTalentType{ allow_random=true, type="chronomancy/alive_today", name="alive today dead yesterday", description = "You use time to aid you in hurting stuff" }

req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}

newTalent{
	name = "KOKOKOKOKORORKOKOKORKOROKOOROOO",
	type = {"chronomancy/alive_today", 1},
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
	name = "Boom bap",
	type = {"chronomancy/alive_today", 2},
	mode = "passive",
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
	info = function(self, t)
		local damage = 2
		local increase = 2
		return ([[Aura around you that spreads like blight, dealign damage blah blah]]):format(damage, increase)
	end
}
