module(...,package.seeall)

firstTimePlayPressed = nil

local numSampleTypes = 5

local partSumms = {}

local activeChannels = {}

local function shutUpVoices(group,isShut,numSamples,numFX,numVoices)
	if (isShut == true) then
		local idx = numSamples + numFX + 1
		while (idx <= numSamples + numVoices) do
			group[idx].alpha = 0.5
			audio.stop(idx)
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
			idx = idx + 1
		end
	end
end

local function playIntro(group,index,trackCounters)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
        
        activeChannels[index] = {-1}
    else
    	local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    	
       	audio.setVolume(1,{channel = index})    
        group[index].alpha = 1
        
        activeChannel.channel = index
    	activeChannel.startTime = system.getTimer() - firstTimePlayPressed
    	activeChannel.category = 1
    	activeChannel.volume = audio.getVolume({channel = index})
    	activeChannels[index] = activeChannel
    end
    trackCounters[index] = trackCounters[index] + 1
end

local function playMelody(group,index,trackCounters)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
        
        activeChannels[index] = {-1}
    else
    	local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    
       	audio.setVolume(1,{channel = index})    
        group[index].alpha = 1
        
    	activeChannel.channel = index
    	activeChannel.startTime = system.getTimer() - firstTimePlayPressed
    	activeChannel.category = 2
    	activeChannel.volume = audio.getVolume({channel = index})
    	activeChannels[index] = activeChannel
    end
    trackCounters[index] = trackCounters[index] + 1
end

local function playDrums(group,index,trackCounters)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
        
        activeChannels[index] = {-1}
    else
    	local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    
       	audio.setVolume(1,{channel = index})    
        group[index].alpha = 1
        
        activeChannel.channel = index
    	activeChannel.startTime = system.getTimer() - firstTimePlayPressed
    	activeChannel.category = 3
    	activeChannel.volume = audio.getVolume({channel = index})
    	activeChannels[index] = activeChannel
    end
    trackCounters[index] = trackCounters[index] + 1
end

local function playVoice(group,kit,index)
	audio.stop(index)
    audio.play(kit[index][1],{channel = index})
    group[index].alpha = 1
    transition.to(group[index],{time = audio.getDuration(kit[index][1]),alpha = 0.5})
    
    local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    activeChannel.channel = index
    activeChannel.startTime = system.getTimer() - firstTimePlayPressed
    activeChannel.category = 4
    activeChannel.volume = audio.getVolume({channel = index})
    activeChannels[index] = activeChannel
    
    local function closeActiveChannel(event)
    	activeChannels[index] = {-1}
    end
    
    timer.performWithDelay(audio.getDuration(kit[index][1]),closeActiveChannel)
end

local function playFX(group,kit,index)
	audio.stop(index)
    audio.play(kit[index][1],{channel = index})
    group[index].alpha = 1
    transition.to(group[index],{time = audio.getDuration(kit[index][1]),alpha = 0.5})
    
    local activeChannel = {["channel"] = nil,["startTime"] = nil,["category"] = nil,["volume"] = nil}
    activeChannel.channel = index
    activeChannel.startTime = system.getTimer() - firstTimePlayPressed
    activeChannel.category = 5
    activeChannel.volume = audio.getVolume({channel = index})
    activeChannels[index] = activeChannel
    
    local function closeActiveChannel(event)
    	activeChannels[index] = {-1}
    end
    
    timer.performWithDelay(audio.getDuration(kit[index][1]),closeActiveChannel)
end

local function playSample(group,kit,trackCounters,index,playParams,numSamples,numFX,numVoices)
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
	
	if (index > partSumms[4]) then
		shutUpVoices(group,playParams[5],numSamples,numFX,numVoices)
		playVoice(group,kit,index)
	end
	
	for idx,val in pairs(activeChannels) do
		for i,v in pairs(val) do
			if (val[1] ~= -1) then
				print(v)
			end
		end
		if (val[1] ~= -1) then
			print("___________________")
		end
	end
	print("\nEND TRACK\n")
end

function play(group,sampleKit,trackCounters,sampleIndex,numSamples,numFX,numVoices,playParams)
	if (firstTimePlayPressed == nil) then
	
		firstTimePlayPressed = system.getTimer()
		
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
	playSample(group,sampleKit,trackCounters,sampleIndex,playParams,numSamples,numFX,numVoices)
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