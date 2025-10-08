mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter


mods.co.coCrewTargetDrones = {}
local coCrewTargetDrones = mods.co.coCrewTargetDrones
coCrewTargetDrones["CO_SLAYER_DRONE_LASER"] = true


script.on_internal_event(Defines.InternalEvents.DRONE_FIRE, function(projectile, drone)
	local bioAmount = coCrewTargetDrones[projectile.extend.name]
	if bioAmount then
		local random = math.random()
		--if random > 0.66 then return Defines.Chain.CONTINUE end
		--if drone.iShipId == 0 and random > 0.66 then return Defines.Chain.CONTINUE end
		local shipManager = Hyperspace.ships(projectile.destinationSpace)
		local crewList = shipManager.vCrewList
		local crewListEnemy = {}
		local crewListSize = 0
		for crewmem in vter(crewList) do
			if not crewmem.intruder then
				crewListSize = crewListSize + 1
				table.insert(crewListEnemy, crewmem)
			end
		end
		if crewListSize > 0 then
			local random = math.random(1, crewListSize)
			local crew = crewListEnemy[random]
			drone.targetLocation = Hyperspace.Pointf(crew.x,crew.y)
		end
	end
	return Defines.Chain.CONTINUE
end)