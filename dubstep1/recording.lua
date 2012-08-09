module (...,package.seeall)

local userActionList = {}
local recPressCounter = 0

local recPressTime = nil
local endRecordingTime = nil
prevRecStartTime = 0

local pl = require("playing")
local gl = require("globals")
local layout = require(gl.currentLayout)

local isRecSwitchedOn = false

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

local function completeUserActList()
	local idx = 1
	while (idx <= #gl.currentKit) do	
		addAction(endRecordingTime - recPressTime,idx,0,0,-1,-1)
		idx = idx + 1
	end
end

local function calcSeekTimeInActiveChannels(activeChannels)
	for idx,val in pairs(activeChannels) do
		if (val[1] ~= -1) then
			addAction(0,val.channel,1,val.volume,val.category,recPressTime - val.startTime)
		end
	end
end

local function saveUserActList()
    local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"w")
    if (not f) then
        print("not ok")
    end
    for idx,val in pairs(userActionList) do
    	f:write(tostring(val["actionTime"]).." ")
		f:write(tostring(val["channel"]).." ")
		f:write(tostring(val["actType"]).." ")
		f:write(tostring(val["volume"]).." ")
		f:write(tostring(val["category"]).." ")
		f:write(tostring(val["channelActiveTime"]).." ")
    end
    f:close()
end

function startRecording(event)
	if (event.phase == "ended") then
		if (recPressCounter % 2 == 0) then
			recPressTime = system.getTimer() - layout.getLayoutAppearTime()
			calcSeekTimeInActiveChannels(pl.getActiveChannels())
			event.target.alpha = 1
			isRecSwitchedOn = true
		else
			endRecordingTime = system.getTimer() - layout.getLayoutAppearTime()
			completeUserActList()
			saveUserActList()
			isRecSwitchedOn = false
			event.target.alpha = 0.5
			printUserActList()
			userActionList = {}
		end
		recPressCounter = recPressCounter + 1
	end
end

function addAction(time,index,actType,vol,category,chActTime)
    local action = {}
	action["actionTime"] = time
	action["channel"] = index
	action["actType"] = actType
	action["volume"] = vol
	action["category"] = category
	action["channelActiveTime"] = chActTime
	userActionList[#userActionList + 1] = action
end

function getRecBeginTime()
	return recPressTime
end

function isRecStarted()
	return isRecSwitchedOn
end
