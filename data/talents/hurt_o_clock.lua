newTalentType{ allow_random=true, type="chronomancy/hurtoclock", name="hurtoclock", description = "You use time to aid you in hurting stuff" }

req1 = {
    stat = { mag=function(level) return 12 + (level-1) * 2 end },
    level = function(level) return 0 + (level-1)  end,
}


newTalent{
    name = "Stabbystab", short_name = "STABBYSTAB",
    type = {"chronomancy/hurtoclock", 1},
    points = 5,
    require = req1,
    tactical = { ESCAPE = 2 },
    action = function(self, t)

        local tg = {type="hit", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
        self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.5), true)

        return true
    end,
    info = function(self, t)
        return ([[Strike an enemy in melee combat, and deal damage in radius ]]):format()
    end
}


newTalent{
    name = "Tick tock time to stop", short_name = "TICK_TOCK_TIME_TO_STOP",
    type = {"chronomancy/hurtoclock", 2},
    points = 5,
    require = req1,
    tactical = { ESCAPE = 2 },
    action = function(self, t)

        local tg = {type="hit", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
        self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.5), true)

        return true
    end,
    info = function(self, t)
        return ([[Stop time for everyone but you, but you cannot damage anyone.]]):format()
    end
}

newTalent{
    name = "Time to die", short_name = "TIME_TO_DIE",
    type = {"chronomancy/hurtoclock", 3},
    points = 5,
    require = req1,
    tactical = { ESCAPE = 2 },
    range = 5,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 290) end,
    target = function(self, t)
        local tg = {type="beam", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		return tg
	end,
    action = function(self, t)
        if not self.tthief_clones then
            game.logPlayer(self, "You do not have any clones to fire beams between")
            return nil
        end

        --TODO: currently doesnt loop back to the first clone
        local last_pos
        local first_clone
        local tg = {type="beam", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"} }
        for i, v in pairs(self.tthief_clones) do
            if not first_clone then
                first_clone = v
            end
            local x2, y2 = v.pos.x, v.pos.y
            if last_pos then
                --Do a beam
                tg.x = last_pos.x
                tg.y = last_pos.y
                self:project(tg, x2, y2, DamageType.FIREBURN, self:spellCrit(t.getDamage(self, t)))
                game.level.map:particleEmitter(tg.x, tg.y, 1, "temporalbeam", {tx=x2-tg.x, ty=y2-tg.y})
                --Beam end
            else
                last_pos = {}
            end
            last_pos.x = v.pos.x
            last_pos.y = v.pos.y
        end
        --Do the last beam to the first clone
        tg.x = last_pos.x
        tg.y = last_pos.y
        self:project(tg, first_clone.pos.x, first_clone.pos.y, DamageType.FIREBURN, self:spellCrit(t.getDamage(self, t)))
        game.level.map:particleEmitter(tg.x, tg.y, 1, "temporalbeam", {tx=first_clone.pos.x-tg.x, ty=first_clone.pos.y-tg.y})
        --Beam end

        return true
    end,
    info = function(self, t)
        return ([[All of your clones fire a beam to the other clones, dealing x damage]]):format()
    end
}

newTalent{
    name = "Damage Theft", short_name = "DAMAGE_THEFT",
    type = {"chronomancy/hurtoclock", 4},
    points = 5,
    require = req1,
    tactical = { ESCAPE = 2 },
    mode = "passive",
    getDuration = function(self, t) return 5 end,
    getSteal = function(self, t)
        return self:combatTalentSpellDamage(t, 5, 50)
    end,
    callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
        if hitted then
            self:setEffect(self.EFF_DAMAGE_STEAL, t.getDuration(self, t), {power=t.getSteal(self, t)})
        end
    end,
    info = function(self, t)
        local damage, increase, decay
        local eff = self.hasEffect and self:hasEffect(self.EFF_DAMAGE_STEAL)
        damage = eff and eff.power or 0
        increase = t.getSteal(self, t)
        decay = damage *0.70
        return ([[Each time you hit an enemy you deal %d extra damage as paradox. This bonus damage will be increased by %d every turn you move more than 1 square. Any turn you do not attack or move more than 1 square, the bonus damage will decay by %d (30%% of current bonus damage). The damage increase increases with talent level and spellpower]])
        :format(damage, increase, decay)
    end
}

newTalent{
    name = "Some dash", short_name = "SOME_DASH",
    type = {"chronomancy/hurtoclock", 5},
    points = 5,
    require = req1,
    tactical = { ESCAPE = 2 },
    action = function(self, t)

    end,
    info = function(self, t)
		return ([[You dash towards one of your clones, blahblah doing something]]):format()
	end
}

