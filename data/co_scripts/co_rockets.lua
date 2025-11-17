--[[mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot

local luciferPerkState = false
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if weapon.blueprint.name == "CO_ROCKET_LUCIFER" then
        if is_first_shot(weapon, true) then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count) --Unique string identifier for each volley from a particular gun.
        --print("identifier inited", userdata_table(projectile, "mods.co.volley").identifier)
        if luciferPerkState == true then
            local lucifer = Hyperspace.Blueprints:GetWeaponBlueprint("CO_ROCKET_LUCIFER_PERK")
            local coLuciferPerk = {}
            coLuciferPerk.CO_ROCKET_LUCIFER = lucifer
            local luciferPerkActive = coLuciferPerk[weapon.blueprint.name]
            if luciferPerkActive then
                local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                    local luciferProj = spaceManager:CreateLaserBlast(
                    luciferPerkActive, projectile.position, projectile.currentSpace, projectile.ownerId,
                    projectile.target, projectile.destinationSpace, projectile.heading)
                    luciferProj.entryAngle = projectile.entryAngle
                luciferPerkState = false
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
    if projectile.extend.name == "CO_ROCKET_LUCIFER" then
        local ship_volley_table = userdata_table(ship, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        print("identifier on hit", identifier)
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        print("hits in volley", ship_volley_table[identifier])
        if ship_volley_table[identifier] == 4 then
            --[[luciferPerkState = true
            ship_volley_table[identifier] = 0
            local lucifer = Hyperspace.Blueprints:GetWeaponBlueprint("CO_ROCKET_LUCIFER_PERK")
            local coLuciferPerk = {}
            coLuciferPerk.CO_ROCKET_LUCIFER = lucifer
            local luciferPerkActive = coLuciferPerk[weapon.blueprint.name]
            if luciferPerkActive then
                local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                    local luciferProj = spaceManager:CreateLaserBlast(
                    luciferPerkActive, projectile.position, projectile.currentSpace, projectile.ownerId,
                    projectile.target, projectile.destinationSpace, projectile.heading)
                    luciferProj.entryAngle = projectile.entryAngle
                luciferPerkState = false
            end
        end
    end
end)]]