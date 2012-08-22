module (...,package.seeall)

local userActionList = {}
recPressCounter = 0

local recPressTime = nil
local endRecordingTime = nil
prevRecStartTime = 0

local pl = require("playing")
local gl = require("globals")
local layout = require(gl.currentLayout)

local timer1 = nil
local timer2 = nil
local timer3 = nil
local timer4 = nil
local timer5 = nil
local timer6 = nil
local timer7 = nil

local isRecSwitchedOn = false

local function printUserActList()
	print("Start rec =",recPressTime)

	for idx,val in pairs(userActionList) do
		print("actionTime = ",val["actionTime"])
		print("Channel = ",val["channel"])
		print("actionType = ",val["actType"])
		print("Volume = ",val["volume"])
		print("Category = ",val["category"])
		print("channelActiveTime = ",val["channelActiveTime"])
		print("\n")
	end
	print("-----------------------------------------------")
end

local function completeUserActList()
	local idx = 1
	addAction(endRecordingTime - recPressTime,-1,0,0,-1,0)
	idx = idx + 1
end

local function calcSeekTimeInActiveChannels(activeChannels)
	for idx,val in pairs(activeChannels) do
		if (val[1] ~= -1) then
			addAction(0,val.channel,1,val.volume,val.category,recPressTime - val.startTime)
		end
	end
end

local function saveUserActList()
    local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"w")
    if (not f) then
        print("not ok")
    end
    
    f:write(tostring(recPressTime).." ")
    
    for idx,val in pairs(userActionList) do
    	f:write(tostring(val["actionTime"]).." ")
		f:write(tostring(val["channel"]).." ")
		f:write(tostring(val["actType"]).." ")
		f:write(tostring(val["volume"]).." ")
		f:write(tostring(val["category"]).." ")
		f:write(tostring(val["channelActiveTime"]).." ")
    end
    f:close()
end

local function updateTimer(event)
	if (isRecSwitchedOn == true) then
		gl.timerTxt.text = tostring(math.round( gl.fullRecordLength - 
									(system.getTimer() - 
										layout.getLayoutAppearTime() - 
											recPressTime) )/1000)
	end
end

local function change5_1(event)
	gl.currentBacks[5].isVisible = false
	gl.changeBackGround(gl.currentBacks[1])
	
	timer6 = timer.performWithDelay(gl.changeLayoutTime,change1_2)
end

local function change4_5(event)
	gl.currentBacks[4].isVisible = false
	
	gl.mainGroup[2][12].isVisible = false

	audio.setVolume(0,{channel = 12})
	
	addAction(system.getTimer() - layout.getLayoutAppearTime() - recPressTime,
    		12,0,audio.getVolume({channel = 12}),4,system.getTimer() - layout.getLayoutAppearTime())
	
	gl.changeBackGround(gl.currentBacks[5])
	timer5 = timer.performWithDelay(gl.changeLayoutTime,change5_1)
end

local function change3_4(event)
	gl.currentBacks[3].isVisible = false
	gl.mainGroup[2][9].isVisible = false
	gl.mainGroup[2][12].isVisible = true

	audio.setVolume(0,{channel = 9})
	
	addAction(system.getTimer() - layout.getLayoutAppearTime() - recPressTime,
    		9,0,audio.getVolume({channel = 9}),3,system.getTimer() - layout.getLayoutAppearTime())
	
	gl.changeBackGround(gl.currentBacks[4])
	timer4 = timer.performWithDelay(gl.changeLayoutTime,change4_5)
end

local function change2_3(event)
	gl.currentBacks[2].isVisible = false
	gl.mainGroup[2][3].isVisible = false
	gl.mainGroup[2][9].isVisible = true
	
	audio.setVolume(0,{channel = 3})
	
	addAction(system.getTimer() - layout.getLayoutAppearTime() - recPressTime,
    			3,0,audio.getVolume({channel = 3}),2,system.getTimer() - layout.getLayoutAppearTime())

	gl.changeBackGround(gl.currentBacks[3])
	timer3 = timer.performWithDelay(gl.changeLayoutTime,change3_4)
end

local function change1_2(event)
	gl.currentBacks[1].isVisible = false
	gl.changeBackGround(gl.currentBacks[2])

	gl.mainGroup[2][3].isVisible = true
	
	timer2 = timer.performWithDelay(gl.changeLayoutTime,change2_3)
end

function startRecording(event)
	local function stopRecording(e)			
		if (timer1 ~= nil) then
			timer.cancel(timer1)
		end
		if (timer2 ~= nil) then
			timer.cancel(timer2)
		end
		if (timer3 ~= nil) then
			timer.cancel(timer3)
		end
		if (timer4 ~= nil) then
			timer.cancel(timer4)
		end
		if (timer5 ~= nil) then
			timer.cancel(timer5)
		end
		if (timer6 ~= nil) then
			timer.cancel(timer6)
		end
		
		gl.mainGroup[2][3].alpha = 0.5
		gl.mainGroup[2][9].alpha = 0.5
		gl.mainGroup[2][12].alpha = 0.5
		
		gl.mainGroup[2][3].isVisible = true
		gl.mainGroup[2][9].isVisible = true
		gl.mainGroup[2][12].isVisible = true
		
		endRecordingTime = system.getTimer() - layout.getLayoutAppearTime()
		completeUserActList()
		saveUserActList()
		isRecSwitchedOn = false
		event.target.alpha = 0.5
		printUserActList()
		userActionList = {}
	end
	local function stopRestrictRecording(e)
		if (isRecSwitchedOn == true) then
			stopRecording(nil)
			recPressCounter = recPressCounter + 1
		end
	end
	
	if (event.phase == "ended") then
		if (recPressCounter % 2 == 0) then
			recPressTime = system.getTimer() - layout.getLayoutAppearTime()
			calcSeekTimeInActiveChannels(pl.getActiveChannels())
			event.target.alpha = 1
			isRecSwitchedOn = true
			
			gl.mainGroup[2][3].alpha = 0.5
			gl.mainGroup[2][9].alpha = 0.5
			gl.mainGroup[2][12].alpha = 0.5
			
			gl.mainGroup[2][3].isVisible = false
			gl.mainGroup[2][9].isVisible = false
			gl.mainGroup[2][12].isVisible = false
			   
			audio.setVolume(0,{channel = 3})
			audio.setVolume(0,{channel = 9})
			audio.setVolume(0,{channel = 12})
			
			timer1 = timer.performWithDelay(gl.changeLayoutTime,change1_2)
			if (gl.isRecordingTimeRestricted == true) then
				timer7 = timer.performWithDelay(gl.fullRecordLength,stopRestrictRecording)
			end
			
			gl.timerTxt.isVisible = true
			Runtime:addEventListener("enterFrame",updateTimer)
		else
			stopRecording(nil)
			
			gl.timerTxt.isVisible = false
			Runtime:removeEventListener("enterFrame",updateTimer)
		end
		recPressCounter = recPressCounter + 1
	end
end

function addAction(time,index,actType,vol,category,chActTime)
    local action = {}
	action["actionTime"] = time
	action["channel"] = index
	action["actType"] = actType
	action["volume"] = vol
	action["category"] = category
	action["channelActiveTime"] = chActTime
	userActionList[#userActionList + 1] = action
end

function getRecBeginTime()
	return recPressTime
end

function isRecStarted()
	return isRecSwitchedOn
end
