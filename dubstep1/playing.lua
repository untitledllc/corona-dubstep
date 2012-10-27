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
	local masterVolume = audio.getVolume()
	audio.setVolume(0)
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
				
					audio.pause(ch)
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), v.channel, "pause", 0, v.id, -1)
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

					audio.pause(ch)
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), v.channel, "pause", 0, v.id, -1)
				end
			end
		end
	end

	
	audio.setVolume(masterVolume)
	timer.performWithDelay(100, function()
		audio.resume(0)
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "resume", 0, "", -1)
		-- Нажимаем те кнопки, которые нажаты по умолчанию на первой сцене
		for i, v in pairs(gl.buttonsInScenes[1]) do
			if v[2] == true and gl.configInterface.soundButtons[v[1]].button then
				local b = gl.configInterface.soundButtons[v[1]].button
				b:dispatchEvent({name = "emulatePress", phase = "release", target = b})
			end
		end
	end)

	-- DEBUG //зажатый глитч
	--[[gl.configInterface.glitchButtons[1].button[1].isVisible = false
	gl.configInterface.glitchButtons[1].button[2].isVisible = true
	gl.configInterface.glitchButtons[1].button:dispatchEvent({name = "emulatePress", phase = "press", target = gl.configInterface.glitchButtons[1].button})
	]]--

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
			gl.toNextSceneTime = 9999
			gl.currentSceneAppearTime = system.getTimer()
			local newNum
			if gl.currentScene == 1 then
				newNum = "I"
			elseif gl.currentScene == 2 then
				newNum = "II"
			elseif gl.currentScene == 3 then
				newNum = "III"
			elseif gl.currentScene == 4 then
				newNum = "IV"
			elseif gl.currentScene == 5 then
				newNum = "V"
			end
			gl.deltaTime = gl.deltaTime + (gl.nextSceneAppearTime - gl.currentSceneLocalTime - curLayout.getLayoutAppearTime())
			gl.sceneNumber.text = "Scene: "..newNum
			gl.sceneNumberShadow.text = gl.sceneNumber.text
			gl.sceneNumber:setReferencePoint(display.TopLeftReferencePoint)
			gl.sceneNumber.x,gl.sceneNumber.y = 168*gl.coefW + display.screenOriginX,8*gl.coefH + display.screenOriginY
			gl.sceneNumberShadow.x,gl.sceneNumberShadow.y = 167*gl.coefW + display.screenOriginX,7*gl.coefH + display.screenOriginY
			
			-- Переключаем таймер перехода на следующую сцену
			gl.sceneChangingTimer = timer.performWithDelay(gl.sceneLength, function()
				gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
			end)

			-- Меняем бэкграунд

			gl.mainGroup:remove(1)
			gl.mainGroup:insert(1, gl.currentBacks[2])

			-- Плавно
			transition.to(gl.currentBacks[1], {alpha = 0, time = 500})
			gl.currentBacks[2].alpha = 0
			gl.currentBacks[2].isVisible = true
			transition.to(gl.currentBacks[2], {alpha = 1, time = 500})

			--timer.performWithDelay(600, function()
				--table.remove(gl.currentBacks, 1)
				--gl.currentBacks[1] = gl.currentBacks[2]
			--end)

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
			
			timer.performWithDelay(2500, function()
				gl.currentBacks[2] = display.newImageRect(gl.configInterface.backGrounds[gl.currentScene+1].fileName, gl.w, gl.h)
				gl.currentBacks[2].isVisible = false
				gl.currentBacks[2].x, gl.currentBacks[2].y = gl.w/2, gl.h/2
			end)

			
		-- Если закончились сцены
		else

			Runtime:removeEventListener("enterFrame", gl.toEndTimerFunc)
			Runtime:removeEventListener("enterFrame", gl.toNextSceneTimerFunc)

			for i, v in pairs(runtimeGlitchHandlers) do
				Runtime:removeEventListener("enterFrame", v)
			end
			for i, b in pairs(gl.configInterface.glitchButtons) do
				if b.button and b.button[2].isVisible ~= false then
					Runtime:removeEventListener("enterFrame", runtimeGlitchHandlers[b.button.id])
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "stopGlitch", 0, b.button.id, 0, b.button.activeChannels)

					for idx,val in pairs(b.button.activeChannels) do
			   			audio.setVolume(val.v,{channel = val.ch})
					end

					
					runtimeGlitchHandlers[b.button.id] = nil
					b.button.activeChannels = {}
				end
			end

			gl.sceneNumber.isVisible = false
			gl.timerTxt.isVisible = false
			gl.nextSceneTimerTxt.isVisible = false
			
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
			
			gl.nextSceneButton.isVisible = false
			gl.nextSceneButton.txt.isVisible = false

			-- Меняем бэкграунд

			gl.mainGroup:remove(1)
			gl.mainGroup:insert(1, gl.currentBacks[2])

			-- Плавно
			transition.to(gl.currentBacks[1], {alpha = 0, time = 500})
			gl.currentBacks[2].alpha = 0
			gl.currentBacks[2].isVisible = true
			transition.to(gl.currentBacks[2], {alpha = 1, time = 500})

			local title = display.newImageRect("images/iphone/dubstep.png",182*gl.sizeCoef, 30*gl.sizeCoef)
			title:setReferencePoint(display.TopLeftReferencePoint)
			title.x, title.y = 300 * gl.coefW + display.screenOriginX, 148 * gl.coefH + display.screenOriginY
			gl.mainGroup:insert(2, title)

			timer.performWithDelay(600, function()
				--gl.currentBacks[1].isVisible = false
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
			gl.voicesBack1.isVisible = false
			gl.voicesBack2.isVisible = false
			gl.glitchTxt.isVisible = false
			--gl.glitchTxtShadow.isVisible = false
			--gl.timerTxtShadow.isVisible = false
			--gl.nextSceneTimerTxtShadow.isVisible = false
			gl.sceneNumberShadow.isVisible = false
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
		
		-- Добавляем трек в список глитча
		
			local flag = 0
			for i, b in pairs(gl.configInterface.glitchButtons) do
				if b.button and b.button[2].isVisible ~= false then
					if b.button.activeChannels then
						for idx, val in pairs(b.button.soundIds) do
							if trackInfo.id == val then
								table.insert(b.button.activeChannels, {ch = trackInfo.channel, v = trackInfo.defaultVolume} )
								flag = 1
								recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "addSoundGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
								break
							end
						end
						if flag == 1 then
							break
						end
					end
					break
				end
			end
		
		--button.alpha = 1
	elseif button.pressed == 1 then
		button.pressed = 0
		local flag = 0
		-- Удаляем трек из списка глитча
		for i, v in pairs(gl.configInterface.glitchButtons) do
			if v.button then
				if v.button.activeChannels then
					for idx, val in pairs(v.button.activeChannels) do
						if trackInfo.channel == val.ch then
							v.button.activeChannels[idx] = nil
							recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "removeSoundGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
							flag = 1
							break
						end
					end
					if flag == 1 then
						break
					end
				end
			end
		end
		audio.setVolume(0, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", 0, trackInfo.id, -1)
		--button.alpha = 0.5
	elseif button.pressed == 0 then
		button.pressed = 1
		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, -1)
		
		-- Добавляем трек в список глитча
		
			local flag = 0
			for i, b in pairs(gl.configInterface.glitchButtons) do
				if b.button and b.button[2].isVisible ~= false then
					if b.button.activeChannels then
						for idx, val in pairs(b.button.soundIds) do
							if trackInfo.id == val then
								table.insert(b.button.activeChannels, {ch = trackInfo.channel, v = trackInfo.defaultVolume} )
								flag = 1
								recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "addSoundGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
								break
							end
						end
						if flag == 1 then
							break
						end
					end
					break
				end
			end
		
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
				trackInfo.channel = nil
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
				trackInfo.channel = nil
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
				-- Удаляем трек из списка глитча
				for i, v in pairs(gl.configInterface.glitchButtons) do
					if v.button then
						if v.button.activeChannels then
							for idx, val in pairs(v.button.activeChannels) do
								if trackInfo.channel == val.ch then
									v.button.activeChannels[idx] = nil
									recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "removeVoiceGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
									flag = 1
									break
								end
							end
							if flag == 1 then
								break
							end
						end
					end
				end
				playingVoicesFxs[trackInfo.id] = nil
				trackInfo.channel = nil
			end
				
		end})

		-- Добавляем трек в список глитча
		
			local flag = 0
			for i, b in pairs(gl.configInterface.glitchButtons) do
				if b.button and b.button[2].isVisible ~= false then
					if b.button.activeChannels then
						for idx, val in pairs(b.button.soundIds) do
							if trackInfo.id == val then
								table.insert(b.button.activeChannels, {ch = trackInfo.channel, v = trackInfo.defaultVolume} )
								flag = 1
								recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "addVoiceGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
								break
							end
						end
						if flag == 1 then
							break
						end
					end
					break
				end
			end
		
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "start", trackInfo.defaultVolume, trackInfo.id, 0)

		audio.setVolume(trackInfo.defaultVolume, {channel = trackInfo.channel})
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "chVolume", trackInfo.defaultVolume, trackInfo.id, 0)
		

		
	else
			button.pressed = 1
			if playingVoicesFxs[trackInfo.id] then
				
				audio.stop(trackInfo.channel)
				-- Удаляем трек из списка глитча
				for i, v in pairs(gl.configInterface.glitchButtons) do
					if v.button then
						if v.button.activeChannels then
							for idx, val in pairs(v.button.activeChannels) do
								if trackInfo.channel == val.ch then
									v.button.activeChannels[idx] = nil
									recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "removeVoiceGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
									flag = 1
									break
								end
							end
							if flag == 1 then
								break
							end
						end
					end
				end
				playingVoicesFxs[trackInfo.id] = nil
				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "stop", 0, trackInfo.id, -1)
			end
			
			local ch = audio.findFreeChannel(13)
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
					-- Удаляем трек из списка глитча
					for i, v in pairs(gl.configInterface.glitchButtons) do
						if v.button then
							if v.button.activeChannels then
								for idx, val in pairs(v.button.activeChannels) do
									if trackInfo.channel == val.ch then
										v.button.activeChannels[idx] = nil
										recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "removeVoiceGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
										flag = 1
										break
									end
								end
								if flag == 1 then
									break
								end
							end
						end
					end
					playingVoicesFxs[trackInfo.id] = nil
					trackInfo.channel = nil
					
				end
				
					
			end})
			
			-- Добавляем трек в список глитча
		
			local flag = 0
			for i, b in pairs(gl.configInterface.glitchButtons) do
				if b.button and b.button[2].isVisible ~= false then
					if b.button.activeChannels then
						for idx, val in pairs(b.button.soundIds) do
							if trackInfo.id == val then
								table.insert(b.button.activeChannels, {ch = trackInfo.channel, v = trackInfo.defaultVolume} )
								flag = 1
								recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), trackInfo.channel, "addVoiceGlitchChannel", trackInfo.defaultVolume, trackInfo.id, -1)
								break
							end
						end
						if flag == 1 then
							break
						end
					end
					break
				end
			end

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
	local btn = button
	local function runtimeGlitchHandler(event)
		if btn[2].isVisible == false then
			Runtime:removeEventListener("enterFrame", runtimeGlitchHandlers[btn.id])
			
			
			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "stopGlitch", 0, btn.id, 0, btn.activeChannels)

			for idx,val in pairs(btn.activeChannels) do
	   			audio.setVolume(val.v,{channel = val.ch})
			end
			runtimeGlitchHandlers[btn.id] = nil
			btn.activeChannels = {}
			
			return 0
		end
 			for idx,val in pairs(btn.activeChannels) do
				
					local volume = val.v * 0.5 * (1.0 + math.cos(6.28*deltaSumm/180.0) )
					audio.setVolume(volume,{channel = val.ch})
				
			end

 			if (curMeasure > prevMeasure) then
				delta = curMeasure - prevMeasure
				prevMeasure = curMeasure
				deltaSumm = deltaSumm + delta
			end
 			
 			curMeasure = system.getTimer()
 			
 			glitchLocalTime = glitchLocalTime + delta
 		
 		-- DEBUG 
 		--gl.glIndicator.isVisible = not gl.glIndicator.isVisible
 		-----
	end
	prevMeasure = system.getTimer()
	return runtimeGlitchHandler
end



function playGlitch(event)
 	
	if (event.phase == "press") then

		-- Если по какой-то причине оставался не удаленный глитч на текущей кнопке, то удаляем его
		if runtimeGlitchHandlers[event.target.id] then
			Runtime:removeEventListener("enterFrame", runtimeGlitchHandlers[event.target.id])
			runtimeGlitchHandlers[event.target.id] = nil

			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "stopGlitch", 0, event.target.id, 0, event.target.activeChannels)
			
			for idx,val in pairs(event.target.activeChannels) do
	   			audio.setVolume(val.v,{channel = val.ch})
			end
			event.target.activeChannels = {}
			
		end

		local activeChannels = {}
 			for i, v in pairs(event.target.soundIds) do
 				if  gl.soundsConfig[v].channel and audio.isChannelActive( gl.soundsConfig[v].channel ) then
 					local vol = audio.getVolume({channel = gl.soundsConfig[v].channel})
 					if vol > 0 then
 						activeChannels[#activeChannels + 1] = {ch = gl.soundsConfig[v].channel, v = vol}
 					end
 				end
 			end
 		event.target.activeChannels = activeChannels
		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "startGlitch", 0, event.target.id, 0, event.target.activeChannels)
		
		local glitchHandler = makeGlitchFunc(event.target)
		runtimeGlitchHandlers[event.target.id] = glitchHandler
		Runtime:addEventListener("enterFrame",runtimeGlitchHandlers[event.target.id])
		
		
	
	
	elseif event.phase == "release" then
		if runtimeGlitchHandlers[event.target.id] then
			Runtime:removeEventListener("enterFrame", runtimeGlitchHandlers[event.target.id])
			runtimeGlitchHandlers[event.target.id] = nil

			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime(), 0, "stopGlitch", 0, event.target.id, 0, event.target.activeChannels)
			
			for idx,val in pairs(event.target.activeChannels) do
	   			audio.setVolume(val.v,{channel = val.ch})
			end
			event.target.activeChannels = {}
			
		end

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
					v.sound = audio.loadSound(kitAddress..v.side.."/"..v.name)--, {bufferSize=32768, maxQueueBuffers=20, startupBuffers=4, buffersQueuedPerUpdate=2})
				elseif not v.side then
					v.sound = audio.loadSound(kitAddress..v.name)--, {bufferSize=32768, maxQueueBuffers=20, startupBuffers=4, buffersQueuedPerUpdate=2})
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

