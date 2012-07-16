local widget = require "widget"

require "listeners"

local w = display.contentWidth 
local h = display.contentHeight

-- Объявили 3 кнопки.
local but1 = widget.newButton{
	id = "btn1",
	left = w/2-75,
	top = h/2-30,
	label = "Track1",
	width = 150,
	height = 28,
	onEvent= playSound1
}

local but2 = widget.newButton{
	id = "btn2",
	left = w/2-75,
	top = h/2,
	label = "Track2",
	width = 150,
	height = 28,
	onEvent = playSound2
}

local but3 = widget.newButton{
	id = "btn3",
	left = w/2-75,
	top = h/2+30,
	label = "Track3",
	width = 150,
	height = 28,
	onEvent = playSound3
}

local rec = widget.newButton{
	id = "rec",
	left = w/2-75,
	top = h/2+60,
	label = "Start recording",
	width = 150,
	height = 28,
	onEvent = recording
}

local replay = widget.newButton{
	id = "replay",
	left = w/2-75,
	top = h/2+90,
	label = "Replay recorded track",
	width = 150,
	height = 28,
	onEvent = replay
}