module (...,package.seeall)

local userActionList = {}
local defaultVolume = 0.3

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
function setScenesDirection1()
	--[[local function findNext5HiddenBtns()
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
	end]]--
	for idx, val in pairs(gl.currentBacks) do
		if idx > 6 then
			break
		end
		local FXs
		local musics
		local toPlay
		if idx == 1 then
			musics = {1}
			FXs = {2}
			toPlay = {2}
		elseif idx == 2 then
			musics = {3, 4}
			FXs = {5}
			toPlay = {3, 4, 5}
		elseif idx == 3 then
			musics = {6, 7}
			FXs = {8, 9, 10}
			toPlay = {6, 7, 8, 9}
		elseif idx == 4 then
			musics = {11, 12}
			FXs = {13}
			toPlay = {11, 12}
		elseif idx == 5 then
			musics = {14, 15}
			FXs = {16, 17}
			toPlay = {14, 15, 16}
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

				--[[for i,v in pairs(findNext5HiddenBtns()) do
					gl.mainGroup[2][v].isVisible = true
					gl.mainGroup[2][v].txt.isVisible = true
				end]]--

				for i = 1, 17 do
					gl.localGroup[i].isVisible = false
					gl.localGroup[i].txt.isVisible = false
				end
				
				local j = 1
				while (j <= gl.currentNumSamples) do
					audio.stop(j)
					audio.rewind({channel = j})

					layout.trackCounters[j] = 0
        			audio.setVolume(0,{channel = j})
        			gl.localGroup[j].alpha = 0.5

					j = j + 1
				end

				for i, v in pairs(musics) do
					audio.play(gl.sampleKit[v][1],{channel = v,loops = -1})
					audio.setVolume(0,{channel = v})
				end
				
				--if idx == 1 then
				for i, v in pairs(toPlay) do
					if gl.bin_search(musics, "right", v) ~= -1 then
						pl.playMelody(gl.localGroup,v,layout.trackCounters)
					else
						pl.playFX(gl.localGroup,gl.sampleKit,v)
					end

				end
				--else

				--end


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


function setScenesDirection2()
	for idx, val in pairs(gl.currentBacks) do
		if idx > 6 then
			break
		end
		--[[local FXs
		local musics
		local toPlay
		if idx == 1 then
			musics = {1}
			FXs = {2}
			toPlay = {2}
		elseif idx == 2 then
			musics = {3, 4}
			FXs = {5}
			toPlay = {3, 4, 5}
		elseif idx == 3 then
			musics = {6, 7}
			FXs = {8, 9, 10}
			toPlay = {6, 7, 8, 9}
		elseif idx == 4 then
			musics = {11, 12}
			FXs = {13}
			toPlay = {11, 12}
		elseif idx == 5 then
			musics = {14, 15}
			FXs = {16, 17}
			toPlay = {14, 15, 16}
		end]]--
		goToScene[idx] = function(event)
			if event.phase == "ended" then
				currentScene = idx
				cancelTimers(timers)
				timers = {}

				if idx == 6 then
					for i = 1, 6 do
						gl.localGroup[gl.localGroup.numChildren - 1]:removeEventListener("touch", goToScene[i])
						gl.localGroup[gl.localGroup.numChildren]:removeEventListener("touch", goToScene[i])
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
							gl.localGroup[gl.localGroup.numChildren]:dispatchEvent({name = "touch", phase = "ended"})
						end
					)
				end

				--[[for i,v in pairs(findNext5HiddenBtns()) do
					gl.mainGroup[2][v].isVisible = true
					gl.mainGroup[2][v].txt.isVisible = true
				end]]--

				--[[for i = 1, 17 do
					gl.localGroup[i].isVisible = false
					gl.localGroup[i].txt.isVisible = false
				end]]--
				
				local j = 1
				--[[while (j <= gl.currentNumSamples) do
					audio.stop(j)
					audio.rewind({channel = j})

					layout.trackCounters[j] = 0
        			audio.setVolume(0,{channel = j})
        			gl.localGroup[j].alpha = 0.5

					j = j + 1
				end]]--

				if currentScene == 2 then
					audio.play(gl.sampleKit[6][1],{channel = 6,loops = -1})
					audio.setVolume(0,{channel = 6})
					recording.addAction(0,6,1,0,2,0)

					audio.play(gl.sampleKit[9][1],{channel = 9,loops = -1})
					audio.setVolume(0,{channel = 9})
					recording.addAction(0,9,1,0,2,0)

					audio.play(gl.sampleKit[10][1],{channel = 10,loops = -1})
					audio.setVolume(0,{channel = 10})
					recording.addAction(0,10,1,0,2,0)

					audio.play(gl.currentBasicMelody1,{channel = gl.currentBasicChannel1,loops = -1})
					audio.setVolume(defaultVolume,{channel = gl.currentBasicChannel1})
					recording.addAction(0,currentBasicChannel1,1,defaultVolume,2,0)
					gl.localGroup[gl.currentBasicChannel1].alpha = 1
					layout.trackCounters[gl.currentBasicChannel1] = 1

					gl.localGroup[6].isVisible = true
					gl.localGroup[9].isVisible = true
					gl.localGroup[10].isVisible = true
					gl.localGroup[gl.currentBasicChannel1].isVisible = true

					gl.localGroup[6].txt.isVisible = true
					gl.localGroup[9].txt.isVisible = true
					gl.localGroup[10].txt.isVisible = true
					gl.localGroup[gl.currentBasicChannel1].txt.isVisible = true
				end

				if currentScene == 3 then
					audio.play(gl.sampleKit[3][1],{channel = 3,loops = -1})
					audio.setVolume(0,{channel = 3})
					recording.addAction(0,3,1,0,2,0)

					audio.play(gl.sampleKit[4][1],{channel = 4,loops = -1})
					audio.setVolume(defaultVolume,{channel = 4})
					recording.addAction(0,4,1,defaultVolume,2,0)
					layout.trackCounters[4] = 1
					gl.localGroup[4].alpha = 1

					audio.play(gl.sampleKit[5][1],{channel = 5,loops = -1})
					audio.setVolume(0,{channel = 5})
					recording.addAction(0,5,1,0,2,0)

					audio.play(gl.sampleKit[11][1],{channel = 11,loops = -1})
					audio.setVolume(0,{channel = 11})
					recording.addAction(0,11,1,0,2,0)

					gl.localGroup[3].isVisible = true
					gl.localGroup[4].isVisible = true
					gl.localGroup[5].isVisible = true
					gl.localGroup[11].isVisible = true

					gl.localGroup[3].txt.isVisible = true
					gl.localGroup[4].txt.isVisible = true
					gl.localGroup[5].txt.isVisible = true
					gl.localGroup[11].txt.isVisible = true
				end

				gl.sceneNumber.text = "Next scene: "..tostring(currentScene + 1)
				gl.currentSceneAppearTime = system.getTimer()

				for i, v in pairs(gl.currentBacks) do
					v.isVisible = false
				end

				gl.changeBackGround(gl.currentBacks[currentScene])

				for i = 1, 6 do
					gl.localGroup[gl.localGroup.numChildren - 1]:removeEventListener("touch", goToScene[i])
					gl.localGroup[gl.localGroup.numChildren]:removeEventListener("touch", goToScene[i])
				end

				timer.performWithDelay(200, function() gl.localGroup[gl.localGroup.numChildren]:addEventListener("touch", goToScene[currentScene + 1]) end)
				
				if currentScene ~= 1 then
					timer.performWithDelay(200, function () gl.localGroup[gl.localGroup.numChildren - 1]:addEventListener("touch", goToScene[currentScene - 1]) end)
				end

				if currentScene == 5 then
					audio.setVolume(0,{channel = 1})
					recording.addAction(0,1,1,0,2,0)
					gl.localGroup[1].alpha = 0.5
					layout.trackCounters[1] = 2
					gl.localGroup[1].isVisible = false
					gl.localGroup[1].txt.isVisible = false

					audio.setVolume(0,{channel = 4})
					recording.addAction(0,4,1,0,2,0)
					gl.localGroup[4].alpha = 0.5
					layout.trackCounters[4] = 2
					gl.localGroup[4].isVisible = false
					gl.localGroup[4].txt.isVisible = false

					audio.setVolume(0,{channel = 10})
					recording.addAction(0,10,1,0,2,0)
					gl.localGroup[10].alpha = 0.5
					layout.trackCounters[10] = 2
					gl.localGroup[10].isVisible = false
					gl.localGroup[10].txt.isVisible = false

					audio.setVolume(0,{channel = 9})
					recording.addAction(0,9,1,0,2,0)
					gl.localGroup[9].alpha = 0.5
					layout.trackCounters[9] = 2
					gl.localGroup[9].isVisible = false
					gl.localGroup[9].txt.isVisible = false
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
	
	--hideBtns()
	
	if (gl.isRecordingTimeRestricted == true) then
		timers[1] = timer.performWithDelay(gl.fullRecordLength,stopRecording)
	end

	idxs = {}
	for idx,val in pairs(gl.currentBacks) do
			idxs[#idxs + 1] = idx + 1
			timers[#timers + 1] = timer.performWithDelay((idx)*gl.fullRecordLength/(#gl.currentBacks - 1),
								function ()
									gl.localGroup[gl.localGroup.numChildren]:dispatchEvent({name = "touch", phase = "ended"})
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

	goodEvilButtonTimers[#goodEvilButtonTimers + 1] = timer.performWithDelay(gl.showChoiceTime,
								function ()
									gl.goodBtn.isVisible = true
									gl.evilBtn.isVisible = true
									gl.goodBtn.txt.isVisible = true
									gl.evilBtn.txt.isVisible = true
								end )
								
	goodEvilButtonTimers[#goodEvilButtonTimers + 1] = timer.performWithDelay(gl.showChoiceTime + gl.choiceShownDurationTime,
								function ()
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