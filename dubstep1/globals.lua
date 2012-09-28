module(...,package.seeall)

jsonModule = require "json"

w = display.contentWidth
h = display.contentHeight

sceneChangingTimer = nil

-- track = {type = "fx/melody/voice", scene = 1..5, button = buttonStruct, sound = "sound1/track1.mp3", channel = 1..32 }
soundsConfig = {}

currentBasicMelody = nil
currentEvilMelody = nil

-- buttonInScenes = {sceneNum = {{buttonHandle1, pressed}, {buttonHandle2, pressed}, ...}, ...} - ставит кнопки в соответствие номеру сцены, на которой они должны быть
buttonsInScenes = {}

currentGoodMelody = nil

gunFxButton = nil

currentBasicChannel = nil
currentEvilChannel = nil
currentGoodChannel = nil

currentScene = nil
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
fullRecordLength = 170000 / 1
showChoiceTime = 30000 / 1
choiceShownDurationTime = 8000
currentSceneLocalTime = nil
currentSceneAppearTime = nil
nextSceneAppearTime = 0

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
nextSceneButton = nil

eqTxt = nil
repTxt = nil

loading = nil

sceneNumber = nil

shareBtn = nil

function readFile(_fname, prefix, base)
	-- set default base dir if none specified
	if not base then base = nil end

	if not prefix then prefix = "" end

	local fname = prefix.._fname

	-- create a file path for corona i/o
	local path = system.pathForFile( fname, base )

	-- will hold contents of file
	local contents

	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "r" )
	if file then
	   -- read all contents of file into a string
	   contents = file:read( "*a" )
	   io.close( file )	-- close the file after using it
	else
		error("File "..fname.." not found")
	end

	return contents
end


-- track = {id, name, scenes = {1, 2, 3,..}, sound = @"sound1/track1.mp3", channel }
-- buttonStruct = {soundId, scenes = {1, 2, 3,..}, x = 1, y = 1, w = 50, h = 50, rgb = {255, 255, 255}, alpha = 0.5}

-- function createButton({track, left, top, width, height, type, rgb, alpha, scenes, soundId})
function createButton(arg)
	if type(arg) ~= "table" then
		error("wrong type of arg: expected table")
	end

	if not arg.track or type(arg.track) ~= "table" then
		error("Track corrupted")
	end

	local _top
	local _left
	local _width
	local _height
	local _label

	if arg.left and type(arg.left) == "number" then
		_left = arg.left

		if arg.top and type(arg.top) == "number" then
			_top = arg.top
		else
			error("wrong type of arg \"top\" ".."expected number, got "..type(arg.top))
		end
	else
		_left = 1
		_top = 1
	end

	if arg.width and type(arg.width) == "number" then
		_width = arg.width

		if arg.height and type(arg.height) == "number" then
			_height = arg.height
		else
			error("wrong type of arg \"height\" ".."expected number, got "..type(arg.height))
		end
	else
		_width = w/10
		_height = h/10
	end

	if arg.track.name and type(arg.track.name) == "string" then
		-- Убираем имя папки
		local k = string.find(arg.track.name, "/")
		if k ~= nil then
			_label = string.sub(arg.track.name, k+1)
		else
			_label = arg.track.name
		end

		-- Убираем расширение файла
		local k = string.find(_label, ".mp3") or string.find(_label, ".wav")
		_label = string.sub(_label, 1, k-1)
	else
		error("wrong type of arg \"track.name\" ".."expected string, got "..type(arg.track.name))
	end

	local b = display.newRoundedRect(_left, _top, _width, _height, 3)
	b.txt = display.newText(_label,_left,_top,native.systemFont,16)
	b.txt.x = b.x
	b.txt.y = b.y

	if arg.alpha and type(arg.alpha) == "number" then
		b.alpha = arg.alpha
	else
		b.alpha = 0.5
	end
	
	if arg.rgb and type(arg.rgb) == "table" then
		if #arg.rgb == 3 then
			for i, v in pairs(arg.rgb) do
				if type(v) ~= "number" then
					error("Wrong type of rgb componet expected number, got "..type(v))
				end
			end
		else
			error("Wrong number of rgb components")
		end
	elseif arg.rgb then 
		error("Wrong type of arg \"rgb\" expected table, got "..type(arg.rgb))
	else
		b:setFillColor(128, 128, 128)
	end

	b:setFillColor(arg.rgb[1], arg.rgb[2], arg.rgb[3])

	if not arg.scenes or type(arg.scenes) ~= "table" then
		error("Wrong type of arg \"scenes\" expected table, got "..type(arg.scenes))
	else
		b.scenes = arg.scenes
	end

	if not arg.type or type(arg.type) ~= "string" then
		error("Wrong type of arg \"type\" expected table, got "..type(arg.type))
	else
		b.type = arg.type
	end

	if not arg.soundId or type(arg.soundId) ~= "string" then
		error("Wrong type of arg \"soundId\" expected table, got "..type(arg.soundId))
	else
		b.soundId = arg.soundId
	end

	b.channel = arg.track.channel

	b:addEventListener("touch", function (event)
									if event.phase == "ended" then
										if arg.type == "fx" then
											require("playing").playFX(arg.track, b)
										elseif arg.type == "melody" then
											require("playing").playMelody(arg.track, b)
										elseif arg.type == "voice" then
											require("playing").playVoice(arg.track, b)
										end
									end
								end
	)

	return b
end

-- function createGlitchButton({soundIds, left, top, width, height, rgb, alpha, label})
function createGlitchButton(arg)
	if type(arg) ~= "table" then
		error("wrong type of arg: expected table")
	end

	if not arg.soundIds or type(arg.soundIds) ~= "table" then
		error("Table \"soundIds\" corrupted")
	end

	local _top
	local _left
	local _width
	local _height
	local _label

	if arg.left and type(arg.left) == "number" then
		_left = arg.left

		if arg.top and type(arg.top) == "number" then
			_top = arg.top
		else
			error("wrong type of arg \"top\" ".."expected number, got "..type(arg.top))
		end
	else
		_left = 1
		_top = 1
	end

	if arg.width and type(arg.width) == "number" then
		_width = arg.width

		if arg.height and type(arg.height) == "number" then
			_height = arg.height
		else
			error("wrong type of arg \"height\" ".."expected number, got "..type(arg.height))
		end
	else
		_width = w/10
		_height = h/10
	end

	if arg.label and type(arg.label) == "string" then
		_label = arg.label
	else
		_label = "GL"
	end

	local b = display.newRoundedRect(_left, _top, _width, _height, 3)
	b.txt = display.newText(_label,_left,_top,native.systemFont,16)
	b.txt.x = b.x
	b.txt.y = b.y

	if arg.alpha and type(arg.alpha) == "number" then
		b.alpha = arg.alpha
	else
		b.alpha = 0.5
	end
	
	if arg.rgb and type(arg.rgb) == "table" then
		if #arg.rgb == 3 then
			for i, v in pairs(arg.rgb) do
				if type(v) ~= "number" then
					error("Wrong type of rgb componet expected number, got "..type(v))
				end
			end
		else
			error("Wrong number of rgb components")
		end
	elseif arg.rgb then 
		error("Wrong type of arg \"rgb\" expected table, got "..type(arg.rgb))
	else
		b:setFillColor(128, 128, 128)
	end

	b:setFillColor(arg.rgb[1], arg.rgb[2], arg.rgb[3])
	b.soundIds = arg.soundIds

	local f = require("playing").playGlitch
	b:addEventListener("touch", f)

	return b
end

function changeBackGround(object) 
	object.isVisible = true
	object.alpha = 0
	mainGroup:insert(2,object)
	transition.to(object, {alpha = 1, time = 500})
	transition.to(mainGroup[1], {alpha = 0, time = 500})
	mainGroup:insert(3,localGroup)
	timer.performWithDelay(500, function()
		mainGroup:insert(1, object)
		mainGroup:insert(2, localGroup)
	end)
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
	
	volumePanel = require("volumeRegulator")
	volumePanel.regulatorPanel = nil
	
	recording = require("recording")
	replaying = require("replayModule")

	local btns = {}
	
	btn1 = display.newRoundedRect(1,1,w/8,h/8,10)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,10)
	repBtn = display.newRoundedRect(1,1,w/10,h/15,4)

	nextSceneButton = display.newRoundedRect(10*w/14, 3*h/12, 2*w/16, 3*h/15, 8)
	nextSceneButton.txt = display.newText("Next scene", 0, 0, native.systemFont, 16)
	nextSceneButton.txt.x, nextSceneButton.txt.y = nextSceneButton.x, nextSceneButton.y
	nextSceneButton.alpha = 0.5
	nextSceneButton:setFillColor(128, 128, 128)

	
	goodBtn = display.newRoundedRect(4*w/27,3*h/12,4*w/16,5*h/15,10)
	evilBtn = display.newRoundedRect(7*w/16,3*h/12,4*w/16,5*h/15,10)
	
	volumeBtn = display.newRoundedRect(1,1,w/10,h/15,4)
	
	timerTxt = display.newText("",0,0,native.systemFont,14)
	timerTxt.x,timerTxt.y = w/2,6*h/7
	timerTxt.isVisible = false
	
	nextSceneTimerTxt = display.newText("",0,0,native.systemFont,14)
	nextSceneTimerTxt.x,nextSceneTimerTxt.y = 2*w/3,8*h/9
	nextSceneTimerTxt.isVisible = false
	
	sceneNumber = display.newText("Next scene: 2",0,0,native.systemFont,14)
	sceneNumber.x,sceneNumber.y = 3*w/4,6*h/7
	sceneNumber.isVisible = false
		
	shareTxt = display.newText("Share!!!",0,0,native.systemFont,32)
	shareBtn = display.newRoundedRect(0,0,w/2,h/2,12)

	shareBtn.x,shareTxt.x = w/2,w/2
	shareBtn.y,shareTxt.y = h/2,h/2
	
	shareBtn.isVisible = false
	shareTxt.isVisible = false
	
	shareTxt:setTextColor(255,0,0)
	shareBtn.txt = shareTxt
	
	btn1.x,btn1.y,btn2.x,btn2.y = w/16,15*h/16,w/16,12*h/16
	btn1:setFillColor(140,255,0)
	btn2:setFillColor(140,255,0)
	btn1.alpha = 0.5
	btn2.alpha = 0.5
	
	goodBtn:setFillColor(0,100,255)
	evilBtn:setFillColor(255,100,0)
	goodBtn.alpha = 0.5
	evilBtn.alpha = 0.5
	--goodBtn.isVisible = false
	--evilBtn.isVisible = false

	goodBtn.txt = display.newText("Good",0,0,native.systemFont,16)
	evilBtn.txt = display.newText("Evil",0,0,native.systemFont,16)
	goodBtn.txt.x,goodBtn.txt.y = goodBtn.x, goodBtn.y
	evilBtn.txt.x,evilBtn.txt.y = evilBtn.x, evilBtn.y
	evilBtn.txt:toBack()
	goodBtn.txt:toBack()
	--goodBtn.txt.isVisible = false
	--evilBtn.txt.isVisible = false
	
	btn1.txt = display.newText("Back",0,0,native.systemFont,14)
	btn2.txt = display.newText("Restart",0,0,native.systemFont,14)
	btn1.txt.x,btn1.txt.y = w/16,15*h/16
	btn2.txt.x,btn2.txt.y = w/16,12*h/16
	
	repBtn.x,repBtn.y = 15*w/16,h/16
	repBtn:setFillColor(255,140,140)
	repBtn.alpha = 0.5
	repBtn.isVisible = false	
	
	repBtn.txt = display.newText("Play",0,0,native.systemFont,14)
	repBtn.txt.x,repBtn.txt.y = 15*w/16,h/16
	repBtn.txt.isVisible = false
	repBtn.txt:setTextColor(0,255,0)
	
	volumeBtn.x,volumeBtn.y = w/16,h/16
	volumeBtn:setFillColor(140,255,140)
	volumeBtn.alpha = 0.5
	
	volumeBtn.txt = display.newText("EQ",0,0,native.systemFont,14)
	volumeBtn.txt.x,volumeBtn.txt.y = w/16,h/16
	volumeBtn.isVisible = false
	volumeBtn.txt.isVisible = false
	
	btn1.scene = "mainScreen"
	btn2.scene = currentLayout
	repBtn.scene = "replayModule"
	volumeBtn.scene = "volumeRegulator"
	
	recording.cancelTimers(recording.getTimers())
	
	function changeScene(event)
		if (event.phase == "ended") then
			audio.stop()
			loading.isVisible = true
			recording.cancelTimers(recording.timers)
			recording.timers = {}
			recording.cancelTimers(recording.goodEvilButtonTimers)
			recording.goodEvilButtonTimers = {}
			timer.performWithDelay(200, function()
				director:changeScene(event.target.scene)
			end)
		end
	end
	
	nextSceneButton:addEventListener("touch", require("playing").nextScene)

	btn1:addEventListener("touch",changeScene)
	btn2:addEventListener("touch",changeScene)
	repBtn:addEventListener("touch",changeScene)
	volumeBtn:addEventListener("touch",volumePanel.showHidePanel)
	goodBtn:addEventListener("touch",playing.playGoodMelody)
	evilBtn:addEventListener("touch",playing.playEvilMelody)
	shareBtn:addEventListener("touch",function()
										shareBtn.isVisible = false
										shareTxt.isVisible = false
									  end )
	
	btns[1] = btn1
	btns[2] = btn2
	btns[3] = repBtn
	btns[4] = volumeBtn
	return btns
end

function drawLvl1Voices()
	local btns = {}
	local path = "sounds1/voices/"

	local track = {}
	local j = 1
	local oldSampleKitLength = #sampleKit
	for i = oldSampleKitLength + 1, oldSampleKitLength + 19, 1 do
		local str = path.."track"..i-oldSampleKitLength..".mp3"
		track[1] = audio.loadSound(str)
		track[2] = str
		sampleKit[i] = track
		track = {}

		btns[#btns + 1] = display.newRoundedRect(1,1,w/12,h/12,8)
		btns[#btns].txt = display.newText("track"..i-oldSampleKitLength..".mp3",0,0,native.systemFont,7)
		if j <= 10 then
			btns[#btns].x, btns[#btns].y =  w/10*j - w/20,12*h/17
			btns[#btns].txt.x, btns[#btns].txt.y = w/10*j - w/20,12*h/17
		else
			btns[#btns].x, btns[#btns].y =  w/10*(j - 10) - w/20,13*h/16
			btns[#btns].txt.x, btns[#btns].txt.y = w/10*(j - 10) - w/20,13*h/16
		end
		btns[#btns]:setFillColor(255, 200, 128)
		btns[#btns].alpha = 0.5
		btns[#btns].txt:setTextColor(0, 100, 0)

		j = j + 1
	end
	local pl = require("playing")
	for i = 1, 19, 1 do
		btns[i]:addEventListener("touch",	function(e)
												if e.phase == "ended" then
													pl.playFX(display.newGroup(), sampleKit, i + oldSampleKitLength, true)
												end
											end
		)
	end

	return btns
end

function bin_search(ar, direct, required)
	if not answer then
		answer = 0
	end
	local center = math.ceil(#ar/2)
	if direct == "left" then
		answer = answer - (#ar - center)
	else
		answer = answer + center
	end

	if required == ar[center] then
		
		return answer
	end

	if #ar == 1 and ar[1] ~= required then
		
		return -1
	end

	if ar[center] > required then
		local tmpArr = {}
		for i = 1, center, 1 do
			tmpArr[#tmpArr+1] = ar[i]
		end
		if #tmpArr == 0 then
			return -1
		end
		return bin_search(tmpArr, "left", required)
	elseif ar[center] < required then
		local tmpArr = {}
		for i = center+1, #ar, 1 do
			tmpArr[#tmpArr+1] = ar[i]
		end
		if #tmpArr == 0 then
			return -1
		end
		return bin_search(tmpArr, "right" ,required)
	end 
end