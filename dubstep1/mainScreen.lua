module (...,package.seeall)

function new()
	local localGroup = display.newGroup()
	local mainGroup = display.newGroup()
	local gl = require("globals")
	
	local delta = 3
	
	--[[gl.loading = display.newText("Loading...", 0, 0, native.systemFont, 32)
	gl.loading.x,gl.loading.y = gl.w/2,gl.h/4
	gl.loading.isVisible = false]]--
	
	--local level1Btn = display.newRoundedRect(1,1,gl.w/5,gl.h/5,2)
	local level2Btn = display.newRoundedRect(1,1,gl.w/5,gl.h/5,2)

	--level1Btn.x,level1Btn.y = gl.w/3,gl.h/2
	level2Btn.x,level2Btn.y = gl.w/2,gl.h/2
	
	--level1Btn:setFillColor(255,255,0)
	level2Btn:setFillColor(0,255,255)
	
	--local txtLevel1 = display.newText("Lvl1",0,0,native.systemFont,14)	
	local txtLevel2 = display.newText("Continue",0,0,native.systemFont,14)	
	
	--txtLevel1.x,txtLevel1.y = gl.w/3,gl.h/2
	txtLevel2.x,txtLevel2.y = gl.w/2,gl.h/2
	
	--txtLevel1:setTextColor(0,0,0)
	txtLevel2:setTextColor(0,0,0)

	--local toLevel1Handler
	local toLevel2Handler
	
	--[[toLevel1Handler = function (event)
		if event.phase == "ended" then
			gl.loading.isVisible = true
			localGroup[1]:removeEventListener("touch", toLevel1Handler)
			localGroup[2]:removeEventListener("touch", toLevel2Handler)
			gl.currentLayout = "layout1"
			gl.choosenSide = "dobro"
			timer.performWithDelay(20, function () director:changeScene("level") end)
		end
	end]]--
	toLevel2Handler = function (event)
		if event.phase == "ended" then
			gl.loading.isVisible = true
			localGroup[1]:removeEventListener("touch", toLevel2Handler)
			--localGroup[2]:removeEventListener("touch", toLevel1Handler)
			gl.currentLayout = "layout2"
			gl.choosenSide = "evil"
			gl.inLevel = true
			timer.performWithDelay(20, function () director:changeScene("level") end)
		end
	end
	
	local function bindListeners() 
		local handlerTable = {toLevel2Handler}--,toLevel1Handler}
		
		local idx = 1
		while (idx <= #handlerTable) do
			localGroup[idx]:addEventListener("touch",handlerTable[idx])
			idx = idx + 1
		end
	end
	
	--localGroup:insert(level1Btn)
	localGroup:insert(level2Btn)
	--localGroup:insert(gl.loading)
	
	bindListeners()
	
--	mainGroup:insert(backGround)
--	mainGroup:insert(localGroup)
	return localGroup
end