module (...,package.seeall)

function new()
	local localGroup = display.newGroup()
	local mainGroup = display.newGroup()
	local gl = require("globals")
	
	local delta = 3
	
	gl.loading = display.newText("Loading...", 0, 0, native.systemFont, 32)
	gl.loading.x,gl.loading.y = gl.w/2,gl.h/4
	gl.loading.isVisible = false
	
--	gl.rotator = display.newImageRect("images/mainScreen/rotator.jpeg",gl.w/5,gl.h/5)
--	gl.rotator.x,gl.rotator.y = gl.w/2,3*gl.h/4
	
--	local backGround = display.newImageRect("images/mainScreen/mainScreenImage.png",gl.w,gl.h)
--	backGround.x,backGround.y = gl.w/2,gl.h/2
	
	local level1Btn = display.newRoundedRect(1,1,gl.w/5,gl.h/5,2)
	local level2Btn = display.newRoundedRect(1,1,gl.w/5,gl.h/5,2)

	level1Btn.x,level1Btn.y = gl.w/3,gl.h/2
	level2Btn.x,level2Btn.y = 2*gl.w/3,gl.h/2
	
	level1Btn:setFillColor(255,255,0)
	level2Btn:setFillColor(0,255,255)
	
	local txtLevel1 = display.newText("Lvl1",0,0,native.systemFont,14)	
	local txtLevel2 = display.newText("Lvl2",0,0,native.systemFont,14)	
	
	txtLevel1.x,txtLevel1.y = gl.w/3,gl.h/2
	txtLevel2.x,txtLevel2.y = 2*gl.w/3,gl.h/2
	
	txtLevel1:setTextColor(0,0,0)
	txtLevel2:setTextColor(0,0,0)
	
	local function toLevel1Handler(event)
		gl.loading.isVisible = true
		if (event.phase == "ended") then
			director:changeScene("layout1")
		end
	end
	local function toLevel2Handler(event)
		gl.loading.isVisible = true
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
	localGroup:insert(gl.loading)
	
	bindListeners()
	
--	mainGroup:insert(backGround)
--	mainGroup:insert(localGroup)
	return localGroup
end