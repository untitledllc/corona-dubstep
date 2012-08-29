module(...,package.seeall)

w = display.contentWidth
h = display.contentHeight

currentBasicMelody = nil
currentEvilMelody = nil
currentGoodMelody = nil

currentBasicChannel = nil
currentEvilChannel = nil
currentGoodChannel = nil

currentKit = nil
currentLayout = nil
currentNumSamples = nil
currentNumFX = nil
currentNumVoices = nil
mainGroup = nil
localGroup = nil
isRecordingTimeRestricted = true

timerTxt = nil

changeLayoutTime = 30000
fullRecordLength = 192000
showChoiceTime = 90000
choiceShownDurationTime = 4000

glitchChannel = 99
glitchShutUpTime = 50
glitchPlayTime = 70

currentBacks = nil
currentHiddenBtns = {}

repBtn = nil
btn1 = nil
btn2 = nil
volumeBtn = nil
goodBtn = nil
evilBtn = nil

goodTxt = nil
evilTxt = nil
eqTxt = nil
repTxt = nil

loading = nil
rotator = nil

sceneNumber = nil

local rotateFunc = nil

function startRotation(object,angle)
	if (object == nil) then
		return
	end
	object.isVisible = true
	--local delta = 0
	local function rotateObject(event)
		print(angle)
		object:rotate(angle)
		--delta = delta + angle
	end
	rotateFunc = rotateObject
	Runtime:addEventListener("enterFrame",rotateObject)
end

function stopRotation(object)
	if (object == nil) then
		return
	end
	object.isVisible = false
	Runtime:removeEventListener("enterFrame",rotateFunc)
end

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
	print(loading)
	activeChannels = {}
	partSumms = {}
	
	volumePanel = require("volumeRegulator")
	volumePanel.regulatorPanel = nil
	
	recording = require("recording")
	replaying = require("replayModule")

	local btns = {}
	
	btn1 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,10)
	repBtn = display.newRoundedRect(1,1,w/10,h/15,4)
	
	goodTxt = display.newText("Good",0,0,native.systemFont,14)
	evilTxt = display.newText("Evil",0,0,native.systemFont,14)
	goodTxt.x,goodTxt.y = w/2,15*h/16
	evilTxt.x,evilTxt.y = 5*w/8,15*h/16
	goodTxt.isVisible = false
	evilTxt.isVisible = false
	
	goodBtn = display.newRoundedRect(1,1,w/10,h/10,10)
	evilBtn = display.newRoundedRect(1,1,w/10,h/10,10)
	
	volumeBtn = display.newRoundedRect(1,1,w/10,h/15,4)
	
	timerTxt = display.newText("",0,0,native.systemFont,32)
	timerTxt.x,timerTxt.y = w/2,6*h/7
	timerTxt.isVisible = false
	
	sceneNumber = display.newText("1",0,0,native.systemFont,32)
	sceneNumber.x,sceneNumber.y = 2*w/3,6*h/7
	sceneNumber.isVisible = false
	
	btn1.x,btn1.y,btn2.x,btn2.y = w/16,15*h/16,w/4,15*h/16
	btn1:setFillColor(140,255,0)
	btn2:setFillColor(140,255,0)
	btn1.alpha = 0.5
	btn2.alpha = 0.5
	
	goodBtn.x,goodBtn.y = w/2,15*h/16
	evilBtn.x,evilBtn.y = 5*w/8,15*h/16
	goodBtn:setFillColor(0,100,255)
	evilBtn:setFillColor(255,100,0)
	goodBtn.isVisible = false
	evilBtn.isVisible = false
	
	repBtn.x,repBtn.y = 15*w/16,h/16
	repBtn:setFillColor(255,140,140)
	repBtn.alpha = 0.5
	repBtn.isVisible = false
	
	volumeBtn.x,volumeBtn.y = w/16,h/16
	volumeBtn:setFillColor(140,255,140)
	volumeBtn.alpha = 0.5
	
	btn1.scene = "mainScreen"
	btn2.scene = currentLayout
	repBtn.scene = "replayModule"
	volumeBtn.scene = "volumeRegulator"
	
	recording.cancelTimers(recording.getTimers())
	
	function changeScene(event)
		audio.stop()
		loading.isVisible = true
		if (event.phase == "ended") then
			director:changeScene(event.target.scene)
		end
	end
	
	btn1:addEventListener("touch",changeScene)
	btn2:addEventListener("touch",changeScene)
	repBtn:addEventListener("touch",changeScene)
	volumeBtn:addEventListener("touch",volumePanel.showHidePanel)
	goodBtn:addEventListener("touch",playing.playGoodMelody)
	evilBtn:addEventListener("touch",playing.playEvilMelody)
	
	btns[1] = btn1
	btns[2] = btn2
	btns[3] = repBtn
	btns[4] = volumeBtn
	return btns
end