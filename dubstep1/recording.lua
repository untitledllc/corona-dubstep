module (...,package.seeall)

local userActionsList = {}
local recPressCounter = 0

local isRecSwitchedOn = false

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
			isRecSwitchedOn = true
			event.target.alpha = 1
		else
			isRecSwitchedOn = false
			event.target.alpha = 0.5
		end
		recPressCounter = recPressCounter + 1
	end
end

function addAction(action)
end