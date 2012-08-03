module(...,package.seeall)

function new()
	local localGroup = display.newGroup()
		
	local gl = require("globals")	
	
	local w = gl.w
	local h = gl.h
	gl.btns = gl.drawLayoutBtns()
	local numSamples = 9
	local numVoices = 2
	
	local kitAddress = "kit2/"

	local trackCounters = {}
	trackCounters = gl.resetCounters(numSamples)

	local sampleKit = gl.initSounds(kitAddress,numSamples,numVoices)

	local function playSound1 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,1,false,numSamples,numVoices)
   	 	end
	end
	local function playSound2 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,2,false,numSamples,numVoices)
    	end
	end
	local function playSound3 (event)
    	if (event.phase == "ended") then		
			gl.play(localGroup,sampleKit,trackCounters,3,false,numSamples,numVoices)

    	end
	end
	local function playSound4 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,4,false,numSamples,numVoices)
    	end
	end
	local function playSound5 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,5,false,numSamples,numVoices)
    	end
	end
	local function playSound6 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,6,false,numSamples,numVoices)
    	end
	end
	local function playSound7 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,7,false,numSamples,numVoices)
    	end
	end
	local function playSound8 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,8,false,numSamples,numVoices)
    	end
	end
	local function playSound9 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,9,false,numSamples,numVoices)
    	end
	end
	local function playSound10 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,10,true,numSamples,numVoices)
    	end
	end
	local function playSound11 (event)
    	if (event.phase == "ended") then
			gl.play(localGroup,sampleKit,trackCounters,11,true,numSamples,numVoices)
    	end
	end
	
	local function bindEventListeners()
		local handlerTable = {playSound1,playSound2,playSound3,
				playSound4,playSound5,playSound6,playSound7,playSound8,
				playSound9,playSound10,playSound11}
		local idx = 1
		while(idx <= localGroup.numChildren) do
			localGroup[idx]:addEventListener("touch",handlerTable[idx])
			idx = idx + 1
		end
	end
	
	gl.firstTimePlayPressed = nil
	
	for idx,val in pairs(gl.btns) do
		gl.btns[idx].alpha = 0.5
	end
	
	gl.btns[2].alpha = 1
	if (localGroup.numChildren == 0) then
		btn1 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn2 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn3 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn4 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn5 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn6 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn7 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn8 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn9 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn10 = display.newRoundedRect(1,1,w/8,h/8,2)
		btn11 = display.newRoundedRect(1,1,w/8,h/8,2)

		btn1.x,btn2.x,btn3.x = w/4,w/2,3*w/4
		btn4.x,btn5.x,btn6.x = w/4,w/2,3*w/4
		btn7.x,btn8.x,btn9.x = w/4,w/2,3*w/4
		btn10.x,btn11.x = w/3,2*w/3
		
		btn1.y,btn2.y,btn3.y = h/5,h/5,h/5
		btn4.y,btn5.y,btn6.y = 2*h/5,2*h/5,2*h/5
		btn7.y,btn8.y,btn9.y = 3*h/5,3*h/5,3*h/5
		btn10.y,btn11.y = 4*h/5,4*h/5
		
		btn1:setFillColor(255,0,0)
		btn2:setFillColor(255,0,0)
		btn3:setFillColor(255,0,0)
		btn4:setFillColor(0,255,0)
		btn5:setFillColor(0,255,0)
		btn6:setFillColor(0,255,0)
		btn7:setFillColor(0,0,255)
		btn8:setFillColor(0,0,255)
		btn9:setFillColor(0,0,255)
		btn10:setFillColor(255,255,0)
		btn11:setFillColor(255,255,0)
	
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
		
		bindEventListeners()
	end
	
	return localGroup
end