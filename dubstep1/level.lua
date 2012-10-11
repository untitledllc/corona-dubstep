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
	local w = gl.w
	local h = gl.h

	local firstScreenBackground = display.newImageRect("images/iphone/dubstepIphoneFirstScreen.png", w, h)
	firstScreenBackground.x, firstScreenBackground.y = w/2, h/2
	 
	local playModule = require("playing")

	function continuePress(event)
		if event.phase == "release" then
			firstScreenBackground.isVisible = false
			continueButton.isVisible = false

			gl.currentLayout = "layout2"
			gl.choosenSide = "evil"
			gl.inLevel = true

			audio.stop(32)

			for idx,val in pairs(gl.btns) do
				if idx == 3 then
					break
				end
				val.isVisible = true
				val.txt.isVisible = true
			end
			gl.nextSceneButton.isVisible = true
			gl.nextSceneButton.txt.isVisible = true

			layoutAppearTime = system.getTimer()

			playModule.prepareToPlay()

			gl.sceneChangingTimer = timer.performWithDelay(gl.sceneLength, function()
				gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
			end)

			require("recording").startRecording()
			
			gl.loading.isVisible = false
		end
	end

	continueButton = widget.newButton{
		id = "continue",
		left = 7*w/10,
		top = 2*h/3,
		default = "images/elements/continueButton.png",
		over = "images/elements/continueButtonPressed.png",
		width = 80,
		height = 40,
		onEvent = continuePress
	}

	local mainGroup = display.newGroup()
	local localGroup = display.newGroup()
	
	

	for i, v in pairs(gl.configInterface.soundButtons) do
		local b = gl.createButton({["track"] = gl.soundsConfig[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = gl.soundsConfig[v.soundId].type, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId, ["label"] = v.label})
		b.isVisible = false
		b.txt.isVisible = false
		v.button = b
		localGroup:insert(b)
	
	end

	for i, v in pairs(gl.configInterface.glitchButtons) do
		local b = gl.createGlitchButton({["soundIds"] = v.soundIds, ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["label"] = v.label})
		b.isVisible = false
		b.txt.isVisible = false
		localGroup:insert(b)
	end

	gl.btns = gl.drawLayoutBtns()
	
	for idx,val in pairs(gl.btns) do
		val.alpha = 0.5
		val.isVisible = false
		val.txt.isVisible = false
	end

	for i, v in pairs(gl.configInterface.backGrounds) do
		backs[i] = display.newImageRect(v.fileName,gl.w,gl.h)
		backs[i].x, backs[i].y = gl.w/2,gl.h/2
		backs[i].isVisible = false
	end

	gl.nextSceneButton.isVisible = false
	gl.nextSceneButton.txt.isVisible = false

	mainGroup:insert(1, backs[1])
	mainGroup:insert(2, localGroup)
	mainGroup:insert(3, firstScreenBackground)
	mainGroup:insert(4, continueButton)

	gl.mainGroup = mainGroup
	gl.localGroup = localGroup 
	gl.currentBacks = backs

	if atOncePlay then
		continuePress({name = "buttonEvent", phase = "release"})
	end
	return mainGroup
end