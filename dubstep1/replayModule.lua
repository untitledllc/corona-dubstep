module (...,package.seeall)

local gl = require("globals")

local runtimeGlitchHandlers = {}
local glitchFlags = {}

local userActionList = {}
local startReplayTime = nil
local prevMeasure = nil
local curActionIdx = 1

local beginPauseTime = 0
local timeInPause = 0

local playPressCounter = 0

function new()

	audio.stop()
	for i, v in pairs(gl.soundsConfig) do
		if v.type == "melody" then
			if v.sound then
				audio.rewind(v.sound)
			end
			v.channel = nil
		end
	end
	local w = gl.w
	local h = gl.h

	startReplayTime = nil
	prevMeasure = nil
	curActionIdx = 1
	
	local localGroup = display.newGroup()

	local backGround = display.newImageRect("player/backGround.png", gl.myW,gl.myH)
	backGround.x, backGround.y = gl.w/2, gl.h/2
	localGroup:insert(backGround)
	
	local playBtn = display.newImageRect("player/play.png", 73*gl.sizeCoef, 73*gl.sizeCoef)
	local pauseBtn = display.newImageRect("player/pause.png", 73*gl.sizeCoef, 73*gl.sizeCoef)
	local stopBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	local playLine = display.newImageRect("player/progressBar.png", 278, 12)
	local curPlayPos = display.newImageRect("player/playingBuble.png", 24, 24)
	--local exitBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	--local txtExit = display.newText("Exit", 0, 0, native.systemFont, 24)
	--local txtPlay = display.newText("Play", 0, 0, native.systemFont, 24)
	local txtStop = display.newText("Stop", 0, 0, native.systemFont, 24)
	txtStop.isVisible = false
	stopBtn.isVisible = false
	pauseBtn.isVisible = false
	
	playPressCounter = 0
	local relEndTrackTime = 1
	local relPlayTime = 2
	local playerAppearTime = nil
	
	local actCounter = 1
	local isPaused = false
	
	local scrollTransition = nil

	local actionSize = 6

	local pl = require("playing")
	--local volPanel = require("volumeRegulator")

	local ptSumms = pl.getPartSumms()
	
	local toSeekAtBeginTime = nil

	local deltaTSumm = 0
	local toChangeGlitchState = gl.glitchShutUpTime
	local glitchState = 1

	local function mainPlayingFunction(event)
		if not isPaused then
			relPlayTime = (system.getTimer() - startReplayTime)
			if relPlayTime >= relEndTrackTime then
				Runtime:removeEventListener("enterFrame", mainPlayingFunction)

				stopBtn:dispatchEvent({name = "touch", phase = "ended"})

				playPressCounter = 0

				relPlayTime = 0

				startReplayTime = nil

				prevMeasure = nil

				--txtPlay.text = "Play"
				
				if (scrollTransition) then
					transition.cancel(scrollTransition)
					scrollTransition = nil
				end

				audio.stop()
				
				for i, v in pairs(gl.soundsConfig) do
					if v.type == "melody" then
						if v.sound then
							audio.rewind(v.sound)
						end
						v.channel = nil
					end
				end

				return -1
			end
			if curActionIdx <= #userActionList then 
				local curActTime = tonumber(userActionList[curActionIdx].actionTime)
				while relPlayTime >= curActTime do
					
					makeAction(curActionIdx)

					curActionIdx = curActionIdx + 1
					if curActionIdx > #userActionList then
						break
					end
					curActTime = tonumber(userActionList[curActionIdx].actionTime)
				end
			else

			end
		else
			timeInPause = system.getTimer() - beginPauseTime
		end
	end

	local function openUserActList()
		
    	local jsonUserActList = gl.readFile("test.json", system.DocumentsDirectory)

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
		if event.phase == "ended" then
			Runtime:removeEventListener("enterFrame", mainPlayingFunction)
			audio.stop()
			isPaused = false
			if (scrollTransition) then
				transition.cancel(scrollTransition)
				scrollTransition = nil
			end

			curPlayPos.x = 101
			userActionList = {}
			relPlayTime = 1000000
			relEndTrackTime = 1
			--txtPlay.text = "Play"
			playPressCounter = 0
			currentMeasure = 0
			prevMeasure = 0

			for i, v in pairs(runtimeGlitchHandlers) do
				Runtime:removeEventListener("enterFrame", v.f)
			end
			
			director:changeScene("replayModule")
		end
	end

	local function makeGlitchFunc( activeChannels )
		local closion = {
			tiks = 0,
		 	glitchStartTime = nil,
		 	glitchFinishTime = nil,
			prevMeasure = 0,
			curMeasure = 0,
			delta = 0,
			glitchLocalTime = 0,
			deltaSumm = 0,
			actChannels = activeChannels
		}
		local function runtimeGlitchHandler(event)
	 			for idx,val in pairs(closion.actChannels) do
					local volume = val.v * 0.5 * (1.0 + math.cos(6.28*closion.deltaSumm/180.0) )
					audio.setVolume(volume,{channel = val.ch})
				end
	 			
	 			if (closion.curMeasure > closion.prevMeasure) then
					closion.delta = closion.curMeasure - closion.prevMeasure
					closion.prevMeasure = closion.curMeasure
					closion.deltaSumm = closion.deltaSumm + closion.delta
				end
	 			
	 			closion.curMeasure = system.getTimer()
	 			
	 			closion.glitchLocalTime = closion.glitchLocalTime + closion.delta
		end
		closion.prevMeasure = system.getTimer()
		return runtimeGlitchHandler, closion
	end
	
	function makeAction(index) 
	
		print("---------------")
		print("NEW ACTION")
		print("---------------")
		print(index)
		print("---------------")
		print("actionTime=",userActionList[index].actionTime)
		print("channel=",userActionList[index].channel)
		print("actType=",userActionList[index].actType)
		print("volume=",userActionList[index].volume)
		print("id=",userActionList[index].id)
		print("loops=",userActionList[index].loops)
		if userActionList[index].activeChannels then
			print("activeChannels=")
			for i, val in pairs(userActionList[index].activeChannels) do
				print("		channel = "..val.ch, " volume = "..val.v)
			end
		end

		local curId = userActionList[index].id
		local curChannel = tonumber(userActionList[index].channel)
		local curVolume = tonumber(userActionList[index].volume)
		local curActType = userActionList[index].actType
		local curActTime = tonumber(userActionList[index].actionTime)
		local curLoops = tonumber(userActionList[index].loops)
		local curActiveChannels
		if userActionList[index].activeChannels then
			curActiveChannels = userActionList[index].activeChannels
		end
		
		if curActType == "endRecord" then 
			audio.stop()
			for i, v in pairs(runtimeGlitchHandlers) do
				Runtime:removeEventListener("enterFrame", v.f)
			end
			return 1
		end
		
		if curActType == "chVolume" then
			audio.setVolume(curVolume, {channel = curChannel})
			return 1
		end

		if curActType == "pause" then
			audio.pause(curChannel)
			for i, v in pairs(runtimeGlitchHandlers) do
				Runtime:removeEventListener("enterFrame", v.f)
			end
			return 1
		end

		if curActType == "resume" then
			audio.resume(curChannel)
			for i, v in pairs(runtimeGlitchHandlers) do
				Runtime:addEventListener("enterFrame", v.f)
			end
			return 1
		end

		if curActType == "start" then
			if curId == "choosing" then
				local m = audio.loadStream(gl.kitAddress.."chooseSide.mp3" )
				audio.play(m, {channel = curChannel, loops = curLoops, onComplete = function()
					audio.dispose(m)
				end})
			elseif gl.soundsConfig[curId].sound then
				audio.play(gl.soundsConfig[curId].sound, {channel = curChannel, loops = curLoops})
			else
				return -1
			end
			return 1
		end

		if curActType == "stop" then
			audio.stop(curChannel)
			return 1
		end

		if curActType == "startGlitch" then
			local runtimeGlitchHandler, closion = makeGlitchFunc(curActiveChannels)
			runtimeGlitchHandlers[curId] = {f = runtimeGlitchHandler, cl = closion}
			Runtime:addEventListener("enterFrame", runtimeGlitchHandlers[curId].f)
			return 1
		end

		if curActType == "stopGlitch" then
			Runtime:removeEventListener("enterFrame", runtimeGlitchHandlers[curId].f)
			for idx,val in pairs(runtimeGlitchHandlers[curId].cl.actChannels) do
	   			audio.setVolume(val.v,{channel = val.ch})
			end
			runtimeGlitchHandlers[curId] = nil
			return 1
		end

		if curActType == "addVoiceGlitchChannel" then
			if runtimeGlitchHandlers.glV then
				table.insert(runtimeGlitchHandlers.glV.cl.actChannels, {ch = curChannel, v = curVolume})
			end
		end

		if curActType == "removeVoiceGlitchChannel" then
			if runtimeGlitchHandlers.glV then
				for i, v in pairs(runtimeGlitchHandlers.glV.cl.actChannels) do
					if v.ch == curChannel then
						runtimeGlitchHandlers.glV.cl.actChannels[i] = nil
					end
				end
			end
		end

		if curActType == "addSoundGlitchChannel" then
			if runtimeGlitchHandlers.glS then
				table.insert(runtimeGlitchHandlers.glS.cl.actChannels, {ch = curChannel, v = curVolume})
			end
		end

		if curActType == "removeSoundGlitchChannel" then
			if runtimeGlitchHandlers.glS then
				for i, v in pairs(runtimeGlitchHandlers.glS.cl.actChannels) do
					if v.ch == curChannel then
						runtimeGlitchHandlers.glS.cl.actChannels[i] = nil
					end
				end
			end
		end
		
		return false
	end
	
	
	
	
	local function onSeek(event)
		if (event.phase == "ended") then

			if (scrollTransition) then
				transition.cancel(scrollTransition)
				scrollTransition = nil
			end

			if playPressCounter == 0 then
				openUserActList()
	
				relPlayTime = 0
				startReplayTime = system.getTimer()
				prevMeasure = system.getTimer()
				relEndTrackTime = userActionList[#userActionList].actionTime + 200
				print(relEndTrackTime)
			end

			Runtime:removeEventListener("enterFrame", mainPlayingFunction)

			local masterVolume = audio.getVolume()
			print(masterVolume)
			audio.setVolume(0)

			audio.stop()
			for i, v in pairs(gl.soundsConfig) do
				if v.type == "melody" then
					if v.sound then
						audio.rewind(v.sound)
					end
					v.channel = nil
				end
			end
			isPaused = false

			for i, v in pairs(runtimeGlitchHandlers) do
				Runtime:removeEventListener("enterFrame", v.f)
			end

			curActionIdx = 1
			relPlayTime = (event.x - event.target.x)/(event.target.width - 6)*relEndTrackTime
			print(relPlayTime)

			-- Последовательно выполняем все действия, до момента, на который мы перемотали
			while tonumber(userActionList[curActionIdx].actionTime) < relPlayTime do
				local act = userActionList[curActionIdx]
				makeAction(curActionIdx)
				-- Если был запущен трек, то перематываем его туда, где он должен быть в искомый момент времени
				if act.actType == "start" then
					audio.pause(tonumber(act.channel))
					local wantToSeek = relPlayTime - tonumber(act.actionTime)
					if act.loops == "-1" then
						local duration = audio.getDuration(gl.soundsConfig[act.id].sound)
						wantToSeek = wantToSeek % duration
						
						audio.seek(wantToSeek, tonumber(act.channel))
					elseif act.loops == "0" then
						if gl.soundsConfig[act.id].type ~= "melody" then
							local duration = audio.getDuration(gl.soundsConfig[act.id].sound)
							if wantToSeek >= duration then
								audio.stop(tonumber(act.channel))
							else
								audio.seek(wantToSeek, tonumber(act.channel))
							end
						end
					end
					
				-- Тоже самое делаем с глитчем
				elseif act.actType == "startGlitch" then
					Runtime:removeEventListener("enterFrame", runtimeGlitchHandlers[act.id].f)
					local tmpDeltaSum = relPlayTime - tonumber(act.actionTime)
					--while tmpDeltaSum > (gl.glitchShutUpTime + gl.glitchPlayTime) do
					--	tmpDeltaSum = tmpDeltaSum - (gl.glitchShutUpTime + gl.glitchPlayTime)
					--end
					runtimeGlitchHandlers[act.id].cl.deltaSumm = tmpDeltaSum
				end

				curActionIdx = curActionIdx + 1
			end

			audio.setVolume(masterVolume)

			curPlayPos.x = event.x
			

			startReplayTime = system.getTimer() - relPlayTime

			for i, v in pairs(runtimeGlitchHandlers) do
				v.cl.curMeasure = system.getTimer()
				v.cl.prevMeasure = v.cl.curMeasure - 16
				Runtime:addEventListener("enterFrame", v.f)
			end
			if playPressCounter % 2 == 0 then
				timeInPause = 0
				beginPauseTime = system.getTimer()
				isPaused = true
				Runtime:addEventListener("enterFrame", mainPlayingFunction)
				audio.pause()
				playPressCounter = playPressCounter + 2
				--txtPlay.text = "Play"
			else
				scrollTransition = transition.to(curPlayPos,
				{time=relEndTrackTime - relPlayTime,x=374})
				audio.resume()
				isPaused = false
				Runtime:addEventListener("enterFrame", mainPlayingFunction)
				--txtPlay.text = "Pause"
			end

				
		end
	end
	
	local function playPressed(event)
		if (event.phase == "ended") then
			if event.target == playBtn then
				if playPressCounter == 0 then	
					
					--prepareToReplay()

					openUserActList()
	
					relPlayTime = 0
					startReplayTime = system.getTimer()
					prevMeasure = system.getTimer()
					relEndTrackTime = userActionList[#userActionList].actionTime + 200
					print(relEndTrackTime)
					
					--makePreRecordActions()
					Runtime:addEventListener("enterFrame", mainPlayingFunction)
				else
					startReplayTime = startReplayTime + timeInPause
					audio.resume()
					isPaused = false
					prevMeasure = system.getTimer()
					--[[for i, v in pairs(runtimeGlitchHandlers) do
						Runtime:removeEventListener("enterFrame", v.f)
					end]]--
				end 
				
				if (scrollTransition) then
					transition.cancel(scrollTransition)
					scrollTransition = nil
				end
				scrollTransition = transition.to(curPlayPos,
				{time=relEndTrackTime - relPlayTime,x=374})
				
				--txtPlay.text = "Pause"
				playBtn.isVisible = false
				pauseBtn.isVisible = true
				
				actCounter = 1
			elseif event.target == pauseBtn then
				timeInPause = 0
				
				beginPauseTime = system.getTimer()
				isPaused = true
				audio.pause()
				
				--[[for i, v in pairs(runtimeGlitchHandlers) do
					Runtime:removeEventListener("enterFrame", v.f)
				end]]--

				--txtPlay.text = "Play"
				if (scrollTransition) then
					transition.cancel(scrollTransition)
					scrollTransition = nil
				end

				playBtn.isVisible = true
				pauseBtn.isVisible = false
			end
			playPressCounter = playPressCounter + 1
		end
	end
	
	local function exitPressed(event)
		if (event.phase == "release") then
			--local vol = require("volumeRegulator")
			--local rc = require("recording")
			--rc.recPressCounter = 0
			
			--vol.scrolls = {}
			--Runtime:removeEventListener("enterFrame",play)
			Runtime:removeEventListener("enterFrame", mainPlayingFunction)
			audio.stop()
			userActionList = {}
			for i, v in pairs(gl.soundsConfig) do
				if v.type == "melody" then
					if v.sound then
						audio.rewind(v.sound)
					end
					v.channel = nil
				end
			end
			for i, v in pairs(runtimeGlitchHandlers) do
				Runtime:removeEventListener("enterFrame", v.f)
			end
			if event.target == gl.btn1 then
				require("level").atOncePlay = false
			elseif event.target == gl.btn2 then
				require("level").atOncePlay = true
			end
			while localGroup.numChildren > 0 do
				localGroup:remove(1)
			end

			local loading = display.newImageRect("images/iphone/splashScreenImage.png", gl.w, gl.h)
			loading.x, loading.y = gl.w/2, gl.h/2
			loading.isVisible = true
			
			local title = display.newImageRect("images/iphone/dubstep.png",182*gl.sizeCoef, 30*gl.sizeCoef)
			title:setReferencePoint(display.TopLeftReferencePoint)
			title.x, title.y = 300 * gl.coefW + display.screenOriginX, 162 * gl.coefH + display.screenOriginY

			local loadIndicator = display.newImageRect("images/iphone/loading.png",51*gl.sizeCoef, 16*gl.sizeCoef)
			loadIndicator:setReferencePoint(display.TopLeftReferencePoint)
			loadIndicator.x, loadIndicator.y = 300 * gl.coefW + display.screenOriginX, 199 * gl.coefH + display.screenOriginY

			localGroup:insert(loading)
			localGroup:insert(title)
			localGroup:insert(loadIndicator)
			--localGroup.isVisible = false
			timer.performWithDelay(200, function()
				director:changeScene("level")
			end)
			

		end
	end	
	
	local function bindListeners()
		playBtn:addEventListener("touch",playPressed)
		pauseBtn:addEventListener("touch", playPressed)
		stopBtn:addEventListener("touch",stopPressed)
		playLine:addEventListener("touch",onSeek)
	end
	
	--playLine:setFillColor(255,0,0)

	playLine:setReferencePoint(display.TopLeftReferencePoint)
	playLine.x,playLine.y = 99*gl.coefW + display.screenOriginX, 292*gl.coefH + display.screenOriginY
	curPlayPos.x,curPlayPos.y = 101*gl.coefW + display.screenOriginX,298*gl.coefH + display.screenOriginY
	--exitBtn.x, exitBtn.y = w/2, 5*h/6
	playBtn:setReferencePoint(display.TopLeftReferencePoint)
	playBtn.x, playBtn.y = 204*gl.coefW + display.screenOriginX, 143*gl.coefH + display.screenOriginY
	pauseBtn:setReferencePoint(display.TopLeftReferencePoint)
	pauseBtn.x, pauseBtn.y = 204*gl.coefW + display.screenOriginX, 143*gl.coefH + display.screenOriginY
	stopBtn.x, stopBtn.y = 2*w/3-5, 2*h/3

	--txtExit.x,txtExit.y = w/2, 5*h/6
	--txtPlay.x,txtPlay.y = w/3, 2*h/3
	txtStop.x,txtStop.y = 2*w/3-5, 2*h/3

	--txtExit:setTextColor(0,0,0)
	--txtPlay:setTextColor(0,0,0)
	txtStop:setTextColor(0,0,0)

	localGroup:insert(playBtn)
	localGroup:insert(pauseBtn)
	localGroup:insert(stopBtn)
	localGroup:insert(playLine)
	localGroup:insert(curPlayPos)
	--localGroup:insert(exitBtn)
	--localGroup:insert(txtExit)
	--localGroup:insert(txtPlay)
	localGroup:insert(txtStop)

	bindListeners()	
	
	playerAppearTime = system.getTimer()


	

	gl.btn1:removeSelf()
	gl.btn2:removeSelf()

	gl.btn1 = gl.widget.newButton{
		id = "toMenu",
		left = 5*gl.coefW + display.screenOriginX,
		top = 3*gl.coefH + display.screenOriginY,
		default = "images/elements/toMenuFromPlayng.png",
		over = "images/elements/toMenuFromPlayngPressed.png",
		width = 55*gl.sizeCoef,
		height = 36*gl.sizeCoef,
		onEvent = exitPressed
	}
	gl.btn1.atOncePlay = false

	gl.btn2 = gl.widget.newButton{
		id = "restart",
		left = 440*gl.coefW + display.screenOriginX,
		top = 5*gl.coefH + display.screenOriginY,
		default = "images/elements/restart.png",
		over = "images/elements/restartPressed.png",
		width = 38*gl.sizeCoef,
		height = 36*gl.sizeCoef,
		onEvent = exitPressed
	}
	gl.btn2.atOncePlay = true
	
	gl.btn1.isVisible = true
	gl.btn2.isVisible = true
	
	gl.navBar:removeSelf()	
	gl.navBar = display.newGroup()
	for i = 1, 120 do
		local navBarPart = display.newImageRect("images/elements/navBar.png", 4*gl.coefW, 43*gl.coefH)
		navBarPart.x, navBarPart.y = (2 + 4*(i-1))*gl.coefW + display.screenOriginX, 21*gl.coefH + display.screenOriginY
		gl.navBar:insert(navBarPart)
	end
	
	gl.navBar.isVisible = true

	localGroup:insert(gl.navBar)
	localGroup:insert(gl.btn1)
	localGroup:insert(gl.btn2)
	--director.loadingScreen:removeSelf()
	return localGroup
end
