system.activate("multitouch")

local director = require("director")

local gl = require("globals")

display.setStatusBar( display.HiddenStatusBar )
system.setIdleTimer( false )

local mainGroup = display.newGroup()

local function main()
	local startSound = audio.loadStream("startSound.mp3")
	audio.play(startSound, {channel = 32, loops = 0, onComplete = function()
		audio.dispose(startSound)
	end})
	audio.setVolume(0.25, {channel = 32})
	mainGroup:insert(director.directorView)
	director:changeScene("splashScreen")
	timer.performWithDelay(500, function () 
									-- версия с загрузкой музыки на сплеш скрине
									gl.loading = display.newImageRect("images/iphone/splashScreenImage.png", gl.w, gl.h)
									gl.loading.x,gl.loading.y = gl.w/2, gl.h/2
									gl.loading.isVisible = false
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
									
									timer.performWithDelay(200, function()
											director:changeScene("level")
										end)
				end )
	return true
end

main()