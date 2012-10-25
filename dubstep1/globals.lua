module(...,package.seeall)

jsonModule = require "json"

widget = require "widget"

-- DEBUG
--glIndicator = nil

--------


toEndTimerFunc = nil
toNextSceneTimerFunc = nil

w = display.contentWidth
h = display.contentHeight
vW = display.viewableContentWidth
vH = display.viewableContentHeight

myW = display.viewableContentWidth
myH = display.viewableContentHeight

coefW = vW/w
coefH = vH/h

sizeCoef = math.min(coefW, coefH)

print(display.screenOriginX, display.screenOriginY, vW, vH, w, h,sizeCoef)

deltaTime = 0

toNextSceneTime = 9999
toFinalTime = 9999

sceneChangingTimer = nil

startRecordTime = nil

-- track = {type = "fx/melody/voice", scene = 1..5, button = buttonStruct, sound = "sound1/track1.mp3", channel = 1..32 }
soundsConfig = {}

currentBasicMelody = nil
currentEvilMelody = nil

-- buttonInScenes = {sceneNum = {{button1Id, pressed}, {button2Id, pressed}, ...}, ...} - ставит кнопки в соответствие номеру сцены, на которой они должны быть
buttonsInScenes = {}

-- soundInScenes = {sceneNum = {soundInfo1Id, soundInfo2Id, ...}, ...} - ставит id треков в соответствие номеру сцены, на которой они должны быть
soundsInScenes = {}

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

timerTxtShadow = nil
timerTxt = nil

nextSceneTimerTxt = nil
nextSceneTimerTxtShadow = nil

changeLayoutTime = 30000
fullRecordLength = 170000 / 1
showChoiceTime = 30000 / 1
choiceShownDurationTime = 8000
currentSceneLocalTime = 0
currentSceneAppearTime = nil
nextSceneAppearTime = 0

glitchChannel = 99
glitchShutUpTime = 50
glitchPlayTime = 70

currentBacks = nil
currentHiddenBtns = {}

menuButtonFinal = nil
repBtn = nil
btn1 = nil
btn2 = nil
volumeBtn = nil
goodBtn = nil
evilBtn = nil
nextSceneButton = nil


voicesBack1 = nil
voicesBack2 = nil
navBar = nil

eqTxt = nil
repTxt = nil

glitchTxt = nil
glitchTxtShadow = nil

loading = nil

sceneNumber = nil
sceneNumberShadow = nil

shareBtn = nil

choosenSide = nil
ifChoosen = false

function readFile(_fname, prefix, base)
	-- set default base dir if none specified
	if not base then base = nil end

	if not prefix then prefix = "" end

	if type(prefix) ~= "string" then
		base = prefix
		prefix = ""
	end

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

-- function createButton({track, left, top, width, height, type, rgb, alpha, scenes, soundId, label, default, over})
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
	local _default
	local _over

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

	if not arg.label then
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
	else
		_label = arg.label
	end

	if arg.default then
		_default = "images/elements/"..arg.default
	end
	if arg.over then
		_over = "images/elements/"..arg.over
	end

	local function buttonListener (event)
									if event.phase == "release" then				
										if event.target.type == "fx" then
											require("playing").playFX(event.target.track, event.target)
										elseif event.target.type == "melody" then
											require("playing").playMelody(event.target.track, event.target)

											--пересоздаем кнопку, чтобы поменять картинку на ней
											local idx
											for i, v in pairs(configInterface.soundButtons) do
												if v.button == event.target then
													idx = i
													break
												end
											end

											local _id = event.target.id
											local defaultImage = event.target.defaultImage
											local overImage = event.target.overImage
											local ttype = event.target.type
											local soundId = event.target.soundId
											local scenes = event.target.scenes
											local x = event.target.x
											local y = event.target.y
											local w = event.target.width											
											local h = event.target.height
											local _alpha = event.target.alpha
											local _track = event.target.track
											local _pressed = event.target.pressed
											local _isVisible = event.target.isVisible

											display.remove(event.target)
											event.target = widget.newButton{
												id = _id,
												left = 1,
												top = 1,
												default = overImage,
												over = defaultImage,
												width = w,
												height = h,
												onEvent = buttonListener
											}
											event.target.defaultImage = overImage
											event.target.overImage = defaultImage
											event.target:addEventListener("emulatePress", buttonListener)
											event.target.alpha = _alpha
											event.target.type = ttype
											event.target.soundId = soundId
											event.target.scenes = scenes
											event.target.x = x
											event.target.y = y
											event.target.track = _track
											event.target.pressed = _pressed
											event.target.isVisible = _isVisible
											mainGroup[2]:insert(event.target)
											configInterface.soundButtons[idx].button = event.target
										elseif event.target.type == "voice" then
											require("playing").playVoice(event.target.track, event.target)
										end
									end
								end

	local b = widget.newButton{
		id = "sound"..arg.soundId,
		left = _left*coefW + display.screenOriginX,
		top = _top*coefH + display.screenOriginY,
		default = _default,
		over = _over,
		width = _width*sizeCoef,
		height = _height*sizeCoef,
		onEvent = buttonListener
	}
	b.defaultImage = _default
	b.overImage = _over
	b.track = arg.track
	b:addEventListener("emulatePress", buttonListener)
	if not _default or not _over then
		b.txt = display.newText(_label,_left,_top,native.systemFont,14)
		b.txt.x = b.x
		b.txt.y = b.y
	end

	if arg.alpha and type(arg.alpha) == "number" then
		b.alpha = arg.alpha
	else
		b.alpha = 0.5
	end
	
	--[[if arg.rgb and type(arg.rgb) == "table" then
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
	if not _default or not _over then
		b:setFillColor(arg.rgb[1], arg.rgb[2], arg.rgb[3])
	end]]--

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

	--[[b:addEventListener("touch", function (event)
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
	)]]--

	return b
end

-- function createGlitchButton({soundIds, left, top, width, height, rgb, alpha, label, default, over, id})
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

	if arg.default then
		_default = "images/elements/"..arg.default
	end
	if arg.over then
		_over = "images/elements/"..arg.over
	end

	local _f = require("playing").playGlitch

	local b = widget.newButton{
		id = arg.id,
		left = _left*coefW + display.screenOriginX,
		top = _top*coefH + display.screenOriginY,
		default = _default,
		over = _over,
		width = _width*sizeCoef,
		height = _height*sizeCoef,
		onEvent = _f
	}
	b:addEventListener("emulatePress", _f)
	--b.txt = display.newText(_label,_left,_top,native.systemFont,16)
	--b.txt.x = b.x
	--b.txt.y = b.y

	if arg.alpha and type(arg.alpha) == "number" then
		b.alpha = arg.alpha
	else
		b.alpha = 1
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
		--b:setFillColor(128, 128, 128)
	end

	--b:setFillColor(arg.rgb[1], arg.rgb[2], arg.rgb[3])
	b.soundIds = arg.soundIds

	return b
end

function createResizableButton(arg)
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
	local _default
	local _over

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

	_left = _left*coefW + display.screenOriginX
	_top = _top*coefH + display.screenOriginY

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

	_width = _width * coefW
	_height = _height * coefH

	if arg.default then
		_default = "images/elements/"..arg.default
	end
	if arg.over then
		_over = "images/elements/"..arg.over
	end

	local function buttonListener (event)
									if event.phase == "began" then
										if event.target[1].isVisible == true then
											event.target[1].isVisible = false
											event.target[2].isVisible = true
										elseif event.target[3].isVisible == true then
											event.target[3].isVisible = false
											event.target[4].isVisible = true
										end
										display.getCurrentStage():setFocus(event.target, event.id)
									elseif event.phase == "ended" or event.phase == "cancelled" then
										if event.phase == "ended" then
											if not ( event.x < (event.target[1].x - event.target[1].x/2) or event.x > (event.target[1].x + event.target[1].x/2) or event.y < (event.target[1].y - event.target[1].y/2) or event.y > (event.target[1].y + event.target[1].y/2)) then
												if event.target.type == "fx" then
													require("playing").playFX(event.target.track, event.target)
												elseif event.target.type == "melody" then
													require("playing").playMelody(event.target.track, event.target)
												elseif event.target.type == "voice" then
													require("playing").playVoice(event.target.track, event.target)
												end
											end
										end
										if event.target[2].isVisible == true then
											event.target[2].isVisible = false
											event.target[1].isVisible = true
										elseif event.target[4].isVisible == true then
											event.target[4].isVisible = false
											event.target[3].isVisible = true
										end
										display.getCurrentStage():setFocus(event.target, nil)


									end
								end

	local b = display.newGroup()

	-- Короткая ненажатая кнопка
	local shortImageGroup = display.newGroup()

	local tmpImg = display.newImageRect(configInterface.longerButtonElements.left.fileName, 5*sizeCoef, 33*sizeCoef)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5, 5
	shortImageGroup:insert(tmpImg)

	tmpImg = display.newImageRect(_default, _width, _height)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5 + 5*sizeCoef, 5
	shortImageGroup:insert(tmpImg)

	tmpImg = display.newImageRect(configInterface.longerButtonElements.right.fileName, 5*sizeCoef, 33*sizeCoef)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5 + 5*sizeCoef + _width, 5
	shortImageGroup:insert(tmpImg)

	shortImageGroup:setReferencePoint(display.TopLeftReferencePoint)
	shortImageGroup.x, shortImageGroup.y = _left, _top

	b:insert(shortImageGroup)
	-----

	-- Короткая нажатая кнопка
	local shortPressedImageGroup = display.newGroup()

	local tmpImg = display.newImageRect(configInterface.longerButtonElements.leftPressed.fileName, 5*sizeCoef, 33*sizeCoef)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5, 5
	shortPressedImageGroup:insert(tmpImg)

	tmpImg = display.newImageRect(_over, _width, _height)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5 + 5*sizeCoef, 5
	shortPressedImageGroup:insert(tmpImg)

	tmpImg = display.newImageRect(configInterface.longerButtonElements.rightPressed.fileName, 5*sizeCoef, 33*sizeCoef)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5 + 5*sizeCoef + _width, 5
	shortPressedImageGroup:insert(tmpImg)

	shortPressedImageGroup:setReferencePoint(display.TopLeftReferencePoint)
	shortPressedImageGroup.x, shortPressedImageGroup.y = _left, _top

	b:insert(shortPressedImageGroup)
	-----

	-- Длинная ненажатая кнопка
	local longImageGroup = display.newGroup()

	local tmpImg = display.newImageRect(configInterface.longerButtonElements.left.fileName, 5, 33)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5, 5
	longImageGroup:insert(tmpImg)

	for i = 1, 7, 1 do
		tmpImg = display.newImageRect(configInterface.longerButtonElements.longer.fileName, 5, 33)
		tmpImg:setReferencePoint(display.TopLeftReferencePoint)
		tmpImg.x, tmpImg.y = 5 + i*5, 5
		longImageGroup:insert(tmpImg)
	end

	tmpImg = display.newImageRect(_default, _width, _height)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 45, 5
	longImageGroup:insert(tmpImg)

	for i = 1, 7, 1 do
		tmpImg = display.newImageRect(configInterface.longerButtonElements.longer.fileName, 5, 33)
		tmpImg:setReferencePoint(display.TopLeftReferencePoint)
		tmpImg.x, tmpImg.y = 45 + _width + (i-1)*5, 5
		longImageGroup:insert(tmpImg)
	end

	tmpImg = display.newImageRect(configInterface.longerButtonElements.right.fileName, 5, 33)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 85 + _width, 5
	longImageGroup:insert(tmpImg)

	longImageGroup:setReferencePoint(display.TopLeftReferencePoint)
	longImageGroup.x, longImageGroup.y = _left, _top

	b:insert(longImageGroup)
	-----

	-- Длинная нажатая кнопка
	local longPressedImageGroup = display.newGroup()

	local tmpImg = display.newImageRect(configInterface.longerButtonElements.leftPressed.fileName, 5, 33)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 5, 5
	longPressedImageGroup:insert(tmpImg)

	for i = 1, 7, 1 do
		tmpImg = display.newImageRect(configInterface.longerButtonElements.longerPressed.fileName, 5, 33)
		tmpImg:setReferencePoint(display.TopLeftReferencePoint)
		tmpImg.x, tmpImg.y = 5 + i*5, 5
		longPressedImageGroup:insert(tmpImg)
	end

	tmpImg = display.newImageRect(_over, _width, _height)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 45, 5
	longPressedImageGroup:insert(tmpImg)

	for i = 1, 7, 1 do
		tmpImg = display.newImageRect(configInterface.longerButtonElements.longerPressed.fileName, 5, 33)
		tmpImg:setReferencePoint(display.TopLeftReferencePoint)
		tmpImg.x, tmpImg.y = 45 + _width + (i-1)*5, 5
		longPressedImageGroup:insert(tmpImg)
	end

	tmpImg = display.newImageRect(configInterface.longerButtonElements.rightPressed.fileName, 5, 33)
	tmpImg:setReferencePoint(display.TopLeftReferencePoint)
	tmpImg.x, tmpImg.y = 85 + _width, 5
	longPressedImageGroup:insert(tmpImg)

	longPressedImageGroup:setReferencePoint(display.TopLeftReferencePoint)
	longPressedImageGroup.x, longPressedImageGroup.y = _left, _top

	b:insert(longPressedImageGroup)
	-----

	b[1].isVisible = true
	b[2].isVisible = false
	b[3].isVisible = false
	b[4].isVisible = false

	b.track = arg.track
	
	if arg.alpha and type(arg.alpha) == "number" then
		b.alpha = arg.alpha
	else
		b.alpha = 0.5
	end

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

	b:addEventListener("touch", buttonListener)

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

function drawLayoutBtns()
	activeChannels = {}
	partSumms = {}
	
	--volumePanel = require("volumeRegulator")
	--volumePanel.regulatorPanel = nil
	
	recording = require("recording")
	replaying = require("replayModule")

	local btns = {}

	function changeScene(event)
		if event.phase == "release" then
			if toEndTimerFunc then
				Runtime:removeEventListener("enterFrame", toEndTimerFunc)
			end
			if toNextSceneTimerFunc then
				Runtime:removeEventListener("enterFrame", toNextSceneTimerFunc)
			end
			audio.stop()
			loading.isVisible = true
			recording.cancelTimers(recording.timers)
			recording.timers = {}
			--recording.cancelTimers(recording.goodEvilButtonTimers)
			recording.goodEvilButtonTimers = {}
			timer.cancel(sceneChangingTimer)
			for i, v in pairs(soundsConfig) do
				if v.sound then
					if v.type == "melody" then
						audio.rewind(v.sound)
					end
					v.channel = nil
				end
			end
			--local sampleKit = playModule.initSounds(kitAddress)
			choosenSide = defaultSide
			--soundsConfig = {}
			--configInterface = {}
			--buttonsInScenes = {}
			--soundsInScenes = {}
				
			if event.target == btn2 then
				require("level").atOncePlay = true
			else
				require("level").atOncePlay = false
			end

			if mainGroup then
				while mainGroup.numChildren > 0 do
					mainGroup:remove(1)
				end

				local loading = display.newImageRect("images/iphone/splashScreenImage.png", myW, myH)
				loading.x, loading.y = w/2, h/2
				loading.isVisible = true
				mainGroup:insert(loading)
			end
			timer.performWithDelay(200, function()
				director:changeScene(event.target.scene)
			end)

		end
	end
	
	btn1 = widget.newButton{
		id = "toMenu",
		left = 5*coefW + display.screenOriginX,
		top = 3*coefH + display.screenOriginY,
		default = "images/elements/toMenuFromPlayng.png",
		over = "images/elements/toMenuFromPlayngPressed.png",
		width = 55*sizeCoef,
		height = 36*sizeCoef,
		onEvent = changeScene
	}
	btn1.scene = "level"
	
	btn2 = widget.newButton{
		id = "restart",
		left = 440*coefW + display.screenOriginX,
		top = 5*coefH + display.screenOriginY,
		default = "images/elements/restart.png",
		over = "images/elements/restartPressed.png",
		width = 38*sizeCoef,
		height = 36*sizeCoef,
		onEvent = changeScene
	}
	btn2.scene = "level"

	repBtn = widget.newButton{
		id = "replay",
		left = 285*coefW + display.screenOriginX,
		top = 195*coefH + display.screenOriginY,
		default = "images/elements/replayButton.png",
		over = "images/elements/replayButtonPressed.png",
		width = 77*sizeCoef,
		height = 38*sizeCoef,
		onEvent = changeScene
	}
	repBtn.scene = "replayModule"

	menuButtonFinal = widget.newButton{
		id = "toMenuFinal",
		left = 385*coefW + display.screenOriginX,
		top = 195*coefH + display.screenOriginY,
		default = "images/elements/toMenuFinal.png",
		over = "images/elements/toMenuFinalPressed.png",
		width = 77*sizeCoef,
		height = 38*sizeCoef,
		onEvent = changeScene
	}
	menuButtonFinal.scene = "level"


	nextSceneButton = display.newRoundedRect(180, 230, 55, 38, 8)
	nextSceneButton.txt = display.newText("Next scene", 0, 0, native.systemFont, 16)
	nextSceneButton.txt.x, nextSceneButton.txt.y = nextSceneButton.x, nextSceneButton.y
	nextSceneButton.alpha = 0.5
	nextSceneButton:setFillColor(128, 128, 128)
	--nextSceneButton.isVisible = false
	--nextSceneButton.txt.isVisible = false

	
	goodBtn = display.newRoundedRect(4*w/27,3*h/12,4*w/16,5*h/15,10)
	evilBtn = display.newRoundedRect(7*w/16,3*h/12,4*w/16,5*h/15,10)
	
	--volumeBtn = display.newRoundedRect(1,1,w/10,h/15,4)

	--timerTxtShadow = display.newText("(00:00)",0,0,native.systemFont,16)
	--timerTxtShadow:setReferencePoint(display.TopLeftReferencePoint)
	--timerTxtShadow.x,timerTxtShadow.y = 179,30
	--timerTxtShadow.isVisible = false
	--timerTxtShadow:setTextColor(100, 100, 100, 127)
	
	timerTxt = display.newText("(00:00)",0,0,native.systemFont,math.round(16*sizeCoef))
	timerTxt:setReferencePoint(display.TopLeftReferencePoint)
	timerTxt.x,timerTxt.y = 180*coefW + display.screenOriginX,30*coefH + display.screenOriginY
	timerTxt.isVisible = false
	timerTxt.alpha = 0.5
	
	--nextSceneTimerTxtShadow = display.newText("Next scene: ",0,0,native.systemFontBold,12)
	--nextSceneTimerTxtShadow:setReferencePoint(display.TopLeftReferencePoint)
	--nextSceneTimerTxtShadow.x,nextSceneTimerTxtShadow.y = 170,300
	--nextSceneTimerTxtShadow.isVisible = false
	--nextSceneTimerTxtShadow:setTextColor(100, 100, 100, 255)

	nextSceneTimerTxt = display.newText("Next scene: ",0,0,native.systemFontBold,math.round(12*sizeCoef))
	nextSceneTimerTxt:setReferencePoint(display.TopLeftReferencePoint)
	nextSceneTimerTxt.x,nextSceneTimerTxt.y = 171*coefW + display.screenOriginX,301*coefH + display.screenOriginY
	nextSceneTimerTxt.isVisible = false
	
	sceneNumberShadow = display.newText("Scene: I",0,0,native.systemFont,math.round(18*sizeCoef))
	sceneNumberShadow:setReferencePoint(display.TopLeftReferencePoint)
	sceneNumberShadow.x,sceneNumberShadow.y = 167*coefW + display.screenOriginX,7*coefH + display.screenOriginY
	sceneNumberShadow.isVisible = false
	sceneNumberShadow:setTextColor(100, 100, 100, 255)

	sceneNumber = display.newText("Scene: I",0,0,native.systemFont,math.round(18*sizeCoef))
	sceneNumber:setReferencePoint(display.TopLeftReferencePoint)
	sceneNumber.x,sceneNumber.y = 168*coefW + display.screenOriginX,8*coefH + display.screenOriginY
	sceneNumber.isVisible = false

	--glitchTxtShadow = display.newText("Glitch", 0, 0, native.systemFontBold, 14)
	--glitchTxtShadow:setReferencePoint(display.TopLeftReferencePoint)
	--glitchTxtShadow.x,glitchTxtShadow.y = 29,216
	--glitchTxtShadow.isVisible = false
	--glitchTxtShadow:setTextColor(100, 100, 100, 255)

	glitchTxt = display.newText("Glitch", 0, 0, native.systemFontBold, math.round(14*sizeCoef))
	glitchTxt:setReferencePoint(display.TopLeftReferencePoint)
	glitchTxt.x,glitchTxt.y = 30*coefW + display.screenOriginX,215*coefH + display.screenOriginY
	glitchTxt.isVisible = false
		
	shareTxt = display.newText("Share!!!",0,0,native.systemFont,32)
	shareBtn = display.newRoundedRect(0,0,w/2,h/2,12)

	shareBtn.x,shareTxt.x = w/2,w/2
	shareBtn.y,shareTxt.y = h/2,h/2
	
	shareBtn.isVisible = false
	shareTxt.isVisible = false
	
	shareTxt:setTextColor(255,0,0)
	shareBtn.txt = shareTxt
	
	--btn1.x,btn1.y,btn2.x,btn2.y = w/16,15*h/16,w/16,12*h/16
	--btn1:setFillColor(140,255,0)
	--btn2:setFillColor(140,255,0)
	--btn1.alpha = 0.5
	--btn2.alpha = 0.5
	
	goodBtn:setFillColor(0,100,255)
	evilBtn:setFillColor(255,100,0)
	goodBtn.alpha = 0.5
	evilBtn.alpha = 0.5
	goodBtn.isVisible = false
	evilBtn.isVisible = false

	goodBtn.txt = display.newText("Good",0,0,native.systemFont,16)
	evilBtn.txt = display.newText("Evil",0,0,native.systemFont,16)
	goodBtn.txt.x,goodBtn.txt.y = goodBtn.x, goodBtn.y
	evilBtn.txt.x,evilBtn.txt.y = evilBtn.x, evilBtn.y
	evilBtn.txt:toBack()
	goodBtn.txt:toBack()
	goodBtn.txt.isVisible = false
	evilBtn.txt.isVisible = false
	
	--btn1.txt = display.newText("Back",0,0,native.systemFont,14)
	--btn2.txt = display.newText("Restart",0,0,native.systemFont,14)
	--btn1.txt.x,btn1.txt.y = btn1.x, btn1.y
	--btn2.txt.x,btn2.txt.y = btn2.x, btn2.y
	
	--repBtn.x,repBtn.y = 15*w/16,h/16
	--repBtn:setFillColor(255,140,140)
	--repBtn.alpha = 0.5
	repBtn.isVisible = false	
	menuButtonFinal.isVisible = false
	--repBtn.txt = display.newText("Play",0,0,native.systemFont,14)
	--repBtn.txt.x,repBtn.txt.y = 15*w/16,h/16
	--repBtn.txt.isVisible = false
	--repBtn.txt:setTextColor(0,255,0)

	
	
	--volumeBtn.x,volumeBtn.y = w/16,h/16
	--volumeBtn:setFillColor(140,255,140)
	--volumeBtn.alpha = 0.5
	
	--volumeBtn.txt = display.newText("EQ",0,0,native.systemFont,14)
	--volumeBtn.txt.x,volumeBtn.txt.y = w/16,h/16
	--volumeBtn.isVisible = false
	--volumeBtn.txt.isVisible = false
	
	--volumeBtn.scene = "volumeRegulator"
	
	recording.cancelTimers(recording.getTimers())
	
	
	
	nextSceneButton:addEventListener("touch", require("playing").nextScene)

	--btn1:addEventListener("touch",changeScene)
	--btn2:addEventListener("touch",changeScene)
	--repBtn:addEventListener("touch",changeScene)
	--volumeBtn:addEventListener("touch",volumePanel.showHidePanel)
	goodBtn:addEventListener("touch",playing.playGoodMelody)
	evilBtn:addEventListener("touch",playing.playEvilMelody)
	shareBtn:addEventListener("touch",function()
										shareBtn.isVisible = false
										shareTxt.isVisible = false
									  end )
	
	btns[1] = btn1
	btns[2] = btn2
	btns[3] = repBtn
	btns[4] = menuButtonFinal
	--btns[4] = volumeBtn
	return btns
end