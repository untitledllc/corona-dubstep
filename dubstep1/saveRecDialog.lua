module ("saveRecDialog",package.seeall)

local btnOk = nil
local btnCancel
local txtBox
local txtOk
local txtCancel
local w = display.contentWidth
local h = display.contentHeight

local function showMainForm(event)
	mainForm.showMainForm()
end

local function hideDialog()
	display.remove(txtBox)
	display.remove(btnOk)
	display.remove(btnCancel)
	display.remove(txtOk)
	display.remove(txtCancel)
end

local function okPressed()
	hideDialog()
	mainForm.isOkSaveDialogPressed = true
	timer.performWithDelay(1000, showMainForm)
end

local function cancelPressed()
	hideDialog()
	mainForm.isOkSaveDialogPressed = false
	timer.performWithDelay(1000, showMainForm)
end

local function bindListeners()
	btnOk:addEventListener("touch",okPressed)
	btnCancel:addEventListener("touch",cancelPressed)
end

function showDialog()
		btnOk = display.newRoundedRect(0, 0, w/3-10, h/12, 12)
		btnCancel = display.newRoundedRect(0, 0, w/3-10, h/12, 12)
		txtBox = display.newText("Do you want to save your composition?",
								 0, 0, native.systemFont, 16)
		txtCancel = display.newText("Discard", 0, 0, native.systemFont, 16)
		txtOk = display.newText("Save", 0, 0, native.systemFont, 16)
		
		btnOk:setFillColor(255,255,255)
		btnOk:setStrokeColor(0,0,0)
		btnOk.x,btnOk.y = w/3,h/2
	
		btnCancel:setFillColor(255,255,255)
		btnCancel:setStrokeColor(0,0,0)
		btnCancel.x,btnCancel.y = 2*w/3,h/2
	
		txtBox.x,txtBox.y = w/2,h/3
		
		txtOk.x,txtOk.y, txtCancel.x,txtCancel.y = w/3,h/2,2*w/3,h/2
		txtOk:setTextColor(0,0,0)
		txtCancel:setTextColor(0,0,0)
		bindListeners()
end