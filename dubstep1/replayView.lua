module ("replayView",package.seeall)

local w = display.contentWidth
local h = display.contentHeight

local playLine
local playBtn
local exitBtn
local pauseBtn
local curPlayPos
local stopBtn

local scrollTransition = nil

local txtExit
local txtPlay
local txtPause
local txtStop

local playLineLen = w - 20
local playUserActList = {}

local beginPlayTime = 0
local relPlayTime = 2
local relEndTrackTime = 1
local pausePressTime = 0
local firstTimePlayPressed = nil
local sumPauseTime = 0

local actCounter = 1
local isPaused = false
local playPressCounter = 0
local state

local function printUserActList()
    for i,t in pairs(playUserActList) do
        for j,val in pairs(t) do
			print(val)
        end
        print("\n")
    end
    print("---------------------------------")
end

local function readAction(file)
	local action = {}
	local i = 1
	while (i <= 4) do
		action[i] = file:read("*number")
		if (action[i] == nil) then
			return nil
		end
		i = i + 1
	end
	return action
end

local function openUserActList()
	playUserActList = {}
    local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"r")
    local act = 0
    while (act) do
    	act = readAction(f)
    	playUserActList[#playUserActList+1] = act
    end
    f:close()
end

local function getActionTime(index)
	return playUserActList[index][1]
end

local function getActionActivity(index)
	return playUserActList[index][3]
end

local function getTrackNumber(index)
	return playUserActList[index][2]
end

local function calcPrerecordedTracks() 
	local i = 1
	local resTable = {}
	for idx,val in pairs(playUserActList) do
		if (val[4] ~= -1 and val[1] == 0) then
			resTable[#resTable + 1] = val[2]
		end
	end
	return resTable
end

local function seekActiveTracks() 
	local idx = 1	
	local actTracks = calcPrerecordedTracks()
	while (idx <= #actTracks) do
		audio.play(tracks[actTracks[idx]][1],{channel = actTracks[idx], loops = -1})	
		audio.seek(playUserActList[idx][4] + beginPlayTime - sumPauseTime,
			{channel = actTracks[idx]})
		idx = idx + 1
	end
end

local function makeAction(index,delta) 
	local track = getTrackNumber(index)
	local playStop = getActionActivity(index)
	local actTime = getActionTime(index)
	
	if (track == -1) then 
		audio.stop(0)
		return true
	end
	
	if (playStop == 1) then
		if (actTime == 0) then
			seekActiveTracks()
		else
			audio.play(tracks[track][1],{channel = track,loops = -1})	
			audio.seek(delta,{channel = track})
		end
	else
		audio.stop(track)
	end
	return false
end

local function play(event)
	if (relPlayTime <= relEndTrackTime and isPaused == false) then
		if (relPlayTime > playUserActList[actCounter][1]) then
			local delta = relPlayTime - playUserActList[actCounter][1]
			state = makeAction(actCounter,delta)
			if (state == true) then
				return
			else
				actCounter = actCounter + 1		
			end
		end
		relPlayTime = relPlayTime + 16----system.getTimer() - firstTimePlayPressed - sumPauseTime
		--print(relPlayTime)
	end
end

local function hideRepView()
	display.remove(playLine)
	display.remove(exitBtn)
	display.remove(curPlayPos)
	display.remove(txtExit)
	display.remove(txtPlay)
	display.remove(playBtn)
	display.remove(stopBtn)
	display.remove(txtStop)

	Runtime:removeEventListener("enterFrame",play)
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
		if (playPressCounter % 2 == 0) then
			if (playPressCounter == 0) then			
				openUserActList()
				printUserActList()
				firstTimePlayPressed = system.getTimer()		
				relEndTrackTime = playUserActList[#playUserActList][1] + 100
				relPlayTime = 0
				--beginPlayTime = 0
			else 
				audio.resume()
				--beginPlayTime = system.getTimer() - firstTimePlayPressed
				--sumPauseTime = sumPauseTime + beginPlayTime - pausePressTime
				--relPlayTime = system.getTimer() - firstTimePlayPressed - sumPauseTime
			end
					
			scrollTransition = transition.to(curPlayPos,
					{time=relEndTrackTime - relPlayTime,x=(w-10)})
			
			actCounter = 1
		
			txtPlay.text = "Pause"
		
			isPaused = false
		
			play()
		else
			audio.pause()		
			txtPlay.text = "Play"
			transition.cancel(scrollTransition)
			--pausePressTime = system.getTimer() - firstTimePlayPressed
			isPaused = true
		end
		playPressCounter = playPressCounter + 1
	end
end

local function onStop(event)
	local idx = 1
	while (idx <= numTracks) do
		audio.stop(idx)
		idx = idx + 1
	end
	transition.cancel(scrollTransition)
	curPlayPos.x = 10
	playUserActList = {}
	relPlayTime = 2
	relEndTrackTime = 1
	txtPlay.text = "Play"
	playPressCounter = 0
	sumPauseTime = 0
end

local function onSeek(event)
	if (event.phase == "ended") then
		transition.cancel(scrollTransition)
		audio.stop(0)
		curPlayPos.x = event.x
		--[[if (playPressCounter == 0) then 
			openUserActList()
			printUserActList()
			firstTimePlayPressed = system.getTimer()		
			relEndTrackTime = playUserActList[#playUserActList][1] + 100		
			relPlayTime = 0
			beginPlayTime = 0
			playPressCounter = 1
		end--]]
		local relPlayTime = (event.x - 10)/(w-20)*relEndTrackTime
		print(relPlayTime)
	end
end

local function bindListeners() 
	exitBtn:addEventListener("touch",onExit)
	playBtn:addEventListener("touch",onPlay)
	stopBtn:addEventListener("touch",onStop)
	playLine:addEventListener("touch",onSeek)
	Runtime:addEventListener("enterFrame",play)
end

function showRepView()
	playBtn = display.newRoundedRect(1,1,w/3,h/12,12)
	stopBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	playLine = display.newRect(1,1,w-10,10)
	curPlayPos = display.newRect(1,1,15,20)
	exitBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	txtExit = display.newText("Exit", 0, 0, native.systemFont, 24)
	txtPlay = display.newText("Play", 0, 0, native.systemFont, 24)
	txtStop= display.newText("Stop", 0, 0, native.systemFont, 24)

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

	bindListeners()
	
	playPressCounter = 0
end