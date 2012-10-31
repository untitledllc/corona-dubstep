module (...,package.seeall)

userActionList = {}
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

function saveUserActList()
    local path = system.pathForFile( "test.json", system.DocumentsDirectory )

    local results, reason = os.remove( path )
 
	if results then
	   print( "file removed" )
	else
	   print( "file does not exist", reason )
	end

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
    		actType = tostring(val["actType"]), volume = tostring(val["volume"]), id = tostring(val["id"]), loops = tostring(val["loops"]), activeChannels = tmpActiveChannels}

    end
    local jsonUserActList = gl.jsonModule.encode(tempActionsTable)
    f:write(jsonUserActList)
    f:close()
end

function startRecording()
	currentSceneAppearTime = layout.getLayoutAppearTime()
	gl.nextSceneAppearTime = currentSceneAppearTime + gl.sceneLength
	
	gl.sceneNumber.isVisible = true
	
	gl.currentSceneAppearTime = currentSceneAppearTime
	
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

	--[[
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

	]]--
	gl.timerTxt.isVisible = true
	--gl.timerTxtShadow.isVisible = true
	gl.nextSceneTimerTxt.isVisible = true
	--gl.nextSceneTimerTxtShadow.isVisible = true

	gl.toEndTimerFunc = function ()
		local toFinalTime = math.round((gl.fullRecordLength - system.getTimer() + layout.getLayoutAppearTime() - gl.deltaTime)/1000 )
		if toFinalTime < gl.toFinalTime then
			gl.toFinalTime = toFinalTime
			local minutes = math.floor(toFinalTime / 60)
			if minutes < 10 then
				minutes = "0"..tostring(minutes)
			end
			local secondes = toFinalTime % 60
			if secondes < 10 then
				secondes = "0"..tostring(secondes)
			end
			gl.timerTxt.text = "("..minutes..":"..secondes..")"
			gl.timerTxt:setReferencePoint(display.TopLeftReferencePoint)
			gl.timerTxt.x, gl.timerTxt.y = 230*gl.coefW + display.screenOriginX,262*gl.coefH + display.screenOriginY

			--gl.timerTxtShadow.text = gl.timerTxt.text
			--gl.timerTxtShadow:setReferencePoint(display.TopLeftReferencePoint)
			--gl.timerTxtShadow.x, gl.timerTxtShadow.y = 179,10
		end
	end

	gl.toNextSceneTimerFunc = function ()
		gl.currentSceneLocalTime = system.getTimer() - gl.currentSceneAppearTime
		local toNextSceneTime = math.round((gl.nextSceneAppearTime - gl.currentSceneLocalTime - layout.getLayoutAppearTime())/1000)
		if toNextSceneTime < gl.toNextSceneTime then
			gl.toNextSceneTime = toNextSceneTime
			--print(gl.nextSceneAppearTime)
			local minutes = math.floor(toNextSceneTime / 60)
			if minutes < 10 then
				minutes = "0"..tostring(minutes)
			end
			local secondes = toNextSceneTime % 60
			if secondes < 10 then
				secondes = "0"..tostring(secondes)
			end
			gl.nextSceneTimerTxt.text = "Next scene: "..minutes..":"..secondes
			gl.nextSceneTimerTxt:setReferencePoint(display.TopLeftReferencePoint)
			gl.nextSceneTimerTxt.x, gl.nextSceneTimerTxt.y = 171*gl.coefW + display.screenOriginX,300*gl.coefH + display.screenOriginY

			--gl.nextSceneTimerTxtShadow.text = gl.nextSceneTimerTxt.text
			--gl.nextSceneTimerTxtShadow:setReferencePoint(display.TopLeftReferencePoint)
			--gl.nextSceneTimerTxtShadow.x, gl.nextSceneTimerTxtShadow.y = 170,301
		end
	end
	
	Runtime:addEventListener("enterFrame", gl.toEndTimerFunc)
	
	Runtime:addEventListener("enterFrame", gl.toNextSceneTimerFunc)

end

--[[ 
action = 
	{
		actionTime,	-- time elapsed since the start of record
		channel,	-- Channel number of action
		actType,	-- "chVolume/pause/resume/start/stop/startGlitch/stopGlitch/endRecord"
		volume,		-- The value of the volume on the channel
		id,		-- Id of the sound
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