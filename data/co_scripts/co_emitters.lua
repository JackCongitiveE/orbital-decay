mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot
local get_room_at_location = mods.multiverse.get_room_at_location
local get_adjacent_rooms = mods.multiverse.get_adjacent_rooms


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if weapon.blueprint.name == "CO_EMITTER_PROMETHEUS" then
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size()
        projectile.damage.fireChance = shotNumber + 1
    elseif weapon.blueprint.name == "CO_EMITTER_HELIOS" then
        if is_first_shot(weapon, true) then
            userdata_table(weapon, "mods.co.volleyHel").count = (userdata_table(weapon, "mods.co.volleyHel").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volleyHel").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volleyHel").count)
    end
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile)
    if projectile.extend.name == "CO_EMITTER_HELIOS" then
        local ship_volleyHel_table = userdata_table(ship, "mods.co.volleyHel")
        local identifier = userdata_table(projectile, "mods.co.volleyHel").identifier
        --print("identifier on hit", identifier)
        ship_volleyHel_table[identifier] = (ship_volleyHel_table[identifier] or 0) + 1
        --print("hits in volley", ship_volleyHel_table[identifier])
        if ship_volleyHel_table[identifier] == 5 then
            ship:DamageHull(1, true)
            ship:GetSystem(1):AddDamage(1)
			ship_volleyHel_table[identifier] = 0
        end
    end
end)


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if projectile and projectile.extend.name == "CO_EMITTER_QUASAR" then
        projectile.table.CO_EMMITER_WEAPON = weapon
    end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location)
    if projectile and projectile.extend.name == "CO_EMITTER_QUASAR" then
        local weapon = projectile.table.CO_EMMITER_WEAPON
        if weapon.cooldown.second > 0 then
			for roomId, roomPos in pairs(get_adjacent_rooms(shipManager.iShipId, get_room_at_location(shipManager, location, false), false)) do
				local chargeFraction = weapon.cooldown.second * 0.05
				weapon.cooldown.first = math.min(weapon.cooldown.first + chargeFraction, weapon.cooldown.second)
			end
        end
    end
end)