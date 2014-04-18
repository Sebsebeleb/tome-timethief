newEffect{
    name = "BLESS_PAST_SLOW",
    --image = "talents/water_jet.png",
    desc = "Aura of Sloth slow",
    long_desc = function(self, eff) return ("Slowed by Aura of Sloth"):format() end,
    type = "magical",
    subtype = { healing = true },
    status = "detrimental",
    parameters = { power },
    activate = function(self, eff)
        eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("global_speed_add", eff.tmpid)
    end,
}

newEffect{
    name = "DAMAGE_STEAL",
    --image = "talents/water_jet.png",
    desc = "Damage steal",
    long_desc = function(self, eff) return ("Slowed by Aura of Sloth"):format() end,
    type = "magical",
    subtype = { healing = true },
    status = "beneficial",
    parameters = { power },
    callbackOnMove = function(self, eff, moved, force, ox, oy)
        --If we move more than 1 distance, we ignore the decay
        --game.logPlayer(self, self.x, self.y, ox, oy)
        if core.fov.distance(self.x, self.y, ox, oy) > 1 then --TODO: This might not work
            eff.ignore_decay = true
        end
    end,
    activate = function(self, eff)
        eff.ignore_decay = false
        eff.tmp_project = self:addTemporaryValue("melee_project", {[DamageType.TEMPORAL]=eff.power})
        eff.damage = eff.power
    end,
    on_merge = function(self, old_eff, new_eff)
        new_eff.power = old_eff.power + new_eff.power
        self:removeTemporaryValue("melee_project", old_eff.tmp_project)
        new_eff.tmp_project = self:addTemporaryValue("melee_project", {[DamageType.TEMPORAL]=new_eff.power})
        return new_eff
    end,
    on_timeout = function(self, eff)
        if not eff.ignore_decay then
            eff.power = math.floor(eff.power * 0.70)
            self:removeTemporaryValue("melee_project", eff.tmp_project)
            eff.tmp_project = self:addTemporaryValue("melee_project", {[DamageType.TEMPORAL]=eff.power})
        end
        eff.ignore_decay = false
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("melee_project", eff.tmp_project)
    end,
}

newEffect{
    name = "LOST_KNOWLEGE",
    desc = "Lost Knowledge",
    long_desc = function(self, eff) return ("This creature has lost one of its susatins"):format() end,
    type = "magical",
    subtype = { healing = true },
    status = "detrimental",
    parameters = { talent },
    activate = function(self, eff)
        eff.level = self:getTalentLevelRaw(eff.talent)
        self:unlearnTalentFull(eff.talent)
    end,
    deactivate = function(self, eff)
        self:learnTalent(eff.talent, true, eff.level)
    end,
}

newEffect{
	name = "DEAL_WITH_IT_LATER",
	desc = "Deal with it later",
	long_desc = function(self, eff) return ("Afflicitions of this creature has been sent into the future"):format() end,
	type = "magical",
	subtype =  { healing = true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		eff.effs = {}
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				eff.effs[#eff.effs+1] = {eff_id, table.clone(p) }
				self:removeEffect(eff_id)
			end
		end
	end,
	deactivate = function(self, eff)
		game.logPlayer(self, "hello?")
		for _, v in pairs(eff.effs) do
			local eff_id, p = unpack(v)
			self:setEffect(eff_id, p.dur, p)
		end
	end
}