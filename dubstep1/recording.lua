module (...,package.seeall)

local userActionList = {}

local recPressTime = nil
local endRecordingTime = nil

local pl = require("playing")
local gl = require("globals")
local layout = require(gl.currentLayout)

local timers = {}

local isRecSwitchedOn = false

function getTimers()
	return timers
end

function setRecState(state) 
	isRecSwitchedOn = state
end

function cancelTimers(tim)
	for idx,val in pairs(tim) do
		timer.cancel(val)
	end
end

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

local function hideBtns()
	for idx,val in pairs(gl.currentHiddenBtns) do
		gl.mainGroup[2][val].alpha = 0.5
		gl.mainGroup[2][val].isVisible = false
		audio.setVolume(0,{channel = val})
	end	
end	

function stopRecording(e)	
	
	cancelTimers(timers)
	timers = {}
		
	endRecordingTime = system.getTimer() - layout.getLayoutAppearTime()
	
	if (isRecSwitchedOn == true) then
		completeUserActList()
		saveUserActList()
		printUserActList()
	end
	
	isRecSwitchedOn = false
	
	userActionList = {}
		
	gl.repBtn.isVisible = true
	gl.timerTxt.isVisible = false
	
	audio.stop(gl.currentBasicChannel)
	audio.stop(gl.currentGoodChannel)
	audio.stop(gl.currentEvilChannel)
	
	Runtime:removeEventListener("enterFrame",updateTimer)
end

function startRecording()
	
	cancelTimers(timers)
	timers = {}
	
	recPressTime = system.getTimer() - layout.getLayoutAppearTime()
	calcSeekTimeInActiveChannels(pl.getActiveChannels())
	isRecSwitchedOn = true
			
	hideBtns()		
	
	if (gl.isRecordingTimeRestricted == true) then
		timers[1] = timer.performWithDelay(gl.fullRecordLength,stopRecording)
	end

	for idx,val in pairs(gl.currentBacks) do
		timers[#timers + 1] = timer.performWithDelay(idx*gl.fullRecordLength/(#gl.currentBacks + 2),
							function ()
								if (idx ~= 1) then
									gl.currentBacks[idx - 1].isVisible = false
								end
									gl.changeBackGround(gl.currentBacks[idx])
							end )
	end		
	
	for idx,val in pairs(gl.currentHiddenBtns) do
		timers[#timers + 1] = timer.performWithDelay(idx*gl.fullRecordLength/(#gl.currentHiddenBtns + 2),
							function()
								gl.mainGroup[2][val].isVisible = true
							end )
	end
			
	timers[#timers + 1] = timer.performWithDelay(gl.showChoiceTime,
								function ()
									gl.goodBtn.isVisible = true
									gl.evilBtn.isVisible = true
								end )
								
	local function playRandom()
		math.randomseed(math.random())
		if (math.random() > 0.5) then
			pl.playGoodMelody()
		else
			pl.playEvilMelody()
		end
	end
	
	timers[#timers + 1] = timer.performWithDelay(gl.showChoiceTime + gl.choiceShownDurationTime,
								function ()
									gl.goodBtn.isVisible = false
									gl.evilBtn.isVisible = false
									if (gl.currentBasicMelody ~= gl.currentGoodMelody
											and
										gl.currentBasicMelody ~= gl.currentEvilMelody) then
										
										playRandom()
										
									end
								end )								

			
	gl.timerTxt.isVisible = true
	Runtime:addEventListener("enterFrame",updateTimer)
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