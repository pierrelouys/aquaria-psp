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

openTimer = 8

function commonInit(me, gfx)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setName(me, "SporeChildFlower")
	entity_initSkeletal(me, gfx)
	entity_setState(me, STATE_IDLE)
	--entity_setDamageTarget(me, DT_AVATAR_NATURE, true)
	entity_setAllDamageTargets(me, false)
	--entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_NATURE, true)
	entity_setCullRadius(me, 1024)
end

function postInit(me)
end

function commonUpdate(me, dt)
	if entity_isState(me, STATE_OPEN) and not entity_isAnimating(me) then
		entity_setState(me, STATE_OPENED)
	end
	if entity_isState(me, STATE_CLOSE) and not entity_isAnimating(me) then
		entity_setState(me, STATE_CLOSED)
	end	
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_CLOSED) then
		iter = 0
		ent = getEntity(iter)
		while ent~=0 do
			if entity_getAnimationName(ent)=="openFlower" then
				if entity_isEntityInRange(me, ent, 128) then
					openTimer = openTimer - dt
				end
			end
			iter = iter + 1
			ent = getEntity(iter)
		end
		if openTimer < 0 then
			entity_setState(me, STATE_OPEN)
		end
	end
end

function songNote(me, note)
--[[
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_OPEN)
	end
]]--
end

function sporesDropped(me, x, y)
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_CLOSED) then
		if entity_isPositionInRange(me, x, y, 128) then
			entity_setState(me, STATE_OPEN)
		end
	end
end

function damage(me, attacker, bone, damageType, dmg)
--[[
	if damageType == DT_AVATAR_NATURE then
		if entity_isState(me, STATE_IDLE) then
			entity_setState(me, STATE_OPEN)
		end
		return false
	end
	]]--
	return false
end

function songNoteDone(me, note, len)
end

function commonEnterState(me, state)
	if entity_isState(me, STATE_OPEN) then
		playSfx("plant-open")
		entity_animate(me, "open")
	elseif entity_isState(me, STATE_CLOSE) then
		entity_animate(me, "close")		
	end
end

function exitState(me, state)
end
