newTalentType{ allow_random=true, type="chronomancy/timephase", name="timephase", description = "Using your time manipulation skills, you slip in and out of the timeline to protect yourself" }

req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}


newTalent{
	name = "Timeslip", short_name = "TIMESLIP",
	type = {"chronomancy/timephase", 1},
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
    action = function(self, t)
        return true
    end,
    info = function(self, t)
        return ([[You slip out of time for a while, preventing enemies from attackign you (like a self timeprison),
        while in this state, debilitating effects on you will timeout like usual, while beneficial effects will be preserved.]]):format()
    end
}

newTalent{
	name = "Deal with it later", short_name = "DEAL_WITH_IT_LATER",
	type = {"chronomancy/timephase", 2},
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
	getDuration = function(self, t)
		return 3
	end,
    action = function(self, t)
		self:setEffect(self.EFF_DEAL_WITH_IT_LATER, t.getDuration(self, t), {})
        return true
    end,
    info = function(self, t)
        return ([[You send all debilitating effects currently affecting you forward in time]]):format()
    end
}

--Idea by Gurkenglas
newTalent{
	name = "Knowledge theft", short_name = "KNOWLEDGE_THEFT",
	type = {"chronomancy/timephase", 3},
	points = 5,
	require = req1,
    range = 2,
	tactical = { ESCAPE = 2 },
    action = function(self, t)
        local tg = {type="hit", range=self:getTalentRange(t), talent=t}
        local tx, ty, target = self:getTarget(tg)
        if not tx or not ty or not target then return nil end
        local _ _, tx, ty = self:canProject(tg, tx, ty)
        target = game.level.map(tx, ty, Map.ACTOR)
        if target == self then target = nil end
        if not target then return end

        local possible_talents = {}
        for tid, _ in pairs(target.talents) do
            local t = target:getTalentFromId(tid)
            if t.mode == "sustained" then
                possible_talents[#possible_talents+1] = tid
            end
        end

        local steal = rng.table(possible_talents)
        local stolen = false
        while steal do
            if not self:knowTalent(steal) then
                self:learnTalent(steal, true, tlevel) --TODO: Talent level multiplier
                local t2 = self:getTalentFromId(steal)
                local old_deactivate = t.deactivate
                t2.deactivate = function(self, t, ...) --FIXME: Talents display sustain deactivation messages twice
                    old_deactivate(self, t, ...)
                    self:unlearnTalent(t.id)
                end
                game.logPlayer(self, "Stealing "..t.name)
                local tlevel = target:getTalentLevel(steal)
                self:forceUseTalent(steal, {no_talent_fail=true, no_equilibrium_fail=true, no_paradox_fail=true})

                -- Apply the debuff to the enemy
                local duration = 30
                --target:setEffect(target.EFF_LOST_KNOWLEDGE, duration, {talent=target:getTalentFromId(steal)})

                self.changed = true
                steal = nil
                stolen = true
            else
                steal = rng.table(possible_talents)
            end
        end
        if not stolen then
            game.logPlayer(self, "The target has no suitable talents")
            return nil
        end

        return true
    end,
    info = function(self, t)
        return ([[You steal an enemy's sustain, taking it yourself as a temporary but long lasting effect]]):format()
    end
}


newTalent{
	name = "Burden of time", short_name = "BURDEN_OF_TIME",
	type = {"chronomancy/timephase", 4},
	points = 5,
	require = req1,
	tactical = { ESCAPE = 2 },
    mode = "passive",
    info = function(self, t)
        return ([[When you directly attack an enemy with an attack or a talent, you apply a debuff to them that make
         them take more damage from each succesive attack, increasing with each attack. However, the extra damage will
         be lowered each turn you do not attack the creatrue]]):format()
    end
}