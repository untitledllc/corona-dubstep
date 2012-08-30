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
	
	gl.shareBtn.isVisible = true
	gl.shareBtn.txt.isVisible = true

	if (isRecSwitchedOn == true) then
		completeUserActList()
		saveUserActList()
		printUserActList()
	end
	
	isRecSwitchedOn = false
	
	userActionList = {}
		
	gl.repBtn.isVisible = true
	gl.repBtn.txt.isVisible = true
	
	gl.timerTxt.isVisible = false
	gl.sceneNumber.isVisible = false
	gl.nextSceneTimerTxt.isVisible = false
	
	audio.stop(gl.currentBasicChannel)
	audio.stop(gl.currentGoodChannel)
	audio.stop(gl.currentEvilChannel)
	
	Runtime:removeEventListener("enterFrame",function ()
												if (isRecSwitchedOn == true) then
													gl.timerTxt.text = "Time left: "..tostring(
														math.round((gl.fullRecordLength - 
															system.getTimer() + 
																layout.getLayoutAppearTime() + 
																	recPressTime)/1000 )
																		)
												end
											 end )
end

function startRecording()

	local function findNext5HiddenBtns()
		local result = {}
		local idx = 1
		while (idx <= 5) do
			if (gl.currentHiddenBtns[1]~= nil) then
				result[idx] = gl.currentHiddenBtns[1]
				table.remove(gl.currentHiddenBtns,1)	
			else
				table.remove(gl.currentHiddenBtns,1)
				break
			end
			idx = idx + 1
		end
		return result
	end
	
	cancelTimers(timers)
	timers = {}
	
	currentSceneAppearTime = layout.getLayoutAppearTime()
	gl.nextSceneAppearTime = 0
	
	recPressTime = system.getTimer() - layout.getLayoutAppearTime()
	calcSeekTimeInActiveChannels(pl.getActiveChannels())
	isRecSwitchedOn = true
	
	gl.sceneNumber.isVisible = true		
			
	gl.nextSceneAppearTime = gl.fullRecordLength/(#gl.currentBacks)
	
	gl.currentSceneAppearTime = system.getTimer()
	
	hideBtns()		
	
	if (gl.isRecordingTimeRestricted == true) then
		timers[1] = timer.performWithDelay(gl.fullRecordLength,stopRecording)
	end

	for idx,val in pairs(gl.currentBacks) do
		timers[#timers + 1] = timer.performWithDelay(idx*gl.fullRecordLength/(#gl.currentBacks),
							function ()
								if (idx ~= 1) then
									gl.currentBacks[idx - 1].isVisible = false
								end
								
								gl.changeBackGround(gl.currentBacks[idx])
								
								for idx,val in pairs(findNext5HiddenBtns()) do
									gl.mainGroup[2][val].isVisible = true
									gl.mainGroup[2][val].txt.isVisible = true
								end
								gl.sceneNumber.text = "Next scene: "..tostring(idx + 2)
								gl.currentSceneAppearTime = system.getTimer()
							end )
	end		
	
	local idx = 1
	while (idx <= #gl.currentBacks + 1) do
		timers[#timers + 1] = timer.performWithDelay(idx*gl.fullRecordLength/(#gl.currentBacks),
							function ()
								gl.currentSceneAppearTime = system.getTimer()
							end )
		idx = idx + 1
	end

	timers[#timers + 1] = timer.performWithDelay(gl.showChoiceTime,
								function ()
									gl.goodBtn.isVisible = true
									gl.evilBtn.isVisible = true
									gl.goodBtn.txt.isVisible = true
									gl.evilBtn.txt.isVisible = true
								end )
								
	timers[#timers + 1] = timer.performWithDelay(gl.showChoiceTime + gl.choiceShownDurationTime,
								function ()
									gl.goodBtn.isVisible = false
									gl.evilBtn.isVisible = false
									gl.goodBtn.txt.isVisible = false
									gl.evilBtn.txt.isVisible = false
									
									if (gl.currentBasicMelody ~= gl.currentGoodMelody
											and
										gl.currentBasicMelody ~= gl.currentEvilMelody) then
										
											local function playRandom()
												math.randomseed(math.random())
												if (math.random() > 0.5) then
													pl.playGoodMelody()
												else
													pl.playEvilMelody()
												end
											end
											
										playRandom()
									end
								end )								

			
	gl.timerTxt.isVisible = true
	gl.nextSceneTimerTxt.isVisible = true
	
	Runtime:addEventListener("enterFrame",function ()
												if (isRecSwitchedOn == true) then
													gl.timerTxt.text = "Time left: "..tostring(
														math.round((gl.fullRecordLength - 
															system.getTimer() + 
																layout.getLayoutAppearTime() + 
																	recPressTime)/1000 )
																		)
												end
											 end )
											 
	Runtime:addEventListener("enterFrame",function ()
										      if (isRecSwitchedOn == true) then
										      		gl.currentSceneLocalTime = system.getTimer() - 
																gl.currentSceneAppearTime
										      	    gl.nextSceneTimerTxt.text = "Scene will change in: "
										      			..tostring(math.round((gl.nextSceneAppearTime - 
										      				gl.currentSceneLocalTime)/1000))
											  end
										   end )
											
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