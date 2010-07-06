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

-- ================================================================================================
-- M A U L
-- ================================================================================================

dofile("scripts/entities/entityinclude.lua")

-- entity specific
STATE_FIRE				= 1000
STATE_PULLBACK			= 1001
v.fireDelay = 0

v.dir = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Crotoid",					-- texture
	6,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	64,								-- collideRadius 
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
		
	--entity_setDropChance(me, 50)
	
	entity_setMaxSpeedLerp(me, 0.5)
	entity_setMaxSpeedLerp(me, 1, 1, -1, 1)
	--entity_setSegs(me, 8, 2, 0.1, 0.9, 0, -0.03, 8, 0)
	entity_setDeathParticleEffect(me, "TinyRedExplode")
end

function update(me, dt)	
	entity_handleShotCollisions(me)	
	entity_touchAvatarDamage(me, 32, 1, 1200)
	
	if v.dir==0 then
		entity_addVel(me, -1000, 0)
	else
		entity_addVel(me, 1000, 0)
	end
	
	entity_updateMovement(me, dt)
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
	entity_flipHorizontal(me)
	if v.dir == 0 then
		v.dir = 1
	elseif v.dir == 1 then 
		v.dir = 0
	end
end

function activate(me)
end
