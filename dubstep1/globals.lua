module(...,package.seeall)

w = display.contentWidth
h = display.contentHeight

currentLayout = require("layout1")

function drawLayoutBtns()
	local btns = {}
	btn1 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn1.x,btn1.y,btn2.x,btn2.y = w/16,15*h/16,w/4,15*h/16
	btn1:setFillColor(140,255,0)
	btn2:setFillColor(140,255,0)
	btn1.alpha = 0.5
	btn2.alpha = 0.5
	
	btn1.scene = "layout1"
	btn2.scene = "layout2"
	
	function changeScene(event)
		audio.stop()
		if (event.phase == "ended") then
			director:changeScene(event.target.scene)
		end
	end
	
	btn1:addEventListener("touch",changeScene)
	btn2:addEventListener("touch",changeScene)
	
	btns[#btns + 1] = btn1
	btns[#btns + 1] = btn2
	return btns
end

local firstTimePlayPressed = nil

local function playVoice(group,kit,index)
	audio.stop(index)
    audio.play(kit[index][1],{channel = index})
    group[index].alpha = 1
    transition.to(group[index],{time = 2000,alpha = 0.5})
end

local function playSample(group,kit,trackCounters,index)
	if (trackCounters[index] % 2 ~= 0) then
        audio.setVolume(0,{channel = index})
        group[index].alpha = 0.5
    else
       	audio.setVolume(1,{channel = index})    
        group[index].alpha = 1
    end
    trackCounters[index] = trackCounters[index] + 1
end

function play(group,sampleKit,trackCounters,sampleIndex,isVoice,numSamples,numVoices)
	if (firstTimePlayPressed == nil) then
		firstTimePlayPressed = system.getTimer()
		local idx = 1
		while (idx <= numSamples) do
			audio.play(sampleKit[idx][1],{channel = idx,loops = -1})
			audio.setVolume(0,{channel = idx})
			idx = idx + 1
		end
	end
	
	if (isVoice) then
		playVoice(group,sampleKit,sampleIndex)
	else
		playSample(group,sampleKit,trackCounters,sampleIndex)
	end
end

function initSounds(kitAddress,numSamples,numVoices)
	local i = 1
	local str
	local track = {sound = nil,name = nil,startTime = nil}
	local tracks = {}
	while (i <= numSamples + numVoices) do
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