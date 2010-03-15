love.filesystem.load("utils.lua")()
love.filesystem.load("animation.lua")()

function love.load()
	math.randomseed( os.time() )
	
	--set stuff up
	love.graphics.setBackgroundColor(0,0,0)
	love.mouse.setVisible(false)
	love.graphics.setColorMode("replace")
	fonts = {
        title= { 
            normal = love.graphics.newFont("fonts/clonewars.ttf"),
            larger = love.graphics.newFont("fonts/clonewars.ttf", 36),
            largest = love.graphics.newFont("fonts/clonewars.ttf", 46)
        },
        normal=love.graphics.newFont("fonts/DroidSans.ttf"),
        bold= {
            normal=love.graphics.newFont("fonts/DroidSans-Bold.ttf"),
            larger=love.graphics.newFont("fonts/DroidSans-Bold.ttf", 14)
        },
        mono=love.graphics.newFont("fonts/DroidSansMono.ttf")
    }
    love.graphics.setFont(fonts.normal)
    love.graphics.setLine(1, "rough" )
	
	--initialize images
    bg = {image=love.graphics.newImage("images/bg.png"), x1=0, y1=0, x2=0, y2=0, width=0}
    bg.width=bg.image:getWidth()
    bg.x2=bg.width
    earth = {image=love.graphics.newImage("images/earth.png"), width=0, height=0, rotation=0}
    earth.width=earth.image:getWidth()
    earth.height=earth.image:getHeight()
    pointer = {image=love.graphics.newImage("images/pointer.png"), width, height}
    pointer.width = pointer.image:getWidth()
    pointer.height = pointer.image:getHeight()
    titletext = {image=love.graphics.newImage("images/titletext.png"),width=0}
    titletext.width = titletext.image:getWidth()
    titlemenu = {play=love.graphics.newImage("images/play.png"), help=love.graphics.newImage("images/help.png"), quit=love.graphics.newImage("images/quit.png"), width=0, height=0}
    titlemenu.width = titlemenu.play:getWidth()
    titlemenu.height = titlemenu.play:getHeight()
    explosion = love.graphics.newImage("images/explosions.png")
    explosionwidth = 64
    explosionheight = 64
    explosions = {}
    ui = {
        health = love.graphics.newImage("images/health.png"),
        ammo = love.graphics.newImage("images/ammo.png")
    }
    powerups = {
		types = {
			{
				name = "ammo",
				sprite = love.graphics.newImage("images/ammopack.png"),
				width, height
			}
		},
		onscreen = {}
    }
    for i,v in ipairs(powerups.types) do
		v.width = v.sprite:getWidth()
		v.height = v.sprite:getHeight()
    end
    
    ranks = {
		{name="Airman", image},
		{name="Airman First Class", image},
		{name="Sergeant", image},
		{name="Staff Sergeant", image},
		{name="Technical Sergeant", image},
		{name="Master Sergeant", image},
		{name="Senior Master Sergeant", image},
		{name="Special Master Sergeant", image},
		{name="Chief Master Sergeant", image},
		{name="Command Chief Master Sergeant", image},
		{name="Chief Master Sergeant of the Air Force", image},
		{name="Second Liutenant", image},
		{name="First Lieutenant", image},
		{name="Captain", image},
		{name="Major", image},
		{name="Lieutenant Colonel", image},
		{name="Colonel", image},
		{name="Brigadier General", image},
		{name="Major General", image},
		{name="Lieutenant General", image},
		{name="General Air Force Chief of Staff", image},
		{name="General of the Air Force", image}
    }
    for i,v in ipairs(ranks) do
		v.image = love.graphics.newImage("images/badges/"..i..".png")
    end
    
	--initialize useful variables
	screenHeight = love.graphics.getHeight()
	screenWidth = love.graphics.getWidth()
    gamemode = "menu"
    help = false
    pause = false
    mx = 0
    stage = 0
    waves = 0
    currentwave = 0
    timer = 0
    debugmode = false
    player = {
        images = {
            normal = {
                sprite = love.graphics.newImage("images/ship/n.png"),
                width, height
            },
            left =  {
                sprite = love.graphics.newImage("images/ship/l.png"),
                width, height
            },
            right = {
                sprite = love.graphics.newImage("images/ship/r.png"),
                width, height
            },
            shot = {
                sprite = love.graphics.newImage("images/shot.png"),
                width, height
            },
        },
        x=400,
        y=650,
        health = 100,
        ammo = 50,
        score = 0,
        state = "normal",
        speed = 200,
        live = true
        
    }
    player.images.normal.width = player.images.normal.sprite:getWidth()
    player.images.normal.height = player.images.normal.sprite:getHeight()
    player.images.left.width = player.images.left.sprite:getWidth()
    player.images.left.height = player.images.left.sprite:getHeight()
    player.images.right.width = player.images.right.sprite:getWidth()
    player.images.right.height = player.images.right.sprite:getHeight()
    player.images.shot.width = player.images.shot.sprite:getWidth()
    player.images.shot.height = player.images.shot.sprite:getHeight()
    
    projectiles = {
        playershots = {}
    }
    
    enemies = {
		types = {
			{
				name = "ufo",
				sprite = love.graphics.newImage("images/enemies/ufo.png"),
				width, height,
				health = 10,
				v = 100,
				score = 100
			}
		},
		onscreen = {},
		tocreate = 0
    }
    
    for i,v in ipairs(enemies.types) do
		v.width = v.sprite:getWidth()
		v.height = v.sprite:getHeight()
    end
    
    
    --text
    helpline = {
        "The situation is dire. Aliens have overtaken our moon base and are now heading for earth.",
        "You are our last line of defence. The odds are against you, but we believe in you.",
        "Now go kick some ET butt!",
        " ",
        "Use W A S D to control your ship",
        " ",
        "Aim using the mouse.",
        "Left click to fire.",
        "Escape to pause.",
        " ",
        "Kill aliens to get more ammo"
    }
	
	--initialize sounds
    sounds = {
        intro = love.audio.newSource("audio/music/intro.ogg", stream),
        music = love.audio.newSource("audio/music/music.ogg", stream),
        rlaunch = love.sound.newSoundData("audio/sounds/launch.ogg", static),
        queue = {}
    }
    sounds.intro:setLooping(true)
    sounds.music:setLooping(true)
    
    love.audio.play(sounds.intro)
end

function love.update(dt)
	if pause == false then
		dt = (dt < 0.1 and dt) or 0.1
		if bg.x1 > -bg.width then
	        bg.x1 = bg.x1-5*dt
	        bg.x2 = bg.x2-5*dt
	    elseif bg.x1 <= -bg.width then
	        bg.x1 = bg.x2+bg.width
	    elseif bg.x2 <= -bg.width then
	        bg.x2 = bg.x1+bg.width
	    end
	    earth.rotation= earth.rotation+.5*dt
	    
	    --Sound queue
	    for i,v in ipairs(sounds.queue) do
	        love.audio.play(v)
	        table.remove(sounds.queue, i)
	    end
	    
	    if gamemode == "getready" then
	        if mx < 800 then
	            mx = mx+500*dt
	        else
	            gamemode = "startgame"
	            mx = 650
	            vol = 1.0
	        end
	    end
	    
	    if gamemode == "startgame" then
	        
	        if vol <= 0 then
	            love.audio.stop(sounds.intro)
	            love.audio.play(sounds.music)
	        else
	            vol = vol-2.0*dt
	            sounds.intro:setVolume(vol)
	        end
	        if mx > 500 then
	            mx = mx-200*dt
	        else
	            player.x = 400
	            player.y = mx-20
	            shotdelay = 0
	            gamemode = "game"
	        end
	    end
	    
	    if gamemode == "game" then
			shotdelay = shotdelay - 1*dt
	        if vol <= 0 and not sounds.intro:isStopped() then
	            love.audio.stop(sounds.intro)
	            love.audio.play(sounds.music)
	        else
	            vol = vol-2.0*dt
	            sounds.intro:setVolume(vol)
	        end
	        
	        if player.health <= 0 and player.live == true then
				local expl = {animation = newAnimation(explosion, 128, 128, 0.2, 10), x=player.x-explosionwidth, y=player.y-explosionheight, live=true}
				expl.animation:setMode("once")
				table.insert(explosions, expl)
				player.x = 1500
				player.y = 1500
				timer = 2
				player.live = false
	        end
	        
	        if love.keyboard.isDown("a") and player.x > widthoffset/2 then
	            player.x = player.x - player.speed*dt
	            player.state = "left"
	        elseif love.keyboard.isDown("d") and player.x < 800-widthoffset/2 then
	            player.x = player.x + player.speed*dt
	            player.state = "right"
	        else
	            player.state = "normal"
	        end
	        if love.keyboard.isDown("w") and player.y > 0 then
	            player.y = player.y - player.speed*dt
	        elseif love.keyboard.isDown("s") and player.y < 600-heightoffset then
	            player.y = player.y + player.speed*dt
	        end
	        
	        if player.state == "normal" then
				widthoffset = player.images.normal.width
				heightoffset = player.images.normal.height
			elseif player.state == "left" then
				widthoffset = player.images.left.width
				heightoffset = player.images.left.height
			elseif player.state == "right" then
				widthoffset = player.images.right.width
				heightoffset = player.images.right.height
			end
			
			if timer <= 0 then
				if enemies.tocreate > 0 then
					table.insert(enemies.onscreen, createRandEnemy())
					enemies.tocreate = enemies.tocreate-1
					timer = 2
				else
					stage = stage + 1
					waves = waves + 3
					currentwave = currentwave+1
					enemies.tocreate = stage*currentwave
				end
				if player.health <= 0 then
					gamemode = "gameover"
				end
			end
			
			timer = timer-1*dt
			
			for i=#explosions, 1,-1 do
				if explosions[i].live == false then
					table.remove(explosions, i)
				end
			end
			
			for i,v in ipairs(explosions) do
				v.animation:update(dt)
				if v.animation:getCurrentFrame() == 10 then
					v.live = false
				end
			end
	        
	        --update enemy movements
	        for i,v in ipairs(enemies.onscreen) do
				v.y = v.y + v.speed*v.scale.y*dt
				if v.y < 300 and v.y > 0 then
					v.scale.y = 0.75 + 0.5*(v.y/(300))
					v.scale.x = v.scale.y
				end
				--remove out of bounds enemies
				if v.y > 600 then
					v.health = 0
				end
	        end
	        
	        --update powerup movements
	        for i,v in ipairs(powerups.onscreen) do
				v.y = v.y + 100*dt
				
				--remove out of bounds powerups
				if v.y > 600 then
					v.live = false
				end
	        end
	        
	        -- Check for enemy collisions
	        for i,v in ipairs(enemies.onscreen) do
				local enemywidth = (enemies.types[v.type].width*v.scale.x)/2
				local enemyheight = (enemies.types[v.type].height*v.scale.y)/2		
				--Check for enemy-player
				if rectRectCollision(v.x, v.y, enemies.types[v.type].width, enemies.types[v.type].height,player.x-widthoffset/2, player.y, widthoffset, heightoffset) then
					player.health = player.health - v.maxhealth
					v.health = 0
				end
	        end
	        
	        for i,v in ipairs(projectiles.playershots) do
	            --update projectile movement
	            v.position.y = v.position.y - lengthdir_y(v.v, math.deg(v.direction))*dt
	            v.position.x = v.position.x + lengthdir_x(v.v, math.deg(v.direction))*dt
	
	            --update projectile speed
	            if v.v < 250 then
	                v.v = v.v*1.1+1*dt
	            end
	            
	            --Remove dead projectiles
	            if v.position.y < -5 or v.position.x < -5 or v.position.x > 805 then
	                table.remove(v, i)
	            end
	            
	            -- Check for enemy collisions
	            for i,v in ipairs(enemies.onscreen) do
					local enemywidth = (enemies.types[v.type].width*v.scale.x)/2
					local enemyheight = (enemies.types[v.type].height*v.scale.y)/2
					
					--Check for playershot-enemy
					for n,c in ipairs(projectiles.playershots) do
						if circRectCollision(v.x, v.y, enemies.types[v.type].width, enemies.types[v.type].height, c.position.x, c.position.y, player.images.shot.width/2) then
							c.live = false
							v.health = v.health - c.power
						end
					end
	            end
	        end
	        for i=#enemies.onscreen,1,-1 do --do this again with projectiles.playershots
				if enemies.onscreen[i].health <= 0 then
					player.score = player.score + enemies.onscreen[i].score
					table.insert(powerups.onscreen, {type=1,ammo=enemies.onscreen[i].ammo, x=enemies.onscreen[i].x+enemies.types[enemies.onscreen[i].type].width/2, y=enemies.onscreen[i].y, live=true})
					local expl = {animation = newAnimation(explosion, 128, 128, 0.2, 10), x=enemies.onscreen[i].x+enemies.types[enemies.onscreen[i].type].width/2-explosionwidth, y=enemies.onscreen[i].y+enemies.types[enemies.onscreen[i].type].height/2-explosionheight, live=true}
					expl.animation:setMode("once")
					table.insert(explosions, expl)
					table.remove(enemies.onscreen, i)
				end
			end
			
			for i=#projectiles.playershots, 1,-1 do
				if projectiles.playershots[i].live == false then
					table.remove(projectiles.playershots, i)
				end
			end
	        for i=#powerups.onscreen, 1, -1 do
				if rectRectCollision(powerups.onscreen[i].x, powerups.onscreen[i].y, powerups.types[powerups.onscreen[i].type].width,powerups.types[powerups.onscreen[i].type].height, player.x-widthoffset/2, player.y, widthoffset, heightoffset) then
					powerups.onscreen[i].live = false
					player.ammo = player.ammo + powerups.onscreen[i].ammo
				end
				if powerups.onscreen[i].live == false then
					table.remove(powerups.onscreen, i)
				end
			end
	    end
	end
end

function love.draw()
    love.graphics.setFont(fonts.normal)
    love.graphics.draw(bg.image, bg.x1, bg.y1)
    love.graphics.draw(bg.image, bg.x2, bg.y2)
    love.graphics.draw(earth.image, 411, 600+earth.height-1310, math.rad(earth.rotation), 1, 1, earth.width/2, earth.height/2)
    if debugmode then
		love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
		love.graphics.print( "Mouse X: ".. love.mouse.getX(), 10, 35 )
		love.graphics.print( "Mouse Y: ".. love.mouse.getY(), 10, 50 )
		love.graphics.print( "Enemies: ".. table.getn(enemies.onscreen), 10, 65)
		love.graphics.print( "Enemies.tocreate: ".. enemies.tocreate, 10, 80 )
		love.graphics.print( "Stage: ".. stage, 10, 95)
		love.graphics.print( "Wave: ".. currentwave.."/"..waves, 10, 110)
    end
    
    if gamemode == "menu" then
        love.graphics.draw(titletext.image, 400-titletext.width/2, 65)
        love.graphics.draw(titlemenu.play, 400-titlemenu.width/2, 250)
        love.graphics.draw(titlemenu.help, 400-titlemenu.width/2, 270+titlemenu.height)
        love.graphics.draw(titlemenu.quit, 400-titlemenu.width/2, 290+titlemenu.height*2)
        
    elseif gamemode == "getready" then
        if mx+400+titletext.width/2 > 0 then
            love.graphics.draw(titletext.image, 400-titletext.width/2+mx, 65)
            love.graphics.draw(titlemenu.play, 400-titlemenu.width/2-mx, 250)
            love.graphics.draw(titlemenu.help, 400-titlemenu.width/2+mx, 270+titlemenu.height)
            love.graphics.draw(titlemenu.quit, 400-titlemenu.width/2-mx, 290+titlemenu.height*2)
        end
        
    elseif gamemode == "startgame" then
        
        love.graphics.draw(player.images.normal.sprite, 400, mx-20, 0, 1,1,player.images.normal.width/2, 0)
        love.graphics.draw(ui.health, 30,mx+60)
        love.graphics.draw(ui.ammo, 180, mx+60)
        love.graphics.setFont(fonts.title.larger)
        love.graphics.print(player.health.."%", 65, mx+83)
        love.graphics.print(player.ammo, 215, mx+83)
        love.graphics.printf(player.score, 650, 600-mx-75, 130, "right")
        
    elseif gamemode == "game" then
    
		if debugmode == true then
			love.graphics.rectangle("fill", player.x-widthoffset/2, player.y, widthoffset, heightoffset)
		end
        if player.state == "normal" then
            love.graphics.draw(player.images.normal.sprite, player.x, player.y, 0, 1,1, player.images.normal.width/2, 0)
        elseif player.state == "left" then
            love.graphics.draw(player.images.left.sprite, player.x, player.y, 0, 1,1, player.images.normal.width/2, 0)
        elseif player.state == "right" then
            love.graphics.draw(player.images.right.sprite, player.x, player.y, 0, 1,1, player.images.normal.width/2, 0)
        end
        
        --Draw all powerups
        for i,v in ipairs(powerups.onscreen) do
			if debugmode == true then
				love.graphics.rectangle("fill", v.x, v.y, powerups.types[v.type].width, powerups.types[v.type].height)
			end
			love.graphics.draw(powerups.types[v.type].sprite, v.x, v.y)
        end
        
        --Draw all enemies
        for i,v in ipairs(enemies.onscreen) do
			if debugmode == true then
				love.graphics.rectangle("fill", v.x, v.y, enemies.types[v.type].width*v.scale.x, enemies.types[v.type].height*v.scale.y)
				--Draw health bars
				love.graphics.setColor(108,213,87,100)
				local health = (enemies.types[v.type].width-3)*(v.health/v.maxhealth)
				love.graphics.rectangle("fill", v.x+3, v.y-10, health*v.scale.x, 5)
			end
			love.graphics.draw(enemies.types[v.type].sprite, v.x, v.y, v.rotation, v.scale.x, v.scale.y, 0, 0)
        end
        
        --Draw all projectiles
        for i,v in ipairs(projectiles.playershots) do
            love.graphics.draw(player.images.shot.sprite, v.position.x, v.position.y, v.direction, 1, 1, player.images.shot.width/2, player.images.shot.height/2)
        end
        
        --Draw all explosions
        for i,v in ipairs(explosions) do
			v.animation:draw(v.x,v.y)
		end

        love.graphics.draw(ui.health, 30,mx+60)
        love.graphics.draw(ui.ammo, 180, mx+60)
        love.graphics.setFont(fonts.title.larger)
        if player.health >= 0 then
			love.graphics.print(player.health.."%", 65, mx+83)
		else 
			love.graphics.print("0%", 65, mx+83)
		end
        love.graphics.print(player.ammo, 215, mx+83)
        love.graphics.printf(player.score, 650, 600-mx-75, 130, "right")
    
    elseif gamemode == "gameover" then
		love.graphics.setFont(fonts.title.larger)
		love.graphics.print("GAME OVER", 300, 150)
        love.graphics.print("Score: "..player.score, 300, 190)
        love.graphics.print("Rank:", 300, 250)
        local level = round(player.score/3000,0)
        love.graphics.setFont(fonts.title.largest)
        
        if level <= #ranks and level ~= 0 then
			local rank = ranks[level]
			love.graphics.draw(rank.image, 320, 270)
			local ranklength = fonts.title.largest:getWidth(rank.name)
			love.graphics.printf(rank.name, 400-ranklength/2, 480, 725, "left")
		elseif level == 0 then
			local rank = "Airman Basic"
			local ranklength = fonts.title.largest:getWidth(rank)
			love.graphics.printf(rank, 400-ranklength/2, 290, 725, "left")
		elseif level > #ranks then
			local rank = ranks[#ranks]
			love.graphics.draw(rank.image, 320, 270)
			local ranklength = fonts.title.largest:getWidth(rank.name)
			love.graphics.printf(rank.name, 400-ranklength/2, 352, 725, "left")
		end
    end
    
    if help then
		--draw help window
		love.graphics.setColor(0,0,0,230)
		love.graphics.circle("fill", 140, 210, 10, 50)
		love.graphics.circle("fill", 660, 210, 10, 50)
		love.graphics.circle("fill", 140, 525, 10, 50)
		love.graphics.circle("fill", 660, 525, 10, 50)
		
		love.graphics.rectangle("fill", 140, 200, 520, 10)
		love.graphics.rectangle("fill", 130, 210, 540, 315)
		love.graphics.rectangle("fill", 140, 525, 520, 10)
		
		love.graphics.setColor(12,166,1,25)
		love.graphics.rectangle("fill", 133, 213, 535, 312)
		
		love.graphics.setColor(108,213,87,15)
		local lineheight = 0
		local i = 1
		
		--lines and help text
		love.graphics.setFont(fonts.normal)
		while lineheight + 235 < 508 do
			love.graphics.line(140, 235+lineheight, 663, 235+lineheight)
			lineheight = lineheight+17
		end
		for i,v in ipairs(helpline) do
			love.graphics.printf(v, 150, 230+i*17-17,530, "left")
		end
		
		--Cancel button
		love.graphics.setFont(fonts.bold.larger)
		love.graphics.print("Close help", 570, 505, 0, 1,1)
	end
    
    love.graphics.draw(pointer.image, love.mouse.getX(), love.mouse.getY(), 0, 1, 1, pointer.width/2, pointer.height/2)
end

function love.keypressed(key)
    if key == "escape" and gamemode == "game" then
			pause = not pause
    end
    
    if key == "tab" then
		debugmode = not debugmode
    end
    
    if key == "k" then
		player.health = 0
    end
    
    if key == " " then
		table.insert(enemies.onscreen, createRandEnemy())
    end
end

function love.mousereleased(x, y, button)
	if pause == false then
	    if button == 'l' then
	        if gamemode == "menu" and not help then
	            if x >= 400-titlemenu.width/2 and x <= 400+titlemenu.width/2 then
	                if y >= 250 and y <= 250+titlemenu.height then
	                    gamemode = "getready"
	                elseif y >= 270+titlemenu.height and y <= 270+titlemenu.height*2 then
	                    help = true
	                elseif y >= 290+titlemenu.height*2 and y <= 290+titlemenu.height*3 then
	                    love.event.push('q')
	                end
	            end
	        elseif help then
	            if x >= 565 and x <= 645 and y >= 490 and y <= 510 then
	                help = false
	            end
	        end
	        
	        if gamemode == "game" and player.ammo > 0 and shotdelay <=0 and y <= player.y then
	            table.insert(projectiles.playershots, {
	                start={
	                    x=player.x,
	                    y=player.y
	                }, 
	                target = {
	                    x=x,
	                    y=y
	                },
	                position={
	                    x=player.x,
	                    y=player.y
	                },
	                direction = math.atan2((y-player.y),(x-player.x)),
	                v = 5,
	                live = true,
	                power = 15
	            })
	            addSound(sounds.rlaunch)
	            player.ammo = player.ammo-1
	            shotdelay=0.5
	        end
	    end
	end
end
