module(...,package.seeall)

local gl = require("globals") 
local recording = require("recording")
local curLayout = require("level")
local numSampleTypes = 5

--local runtimeGlitchHandler
local runtimeGlitchHandlers = {}

local defaultVolume = 0.2

local partSumms = {}

local activeChannels = {["glitchChannel"] = nil}

local voiceTimer = nil
local fxTimer = nil

local playingVoicesFxs = {}

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
			--curBInfo.button.txt.isVisible = true
		elseif not curBInfo.side then
			curBInfo.button.isVisible = true
			--curBInfo.button.txt.isVisible = true
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
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), v.channel, "start", 0, v.id, -1)
					
					audio.setVolume(0, {channel = v.channel})
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), v.channel, "chVolume", 0, v.id, -1)
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
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), v.channel, "start", 0, v.id, -1)

					audio.setVolume(0, {channel = gl.soundsConfig[v].channel})
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), v.channel, "chVolume", 0, v.id, -1)
				end
			end
		end
	end

	-- Нажимаем те кнопки, которые нажаты по умолчанию на первой сцене
	for i, v in pairs(gl.buttonsInScenes[1]) do
		if v[2] == true and gl.configInterface.soundButtons[v[1]].button then
			local b = gl.configInterface.soundButtons[v[1]].button
			b:dispatchEvent({name = "emulatePress", phase = "release", target = b})
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
	local curSInfo = gl.soundsConfig[b.soundId]
	if b.tween then
		transition.cancel(b.tween)
	end
	--b.alpha = 0.5
	b.pressed = 0
	audio.setVolume(0, {channel = curSInfo.channel})
	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), curSInfo.channel, "chVolume", 0, curSInfo.id, -1)
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
							--curBInfo.button.txt.isVisible = false
							-- Если кнопка нажата, то "отжимаем"
							if curBInfo.button.pressed and curBInfo.button.pressed ~= 0 then
								--unpressButton(curBInfo.button)
								curBInfo.button:dispatchEvent({name = "emulatePress", phase = "release", target = curBInfo.button})
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
							--unpressButton(curBInfo.button)
							curBInfo.button:dispatchEvent({name = "emulatePress", phase = "release", target = curBInfo.button})
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
							recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), gl.soundsConfig[v].channel, "stop", 0, gl.soundsConfig[v].id, -1)
							
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
							recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), gl.soundsConfig[v].channel, "start", 0, gl.soundsConfig[v].id, -1)

							audio.setVolume(0, {channel = gl.soundsConfig[v].channel})
							recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), gl.soundsConfig[v].channel, "chVolume", 0, gl.soundsConfig[v].id, -1)
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
						--curBInfo.button.txt.isVisible = true
					elseif not curBInfo.side then
						curBInfo.button.isVisible = true
						--curBInfo.button.txt.isVisible = true
					end
				end
			end

			-- Нажимаем ненажатые кнопки новой сцены, если они должны быть нажаты
			for i, v in pairs(gl.buttonsInScenes[gl.currentScene]) do
				local curBInfo = gl.configInterface.soundButtons[v[1]]
				if curBInfo.button and curBInfo.side == gl.choosenSide then
					if v[2] == true and (not curBInfo.button.pressed  or curBInfo.button.pressed == 0) then
						gl.configInterface.soundButtons[v[1]].button:dispatchEvent({name = "emulatePress", phase = "release", target = gl.configInterface.soundButtons[v[1]].button})
					end
				end
			end
		-- Если закончились сцены
		else
			
			--[[ Скрываем кнопки
			for i = 1, gl.mainGroup[2].numChildren, 1 do
					gl.mainGroup[2][i].isVisible = false
					--gl.mainGroup[2][i].txt.isVisible = false

					-- Если кнопка нажата, то "отжимаем"
					if gl.mainGroup[2][i].pressed and gl.mainGroup[2][i].pressed ~= 0 then
						--unpressButton(gl.mainGroup[2][i])
						gl.mainGroup[2][i]:dispatchEvent({name = "emulatePress", phase = "release", target = gl.mainGroup[2][i]})
					end
			end
			]]--

			for i, v in pairs(gl.configInterface.soundButtons) do
				v.button.isVisible = false

				if v.button.pressed and v.button.pressed ~= 0 then
					v.button:dispatchEvent({name = "emulatePress", phase = "release", target = v.button})
				end
			end

			for i, v in pairs(gl.configInterface.glitchButtons) do
				v.button.isVisible = false
			end

			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "endRecord", 0, 0, 0)
			
			gl.goodBtn.isVisible = false
			gl.goodBtn.txt.isVisible = false
			gl.evilBtn.isVisible = false
			gl.evilBtn.txt.isVisible = false
			gl.nextSceneButton.isVisible = false
			gl.nextSceneButton.txt.isVisible = false

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
			--gl.shareBtn.isVisible = true
			--gl.shareBtn.txt.isVisible = true

			gl.repBtn.isVisible = true
			gl.menuButtonFinal.isVisible = true

			gl.btn1.isVisible = false
			gl.btn2.isVisible = false
			gl.navBar.isVisible = false
			--gl.repBtn.txt.isVisible = true

			recording.saveUserActList()

			recording.printUserActList()
		end
	end
end



function playMelody(trackInfo,button)
	if not button.pressed then
		button.pressed = 1
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, -1)
		--button.alpha = 1
	elseif button.pressed == 1 then
		button.pressed = 0
		audio.setVolume(0, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", 0, trackInfo.id, -1)
		--button.alpha = 0.5
	elseif button.pressed == 0 then
		button.pressed = 1
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, -1)
		--button.alpha = 1
	end

end

function playFX(trackInfo,button)
	if not button.pressed then
		button.pressed = 1
		local ch = audio.findFreeChannel(13)
		trackInfo.channel = ch

		playingVoicesFxs[trackInfo.id] = trackInfo
		button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})
		audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
			button.pressed = 0
			if system.getTimer() >= button.tween._timeStart + button.tween._duration then
				playingVoicesFxs[trackInfo.id] = nil
			end
		end})

		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "start", trackInfo.defaultVolume, trackInfo.id, 0)
		
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, 0)
		
	else
		button.pressed = 1
		
		if playingVoicesFxs[trackInfo.id] then
			audio.stop(trackInfo.channel)
			playingVoicesFxs[trackInfo.id] = nil
			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "stop", trackInfo.defaultVolume, trackInfo.id, 0)
		end

		local ch = audio.findFreeChannel()
		trackInfo.channel = ch

		if button.tween then
			transition.cancel(button.tween)
			--button.alpha = 0.5
		end

		playingVoicesFxs[trackInfo.id] = trackInfo
		button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})

		audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
			button.pressed = 0
			if system.getTimer() >= button.tween._timeStart + button.tween._duration then
				playingVoicesFxs[trackInfo.id] = nil
			end
		end})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "start", trackInfo.defaultVolume, trackInfo.id, 0)

		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, 0)
		
		
	end
    
	
end

function playVoice(trackInfo,button)
	
	if not button.pressed then
		button.pressed = 1
		local ch = audio.findFreeChannel(13)
		trackInfo.channel = ch

		playingVoicesFxs[trackInfo.id] = trackInfo
		button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})
		audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
			button.pressed = 0
			if system.getTimer() >= button.tween._timeStart + button.tween._duration then
				playingVoicesFxs[trackInfo.id] = nil
			end
		end})
		
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "start", trackInfo.defaultVolume, trackInfo.id, 0)

		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, 0)
		

		
	else
			button.pressed = 1
			if playingVoicesFxs[trackInfo.id] then
				
				audio.stop(trackInfo.channel)
				playingVoicesFxs[trackInfo.id] = nil
				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "stop", 0, trackInfo.id, -1)
			end
			
			local ch = audio.findFreeChannel(13)
			trackInfo.channel = ch

			if button.tween then
				transition.cancel(button.tween)
				button.alpha = 0.5
			end

			playingVoicesFxs[trackInfo.id] = trackInfo
			button.tween = transition.from(button, {alpha = 1, time = audio.getDuration(trackInfo.sound)})
			audio.play(trackInfo.sound, {channel = trackInfo.channel, loops = 0, onComplete = function()
				button.pressed = 0
				if system.getTimer() >= button.tween._timeStart + button.tween._duration then
					playingVoicesFxs[trackInfo.id] = nil
				end
			end})
			
			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "start", trackInfo.defaultVolume, trackInfo.id, 0)

			audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, 0)
			
	end
end

function makeGlitchFunc(button)
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
	local function runtimeGlitchHandler(event)
		--if (isGlitchStarted == true) then
 			if (deltaSumm > gl.glitchShutUpTime) then
 				--button.alpha = 1
 				for idx,val in pairs(activeChannels) do
					--if (val.channel ~= nil and val.channel > partSumms[3]) then
						audio.setVolume(0,{channel = val.ch})
					--end
				end
 			end

 			if (deltaSumm > gl.glitchShutUpTime + gl.glitchPlayTime) then
 				--button.alpha = 0.5
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
 		--else
 		--	Runtime:removeEventListener("enterFrame", runtimeGlitchHandler)
 		--end
	end
	prevMeasure = system.getTimer()
	return runtimeGlitchHandler
end



function playGlitch(event)
 	--[[local tiks = 0
 	local glitchStartTime = nil
 	local glitchFinishTime = nil
	local prevMeasure = 0
	local curMeasure = 0
	local delta = 0
	local glitchLocalTime = 0
	local deltaSumm = 0
	local activeChannelsCopy = {}
	local isGlitchStarted = false
	
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
	]]--
	if (event.phase == "press") then
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
 		event.target.glitchIdx = "gl"..tostring(#runtimeGlitchHandlers + 1)
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "startGlitch", 0, event.target.glitchIdx, 0, activeChannels)
		--prevMeasure = system.getTimer()
		--curMeasure = 0
		
		local glitchHandler = makeGlitchFunc(event.target)
		runtimeGlitchHandlers[event.target.glitchIdx] = glitchHandler
		Runtime:addEventListener("enterFrame",runtimeGlitchHandlers[event.target.glitchIdx])
		
		display.getCurrentStage():setFocus(event.target, event.id)
	end
	
	if (event.phase == "release" or (event.phase == "moved"  and 
		( event.x < (event.target.x - event.target.x/2) or event.x > (event.target.x + event.target.x/2) or event.y < (event.target.y - event.target.y/2) or event.y > (event.target.y + event.target.y/2) ) ) ) then
		
		Runtime:removeEventListener("enterFrame",runtimeGlitchHandlers[event.target.glitchIdx])
		--event.target.alpha = 0.5
		isGlitchStarted = false
		
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "stopGlitch", 0, event.target.glitchIdx, 0, activeChannels)

		for idx,val in pairs(activeChannels) do
   			audio.setVolume(val.v,{channel = val.ch})
		end
		runtimeGlitchHandlers[event.target.glitchIdx] = nil
		display.getCurrentStage():setFocus(event.target, nil)
	end
end

local function playChoosingMelody()
	local m = audio.loadStream(gl.kitAddress.."chooseSide.mp3" )
	local ch = audio.findFreeChannel()
	audio.play(m, {channel = ch, loops = 0, onComplete = function()
		audio.dispose(m)
	end})
	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), ch, "start", 0, "choosing", 0)
	
	audio.setVolume(0.5, {channel = ch})
	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), ch, "chVolume", 0.5, "choosing", 0)
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

