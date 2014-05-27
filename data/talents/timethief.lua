newTalentType{ allow_random=true, type="chronomancy/past", name="voidwalker", description = "You have learned to step through the cracks in reality." }

req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}



newTalent{
	name = "Back to the Past", short_name = "BACK_TO_THE_PAST",
	type = {"chronomancy/past", 1},
	points = 5,
    cooldown = 4,
	require = req1,
	tactical = { ESCAPE = 2 },
	updateClones = function(self, t) -- Updates clones per movement/turn passed.
        local new_clones = {}
        local oldest_clone --FIXME: Not working when there are less than 3 clones for some reason
        for i, v in ipairs(self.tthief_clones) do
            new_clones[i+1] = v
            if not (i+1 == 4) then
                oldest_clone = v
            end
        end
        self.tthief_clones = new_clones

        --Remove expired clone, if any
        local expired_clone = self.tthief_clones[4]
        if expired_clone then
            local effect, pos = expired_clone.eff, expired_clone.pos
            effect.duration  = 0
            self.tthief_clones[4] = nil
        end

        --Update the map effect of the oldest, not expiring clone.
        if oldest_clone then
            oldest_clone.eff.overlay.color_br = 200
            oldest_clone.eff.overlay.color_bb = 100
            oldest_clone.eff.overlay.color_bg = 50
		end
	end,
    getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.7) end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
        if not moved or not ox or not oy then
            return moved, force, ox, oy
        end
        if not self.tthief_clones then
            self.tthief_clones = {}
        end

        if ox and oy and ox ~= self.x or oy ~= self.y then
            local eff = game.level.map:addEffect(self,
                ox, oy, 10, -- The effect duration is set high and instead modified directly later on, to avoid mismatch between the mapeffect and the actual clone state
                DamageType.COSMETIC, 0,
                0,
                5, 5,
                engine.Entity.new{alpha=100, display='', color_br=176, color_bg=196, color_bb=222},
                nil, false
            )

            t.updateClones(self, t)

            self.tthief_clones[1] = {eff=eff, pos={x=ox, y=oy}}
        end

        return moved, force, ox, oy
	end,
    action = function(self, t)
        if not self.tthief_clones then
            return nil
        end

        --Get the oldest clone
        local oldest
        for i,v in ipairs(self.tthief_clones) do
            oldest = v
        end
        if oldest then
            local x, y = oldest.pos.x, oldest.pos.y
            local blocking_actor = game.level.map(x, y, Map.ACTOR)
            if blocking_actor then
                game.log("Your clone's position is blocked")
                if blocking_actor:canBe("teleport") and self:canBe("teleport") then
                    --TODO: There's a bug where enemies occasionally "clone" | Might be fixed now
                    local old_x, old_y = self.x, self.y

                    game.level.map:remove(x, y, Map.ACTOR) -- Remove the target while we teleport to the square
                    self:teleportRandom(x, y, 0)
                    game.level.map(old_x, old_y, Map.ACTOR, blocking_actor) -- Return it to the player's old position
                    blocking_actor.x, blocking_actor.y = old_x, old_y
                end
            else
                self:teleportRandom(x, y, 0)
            end

            -- Check if there's an actor next to us now that we can strike.
            local tgts = {}
            local grids = core.fov.circle_grids(self.x, self.y, 1, true)
            for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
                local a = game.level.map(x, y, Map.ACTOR)
                if a and self:reactionToward(a) < 0 then
                    tgts[#tgts+1] = a
                end
            end end

            local target = rng.table(tgts)
            if target then
                local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)
                if hitted then -- Or should we reward the cooldown reduction even if the attack is a miss?
                    game:onTickEnd(function()
                        self.talents_cd[self.T_BACK_TO_THE_PAST] = nil
                        self.changed = true
                        end)
                end
            end
            return true
        end
        return nil
    end,
    info = function(self, t)
        local damage = t.getDamage(self, t)
        return ([[Return to your oldest clone. If an enemy is in the way, it will be teleported to your position. If an enemy is next to the clone, you will attack it for %d%% weapon damage and the cooldown of the talent will be refreshed]]
        ):format(damage * 100)
    end
}

newTalent{
    name = "Aura of Sloth", short_name = "AURA_OF_SLOTH",
    type = {"chronomancy/past", 2},
    points = 5,
    require = req1,
    tactical = { ESCAPE = 2 },
    mode = "sustained",
    cooldown = 10,
    radius = function(self, t) return 3 end,
    getSlow = function(self, t) return 0.20 end,
    callbackOnActBase = function(self, t)
        if not self:isTalentActive(self.T_AURA_OF_SLOTH) then -- TODO: Should probably find a better way to find the talent
        end
        local tg = {type="ball", range=0, selffire=false, radius=self:getTalentRadius(t)}
        self:project(tg, self.x, self.y, function(px, py, tg, self)
            local target = game.level.map(px, py, Map.ACTOR)
            if target and target ~= self then
                target:setEffect(target.EFF_BLESS_PAST_SLOW, 1, {power=t.getSlow()})
            end
        end)
    end,
    activate = function(self, t)
        return true
    end,
    deactivate = function(self, t)
        return true
    end,
    info = function(self, t)
        return ([[Enemies in radius 2 around you are slowed by 20%%. Everytime an enemy is affected this for x number consecutive turns, it will have all its debilitating effects' duration increased by one.]]):format()
    end
}

newTalent{
    name = "Timely dash", short_name = "TIMELY_DASH",
    type = {"chronomancy/past", 3},
    points = 5,
    require = req1,
    tactical = { ESCAPE = 2 },
    range = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 2, 4)) end,
    action = function(self, t)

        local target
        local tg = {type="hit", range=self:getTalentRange(t)}
        local tx, ty = self:getTarget(tg)
        if tx and ty then
            local _ _, tx, ty = self:canProject(tg, tx, ty)
            if not tx then return nil end
            target = game.level.map(tx, ty, Map.ACTOR)
            if not target then game.logPlayer(self, "You need to target a creature") return nil end
        else
            return nil
        end

        --old
        --local tg = {type="hit", range=self:getTalentRange(t)}
        --local x, y, target = self:getTarget(tg)
        --if not x or not y or not target then return nil end

        local dash_x, dash_y = self.x + (tx - self.x)*2, self.y + (ty - self.y)*2
        if not self:canMove(dash_x, dash_y, false) then --Might be the wrong way to check this
            game.logPlayer(self, "Your landing spot is blocked")
            return nil
        end

        self:move(dash_x, dash_y, false)
        target:setEffect(target.EFF_DAZED, 2, {apply_power=self:combatPhysicalpower()})

        return true
    end,
    info = function(self, t)
        return ([[You dash trhourh an enemy, ending up on the direct other side of it, with the same diandcece to it. The target you dash through is dazed for 2 turns]]):format()
    end
}
