mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot


local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if weapon.blueprint.name == "CO_ROCKET_LUCIFER" or weapon.blueprint.name == "CO_ROCKET_LUCIFER_ARTI" then
        if is_first_shot(weapon, true) then
            userdata_table(weapon, "mods.co.volleyLucifer").count = (userdata_table(weapon, "mods.co.volleyLucifer").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volleyLucifer").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volleyLucifer").count)
    end
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location)
    if projectile.extend.name == "CO_ROCKET_LUCIFER" or projectile.extend.name == "CO_ROCKET_LUCIFER_ARTI" then
        local ship_volleyLucifer_table = userdata_table(ship, "mods.co.volleyLucifer")
        local identifier = userdata_table(projectile, "mods.co.volleyLucifer").identifier
        ship_volleyLucifer_table[identifier] = (ship_volleyLucifer_table[identifier] or 0) + 1
        if ship_volleyLucifer_table[identifier] == 4 then
            local roomId = get_room_at_location(ship, location, true)
            ship:DamageHull(1, true)
            ship:GetSystemInRoom(roomId):AddDamage(1)
            ship_volleyLucifer_table[identifier] = 0
        end
    end
end)