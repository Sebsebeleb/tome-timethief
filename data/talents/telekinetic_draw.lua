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
		callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam)
		if not (hitted and self.summoner and target and target.x) then -- Don't think this should happen when it would matter
			mult = t.getMaxReduction(self, t)
			return 
		end
		mult = mult * t.getDamagePenality(self, t, target) --TODO: This one doesnt work properly
	end,
	getDamagePenality = function(self, t, target)
		if not self.summoner and target.x then
			return 1.0
		end
		local dist = core.fov.distance(self.summoner.x, self.summoner.y, target.x, target.y)
		local mult = t.getMaxReduction(self, t)
		mult = mult * (t.getMaxReduction(self, t) - t.getMinReduction(self, t)) * (util.bound(dist, 0, 4) / 4)

		return mult 
	end,	tactical = { ESCAPE = 2 },
	getMinReduction = function(self, t)
		return 30
	end,
	getMaxReduction = function(self, t)
		return 75
	end,
	info = function(self, t)
		local min_red = t.getMinReduction(self, t)
		local max_red = t.getMaxReduction(self, t)
		return ([[You augument your shot with your telekinetic powers. However, because of the unstable state of your existance, you have problems aiming without assistance. If the target is 4 tiles or closer to your other self, this penality will be reduced, from %d%% at 5 distance, to %d%% at 1 distance.]]):format(max_red, min_red)
	end
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
        local tx, ty = self:getTarget(tg)
        if tx and ty then
            local _ _, tx, ty = self:canProject(tg, tx, ty)
            if not tx then return nil end

           	if not (core.fov.distance(tx, ty, other_self.x, other_self.y) <= 1) then
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

newTalent{
	name = "Grappling Arrow",
	type = {"chronomancy/telekinetic_draw", 3},
	mode = "activated",
	points = 5,
	require = req2,
	no_unlearn_last = true,
	tactical = { ESCAPE = 2 },
	range = 10,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "The target is out of range")
			return nil
		end

		local dist = core.fov.distance(self.x, self.y, target.x, target.y)
		target:pull(self.x, self.y, dist/2)
		self:pull(target.x, target.y, tg.range)
		--game:playSoundNear(self, "talents/arcane")

		return true
	end,
 	info = function(self, t)
		return ([[pulls you and another creature towards each other, ending up as close to one another as possible (stopped by obstacles)]]):format()
	end,
}
