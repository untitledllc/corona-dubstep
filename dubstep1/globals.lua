module(...,package.seeall)

w = display.contentWidth
h = display.contentHeight

currentKit = nil
currentLayout = nil
currentNumSamples = nil
currentNumFX = nil
currentNumVoices = nil
mainGroup = nil
localGroup = nil
isRecordingTimeRestricted = true

timerTxt = nil

changeLayoutTime = 3000
fullRecordLength = 18000
showChoiceTime = 6000
choiceShownDurationTime = 2000

glitchChannel = 99
glitchShutUpTime = 50
glitchPlayTime = 70

currentBacks = nil
currentHiddenBtns = {}

repBtn = nil
btn1 = nil
btn2 = nil
volumeBtn = nil

function changeBackGround(object) 
	object.isVisible = true
	mainGroup:insert(1,object)
	mainGroup:insert(2,localGroup)
end

function mySeek(time,sound,chan,loop)
	if (loop == nil) then
		loop = 0
	end
	
	if (time <= 0) then
		audio.play(sound,{channel = chan,loops = loop})
		return
	end

	audio.play(sound,{channel = chan,loops = loop})
	audio.seek(audio.getDuration(sound) - (time % audio.getDuration(sound)),{channel = chan}) 
end

function seekGlitch(time) 
	local state = nil
	local timeToChangeState = nil
	noLoopsTime = time % (glitchShutUpTime+glitchPlayTime)
	if (noLoopsTime > glitchShutUpTime) then
		state = 1
		timeToChangeState = (glitchShutUpTime+glitchPlayTime) - noLoopsTime
	else
		state = 0 
		timeToChangeState = glitchShutUpTime - noLoopsTime
	end
	
	return state,timeToChangeState
end

function drawLayoutBtns()
	activeChannels = {}
	partSumms = {}
	
	recording = require("recording")
--	recording.recPressCounter = 0
	replaying = require("replayModule")
	volumePanel = require("volumeRegulator")
	volumePanel.regulatorPanel = nil
	
	local btns = {}
	
	btn1 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,10)
--	recBtn = display.newRoundedRect(1,1,w/8,h/8,10)
	repBtn = display.newRoundedRect(1,1,w/10,h/15,4)
	
	volumeBtn = display.newRoundedRect(1,1,w/10,h/15,4)
	
	loading = display.newText("Loading...", 0, 0, native.systemFont, 32)
	loading.x,loading.y = w/2,h/2
	loading.isVisible = false
	
	timerTxt = display.newText("",0,0,native.systemFont,32)
	timerTxt.x,timerTxt.y = w/2,6*h/7
	timerTxt.isVisible = false
	
	btn1.x,btn1.y,btn2.x,btn2.y = w/16,15*h/16,w/4,15*h/16
	btn1:setFillColor(140,255,0)
	btn2:setFillColor(140,255,0)
	btn1.alpha = 0.5
	btn2.alpha = 0.5
	
--	recBtn.x,recBtn.y = 15*w/16,15*h/16
--	recBtn:setFillColor(140,255,140)
--	recBtn.alpha = 0.5
	
	repBtn.x,repBtn.y = 15*w/16,h/16
	repBtn:setFillColor(255,140,140)
	repBtn.alpha = 0.5
	repBtn.isVisible = false
	
	volumeBtn.x,volumeBtn.y = w/16,h/16
	volumeBtn:setFillColor(140,255,140)
	volumeBtn.alpha = 0.5
	
	btn1.scene = "layout1"
	btn2.scene = "layout2"
--	recBtn.scene = "recording"
	repBtn.scene = "replayModule"
	volumeBtn.scene = "volumeRegulator"
	
	print("here")
	recording.cancelTimers(recording.getTimers())
	recording.setRecState(false)
	
	function changeScene(event)
		audio.stop()
		loading.isVisible = true
		if (event.phase == "ended") then
			director:changeScene(event.target.scene)
		end
	end
	
	btn1:addEventListener("touch",changeScene)
	btn2:addEventListener("touch",changeScene)
	--recBtn:addEventListener("touch",recording.startRecording)
	repBtn:addEventListener("touch",changeScene)
	volumeBtn:addEventListener("touch",volumePanel.showHidePanel)
	
	btns[1] = btn1
	btns[2] = btn2
	--btns[3] = recBtn
	btns[3] = repBtn
	btns[4] = volumeBtn
	return btns
end