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

audio.reserveChannels(3)

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

--[[local function openUserActList()
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
end--]]

function playSound1 (event)
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
        printUserActList()
        but1ClickedCounter = but1ClickedCounter + 1
    end
end

function playSound2 (event)
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
        printUserActList()
        but2ClickedCounter = but2ClickedCounter + 1
    end
end

function playSound3 (event)
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
        printUserActList()
        but3ClickedCounter = but3ClickedCounter + 1
    end
end

function recording(event)
    if (event.phase == "ended") then
        if (recCounter % 2 == 0) then
            userActList = {}
            textRecBut.text = "Recording is started"
            isRecStarted = true
            relatTime = system.getTimer()
        else
        	isRecStarted = false
        	textRecBut.text = "Recording is stopped"
        	if (#userActList > 0) then
            	saveUserActList()
            end
            local path = "Record "..tostring(os.date("%c"))..".txt"
            local destDir = system.DocumentsDirectory
			os.rename( system.pathForFile( "currentRecord.txt", destDir  ),
        		system.pathForFile( path, destDir  ) )
        	repBut.isVisible = false
        end
        recCounter = recCounter + 1
    end
end

--[[function replay(event)
    repBut = event.target
    if (event.phase == "release") then
        openUserActList()    
    end
end--]]

but1:addEventListener("touch",listeners.playSound1)
but2:addEventListener("touch",listeners.playSound2)
but3:addEventListener("touch",listeners.playSound3)
recBut:addEventListener("touch",listeners.recording)
--repBut:addEventListener("touch",replay)