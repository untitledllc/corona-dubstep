module (...,package.seeall)

local userActionList = {}

local actionSize = 6

local function printUserActList()
	for idx,val in pairs(userActionList) do
		print("actionTime = ",val["actionTime"])
		print("Channel = ",val["channel"])
		print("actionType = ",val["actType"])
		print("Volume = ",val["volume"])
		print("Category = ",val["category"])
		print("channelActiveTime = ",val["channelActiveTime"])
		print("\n")
	end
	print("-----------------------------------------------")
end

local function readAction(file)
	local action = {}

	action["actionTime"] = file:read("*number")
	
	if (action["actionTime"] == nil) then
		return nil
	end
	
	action["channel"] = file:read("*number")
	action["actType"] = file:read("*number")
	action["volume"] = file:read("*number")
	action["category"] = file:read("*number")
	action["channelActiveTime"] = file:read("*number")

	return action
end

local function openUserActList()
	local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"r")
    local act = 0
    while (act) do
    	act = readAction(f)
    	userActionList[#userActionList+1] = act
    end
    f:close()
end

function new()
	local gl = require("globals")
	
	local w = gl.w
	local h = gl.h
	
	local localGroup = display.newGroup()
	
	local playBtn = display.newRoundedRect(1,1,w/3,h/12,12)
	local stopBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	local playLine = display.newRect(1,1,w-10,10)
	local curPlayPos = display.newRect(1,1,15,20)
	local exitBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	local txtExit = display.newText("Exit", 0, 0, native.systemFont, 24)
	local txtPlay = display.newText("Play", 0, 0, native.systemFont, 24)
	local txtStop= display.newText("Stop", 0, 0, native.systemFont, 24)
	
	local playPressCounter = 0
	
	local function prepareToReplay()
		idx = 1
		while (idx <= gl.currentNumSamples) do
			audio.play(gl.currentKit[idx][1],{channel = idx,loops = -1})
			audio.setVolume(0,{channel = idx})
			idx = idx + 1
		end
	end
	
	local function findSeekSamplesTime()
		local idx = 1
		while (userActionList[idx].actionTime == 0) do
			if (userActionList[idx].category <= 3) then
				return userActionList[idx].channelActiveTime
			end
			idx = idx + 1
		end
		return nil
	end
	
	local function makePreRecordActions()
		local idx = 1
		local toSeekSampleTime = findSeekSamplesTime()
		while (userActionList[idx].actionTime == 0) do
			if (userActionList[idx].category <= 3) then
				gl.mySeek(toSeekSampleTime,
					gl.currentKit[userActionList[idx].channel][1],
								userActionList[idx].channel,-1)
				audio.setVolume(userActionList[idx].volume,
						{channel = userActionList[idx].channel})
			else
				gl.mySeek(userActionList[idx].channelActiveTime,
					gl.currentKit[userActionList[idx].channel][1],
								userActionList[idx].channel,0)
			end
			idx = idx + 1
		end
	end
	
	local function play(event)
		if (event.phase == "ended") then
			if (playPressCounter % 2 == 0) then
				makePreRecordActions()
			else
				audio.stop()
			end
		end
	end
	
	local function stop(event)
		if (event.phase == "ended") then
			audio.stop()
		end
	end
	
	local function exit(event)
		if (event.phase == "ended") then
			director:changeScene(gl.currentLayout)
		end
	end
	
	local function bindListeners()
		playBtn:addEventListener("touch",play)
		stopBtn:addEventListener("touch",stop)
		exitBtn:addEventListener("touch",exit)
	end
	
	playLine:setFillColor(255,0,0)

	playLine.x,playLine.y = w/2,h/2
	curPlayPos.x,curPlayPos.y = 10,h/2
	exitBtn.x, exitBtn.y = w/2, 5*h/6
	playBtn.x, playBtn.y = w/3-5, 2*h/3
	stopBtn.x, stopBtn.y = 2*w/3-5, 2*h/3

	txtExit.x,txtExit.y = w/2, 5*h/6
	txtPlay.x,txtPlay.y = w/3, 2*h/3
	txtStop.x,txtStop.y = 2*w/3-5, 2*h/3

	txtExit:setTextColor(0,0,0)
	txtPlay:setTextColor(0,0,0)
	txtStop:setTextColor(0,0,0)

	localGroup:insert(playBtn)
	localGroup:insert(stopBtn)
	localGroup:insert(playLine)
	localGroup:insert(curPlayPos)
	localGroup:insert(exitBtn)
	localGroup:insert(txtExit)
	localGroup:insert(txtPlay)
	localGroup:insert(txtStop)

	bindListeners()	
	
	prepareToReplay()
	
	openUserActList()
	
	return localGroup
end
