isOkSaveDialogPressed = nil
numTracks = 12
numVoices = 3
tracks = {}
require "saveRecDialog"
require "replayView"
module ("mainForm",package.seeall)

local userActList = {}
local action = {}
local relatTime = 0
local isRecStarted = false

local w = display.contentWidth
local h = display.contentHeight

local activeTracks = {}
local activeTime = {}
local trackCounters = {}

local playPressFirstTime = nil

local btns = {}

local btn1 = nil
local btn2
local btn3
local btn4
local recBtn
local repBtn

local txtBtn1
local txtBtn2
local txtBtn3
local txtBtn4
local txtRecBtn
local txtRepBtn

local function resetCounters() 
	local i = 1
	while (i <= numTracks + 1) do
		trackCounters[i] = 0
		i = i + 1
	end
end

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

local function printUserActList()
    for i,t in pairs(userActList) do
        for j,val in pairs(t) do
			print(val)
        end
        print("\n")
    end
    print("---------------------------------")
end

local function printActiveTracks()
    for i,t in pairs(activeTracks) do
        for j,val in pairs(t) do
			print(val)
			print("#####")
        end
    end
    print("---------------------------------")
end

local function playTrack(trIndex)
	if (playPressFirstTime == nil)  then
		playPressFirstTime = system.getTimer()
		local idx = 1
		while (idx <= numTracks-numVoices) do
			audio.play(tracks[idx][1],{channel = idx,loops = -1})
			audio.setVolume(0,{channel = idx})
			trackCounters[idx] = trackCounters[idx] + 1
			idx = idx + 1
		end
	end
	
	if (trIndex > numTracks - numVoices) then
		audio.stop(trIndex)
    	audio.play(tracks[trIndex][1],{channel = trIndex})
    	btns[trIndex].alpha = 1
    	transition.to(btns[trIndex],{time = 2000,alpha = 0.5})
    	return
    end
	if (trackCounters[trIndex] % 2 == 0) then
        audio.setVolume(0,{channel = trIndex})
        btns[trIndex].alpha = 0.5
    else
       	audio.setVolume(1,{channel = trIndex})    
        btns[trIndex].alpha = 1
    end
    trackCounters[trIndex] = trackCounters[trIndex] + 1
end

local function stopAllTracks(addToList)
	audio.stop(0)
	if (addToList == true) then
			userActList[#userActList+1] = {system.getTimer() - relatTime,-1,0,-1}
	end
	startPlay = nil
end

local function addActiveTracksToActList() 
	local idx = 1
	while (idx <= numTracks) do
		if (activeTracks[idx] and activeTracks[idx][3] ~= -1) then
			userActList[#userActList + 1] = {0,idx,1,activeTime[idx]}
		end
		idx = idx + 1
	end
end

local function calcActiveTime()
	local absTime = system.getTimer()
	local result = {}
	local i = 1
	while (i <= numTracks) do
		if (activeTracks[i] and activeTracks[i][3] ~= -1) then
			result[i] = absTime - activeTracks[i][3]
		else 
			result[i] = -1
		end
		i = i + 1
	end
	return result
end

local function playSound1 (event)
    if (event.phase == "ended") then
		playTrack(1)
    end
end
local function playSound2 (event)
    if (event.phase == "ended") then
		playTrack(2)
    end
end
local function playSound3 (event)
    if (event.phase == "ended") then
		playTrack(3)
    end
end
local function playSound4 (event)
    if (event.phase == "ended") then
		playTrack(4)
    end
end
local function playSound5 (event)
    if (event.phase == "ended") then
		playTrack(5)
    end
end
local function playSound6 (event)
    if (event.phase == "ended") then
		playTrack(6)
    end
end
local function playSound7 (event)
    if (event.phase == "ended") then
		playTrack(7)
    end
end
local function playSound8 (event)
    if (event.phase == "ended") then
		playTrack(8)
    end
end
local function playSound9 (event)
    if (event.phase == "ended") then
		playTrack(9)
    end
end
local function playSound10 (event)
    if (event.phase == "ended") then
		playTrack(10)
    end
end
local function playSound11 (event)
    if (event.phase == "ended") then
		playTrack(11)
    end
end
local function playSound12 (event)
    if (event.phase == "ended") then
		playTrack(12)
    end
end

local function recording(event)
    if (event.phase == "ended") then
        if (trackCounters[#trackCounters] % 2 == 0) then
            userActList = {}
            activeTime = calcActiveTime()
            addActiveTracksToActList()
            txtRecBtn.text = "Recording is started"
            isRecStarted = true
            relatTime = system.getTimer()
        else
        	stopAllTracks(true)
        	printUserActList()
        	isRecStarted = false
        	txtRecBtn.text = "Recording is stopped"       
        	hideMainForm()
        	saveRecDialog.showDialog()
        end
        trackCounters[#trackCounters] = trackCounters[#trackCounters] + 1
    end
end

local function replay(event)
    if (event.phase == "ended") then
    	hideMainForm()   
    	replayView.showRepView() 
    end
end

local function bindEventListeners()
	btn1:addEventListener("touch",playSound1)
	btn2:addEventListener("touch",playSound2)
	btn3:addEventListener("touch",playSound3)
	btn4:addEventListener("touch",playSound4)
	btn5:addEventListener("touch",playSound5)
	btn6:addEventListener("touch",playSound6)
	btn7:addEventListener("touch",playSound7)
	btn8:addEventListener("touch",playSound8)
	btn9:addEventListener("touch",playSound9)
	btn10:addEventListener("touch",playSound10)
	btn11:addEventListener("touch",playSound11)
	btn12:addEventListener("touch",playSound12)
	
	--recBtn:addEventListener("touch",recording)
	--repBtn:addEventListener("touch",replay)
end

function initSounds()
	local i = 1
	local str
	local track = {sound = nil,name = nil,startTime = nil}
	while (i <= numTracks) do
		str = "Track"..tostring(i)..".wav"
		track[1] = audio.loadSound(str)
		track[2] = str
		tracks[i] = track
		track = {}
		i = i + 1
	end
end

function showMainForm()
	btn1 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn2 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn3 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn4 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn5 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn6 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn7 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn8 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn9 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn10 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn11 = display.newRoundedRect(1,1,w/8,h/8,2)
	btn12 = display.newRoundedRect(1,1,w/8,h/8,2)
	--recBtn = display.newRoundedRect(1,1,3*w/4,28,2)
	--repBtn = display.newRoundedRect(1,1,3*w/4,28,2)
	
	btns[#btns + 1] = btn1
	btns[#btns + 1] = btn2
	btns[#btns + 1] = btn3
	btns[#btns + 1] = btn4
	btns[#btns + 1] = btn5
	btns[#btns + 1] = btn6
	btns[#btns + 1] = btn7
	btns[#btns + 1] = btn8
	btns[#btns + 1] = btn9
	btns[#btns + 1] = btn10
	btns[#btns + 1] = btn11
	btns[#btns + 1] = btn12

	btn1.x,btn2.x = w/3,2*w/3
	btn1.y,btn2.y = h/6,h/6
	btn3.x,btn4.x,btn5.x,btn6.x = w/5,2*w/5,3*w/5,4*w/5
	btn3.y,btn4.y,btn5.y,btn6.y = h/3,h/3,h/3,h/3
	btn7.x,btn8.x,btn9.x = w/4,w/2,3*w/4
	btn7.y,btn8.y,btn9.y = h/2,h/2,h/2
	btn10.x,btn10.y = w/4,2*h/3
	btn11.x,btn11.y = w/2,2*h/3
	btn12.x,btn12.y = 3*w/4,2*h/3
	
	btn1:setFillColor(255,0,0)
	btn2:setFillColor(255,0,0)
	btn3:setFillColor(0,255,0)
	btn4:setFillColor(0,255,0)
	btn5:setFillColor(0,255,0)
	btn6:setFillColor(0,255,0)
	btn7:setFillColor(0,0,255)
	btn8:setFillColor(0,0,255)
	btn9:setFillColor(0,0,255)
	btn10:setFillColor(255,0,255)
	btn11:setFillColor(255,0,255)
	btn12:setFillColor(255,0,255)
	
	btn1.alpha = 0.5
	btn2.alpha = 0.5
	btn3.alpha = 0.5
	btn4.alpha = 0.5
	btn5.alpha = 0.5
	btn6.alpha = 0.5
	btn7.alpha = 0.5
	btn8.alpha = 0.5
	btn9.alpha = 0.5
	btn10.alpha = 0.5
	btn11.alpha = 0.5
	btn12.alpha = 0.5
	--recBtn:setFillColor(0,0,0)
	--repBtn:setFillColor(0,0,0)

	btn1:setStrokeColor(0,0,0)
	btn2:setStrokeColor(0,0,0)
	btn3:setStrokeColor(0,0,0)
	btn4:setStrokeColor(0,0,0)

	initSounds()

	audio.reserveChannels(4)

	bindEventListeners()

	stopAllTracks(false)

	resetCounters()

	print("IM HERE")
	if (isOkSaveDialogPressed == true and #userActList > 0) then
		--print("Ok")
    	saveUserActList()
        --[[local path = "Record "..tostring(os.date("%c"))..".txt"
        local destDir = system.DocumentsDirectory
		os.rename( system.pathForFile( "currentRecord.txt", destDir  ),
        			system.pathForFile( path, destDir  ) )--]]
    end
    --activeTime = {}
 	isOkSaveDialogPressed = nil
end

function hideMainForm()
	display.remove(btn1)
	display.remove(btn2)
	display.remove(btn3)
	display.remove(btn4)
	display.remove(btn5)
	display.remove(btn6)
	display.remove(btn7)
	display.remove(btn8)	
	display.remove(btn9)
	display.remove(btn10)

	--[[display.remove(recBtn)
	display.remove(repBtn)
	display.remove(txtBtn1)
	display.remove(txtBtn2)
	display.remove(txtBtn3)
	display.remove(txtBtn4)
	display.remove(txtRecBtn)
	display.remove(txtRepBtn)--]]

	stopAllTracks(false)
	activeTracks = {}
	playPressFirstTime = nil
end