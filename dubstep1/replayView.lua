module ("replayView",package.seeall)

local w = display.contentWidth
local h = display.contentHeight
local playLine
local playBut
local exitBut
local curplayButPos
local textExit
local textPlay
local playLineLen = w - 20
local playUserActList = {}
local activeActions = {}
local beginPlayTime
local endTrackTime
local sound

local function printUserActList()
    for i,t in pairs(playUserActList) do
        for j,val in pairs(t) do
			print(val)
        end
    end
    print("---------------------------------")
end

local function readAction(file)
	local action = {}
	local i = 1
	while (i <= 3) do
		action[i] = file:read("*number")
		if (action[i] == nil) then
			return nil
		end
		i = i + 1
	end
	return action
end

local function openUserActList()
    local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"r+")
    local act = 0
    while (act) do
    	act = readAction(f)
    	playUserActList[#playUserActList+1] = act
    end
    f:close()
end

local function getNextActionTime(index)
	return playUserActList[index][2]
end

local function getActionActivity(index)
	return playUserActList[index][1]
end

local function getTrackNumber(index)
	return playUserActList[index][3]
end

local function makeAction(index) 
	local track = getTrackNumber(index)
	local playStop = getActionActivity(index)
	local trackName = "Track"..tostring(track)..".wav"
	if (playStop == 1) then
		sound = audio.loadSound(trackName)
		audio.play(sound,{ channel = track,loops = -1})
	else
		audio.stop(track)
	end
end

local function play()
	openUserActList()
	beginPlayTime = system.getTimer()
	relEndTrackTime = playUserActList[#playUserActList][2]
	local relPlayTime = system.getTimer() - beginPlayTime
	local actCounter = 1
	while(relPlayTime < relEndTrackTime) do
		if (math.abs(relPlayTime - playUserActList[actCounter][2]) < 0.01) then
			--print("Arrived here")
			--print(actCounter)
			makeAction(actCounter)
			actCounter = actCounter + 1
		end
		--print(relPlayTime)
		relPlayTime = system.getTimer() - beginPlayTime
	end
	print("finished")
end

local function hideRepView()
	display.remove(playLine)
	display.remove(exitBut)
	display.remove(curPlayPos)
	display.remove(textExit)
	display.remove(textPlay)
	display.remove(playBut)
end

local function showMainForm(event)
	mainForm.showMainForm()
end

local function onExit(event)
	hideRepView()
	timer.performWithDelay(1000, showMainForm)
end

local function onPlay(event)
	if (event.phase == "ended") then
		play()
	end
end

local function bindListeners() 
	exitBut:addEventListener("touch",onExit)
	playBut:addEventListener("touch",onPlay)
end

function showRepView()
	playBut = display.newRoundedRect(1,1,w/3,h/12,12)
	curPlayPos = display.newRect(1,1,5,20)
	playLine = display.newLine(10,h/2,w-10,h/2)
	exitBut = display.newRoundedRect(1, 1, w/3, h/12, 12)
	textExit = display.newText("Exit", 0, 0, native.systemFont, 24)
	textPlay = display.newText("Play", 0, 0, native.systemFont, 24)
	
	playLine:setColor(255,0,0)
	playLine.width = 5 
	
	curPlayPos.x,curPlayPos.y = 10,h/2
	
	exitBut.x, exitBut.y = 2*w/3-5, 2*h/3
	
	playBut.x, playBut.y = w/3-5, 2*h/3
	
	textExit.x,textExit.y = 2*w/3, 2*h/3
	textPlay.x,textPlay.y = w/3, 2*h/3
	
	textExit:setTextColor(0,0,0)
	textPlay:setTextColor(0,0,0)
	
	bindListeners()
end