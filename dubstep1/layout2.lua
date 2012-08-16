module(...,package.seeall)

local layoutAppearTime = nil

local gl = nil
if (package.loaded.globals == nil) then
	gl = require("globals")
else
	gl = package.loaded.globals
end	

local w = gl.w
local h = gl.h

local backs = {}

function getLayoutBacks()
	return backs
end

function getLayoutAppearTime()
	return layoutAppearTime
end

function new()
	local mainGroup = display.newGroup()
	local localGroup = display.newGroup()
	
	local numSamples = 15
	local numFX = 5
	local numVoices = 5
	
	gl.currentLayout = "layout2"	
	gl.currentNumSamples = numSamples
	gl.currentNumFX = numFX
	gl.currentNumVoices = numVoices
	
	local playModule = require("playing")
	layoutAppearTime = system.getTimer()
	local kitAddress = "T"

	playModule.firstTimePlayPressed = nil
	
	local playParams = {true,true,false,false,false,6,5,4,5,5}

	local trackCounters = playModule.resetCounters(numSamples)

	local sampleKit = playModule.initSounds(kitAddress,numSamples,numFX,numVoices)

	playModule.prepareToPlay(sampleKit,playParams,numSamples,numFX,numVoices)

	local function playSound1 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,1,numSamples,numFX,numVoices,playParams)
   	 	end
	end
	local function playSound2 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,2,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound3 (event)
    	if (event.phase == "ended") then		
			playModule.play(localGroup,sampleKit,trackCounters,3,numSamples,numFX,numVoices,playParams)

    	end
	end
	local function playSound4 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,4,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound5 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,5,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound6 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,6,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound7 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,7,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound8 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,8,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound9 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,9,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound10 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,10,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound11 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,11,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound12 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,12,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound13 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,13,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound14 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,14,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound15 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,15,numSamples,numFX,numVoices,playParams)
   	 	end
	end
	local function playSound16 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,16,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound17 (event)
    	if (event.phase == "ended") then		
			playModule.play(localGroup,sampleKit,trackCounters,17,numSamples,numFX,numVoices,playParams)

    	end
	end
	local function playSound18 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,18,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound19 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,19,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound20 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,20,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound21 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,21,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound22 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,22,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound23 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,23,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound24 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,24,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound25 (event)
    	if (event.phase == "ended") then
			playModule.play(localGroup,sampleKit,trackCounters,25,numSamples,numFX,numVoices,playParams)
    	end
	end
	
	local function bindEventListeners()
		local handlerTable = {playSound1, playSound2,playSound3,
					playSound4,playSound5,playSound6,playSound7,playSound8,
					playSound9,playSound10,playSound11,
					playSound12,playSound13,playSound14,
					playSound15,playSound16,playSound17,
					playSound18,playSound19,playSound20,
					playSound21,playSound22,playSound23,
					playSound24,playSound25}
		local idx = 1
		while(idx <= localGroup.numChildren) do
			localGroup[idx]:addEventListener("touch",handlerTable[idx])
			idx = idx + 1
		end
	end
	
	gl.btns = gl.drawLayoutBtns()
		
	for idx,val in pairs(gl.btns) do
		gl.btns[idx].alpha = 0.5
	end
	
	gl.btns[2].alpha = 1
		
	btn1 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn2 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn3 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn4 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn5 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn6 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn7 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn8 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn9 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn10 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn11 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn12 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn13 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn14 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn15 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn16 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn17 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn18 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn19 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn20 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn21 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn22 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn23 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn24 = display.newRoundedRect(1,1,w/10,h/10,2)
	btn25 = display.newRoundedRect(1,1,w/10,h/10,2)
		
	btn1.x,btn2.x,btn3.x,btn4.x,btn5.x,btn6.x = w/7,2*w/7,3*w/7,4*w/7,5*w/7,6*w/7
	btn7.x,btn8.x,btn9.x,btn10.x,btn11.x = w/6,w/3,w/2,2*w/3,5*w/6
	btn12.x,btn13.x,btn14.x,btn15.x= w/5,2*w/5,3*w/5,4*w/5
	btn16.x,btn17.x,btn18.x,btn19.x,btn20.x = w/6,w/3,w/2,2*w/3,5*w/6
	btn21.x,btn22.x,btn23.x,btn24.x,btn25.x = w/6,w/3,w/2,2*w/3,5*w/6
		
	btn1.y,btn2.y,btn3.y,btn4.y,btn5.y,btn6.y = h/7,h/7,h/7,h/7,h/7,h/7
	btn7.y,btn8.y,btn9.y,btn10.y,btn11.y = 2*h/7,2*h/7,2*h/7,2*h/7,2*h/7
	btn12.y,btn13.y,btn14.y,btn15.y = 3*h/7,3*h/7,3*h/7,3*h/7
	btn16.y,btn17.y,btn18.y,btn19.y,btn20.y = 4*h/7,4*h/7,4*h/7,4*h/7,4*h/7
	btn21.y,btn22.y,btn23.y,btn24.y,btn25.y = 5*h/7,5*h/7,5*h/7,5*h/7,5*h/7
		
	btn1:setFillColor(255,0,0)
	btn2:setFillColor(255,0,0)
	btn3:setFillColor(255,0,0)
	btn4:setFillColor(255,0,0)
	btn5:setFillColor(255,0,0)
	btn6:setFillColor(255,0,0)
	btn7:setFillColor(0,0,255)
	btn8:setFillColor(0,0,255)
	btn9:setFillColor(0,0,255)
	btn10:setFillColor(0,0,255)
	btn11:setFillColor(0,0,255)
	btn12:setFillColor(255,0,255)
	btn13:setFillColor(255,0,255)
	btn14:setFillColor(255,0,255)
	btn15:setFillColor(255,0,255)
	btn16:setFillColor(0,255,255)
	btn17:setFillColor(0,255,255)
	btn18:setFillColor(0,255,255)	
	btn19:setFillColor(0,255,255)
	btn20:setFillColor(0,255,255)
	btn21:setFillColor(0,255,0)
	btn22:setFillColor(0,255,0)
	btn23:setFillColor(0,255,0)
	btn24:setFillColor(0,255,0)
	btn25:setFillColor(0,255,0)

	btn1.alpha = 0.5
	btn2.alpha = 0.5
	btn3.alpha = 0.5
	btn4.alpha = 0.5
	btn5.alpha = 0.5
	btn6.alpha = 0.5
	btn7.alpha = 0.5
	btn8.alpha = 0.5
	btn9.alpha = 0.5
	btn10.alpha = 0.5
	btn11.alpha = 0.5
	btn12.alpha = 0.5
	btn13.alpha = 0.5
	btn14.alpha = 0.5
	btn15.alpha = 0.5
	btn16.alpha = 0.5
	btn17.alpha = 0.5
	btn18.alpha = 0.5
	btn19.alpha = 0.5
	btn20.alpha = 0.5
	btn21.alpha = 0.5
	btn22.alpha = 0.5
	btn23.alpha = 0.5
	btn24.alpha = 0.5
	btn25.alpha = 0.5
		
	localGroup:insert(btn1)
	localGroup:insert(btn2)
	localGroup:insert(btn3)
	localGroup:insert(btn4)
	localGroup:insert(btn5)
	localGroup:insert(btn6)
	localGroup:insert(btn7)
	localGroup:insert(btn8)
	localGroup:insert(btn9)
	localGroup:insert(btn10)
	localGroup:insert(btn11)	
	localGroup:insert(btn12)
	localGroup:insert(btn13)
	localGroup:insert(btn14)
	localGroup:insert(btn15)
	localGroup:insert(btn16)
	localGroup:insert(btn17)
	localGroup:insert(btn18)
	localGroup:insert(btn19)
	localGroup:insert(btn20)
	localGroup:insert(btn21)
	localGroup:insert(btn22)
	localGroup:insert(btn23)
	localGroup:insert(btn24)
	localGroup:insert(btn25)
			
	bindEventListeners()	
		
	backs[1] = display.newRect(0,0,w,h)
	backs[2] = display.newRect(0,0,w,h)
	backs[3] = display.newRect(0,0,w,h)
	backs[4] = display.newRect(0,0,w,h)
	backs[5] = display.newRect(0,0,w,h)	
	
	backs[1]:setFillColor(10,150,100)
	backs[2]:setFillColor(150,150,150)
	backs[3]:setFillColor(50,50,50)
	backs[4]:setFillColor(10,10,10)
	backs[5]:setFillColor(100,100,100)
	
	backs[1].isVisible = false
	backs[2].isVisible = false
	backs[3].isVisible = false
	backs[4].isVisible = false
	backs[5].isVisible = false
	
	backs[1].isVisible = true
	mainGroup:insert(1,backs[1])
	mainGroup:insert(2,localGroup)

	gl.mainGroup = mainGroup
	gl.localGroup = localGroup 
	gl.currentBacks = backs
	
	return mainGroup
end