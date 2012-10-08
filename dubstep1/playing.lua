module(...,package.seeall)

local gl = require("globals") 
local recording = require("recording")
local curLayout = require("level")
local numSampleTypes = 5

local runtimeGlitchHandler

local defaultVolume = 0.2

local partSumms = {}

local activeChannels = {["glitchChannel"] = nil}

local voiceTimer = nil
local fxTimer = nil

local isGlitchStarted = false

function getPartSumms()
	return partSumms
end

function getActiveChannels()
	return activeChannels
end

function prepareToPlay()
	-- gl.soundsConfig - треки с информацией из конфига
	-- gl.mainGroup[2] - кнопки управления музыкой текущего уровня

	-- Делаем видимыми кнопки первой сцены
	for i, v in pairs(gl.buttonsInScenes[1]) do
		local curBInfo = gl.configInterface.soundButtons[v[1]]
		if curBInfo.side and curBInfo.side == gl.choosenSide then
			curBInfo.button.isVisible = true
			curBInfo.button.txt.isVisible = true
		elseif not curBInfo.side then
			curBInfo.button.isVisible = true
			curBInfo.button.txt.isVisible = true
		end
	end

	gl.startRecordTime = system.getTimer()

	if gl.tracksStartSameTime then 
		-- запускаем все мелодии на воспроизведение
		for i, v in pairs(gl.soundsConfig) do
			if v.type == "melody" and v.sound then
				if (v.side and v.side == gl.choosenSide) or (not v.side) then
					local ch = audio.findFreeChannel()
					v.channel = ch
					audio.play(v.sound, {channel = v.channel, loops = -1})
					audio.setVolume(0, {channel = v.channel})
				end
			end
		end
	else
		-- запускаем на воспроизведение мелодии 1 сцены
		for i, v in pairs(gl.soundsInScenes[1]) do
			if gl.soundsConfig[v].type == "melody" and gl.soundsConfig[v].sound then
				if (gl.soundsConfig[v].side and gl.soundsConfig[v].side == gl.choosenSide) or (not gl.soundsConfig[v].side) then
					local ch = audio.findFreeChannel()
					gl.soundsConfig[v].channel = ch
					audio.play(gl.soundsConfig[v].sound, {channel = gl.soundsConfig[v].channel, loops = -1})
					audio.setVolume(0, {channel = gl.soundsConfig[v].channel})
				end
			end
		end
	end

	-- Нажимаем те кнопки, которые нажаты по умолчанию на первой сцене
	for i, v in pairs(gl.buttonsInScenes[1]) do
		if v[2] == true and gl.configInterface.soundButtons[v[1]].button then
			gl.configInterface.soundButtons[v[1]].button:dispatchEvent({name = "touch", phase = "ended"})
		end
	end

	-- Ставим первый бэкграунд
	gl.mainGroup[1].isVisible = true

	gl.currentScene = 1
end

-- Проверяет, принадлежит ли кнопка сцене
function ifButtonInScene(b, sNum)
	local fl = false
	for i, v in pairs(gl.buttonsInScenes[sNum]) do
		if gl.configInterface.soundButtons[v[1]].button == b then
			fl = true
			break
		end
	end

	return fl
end

function ifMelodyInScene(mInfo, sNum)
	local fl = false
	for i, v in pairs(gl.soundsInScenes[sNum]) do
		if v == mInfo.id then
			fl = true
			break
		end
	end

	return fl
end

local function unpressButton(b)
	if b.tween then
		transition.cancel(b.tween)
	end
	b.alpha = 0.5
	b.pressed = 0
	audio.setVolume(0, {channel = gl.soundsConfig[b.soundId].channel})
	if b.type == "melody" then

	elseif b.type == "fx" then

	elseif b.type == "voice" then

	end
end

function nextScene(event)
	if event.phase == "ended" then
		gl.ifChoosen = true
		for i = 1, #recording.goodEvilButtonTimers, 1 do
			timer.cancel(recording.goodEvilButtonTimers[i])
		end

		gl.currentScene = gl.currentScene + 1
		timer.cancel(gl.sceneChangingTimer)
		if gl.currentScene <= gl.scenesNum then

			print("ololo")

			-- Переключаем таймер перехода на следующую сцену
			gl.sceneChangingTimer = timer.performWithDelay(gl.sceneLength, function()
				gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
			end)

			-- Меняем бэкграунд
			local backs = require("level").getLayoutBacks()

			gl.mainGroup:remove(1)
			gl.mainGroup:insert(1, backs[gl.currentScene])

			-- Плавно
			transition.to(backs[gl.currentScene - 1], {alpha = 0, time = 500})
			backs[gl.currentScene].alpha = 0
			backs[gl.currentScene].isVisible = true
			transition.to(backs[gl.currentScene], {alpha = 1, time = 500})

			timer.performWithDelay(600, function()
				backs[gl.currentScene - 1].isVisible = false
			end)

			-- Скрываем кнопки предыдущей сцены, которых нет в новой сцене
			for i, v in pairs(gl.buttonsInScenes[gl.currentScene - 1]) do
				local curBInfo = gl.configInterface.soundButtons[v[1]]
				if curBInfo.button then
					if gl.tracksStartSameTime then 
						if not ifButtonInScene(curBInfo.button, gl.currentScene) then
							curBInfo.button.isVisible = false
							curBInfo.button.txt.isVisible = false
							-- Если кнопка нажата, то "отжимаем"
							if curBInfo.button.pressed and curBInfo.button.pressed ~= 0 then
								unpressButton(curBInfo.button)
							end
							--gl.configInterface.soundButtons[v[1]].button.txt:removeSelf()
							--gl.configInterface.soundButtons[v[1]].button.txt = nil
							--gl.configInterface.soundButtons[v[1]].button:removeSelf()
							--gl.configInterface.soundButtons[v[1]].button = nil
						end
					else
						curBInfo.button.isVisible = false
						curBInfo.button.txt.isVisible = false
						-- Если кнопка нажата, то "отжимаем"
						if curBInfo.button.pressed and curBInfo.button.pressed ~= 0 then
							unpressButton(curBInfo.button)
						end
					end
				end
			end


			if not gl.tracksStartSameTime then
				--[[ подгружаем музыку новой сцены (если она не запущена вся сразу)
				local channelCounter = 1
				for i, v in pairs(gl.soundsInScenes[gl.currentScene]) do
					if gl.soundsConfig[v].side and gl.soundsConfig[v].side == gl.choosenSide then
						gl.soundsConfig[v].sound = audio.loadSound(gl.kitAddress..gl.soundsConfig[v].side.."/"..gl.soundsConfig[v].name)
					elseif not gl.soundsConfig[v].side then
						gl.soundsConfig[v].sound = audio.loadSound(gl.kitAddress..gl.soundsConfig[v].name)
					end
					gl.soundsConfig[v].channel = channelCounter
					channelCounter = channelCounter + 1
				end]]--

				-- останавливаем мелодии предыдущей сцены
				for i, v in pairs(gl.soundsInScenes[gl.currentScene - 1]) do
					if gl.soundsConfig[v].type == "melody" and gl.soundsConfig[v].sound then
						--if not ifMelodyInScene(gl.soundsConfig[v], gl.currentScene) then
							audio.stop(gl.soundsConfig[v].channel)
							gl.soundsConfig[v].channel = nil
							--audio.dispose(gl.soundsConfig[v].sound)
							--gl.soundsConfig[v].sound = nil
						--end
					end
				end--

				-- запускаем на воспроизведение мелодии новой сцены
				for i, v in pairs(gl.soundsInScenes[gl.currentScene]) do
					if gl.soundsConfig[v].type == "melody" and gl.soundsConfig[v].sound then
						if (gl.soundsConfig[v].side and gl.soundsConfig[v].side == gl.choosenSide) or (not gl.soundsConfig[v].side) then
							local ch = audio.findFreeChannel()
							gl.soundsConfig[v].channel = ch
							audio.play(gl.soundsConfig[v].sound, {channel = gl.soundsConfig[v].channel, loops = -1})
							audio.setVolume(0, {channel = gl.soundsConfig[v].channel})
						end
					end
				end

				--[[ создаём кнопки новой сцены
				for i, v in pairs(gl.buttonsInScenes[gl.currentScene]) do
					local curBInfo = gl.configInterface.soundButtons[v[1] ]
					if (curBInfo.side and curBInfo.side == gl.choosenSide) or (not curBInfo.side) then
						local b = gl.createButton({["track"] = gl.soundsConfig[curBInfo.soundId], ["left"] = curBInfo.left, ["top"] = curBInfo.top, ["width"] = curBInfo.w, ["height"] = curBInfo.h, ["type"] = gl.soundsConfig[curBInfo.soundId].type, ["rgb"] = curBInfo.rgb, ["alpha"] = curBInfo.alpha, ["scenes"] = curBInfo.scenes, ["soundId"] = curBInfo.soundId})
						b.isVisible = false
						b.txt.isVisible = false
						gl.configInterface.soundButtons[v[1] ].button = b
						gl.mainGroup[2]:insert(b)
					end
				end]]--
			end

			-- Показываем кнопки новой сцены
			for i, v in pairs(gl.buttonsInScenes[gl.currentScene]) do
				local curBInfo = gl.configInterface.soundButtons[v[1]]
				if curBInfo.button then
					if curBInfo.side and curBInfo.side == gl.choosenSide then
						curBInfo.button.isVisible = true
						curBInfo.button.txt.isVisible = true
					elseif not curBInfo.side then
						curBInfo.button.isVisible = true
						curBInfo.button.txt.isVisible = true
					end
				end
			end

			-- Нажимаем ненажатые кнопки новой сцены, если они должны быть нажаты
			for i, v in pairs(gl.buttonsInScenes[gl.currentScene]) do
				local curBInfo = gl.configInterface.soundButtons[v[1]]
				if curBInfo.button and curBInfo.side == gl.choosenSide then
					if v[2] == true and (not curBInfo.button.pressed  or curBInfo.button.pressed == 0) then
						gl.configInterface.soundButtons[v[1]].button:dispatchEvent({name = "touch", phase = "ended"})
					end
				end
			end
		-- Если закончились сцены
		else
			-- Скрываем кнопки
			for i = 1, gl.mainGroup[2].numChildren, 1 do
					gl.mainGroup[2][i].isVisible = false
					gl.mainGroup[2][i].txt.isVisible = false

					-- Если кнопка нажата, то "отжимаем"
					if gl.mainGroup[2][i].pressed and gl.mainGroup[2][i].pressed ~= 0 then
						unpressButton(gl.mainGroup[2][i])
					end
			end
			gl.goodBtn.isVisible = false
			gl.goodBtn.txt.isVisible = false
			gl.evilBtn.isVisible = false
			gl.evilBtn.txt.isVisible = false
			gl.nextSceneButton.isVisible = false
			gl.nextSceneButton.txt.isVisible = false

			-- включаем музыку экрана с кнопкой шаринга
			local path = system.pathForFile(gl.kitAddress.."share.mp3")
			if path then
				local shareMusic = audio.loadStream(gl.kitAddress.."share.mp3")
				local ch = audio.findFreeChannel()
				audio.play(shareMusic, {channel = ch, loops = -1})
				audio.setVolume(0.5, {channel = ch})
			end

			-- Снимаем обработчик перехода между сценами
			gl.nextSceneButton:removeEventListener("touch", nextScene)

			-- Кнопка шаринга
			gl.shareBtn.isVisible = true
			gl.shareBtn.txt.isVisible = true
		end
	end
end



function playMelody(trackInfo,button)
	if not button.pressed then
		button.pressed = 1
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		button.alpha = 1
	elseif button.pressed == 1 then
		button.pressed = 0
		audio.setVolume(0, {channel = trackInfo.channel})
		button.alpha = 0.5
	elseif button.pressed == 0 then
		button.pressed = 1
		button.pressed = 1
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		button.alpha = 1
	end

  --[[  if (recording.isRecStarted() == true) then
    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
   	end]]--
end

function playFX(trackInfo,button)
	if not button.pressed then
		button.pressed = 1
		local ch = audio.findFreeChannel()
		trackInfo.channel = ch
		audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
			button.pressed = 0
			--[[if (recording.isRecStarted() == true) then
	    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    							index,0,audio.getVolume({channel = index}),4,0)
	   		end]]--
		end})
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})

		--[[if (recording.isRecStarted() == true) then
    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
   		end]]--

		button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})
	else
		button.pressed = 1
		if button.tween then
			transition.cancel(button.tween)
			button.alpha = 0.5
		end
		audio.stop(trackInfo.channel)
		local ch = audio.findFreeChannel()
		trackInfo.channel = ch
		audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
			button.pressed = 0
			--[[if (recording.isRecStarted() == true) then
	    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    							index,0,audio.getVolume({channel = index}),4,0)
	   		end]]--
		end})
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})

		--[[if (recording.isRecStarted() == true) then
    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
   		end]]--

		button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})
	end
    
	
end

function playVoice(trackInfo,button)
	if not button.pressed then
		button.pressed = 1
		local ch = audio.findFreeChannel()
		trackInfo.channel = ch
		audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
			button.pressed = 0
			--[[if (recording.isRecStarted() == true) then
	    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    							index,0,audio.getVolume({channel = index}),4,0)
	   		end]]--
		end})
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})

		--[[if (recording.isRecStarted() == true) then
	    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    						index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
	   	end]]--

		button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})
	else
		button.pressed = 1
		if button.tween then
			transition.cancel(button.tween)
			button.alpha = 0.5
		end
		audio.stop(trackInfo.channel)
		local ch = audio.findFreeChannel()
		trackInfo.channel = ch
		audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
			button.pressed = 0
			--[[if (recording.isRecStarted() == true) then
		   		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
		   							index,0,audio.getVolume({channel = index}),4,0)
		  		end]]--
		end})
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})

		--[[if (recording.isRecStarted() == true) then
	    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    						index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
	   	end]]--

		button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})
	end
end



function playGlitch(event)
 	local tiks = 0
 	local glitchStartTime = nil
 	local glitchFinishTime = nil
	local prevMeasure = 0
	local curMeasure = 0
	local delta = 0
	local glitchLocalTime = 0
	local deltaSumm = 0
	local activeChannelsCopy = {}
	--local isGlitchStarted = false
	
 	runtimeGlitchHandler = function(e)
 		if (isGlitchStarted == true) then
 			if (deltaSumm > gl.glitchShutUpTime) then
 				event.target.alpha = 1
 				for idx,val in pairs(activeChannels) do
					--if (val.channel ~= nil and val.channel > partSumms[3]) then
						audio.setVolume(0,{channel = val.ch})
					--end
				end
 			end

 			if (deltaSumm > gl.glitchShutUpTime + gl.glitchPlayTime) then
 				event.target.alpha = 0.5
 				for idx,val in pairs(activeChannels) do
					--if (val.channel ~= nil and val.channel > partSumms[3]) then
						audio.setVolume(val.v,{channel = val.ch})	
					--end
				end
				deltaSumm = 0
 			end 	
 			
 			if (curMeasure > prevMeasure) then
				delta = curMeasure - prevMeasure
				prevMeasure = curMeasure
				deltaSumm = deltaSumm + delta
			end
 			
 			curMeasure = system.getTimer()
 			
 			glitchLocalTime = glitchLocalTime + delta
 		else
 			Runtime:removeEventListener("enterFrame", runtimeGlitchHandler)
 		end
 	end
	
	if (event.phase == "began") then
		isGlitchStarted = true
		activeChannels = {}
 			for i, v in pairs(event.target.soundIds) do
 				if  gl.soundsConfig[v].channel and audio.isChannelActive( gl.soundsConfig[v].channel ) then
 					local vol = audio.getVolume({channel = gl.soundsConfig[v].channel})
 					if vol > 0 then
 						activeChannels[#activeChannels + 1] = {ch = gl.soundsConfig[v].channel, v = vol}
 						--print(activeChannels[#activeChannels].ch, activeChannels[#activeChannels].v)
 					end
 				end
 			end
		
		prevMeasure = system.getTimer()
		curMeasure = 0
		--[[
		local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    	activeChannel.channel = gl.glitchChannel
    	activeChannel.startTime = system.getTimer() - curLayout.getLayoutAppearTime()
    	activeChannel.category = 6
    	activeChannel.volume = 0
   		activeChannels.glitchChannel = activeChannel
   		]]--
		if (recording.isRecStarted()) then
			--glitchStartTime = system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime()
			--recording.addAction(glitchStartTime,gl.glitchChannel,1,0,6,0)
		else
			glitchStartTime = 0
		end
		
		Runtime:addEventListener("enterFrame",runtimeGlitchHandler)
		display.getCurrentStage():setFocus(event.target, event.id)
	end
	
	if (event.phase == "ended" or (event.phase == "moved"  and 
		( event.x < (event.target.x - event.target.x/2) or event.x > (event.target.x + event.target.x/2) or event.y < (event.target.y - event.target.y/2) or event.y > (event.target.y + event.target.y/2) ) ) ) then
		
		Runtime:removeEventListener("enterFrame",runtimeGlitchHandler)
		event.target.alpha = 0.5
		isGlitchStarted = false
		
		if (recording.isRecStarted()) then
			--glitchFinishTime = system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime()
			--recording.addAction(glitchFinishTime,gl.glitchChannel,0,0,6,0)
		end
		
		--activeChannels.glitchChannel = {-1}

		for idx,val in pairs(activeChannels) do
			--if (val.channel ~= nil and val.channel > partSumms[3]) then
			
				--[[if (val.channel > partSumms[3] and val.channel <= partSumms[4]) then
				
					if (volumePanel.scrolls[4] ~= nil) then	
        				audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[4]),{channel = val.channel})  	
    				else	
    					audio.setVolume(defaultVolume,{channel = val.channel})  
   					end
   					
   				end]]--

   				audio.setVolume(val.v,{channel = val.ch}) 
   				--[[
   				if (val.channel > partSumms[4] and val.channel <= partSumms[5]) then
   				
   					if (volumePanel.scrolls[5] ~= nil) then	
        				audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[5]),{channel = val.channel})  	
    				else	
    					audio.setVolume(defaultVolume,{channel = val.channel})  
   					end
   					
   				end
   				]]--
				if (recording.isRecStarted()) then
					if val.ch > 13 then
						--recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    					--	val.ch,2,val.v,5,system.getTimer() - curLayout.getLayoutAppearTime())
					else
						--recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    					--	val.ch,2,val.v,2,system.getTimer() - curLayout.getLayoutAppearTime())
					end
				end
				
			--end
		end
		display.getCurrentStage():setFocus(nil)
	end
end

function play(group,kit,trackCounters,index,numSamples,numFX,numVoices,playParams)
	if (index <= partSumms[1]) then
		shutUpIntros(group,playParams[1],partSumms,trackCounters)
		playIntro(group,index,trackCounters)
	end
	
	if (index > partSumms[1] and index <= partSumms[2]) then
		shutUpMelodies(group,playParams[2],partSumms,trackCounters)
		playMelody(group,index,trackCounters)
	end
	
	if (index > partSumms[2] and index <= partSumms[3]) then
		shutUpDrums(group,playParams[3],partSumms,trackCounters)
		playDrums(group,index,trackCounters)
	end
	
	if (index > partSumms[3] and index <= partSumms[4]) then
		shutUpFX(group,playParams[4],numSamples,numFX,numVoices)
		playFX(group,kit,index)
	end
	
	if (index > partSumms[4] and index <= partSumms[5]) then
		shutUpVoices(group,playParams[5],numSamples,numFX,numVoices)
		playVoice(group,kit,index)
	end
end

local function playChoosingMelody()
	local m = audio.loadStream(gl.kitAddress.."chooseSide.mp3" )
	print(m)
	local ch = audio.findFreeChannel()
	audio.play(m, {channel = ch, loops = 0, onComplete = function()
		audio.dispose(m)
	end})
	audio.setVolume(0.5, {channel = ch})
end

function playGoodMelody(event)
	gl.ifChoosen = true
	gl.goodBtn.isVisible = false
	gl.evilBtn.isVisible = false
	gl.goodBtn.txt.isVisible = false
	gl.evilBtn.txt.isVisible = false
	local newSide = "dobro"

	if gl.currentLayout == "layout1" then

		audio.stop()
		timer.cancel(gl.sceneChangingTimer)	
		playChoosingMelody()
		
		-- если сторона поменялась, то подгружаем треки новой стороны
		if gl.choosenSide ~= newSide then
			--[[for i, v in pairs(gl.soundsConfig) do
				if v.side and v.side == newSide then
					v.sound = audio.loadSound(gl.kitAddress..v.side.."/"..v.name)
					v.channel = nil
				elseif v.side then
					audio.dispose(v.sound)
					v.sound = nil
					v.channel = nil
				end
			end]]--

			--[[ и создаем кнопки новой стороны
			for i, v in pairs(gl.configInterface.soundButtons) do
				if v.side and v.side == newSide then
					local b = gl.createButton({["track"] = gl.soundsConfig[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = gl.soundsConfig[v.soundId].type, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId})
					b.isVisible = false
					b.txt.isVisible = false
					v.button = b
					gl.mainGroup[2]:insert(b)
				end
			end]]--
		end
		
		-- переходим к следующей сцене
		timer.performWithDelay(1400, function()
			gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
		end)
		

		--[[recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							currentBasicChannel,
								0,0,2,0)]]--	
	else
		gl.goodBtn.isVisible = false
		gl.evilBtn.isVisible = false
		gl.goodBtn.txt.isVisible = false
		gl.evilBtn.txt.isVisible = false
		gl.currentBasicMelody = gl.currentEvilMelody
	end

	--gl.choosenSide = newSide
end

function playEvilMelody(event)
	gl.ifChoosen = true
	gl.goodBtn.isVisible = false
	gl.evilBtn.isVisible = false
	gl.goodBtn.txt.isVisible = false
	gl.evilBtn.txt.isVisible = false
	local newSide = "evil"

	if gl.currentLayout == "layout1" then

		audio.stop()
		timer.cancel(gl.sceneChangingTimer)	
		playChoosingMelody()
		
		-- если сторона поменялась, то подгружаем треки новой стороны
		if gl.choosenSide ~= newSide then
			--[[for i, v in pairs(gl.soundsConfig) do
				if v.side and v.side == newSide then
					v.sound = audio.loadSound(gl.kitAddress..v.side.."/"..v.name)
					v.channel = nil
				elseif v.side then
					audio.dispose(v.sound)
					v.sound = nil
					v.channel = nil
				end
			end]]--

			--[[ и создаем кнопки новой стороны
			for i, v in pairs(gl.configInterface.soundButtons) do
				if v.side and v.side == newSide then
					local b = gl.createButton({["track"] = gl.soundsConfig[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = gl.soundsConfig[v.soundId].type, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId})
					b.isVisible = false
					b.txt.isVisible = false
					v.button = b
					gl.mainGroup[2]:insert(b)
				end
			end]]--
		end
		
		-- переходим к следующей сцене
		timer.performWithDelay(1400, function()
			gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
		end)
		

		--[[recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							currentBasicChannel,
								0,0,2,0)]]--	
	else
		gl.goodBtn.isVisible = false
		gl.evilBtn.isVisible = false
		gl.goodBtn.txt.isVisible = false
		gl.evilBtn.txt.isVisible = false
		gl.currentBasicMelody = gl.currentEvilMelody
	end

	gl.choosenSide = newSide
end


function initSounds(kitAddress)
	local soundsConfig = gl.jsonModule.decode( gl.readFile("configSounds.json", kitAddress))

	for i = 1, gl.scenesNum, 1 do
		gl.soundsInScenes[i] = {}
	end

	for i, val in pairs(soundsConfig) do
		if val.scenes then
			for j, v in pairs(val.scenes) do
				table.insert(gl.soundsInScenes[tonumber(v)], i)
			end
		end
	end

	-- подгружаем всю музыку сразу (для текущей стороны)
	--if gl.tracksStartSameTime then
		for i, v in pairs(soundsConfig) do
			if v.type == "melody" then
				if v.side then --and v.side == gl.choosenSide then
					v.sound = audio.loadStream(kitAddress..v.side.."/"..v.name)
				elseif not v.side then
					v.sound = audio.loadStream(kitAddress..v.name)
				end
			else
				if v.side then --and v.side == gl.choosenSide then
					v.sound = audio.loadSound(kitAddress..v.side.."/"..v.name)
				elseif not v.side then
					v.sound = audio.loadSound(kitAddress..v.name)
				end
			end
			
			v.channel = nil
		end
	-- подгружаем только музыку первой сцены
	--[[else
		for i, v in pairs(gl.soundsInScenes[1]) do
			if soundsConfig[v].side and soundsConfig[v].side == gl.choosenSide then
				soundsConfig[v].sound = audio.loadSound(kitAddress..soundsConfig[v].side.."/"..soundsConfig[v].name)
			elseif not soundsConfig[v].side then
				soundsConfig[v].sound = audio.loadSound(kitAddress..soundsConfig[v].name)
			end
			soundsConfig[v].channel = channelCounter
			channelCounter = channelCounter + 1
		end
	--end]]
	gl.soundsConfig = soundsConfig
	
	return soundsConfig
end

function resetCounters(numSamples) 
	local i = 1
	local trackCounters = {}
	while (i <= numSamples) do
		trackCounters[i] = 0
		i = i + 1
	end
	return trackCounters
end

