module (...,package.seeall)
local userActionList = {}

function new()
	local gl = require("globals")
	audio.stop()
	audio.rewind()
	local w = gl.w
	local h = gl.h
	
	local localGroup = display.newGroup()
	
	local playBtn = display.newRoundedRect(1,1,w/3,h/12,12)
	local stopBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	local playLine = display.newRect(1,1,w-10,10)
	local curPlayPos = display.newRect(1,1,15,20)
	local exitBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	local txtExit = display.newText("Exit", 0, 0, native.systemFont, 24)
	local txtPlay = display.newText("Play", 0, 0, native.systemFont, 24)
	local txtStop= display.newText("Stop", 0, 0, native.systemFont, 24)
	
	local playPressCounter = 0
	local relEndTrackTime = 1
	local relPlayTime = 2
	local playerAppearTime = nil
	
	local actCounter = 1
	local isPaused = false
	
	local scrollTransition = nil

	local actionSize = 6

	local pl = require("playing")
	local volPanel = require("volumeRegulator")

	local ptSumms = pl.getPartSumms()
	
	local toSeekAtBeginTime = nil

	local deltaTSumm = 0
	local toChangeGlitchState = gl.glitchShutUpTime
	local glitchState = 1

	local function openUserActList()
		local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
  	  	local f = io.open(path,"r")
    
   		if (not f) then
   	 		local errorTxt = display.newText("No records found", 0, 0, native.systemFont, 32)
    		errorTxt.x,errorTxt.y = w/2,h/2
    		return
   		end
    
    	local jsonUserActList = f:read("*a")
  		f:close()

    	jsonUserActList = gl.jsonModule.decode(jsonUserActList)
    	-- Пробегаем по списку всех действий
    	for idx, act in pairs(jsonUserActList) do
    		local action = {}
    		-- пробегаем по всем полям каждого действия
    		for fieldName, field in pairs(act) do
    			if fieldName == "activeChannels" then
    				-- пробегаем по списку каналов глитча, если он(список) есть
    				action[fieldName] = {}
    				for chIdx, ch in pairs(field) do
    					table.insert(action[fieldName], {["ch"] = ch.channel, ["v"] = ch.volume})
    				end
    			else
    				action[fieldName] = field
    			end
    		end
    		table.insert(userActionList, action)
    	end
    end
	
	local function prepareToReplay()
		idx = 1
		while (idx <= gl.currentNumSamples) do
			gl.mySeek(toSeekAtBeginTime,gl.currentKit[idx][1],idx,-1)
			audio.setVolume(0,{channel = idx})
			idx = idx + 1
		end
	end
	
	local function findSeekSamplesTime()
		local idx = 1
		while (userActionList[idx].actionTime == 0) do
			if (userActionList[idx].category <= 3) then
				return userActionList[idx].channelActiveTime
			end
			idx = idx + 1
		end
		return nil
	end
	
	local function makePreRecordActions()
		local idx = 1
		local toSeekSampleTime = findSeekSamplesTime()
		while (userActionList[idx].actionTime == 0) do
			if (userActionList[idx].category <= 3) then
				print("channel is ",userActionList[idx].channel)
				gl.mySeek(toSeekSampleTime,
					gl.currentKit[userActionList[idx].channel][1],
								userActionList[idx].channel,-1)
				audio.setVolume(userActionList[idx].volume,
						{channel = userActionList[idx].channel})
			end
			if (userActionList[idx].category > 3 and userActionList[idx].category < 6) then
				gl.mySeek(userActionList[idx].channelActiveTime,
					gl.currentKit[userActionList[idx].channel][1],
								userActionList[idx].channel,0)
			end
			if (userActionList[idx].category == 6) then
				isGlitchStarted = true
				glitchState,toChangeGlitchState = gl.seekGlitch(userActionList[idx].channelActiveTime)
			end
			idx = idx + 1
		end
	end
	
	local function stopPressed(event)
		audio.stop()
		if (scrollTransition) then
			transition.cancel(scrollTransition)
			scrollTransition = nil
		end

		curPlayPos.x = 10
		userActionList = {}
		relPlayTime = 1000000
		relEndTrackTime = 1
		txtPlay.text = "Play"
		playPressCounter = 0
		currentMeasure = 0
		prevMeasure = 0
		
		if (scrollTransition) then
			transition.cancel(scrollTransition)
			scrollTransition = nil
		end
	end
	
	local function makeAction(index) 
	
		print("---------------")
		print("NEW ACTION")
		print("---------------")
		print(relPlayTime)
		print("---------------")
		print("actionTime=",userActionList[index].actionTime)
		print("channel=",userActionList[index].channel)
		print("actType=",userActionList[index].actType)
		print("volume=",userActionList[index].volume)
		print("category=",userActionList[index].category)
		print("channelActiveTime=",userActionList[index].channelActiveTime)

		local track = userActionList[index].channel
		local actType = userActionList[index].actType
		local actTime = userActionList[index].actionTime
		local category = userActionList[index].category
		
		if (track == -1) then 
			audio.stop()
			return true
		end
		
		if (actType == 1 and category > 3 and category < 6) then
			audio.setVolume(userActionList[index].volume,{channel = track})
			audio.play(gl.currentKit[track][1],{channel = track})
		end
		
		if (actType == 0 and category > 3 and category < 6) then
			audio.stop(track)
		end
		
		if (actType == 1 and category <=  3) then
			audio.setVolume(userActionList[index].volume,{channel = track})
		end
		
		if (actType == 0 and category <= 3) then
			audio.setVolume(0,{channel = track})
		end
		
		if (actType == 2) then
			audio.setVolume(userActionList[index].volume,{channel = track})
		end
		
		if (actType == 1 and category == 6) then
			isGlitchStarted = true
		end
		
		if (actType == 0 and category == 6) then
			isGlitchStarted = false
		end
		
		return false
	end
	
	local function play(event)
		if (relPlayTime <= relEndTrackTime and isPaused == false) then
			if (relPlayTime > userActionList[actCounter].actionTime) then
				state = makeAction(actCounter)
				if (state == true) then
					txtPlay.text = "Play"
					stopPressed(nil)
					return
				else
					actCounter = actCounter + 1		
				end
			end
			
			local deltaT
			
			currentMeasure = system.getTimer()
			if (currentMeasure > prevMeasure) then
				deltaT = currentMeasure - prevMeasure
				prevMeasure = currentMeasure
			end
			
			if (isGlitchStarted == true) then
				
				local function updateGlitchState(time,st) 
					local resTime
					local resSt
					if (time == gl.glitchShutUpTime) then
						resTime = gl.glitchPlayTime
					else
						resTime = gl.glitchShutUpTime
					end
					
					if (st == 1) then
						resSt = 0
					else
						resSt = 1
					end
					return resTime, resSt
				end
				if (deltaTSumm > toChangeGlitchState) then
					local idx = ptSumms[3] + 1
					if (glitchState == 1) then
						while (idx <= ptSumms[5]) do
							if (audio.isChannelPlaying(idx) and idx <= ptSumms[4]) then
							
								if (volPanel.scrolls[4] ~= nil) then	
        							audio.setVolume(volPanel.getVolume(volPanel.scrolls[4]),{channel = idx})  	
    							else	
    								audio.setVolume(0.5,{channel = idx})  
        						end  
        						
							end
							if (audio.isChannelPlaying(idx) and idx > ptSumms[4] and idx <= ptSumms[5]) then
								
								if (volPanel.scrolls[5] ~= nil) then	
        							audio.setVolume(volPanel.getVolume(volPanel.scrolls[5]),{channel = idx})  	
    							else	
    								audio.setVolume(0.5,{channel = idx})  
        						end  
        						
							end
							idx = idx + 1
						end
					else
						while (idx <= ptSumms[5]) do
							if (audio.isChannelPlaying(idx)) then
								audio.setVolume(0,{channel = idx})
							end
							idx = idx + 1
						end
					end
					deltaTSumm = 0
					toChangeGlitchState,glitchState = updateGlitchState(toChangeGlitchState,glitchState)
				end
				deltaTSumm = deltaTSumm + deltaT
			end
			
			relPlayTime = relPlayTime + deltaT
			--print("relativePlayTime = ",relPlayTime)
		else
			audio.stop()
			txtPlay.text = "Play"
			stopPressed(nil)
			return
		end
	end
	
	local function findStartActionForTrack(trackNumber,relativeTime)
		local idx = #userActionList
		----print(trackNumber)
		while(true) do
			if (userActionList[idx].actType == 1 
				and 
			userActionList[idx].channel == trackNumber
				and 
			userActionList[idx].actionTime <= relativeTime) then
				break
			end
			idx = idx - 1
		end
		return idx
	end

	local function findActiveTracks(relativeTime)
		local idx = 1
		local trActivity = {}
		while(userActionList[idx].actionTime < relativeTime) do
			if (userActionList[idx].channel ~= -1) then
				if (userActionList[idx].actType == 0) then
					trActivity[userActionList[idx].channel] = nil
				else
					trActivity[userActionList[idx].channel] = userActionList[idx].channel
				end
			else 
				trActivity = {}
			end
			idx = idx + 1
		end
		return trActivity,idx
	end

	local function findActiveActions(relativeTime)
		local trActivity,actCount = findActiveTracks(relativeTime)
		local actActivity = {}
		for idx,val in pairs(trActivity) do
			actActivity[#actActivity + 1] = findStartActionForTrack(val,relativeTime)
		end
		return actActivity,actCount
	end

	local function seek(activeActs,relativeTime)
		local idx = 1
		
	--	print("---------------")
	--	print("SEEK BEGIN")
	--	print(relativeTime)
	--	print("---------------")
	--	for i,val in pairs(activeActs) do
	--		print("seekTime=",toSeekAtBeginTime - userActionList[val].actionTime + relativeTime)
	--		print("actionTime=",userActionList[val].actionTime)
	--		print("channel=",userActionList[val].channel)
	--		print("actType=",userActionList[val].actType)
	--		print("volume=",userActionList[val].volume)
	--		print("category=",userActionList[val].category)
	--		print("channelActiveTime=",userActionList[val].channelActiveTime)
	--		print("---------------")
	--	end
	--	print("SEEK END")
		
		while(idx <= gl.currentNumSamples) do
			gl.mySeek(toSeekAtBeginTime + relativeTime,gl.currentKit[idx][1],idx,-1)
			if (activeActs[idx]) then	
				audio.setVolume(userActionList[activeActs[idx]].volume,
						{channel = userActionList[activeActs[idx]].channel})
			end
			idx = idx + 1
		end
		
		idx = 1
		while (idx <= #activeActs) do
			if (userActionList[activeActs[idx]].category > 3 and userActionList[activeActs[idx]].category < 6) then
				audio.play(gl.currentKit[userActionList[activeActs[idx]].channel][1],
					{channel = userActionList[activeActs[idx]].channel})
					
				audio.seek(relativeTime - userActionList[activeActs[idx]].actionTime + 
						userActionList[activeActs[idx]].channelActiveTime,
					{channel = userActionList[activeActs[idx]].channel})
					
				audio.setVolume(userActionList[activeActs[idx]].volume,
					{channel = userActionList[activeActs[idx]].channel})
			end
			
			if (userActionList[activeActs[idx]].category == 6) then
				isGlitchStarted = true
				glitchState, toChangeGlitchState = gl.seekGlitch(relativeTime
															 - userActionList[activeActs[idx]].actionTime
															 + userActionList[activeActs[idx]].channelActiveTime)
			end
			
			idx = idx + 1
		end
	end
	
	local function onSeek(event)
		if (event.phase == "ended") then
			local idx = 1
			while (idx <= gl.currentNumSamples) do
				audio.setVolume(0,{channel = idx})
				idx = idx + 1
			end
			
			idx = gl.currentNumSamples + 1
			
			while (idx <= gl.currentNumSamples + gl.currentNumFX + gl.currentNumVoices) do
				audio.stop(idx)
				idx = idx + 1
			end
			
			curPlayPos.x = event.x
			txtPlay.text = "Pause"

			if (playPressCounter == 0) then 
				openUserActList()		
				
				prevMeasure	= system.getTimer()
				relEndTrackTime = userActionList[#userActionList].actionTime + 200
				relPlayTime = 0
				makePreRecordActions()
			end
			
			playPressCounter = 1

			relPlayTime = (event.x - 10)/(w-20)*relEndTrackTime
			
			if (isPaused == true) then
				audio.resume()
				prevMeasure = system.getTimer()
				isPaused = false
			end
			
			isGlitchStarted = false
			
			activeActions,actCounter = findActiveActions(relPlayTime)

			if (scrollTransition ~= nil) then
				transition.cancel(scrollTransition)
				scrollTransition = nil
			end

			scrollTransition = transition.to(curPlayPos,
						{time=relEndTrackTime - relPlayTime,x=(w-10)})

		--	print("---------ACTIVE ACTS-----------")
			--idx = 1
			--while (idx <= #activeActions) do 
			--	print("Channel = ",userActionList[activeActions[idx]].channel)
			--	idx = idx + 1
			--end
			--print("------NO MORE ACTIVE ACTS------")
			
			seek(activeActions,relPlayTime)

			play()
		end
	end
	
	local function playPressed(event)
		if (event.phase == "ended") then
			if (playPressCounter % 2 == 0) then
				if (playPressCounter == 0) then	
					openUserActList()		
					prepareToReplay()
					prevMeasure = system.getTimer()

					relEndTrackTime = userActionList[#userActionList].actionTime + 200
					relPlayTime = 0
					
					makePreRecordActions()
				else
					audio.resume()
					isPaused = false
					prevMeasure = system.getTimer()
				end 
				
				if (scrollTransition) then
					transition.cancel(scrollTransition)
					scrollTransition = nil
				end
				print("here2")
				scrollTransition = transition.to(curPlayPos,
				{time=relEndTrackTime - relPlayTime,x=(w-10)})
				
				txtPlay.text = "Pause"
					
				actCounter = 1
				
				play()
			else
				print("here")
				audio.pause()
				isPaused = true
				txtPlay.text = "Play"
				if (scrollTransition) then
					transition.cancel(scrollTransition)
					scrollTransition = nil
				end
			end
			playPressCounter = playPressCounter + 1
		end
	end
	
	local function exitPressed(event)
		if (event.phase == "ended") then
			local vol = require("volumeRegulator")
			local rc = require("recording")
			rc.recPressCounter = 0
			
			vol.scrolls = {}
			Runtime:removeEventListener("enterFrame",play)
			stopPressed(nil)
			director:changeScene("level")
		end
	end
	
	local function bindListeners()
		playBtn:addEventListener("touch",playPressed)
		stopBtn:addEventListener("touch",stopPressed)
		exitBtn:addEventListener("touch",exitPressed)
		playLine:addEventListener("touch",onSeek)
		Runtime:addEventListener("enterFrame",play)
	end
	
	playLine:setFillColor(255,0,0)

	playLine.x,playLine.y = w/2,h/2
	curPlayPos.x,curPlayPos.y = 10,h/2
	exitBtn.x, exitBtn.y = w/2, 5*h/6
	playBtn.x, playBtn.y = w/3-5, 2*h/3
	stopBtn.x, stopBtn.y = 2*w/3-5, 2*h/3

	txtExit.x,txtExit.y = w/2, 5*h/6
	txtPlay.x,txtPlay.y = w/3, 2*h/3
	txtStop.x,txtStop.y = 2*w/3-5, 2*h/3

	txtExit:setTextColor(0,0,0)
	txtPlay:setTextColor(0,0,0)
	txtStop:setTextColor(0,0,0)

	localGroup:insert(playBtn)
	localGroup:insert(stopBtn)
	localGroup:insert(playLine)
	localGroup:insert(curPlayPos)
	localGroup:insert(exitBtn)
	localGroup:insert(txtExit)
	localGroup:insert(txtPlay)
	localGroup:insert(txtStop)

	bindListeners()	
	
	playerAppearTime = system.getTimer()
	
	return localGroup
end
