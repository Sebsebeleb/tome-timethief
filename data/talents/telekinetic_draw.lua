newTalentType{ allow_random=true, type="chronomancy/telekinetic_draw", name="telekinetic draw", description = "Use telekinetic powers to enhance your draw power" }

req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}

newTalent{
	name = "Augumented Shots",
	type = {"chronomancy/telekinetic_draw", 1},
	mode = "passive",
	points = 5,
	require = req1,
	no_unlearn_last = true,
	tactical = { ESCAPE = 2 },
	getPenality = function(self, t)
		return 75
	end,
	getMinReduction = function(self, t)
		return 25
	end,
	getMaxReduction = function(self, t)
		return 75
	end,
	info = function(self, t)
		local penality = t.getPenality(self, t)
		local min_red = t.getMinReduction(self, t)
		local max_red = t.getMaxReduction(self, t)
		return ([[You augument your shot with your telekinetic powers. However, because of the unstable state of your existance, you have problems aiming without assistance. All damage dealt by projectiles is reduced by %d%%. This penality is reduced against enemies closer to your other self, from %d%% reduction at distance 4 to %d%% at distance 1]]):format(penality, min_red, max_red)
	end
}

newTalent{
	name = "Piercing Shot",
	type = {"chronomancy/telekinetic_draw", 2},
	mode = "activated",
	points = 5,
	require = req2,
	no_unlearn_last = true,
	tactical = { ESCAPE = 2 },
	range = 10,

	action = function(self, t)
		local other_self = self.summoner
		local target
        local tg = {type="hit", range=self:getTalentRange(t)}
        local tx, ty = self:getTarget(tg)
        if tx and ty then
            local _ _, tx, ty = self:canProject(tg, tx, ty)
            if not tx then return nil end

           	if not core.fov.distance(tx, ty, other_self.x, other_self.y) <= 1 then
           		game.logPlayer(self, "You must target a square next to your other self")
           	end

			local targets = self:archeryAcquireTargets({type="beam"}, {one_shot=true, x=tx, y=ty})
			if not targets then return end
			self:archeryShoot(targets, t, {type="beam"}, {mult=self:combatTalentWeaponDamage(t, 1, 1.5), apr=1000})

			--TODO: Check for wells
			return true

        else
            return nil
        end
    end,
 	info = function(self, t)
		return ([[You use your telekinetic power to draw the bow string with incredible strength, while using timespace manipulation to make sure the string doesnt snap, resulting in an extremely fast arrow. However, you require the guidance of your other self and must target a spot next to your other self. This results in a beam attack hitting all enemies in the beam, while you use spacetime manipulation to make sure you do not hit your other self. Any temporal wells hit will explode, dealing x damage in radius 2.]]):format(penality, min_red, max_red)
	end,
}
