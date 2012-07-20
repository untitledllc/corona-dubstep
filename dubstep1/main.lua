require "mainForm"

local backRect
local w = display.contentWidth
local h = display.contentHeight
backRect = display.newRoundedRect(0, 0, w, h, 64)
backRect:setFillColor(140, 140, 140)
backRect.strokeWidth = 3

mainForm.showMainForm()
--[[local sound = audio.loadSound("Track3.mp3")

--audio.stop(sound)
audio.play(sound,{channel = 1})
audio.seek(2000,{channel = 1})--]]
