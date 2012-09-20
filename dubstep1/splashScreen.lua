module (...,package.seeall)

function new() 
	local gl = require("globals")
	local localGroup = display.newGroup()
	local splashImage = display.newImageRect("images/splashScreen/splashScreenImage.jpg",gl.w,gl.h)
	
	splashImage.x,splashImage.y = gl.w/2,gl.h/2
	
	localGroup:insert(splashImage)
	
	return localGroup
end