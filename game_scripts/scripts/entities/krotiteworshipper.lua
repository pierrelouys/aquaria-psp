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

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "Krotite")	
	
	entity_scale(me, 0.7, 0.7)
	
	
	v.noteBone = entity_getBoneByName(me, "Note")
	v.glow = entity_getBoneByName(me, "Glow")
	
	bone_setVisible(v.noteBone, false)
	bone_setVisible(v.glow, false)
	
	entity_setState(me, STATE_IDLE)
end

function postInit(me)
	debugLog("KROTITE POST INIT!")
	v.n = getNaija()

	entity_setTarget(me, v.n)
	
	local node = entity_getNearestNode(me, "WORSHIP2")
	if node ~= 0 and node_isEntityIn(node, me) then
		entity_animate(me, "worship2", -1)
	else
		entity_animate(me, "worship", -1)
	end
	
	--entity_setAnimLayerTimeMult(me, 0, math.random(300)/100+1)
	
	entity_updateSkeletal(me, math.random(4))
	--entity_updateSkeletal(me, randAngle360()/180)
end

v.done = false

function update(me, dt)
	if entity_isAnimating(me) and not v.done then
		entity_updateSkeletal(me, math.random(4))
		v.done = true
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
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

