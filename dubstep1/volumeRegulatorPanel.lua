module (...,package.seeall)

local w = display.contentWidth
local h = display.contentHeight

local volumePressCounter = 0

regulatorPanel = nil

local lineLen = h/4
local topLimit = h/4 + h/8 + h/2
local bottomLimit = h/4 - h/8 + h/2

scrolls = {}

voiceVolume = 0.5
fxVolume = 0.5

local gl = require("globals")

function setVolume(volumeLevel,channels)
	local idx = 1
	while (idx <= #channels) do
		audio.setVolume(volumeLevel,{channel = channels[idx]})
		idx = idx + 1
	end
end

function getVolume(scrollTmp)
	return (topLimit - scrollTmp.y - h/2)/lineLen
end

local function calcScrollIndex(scroll)
	local idx = 1
	while (idx <= #scrolls) do
		if (scroll == scrolls[idx]) then
			return idx
		end
		idx = idx + 1
	end
	return "Error"
end

local function calcChannels(index) 
	local beginIndex 
	local endIndex = nil
	local result = {}
	if (gl.partSumms[index - 1] == nil) then
		beginIndex = 1

	else
		beginIndex = gl.partSumms[index - 1] + 1
	end		
	
	endIndex = gl.partSumms[index]
	
	local idx = beginIndex
	while (idx <= endIndex) do
		if (gl.activeChannels[idx] ~= nil) then
			result[#result + 1] = idx
		end
		idx = idx + 1
	end
	
	for i,val in pairs(result) do
		print(val)
	end
	print("______________________________")
	return result
end

local function moveScroll(event)
	if (event.phase == "moved") then
		if (bottomLimit <= event.y and event.y <= topLimit) then
			event.target.y = event.y - h/2
			local index = calcScrollIndex(event.target)
			if (index <= 3) then 
				local channels = calcChannels(index)
				setVolume(getVolume(event.target),channels)
			end
			if (index == 5) then	
				voiceVolume = getVolume(scrolls[5])
			end
			if (index == 4) then
				fxVolume = getVolume(scrolls[4])
			end
		end
	end
end
	
local function createVolumeRegulator(x,y)
	local line = display.newRoundedRect(1,1,4,h/4,2)
	local scroll = display.newRoundedRect(1,1,20,20,2)
	local scTable = {}
	
	scroll:setFillColor(255,255,255)
	line:setFillColor(255,0,0)
	scroll.x,scroll.y = x,y
	line.x,line.y = x,y
	
	scroll:addEventListener("touch",moveScroll)
	
	scrolls[#scrolls + 1] = scroll
	
	return scroll,line
end

function showHidePanel(event)
	if (event.phase == "ended") then
		if (regulatorPanel == nil) then
			createVolumeRegulatorPanel()
		end
		if (volumePressCounter % 2 == 0) then
			transition.to(regulatorPanel,{time = 500,y = h/2})
		else 
			transition.to(regulatorPanel,{time = 500,y = h})
		end
		volumePressCounter = volumePressCounter + 1
	end
end

function createVolumeRegulatorPanel()
	regulatorPanel = display.newGroup()

	scrolls = {}

	local backGroundRect = display.newRect(0,0,w,h/2)
	backGroundRect:setFillColor(140,140,140)
	
	regulatorPanel.xReference,regulatorPanel.yReference = 0,0
	regulatorPanel.x,regulatorPanel.y = 0,h
	regulatorPanel:insert(backGroundRect)
	
	local scroll,line = createVolumeRegulator(w/6,h/4)
	regulatorPanel:insert(line)
	regulatorPanel:insert(scroll)
		
	local scroll,line = createVolumeRegulator(w/3,h/4)
	regulatorPanel:insert(line)
	regulatorPanel:insert(scroll)
	
	local scroll,line = createVolumeRegulator(w/2,h/4)
	regulatorPanel:insert(line)
	regulatorPanel:insert(scroll)
	
	local scroll,line = createVolumeRegulator(2*w/3,h/4)
	regulatorPanel:insert(line)
	regulatorPanel:insert(scroll)
	
	local scroll,line = createVolumeRegulator(5*w/6,h/4)
	regulatorPanel:insert(line)	
	regulatorPanel:insert(scroll)
end 