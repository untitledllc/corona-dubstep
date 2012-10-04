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
	gl.kitAddress = kitAddress

	local configInterface = gl.jsonModule.decode( gl.readFile("configInterface.json", kitAddress) )
	print(#configInterface.soundButtons, gl.choosenSide)

	gl.sceneLength = configInterface.sceneLength
	gl.scenesNum = configInterface.scenesNum
	gl.fullRecordLength = configInterface.sceneLength * configInterface.scenesNum
	gl.showChoiceTime = configInterface.showChoiceTime
	gl.choiceShownDurationTime = configInterface.choiceShownDurationTime
	gl.tracksStartSameTime = configInterface.tracksStartSameTime
	gl.defaultSide = configInterface.defaultSide
	gl.configInterface = configInterface

	local w = gl.w
	local h = gl.h

	local mainGroup = display.newGroup()
	local localGroup = display.newGroup()
	
	local playModule = require("playing")
	layoutAppearTime = system.getTimer()

	local sampleKit = playModule.initSounds(kitAddress)

	for i = 1, gl.scenesNum, 1 do
		gl.buttonsInScenes[i] = {}
	end

	-- Заполняем таблицу, в которой номеру сцены соответствует кнопка и информация о том, нажата она или нет
	for i, val in pairs(configInterface.soundButtons) do
		if val.scenes then
			for j, v in pairs(val.scenes) do
				table.insert(gl.buttonsInScenes[tonumber(j)], {i, v})
			end
		end
	end

	-- создаём сразу все кнопки
	--if gl.tracksStartSameTime then
		for i, v in pairs(configInterface.soundButtons) do
			--if (v.side and v.side == gl.choosenSide) or (not v.side) then
				local b = gl.createButton({["track"] = sampleKit[v.soundId], ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["type"] = sampleKit[v.soundId].type, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["scenes"] = v.scenes, ["soundId"] = v.soundId})
				b.isVisible = false
				b.txt.isVisible = false
				v.button = b
				localGroup:insert(b)
			--end
		end
	--[[ создаём кнопки только первой сцены
	else
		for i, v in pairs(gl.buttonsInScenes[1]) do
			local curBInfo = configInterface.soundButtons[v[1] ]
			if (curBInfo.side and curBInfo.side == gl.choosenSide) or (not curBInfo.side) then
				local b = gl.createButton({["track"] = sampleKit[curBInfo.soundId], ["left"] = curBInfo.left, ["top"] = curBInfo.top, ["width"] = curBInfo.w, ["height"] = curBInfo.h, ["type"] = sampleKit[curBInfo.soundId].type, ["rgb"] = curBInfo.rgb, ["alpha"] = curBInfo.alpha, ["scenes"] = curBInfo.scenes, ["soundId"] = curBInfo.soundId})
				b.isVisible = false
				b.txt.isVisible = false
				configInterface.soundButtons[v[1] ].button = b
				localGroup:insert(b)
			end
		end
	end]]--
	
	

	for i, v in pairs(configInterface.glitchButtons) do
		local b = gl.createGlitchButton({["soundIds"] = v.soundIds, ["left"] = v.left, ["top"] = v.top, ["width"] = v.w, ["height"] = v.h, ["rgb"] = v.rgb, ["alpha"] = v.alpha, ["label"] = v.label})
		localGroup:insert(b)
	end

	gl.btns = gl.drawLayoutBtns()
	
	for idx,val in pairs(gl.btns) do
		val.alpha = 0.5
	end

	for i, v in pairs(configInterface.backGrounds) do
		backs[i] = display.newImageRect(v.fileName,gl.w,gl.h)
		backs[i].x, backs[i].y = gl.w/2,gl.h/2
		backs[i].isVisible = false
	end

	mainGroup:insert(1,backs[1])
	mainGroup:insert(2,localGroup)

	gl.mainGroup = mainGroup
	gl.localGroup = localGroup 
	gl.currentBacks = backs

	playModule.prepareToPlay()

	gl.sceneChangingTimer = timer.performWithDelay(gl.sceneLength, function()
		gl.nextSceneButton:dispatchEvent({name = "touch", phase = "ended"})
	end)

	require("recording").startRecording()
	
	gl.loading.isVisible = false
	
	return mainGroup
end