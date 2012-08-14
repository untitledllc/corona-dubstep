module(...,package.seeall)

w = display.contentWidth
h = display.contentHeight

currentKit = nil
currentLayout = nil
currentNumSamples = nil
currentNumFX = nil
currentNumVoices = nil

function mySeek(time,sound,chan,loop)
	if (loop == nil) then
		loop = 0
	end
	
	if (time <= 0) then
		audio.play(sound,{channel = chan,loops = loop})
		return
	end
	
	if (time <= audio.getDuration(sound)) then
		audio.play(sound,{channel = chan,loops = loop})
		audio.seek(time,{channel = chan})
	end
	
	if (time > audio.getDuration(sound)) then
		audio.play(sound,{channel = chan})
		audio.seek(time % audio.getDuration(sound),{channel = chan,loops = loop}) 
	end
end

function drawLayoutBtns()
	activeChannels = {}
	partSumms = {}
	
	recording = require("recording")
	replaying = require("replayModule")
	
	local btns = {}
	
	btn1 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,10)
	recBtn = display.newRoundedRect(1,1,w/8,h/8,10)
	repBtn = display.newRoundedRect(1,1,w/10,h/15,4)
	
	loading = display.newText("Loading...", 0, 0, native.systemFont, 32)
	loading.x,loading.y = w/2,h/2
	loading.isVisible = false
	
	btn1.x,btn1.y,btn2.x,btn2.y = w/16,15*h/16,w/4,15*h/16
	btn1:setFillColor(140,255,0)
	btn2:setFillColor(140,255,0)
	btn1.alpha = 0.5
	btn2.alpha = 0.5
	
	recBtn.x,recBtn.y = 15*w/16,15*h/16
	recBtn:setFillColor(140,255,140)
	recBtn.alpha = 0.5
	
	repBtn.x,repBtn.y = 15*w/16,h/16
	repBtn:setFillColor(255,140,140)
	repBtn.alpha = 0.5
	
	btn1.scene = "layout1"
	btn2.scene = "layout2"
	recBtn.scene = "recording"
	repBtn.scene = "replayModule"
	
	function changeScene(event)
		audio.stop()
		loading.isVisible = true
		if (event.phase == "ended") then
			director:changeScene(event.target.scene)
		end
	end
	
	btn1:addEventListener("touch",changeScene)
	btn2:addEventListener("touch",changeScene)
	recBtn:addEventListener("touch",recording.startRecording)
	repBtn:addEventListener("touch",changeScene)
	
	btns[1] = btn1
	btns[2] = btn2
	btns[3] = recBtn
	btns[4] = repBtn
	return btns
end