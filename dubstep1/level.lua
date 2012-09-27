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

	local kitAddress = gl.currentLayout.."/"

	local configInterface = gl.jsonModule.decode( gl.readFile("configInterface.json", kitAddress) )

	gl.scenesNum = configInterface.scenesNum
	gl.fullRecordLength = configInterface.sceneLength * configInterface.scenesNum
	gl.showChoiceTime = configInterface.showChoiceTime
	gl.choiceShownDurationTime = configInterface.choiceShownDurationTime

	local w = gl.w
	local h = gl.h

	local mainGroup = display.newGroup()
	local localGroup = display.newGroup()
	
	local playModule = require("playing")
	layoutAppearTime = system.getTimer()

	local sampleKit = playModule.initSounds(kitAddress)

	for i, v in pairs(configInterface.soundButtons) do
		local b = gl.createButton({["track"] = sampleKit[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = sampleKit[v.soundId].type, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId})
		b.isVisible = false
		b.txt.isVisible = false
		localGroup:insert(b)
	end

	for i, v in pairs(configInterface.glitchButtons) do
		local b = gl.createGlitchButton({["soundIds"] = v.soundIds, ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["label"] = v.label})
		localGroup:insert(b)
	end

	gl.btns = gl.drawLayoutBtns()
	
	for idx,val in pairs(gl.btns) do
		gl.btns[idx].alpha = 0.5
	end
	
	for i = 1, gl.scenesNum + 1, 1 do
		backs[i] = display.newImageRect("images/"..gl.currentLayout.."/back"..i..".jpg",gl.w,gl.h)
		backs[i].x, backs[i].y = gl.w/2,gl.h/2
		backs[i].isVisible = false
	end

	mainGroup:insert(1,backs[1])
	mainGroup:insert(2,localGroup)

	gl.mainGroup = mainGroup
	gl.localGroup = localGroup 
	gl.currentBacks = backs

	playModule.prepareToPlay()

	--require("recording").startRecording()
	
	gl.loading.isVisible = false
	
	return mainGroup
end