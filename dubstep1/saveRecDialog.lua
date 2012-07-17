module ("saveRecDialog",package.seeall)

local butOk = nil
local butCancel
local textBox
local textOk
local textCancel
local w = display.contentWidth
local h = display.contentHeight

local function showMainForm(event)
	mainForm.showMainForm()
end
local function hideDialog()
	display.remove(textBox)
	display.remove(butOk)
	display.remove(butCancel)
	display.remove(textOk)
	display.remove(textCancel)
	--[[butOk:removeEventListener("touch", okPressed)
	butCancel:removeEventListener("touch", cancelPressed)--]]
end

local function okPressed()
	hideDialog()
	mainForm.isOkSaveDialogPressed = true
	timer.performWithDelay(1000, showMainForm)
end

local function cancelPressed()
	hideDialog()
	mainForm.isOkSaveDialogPressed = false
	mainForm.showMainForm()
end

local function bindListeners()
	butOk:addEventListener("touch",okPressed)
	butCancel:addEventListener("touch",cancelPressed)
end

function showDialog()
		butOk = display.newRoundedRect(0, 0, w/3-10, h/12, 12)
		butCancel = display.newRoundedRect(0, 0, w/3-10, h/12, 12)
		textBox = display.newText("Do you want to save your composition?",
								 0, 0, native.systemFont, 16)
		textCancel = display.newText("Discard", 0, 0, native.systemFont, 16)
		textOk = display.newText("Save", 0, 0, native.systemFont, 16)
		
		butOk:setFillColor(255,255,255)
		butOk:setStrokeColor(0,0,0)
		butOk.x,butOk.y = w/3,h/2
	
		butCancel:setFillColor(255,255,255)
		butCancel:setStrokeColor(0,0,0)
		butCancel.x,butCancel.y = 2*w/3,h/2
	
		textBox.x,textBox.y = w/2,h/3
		
		textOk.x,textOk.y, textCancel.x,textCancel.y = w/3,h/2,2*w/3,h/2
		textOk:setTextColor(0,0,0)
		textCancel:setTextColor(0,0,0)
		bindListeners()
end