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

normal = 0
spirit = 0

curNode = 0
racePath = 0

speed = 1500

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "arnassi-spirit")	
	--entity_setTexture(me, "missingImage")
	
	entity_setSpiritFreeze(me, false)
	
	entity_setState(me, STATE_IDLE)
	
	normal = entity_getBoneByName(me, "normal")
	spirit = entity_getBoneByName(me, "spirit")
	
	bone_setBlendType(normal, BLEND_ADD)
	bone_alpha(normal, 1)
	bone_color(normal, 0.5, 0.6, 1)
	
	bone_alpha(spirit, 0)
	
	bone_rotateOffset(normal, 360, 0.5, -1)
	
	entity_setCullRadius(me, 512)
	
	racePath = getNode("arnassipath")	
	c = 0
	e = getFirstEntity()
	while e ~= 0 do
		if entity_isName(e, "arnassi-spirit") then
			c = c + 1
		end
		e = getNextEntity()
	end
	curNode = c*5
	

	x, y = node_getPathPosition(racePath, curNode)
	entity_setPosition(me, x, y)

end

function postInit(me)
	n = getNaija()
	entity_setTarget(me, n)
end

function update(me, dt)
	if not entity_isInterpolating(me) then
		
		curNode = curNode + 1
		x, y = node_getPathPosition(racePath, curNode)
		if x == 0 and y == 0 then
			curNode = 0
			x, y = node_getPathPosition(racePath, curNode)
		end
		entity_setPosition(me, x, y, -speed)
		
		if x > entity_x(me) and not entity_isfh(me) then
			entity_fh(me)
		elseif x < entity_x(me) and entity_isfh(me) then
			entity_fh(me)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function shiftWorlds(me, lt, wt)
	t = 0.9
	if wt == WT_SPIRIT then
		entity_scale(me, 0.8, 0.8, t, 0, 0, 1)
		bone_alpha(normal, 0.4, t)
		bone_alpha(spirit, 0.8, t)
		bone_scale(normal, 3, 3, t)
	elseif wt == WT_NORMAL then
		entity_scale(me, 1, 1, t, 0, 0, 1)
		bone_alpha(normal, 1, t)
		bone_alpha(spirit, 0, t)
		bone_scale(normal, 1, 1, t)
	end
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
