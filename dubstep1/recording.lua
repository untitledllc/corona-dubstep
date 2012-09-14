module (...,package.seeall)

local userActionList = {}

local recPressTime = nil
local endRecordingTime = nil

local pl = require("playing")
local gl = require("globals")
local layout = require(gl.currentLayout)

timers = {}

goodEvilButtonTimers = {}

currentScene = 1

local isRecSwitchedOn = false

local playParams = {false,false,false,false,false,3,3,3,3,0}

goToScene = {}
function setScenesDirection()
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
	for idx, val in pairs(gl.currentBacks) do
		if idx > 6 then
			break
		end
		local FXs
		local musics
		if idx == 1 then
			musics = {1}
			FXs = {2}
		elseif idx == 2 then
			musics = {3, 4}
			FXs = {5}
		elseif idx == 3 then
			musics = {6, 7}
			FXs = {8, 9, 10}
		elseif idx == 4 then
			musics = {11, 12}
			FXs = {13}
		elseif idx == 5 then
			musics = {14, 15}
			FXs = {16, 17}
		end
		goToScene[idx] = function(event)
			if event.phase == "ended" then
				
				currentScene = idx

				cancelTimers(timers)
				timers = {}

				if idx == 6 then
					for i = 1, 6 do
						gl.localGroup[19]:removeEventListener("touch", goToScene[i])
						gl.localGroup[18]:removeEventListener("touch", goToScene[i])
					end
					stopRecording()
					return false
				end

				if (gl.isRecordingTimeRestricted == true) then
					timers[1] = timer.performWithDelay((#gl.currentBacks - currentScene) * gl.fullRecordLength/(#gl.currentBacks - 1),stopRecording)
				end

				if currentScene ~= 5 then
					timers[#timers + 1] = timer.performWithDelay(gl.fullRecordLength/(#gl.currentBacks - 1),
						function ()
							gl.localGroup[19]:dispatchEvent({name = "touch", phase = "ended"})
						end
					)
				end

				for i,v in pairs(findNext5HiddenBtns()) do
					gl.mainGroup[2][v].isVisible = true
					gl.mainGroup[2][v].txt.isVisible = true
				end

				for i = 1, 17 do
					gl.localGroup[i].isVisible = false
					gl.localGroup[i].txt.isVisible = false
				end
				
				local j = 1
				while (j <= gl.currentNumSamples) do
					audio.stop(j)
					j = j + 1
				end

				for i, v in pairs(musics) do
					print("here")
					audio.play(gl.sampleKit[v][1],{channel = v,loops = -1})
					audio.setVolume(0,{channel = v})
				end
				print(musics[1])
				pl.playMelody(gl.localGroup,musics[1],layout.trackCounters)

				for i, v in pairs(FXs) do
					gl.localGroup[v].isVisible = true
					gl.localGroup[v].txt.isVisible = true
				end

				for i, v in pairs(musics) do
					gl.localGroup[v].isVisible = true
					gl.localGroup[v].txt.isVisible = true
				end

				gl.sceneNumber.text = "Next scene: "..tostring(currentScene + 1)
				gl.currentSceneAppearTime = system.getTimer()

				for i, v in pairs(gl.currentBacks) do
					v.isVisible = false
				end

				gl.changeBackGround(gl.currentBacks[currentScene])

				for i = 1, 6 do
					gl.localGroup[19]:removeEventListener("touch", goToScene[i])
					gl.localGroup[18]:removeEventListener("touch", goToScene[i])
				end

				timer.performWithDelay(200, function() gl.localGroup[19]:addEventListener("touch", goToScene[currentScene + 1]) end)
				
				if currentScene ~= 1 then
					timer.performWithDelay(200, function () gl.localGroup[18]:addEventListener("touch", goToScene[currentScene - 1]) end)
					
				end
			end
		end
	end
end




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
	for i = 1, 6 do
		gl.localGroup[19]:removeEventListener("touch", goToScene[i])
		gl.localGroup[18]:removeEventListener("touch", goToScene[i])
	end

	gl.localGroup[14].isVisible = false
	gl.localGroup[15].isVisible = false
	gl.localGroup[16].isVisible = false
	gl.localGroup[17].isVisible = false

	gl.localGroup[14].txt.isVisible = false
	gl.localGroup[15].txt.isVisible = false
	gl.localGroup[16].txt.isVisible = false
	gl.localGroup[17].txt.isVisible = false

	pl.shutUpFX(gl.localGroup,true,gl.currentNumSamples,numFX,numVoices)
	pl.shutUpMelodies(gl.localGroup,true,pl.getPartSumms(),layout.trackCounters)
	
	cancelTimers(timers)
	cancelTimers(goodEvilButtonTimers)
	goodEvilButtonTimers = {}
	timers = {}
		
	gl.currentBacks[#gl.currentBacks - 1].isVisible = false
	gl.changeBackGround(gl.currentBacks[#gl.currentBacks])								
	gl.currentSceneAppearTime = system.getTimer()

	endRecordingTime = system.getTimer() - layout.getLayoutAppearTime()

	recording.addAction(endRecordingTime - recPressTime,
    							1,0,0,4,-1)

	recording.addAction(endRecordingTime - recPressTime,
    							gl.currentGoodChannel,0,0,4,-1)

	recording.addAction(endRecordingTime - recPressTime,
    							gl.currentEvilChannel,0,0,4,-1)
	
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

	audio.stop(1)
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
			
	gl.nextSceneAppearTime = gl.fullRecordLength/(#gl.currentBacks - 1)
	
	gl.currentSceneAppearTime = system.getTimer()
	
	hideBtns()		
	
	if (gl.isRecordingTimeRestricted == true) then
		timers[1] = timer.performWithDelay(gl.fullRecordLength,stopRecording)
	end

	
	

	idxs = {}
	for idx,val in pairs(gl.currentBacks) do
			idxs[#idxs + 1] = idx + 1
			timers[#timers + 1] = timer.performWithDelay((idx)*gl.fullRecordLength/(#gl.currentBacks - 1),
								function ()
									gl.localGroup[19]:dispatchEvent({name = "touch", phase = "ended"})
									table.remove(idxs, 1)
								end )
			idx = idx - 1
		
	end		
	
	local idx = 1
	while (idx <= #gl.currentBacks + 1 - 1) do
		timers[#timers + 1] = timer.performWithDelay(idx*gl.fullRecordLength/(#gl.currentBacks - 1),
							function ()
								gl.currentSceneAppearTime = system.getTimer()
							end )
		idx = idx + 1
	end

	goodEvilButtonTimers[#timers + 1] = timer.performWithDelay(gl.showChoiceTime,
								function ()
									gl.goodBtn.isVisible = true
									gl.evilBtn.isVisible = true
									gl.goodBtn.txt.isVisible = true
									gl.evilBtn.txt.isVisible = true
								end )
								
	goodEvilButtonTimers[#timers + 1] = timer.performWithDelay(gl.showChoiceTime + gl.choiceShownDurationTime,
								function ()
									gl.goodBtn.isVisible = false
									gl.evilBtn.isVisible = false
									gl.goodBtn.txt.isVisible = false
									gl.evilBtn.txt.isVisible = false
									print("here")
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
											
										--playRandom()
										pl.playGoodMelody()
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