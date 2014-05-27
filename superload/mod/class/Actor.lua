local _M                    = loadPrevious(...)
local base_levelup = _M.levelup

function _M:levelup()
	local ret = base_levelup(self)

	if self.tthief_ally then
		self.tthief_ally.max_level = self.max_level  -- make sure golem can level up with master
		self.tthief_ally:forceLevelup(self.level)
	end

	return ret
end
