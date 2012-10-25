system.activate("multitouch")

local director = require("director")

display.setStatusBar( display.HiddenStatusBar )
system.setIdleTimer( false )

audio.setVolume(2)
local mainGroup = display.newGroup()

mainGroup:insert(director.directorView)
director:changeScene("splashScreen")

--[[local function main()
	
	return true
end
timer.performWithDelay(200, function ()
	main()
end)]]--