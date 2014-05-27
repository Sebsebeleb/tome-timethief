local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"
 
local _M                    = loadPrevious(...)
local base_resurrectBasic = _M.resurrectBasic
 
function _M:resurrectBasic(actor)
	if actor.tthief_ally then
		base_resurrectBasic(self, actor.tthief_ally)
	end

	local ret = base_resurrectBasic(self, actor)

	return ret
end
 
return _M