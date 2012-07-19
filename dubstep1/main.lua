require "mainForm"

local backRect
local w = display.contentWidth
local h = display.contentHeight
backRect = display.newRoundedRect(0, 0, w, h, 64)
backRect:setFillColor(140, 140, 140)
backRect.strokeWidth = 3

mainForm.showMainForm()