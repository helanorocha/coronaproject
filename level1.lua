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
local contador = 0
local delayGerarPedra = 2600
local lives = {}
local lifeCount = 3

-- Set Variables
_W = display.contentWidth; -- Get the width of the screen
_H = display.contentHeight; -- Get the height of the screen
scrollSpeed = 2; -- Set Scroll Speed of background
local bg1, bg2, bg3
local function createBackground(sceneGroup)
		-- Add First Background
		bg1 = display.newImageRect("bg.png", 320, 480)
		bg1.anchorX = 0; bg1.anchorY = 0.0;
		bg1.x = 0; bg1.y = 0;
		sceneGroup:insert(bg1)
		-- Add Second Background
		bg2 = display.newImageRect("bg.png", 320, 480)
		bg2.anchorX = 0.0; bg2.anchorY = 0.0;
		bg2.x = 0; bg2.y = bg1.y+480;
		sceneGroup:insert(bg2)
		-- Add Third Background
		bg3 = display.newImageRect("bg.png", 320, 480)
		bg3.anchorX = 0.0; bg3.anchorY = 0.0;
		bg3.x = 0; bg3.y = bg2.y+480;
		sceneGroup:insert(bg3)
end

local function move(event)

		delayGerarPedra = 4000 - (pontos * 100)
		physics.start();
		physics.setGravity( 0, 9.6 + contador * 2 )

		-- move backgrounds to the left by scrollSpeed, default is 8
		local velocidade = scrollSpeed + (contador/10)
		bg1.y = bg1.y - velocidade
		bg2.y = bg2.y - velocidade
		bg3.y = bg3.y - velocidade

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

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

--- gerar pedra
local count = 1
local function gerarPedra(sceneGroup)
		local imgSelect = math.random(1,2)
		local qtPedras = math.random(1,2)
		local xAnterior = 0
		for i = 1, qtPedras do
				local imgName = "rock.png"
				if imgSelect % 2 == 0 then
					imgName = "rock.png"
				end
				local barrelDrop = display.newImageRect( imgName, 50, 50 )
				local posX = math.random(1,3)
				local pos = {
				  [1] = function (barrel) barrel.x=(_W / 3 ) - 20 end,
				  [2] = function (barrel) barrel.x= (_W / 3) + 50 end,
				  [3] = function (barrel)barrel.x= _W - 85 end
				}
				if i == 1 then
					xAnterior = posX
				elseif i > 1 and posX == xAnterior then
					while posX == xAnterior do
						posX = math.random(1,3)
					end
				end

				pos[posX](barrelDrop)
				barrelDrop.y = -50
				count = count + 1
				barrelDrop.rotation = 1
				barrelDrop.myName = 'Pedra'

				physics.addBody( barrelDrop, { density=1.0, friction=0.2 } )
				sceneGroup:insert(barrelDrop)
		end
end

local function rebolaPiranha()
	local piranha = display.newImageRect( "piranha.png", 40, 40 );
	piranha.x, piranha.y = 0, 20
	physics.addBody( piranha, "dynamic",{ density=1, friction=0.5 })

	piranha:applyLinearImpulse(20, 50, piranha.x, piranha.y)
	piranha.myName = 'Piranha'
end
-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

--movimentação inical do barril
local moveBarrelTimer, gerarPedraTimer, atualizarPontosTimer, particleTimer, rebolaPiranhaTimer
local function moveBarrel()
	if barrel.y < _H/2 then
		barrel.y = barrel.y + 3
	else
		timer.cancel(moveBarrelTimer)
	end
end

--efeito da agua no barril
local function fire(sceneGroup)
local beam = {}

	for i = 1, 30 do
		local particle = display.newCircle(0,0.7,4.5)
		beam[i] = particle
		beam[i]:setFillColor( 1.0, 1.0, 1.0 )
		beam[i].x, beam[i].y = math.random(barrel.x - 30,barrel.x + 30) ,  math.random(barrel.y+20,barrel.y + 40)
		beam[i].alpha = 0.6
		beam[i].trans = transition.to(beam[i], { x = barrel.x , y = barrel.y - math.random (190, 250), alpha = 0.0, time = math.random(1000, 1200), delay = 100, onComplete = function() if beam[i] then beam[i]:removeSelf() beam[i] = nil end end })
	end
end

local texto = display.newText( "Pontos: "..pontos, _W - 50, _H - _H - 20, native.systemFont, 16 )


local function winGame()
	audio.setVolume( 0.50 , { channel=3 })
	local gameoverSound = audio.loadSound("win.mp3");
	audio.play( gameoverSound )
end

local function atualizarPontos(sceneGroup)
	pontos = pontos +1
	contador = contador + 2
	texto.text = "Pontos: "..pontos

	if pontos % 10 == 0 then
   winGame()
	end
end

local function updateLives()
	for i = 1, 3 do
		lives[i].isVisible = false;
	end
	for i = 1, lifeCount do
		lives[i].isVisible = true;
	end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	createBackground(sceneGroup)

	-- make a barrel (off-screen), position it, and rotate slightly
	barrel = display.newImageRect( "barrel_2.png", 80, 85 )
	barrel.x, barrel.y = (_W/3) + 50, _H - _H - 50

	barrel.rotation = 0
	barrel.myName = 'Barril'

	-- add physics to the barrel
	physics.addBody( barrel, "static", { density=0.8, friction=0.6 } )

	-- all display objects must be inserted into group

	sceneGroup:insert( barrel )

	-- chamando gerarOBJETOS aleatorios
	sceneGroup:insert(texto)


end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
    local bgMusic = audio.loadStream("the-fall-song.mp3")
    audio.setVolume( 0.50 , { channel=1 })
    audio.play(bgMusic, {loops = -1, channel = 1, fadein = 2000})

    local bgFx = audio.loadStream("waterfall.mp3")
    audio.setVolume( 0.10 , { channel=2 })
    audio.play(bgFx, {loops = -1, channel = 2, fadein = 2000})

		lifeCount = 3
		pontos = 0
		contador = 0

		barrel.x, barrel.y = (_W/3) + 50, _H - _H - 50

    for i = 1, lifeCount do
      local life = display.newImageRect( "barrel_2.png", 25, 30 )
      life.x, life.y = 0 + i*28, 5;
      lives[i] = life
    end

    local callfire = function() return fire(sceneGroup) end
  	particleTimer = timer.performWithDelay(200, fire, -1)

		local generate = function() return gerarPedra(sceneGroup) end

		gerarPedraTimer = timer.performWithDelay(delayGerarPedra, generate, -1)
		moveBarrelTimer = timer.performWithDelay(50, moveBarrel, -1)
		atualizarPontosTimer = timer.performWithDelay(1000, atualizarPontos, -1)
		rebolaPiranhaTimer = timer.performWithDelay(delayGerarPedra + 200, rebolaPiranha, -1)

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
local function gameOver()
	timer.cancel(atualizarPontosTimer);
	timer.cancel(gerarPedraTimer);
	timer.cancel(particleTimer);
	timer.cancel(rebolaPiranhaTimer);
	audio.stop();
	composer.gotoScene( "gameover", "fade", 500 );
end

-------------------Eventos do teclado--------------------------------------
local splashSound = audio.loadSound( "water-splash.wav" )
local action = {
  [-1] = function (barrel) transition.to( barrel, { time=50, x=(_W / 3 ) - 20 } ) end,
  [0] = function (barrel) transition.to( barrel, { time=50, x=(_W / 3) + 50 } ) end,
  [1] = function (barrel) transition.to( barrel, { time=50, x=_W - 80 } ) end
}
local countArrow = 0
-- Called when a key event has been received
local function onKeyEvent( event )
		-- transition.to( rect.path, { time=2000, height=100, x1=0 } )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    print( message )
		if  event.phase == "down" then
		    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
		    if ( event.keyName == "left" and countArrow>-1) then
					countArrow = countArrow-1
					audio.play(splashSound)
		    end
				if ( event.keyName == "right" and countArrow<1) then
					countArrow = countArrow+1
					audio.play(splashSound)
				end

				action[countArrow](barrel)
		end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

--------------------------------------- swipe events ------------------------------
local function handleSwipe( event )
		print(event.phase)
    if ( event.phase == "ended" ) then
        local dX = event.x - event.xStart
        print( countArrow )
        if ( dX > 10 and countArrow<1) then
            --swipe right
            countArrow = countArrow+1
						audio.play(splashSound)
        elseif ( dX < -10 and countArrow>-1) then
            --swipe left
						countArrow = countArrow-1
						audio.play(splashSound)
        end
				action[countArrow](barrel)
    end
    return true
end

Runtime:addEventListener( "touch", handleSwipe )

-- Collision event
local rockSound = audio.loadSound( "rock-crash.wav" )

local function onGlobalCollision( event )
		if ( event.object1.myName == "Barril" ) then
		audio.play( rockSound );
		lifeCount = lifeCount - 1;
		updateLives();
		if lifeCount < 1 then
			gameOver();
		end
        pontos = pontos -3
				scrollSpeed = scrollSpeed + 0.05
				if pontos < 0 then
					pontos = 0
				end
		end
		if ( (event.object1.myName == "Pedra" or event.object1.myName == "Piranha") and event.object2.myName == "Barril" ) then
        event.object1:removeSelf()
				event.object1 = nil
		end
    if ( (event.object2.myName == "Pedra" or event.object2.myName == "Piranha") and event.object1.myName == "Barril") then
        event.object2:removeSelf()
				event.object2 = nil
    end
end

Runtime:addEventListener( "collision", onGlobalCollision )


-- Add the key event listener
Runtime:addEventListener( "key", onKeyEvent )
-- Create a runtime event to move backgrounds
Runtime:addEventListener( "enterFrame", move )
return scene
