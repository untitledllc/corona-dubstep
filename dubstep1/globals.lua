module(...,package.seeall)

w = display.contentWidth
h = display.contentHeight

currentLayout = require("layout1")

firstTimePlayPressed = nil

local numSampleTypes = 5

local activeTracks = {} --track = {index,activeTime}

local recording = require("recording")
local volumePanel = require("volumeRegulatorPanel")

function drawLayoutBtns()
	local btns = {}
	local localGroup = display.newGroup()
	btn1 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,10)
	volume = display.newRoundedRect(1,1,w/8,h/8,10)
	recBtn = display.newRoundedRect(1,1,w/8,h/8,10)
	
	loading = display.newText("Loading...", 0, 0, native.systemFont, 32)
	loading.x,loading.y = w/2,h/2
	loading.isVisible = false
	
	btn1.x,btn1.y,btn2.x,btn2.y = w/16,15*h/16,w/4,15*h/16
	btn1:setFillColor(140,255,0)
	btn2:setFillColor(140,255,0)
	btn1.alpha = 0.5
	btn2.alpha = 0.5
	
	volume.x,volume.y = w/16,h/16
	volume.alpha = 0.5
	
	recBtn.x,recBtn.y = 15*w/16,15*h/16
	recBtn:setFillColor(140,255,140)
	recBtn.alpha = 0.5
	
	btn1.scene = "layout1"
	btn2.scene = "layout2"
	recBtn.scene = "recording"
	
	function changeScene(event)
		audio.stop()
		loading.isVisible = true
		if (event.phase == "ended") then
			director:changeScene(event.target.scene)
		end
	end
	
	btn1:addEventListener("touch",changeScene)
	btn2:addEventListener("touch",changeScene)
	volume:addEventListener("touch",volumePanel.showHidePanel)
	recBtn:addEventListener("touch",recording.startRecording)
	
	btns[#btns + 1] = btn1
	btns[#btns + 1] = btn2
	btns[#btns + 1] = recBtn
	return btns
end

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

local function playVoice(group,kit,index)
	audio.stop(index)
	audio.setVolume(0.1,{channel = index})
    audio.play(kit[index][1],{channel = index})
    group[index].alpha = 1
    transition.to(group[index],{time = 2000,alpha = 0.5})
end

local function playIntro(group,index,trackCounters)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
    else
       	audio.setVolume(1,{channel = index})    
        group[index].alpha = 1
    end
    trackCounters[index] = trackCounters[index] + 1
end

local function playMelody(group,index,trackCounters)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
    else
       	audio.setVolume(1,{channel = index})  
        group[index].alpha = 1
    end
    trackCounters[index] = trackCounters[index] + 1
end

local function playDrums(group,index,trackCounters)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
    else
       	audio.setVolume(1,{channel = index})    
        group[index].alpha = 1
    end
    trackCounters[index] = trackCounters[index] + 1
end

local function playFX(group,kit,index)
	audio.stop(index)
    audio.play(kit[index][1],{channel = index})
    group[index].alpha = 1
    transition.to(group[index],{time = 2000,alpha = 0.5})
end

local function playSample(group,kit,trackCounters,index,playParams,numSamples,numFX,numVoices)
	local partSumms = {}
	local idx = 1
	local summ = 0
	while (idx <= numSampleTypes) do
		partSumms[idx] = summ + playParams[numSampleTypes+idx]
		summ = summ + playParams[numSampleTypes+idx]
		idx = idx + 1
	end 
	
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
end

function play(group,sampleKit,trackCounters,sampleIndex,numSamples,numFX,numVoices,playParams)
	if (firstTimePlayPressed == nil) then
		firstTimePlayPressed = system.getTimer()
		local idx = 1
		while (idx <= numSamples) do
			audio.play(sampleKit[idx][1],{channel = idx,loops = -1})
			audio.setVolume(0,{channel = idx})
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