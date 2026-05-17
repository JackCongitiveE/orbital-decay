mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter


mods.co.coCrewTargetDrones = {}
local coCrewTargetDrones = mods.co.coCrewTargetDrones
coCrewTargetDrones["CO_SLAYER_DRONE_LASER"] = true


script.on_internal_event(Defines.InternalEvents.DRONE_FIRE, function(projectile, drone)
	local bioAmount = coCrewTargetDrones[projectile.extend.name]
	if bioAmount then
		--local random = math.random()
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
			--local random = math.random(1, crewListSize)
			local crew = crewListEnemy[1]
			drone.targetLocation = Hyperspace.Pointf(crew.x,crew.y)
		end
	end
	return Defines.Chain.CONTINUE
end)

--[[
mods.co.speedChainDrones = {}
local speedChainDrones = mods.co.speedChainDrones
speedChainDrones["CO_PLASMA_AURORA_WEAPON"] = true

script.on_internal_event(Defines.InternalEvents.DRONE_FIRE, function(projectile, drone)
	local speedApplier = speedChainDrones[projectile.extend.name]
	local speed = 2
	if speedApplier then
		speed = speed + 1
        if drone.powered then
            if drone.currentSpeed and drone.weaponCooldown >= 0 then
                drone.weaponCooldown = drone.weaponCooldown - Hyperspace.FPS.SpeedFactor / 16 * rate
                if drone.weaponCooldown <= 0 then
                    drone.weaponCooldown = -1
                end
            end
            for _ = 1, speed - 1 do
                drone:OnLoop()
            end
        end
	end
	return Defines.Chain.CONTINUE
end)]]