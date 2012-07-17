isOkSaveDialogPressed = nil

require "saveRecDialog"

module ("mainForm",package.seeall)

local userActList = {}
local action = {}
local relatTime = 0
local isRecStarted = false

local sound1 = audio.loadSound("Track1.wav")
local sound2 = audio.loadSound("Track2.wav")
local sound3 = audio.loadSound("Track3.wav")

local but1ClickedCounter = 0
local but2ClickedCounter = 0
local but3ClickedCounter = 0
local recCounter = 0

local backRect
local but1 = nil
local but2
local but3
local recBut
local repBut

local textBut1
local textBut2
local textBut3
local textRecBut
local textRepBut


local function saveUserActList()
    local path = system.pathForFile( "currentRecord.txt", system.DocumentsDirectory )
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

local function openUserActList()
    local path = system.pathForFile( "test.txt", system.DocumentsDirectory )
    local f = io.open(path,"r+")
    if (not f) then
        print("not ok")
    end
    for i,t in pairs(userActList) do
        for j,val in pairs(t) do
           val = f:read("*number")
        end
    end
    for i,t in pairs(userActList) do
        for j,val in pairs(t) do
            print(val)
        end
    end
    f:close()
end

local function playSound1 (event)
    if (event.phase == "ended") then
        if (but1ClickedCounter % 2 ~= 0) then
        	textBut1.text = "Track1 is stopped"
            action = {time = system.getTimer() - relatTime, trackNumber = 1, start = 0}
            audio.stop(1) 
        else
        	textBut1.text = "Track1 is started"
           	action = {time = system.getTimer() - relatTime, trackNumber = 1, start = 1}
            audio.play(sound1,{ channel = 1,loops = -1})
        end
        if (isRecStarted == true) then
        	userActList[#userActList+1] = action
        end
        but1ClickedCounter = but1ClickedCounter + 1
    end
end

local function playSound2 (event)
    if (event.phase == "ended") then
        if (but2ClickedCounter % 2 ~= 0) then
        	textBut2.text = "Track2 is stopped"
            action = {time = system.getTimer() - relatTime, trackNumber = 2, start = 0}
            audio.stop(2) 
        else
        	textBut2.text = "Track2 is started"
           	action = {time = system.getTimer() - relatTime, trackNumber = 2, start = 1}
            audio.play(sound2,{ channel = 2,loops = -1})
        end
        if (isRecStarted == true) then
        	userActList[#userActList+1] = action
        end
        but2ClickedCounter = but2ClickedCounter + 1
    end
end

local function playSound3 (event)
    if (event.phase == "ended") then
        if (but3ClickedCounter % 2 ~= 0) then
        	textBut3.text = "Track3 is stopped"
            action = {time = system.getTimer() - relatTime, trackNumber = 3, start = 0}
            audio.stop(3) 
        else
        	textBut3.text = "Track3 is started"
           	action = {time = system.getTimer() - relatTime, trackNumber = 3, start = 1}
            audio.play(sound3,{ channel = 3,loops = -1})
        end
        if (isRecStarted == true) then
        	userActList[#userActList+1] = action
        end
        but3ClickedCounter = but3ClickedCounter + 1
    end
end

local function recording(event)
    if (event.phase == "ended") then
        if (recCounter % 2 == 0) then
            userActList = {}
            textRecBut.text = "Recording is started"
            isRecStarted = true
            relatTime = system.getTimer()
        else
        	isRecStarted = false
        	textRecBut.text = "Recording is stopped"       
        	hideMainForm()
        	saveRecDialog.showDialog()
        end
        recCounter = recCounter + 1
    end
end

local function replay(event)
    repBut = event.target
    if (event.phase == "release") then
        openUserActList()    
    end
end

local function bindEventListeners()
	but1:addEventListener("touch",playSound1)
	but2:addEventListener("touch",playSound2)
	but3:addEventListener("touch",playSound3)
	recBut:addEventListener("touch",recording)
	repBut:addEventListener("touch",replay)
end

function showMainForm()
	local w = display.contentWidth
	local h = display.contentHeight
	backRect = display.newRoundedRect(0, 0, w, h, 64)
	but1 = display.newRoundedRect(w/8,h/6,3*w/4,28,12)
	but2 = display.newRoundedRect(w/8,h/3,3*w/4,28,12)
	but3 = display.newRoundedRect(w/8,h/2,3*w/4,28,12)
	recBut = display.newRoundedRect(w/8,2*h/3,3*w/4,28,12)
	repBut = display.newRoundedRect(w/8,5*h/6,3*w/4,28,12)

	textBut1 = display.newText("Track1 is stopped", w/8, h/6+3, native.systemFont, 16)
	textBut2 = display.newText("Track2 is stopped", w/8, h/3+3, native.systemFont, 16)
	textBut3 = display.newText("Track3 is stopped", w/8, h/2+3, native.systemFont, 16)
	textRecBut = display.newText("Recording is stopped", w/8, 2*h/3+3, native.systemFont, 16)
	textRepBut = display.newText("Replaying is stopped", w/8, 5*h/6+3, native.systemFont, 16)

	textBut1:setTextColor(0,0,0)
	textBut2:setTextColor(0,0,0)
	textBut3:setTextColor(0,0,0)
	textRecBut:setTextColor(0,0,0)
	textRepBut:setTextColor(0,0,0)

	textBut1.x,textBut2.x,textBut3.x,textRecBut.x,textRepBut.x = w/2,w/2,w/2,w/2,w/2

	backRect:setFillColor(140, 140, 140)
	but1:setFillColor(255,255,255)
	but2:setFillColor(255,255,255)
	but3:setFillColor(255,255,255)
	recBut:setFillColor(255,255,255)
	repBut:setFillColor(255,255,255)

	but1:setStrokeColor(0,0,0)
	but2:setStrokeColor(0,0,0)
	but3:setStrokeColor(0,0,0)
	recBut:setStrokeColor(0,0,0)
	repBut:setStrokeColor(0,0,0)

	backRect.strokeWidth = 3
	but1.strokeWidth = 2
	but2.strokeWidth = 2
	but3.strokeWidth = 2
	recBut.strokeWidth = 2
	repBut.strokeWidth = 2
	
	audio.reserveChannels(3)
	bindEventListeners()

	audio.stop(1)
	audio.stop(2)
	audio.stop(3)
	
	but1ClickedCounter = 0
	but2ClickedCounter = 0
	but3ClickedCounter = 0
	recCounter = 0
	
	if (isOkSaveDialogPressed == true and #userActList > 0) then
		print("Ok")
    	saveUserActList()
        local path = "Record "..tostring(os.date("%c"))..".txt"
        local destDir = system.DocumentsDirectory
		os.rename( system.pathForFile( "currentRecord.txt", destDir  ),
        			system.pathForFile( path, destDir  ) )
    end
    
 	isOkSaveDialogPressed = nil
end

function hideMainForm()
	display.remove(but1)
	display.remove(but2)
	display.remove(but3)
	display.remove(recBut)
	display.remove(textBut1)
	display.remove(textBut2)
	display.remove(textBut3)
	display.remove(textRecBut)
	display.remove(textRepBut)
	
	--[[but1:removeEventListener("touch", playSound1)
	but2:removeEventListener("touch", playSound2)
	but3:removeEventListener("touch", playSound3)
	recBut:removeEventListener("touch", recording)
	repBut:removeEventListener("touch", replay)--]]
	
	audio.stop(1)
	audio.stop(2)
	audio.stop(3)
	but1ClickedCounter = 0
	but2ClickedCounter = 0
	but3ClickedCounter = 0
	recCounter = 0
end

