mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot

mods.co.charonPerkCharge = {}
local charonPerkCharge = mods.co.charonPerkCharge
charonPerkCharge["CO_RAIL_CHARON"] = {maxShots = 2, pState = true}
charonPerkCharge["CO_RAIL_CHARON_CHAOS"] = {maxShots = 2, pState = true}

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local coPerkCharge = nil
    pcall(function() coPerkCharge = charonPerkCharge[weapon.blueprint.name] end)
    if coPerkCharge then
        local perkDataTable = userdata_table(weapon, "mods.coCharon.shots")
        if perkDataTable.pChargeProgress then
            local ship = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
            perkDataTable.pChargeProgress = math.max(perkDataTable.pChargeProgress - 1, 0)
            if perkDataTable.pChargeProgress == 0 then
                perkDataTable.pChargeProgress = nil
                local charon = Hyperspace.Blueprints:GetWeaponBlueprint("CO_RAIL_CHARON_PERK")
                local coCharonPerk = {}
                coCharonPerk.CO_RAIL_CHARON = charon
                coCharonPerk.CO_RAIL_CHARON_CHAOS = charon
                local charonProjReplacement = coCharonPerk[weapon.blueprint.name]
                if charonProjReplacement then
                    projectile:Kill()
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                        local charonProj = spaceManager:CreateLaserBlast(
                        charonProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
                        projectile.target, projectile.destinationSpace, projectile.heading)
                        charonProj.entryAngle = projectile.entryAngle
                    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
                end
            elseif weapon.powered == false then
                perkDataTable.pChargeProgress = nil
            end
        else
            userdata_table(weapon, "mods.coCharon.shots").pChargeProgress = coPerkCharge.maxShots
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    local charonWeaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() charonWeaponData = charonPerkCharge[weapon.blueprint.name] end)
        if charonWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.coCharon.shots")
            if perkDataTable.pChargeProgress then
                perkDataTable.pChargeProgress = nil
            end
        end
    end
end)
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    local charonWeaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() charonWeaponData = charonPerkCharge[weapon.blueprint.name] end)
        if charonWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.coCharon.shots")
            if perkDataTable.pChargeProgress then
                if weapon.powered == false then
                    perkDataTable.pChargeProgress = nil
                end
            end
        end
    end
end)


local adapterPerkState = false
local thyrsusPerkState = false
local kaijuPerkState = false
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if weapon.blueprint.name == "CO_RAIL_ADAPTER" then
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size()
        if shotNumber % 3 == 0 and adapterPerkState == true then
            projectile.damage.iDamage = 1
            --projectile.damage.iSystemDamage = -1
            --projectile.damage.iPersDamage = -1
            adapterPerkState = false
        elseif shotNumber % 3 ~= 0 then
            if is_first_shot(weapon, true) and thyrsusPerkState == false then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
            end
            userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count)
        end
    elseif weapon.blueprint.name == "CO_RAIL_THYRSUS" then
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size()
        if is_first_shot(weapon, true) and thyrsusPerkState == false then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count)
        if shotNumber % 4 == 0 then
            projectile.damage.iSystemDamage = 0
        elseif thyrsusPerkState == true then
            weapon.weaponVisual:SetFireTime(0.00001)
            projectile.damage.iSystemDamage = 0
            projectile.damage.iPersDamage = 0
            if shotNumber == 4 then
                thyrsusPerkState = false
                weapon.weaponVisual:SetFireTime(0.125)
            end
        end
    elseif weapon.blueprint.name == "CO_RAIL_KAIJU" then
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size()
        if is_first_shot(weapon, true) and kaijuPerkState == false then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count)
        if shotNumber % 6 == 0 then
            projectile.damage.iSystemDamage = 0
        elseif kaijuPerkState == true then
            if shotNumber % 3 == 0 then
                projectile.damage.iDamage = 2
                if shotNumber == 12 then
                    kaijuPerkState = false
                end
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
    if projectile.extend.name == "CO_RAIL_ADAPTER" and adapterPerkState == false then
        local ship_volley_table = userdata_table(ship, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        if ship_volley_table[identifier] == 2 then adapterPerkState = true end
    elseif projectile.extend.name == "CO_RAIL_THYRSUS" and thyrsusPerkState == false then
        local ship_volley_table = userdata_table(ship, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        if ship_volley_table[identifier] == 4 then thyrsusPerkState = true end
    elseif projectile.extend.name == "CO_RAIL_KAIJU" and kaijuPerkState == false then
        local ship_volley_table = userdata_table(ship, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        --print("identifier on hit", identifier)
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        print("hits in volley", ship_volley_table[identifier])
        if ship_volley_table[identifier] == 12 then kaijuPerkState = true end
            print('perk is active')
    end
end)


mods.co.statChargers = {}
local statChargers = mods.co.statChargers
statChargers["CO_RAIL_ASTREAUS"] = {{stat = "iDamage"}, {stat = "breachChance"}, {stat = "iShieldPiercing"}}
--statChargers["CO_EMITTER_ASSEMBLER"] = {{stat = "iDamage"},{stat = "breachChance"},{stat = "fireChance"}}
--[[mods.co.cooldownChargers = {}
local cooldownChargers = mods.co.cooldownChargers
cooldownChargers["CO_RAIL_ASTREAUS"] = 2
cooldownChargers["CO_EMITTER_ASSEMBLER"] = 1.5]]


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local statBoosts = statChargers[weapon and weapon.blueprint and weapon.blueprint.name]
    if statBoosts then
        local boost = weapon.queuedProjectiles:size()
        weapon.queuedProjectiles:clear() -- Delete all other projectiles
        for _, statBoost in ipairs(statBoosts) do -- Apply all stat boosts
            if weapon.blueprint.name == "CO_RAIL_ASTREAUS" then
                if statBoost.calc then
                    projectile.damage[statBoost.stat] = statBoost.calc(0.67 * boost, projectile.damage[statBoost.stat])
                else
                    projectile.damage[statBoost.stat] = 0.67 * boost + projectile.damage[statBoost.stat]
                end
            end
        end
    end
end)
--[[script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    local weapons = ship and ship.weaponSystem and ship.weaponSystem.weapons
    if weapons then
        for weapon in vter(weapons) do
            if weapon.chargeLevel ~= 0 and weapon.chargeLevel < weapon.weaponVisual.iChargeLevels then
                local cdBoost = cooldownChargers[weapon and weapon.blueprint and weapon.blueprint.name]
                if cdBoost then
                    local cdLast = userdata_table(weapon, "mods.co.weaponStuff").cdLast
                    if cdLast and weapon.cooldown.first > cdLast then
                        local chargeUpdate = weapon.cooldown.first - cdLast
                        local chargeNew = weapon.cooldown.first - chargeUpdate + cdBoost^weapon.chargeLevel*chargeUpdate
                        if chargeNew >= weapon.cooldown.second then
                            weapon.chargeLevel = weapon.chargeLevel + 1
                            if weapon.chargeLevel == weapon.weaponVisual.iChargeLevels then
                                weapon.cooldown.first = weapon.cooldown.second
                                weapon.autoFiring = true
                            else
                                weapon.cooldown.first = 0
                            end
                        else
                            weapon.cooldown.first = chargeNew
                        end
                    end
                    userdata_table(weapon, "mods.co.weaponStuff").cdLast = weapon.cooldown.first
                end
            end
        end
    end
end)
script.on_internal_event(Defines.InternalEvents.WEAPON_RENDERBOX, function(weapon, cooldown, maxCooldown, chargeString, damageString, shotLimitString)
    local chargerBoost = cooldownChargers[weapon and weapon.blueprint and weapon.blueprint.name]
    if chargerBoost then
        local first, second = chargeString:match("([%d%.]+)%s*/%s*([%d%.]+)")
        local boostLevel = math.min(weapon.chargeLevel, weapon.weaponVisual.iChargeLevels - 1)
        first = first / chargerBoost ^ boostLevel
        second = second / chargerBoost ^ boostLevel
        chargeString = string.format("%.1f / %.1f", first, second)
    end
    return Defines.Chain.CONTINUE, chargeString, damageString, shotLimitString
end)]]

mods.co.weapStatChargers = {}
local weapStatChargers = mods.co.weapStatChargers
weapStatChargers["CO_RAIL_ASTREAUS"] = {{stat = "cooldown"}, {stat = "speed"}}

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    local weapons = ship and ship.weaponSystem and ship.weaponSystem.weapons
    if weapons then
        for weapon in vter(weapons) do
            if weapon.chargeLevel ~= 0 and weapon.chargeLevel < weapon.weaponVisual.iChargeLevels then

                local wpStatBoosts = weapStatChargers[weapon and weapon.blueprint and weapon.blueprint.name]
                if wpStatBoosts then
                    local statLast = userdata_table(weapon, "mods.co.weaponStuff").statLast
                    for _, wpStatBoost in ipairs(wpStatBoosts) do
                        if statLast and weapon.wpStatBoost.stat.first > statLast then
                            local chargeUpdate = weapon.wpStatBoost.stat.first - statLast
                            local chargeNew = weapon.wpStatBoost.stat.first - chargeUpdate + wpStatBoost^weapon.chargeLevel*chargeUpdate
                            if chargeNew >= weapon.wpStatBoost.stat.second then
                                weapon.chargeLevel = weapon.chargeLevel + 1
                                if weapon.chargeLevel == weapon.weaponVisual.iChargeLevels then
                                    weapon.wpStatBoost.stat.first = weapon.wpStatBoost.stat.second
                                    --weapon.autoFiring = true
                                else
                                    weapon.wpStatBoost.stat.first = 0
                                end
                            else
                                weapon.wpStatBoost.stat.first = chargeNew
                            end
                        end
                        userdata_table(weapon, "mods.co.weaponStuff").statLast = weapon.wpStatBoost.stat.first
                    end
                end

            end
        end
    end
end)
script.on_internal_event(Defines.InternalEvents.WEAPON_RENDERBOX, function(weapon, cooldown, maxCooldown, chargeString, damageString, shotLimitString)
    local chargerBoost = weapStatChargers[weapon and weapon.blueprint and weapon.blueprint.name]
    if chargerBoost then
        local first, second = chargeString:match("([%d%.]+)%s*/%s*([%d%.]+)")
        local boostLevel = math.min(weapon.chargeLevel, weapon.weaponVisual.iChargeLevels - 1)
        first = first / chargerBoost ^ boostLevel
        second = second / chargerBoost ^ boostLevel
        chargeString = string.format("%.1f / %.1f", first, second)
    end
    return Defines.Chain.CONTINUE, chargeString, damageString, shotLimitString
end)


--[[
script.on_internal_event(Defines.InternalEvents.PROJECTILE_INITIALIZE, function(projectile, weaponBlueprint)
    if weaponBlueprint.name == "CO_RAIL_ASTREAUS" then
        local ship = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
        local otherShip = Hyperspace.Global.GetInstance():GetShipManager((projectile.ownerId + 1)%2)
        local targetRoom = nil

        if not otherShip:GetSystem(0):CompletelyDestroyed() then
            targetRoom = otherShip:GetSystemRoom(0)
        elseif not otherShip:GetSystem(3):CompletelyDestroyed() then
            targetRoom = otherShip:GetSystemRoom(3)
        elseif not otherShip:GetSystem(4):CompletelyDestroyed() then
            targetRoom = otherShip:GetSystemRoom(4)
        elseif not otherShip:GetSystem(10):CompletelyDestroyed() then
            targetRoom = otherShip:GetSystemRoom(10)
        elseif not otherShip:GetSystem(1):CompletelyDestroyed() then
            targetRoom = otherShip:GetSystemRoom(1)
        end
        
        if targetRoom then
            projectile.target = otherShip:GetRoomCenter(targetRoom)
            userdata_table(projectile, "mods.co_rail_astreaus.comhead").notComputed = true
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.PROJECTILE_PRE, function(projectile)
    local weaponName = projectile.extend.name
    if weaponName == "CO_RAIL_ASTREAUS" then
        local chTable = userdata_table(projectile, "mods.co_rail_astreaus.comhead")
        if projectile.currentSpace == projectile.destinationSpace and chTable.notComputed then 
            chTable.notComputed = nil
            projectile:ComputeHeading()
        end
    end
end)]]