module (...,package.seeall)

local userActionList = {}
local recPressCounter = 0

local recPressTime = nil

local pl = require("playing")
local gl = require("globals")

local isRecSwitchedOn = false

local function calcSeekTimeInActiveChannels(activeChannels)
	for idx,val in pairs(activeChannels) do
		if (val[1] ~= -1) then
			local action = {}
			action["actionTime"] = 0
			action["channel"] = val.channel
			action["actType"] = 1
			action["volume"] = val.volume
			action["category"] = val.category
			action["channelActiveTime"] = recPressTime - val.startTime
			addAction(action)
		end
	end
	print(#userActionList)
end

--[[local function seekActiveChannels()
	for idx,val in pairs(userActionList) do
		gl.mySeek(val.channelsActiveTime,gl.currentKit[val.channel][1],val.channel,0)
	end
end--]]

local function saveUserActList()
    local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"w")
    if (not f) then
        print("not ok")
    end
    for i,t in pairs(userActList) do
        for j,val in pairs(t) do
           f:write(val)
           f:write(" ")
        end
    end
    f:close()
end

function startRecording(event)
	if (event.phase == "ended") then
		if (recPressCounter % 2 == 0) then
			if (pl.firstTimePlayPressed ~= nil) then
				isRecSwitchedOn = true
				recPressTime = system.getTimer() - pl.firstTimePlayPressed
				event.target.alpha = 1
				calcSeekTimeInActiveChannels(pl.getActiveChannels())
			end
		else
			isRecSwitchedOn = false
			event.target.alpha = 0.5
			userActionList = {}
		end
		recPressCounter = recPressCounter + 1
	end
end

function addAction(action)
	userActionList[#userActionList + 1] = action
end

function getRecBeginTime()
	return recPressTime
end

function isRecStarted()
	return isRecSwitchedOn
end