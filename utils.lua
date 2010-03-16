--Returns the x vector from {len} and {dir}
function lengthdir_x( len, dir )
    local cos = math.cos
    local rad = math.rad
    local dir = rad( dir )
    return cos( dir ) * len
end

--Returns the y vector from {len} and {dir}
function lengthdir_y( len, dir )
	local sin = math.sin
	local rad = math.rad
    local dir = rad( dir )
    return -sin( dir ) * len
end

--add a sound to the sound queue
function addSound(sound)
    local audio = love.audio.newSource(sound, "static")
    table.insert(sounds.queue, audio)
end

function createRandEnemy()
    local randint = math.random
    local hp = randint(10,20)
    local species = randint(1 , #enemies.types )
	return {
		type = species,
		x = randint(50, screenWidth-50),
		y = -100,
		rotation = 0.0,
		scale = {
			x = 0.75,
			y = 0.75,
		},
		speed = 50,
		maxhealth = hp,
		health = hp,
		score = (hp*enemies.types[species].score)/10,
		ammo = randint(2,3),
        live = true
	}
end

function createRandAsteroid()
    local randint = math.random
    local starty = randint(0, 600)
    local targety = randint(0,600)
    local scale = randint(30, 75)/100
    local startx = 0
    local targetx = 0
    if starty%2 == 1 then
        startx = -128
        targetx = 928
    else
        startx = 928
        targetx = -128
    end
    table.insert(projectiles.debris, {
        start={
            x = startx,
            y = starty
        }, 
        target = {
            x=targetx,
            y=targety
        },
        position={
            x=startx,
            y=starty
        },
        direction = math.atan2((targety-starty),(targetx-startx)),
        rotation = randint(0, 360),
        v=100,
        live = true,
        collide = false,
        type=1,
        scale = scale
        })
end

function createExplosion(x,y)
    local expl = {animation = newAnimation(explosion, 128, 128, 0.2, 10), x=x-explosionwidth, y=y-explosionheight, live=true}
    expl.animation:setMode("once")
    table.insert(explosions, expl)
    addSound(sounds.explosion)
end

function createFireball(x,y)
    local _p = love.graphics.newParticleSystem(particle, 200)
    _p:setEmissionRate(100)
    _p:setSpeed(0, 0)
    _p:setSize(0.5, 0.25)
    _p:setColor(220, 105, 20, 255, 194, 30, 18, 0)
    _p:setPosition(300, 240)
    _p:setLifetime(0.1)
    _p:setParticleLife(0.3)
    _p:setDirection(0)
    _p:setSpread(0)
    _p:setTangentialAcceleration(0)
    _p:setRadialAcceleration(2000)
    table.insert(systems, _p)
end

function circRectCollision(enemyx, enemyy, enemywidth, enemyheight, pointx, pointy, radius)
	local pow = math.pow
	local root = math.sqrt
	--Check if the projectile is inside the enemy bounding box
	if pointx > enemyx-radius and pointy > enemyy-radius and pointx < enemyx+enemywidth+radius and pointy < enemyy+enemyheight+radius then
		return true
	--Check if the projectile is touching the corner of an enemy bounding box
	elseif root( pow( enemyx-pointx, 2 ) + pow( enemyy-pointy, 2 ) ) < radius or
	   root( pow( enemyx+enemywidth-pointx, 2 ) + pow( enemyy-pointy, 2 ) ) < radius or
	   root( pow( enemyx-pointx, 2 ) + pow( enemyy+enemyheight-pointy, 2 ) ) < radius or
	   root( pow( enemyx+enemywidth-pointx, 2 ) + pow( enemyy+enemyheight-pointy, 2 ) ) < radius then
		return true
	end
end

function circCircCollision(x1,y1,r1,x2,y2,r2)
    local root = math.sqrt
    local pow = math.pow
    local distance = root( pow( x1 - x2 , 2 ) + pow( y1-y2, 2 ) )
    if distance < r1+r2 then return true end
end

function rectRectCollision(enemyx, enemyy, enemywidth, enemyheight, playerx, playery, playerwidth, playerheight)
	local enemyx1 = enemyx
	local enemyx2 = enemyx+enemywidth
	local enemyx3 = enemyx
	local enemyx4 = enemyx+enemywidth
	local enemyy1 = enemyy
	local enemyy2 = enemyy
	local enemyy3 = enemyy + enemyheight
	local enemyy4 = enemyy + enemyheight
	
	if 	(enemyx1 >= playerx and enemyx1 <= playerx+playerwidth and enemyy1 >= playery and enemyy1 <= playery+playerheight) or
		(enemyx2 >= playerx and enemyx2 <= playerx+playerwidth and enemyy2 >= playery and enemyy2 <= playery+playerheight) or
		(enemyx3 >= playerx and enemyx3 <= playerx+playerwidth and enemyy3 >= playery and enemyy3 <= playery+playerheight) or
		(enemyx4 >= playerx and enemyx4 <= playerx+playerwidth and enemyy4 >= playery and enemyy4 <= playery+playerheight) then
		return true
	end
end

function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
