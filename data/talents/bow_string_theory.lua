newTalentType{ allow_random=true, type="chronomancy/telekinetic_draw", name="telekinetic draw", description = "Use telekinetic powers to enhance your draw power" }

req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}

newTalent{
	name = "Piercing Shot",
	type = {"chronomancy/telekinetic_draw", 2},
	mode = "activated",
	points = 5,
	require = req2,
	tactical = { ESCAPE = 2 },
	range = 10,
	action = function(self, t)
		local other_self = self.summoner
		local target
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty, target = self:getTarget(tg)
		if not target then
			game.logPlayer(self, "You need a target")
			return nil
		end
	end
}