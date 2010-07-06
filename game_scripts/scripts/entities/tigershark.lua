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

dofile("scripts/entities/entityinclude.lua")

v.attackDelay = 0
v.dir = 1
v.n = getNaija()

function init(me)
	setupBasicEntity(
	me,
	"",							-- texture
	10,							-- health
	2,							-- manaballamount
	2,							-- exp
	10,							-- money
	64,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,							-- particle "explosion" type, 0 = none
	0,							-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "tigershark")	
	entity_generateCollisionMask(me)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_setState(me, STATE_IDLE)
	
	entity_offset(me, -0, -10)
	entity_offset(me, 0, 10, 0.5, -1, 1, 1)
	
	v.n = getNaija()
end

function update(me, dt)

	if not entity_hasTarget(me) then
		entity_findTarget(me, 400)

		if entity_hasTarget(me) then
			entity_moveTowardsTarget(me, 1, 600)
		else
			entity_addVel(me, 600*v.dir, 0)
			entity_updateMovement(me, dt)
			entity_flipToVel(me)
		end
	else		
		entity_moveTowardsTarget(me, dt, 600)
		entity_flipToEntity(me, entity_getTarget(me))
		entity_findTarget(me, 440)
	end

	entity_doEntityAvoidance(me, dt, 32, 0.5)
	entity_doCollisionAvoidance(me, dt, 4, 0.2)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	--entity_rotateToVel(me, 0, 90)
	
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1.0, 400)
	entity_handleShotCollisions(me)
	--if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.75, 400) then
	--	entity_moveTowardsTarget(me, 1, -500)
	--end
end

function hitSurface(me)
	v.dir = -v.dir
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
	end
end

function exitState(me)
end

function dieNormal(me)
	if chance(50) then
		spawnIngredient("SharkFin", entity_x(me), entity_y(me))
	end
end

function damage(me)
	return true
end

function animationKey(me, key)
end
