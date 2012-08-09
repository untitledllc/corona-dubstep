module(...,package.seeall)

w = display.contentWidth
h = display.contentHeight

currentKit = nil
currentLayout = nil
function mySeek(time,sound,chan,loop)
	if (loop == nil) then
		loop = 0
	end
	
	if (time <= 0) then
		audio.play(sound,{channel = chan})
		return
	end
	
	if (time <= audio.getDuration(sound)) then
		audio.play(sound,{channel = chan})
		audio.seek(time,{channel = chan})
	end
	
	if (time > audio.getDuration(sound)) then
		audio.play(sound,{channel = chan})
		audio.seek(time % audio.getDuration(sound),{channel = chan}) 
	end
end

function drawLayoutBtns()
	activeChannels = {}
	partSumms = {}
	
	recording = require("recording")
	
	local btns = {}
	local localGroup = display.newGroup()
	btn1 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,10)
	recBtn = display.newRoundedRect(1,1,w/8,h/8,10)
	
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
	recBtn:addEventListener("touch",recording.startRecording)
	
	btns[#btns + 1] = btn1
	btns[#btns + 1] = btn2
	btns[#btns + 1] = recBtn
	return btns
end