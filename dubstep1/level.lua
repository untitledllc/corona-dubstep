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

	local myW = gl.myW
	local myH = gl.myH

	local vW = gl.vW
	local vH = gl.vH

	local firstScreenBackground = display.newImageRect("images/iphone/dubstepIphoneFirstScreen.png", vW, vH)
	firstScreenBackground.x, firstScreenBackground.y = w/2, h/2
	 
	local playModule = require("playing")

	local mainGroup = display.newGroup()
	local localGroup = display.newGroup()

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
			gl.glitchTxt.isVisible = true
			--gl.glitchTxtShadow.isVisible = true

			layoutAppearTime = system.getTimer()

			playModule.prepareToPlay()

			gl.sceneChangingTimer = timer.performWithDelay(gl.sceneLength, function()
				gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
			end)

			gl.toNextSceneTime = 9999
			gl.toFinalTime = 9999

			localGroup:insert(gl.btn1)
			localGroup:insert(gl.btn2)
			localGroup:insert(gl.repBtn)
			localGroup:insert(gl.menuButtonFinal)
			localGroup:insert(gl.glitchTxt)
			localGroup:insert(gl.nextSceneButton)
			localGroup:insert(gl.nextSceneButton.txt)
			localGroup:insert(gl.sceneNumberShadow)
			localGroup:insert(gl.sceneNumber)
			localGroup:insert(gl.timerTxt)
			localGroup:insert(gl.nextSceneTimerTxt)

			-- DEBUG 
			--gl.glIndicator = display.newRect(170 ,245, 40, 40)
			--gl.glIndicator:setFillColor(190, 40, 80)
			--gl.glIndicator.isVisible = true

			-----

			require("recording").startRecording()
			
			
		end
	end
	require("recording").userActionList = {}
	continueButton = widget.newButton{
		id = "continue",
		left = 335*gl.coefW + display.screenOriginX,
		top = 220*gl.coefH + display.screenOriginY,
		default = "images/elements/continueButton.png",
		over = "images/elements/continueButtonPressed.png",
		width = 77*gl.sizeCoef,
		height = 38*gl.sizeCoef,
		onEvent = continuePress
	}

	
	
	gl.voicesBack1 = display.newImageRect("images/elements/voicesGroup.png", 159*gl.coefW, 128*gl.coefH)
	gl.voicesBack1:setReferencePoint(display.TopLeftReferencePoint)
	gl.voicesBack1.x, gl.voicesBack1.y = 320*gl.coefW + display.screenOriginX, 63*gl.coefH + display.screenOriginY
	gl.voicesBack1.isVisible = false

	gl.voicesBack2 = display.newImageRect("images/elements/voicesGroup.png", 159*gl.coefW, 128*gl.coefH)
	gl.voicesBack2:setReferencePoint(display.TopLeftReferencePoint)
	gl.voicesBack2.x, gl.voicesBack2.y = 320*gl.coefW + display.screenOriginX, 191*gl.coefH + display.screenOriginY
	gl.voicesBack2.isVisible = false

	gl.navBar = display.newGroup()
	for i = 1, 120 do
		local navBarPart = display.newImageRect("images/elements/navBar.png", 4*gl.coefW, 43*gl.coefH)
		navBarPart.x, navBarPart.y = (2 + 4*(i-1) )*gl.coefW + display.screenOriginX, 21*gl.coefH + display.screenOriginY
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
		backs[i] = display.newImageRect(v.fileName,gl.vW,gl.vH)
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
		timer.performWithDelay(50, function()
			continuePress({name = "buttonEvent", phase = "release"})
		end)
	end
	--gl.loading:removeSelf()
	return mainGroup
end