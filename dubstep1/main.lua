system.activate("multitouch")

local director = require("director")

display.setStatusBar( display.HiddenStatusBar )

local mainGroup = display.newGroup()

local function toMainScreen(event)
	director:changeScene("layout1")
end

local function main()
	local startSound = audio.loadSound("startSound.mp3")
	audio.play(startSound, {channel = 30, loops = 0, onComplete = function()
		audio.dispose(startSound)
	end})
	audio.setVolume(0.2, {channel = 30})
	mainGroup:insert(director.directorView)
	director:changeScene("splashScreen")
	timer.performWithDelay(3000, function () 
									director:changeScene("mainScreen")
								 end )
	return true
end

main()