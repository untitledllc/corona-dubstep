module(...,package.seeall)

local gl = require("globals") 
local recording = require("recording")
local volumePanel = require("volumeRegulator")
local curLayout = require(gl.currentLayout)
local numSampleTypes = 5

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
		
	while (idx <= numSampleTypes) do
		partSumms[idx] = summ + playParams[numSampleTypes+idx]
		summ = summ + playParams[numSampleTypes+idx]
		idx = idx + 1
	end 	
		
	idx = 1
	while (idx <= numSamples) do
		audio.play(sampleKit[idx][1],{channel = idx,loops = -1})
		audio.setVolume(0,{channel = idx})
		idx = idx + 1
	end
		
	idx = 1
	while (idx <= numSamples + numFX + numVoices) do
		activeChannels[idx] = {-1}
		idx = idx + 1
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
    							idx,0,audio.getVolume({channel = index}),5,-1)
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
										idx,0,audio.getVolume({channel = index}),3,-1)
   			end
			
			idx = idx + 1
		end
	end
end

local function shutUpMelodies(group,isShut,partSumms,trackCounters)
	if (isShut == true) then
		local idx = partSumms[1] + 1
		while (idx <= partSumms[2]) do		
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
										idx,0,audio.getVolume({channel = index}),2,-1)
   			end
			
			idx = idx + 1
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
										idx,0,audio.getVolume({channel = index}),1,-1)
   			end
   			
			idx = idx + 1
		end
	end
end

local function shutUpFX(group,isShut,numSamples,numFX,numVoices)
	if (isShut == true) then
		local idx = numSamples + 1
		while (idx <= numSamples + numVoices) do
			group[idx].alpha = 0.5
			audio.stop(idx)
			
			if (recording.isRecStarted() == true) then
    			if (recording.isRecStarted() == true) then
    				recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							idx,0,audio.getVolume({channel = index}),4,-1)
   				end
   			end
			
			idx = idx + 1
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
    		audio.setVolume(0.5,{channel = index})  
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

local function playMelody(group,index,trackCounters)
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
    		audio.setVolume(0.5,{channel = index})  
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
    		audio.setVolume(0.5,{channel = index})  
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

local function playFX(group,kit,index)   
	local function closeActiveChannel(event)
    	activeChannels[index] = {-1}
    	
    	if (recording.isRecStarted() == true) then
    		recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    							index,0,audio.getVolume({channel = index}),4,0)
   		end
    end
    
	if (audio.isChannelPlaying(index)) then
		if (fxTimer) then
			timer.cancel(fxTimer)
		end
		closeActiveChannel(nil)
	end
	
	audio.stop(index)
    audio.play(kit[index][1],{channel = index})
    
    if (volumePanel.scrolls[4] ~= nil) then	
        	audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[4]),{channel = index})  	
    	else	
    		audio.setVolume(0.5,{channel = index})  
    end 
    
    group[index].alpha = 1
    transition.to(group[index],{time = audio.getDuration(kit[index][1]),alpha = 0.5})
    
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

local function playVoice(group,kit,index)
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
    		audio.setVolume(0.5,{channel = index})  
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
	
 	local function runtimeGlitchHandler(e)
 		if (isGlitchStarted == true) then
 		
 			if (deltaSumm > gl.glitchShutUpTime) then
 				event.target.alpha = 1
 				for idx,val in pairs(activeChannels) do
					if (val.channel ~= nil and val.channel > partSumms[3]) then
						audio.setVolume(val.channel,{channel = val.channel})	
					end
				end	
 			end 			 
 			
 			if (deltaSumm > gl.glitchShutUpTime + gl.glitchPlayTime) then
 				event.target.alpha = 0.5
 				for idx,val in pairs(activeChannels) do
					if (val.channel ~= nil and val.channel > partSumms[3]) then
						audio.setVolume(0,{channel = val.channel})
					end
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
		
		prevMeasure = system.getTimer()
		curMeasure = 0
		
		local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    	activeChannel.channel = gl.glitchChannel
    	activeChannel.startTime = system.getTimer() - curLayout.getLayoutAppearTime()
    	activeChannel.category = 6
    	activeChannel.volume = 0
   		activeChannels.glitchChannel = activeChannel
   		
		if (recording.isRecStarted()) then
			glitchStartTime = system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime()
			recording.addAction(glitchStartTime,gl.glitchChannel,1,0,6,0)
		else
			glitchStartTime = 0
		end
		
		Runtime:addEventListener("enterFrame",runtimeGlitchHandler)
	end
	
	if (event.phase == "ended") then
		event.target.alpha = 0.5
		isGlitchStarted = false
		
		if (recording.isRecStarted()) then
			glitchFinishTime = system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime()
			recording.addAction(glitchFinishTime,gl.glitchChannel,0,0,6,0)
		end
		
		activeChannels.glitchChannel = {-1}
		
		for idx,val in pairs(activeChannels) do
			if (val.channel ~= nil and val.channel > partSumms[3]) then
			
				if (val.channel > partSumms[3] and val.channel <= partSumms[4]) then
				
					if (volumePanel.scrolls[4] ~= nil) then	
        				audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[4]),{channel = val.channel})  	
    				else	
    					audio.setVolume(0.5,{channel = val.channel})  
   					end
   					
   				end
   				
   				if (val.channel > partSumms[4] and val.channel <= partSumms[5]) then
   				
   					if (volumePanel.scrolls[5] ~= nil) then	
        				audio.setVolume(volumePanel.getVolume(volumePanel.scrolls[5]),{channel = val.channel})  	
    				else	
    					audio.setVolume(0.5,{channel = val.channel})  
   					end
   					
   				end
   				
				if (recording.isRecStarted()) then
					recording.addAction(system.getTimer() - curLayout.getLayoutAppearTime() - recording.getRecBeginTime(),
    						val.channel,2,val.volume,val.category,system.getTimer() - curLayout.getLayoutAppearTime())
				end
				
			end
		end
		
		Runtime:removeEventListener("enterFrame",runtimeGlitchHandler)
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

function initSounds(kitAddress,numSamples,numFX,numVoices)
	local i = 1
	local str
	local track = {sound = nil,name = nil,startTime = nil}
	local tracks = {}
	while (i <= numSamples + numVoices + numFX) do
		str = kitAddress.."Track"..tostring(i)..".mp3"
		track[1] = audio.loadSound(str)
		track[2] = str
		tracks[i] = track
		track = {}
		i = i + 1
	end
	return tracks
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

