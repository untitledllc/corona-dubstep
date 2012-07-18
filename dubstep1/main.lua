require "mainForm"

mainForm.showMainForm()


--[[local square = display.newRect( 0, 0, 100, 100 )
square:setFillColor( 255,255,255 )
 
local w,h = display.stageWidth, display.stageHeight
 
local square = display.newRect( 0, 0, 100, 100 )
square:setFillColor( 255,255,255 )
 
local w,h = display.stageWidth, display.stageHeight
 
local listener1 = function( obj )
        print( "Transition 1 completed on object: " .. tostring( obj ) )
end
 
local listener2 = function( obj )
        print( "Transition 2 completed on object: " .. tostring( obj ) )
end
 
-- (1) move square to bottom right corner; subtract half side-length
--     b/c the local origin is at the square's center; fade out square
transition.to( square, { time=1500, alpha=0, x=(w-50), y=(h-50), onComplete=listener1 } )
 
-- (2) fade square back in after 2.5 seconds
transition.to( square, { time=500, delay=2500, alpha=1.0, onComplete=listener2 } )--]]