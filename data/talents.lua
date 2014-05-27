-- Level 0 cun tree requirements:
tthief_mag_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
tthief_mag_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
tthief_mag_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
tthief_mag_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}

load("/data-timethief/talents/timethief.lua")
load("/data-timethief/talents/timephase.lua")
load("/data-timethief/talents/hurt_o_clock.lua")
load("/data-timethief/talents/alive_today_dead_yesterday.lua")
load("/data-timethief/talents/ten_past_death.lua")
load("/data-timethief/talents/special.lua")
load("/data-timethief/talents/telekinetic_draw.lua")
