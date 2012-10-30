system.activate("multitouch")

local director = require("director")

display.setStatusBar( display.HiddenStatusBar )
system.setIdleTimer( false )

audio.setVolume(3)
local mainGroup = display.newGroup()

--[[local monitorMem = {prevMeasure = -1000}

function monitorMem:enterFrame()
	if system.getTimer() - self.prevMeasure > 250 then
	    collectgarbage()
	    print( "MemUsage: " .. collectgarbage("count") )

	    local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
	    print( "TexMem:   " .. textMem )
	    self.prevMeasure = system.getTimer()
	end
end

Runtime:addEventListener( "enterFrame", monitorMem )]]--

mainGroup:insert(director.directorView)
director:changeScene("splashScreen")

--[[local function main()
	
	return true
end
timer.performWithDelay(200, function ()
	main()
end)]]--