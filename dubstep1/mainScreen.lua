module (...,package.seeall)

function new()
	local localGroup = display.newGroup()
	local mainGroup = display.newGroup()
	local gl = require("globals")
	
	local backGround = display.newImageRect("images/mainScreenImage.png",gl.w,gl.h)
	backGround.x,backGround.y = gl.w/2,gl.h/2
	
	local level1Btn = display.newRoundedRect(1,1,gl.w/10,gl.h/10,2)
	local level2Btn = display.newRoundedRect(1,1,gl.w/10,gl.h/10,2)
	
	level1Btn.x,level1Btn.y = gl.w/3,gl.h/2
	level2Btn.x,level2Btn.y = 2*gl.w/3,gl.h/2
	
	level1Btn:setFillColor(255,255,0)
	level2Btn:setFillColor(0,255,255)
	
	local function toLevel1Handler(event)
		if (event.phase == "ended") then
			director:changeScene("layout1")
		end
	end
	local function toLevel2Handler(event)
		if (event.phase == "ended") then
			director:changeScene("layout2")
		end
	end
	
	local function bindListeners() 
		local handlerTable = {toLevel1Handler,toLevel2Handler}
		
		local idx = 1
		while (idx <= #handlerTable) do
			localGroup[idx]:addEventListener("touch",handlerTable[idx])
			idx = idx + 1
		end
	end
	
	localGroup:insert(level1Btn)
	localGroup:insert(level2Btn)
	
	bindListeners()
	
	mainGroup:insert(backGround)
	mainGroup:insert(localGroup)
	
	return mainGroup
end