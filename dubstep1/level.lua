module(...,package.seeall)

local layoutAppearTime = nil

local backs = {}

function getLayoutBacks()
	return backs
end

function getLayoutAppearTime()
	return layoutAppearTime
end

function new()
	local gl = require("globals")
	audio.stop(32)
	local w = gl.w
	local h = gl.h

	local mainGroup = display.newGroup()
	local localGroup = display.newGroup()
	
	local playModule = require("playing")

	for i, v in pairs(gl.configInterface.soundButtons) do
		local b = gl.createButton({["track"] = gl.soundsConfig[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = gl.soundsConfig[v.soundId].type, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId, ["label"] = v.label})
		b.isVisible = false
		b.txt.isVisible = false
		v.button = b
		localGroup:insert(b)
	
	end

	for i, v in pairs(gl.configInterface.glitchButtons) do
		local b = gl.createGlitchButton({["soundIds"] = v.soundIds, ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["label"] = v.label})
		localGroup:insert(b)
	end

	gl.btns = gl.drawLayoutBtns()
	
	for idx,val in pairs(gl.btns) do
		val.alpha = 0.5
	end

	for i, v in pairs(gl.configInterface.backGrounds) do
		backs[i] = display.newImageRect(v.fileName,gl.w,gl.h)
		backs[i].x, backs[i].y = gl.w/2,gl.h/2
		backs[i].isVisible = false
	end

	mainGroup:insert(1,backs[1])
	mainGroup:insert(2,localGroup)

	gl.mainGroup = mainGroup
	gl.localGroup = localGroup 
	gl.currentBacks = backs

	layoutAppearTime = system.getTimer()

	playModule.prepareToPlay()

	gl.sceneChangingTimer = timer.performWithDelay(gl.sceneLength, function()
		gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
	end)

	require("recording").startRecording()
	
	gl.loading.isVisible = false
	
	return mainGroup
end