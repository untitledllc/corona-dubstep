module(...,package.seeall)

local layoutAppearTime = nil

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
	
	local numSamples = 17
	local numFX = 3
	local numVoices = 0
	
	local gl = require("globals")
	
	gl.currentLayout = "layout1"
	gl.currentNumSamples = numSamples
	gl.currentNumFX = numFX
	gl.currentNumVoices = numVoices
	
	local playModule = require("playing")
	local kitAddress = "sounds1/"

	layoutAppearTime = system.getTimer()

	local playParams = {false,false,false,false,false,3,3,3,3,0}

	local w = gl.w
	local h = gl.h

	gl.btns = gl.drawLayoutBtns()
	
	trackCounters = {}
	trackCounters = playModule.resetCounters(numSamples)

	local sampleKit = playModule.initSoundsFirstLayout(kitAddress,numSamples,numFX,numVoices)
	trackCounters[1] = trackCounters[1] + 1
	playModule.prepareToPlay(sampleKit,playParams,numSamples,numFX,numVoices)

	local function playSound1 (event)
    	if (event.phase == "ended") then
    		playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,1,trackCounters)
    	end
	end
	local function playSound2 (event)
 	   if (event.phase == "ended") then
 	   		playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,2)
   	   end
	end
	local function playSound3 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,3,trackCounters)
    	end
	end
	local function playSound4 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,4,trackCounters)
   	 	end
	end
	local function playSound5 (event)
    	if (event.phase == "ended") then
			playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,5)
    	end
	end
	local function playSound6 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,6,trackCounters)
    	end
	end
	local function playSound7 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,7,trackCounters)
    	end
	end
	local function playSound8 (event)
    	if (event.phase == "ended") then
			playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,8)
    	end
	end
	local function playSound9 (event)
    	if (event.phase == "ended") then
			playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,9)
    	end
	end
	local function playSound10 (event)
    	if (event.phase == "ended") then
			playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,10)
   		end
	end
	local function playSound11 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,11,trackCounters)
   		end
	end
	local function playSound12 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,12,trackCounters)
    	end
	end
	local function playSound13 (event)
    	if (event.phase == "ended") then
			playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,13)
    	end
	end
	local function playSound14 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,14,trackCounters)
    	end
	end
	local function playSound15 (event)
    	if (event.phase == "ended") then
			playModule.shutUpMelodies(localGroup,playParams[2],playModule.getPartSumms(),trackCounters)
			playModule.playMelody(localGroup,15,trackCounters)
    	end
	end
	local function playSound16 (event)
    	if (event.phase == "ended") then
			playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,16)
    	end
	end
	local function playSound17 (event)
    	if (event.phase == "ended") then
			playModule.shutUpFX(localGroup,playParams[4],numSamples,numFX,numVoices)
			playModule.playFX(localGroup,sampleKit,17)
    	end
	end

	local function bindEventListeners()
		local handlerTable = {playSound1,playSound2,playSound3,
				playSound4,playSound5,playSound6,
				playSound7,playSound8,playSound9,
				playSound10,playSound11,playSound12,
				playSound13,playSound14,playSound15,
				playSound16,playSound17}
		local idx = 1
		while(idx <= #handlerTable) do
			localGroup[idx]:addEventListener("touch",handlerTable[idx])
			idx = idx + 1
		end
	end
	
	for idx,val in pairs(gl.btns) do
		gl.btns[idx].alpha = 0.5
	end
	
	txt1 = display.newText("ritm-1",0,0,native.systemFont,14)	
	txt2 = display.newText("sintezator-1",0,0,native.systemFont,14)	
	txt3 = display.newText("ritm-2",0,0,native.systemFont,14)	
	txt4 = display.newText("sintezator-1",0,0,native.systemFont,14)	
	txt5 = display.newText("bass-2",0,0,native.systemFont,14)	
	txt6 = display.newText("ritm-2",0,0,native.systemFont,14)	
	txt7 = display.newText("sintezator-1",0,0,native.systemFont,14)	
	txt8 = display.newText("bass-2",0,0,native.systemFont,14)	
	txt9 = display.newText("tom-tom",0,0,native.systemFont,14)	
	txt10 = display.newText("space-fx",0,0,native.systemFont,14)	
	txt11 = display.newText("ritm-3",0,0,native.systemFont,14)	
	txt12 = display.newText("tom-tom",0,0,native.systemFont,14)	
	txt13 = display.newText("gun-fx",0,0,native.systemFont,14)	
	txt14 = display.newText("ritm-3",0,0,native.systemFont,14)	
	txt15 = display.newText("tom-tom",0,0,native.systemFont,14)
	txt16 = display.newText("bass-3",0,0,native.systemFont,14)	
	txt17 = display.newText("bass-fx",0,0,native.systemFont,14)	
	 
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
	btn16.x,btn17.x = w/4,w/2
	btn16.y,btn17.y = 6*h/8,6*h/8
	
	btn1.x,btn2.x,btn3.x = w/4,w/2,3*w/4
	btn1.y,btn2.y,btn3.y = h/8,h/8,h/8
	btn4.x,btn5.x,btn6.x = w/4,w/2,3*w/4
	btn4.y,btn5.y,btn6.y = h/4,h/4,h/4
	btn7.x,btn8.x,btn9.x = w/4,w/2,3*w/4
	btn7.y,btn8.y,btn9.y = 3*h/8,3*h/8,3*h/8
	btn10.x,btn10.y = w/4,h/2
	btn11.x,btn11.y = w/2,h/2
	btn12.x,btn12.y = 3*w/4,h/2
	btn13.x,btn14.x,btn15.x = w/4,w/2,3*w/4
	btn13.y,btn14.y,btn15.y = 5*h/8,5*h/8,5*h/8
	btn16.x,btn17.x = w/4,w/2
	btn16.y,btn17.y = 6*h/8,6*h/8
	
	txt1.x,txt2.x,txt3.x = w/4,w/2,3*w/4
	txt1.y,txt2.y,txt3.y = h/8,h/8,h/8
	txt4.x,txt5.x,txt6.x = w/4,w/2,3*w/4
	txt4.y,txt5.y,txt6.y = h/4,h/4,h/4,h/4
	txt7.x,txt8.x,txt9.x = w/4,w/2,3*w/4
	txt7.y,txt8.y,txt9.y = 3*h/8,3*h/8,3*h/8
	txt10.x,txt10.y = w/4,h/2
	txt11.x,txt11.y = w/2,h/2
	txt12.x,txt12.y = 3*w/4,h/2
	txt13.x,txt14.x,txt15.x = w/4,w/2,3*w/4
	txt13.y,txt14.y,txt15.y = 5*h/8,5*h/8,5*h/8
	txt16.x,txt17.x = w/4,w/2
	txt16.y,txt17.y = 6*h/8,6*h/8
	
	btn1:setFillColor(255,0,0)
	btn2:setFillColor(255,0,0)
	btn3:setFillColor(255,0,0)
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
	btn16:setFillColor(0,255,255)
	btn17:setFillColor(0,255,255)
	
--	txt2.isVisible = false
--	txt3.isVisible = false
--	txt5.isVisible = false
--	txt6.isVisible = false	
--	txt8.isVisible = false
--	txt9.isVisible = false	
--	txt11.isVisible = false	
--	txt12.isVisible = false		
--	txt14.isVisible = false
--	txt15.isVisible = false
	
	btn1.alpha = 1
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
	
	btn1.txt = txt1
	btn2.txt = txt2
	btn3.txt = txt3
	btn4.txt = txt4
	btn5.txt = txt5
	btn6.txt = txt6
	btn7.txt = txt7
	btn8.txt = txt8
	btn9.txt = txt9
	btn10.txt = txt10
	btn11.txt = txt11
	btn12.txt = txt12
	btn13.txt = txt13
	btn14.txt = txt14
	btn15.txt = txt15
	btn16.txt = txt16
	btn17.txt = txt17
	
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

	local idxOfBtn3
	for i = 1, localGroup.numChildren do
		if localGroup[i] == btn3 then
			idxOfBtn3 = i
		end
	end

	for i = idxOfBtn3, localGroup.numChildren do
		localGroup[i].isVisible = false
		localGroup[i].txt.isVisible = false
	end

	bindEventListeners()

	backs[1] = display.newImageRect("images/layout1/back1.png",gl.w,gl.h)
	backs[2] = display.newImageRect("images/layout1/back2.png",gl.w,gl.h)
	backs[3] = display.newImageRect("images/layout1/back3.png",gl.w,gl.h)
	backs[4] = display.newImageRect("images/layout1/back4.png",gl.w,gl.h)
	backs[5] = display.newImageRect("images/layout1/back5.png",gl.w,gl.h)
	backs[6] = display.newImageRect("images/layout1/back6.png",gl.w,gl.h)
	
	backs[1].x,backs[1].y = gl.w/2,gl.h/2
	backs[2].x,backs[2].y = gl.w/2,gl.h/2
	backs[3].x,backs[3].y = gl.w/2,gl.h/2
	backs[4].x,backs[4].y = gl.w/2,gl.h/2
	backs[5].x,backs[5].y = gl.w/2,gl.h/2
	backs[6].x,backs[6].y = gl.w/2,gl.h/2
	
	backs[1].isVisible = true
	backs[2].isVisible = false
	backs[3].isVisible = false
	backs[4].isVisible = false
	backs[5].isVisible = false
	backs[6].isVisible = false
	
	--backs[1].isVisible = true
	mainGroup:insert(1,backs[1])
	mainGroup:insert(2,localGroup)

	local function initHiddenBacks() 
		--return {2,5,8,11,14,3,6,9,12}
		return {}
	end

	gl.mainGroup = mainGroup
	gl.localGroup  = localGroup 
	gl.currentBacks = backs
	gl.currentHiddenBtns = initHiddenBacks()
	gl.sampleKit = sampleKit
	
	require("recording").startRecording()
	playModule.playBasicMelody()
	
	gl.loading.isVisible = false
	
	return mainGroup
end