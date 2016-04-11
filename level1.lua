-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

local runtime = 0

local barrel, text
local pontos = 0

-- Set Variables
_W = display.contentWidth; -- Get the width of the screen
_H = display.contentHeight; -- Get the height of the screen
scrollSpeed = 2; -- Set Scroll Speed of background
local bg1, bg2, bg3
local function createBackground(sceneGroup)
		-- Add First Background
		bg1 = display.newImageRect("water.jpg", 320, 480)
		bg1.anchorX = 0; bg1.anchorY = 0.0;
		bg1.x = 0; bg1.y = 0;
		sceneGroup:insert(bg1)
		-- Add Second Background
		bg2 = display.newImageRect("water.jpg", 320, 480)
		bg2.anchorX = 0.0; bg2.anchorY = 0.0;
		bg2.x = 0; bg2.y = bg1.y+480;
		sceneGroup:insert(bg2)
		-- Add Third Background
		bg3 = display.newImageRect("water.jpg", 320, 480)
		bg3.anchorX = 0.0; bg3.anchorY = 0.0;
		bg3.x = 0; bg3.y = bg2.y+480;
		sceneGroup:insert(bg3)
end

local function move(event)
		-- move backgrounds to the left by scrollSpeed, default is 8
		bg1.y = bg1.y - scrollSpeed
		bg2.y = bg2.y - scrollSpeed
		bg3.y = bg3.y - scrollSpeed

		-- Set up listeners so when backgrounds hits a certain point off the screen,
		-- move the background to the right off screen
		if (bg1.y + bg1.contentHeight) < -40 then
				bg1:translate( 0, 480*3 )
		end
		if (bg2.y + bg2.contentHeight) < -40 then
				bg2:translate( 0, 480*3 )
		end
		if (bg3.y + bg3.contentHeight) < -40 then
				bg3:translate( 0, 480*3 )
		end
end

--- gerar pedra
local count = 1
local function gerarPedra(sceneGroup)

		local barrelDrop = display.newImageRect( "rock.png", 50, 50 )
		barrelDrop.x, barrelDrop.y = math.random(49,259), -50
		count = count + 1
		barrelDrop.rotation = 5
		physics.addBody( barrelDrop, { density=0.8, friction=0.6 } )
		sceneGroup:insert(barrelDrop)
end



-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

--movimentação inical do barril
local function moveBarrel()
	if barrel.y < _H/2 then
		barrel.y = barrel.y + 3
	end
end

--efeito da agua no barril
local function fire(sceneGroup)
local beam = {}

	for i = 1, 100 do
		local particle = display.newCircle(0,0.7,5.5)
		beam[i] = particle
		beam[i]:setFillColor( 1.0, 1.0, 1.0 )
		beam[i].x, beam[i].y = math.random(barrel.x - 30,barrel.x + 30) ,  math.random(barrel.y+20,barrel.y + 40)
		beam[i].alpha = 0.6
		beam[i].trans = transition.to(beam[i], { x = barrel.x - math.random(100,150), y = barrel.y - math.random (190, 250), alpha = 0.0, time = math.random(1000, 1200), delay = 100, onComplete = function() if beam[i] then beam[i]:removeSelf() end end })
	end
end
local texto = display.newText( "Pontos: "..pontos, _W - 50, _H - _H - 20, native.systemFont, 16 )
local function atualizarPontos(sceneGroup)
	pontos = pontos +1
	texto.text = "Pontos: "..pontos
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	createBackground(sceneGroup)
	-- create a grey rectangle as the backdrop


	-- make a barrel (off-screen), position it, and rotate slightly
	barrel = display.newImageRect( "Barrel.png", 60, 60 )
	barrel.x, barrel.y = (_W/3) + 50, _H - _H - 50
	local callfire = function() return fire(sceneGroup) end
	timer.performWithDelay(200, fire, -1)
	barrel.rotation = 0
	
	-- add physics to the barrel
	physics.addBody( barrel, "static", { density=0.8, friction=0.6 } )

	-- all display objects must be inserted into group

	sceneGroup:insert( barrel )

	-- chamando gerarOBJETOS aleatorios
	local generate = function() return gerarPedra(sceneGroup) end
	sceneGroup:insert(texto)
	timer.performWithDelay(4000, generate, -1)
	timer.performWithDelay(50, moveBarrel, 5000)
	timer.performWithDelay(1000, atualizarPontos, -1)

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc
		physics.start()
	end

end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view

	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

-------------------Eventos do teclado--------------------------------------
local action = {
  [-1] = function (barrel) barrel.x=(_W / 3 ) - 20 end,
  [0] = function (barrel) barrel.x= (_W / 3) + 50 end,
  [1] = function (barrel)barrel.x= _W - 80 end
}
local countArrow = 0
-- Called when a key event has been received
local function onKeyEvent( event )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    print( message )
		if  event.phase == "down" then
		    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
		    if ( event.keyName == "left" and countArrow>-1) then
					countArrow = countArrow-1
		    end

				if ( event.keyName == "right" and countArrow<1) then
					countArrow = countArrow+1
				end

				action[countArrow](barrel)
		end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end


-- Add the key event listener
Runtime:addEventListener( "key", onKeyEvent )
-- Create a runtime event to move backgrounds
Runtime:addEventListener( "enterFrame", move )
return scene
