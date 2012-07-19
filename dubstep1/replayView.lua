module ("replayView",package.seeall)

local w = display.contentWidth
local h = display.contentHeight
local playLine
local playBtn
local exitBtn
local pauseBtn
local curPlayPos
local txtExit
local txtPlay
local txtPause
local playLineLen = w - 20
local playUserActList = {}
local beginPlayTime
local relPlayTime = 2
local relEndTrackTime = 1
local sound
local actCounter = 1
local speed
local isPaused = false
local isPlayed = false

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

local function getNextActionTime(index)
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
	local result = 0
	for idx,val in pairs(playUserActList) do
		if (val[4] ~= -1) then
			result = result + 1
		end
	end
	return result
end

local function makeAction(index) 
	local track = getTrackNumber(index)
	local playStop = getActionActivity(index)
	local trackName = "Track"..tostring(track)..".mp3"
	if (playStop == 1) then
		sound = audio.loadSound(trackName)
		audio.play(sound,{ channel = track,loops = 1})
	else
		audio.stop(track)
		audio.dispose(track)
	end
end

local function pauseActiveChannels()
	if (audio.isChannelPlaying(1)) then
		audio.pause(1)
	end
	if (audio.isChannelPlaying(2)) then
		audio.pause(2)
	end
	if (audio.isChannelPlaying(3)) then
		audio.pause(3)
	end
	isPaused = true
end

local function seekActiveTracks(quaActTracks) 
	local idx = 1	
	while (idx <= quaActTracks) do
		print("HERE")
		audio.play(mainForm.tracks[idx][1])
		audio.seek(playUserActList[idx][4],mainForm.tracks[idx][1])
		--audio.pause(playUserActList[idx][2])
		idx = idx + 1
	end
end

local function resumePausedChannels()
	if (audio.isChannelPaused(1)) then
		audio.resume(1)
	end
	if (audio.isChannelPaused(1)) then
		audio.resume(2)
	end
	if (audio.isChannelPaused(1)) then
		audio.resume(3)
	end
	isPaused = false
end

local function play(event)
	if (relPlayTime <= relEndTrackTime) then
		if (math.abs(relPlayTime - playUserActList[actCounter][1]) < 20) then
			makeAction(actCounter)
			actCounter = actCounter + 1
		end
		curPlayPos.x = curPlayPos.x + speed*16
		relPlayTime = system.getTimer() - beginPlayTime
	end
end

local function hideRepView()
	display.remove(playLine)
	display.remove(exitBtn)
	display.remove(curPlayPos)
	display.remove(txtExit)
	display.remove(txtPlay)
	display.remove(playBtn)
	display.remove(pauseBtn)
	display.remove(txtPause)
	
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
		curPlayPos.x = 10
		openUserActList()
		printUserActList()
		beginPlayTime = system.getTimer()
		relEndTrackTime = playUserActList[#playUserActList][1]
		relPlayTime = system.getTimer() - beginPlayTime
		actCounter = 1
		speed = (w - 20)/relEndTrackTime
		isPlayed = true
		seekActiveTracks(calcPrerecordedTracks())
		--play()
	end
end

local function onPause(event) 
	if (event.phase == "ended") then
		isPaused = true
	end
end

local function bindListeners() 
	exitBtn:addEventListener("touch",onExit)
	playBtn:addEventListener("touch",onPlay)
	pauseBtn:addEventListener("touch",onPause)
	Runtime:addEventListener("enterFrame",play)
end

function showRepView()
	playBtn = display.newRoundedRect(1,1,w/3,h/12,12)
	pauseBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	curPlayPos = display.newRect(1,1,5,20)
	playLine = display.newLine(10,h/2,w-10,h/2)
	exitBtn = display.newRoundedRect(1, 1, w/3, h/12, 12)
	txtExit = display.newText("Exit", 0, 0, native.systemFont, 24)
	txtPlay = display.newText("Play", 0, 0, native.systemFont, 24)
	txtPause = display.newText("Pause", 0, 0, native.systemFont, 24)
	
	playLine:setColor(255,0,0)
	playLine.width = 5 
	
	curPlayPos.x,curPlayPos.y = 10,h/2
	exitBtn.x, exitBtn.y = w/2, 5*h/6
	playBtn.x, playBtn.y = w/3-5, 2*h/3
	pauseBtn.x,pauseBtn.y = 2*w/3-5, 2*h/3
	
	txtExit.x,txtExit.y = w/2, 5*h/6
	txtPlay.x,txtPlay.y = w/3, 2*h/3
	txtPause.x,txtPause.y = 2*w/3-5, 2*h/3
	
	txtExit:setTextColor(0,0,0)
	txtPlay:setTextColor(0,0,0)
	txtPause:setTextColor(0,0,0)
	
	bindListeners()
end