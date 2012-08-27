system.activate("multitouch")

local director = require("director")

local mainGroup = display.newGroup()

local function toMainScreen(event)
	director:changeScene("layout1")
end

local function main()
	mainGroup:insert(director.directorView)
	director:changeScene("splashScreen")
	timer.performWithDelay(3000, function () 
									director:changeScene("mainScreen")
								 end )
	return true
end

main()