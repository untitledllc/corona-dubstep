userActList = {}

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

local sound1 = audio.loadSound("Track1.wav")
local sound2 = audio.loadSound("Track2.wav")
local sound3 = audio.loadSound("Track3.wav")
local i1 = 0
local i2 = 0
local i3 = 0
local recCounter = 0
audio.reserveChannels(3)

function playSound1 (event)
    but = event.target
    if (event.phase == "release") then
        if (not(i1 % 2 == 0)) then
            local action = {time = system.getTimer(), trackNumber = 1, start = 0}
            table.insert(action,userActList)
            but:setLabel("Track1 is stopped")
            audio.stop(1) 
        else
            local action = {time = system.getTimer(), trackNumber = 1, start = 1}
            table.insert(action,userActList)
            but:setLabel("Track1 is playing")
            audio.play(sound1,{ channel = 1,loops = -1}) --на 1 канале беск число раз играем
        end
        i1 = i1 + 1 --Увеличили счетчик
    end
end

function playSound2 (event)
	if (event.phase == "release") then	
		audio.play(sound2,{ channel=2,loops = -1})
		i2 = i2 + 1
	end
	if (i2 % 2 == 0) then
		audio.stop(2)
	end
end

function playSound3 (event)
	if (event.phase == "release") then
		audio.play(sound3,{ channel=3,loops = -1})
		i3 = i3 + 1
	end
	if (i3 % 2 == 0) then
		audio.stop(3)
	end
end

function recording(event)
    recBut = event.target
    if (event.phase == "release") then
        if (recCounter % 2 == 0) then
            recBut:setLabel("Stop recording")
            userActList = {}
        else
            recBut:setLabel("Start recording")
            saveUserActList()
        end
        recCounter = recCounter + 1
    end
end

function replay(event)
    repBut = event.target
    if (event.phase == "release") then
        openUserActList()    
    end
end