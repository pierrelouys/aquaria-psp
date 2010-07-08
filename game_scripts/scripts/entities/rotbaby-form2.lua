-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

v = getVars()

v.n = 0
v.evolveTimer = 0
v.fireDelay = 2

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "RotBaby/Form2")
	entity_setCollideRadius(me, 20)
	
	v.evolveTimer = 3 + math.random(3)
	entity_addRandomVel(me, 500)
	
	
	entity_setUpdateCull(me, 4000)
	
	entity_setHealth(me, 4)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	entity_setMaxSpeed(me, 600)
	
	entity_setDropChance(me, 20, 1)
	
	entity_setState(me, STATE_IDLE)	
	
	loadSound("rotcore-birth")
end

function postInit(me)
	v.n = getNaija()
end

function update(me, dt)
	entity_findTarget(me, 800)
	
	if entity_hasTarget(me) then
		
		if entity_isTargetInRange(me, 256) then
			entity_moveAroundTarget(me, dt, 2000, 1)
		else
			entity_moveTowardsTarget(me, dt, 800)
		end
	end
	
	entity_doCollisionAvoidance(me, dt, 8, 0.5)
	entity_doEntityAvoidance(me, dt, 32, 0.5)
	
	entity_rotateToVel(me, 0.1)
	
	entity_updateMovement(me, dt)

	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 400)
	
	if v.evolveTimer > 0 then
		v.evolveTimer = v.evolveTimer - dt
		if v.evolveTimer < 0 then
			spawnParticleEffect("TinyRedExplode", entity_getPosition(me))
			createEntity("RotBaby-Form3", "", entity_getPosition(me))
			entity_sound(me, "rotcore-birth")
			entity_delete(me)
		end
	end

	
	v.fireDelay = v.fireDelay - dt
	if v.fireDelay < 0 then
		v.fireDelay = math.random(3)+2
		local s = createShot("BlasterFire", me, entity_getTarget(me))
		shot_setOut(s, 32)
		entity_moveTowardsTarget(me, 1, -1000)
	end

end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_ENEMY_BEAM then
		return false
	end
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -10)
	end
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

