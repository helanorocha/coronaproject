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

local bg1
local bg2
local barrel, grass

local function getDeltaTime()
	local temp = system.getTimer()
	local dt = (temp-runtime) / (1000/60)
	runtime = temp
	return dt
end

local scrollSpeed = 1.4
-- Metodo de movimentar o background

local function moveBg(dt)
	bg1.y = bg1.y + scrollSpeed * dt
	bg2.y = bg2.y + scrollSpeed * dt
	if (bg1.y - display.contentHeight/2) > display.actualContentHeight then
		bg1:translate(0, -bg1.contentHeight * 2)
	end
	if (bg2.y - display.contentHeight/2) > display.actualContentHeight then
		bg2:translate(0, -bg2.contentHeight * 2)
	end
	if (barrel.y < 250) then
		barrel.y = barrel.y + (scrollSpeed * dt + 1.5)
	end
end

local function enterFrame()
	local dt = getDeltaTime()
	moveBg(dt)
end
local function addScrollableBg(sceneGroup)
    local bgImage = { type="image", filename="water.jpg" }
    -- Add First bg image
    bg1 = display.newRect(0, 0, display.contentWidth, display.actualContentHeight)
    bg1.fill = bgImage
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY
		sceneGroup:insert(bg1)
    -- Add Second bg image
    bg2 = display.newRect(0, 0, display.contentWidth, display.actualContentHeight)
    bg2.fill = bgImage
    bg2.x = display.contentCenterX
    bg2.y = display.contentCenterY - display.actualContentHeight
		sceneGroup:insert(bg2)
end


--- gerar pedra
local count = 1
local function gerarPedra(sceneGroup)

		local barrelDrop = display.newImageRect( "rock.png", 50, 50 )
		barrelDrop.x, barrelDrop.y = math.random(49,259), -50
		count = count + 13
		barrelDrop.rotation = 5
		physics.addBody( barrelDrop, { density=0.8, friction=0.6 } )
		sceneGroup:insert(barrelDrop)
end



-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- create a grey rectangle as the backdrop


	-- make a barrel (off-screen), position it, and rotate slightly
	barrel = display.newImageRect( "Barrel.png", 60, 60 )
	barrel.x, barrel.y = 160, -50
	barrel.rotation = 2
	-- add physics to the barrel
	physics.addBody( barrel, "static", { density=0.8, friction=0.6 } )

	-- all display objects must be inserted into group
	addScrollableBg(sceneGroup)
	Runtime:addEventListener("enterFrame", enterFrame)

	sceneGroup:insert( barrel )

	-- chamando gerarOBJETOS aleatorios
	local generate = function() return gerarPedra(sceneGroup) end
	timer.performWithDelay(4000, generate, 9999)
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


-- Called when a key event has been received
local function onKeyEvent( event )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    print( message )

    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
    if ( event.keyName == "left" ) then
			if barrel.x > 48 then
				barrel.x = barrel.x -20
				--grass.x = grass.x -20
			end
    end

		if ( event.keyName == "right") then
			if barrel.x < 260 then
				barrel.x = barrel.x +20
				--grass.x = grass.x +20
			end
		end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

-- Add the key event listener
Runtime:addEventListener( "key", onKeyEvent )

return scene
