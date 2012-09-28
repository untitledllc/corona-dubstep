module(...,package.seeall)

local gl = require("globals") 
local recording = require("recording")
local curLayout = require(gl.currentLayout)
local numSampleTypes = 5

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
	for i = 1, gl.scenesNum, 1 do
		gl.buttonsInScenes[i] = {}
	end

	-- Заполняем таблицу, в которой номеру сцены соответствует кнопка и информация о том, нажата она или нет
	for i = 1, gl.mainGroup[2].numChildren, 1 do
		if gl.mainGroup[2][i].scenes then
			for j, v in pairs(gl.mainGroup[2][i].scenes) do
				table.insert(gl.buttonsInScenes[tonumber(j)], {gl.mainGroup[2][i], v})
			end
		end
	end

	-- Делаем видимыми кнопки первой сцены
	for i, v in pairs(gl.buttonsInScenes[1]) do
		v[1].isVisible = true
		v[1].txt.isVisible = true
	end

	-- запускаем все мелодии на воспроизведение
	for i, v in pairs(gl.soundsConfig) do
		if v.type == "melody" then
			audio.play(v.sound, {channel = v.channel, loops = -1})
			audio.setVolume(0, {channel = v.channel})
		end
	end

	-- Нажимаем те кнопки, которые нажаты по умолчанию на первой сцене
	for i, v in pairs(gl.buttonsInScenes[1]) do
		if v[2] == true then
			v[1]:dispatchEvent({name = "touch", phase = "ended"})
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
		if v[1] == b then
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
	audio.setVolume(0, {channel = b.channel})
	if b.type == "melody" then

	elseif b.type == "fx" then

	elseif b.type == "voice" then

	end
end

function nextScene(event)
	if event.phase == "ended" then
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
				if not ifButtonInScene(v[1], gl.currentScene) then
					v[1].isVisible = false
					v[1].txt.isVisible = false
					-- Если кнопка нажата, то "отжимаем"
					if v[1].pressed and v[1].pressed ~= 0 then
						unpressButton(v[1])
					end
				end
			end

			-- Показываем кнопки новой сцены
			for i, v in pairs(gl.buttonsInScenes[gl.currentScene]) do
				v[1].isVisible = true
				v[1].txt.isVisible = true
			end

			-- Нажимаем ненажатые кнопки новой сцены, если они должны быть нажаты
			for i, v in pairs(gl.buttonsInScenes[gl.currentScene]) do
				if v[2] == true and (not v[1].pressed  or v[1].pressed == 0) then
					v[1]:dispatchEvent({name = "touch", phase = "ended"})
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

			-- Снимаем обработчик перехода между сценами
			gl.nextSceneButton:removeEventListener("touch", nextScene)

			-- Кнопка шаринга
			gl.shareBtn.isVisible = true
			gl.shareBtn.txt.isVisible = true
		end
	end
end

local function shutUpVoices(group,isShut,numSamples,numFX,numVoices)
	if (isShut == true) then
		local idx = numSamples + numFX + 1
		while (idx <= numSamples + numVoices) do
			group[idx].alpha = 0.5
			
			audio.stop(idx)
			
			if (recording.isRecStarted() == true) then
      			if (recording.isRecStarted() == true) then
    				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							idx,0,audio.getVolume({channel = idx}),5,-1)
   				end
   			end
			
			idx = idx + 1
		end
	end
end

local function shutUpDrums(group,isShut,partSumms,trackCounters)
	if (isShut == true) then
		local idx = partSumms[2] + 1
		while (idx <= partSumms[3]) do		
			group[idx].alpha = 0.5
			
			local channelVolume = audio.getVolume( { channel=idx } )
			if (channelVolume ~= 0) then
				trackCounters[idx] = 1
			else
				trackCounters[idx] = 0
			end
			audio.setVolume(0,{channel = idx})
			activeChannels[idx] = {-1}
			
			if (recording.isRecStarted() == true) then
				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
										idx,0,audio.getVolume({channel = idx}),3,-1)
   			end
			
			idx = idx + 1
		end
	end
end

function shutUpMelodies(group,isShut,partSumms,trackCounters)
	if (isShut == true) then
		local MelodiesIdxs = {1, 3, 4, 6, 7, 11, 12, 14, 15}
		for i, idx in pairs(MelodiesIdxs) do
			group[idx].alpha = 0.5
			
			local channelVolume = audio.getVolume( { channel=idx } )
			if (channelVolume ~= 0) then
				trackCounters[idx] = 1
			else
				trackCounters[idx] = 0
			end
			audio.setVolume(0,{channel = idx})
			activeChannels[idx] = {-1}
			
			if (recording.isRecStarted() == true) then
				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
										idx,0,audio.getVolume({channel = idx}),2,-1)
   			end
		end
	end
end

local function shutUpIntros(group,isShut,partSumms,trackCounters)	
	if (isShut == true) then
		local idx = 1
		while (idx <= partSumms[1]) do		
			group[idx].alpha = 0.5

			local channelVolume = audio.getVolume( { channel=idx } )
			if (channelVolume ~= 0) then
				trackCounters[idx] = 1
			else
				trackCounters[idx] = 0
			end
			audio.setVolume(0,{channel = idx})
			activeChannels[idx] = {-1}
			
			if (recording.isRecStarted() == true) then
				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
										idx,0,audio.getVolume({channel = idx}),1,-1)
   			end
   			
			idx = idx + 1
		end
	end
end

function shutUpFX(group,isShut,numSamples,numFX,numVoices)
	if (isShut == true) then
		local FXIndxs = {2, 5, 8, 9, 10, 13, 16, 17}
		for i,idx in pairs(FXIndxs) do
			group[idx].alpha = 0.5
			audio.stop(idx)
			
			if (recording.isRecStarted() == true) then
    			if (recording.isRecStarted() == true) then
    				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							idx,0,audio.getVolume({channel = idx}),4,-1)
   				end
   			end
		end
	end
end

local function playIntro(group,index,trackCounters)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
        
        startStop = 0
        
        activeChannels[index] = {-1}
    else
    	local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}  
       	
       	if (volumePanel.scrolls[1] ~= nil) then	
        	audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[1]),{channel = index})  	
    	else	
    		audio.setVolume(defaultVolume,{channel = index})  
        end 
        group[index].alpha = 1
        
        activeChannel.channel = index
    	activeChannel.startTime = 0
    	activeChannel.category = 1
    	activeChannel.volume = audio.getVolume({channel = index})
    	activeChannels[index] = activeChannel
    	
    	startStop = 1
    end
    
    if (recording.isRecStarted() == true) then
    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,startStop,audio.getVolume({channel = index}),1,system.getTimer() - curLayout.getLayoutAppearTime())
   	end
   	
    trackCounters[index] = trackCounters[index] + 1
end

local function playDrums(group,index,trackCounters)
	local startStop = nil
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
        
        startStop = 0
        
        activeChannels[index] = {-1}
    else
    	local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
     
       	if (volumePanel.scrolls[3] ~= nil) then	
        	audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[3]),{channel = index})  	
    	else	
    		audio.setVolume(defaultVolume,{channel = index})  
        end    
        group[index].alpha = 1
        
        activeChannel.channel = index
    	activeChannel.startTime = 0
    	activeChannel.category = 3
    	activeChannel.volume = audio.getVolume({channel = index})
    	activeChannels[index] = activeChannel
   		startStop = 1
    end
    
    if (recording.isRecStarted() == true) then
    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,startStop,audio.getVolume({channel = index}),3,system.getTimer() - curLayout.getLayoutAppearTime())
   	end
   	
    trackCounters[index] = trackCounters[index] + 1
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
	
 	function runtimeGlitchHandler(e)
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
 				if audio.isChannelActive( gl.soundsConfig[v].channel ) then
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
			glitchStartTime = system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime()
			recording.addAction(glitchStartTime,gl.glitchChannel,1,0,6,0)
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
			glitchFinishTime = system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime()
			recording.addAction(glitchFinishTime,gl.glitchChannel,0,0,6,0)
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
						recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    						val.ch,2,val.v,5,system.getTimer() - curLayout.getLayoutAppearTime())
					else
						recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    						val.ch,2,val.v,2,system.getTimer() - curLayout.getLayoutAppearTime())
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

function playGoodMelody(event)
	if gl.currentLayout == "layout1" then
		gl.goodBtn.isVisible = false
		gl.evilBtn.isVisible = false
		gl.goodBtn.txt.isVisible = false
		gl.evilBtn.txt.isVisible = false
		gl.currentBasicMelody = gl.currentGoodMelody

		gl.unbindButtonsListeners()

		local volumes = {}
		for i = 1, 32 do
			print("zdes")
			volumes[i] = audio.getVolume({ channel = i })
			audio.setVolume(0, {channel = i})						
			recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							i,
								1,0,2,0)
		end

		for i, v in pairs(recording.timers) do
			timer.pause(v)
		end

		playFX(gl.localGroup,gl.currentKit,toGoodEvilFXChannel)
		
		
		timer.performWithDelay(1600, function()
			for i = 1, 32 do
				audio.setVolume(volumes[i], {channel = i})						
				recording.addAction(system.getTimer() - 
						curLayout.getLayoutAppearTime(),
								i,
									1,volumes[i],2,0)
			end
			for i, v in pairs(recording.timers) do
				timer.resume(v)
			end
			gl.bindButtonsListeners()
			if recording.currentScene - 1 > 0 then
				gl.localGroup[gl.localGroup.numChildren - 1]:addEventListener("touch", recording.goToScene[recording.currentScene - 1])
			end
			if recording.currentScene + 1 < 7 then
				gl.localGroup[gl.localGroup.numChildren]:addEventListener("touch", recording.goToScene[recording.currentScene + 1])
			end

			audio.setVolume(0, {channel = currentGoodChannel})
												
			recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							currentGoodChannel,
								1,0,2,0)
		end)
		

		--[[recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							currentBasicChannel,
								0,0,2,0)
		
		audio.setVolume(0,{channel = currentBasicChannel})	]]--	
	else
		gl.goodBtn.isVisible = false
		gl.evilBtn.isVisible = false
		gl.goodBtn.txt.isVisible = false
		gl.evilBtn.txt.isVisible = false
		gl.currentBasicMelody = gl.currentEvilMelody
	end
end

function playEvilMelody(event)
	if gl.currentLayout == "layout1" then
		gl.goodBtn.isVisible = false
		gl.evilBtn.isVisible = false
		gl.goodBtn.txt.isVisible = false
		gl.evilBtn.txt.isVisible = false
		gl.currentBasicMelody = gl.currentEvilMelody
		local volumes = {}
		for i = 1, 32 do
			print("zdes")
			volumes[i] = audio.getVolume({ channel = i })
			audio.setVolume(0, {channel = i})						
			recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							i,
								1,0,2,0)
		end

		for i, v in pairs(recording.timers) do
			timer.pause(v)
		end

		playFX(gl.localGroup,gl.currentKit,toGoodEvilFXChannel)	
		
		timer.performWithDelay(1600, function()
			for i = 1, 32 do
				audio.setVolume(volumes[i], {channel = i})						
				recording.addAction(system.getTimer() - 
						curLayout.getLayoutAppearTime(),
								i,
									1,volumes[i],2,0)
			end
			for i, v in pairs(recording.timers) do
				timer.resume(v)
			end

		end)
		

		--[[recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							currentBasicChannel,
								0,0,2,0)
		
		audio.setVolume(0,{channel = currentBasicChannel})	]]--																
		audio.setVolume(0, {channel = currentEvilChannel})
												
		recording.addAction(system.getTimer() - 
					curLayout.getLayoutAppearTime(),
							currentEvilChannel,
								1,0,2,0)
	else
		gl.goodBtn.isVisible = false
		gl.evilBtn.isVisible = false
		gl.goodBtn.txt.isVisible = false
		gl.evilBtn.txt.isVisible = false
		gl.currentBasicMelody = gl.currentEvilMelody
	end
	
end

function playBasicMelody2()
	audio.play(gl.currentBasicMelody2,{channel = gl.currentBasicChannel2,loops = -1})
	audio.setVolume(defaultVolume,{channel = gl.currentBasicChannel2})
	recording.addAction(0,currentBasicChannel2,1,defaultVolume,2,0)

	audio.play(gl.sampleKit[7][1],{channel = 7,loops = -1})
	audio.setVolume(0,{channel = 7})
	recording.addAction(0,7,1,0,2,0)

	audio.play(gl.sampleKit[8][1],{channel = 8,loops = -1})
	audio.setVolume(0,{channel = 8})
	recording.addAction(0,8,1,0,2,0)

	audio.play(gl.sampleKit[12][1],{channel = 12,loops = -1})
	audio.setVolume(0,{channel = 12})
	recording.addAction(0,12,1,0,2,0)

	--curLayout.trackCounters[1] = curLayout.trackCounters[1] + 1
	curLayout.trackCounters[2] = curLayout.trackCounters[2] + 1

	--[[ DEBUG

	for i = 5, 12, 1 do
		audio.play(gl.sampleKit[i][1],{channel = i,loops = -1})
		audio.setVolume(0,{channel = i})

		gl.localGroup[i].isVisible = true
		gl.localGroup[i].txt.isVisible = true

		recording.addAction(0,i,1,0,2,0)
		recording.addAction(0,i,1,0,2,0)
	end
	]]--
end

function initSounds(kitAddress)
	local soundsConfig = gl.jsonModule.decode( gl.readFile("configSounds.json", kitAddress))

	local channelCounter = 1
	for i, v in pairs(soundsConfig) do
		v.sound = audio.loadSound(kitAddress..v.name)
		v.channel = channelCounter
		channelCounter = channelCounter + 1
	end
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

