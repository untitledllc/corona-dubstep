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

function prepareToPlay(sampleKit,playParams,numSamples,numFX,numVoices)
	gl.currentKit = sampleKit
		
	partSumms = {}
	local idx = 1
	local summ = 0
		
	
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

function playMelody(group,index,trackCounters)
	local startStop = nil
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
        
        startStop = 0
        
        activeChannels[index] = {-1}
    else
    	local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    
		if (volumePanel.scrolls[2] ~= nil) then	
        	audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[2]),{channel = index})  	
    	else	
    		audio.setVolume(defaultVolume,{channel = index})  
        end 
           
        group[index].alpha = 1
        
    	activeChannel.channel = index
    	activeChannel.startTime = 0
    	activeChannel.category = 2
    	activeChannel.volume = audio.getVolume({channel = index})
    	activeChannels[index] = activeChannel
    	
    	startStop = 1
    end
    
    if (recording.isRecStarted() == true) then
    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
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

function playFX(group,kit,index, isVoice)
	local function closeActiveChannel(event)
    	activeChannels[index] = {-1}
    	
    	if (recording.isRecStarted() == true) then
    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,0,audio.getVolume({channel = index}),4,0)
   		end
   		if curLayout.trackCounters[index] then
			curLayout.trackCounters[index] = 0
		end
    end
    
    if group.numChildren ~= nil and index <= group.numChildren then
		if group[index].tween then
			--transition.cancel(group[index].tween )
		end
	end
	if (curLayout.trackCounters[index] and curLayout.trackCounters[index] % 2 ~= 0) then
		if (audio.isChannelPlaying(index)) then
			if (fxTimer) then
				--timer.cancel(fxTimer)
			end
			--closeActiveChannel(nil)
		end
		audio.setVolume(0, {channel = index})
		--if group.numChildren ~= nil and index <= group.numChildren then
		--	group[index].alpha = 0.5
		--end
		if (recording.isRecStarted() == true) then
    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
   		end
	elseif curLayout.trackCounters[index] then
		if (curLayout.trackCounters[index] and curLayout.trackCounters[index] == 0) then
    		audio.play(kit[index][1],{channel = index, loop = 0})
    		if isVoice then

    			audio.setVolume(1, {channel = index})
    		else

    			audio.setVolume(defaultVolume, {channel = index})
    		end
    		if (recording.isRecStarted() == true) then
	    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    								index,1,audio.getVolume({channel = index}),4,0)
	   		end
	   		if group.numChildren ~= nil and index <= group.numChildren then
	    		group[index].alpha = 1
	    		group[index].tween = transition.to(group[index],{time = audio.getDuration(kit[index][1]),alpha = 0.5})
	    	end
	    	local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
		    activeChannel.channel = index
		    activeChannel.startTime = system.getTimer() - curLayout.getLayoutAppearTime()
		    activeChannel.category = 4
		    activeChannel.volume = audio.getVolume({channel = index})
		    activeChannels[index] = activeChannel
		     
		    
		   	
		    fxTimer = timer.performWithDelay(audio.getDuration(kit[index][1]),closeActiveChannel)
    	elseif (curLayout.trackCounters[index] and curLayout.trackCounters[index] ~= 0) then
    		if (volumePanel.scrolls[4] ~= nil) then	
        			audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[4]),{channel = index})  	
    			else	
    				audio.setVolume(defaultVolume,{channel = index})  
   			end 
   			if (recording.isRecStarted() == true) then
    			recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    								index,startStop,audio.getVolume({channel = index}),2,system.getTimer() - curLayout.getLayoutAppearTime())
   			end
   		end
	else
		audio.play(kit[index][1],{channel = index, loop = 0})
		if isVoice then
			audio.setVolume(1, {channel = index})
			print("play!")
		else
			audio.setVolume(defaultVolume, {channel = index})
		end
		
    	if (recording.isRecStarted() == true) then
	    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    							index,1,audio.getVolume({channel = index}),4,0)
	   	end
	    local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
		activeChannel.channel = index
	    activeChannel.startTime = system.getTimer() - curLayout.getLayoutAppearTime()
	    activeChannel.category = 4
	    activeChannel.volume = audio.getVolume({channel = index})
	    activeChannels[index] = activeChannel
		fxTimer = timer.performWithDelay(audio.getDuration(kit[index][1]),closeActiveChannel)
	end
	if curLayout.trackCounters[index] then
		curLayout.trackCounters[index] = curLayout.trackCounters[index] + 1
	end
end

function oldPlayFx(group,kit,index)
	local function closeActiveChannel(event)
    	activeChannels[index] = {-1}
    	
    	if (recording.isRecStarted() == true) then
    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,0,audio.getVolume({channel = index}),4,0)
   		end
    end
    
    if group.numChildren ~= nil and index <= group.numChildren then
		if group[index].tween then
			transition.cancel(group[index].tween )
		end
	end
	if (curLayout.trackCounters[index] and curLayout.trackCounters[index] % 2 ~= 0) then
		if (audio.isChannelPlaying(index)) then
			if (fxTimer) then
				timer.cancel(fxTimer)
			end
			closeActiveChannel(nil)
		end
		audio.stop(index)
		if group.numChildren ~= nil and index <= group.numChildren then
			group[index].alpha = 0.5
		end
	else

    	audio.play(kit[index][1],{channel = index})
    
    	if (volumePanel.scrolls[4] ~= nil) then	
        		audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[4]),{channel = index})  	
    		else	
    			audio.setVolume(0.8,{channel = index})
   		end 
    	
	    if group.numChildren ~= nil and index <= group.numChildren and currentLayout == "layout1" then
	    	group[index].alpha = 1
	    	group[index].tween = transition.to(group[index],{time = audio.getDuration(kit[index][1]),alpha = 0.5})
	    end
    
	    local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
	    activeChannel.channel = index
	    activeChannel.startTime = system.getTimer() - curLayout.getLayoutAppearTime()
	    activeChannel.category = 4
	    activeChannel.volume = audio.getVolume({channel = index})
	    activeChannels[index] = activeChannel
	     
	    if (recording.isRecStarted() == true) then
	    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
	    							index,1,audio.getVolume({channel = index}),4,0)
	   	end
	   	
	    fxTimer = timer.performWithDelay(audio.getDuration(kit[index][1]),closeActiveChannel)
	end
	if curLayout.trackCounters[index] then
		curLayout.trackCounters[index] = curLayout.trackCounters[index] + 1
	end
end

function playVoice(group,kit,index)
	local function closeActiveChannel(event)
    	activeChannels[index] = {-1}
    	
    	if (recording.isRecStarted() == true) then
    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,0,audio.getVolume({channel = index}),5,0)
   		end
    end
    
	if (audio.isChannelPlaying(index)) then
		if (voiceTimer) then
			timer.cancel(voiceTimer)
		end
		closeActiveChannel(nil)
	end
	
	audio.stop(index)
    audio.play(kit[index][1],{channel = index})
    
    if (volumePanel.scrolls[5] ~= nil) then	
        	audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[5]),{channel = index})  	
    	else	
    		audio.setVolume(defaultVolume,{channel = index})  
    end 
    
    group[index].alpha = 1
    transition.to(group[index],{time = audio.getDuration(kit[index][1]),alpha = 0.5})
    
    local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    
    activeChannel.channel = index
    activeChannel.startTime = system.getTimer() - curLayout.getLayoutAppearTime()
    activeChannel.category = 5
    activeChannel.volume = audio.getVolume({channel = index})
    activeChannels[index] = activeChannel  
    
    if (recording.isRecStarted() == true) then
    	recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,1,audio.getVolume({channel = index}),5,0)
   	end
    
    voiceTimer = timer.performWithDelay(audio.getDuration(kit[index][1]),closeActiveChannel)
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
	
 	local function runtimeGlitchHandler(e)
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
 		end
 	end
	
	if (event.phase == "began") then
		isGlitchStarted = true
		activeChannels = {}
 			for i = 1, 12 do
 				if audio.isChannelActive( i ) then
 					local vol = audio.getVolume({channel = i})
 					if vol > 0 then
 						activeChannels[#activeChannels + 1] = {ch = i, v = vol}
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

function playGlitchVoices(event)
	local tiks = 0
 	local glitchStartTime = nil
 	local glitchFinishTime = nil
	local prevMeasure = 0
	local curMeasure = 0
	local delta = 0
	local glitchLocalTime = 0
	local deltaSumm = 0
	local activeChannelsCopy = {}
	
 	local function runtimeGlitchHandlerV(e)
 		if (isGlitchStartedV == true) then
 			
 			
 			if (deltaSumm > gl.glitchShutUpTime) then
 				event.target.alpha = 1
 				for idx,val in pairs(activeChannelsV) do
					--if (val.channel ~= nil and val.channel > partSumms[3]) then
						audio.setVolume(0,{channel = val.ch})
					--end
				end
 			end

 			if (deltaSumm > gl.glitchShutUpTime + gl.glitchPlayTime) then
 				event.target.alpha = 0.5
 				for idx,val in pairs(activeChannelsV) do
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
 		end
 	end
	
	if (event.phase == "began") then
		isGlitchStartedV = true
		activeChannelsV = {}
 			for i = 14, 32 do
 				if audio.isChannelActive( i ) then
 					local vol = audio.getVolume({channel = i})
 					if vol > 0 then
 						activeChannelsV[#activeChannelsV + 1] = {ch = i, v = vol}
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
		
		Runtime:addEventListener("enterFrame",runtimeGlitchHandlerV)
		display.getCurrentStage():setFocus(event.target, event.id)
	end
	
	if (event.phase == "ended" or (event.phase == "moved"  and 
		( event.x < (event.target.x - event.target.x/2) or event.x > (event.target.x + event.target.x/2) or event.y < (event.target.y - event.target.y/2) or event.y > (event.target.y + event.target.y/2) ) ) ) then
		
		Runtime:removeEventListener("enterFrame",runtimeGlitchHandlerV)
		event.target.alpha = 0.5
		isGlitchStartedV = false
		
		if (recording.isRecStarted()) then
			glitchFinishTime = system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime()
			recording.addAction(glitchFinishTime,gl.glitchChannel,0,0,6,0)
		end
		
		--activeChannels.glitchChannel = {-1}

		for idx,val in pairs(activeChannelsV) do
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
		for i = 1, 17 do
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
			for i = 1, 17 do
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
		for i = 1, 17 do
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
			for i = 1, 17 do
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

function playBasicMelody() 
	idx = 1
	while (idx <= 1) do
		audio.play(gl.sampleKit[idx][1],{channel = idx,loops = -1})
		audio.setVolume(0,{channel = idx})
		idx = idx + 1
	end
	playFX(gl.localGroup, gl.sampleKit, 2)
	
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

	for i, v in pairs(soundsConfig) do
		local track = {}
		v.sound = audio.loadSound(kitAddress..v.name)
		v.channel = i
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

