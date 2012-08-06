module(...,package.seeall)

function new()	
	local localGroup = display.newGroup()	

	local numSamples = 9
	local numFX = 3
	local numVoices = 3
	local gl = require("globals")	
	local kitAddress = "sounds1/"

	local playParams = {false,true,false,true,true,2,4,3,3,3}

	local w = gl.w
	local h = gl.h

	gl.btns = gl.drawLayoutBtns()
	
	gl.firstTimePlayPressed = nil
	
	local trackCounters = {}
	trackCounters = gl.resetCounters(numSamples)

	local sampleKit = nil

	local function playSound1 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,1,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound2 (event)
 	   if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,2,numSamples,numFX,numVoices,playParams)
   	   end
	end
	local function playSound3 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,3,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound4 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,4,numSamples,numFX,numVoices,playParams)
   	 	end
	end
	local function playSound5 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,5,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound6 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,6,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound7 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,7,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound8 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,8,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound9 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,9,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound10 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,10,numSamples,numFX,numVoices,playParams)
   		end
	end
	local function playSound11 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,11,numSamples,numFX,numVoices,playParams)
   		end
	end
	local function playSound12 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,12,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound13 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,13,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound14 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,14,numSamples,numFX,numVoices,playParams)
    	end
	end
	local function playSound15 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,15,numSamples,numFX,numVoices,playParams)
    	end
	end

	local function bindEventListeners()
		local handlerTable = {playSound1,playSound2,playSound3,
				playSound4,playSound5,playSound6,
				playSound7,playSound8,playSound9,
				playSound10,playSound11,playSound12,
				playSound13,playSound14,playSound15}
		local idx = 1
		while(idx <= localGroup.numChildren) do
			localGroup[idx]:addEventListener("touch",handlerTable[idx])
			idx = idx + 1
		end
	end
	
	for idx,val in pairs(gl.btns) do
		gl.btns[idx].alpha = 0.5
	end
	
	gl.btns[1].alpha = 1	
	
	if (samplekit == nil) then
		sampleKit = gl.initSounds(kitAddress,numSamples,numFX,numVoices)
	end
	
	if (localGroup.numChildren == 0) then 
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

		btn1.x,btn2.x = w/3,2*w/3
		btn1.y,btn2.y = h/8,h/8
		btn3.x,btn4.x,btn5.x,btn6.x = w/5,2*w/5,3*w/5,4*w/5
		btn3.y,btn4.y,btn5.y,btn6.y = h/4,h/4,h/4,h/4
		btn7.x,btn8.x,btn9.x = w/4,w/2,3*w/4
		btn7.y,btn8.y,btn9.y = 3*h/8,3*h/8,3*h/8
		btn10.x,btn10.y = w/4,h/2
		btn11.x,btn11.y = w/2,h/2
		btn12.x,btn12.y = 3*w/4,h/2
		btn13.x,btn14.x,btn15.x = w/4,w/2,3*w/4
		btn13.y,btn14.y,btn15.y = 5*h/8,5*h/8,5*h/8
	
		btn1:setFillColor(255,0,0)
		btn2:setFillColor(255,0,0)
		btn3:setFillColor(0,255,0)
		btn4:setFillColor(0,255,0)
		btn5:setFillColor(0,255,0)
		btn6:setFillColor(0,255,0)
		btn7:setFillColor(0,0,255)
		btn8:setFillColor(0,0,255)
		btn9:setFillColor(0,0,255)
		btn10:setFillColor(255,0,255)
		btn11:setFillColor(255,0,255)
		btn12:setFillColor(255,0,255)
		btn13:setFillColor(0,255,255)
		btn14:setFillColor(0,255,255)
		btn15:setFillColor(0,255,255)
	
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

		bindEventListeners()
	end
	return localGroup
end