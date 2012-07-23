require "mainForm"

local backRect
local w = display.contentWidth
local h = display.contentHeight
backRect = display.newRoundedRect(0, 0, w, h, 64)
backRect:setFillColor(140, 140, 140)
backRect.strokeWidth = 3

mainForm.showMainForm()
--[[local sound = audio.loadSound("Track3.mp3")

audio.play(sound,{channel = 1,loops = 2})

local function pause(event) 
	audio.pause()
end

local function resume(event) 
	audio.resume()
end

timer.performWithDelay(1000,pause)

timer.performWithDelay(1500,resume)--]]