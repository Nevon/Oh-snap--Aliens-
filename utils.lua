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
		ammo = randint(2,3)
	}
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
