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
	local gl = require("globals")

	local w = gl.w
	local h = gl.h

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
	local kitAddress = "sounds2/T"
	
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
		while(idx < #handlerTable) do
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
	btn26 = display.newRoundedRect(1,1,w/20,h/2,4)	
		
--[[	txt1 = display.newText("Sound1_1",0,0,native.systemFont,14)	
	txt2 = display.newText("Sound2_1",0,0,native.systemFont,14)	
	txt3 = display.newText("Sound3_1",0,0,native.systemFont,14)	
	txt4 = display.newText("Sound4_1",0,0,native.systemFont,14)	
	txt5 = display.newText("Sound5_1",0,0,native.systemFont,14)	
	txt6 = display.newText("Sound6_1",0,0,native.systemFont,14)	
	txt7 = display.newText("Sound1_2",0,0,native.systemFont,14)	
	txt8 = display.newText("Sound2_2",0,0,native.systemFont,14)	
	txt9 = display.newText("Sound3_2",0,0,native.systemFont,14)	
	txt10 = display.newText("Sound4_2",0,0,native.systemFont,14)	
	txt11 = display.newText("Sound5_2",0,0,native.systemFont,14)	
	txt12 = display.newText("Sound1_3",0,0,native.systemFont,14)	
	txt13 = display.newText("Sound2_3",0,0,native.systemFont,14)	
	txt14 = display.newText("Sound3_3",0,0,native.systemFont,14)	
	txt15 = display.newText("Sound4_3",0,0,native.systemFont,14)	
	txt16 = display.newText("Sound1_4",0,0,native.systemFont,14)	
	txt17 = display.newText("Sound2_4",0,0,native.systemFont,14)	
	txt18 = display.newText("Sound3_4",0,0,native.systemFont,14)	
	txt19 = display.newText("Sound4_4",0,0,native.systemFont,14)	
	txt20 = display.newText("Sound5_4",0,0,native.systemFont,14)	
	txt21 = display.newText("Sound1_5",0,0,native.systemFont,14)	
	txt22 = display.newText("Sound2_5",0,0,native.systemFont,14)	
	txt23 = display.newText("Sound3_5",0,0,native.systemFont,14)	
	txt24 = display.newText("Sound4_5",0,0,native.systemFont,14)	
	txt25 = display.newText("Sound5_5",0,0,native.systemFont,14)	
	txt26 = display.newText("Glitch",0,0,native.systemFont,14)	--]]
		
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
		
	btn26.x,btn26.y = w/20,h/2	
	
--[[	txt1.x,txt2.x,txt3.x,txt4.x,txt5.x,txt6.x = w/7,2*w/7,3*w/7,4*w/7,5*w/7,6*w/7
	txt7.x,txt8.x,txt9.x,txt10.x,txt11.x = w/6,w/3,w/2,2*w/3,5*w/6
	txt12.x,txt13.x,txt14.x,txt15.x= w/5,2*w/5,3*w/5,4*w/5
	txt16.x,txt17.x,txt18.x,txt19.x,txt20.x = w/6,w/3,w/2,2*w/3,5*w/6
	txt21.x,txt22.x,txt23.x,txt24.x,txt25.x = w/6,w/3,w/2,2*w/3,5*w/6
		
	txt1.y,txt2.y,txt3.y,txt4.y,txt5.y,txt6.y = h/7,h/7,h/7,h/7,h/7,h/7
	txt7.y,txt8.y,txt9.y,txt10.y,txt11.y = 2*h/7,2*h/7,2*h/7,2*h/7,2*h/7
	txt12.y,txt13.y,txt14.y,txt15.y = 3*h/7,3*h/7,3*h/7,3*h/7
	txt16.y,txt17.y,txt18.y,txt19.y,txt20.y = 4*h/7,4*h/7,4*h/7,4*h/7,4*h/7
	txt21.y,txt22.y,txt23.y,txt24.y,txt25.y = 5*h/7,5*h/7,5*h/7,5*h/7,5*h/7
		
	txt26.x,txt26.y = w/20,h/2	--]]
		
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
	btn26:setFillColor(140,255,140)

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
	btn26.alpha = 0.5	
		
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
	localGroup:insert(btn26)		
	
--[[	localGroup:insert(txt1)
	localGroup:insert(txt2)
	localGroup:insert(txt3)
	localGroup:insert(txt4)
	localGroup:insert(txt5)
	localGroup:insert(txt6)
	localGroup:insert(txt7)
	localGroup:insert(txt8)
	localGroup:insert(txt9)
	localGroup:insert(txt10)
	localGroup:insert(txt11)	
	localGroup:insert(txt12)
	localGroup:insert(txt13)
	localGroup:insert(txt14)
	localGroup:insert(txt15)
	localGroup:insert(txt16)
	localGroup:insert(txt17)
	localGroup:insert(txt18)
	localGroup:insert(txt19)
	localGroup:insert(txt20)
	localGroup:insert(txt21)
	localGroup:insert(txt22)
	localGroup:insert(txt23)
	localGroup:insert(txt24)
	localGroup:insert(txt25)
	localGroup:insert(txt26)	--]]	
			
	bindEventListeners()	
	btn26:addEventListener("touch",playModule.playGlitch)
	
	backs[1] = display.newImageRect("images/layout1/back1.png",gl.w,gl.h)
	backs[2] = display.newImageRect("images/layout2/back2.png",gl.w,gl.h)
	backs[3] = display.newImageRect("images/layout2/back3.png",gl.w,gl.h)
	backs[4] = display.newImageRect("images/layout2/back4.png",gl.w,gl.h)
	backs[5] = display.newImageRect("images/layout2/back5.png",gl.w,gl.h)
	backs[6] = display.newImageRect("images/layout2/back6.png",gl.w,gl.h)
	
	backs[1].x,backs[1].y = gl.w/2,gl.h/2
	backs[2].x,backs[2].y = gl.w/2,gl.h/2
	backs[3].x,backs[3].y = gl.w/2,gl.h/2
	backs[4].x,backs[4].y = gl.w/2,gl.h/2
	backs[5].x,backs[5].y = gl.w/2,gl.h/2
	backs[6].x,backs[6].y = gl.w/2,gl.h/2
	
	backs[1].isVisible = false
	backs[2].isVisible = false
	backs[3].isVisible = false
	backs[4].isVisible = false
	backs[5].isVisible = false
	backs[6].isVisible = false
	
	backs[1].isVisible = true
	mainGroup:insert(1,backs[1])
	mainGroup:insert(2,localGroup)

	gl.mainGroup = mainGroup
	gl.localGroup = localGroup 
	gl.currentBacks = backs
	
	local function initHiddenBacks() 
		return {2,8,13,17,22,3,9,14,18,23,4,10,15,19,24,5,6,11,20,25}
	end
	gl.currentHiddenBtns = initHiddenBacks()
	
	require("recording").startRecording()
	
	playModule.playBasicMelody() 
	gl.loading.isVisible = false
	gl.stopRotation(gl.rotator)
	
	return mainGroup
end