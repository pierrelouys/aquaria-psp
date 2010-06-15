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

dofile("scripts/entities/entityinclude.lua")

n = 0

STATE_PULL			= 1001

entToSpawn = ""
ingToSpawn = ""
amount = 0

pullTimer			= 0
pullMax				= 0.2

leaf1 				= 0
leaf2				= 0

function commonInit(me, ent, ing, amt)
	setupEntity(me)
	amount = amt
	if amount == 0 then
		amount = 1
	end
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "PullPlant")
	
	entity_setProperty(me, EP_MOVABLE, true)	
	
	entity_setState(me, STATE_IDLE)
	
	entToSpawn = ent
	ingToSpawn = ing
	entity_setEntityLayer(me, -2)
	
	leaf1 = entity_getBoneByIdx(me, 0)
	leaf2 = entity_getBoneByIdx(me, 1)
	
	sz1 = 1 + math.random(1000)/4000.0
	sz2 = 1 + math.random(1000)/4000.0
	bone_scale(leaf1, sz1, sz1)
	bone_scale(leaf2, sz2, sz2)
end

function postInit(me)
	n = getNaija()
	entity_setTarget(me, n)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) and entity_isBeingPulled(me) then
		pullTimer = pullTimer + dt
		if pullTimer > pullMax then
			entity_setState(me, STATE_PULL)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_PULL) then
		entity_setStateTime(me, entity_animate(me, "pull")-0.2)

	end
end

function exitState(me)
	if entity_isState(me, STATE_PULL) then

		

		entity_alpha(me, 0, 0.2)
		entity_delete(me, 0.2)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_PULL) then
		if key == 2 then
			if ingToSpawn ~= "" then
				spawnIngredient(ingToSpawn, entity_x(me), entity_y(me))
				playSfx("secret")
			end
		elseif key == 3 then
			if entToSpawn ~= "" then
				createEntity(entToSpawn, "", entity_x(me), entity_y(me))
				playSfx("secret")
			end
		end
	end
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
