module (...,package.seeall)

local userActionList = {}
local defaultVolume = 0.3

local recPressTime = nil
local endRecordingTime = nil

local pl = require("playing")
local gl = require("globals")
local layout = require("level")
--local layout = require(gl.currentLayout)

timers = {}

goodEvilButtonTimers = {}

currentScene = 1

local isRecSwitchedOn = false

local playParams = {false,false,false,false,false,3,3,3,3,0}

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

function printUserActList()
	print("Start rec =",recPressTime)

	for idx,val in pairs(userActionList) do
		print("actionTime = ",val["actionTime"])
		print("Channel = ",val["channel"])
		print("actionType = ",val["actType"])
		print("Volume = ",val["volume"])
		print("id = ",val["id"])
		print("loops = ",val["loops"])
		if val["activeChannels"] then
			print("Glitched channels = \n")
			for i, value in pairs(val["activeChannels"]) do
				print("		"..value.ch.." "..value.v)
			end
		end
		print("\n")
	end
	print("-----------------------------------------------")
end

local function completeUserActList()
	local idx = 1
	--addAction(endRecordingTime - recPressTime,-1,0,0,-1,0)
	idx = idx + 1
end

local function calcSeekTimeInActiveChannels(activeChannels)
	for idx,val in pairs(activeChannels) do
		if (val[1] ~= -1) then
			--addAction(0,val.channel,1,val.volume,val.category,recPressTime - val.startTime)
		end
	end
end

function saveUserActList()
    local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"w")
    if (not f) then
        print("not ok")
    end

	local tempActionsTable = {}
    
    for idx,val in pairs(userActionList) do
    	local tmpActiveChannels = {}
    	if val["activeChannels"] then
    		tmpActiveChannels = {}
    		for i, value in pairs(val["activeChannels"]) do

    			tmpActiveChannels[#tmpActiveChannels + 1] = {channel = value.ch, volume = value.v}
    		end
    	else
    		tmpActiveChannels = nil
    	end

    	tempActionsTable[#tempActionsTable + 1] = {actionTime = tostring(val["actionTime"]), channel = tostring(val["channel"]), 
    		actionType = tostring(val["actType"]), volume = tostring(val["volume"]), id = tostring(val["id"]), loops = tostring(val["loops"]), activeChannels = tmpActiveChannels}

    end
    local jsonUserActList = gl.jsonModule.encode(tempActionsTable)
    f:write(jsonUserActList)
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
	if gl.currentLayout == "layout1" then
		for i = 1, 6 do
			gl.localGroup[19]:removeEventListener("touch", goToScene[i])
			gl.localGroup[18]:removeEventListener("touch", goToScene[i])
		end
	else
		for i = 1, 6 do
			gl.localGroup[gl.localGroup.numChildren - 1]:removeEventListener("touch", goToScene[i])
			gl.localGroup[gl.localGroup.numChildren]:removeEventListener("touch", goToScene[i])
		end
	end

	for i = 1, gl.localGroup.numChildren, 1 do
		gl.localGroup[i].isVisible = false
		gl.localGroup[i].txt.isVisible = false
	end
	--[[
	gl.localGroup[14].isVisible = false
	gl.localGroup[15].isVisible = false
	gl.localGroup[16].isVisible = false
	gl.localGroup[17].isVisible = false

	gl.localGroup[14].txt.isVisible = false
	gl.localGroup[15].txt.isVisible = false
	gl.localGroup[16].txt.isVisible = false
	gl.localGroup[17].txt.isVisible = false
	]]--
	if gl.currentLayout == "layout1" then
		pl.shutUpFX(gl.localGroup,true,gl.currentNumSamples,numFX,numVoices)
		pl.shutUpMelodies(gl.localGroup,true,pl.getPartSumms(),layout.trackCounters)
	else
		for i = 1, #gl.lvl1Voices do
			gl.lvl1Voices[i].isVisible = false
			gl.lvl1Voices[i].txt.isVisible = false
			gl.gunFxButton.isVisible = false
			gl.gunFxButton.txt.isVisible = false
		end
	end
	
	cancelTimers(timers)
	cancelTimers(goodEvilButtonTimers)
	goodEvilButtonTimers = {}
	timers = {}
	
	gl.currentBacks[#gl.currentBacks - 1].isVisible = false
	gl.changeBackGround(gl.currentBacks[#gl.currentBacks])								
	gl.currentSceneAppearTime = system.getTimer()

	endRecordingTime = system.getTimer() - layout.getLayoutAppearTime()

	--recording.addAction(endRecordingTime - recPressTime,
   -- 							1,0,0,4,-1)

	--recording.addAction(endRecordingTime - recPressTime,
    --							gl.currentGoodChannel,0,0,4,-1)

	--recording.addAction(endRecordingTime - recPressTime,
    --							gl.currentEvilChannel,0,0,4,-1)
	
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

	audio.stop()
	--audio.stop(gl.currentGoodChannel)
	--audio.stop(gl.currentEvilChannel)
	if gl.currentLayout == "layout1" then
		audio.play(gl.sharingMelody,{channel = gl.sharingChannel,loops = -1})
		audio.setVolume(defaultVolume,{channel = gl.sharingChannel})
	else

	end

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
	
	currentSceneAppearTime = layout.getLayoutAppearTime()
	gl.nextSceneAppearTime = 0
	
	gl.sceneNumber.isVisible = false
	
	gl.nextSceneAppearTime = gl.fullRecordLength/(#gl.currentBacks - 1)
	
	gl.currentSceneAppearTime = system.getTimer()
	
	--hideBtns()
	
	if (gl.isRecordingTimeRestricted == true) then
		--timers[1] = timer.performWithDelay(gl.fullRecordLength,stopRecording)
	end
	
	local idx = 1
	--[[while (idx <= #gl.currentBacks + 1 - 1) do
		timers[#timers + 1] = timer.performWithDelay(idx*gl.fullRecordLength/(#gl.currentBacks - 1),
							function ()
								gl.currentSceneAppearTime = system.getTimer()
							end )
		idx = idx + 1
	end]]--

	goodEvilButtonTimers[#goodEvilButtonTimers + 1] = timer.performWithDelay(gl.showChoiceTime,
								function ()
									gl.goodBtn.isVisible = true
									gl.evilBtn.isVisible = true
									gl.goodBtn.txt.isVisible = true
									gl.evilBtn.txt.isVisible = true
								end )
								
	goodEvilButtonTimers[#goodEvilButtonTimers + 1] = timer.performWithDelay(gl.showChoiceTime + gl.choiceShownDurationTime,
								function ()
									print("1")
									if not gl.ifChoosen then
										print("2")
											local function playRandom()
												math.randomseed(math.random())
												if (math.random() > 0.5) then
													pl.playGoodMelody()
												else
													pl.playEvilMelody()
												end
											end
											
										playRandom()
										--pl.playGoodMelody()
									end
								end )								

	
	gl.timerTxt.isVisible = true
	gl.nextSceneTimerTxt.isVisible = true
	
	--[[Runtime:addEventListener("enterFrame",function ()
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
	]]--						
end

--[[ 
action = 
	{
		actionTime,	-- time elapsed since the start of record
		channel,	-- Channel number of action
		actType,	-- "chVolume/pause/resume/start/stop/startGlitch/stopGlitch"
		volume,		-- The value of the volume on the channel
		sound,		-- Id of the sound
		loops,		-- Number of loops for playing
	}
]]--
function addAction(time,ch,actType,vol,id, loops, activeChannels)
    local action = {}
	action["actionTime"] = time
	action["channel"] = ch
	action["actType"] = actType
	action["volume"] = vol
	action["id"] = id
	action["loops"] = loops
	if activeChannels then
		action["activeChannels"] = activeChannels
	end
	userActionList[#userActionList + 1] = action
end

function getRecBeginTime()
	return recPressTime
end

function isRecStarted()
	return isRecSwitchedOn
end