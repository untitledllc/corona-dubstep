isOkSaveDialogPressed = nil
numTracks = 3
require "saveRecDialog"
require "replayView"
module ("mainForm",package.seeall)

local userActList = {}
local action = {}
local relatTime = 0
local isRecStarted = false

local tracks = {}
local activeTracks = {}
local track = {sound = nil,name = nil,startTime = nil}
local trackCounters = {}

local btn1 = nil
local btn2
local btn3
local recBtn
local repBtn

local txtBtn1
local txtBtn2
local txtBtn3
local txtRecBtn
local txtRepBtn

local function getTxtFromGui(trIndex)
	if (trIndex == 1) then
		return txtBtn1
	end
	if (trIndex == 2) then
		return txtBtn2
	end
	return txtBtn3
end

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
    end
    print("---------------------------------")
end

local function playTrack(trIndex)
	local txtBtn = getTxtFromGui(trIndex)
	if (trackCounters[trIndex] % 2 ~= 0) then
        txtBtn.text = "Track"..tostring(trIndex).." is stopped"
        action = {time = system.getTimer() - relatTime, trackNumber = trIndex, start = 0}
        audio.stop(trIndex)
        activeTracks[trIndex] = nil 
    else
        print(trIndex)
        txtBtn.text = "Track"..tostring(trIndex).." is started"
        action = {time = system.getTimer() - relatTime, trackNumber = trIndex, start = 1}
        audio.play(tracks[trIndex][1],{channel = trIndex,loops = -1})
        tracks[trIndex][3] = system.getTimer()
        activeTracks[trIndex] = tracks[trIndex]
    end
    if (isRecStarted == true) then
        userActList[#userActList+1] = action
    end
    for idx,val in pairs(activeTracks) do
        print(val[2])
    end
    print("-----------------------")
    trackCounters[trIndex] = trackCounters[trIndex] + 1
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

local function recording(event)
    if (event.phase == "ended") then
        if (trackCounters[#trackCounters] % 2 == 0) then
            userActList = {}
            txtRecBtn.text = "Recording is started"
            isRecStarted = true
            relatTime = system.getTimer()
        else
        	stopAllTracks(true)
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
	recBtn:addEventListener("touch",recording)
	repBtn:addEventListener("touch",replay)
end

local function stopAllTracks(addToList)
	local trCounter = 1
	while (trCounter <= numTracks) do
		if (addToList == true) then
			userActList[#userActList+1] = {0,system.getTimer() - relatTime,trCounter}
		end
		audio.stop(trCounter)
		trCounter = trCounter + 1
	end
end

local function initSounds()
	local i = 1
	local str
	while (i <= numTracks) do
		str = "Track"..tostring(i)..".mp3"
		track[1] = audio.loadSound(str)
		track[2] = str
		tracks[i] = track
		track = {}
		i = i + 1
	end
end

function showMainForm()
	local w = display.contentWidth
	local h = display.contentHeight
	
	btn1 = display.newRoundedRect(w/8,h/6,3*w/4,28,12)
	btn2 = display.newRoundedRect(w/8,h/3,3*w/4,28,12)
	btn3 = display.newRoundedRect(w/8,h/2,3*w/4,28,12)
	recBtn = display.newRoundedRect(w/8,2*h/3,3*w/4,28,12)
	repBtn = display.newRoundedRect(w/8,5*h/6,3*w/4,28,12)

	txtBtn1 = display.newText("Track1 is stopped", w/8, h/6+3, native.systemFont, 16)
	txtBtn2 = display.newText("Track2 is stopped", w/8, h/3+3, native.systemFont, 16)
	txtBtn3 = display.newText("Track3 is stopped", w/8, h/2+3, native.systemFont, 16)
	txtRecBtn = display.newText("Recording is stopped", w/8, 2*h/3+3, native.systemFont, 16)
	txtRepBtn = display.newText("Replaying is stopped", w/8, 5*h/6+3, native.systemFont, 16)

	txtBtn1:setTextColor(0,0,0)
	txtBtn2:setTextColor(0,0,0)
	txtBtn3:setTextColor(0,0,0)
	txtRecBtn:setTextColor(0,0,0)
	txtRepBtn:setTextColor(0,0,0)

	txtBtn1.x,txtBtn2.x,txtBtn3.x,txtRecBtn.x,txtRepBtn.x = w/2,w/2,w/2,w/2,w/2

	btn1:setFillColor(255,255,255)
	btn2:setFillColor(255,255,255)
	btn3:setFillColor(255,255,255)
	recBtn:setFillColor(255,255,255)
	repBtn:setFillColor(255,255,255)

	btn1:setStrokeColor(0,0,0)
	btn2:setStrokeColor(0,0,0)
	btn3:setStrokeColor(0,0,0)
	recBtn:setStrokeColor(0,0,0)
	repBtn:setStrokeColor(0,0,0)

	btn1.strokeWidth = 2
	btn2.strokeWidth = 2
	btn3.strokeWidth = 2
	recBtn.strokeWidth = 2
	repBtn.strokeWidth = 2
	
	initSounds()
	
	audio.reserveChannels(3)
	
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
    
 	isOkSaveDialogPressed = nil
end

function hideMainForm()
	display.remove(btn1)
	display.remove(btn2)
	display.remove(btn3)
	display.remove(recBtn)
	display.remove(repBtn)
	display.remove(txtBtn1)
	display.remove(txtBtn2)
	display.remove(txtBtn3)
	display.remove(txtRecBtn)
	display.remove(txtRepBtn)
	
	stopAllTracks(false)
	activeTracks = {}
end