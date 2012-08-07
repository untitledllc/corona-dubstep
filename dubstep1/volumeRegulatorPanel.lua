module (...,package.seeall)

local w = display.contentWidth
local h = display.contentHeight

local volumePressCounter = 0

local regulatorPanel = nil

local lineLen = h/4

scrolls = {}

function setScrollPosition(volumeLevel,index)
	scrolls[index]["scroll"].y = scrolls[index]["top"] - volumeLevel*lineLen - h/2
	print(scrolls[index]["scroll"].y)
end

local function createVolumeRegulator(x,y)
	local line = display.newRoundedRect(1,1,4,h/4,2)
	local scroll = display.newRoundedRect(1,1,10,5,2)
	local topLimit = y + h/8 + h/2
	local bottomLimit = y - h/8 + h/2
	local scTable = {}
	
	scroll:setFillColor(255,255,255)
	line:setFillColor(255,0,0)
	scroll.x,scroll.y = x,y
	line.x,line.y = x,y
	
	local function moveScroll(event)
		if (event.phase == "moved") then
			if (bottomLimit <= event.y and event.y <= topLimit) then
				event.target.y = event.y - h/2
				print((topLimit - event.y)/lineLen)
			end
		end
	end
	
	scroll:addEventListener("touch",moveScroll)
	
	scTable["scroll"] = scroll
	scTable["top"] = topLimit
	scTable["bottom"] = bottomLimit
	scrolls[#scrolls + 1] = scTable
	
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