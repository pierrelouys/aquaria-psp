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

function init(me)
	if isFlag(FLAG_MAINAREA_ENERGYTEMPLE_ROCK, 1) then
		local rock = node_getNearestEntity(me, "Rock0001")
		local node = getNode("ENERGYTEMPLE_ROCK_MOVED")
		if node ~= 0 then
			entity_setPosition(rock, node_x(node), node_y(node))
		end
	end
end

function activate(me)
end

function update(me, dt)
	if isFlag(FLAG_MAINAREA_ENERGYTEMPLE_ROCK, 0) then
		if node_isEntityIn(me, getNaija()) then
			--debugLog("setting FLAG FOR ROCK")
			voiceOnce("Naija_EnterEnergyTemple")
			setFlag(FLAG_MAINAREA_ENERGYTEMPLE_ROCK, 1)
		end
	end
end
