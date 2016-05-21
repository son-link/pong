--[[
	Pong
	© 2016 Alfonso Saavedra "Son Link"
	Under the GNU/GPL 3 license
	http://github.com/son-link/EntroPipes
	http://son-link.github.io
]]

W = 640
H = 480

padHeight = 60

player1 = {posY=H/2-30, score=0}
player2 = {posY=H/2-30, score=0}
ball = {posX=H/2-30, posY=230, xvel = -1, yvel = 0}

gameState = 0 -- 0: Title screen, 1 play, 2 win/lose, 3 pause
vsCPU = true

function love.load()
	love.window.setMode(W, H, {resizable=false, centered=true})
	love.window.setTitle("Pong")
	love.graphics.setBackgroundColor(0,0,0)
	font = love.graphics.newFont("PixelOperator8.ttf", 40)
	font2 = love.graphics.newFont("PixelOperator8.ttf", 20)
	love.graphics.setFont(font)
	hitfx = love.audio.newSource('hit.wav')
end

function love.update(dt)
	if gameState == 1 then
		if vsCPU then
			player2IA(dt)
		else
			if love.keyboard.isDown('o') and player2.posY >= 60 then
				player2.posY = player2.posY - dt * 150
			elseif love.keyboard.isDown('l') and player2.posY + 60 <= H then
				player2.posY = player2.posY + dt * 150
			end
		end
		if love.keyboard.isDown('w') and player1.posY >= 60 then
			player1.posY = player1.posY - dt * 150
		elseif love.keyboard.isDown('s') and player1.posY + 60 <= H then
			player1.posY = player1.posY + dt * 150
		end
		
		ball.posX = ball.posX + ball.xvel * (dt*180)
		ball.posY = ball.posY + ball.yvel * (dt*180)
		
		if CheckCollision(10, player1.posY, 20, padHeight, ball.posX, ball.posY-10, 20, 20) then
			ball.xvel = 1
			hitfx:play()
			local diff = -((player1.posY + (padHeight / 2)) - (ball.posY+10))
			if diff >= 2 then
				ball.yvel = 1
			elseif diff <= -2 then
				ball.yvel = -1
			end
		elseif CheckCollision(W-30, player2.posY, 20, padHeight, ball.posX-10, ball.posY-10, 20, 20) and ball.posX <= W-10 then
			ball.xvel = -1
			hitfx:play()
			local diff = -((player2.posY + (padHeight / 2)) - (ball.posY+10))
			if diff >= 2 then
				ball.yvel = 1
			elseif diff <= -2 then
				ball.yvel = -1
			end
		elseif ball.posX <= 0 then
			player2.score = player2.score+1
			resetball()
		elseif ball.posX >= W then
			player1.score = player1.score+1
			resetball()
		elseif ball.posY <= 60 then
			hitfx:play()
			ball.yvel = 1
		elseif ball.posY + 20 >= H then
			ball.yvel = -1
			hitfx:play()
		end
	end
	
	if player1.score == 10 or player2.score == 10 then
		gameState = 2
	end
end

function love.draw()
	love.graphics.setColor(255,255,255)
	
	if gameState == 0 then
		love.graphics.printf("PONG", 0, 80, W, 'center')
		love.graphics.setFont(font2)
		love.graphics.printf("Press 1 to play vs CPU", 0, 150, W, 'center')
		love.graphics.printf("Press 2 to play vs another player", 0, 180, W, 'center')
		love.graphics.setFont(font)
	elseif gameState == 1 then
		love.graphics.rectangle('fill', 0, 58, W, 2)
		love.graphics.rectangle('fill', (W/2)-2, 60, 4, H)
		love.graphics.rectangle('fill', 10, player1.posY, 20, padHeight)
		love.graphics.rectangle('fill', W-30, player2.posY, 20, padHeight)
		love.graphics.rectangle('fill', ball.posX, ball.posY, 20, 20)
		love.graphics.print(player1.score, 40, 10)
		love.graphics.print(player2.score, W-60, 10)
	elseif gameState == 2 then
		love.graphics.printf('Player 1', 0, 80, W/2, 'center')
		if vsCPU then
			love.graphics.printf('CPU', W/2, 80, W/2, 'center')
		else
			love.graphics.printf('Player 2', W/2, 80, W/2, 'center')
		end
		love.graphics.printf(player1.score, 0, 130, W/2, 'center')
		love.graphics.printf(player2.score, W/2, 130, W/2, 'center')
		if player1.score > player2.score then
			if vsCPU then
				love.graphics.printf('YOU WIN', 0, 200, W, 'center')
			else
				love.graphics.printf('PLAYER 1 WIN', 0, 200, W, 'center')
			end
		else
			if vsCPU then
				love.graphics.printf('YOU LOSE', 0, 200, W, 'center')
			else
				love.graphics.printf('PLAYER 2 WIN', 0, 200, W, 'center')
			end
		end
	elseif gameState == 3 then
		love.graphics.rectangle('fill', 0, 58, W, 2)
		love.graphics.rectangle('fill', (W/2)-2, 60, 4, H)
		love.graphics.print(player1.score, 40, 10)
		love.graphics.print(player2.score, W-60, 10)
		love.graphics.printf('PAUSE', 0, H/2-20, W, 'center')
	end
end

function love.keypressed(key)
	if gameState == 0 then
		if key == '1' then
			vsCPU = true
			gameState = 1
		elseif key == '2' then
			vsCPU = false
			gameState = 1
		end
	else
		if key == 'space' then
			if gameState == 1 then
				gameState = 3
			elseif gameState == 3 then
				gameState = 1
			end
		end
	end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function calcPosCol(padx)
	return ((padx+padHeight) - ball.posY)
end

function resetball()
	ball.posX = 320
	ball.posY = H/2-30
	ball.yvel = 0
end

function player2IA(dt)
	local diff = -((player2.posY + (padHeight / 2)) - (ball.posY+10))
	if diff >= 4 then
		player2.posY = player2.posY + dt * 150
	elseif diff <= -4 then
		player2.posY = player2.posY - dt * 150
	end
end
