module (...,package.seeall)

function new()
	local localGroup = display.newGroup()
	local splashImage = display.newImageRect("images/iphone/splashScreenImage.png",display.contentWidth,display.contentHeight)
	
	splashImage.x,splashImage.y = display.contentWidth/2,display.contentHeight/2
	
	localGroup:insert(splashImage)



	
	return localGroup
end