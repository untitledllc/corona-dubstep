--require "mainForm"

--[[local backRect
local w = display.contentWidth
local h = display.contentHeight
backRect = display.newRoundedRect(0, 0, w, h, 64)
backRect:setFillColor(140, 140, 140)
backRect.strokeWidth = 3--]]

--	mainForm.showMainForm()

--[[local function listener(event)
	print(system.getTimer())
end

--Runtime:addEventListener("enterFrame",listener)
--]]

system.activate("multitouch")

local director = require("director")

local mainGroup = display.newGroup()

local function main()
	mainGroup:insert(director.directorView)
	director:changeScene("layout1")
	return true
end

main()