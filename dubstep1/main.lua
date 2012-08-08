system.activate("multitouch")

local director = require("director")

local mainGroup = display.newGroup()

local function main()
	mainGroup:insert(director.directorView)
	director:changeScene("layout1")
	return true
end

main()