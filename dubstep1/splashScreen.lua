module (...,package.seeall)

local director = require("director")

local gl = require("globals")

function new()
	local localGroup = display.newGroup()
	local splashImage = display.newImageRect("images/iphone/splashScreenImage.png",gl.vW, gl.vH)
	
	splashImage.x,splashImage.y = gl.w/2, gl.h/2

	localGroup:insert(splashImage)

	local startSound = audio.loadStream("startSound.mp3")
	audio.play(startSound, {channel = 32, loops = 0, onComplete = function()
		audio.dispose(startSound)
	end})
	audio.setVolume(0.25, {channel = 32})
	
	timer.performWithDelay(500, function () 
									-- версия с загрузкой музыки на сплеш скрине
									gl.loading = display.newImageRect("images/iphone/splashScreenImage.png", gl.vW, gl.vH)
									gl.loading.isVisible = false
									gl.loading.x,gl.loading.y = gl.w/2, gl.h/2
									
									--transition.to(gl.loading, {time = 3000, rotation = 360})
									gl.currentLayout = "layout2"
									local kitAddress = gl.currentLayout.."/"
									gl.kitAddress = kitAddress

									local configInterface = gl.jsonModule.decode( gl.readFile("configInterface.json", kitAddress) )

									gl.sceneLength = configInterface.sceneLength
									gl.scenesNum = configInterface.scenesNum
									gl.fullRecordLength = configInterface.sceneLength * configInterface.scenesNum
									gl.showChoiceTime = configInterface.showChoiceTime
									gl.choiceShownDurationTime = configInterface.choiceShownDurationTime
									gl.tracksStartSameTime = configInterface.tracksStartSameTime
									gl.defaultSide = configInterface.defaultSide
									gl.configInterface = configInterface
									
									local playModule = require("playing")

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
									
									timer.performWithDelay(100, function()
											director:changeScene("level")
										end)
				end )
	
	return localGroup
end