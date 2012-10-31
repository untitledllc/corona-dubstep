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

	local function showAd(event)
		if event.isError then
			print("Failed to receive an ad")
		end
		if gl.ads.width and gl.ads.height then
			print("sizes: ",gl.ads.width, gl.ads.height)
		end
	end
	gl.ads.init("inneractive", "itsbeta_RomneyDubtest_Android", showAd)

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

	local firstScreenBackground = display.newImageRect("images/iphone/splashScreenImage.png", w, h)
	firstScreenBackground.x, firstScreenBackground.y = w/2, h/2

	local title = display.newImageRect("images/iphone/dubstep.png",182*gl.sizeCoef, 30*gl.sizeCoef)
	title:setReferencePoint(display.TopLeftReferencePoint)
	title.x, title.y = 300 * gl.coefW + display.screenOriginX, 162 * gl.coefH + display.screenOriginY
	 
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

			--firstScreenBackground.isVisible = false
			firstScreenBackground:removeSelf()
			firstScreenBackground = nil
			--title.isVisible = false
			title:removeSelf()
			title = nil
			--continueButton.isVisible = false
			continueButton:removeSelf()
			continueButton = nil

			
			print("this1")
				backs[1] = display.newImageRect(gl.configInterface.backGrounds[1].fileName, w, h)
				backs[1].isVisible = false
				backs[1].x, backs[1].y = gl.w/2, gl.h/2
				
			print("this2")
			timer.performWithDelay(3000, function()
				print("this3")
				backs[2] = display.newImageRect(gl.configInterface.backGrounds[2].fileName, w, h)
				backs[2].isVisible = false
				backs[2].x, backs[2].y = gl.w/2, gl.h/2
				
				print("this4")
			end)
			
			print("this2.5")
			mainGroup:insert(1, backs[1])

			gl.currentLayout = "layout2"
			gl.choosenSide = "evil"
			gl.inLevel = true

			audio.stop(32)

			-- adversity
			
			gl.ads.show( "banner", { x=(240*gl.coefW + display.screenOriginX), y=(0*gl.coefH + display.screenOriginY), interval=30, testMode = true } )
			
			------------

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

			--localGroup:insert(gl.btn1)
			--localGroup:insert(gl.btn2)
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
		local navBarPart = display.newImageRect("images/elements/navBar.png", 4*gl.coefW, 55*gl.coefH)
		navBarPart.x, navBarPart.y = (2 + 4*(i-1) )*gl.coefW + display.screenOriginX, 55*gl.coefH/2 + display.screenOriginY
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
	




	mainGroup:insert(localGroup)
	mainGroup:insert(firstScreenBackground)
	mainGroup:insert(title)
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
	--native.showAlert("alert3", "alert3", {"ok"})
	--gl.loading:removeSelf()
	return mainGroup
end