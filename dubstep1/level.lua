module(...,package.seeall)
local widget = require "widget"

atOncePlay = nil

local layoutAppearTime = nil

local backs = {}

continueButton = nil

function getLayoutBacks()
	return backs
end

function getLayoutAppearTime()
	return layoutAppearTime
end

function new()

	local gl = require("globals")

	if gl.toEndTimerFunc then
		Runtime:removeEventListener("enterFrame", gl.toEndTimerFunc)
	end
	
	if gl.toNextSceneTimerFunc then
		Runtime:removeEventListener("enterFrame", gl.toNextSceneTimerFunc)
	end

	local w = gl.w
	local h = gl.h

	local firstScreenBackground = display.newImageRect("images/iphone/dubstepIphoneFirstScreen.png", w, h)
	firstScreenBackground.x, firstScreenBackground.y = w/2, h/2
	 
	local playModule = require("playing")

	function continuePress(event)
		if event.phase == "release" then

			audio.stop()
			for i, v in pairs(gl.soundsConfig) do
				if v.type == "melody" then
					if v.sound then
						audio.rewind(v.sound)
					end
					v.channel = nil
				end
			end

			firstScreenBackground.isVisible = false
			continueButton.isVisible = false

			gl.currentLayout = "layout2"
			gl.choosenSide = "evil"
			gl.inLevel = true

			audio.stop(32)

			gl.btns = gl.drawLayoutBtns()
	
			for idx,val in pairs(gl.btns) do
				val.alpha = 1
				--val.isVisible = false
				--val.txt.isVisible = false
			end

			for i, v in pairs(gl.configInterface.glitchButtons) do
				v.button.isVisible = true
			end

			gl.voicesBack1.isVisible = true
			gl.voicesBack2.isVisible = true

			layoutAppearTime = system.getTimer()

			playModule.prepareToPlay()

			gl.sceneChangingTimer = timer.performWithDelay(gl.sceneLength, function()
				gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
			end)

			require("recording").startRecording()
			
			gl.loading.isVisible = false
		end
	end
	require("recording").userActionList = {}
	continueButton = widget.newButton{
		id = "continue",
		left = 335,
		top = 220,
		default = "images/elements/continueButton.png",
		over = "images/elements/continueButtonPressed.png",
		width = 77,
		height = 38,
		onEvent = continuePress
	}

	local mainGroup = display.newGroup()
	local localGroup = display.newGroup()
	
	gl.voicesBack1 = display.newImageRect("images/elements/voicesGroup.png", 159, 128)
	gl.voicesBack1:setReferencePoint(display.TopLeftReferencePoint)
	gl.voicesBack1.x, gl.voicesBack1.y = 320, 63
	gl.voicesBack1.isVisible = false

	gl.voicesBack2 = display.newImageRect("images/elements/voicesGroup.png", 159, 128)
	gl.voicesBack2:setReferencePoint(display.TopLeftReferencePoint)
	gl.voicesBack2.x, gl.voicesBack2.y = 320, 191
	gl.voicesBack2.isVisible = false

	gl.navBar = display.newGroup()
	for i = 1, 120 do
		local navBarPart = display.newImageRect("images/elements/navBar.png", 4, 43)
		navBarPart.x, navBarPart.y = 2 + 4*(i-1), 21
		gl.navBar:insert(navBarPart)
	end

	localGroup:insert(gl.voicesBack1)
	localGroup:insert(gl.voicesBack2)
	localGroup:insert(gl.navBar)

	for i, v in pairs(gl.configInterface.soundButtons) do
		local b
		if v.resizable then
			b = gl.createResizableButton({["track"] = gl.soundsConfig[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = gl.soundsConfig[v.soundId].type, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId, ["default"] = v.default, ["over"] = v.over})

		else
			b = gl.createButton({["track"] = gl.soundsConfig[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = gl.soundsConfig[v.soundId].type, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId, ["label"] = v.label, ["default"] = v.default, ["over"] = v.over})
			
		end
		b.isVisible = false
		--b.txt.isVisible = false
		v.button = b
		localGroup:insert(b)
	end

	for i, v in pairs(gl.configInterface.glitchButtons) do
		local b = gl.createGlitchButton({["soundIds"] = v.soundIds, ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["label"] = v.label, ["default"] = v.default, ["over"] = v.over, ["id"] = v.id})
		b.isVisible = false
		--b.txt.isVisible = false
		v.button = b
		localGroup:insert(b)
	end

	

	for i, v in pairs(gl.configInterface.backGrounds) do
		backs[i] = display.newImageRect(v.fileName,gl.w,gl.h)
		backs[i].x, backs[i].y = gl.w/2,gl.h/2
		backs[i].isVisible = false
	end

	

	mainGroup:insert(backs[1])
	mainGroup:insert(localGroup)
	mainGroup:insert(firstScreenBackground)
	mainGroup:insert(continueButton)

	gl.mainGroup = mainGroup
	gl.localGroup = localGroup 
	gl.currentBacks = backs

	gl.deltaTime = 0

	if atOncePlay then
		timer.performWithDelay(200, function()
			continuePress({name = "buttonEvent", phase = "release"})
		end)
	end
	return mainGroup
end