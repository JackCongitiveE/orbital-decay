mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot


local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end


local function get_random_point_in_radius(center, radius)
    local r = radius * math.sqrt(math.random())
    local theta = math.random() * 2 * math.pi
    return Hyperspace.Pointf(center.x + r * math.cos(theta), center.y + r * math.sin(theta))
end


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
        elseif projectile.missed then
            perkDataTable.pChargeProgress = coPerkCharge.maxShots
            print("projectile missed")
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


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if weapon.blueprint.name == "CO_RAIL_ADAPTER" then
        if is_first_shot(weapon, true) then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count)
    end
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location)
    if projectile.extend.name == "CO_RAIL_ADAPTER" then
        local ship_volley_table = userdata_table(ship, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        --print("hits in volley", ship_volley_table[identifier])
        if ship_volley_table[identifier] == 3 then
            local roomId = get_room_at_location(ship, location, true)
            --print("you hit", roomId)
            ship:DamageHull(1, true)
            ship:GetSystemInRoom(roomId):AddDamage(1)
            ship_volley_table[identifier] = 0
        end
    end
end)


--[[local thyrsusPerkState = mods.co.thyrsusPerkState
thyrsusPerkState["CO_RAIL_CHARON"] = {maxShots = 2, pState = true}]]

local thyrsusPerkState = 2

script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    thyrsusPerkState = 2
end)

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if weapon.blueprint.name == "CO_RAIL_THYRSUS" then
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size()
        if is_first_shot(weapon, true) and thyrsusPerkState < 1 then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count)
        if thyrsusPerkState > 0 then
            local stimShots = weapon.queuedProjectiles:size()
            weapon.queuedProjectiles:clear()
            for shots = 1, stimShots do
                local spaceManager = Hyperspace.App.world.space
                local thyrsusShot = spaceManager:CreateLaserBlast(
                weapon.blueprint,
                projectile.position,
                projectile.currentSpace,
                projectile.ownerId,
                projectile.target,
                projectile.destinationSpace,
                projectile.heading
                )
                projectile.damage.iSystemDamage = 0
                projectile.damage.iPersDamage = 0
                projectile.damage.iShieldPiercing = projectile.damage.iShieldPiercing + 1
            end
            --[[weapon.weaponVisual:SetFireTime(0.00001)]]
            --if shotNumber == 4 then
                thyrsusPerkState = thyrsusPerkState - 1
                --weapon.weaponVisual:SetFireTime(0.125)
                if thyrsusPerkState == 0 then
                    thyrsusPerkState = thyrsusPerkState - 1
                    print('perk state:', thyrsusPerkState)
                end
            --end
        elseif shotNumber % 4 == 0 then
            projectile.damage.iSystemDamage = 0
        end
    end
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
    if projectile.extend.name == "CO_RAIL_THYRSUS" and thyrsusPerkState < 1 then
        local ship_volley_table = userdata_table(ship, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        print("hits in volley", ship_volley_table[identifier])
        if ship_volley_table[identifier] == 4 then
            thyrsusPerkState = thyrsusPerkState + 1
            print('perk state:', thyrsusPerkState)
        end
        if thyrsusPerkState > 0 then
            print('perk charged')
        end
    end
end)


local kaijuPerkState = nil

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if weapon.blueprint.name == "CO_RAIL_KAIJU" then
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size()
        if is_first_shot(weapon, true) and kaijuPerkState == nil then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count)
        if kaijuPerkState == true then
            if shotNumber % 3 == 0 then
                projectile.damage.iDamage = 2
                if shotNumber == 12 then
                    kaijuPerkState = nil
                end
            end
        elseif shotNumber % 6 == 0 then
            projectile.damage.iSystemDamage = 0
        end
    end
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
    if projectile.extend.name == "CO_RAIL_KAIJU" and kaijuPerkState == nil then
        local ship_volley_table = userdata_table(ship, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        --print("identifier on hit", identifier)
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        --print("hits in volley", ship_volley_table[identifier])
        if ship_volley_table[identifier] == 12 then
            kaijuPerkState = true
            --print('perk is active')
        end
    end
end)


local function weapon_center(weapon, offsetX, offsetY)
    local emitPointX = 0
    local emitPointY = 0
    local rotate = false
    local mirror = false
    local vertMod = 1
    if weapon then
        rotate = weapon.mount.rotate
        mirror = weapon.mount.mirror
        if mirror then vertMod = -1 end
        
        -- Calculate weapon coodinates
        local weaponAnim = weapon.weaponVisual
        local ship = Hyperspace.ships(weapon.iShipId).ship
        local shipGraph = Hyperspace.ShipGraph.GetShipInfo(weapon.iShipId)
        local slideOffset = weaponAnim:GetSlide()
        emitPointX = emitPointX + ship.shipImage.x + shipGraph.shipBox.x + weaponAnim.renderPoint.x + slideOffset.x
        emitPointY = emitPointY + ship.shipImage.y + shipGraph.shipBox.y + weaponAnim.renderPoint.y + slideOffset.y

        -- Add emitter and mount point offset
        if rotate then
            emitPointX = emitPointX - offsetY + weaponAnim.mountPoint.y
            emitPointY = emitPointY + (offsetX - weaponAnim.mountPoint.x)*vertMod
        else
            emitPointX = emitPointX + (offsetX - weaponAnim.mountPoint.x)*vertMod
            emitPointY = emitPointY + offsetY - weaponAnim.mountPoint.y
        end
        return Hyperspace.Pointf(emitPointX, emitPointY)
    end
    return 0
end


mods.co.statChargers = {}
local statChargers = mods.co.statChargers
statChargers["CO_RAIL_ASTREAUS"] = {{damageType = "iDamage"}, {damageType = "breachChance"}, {damageType = "iShieldPiercing"}}
statChargers["CO_EMITTER_ASSEMBLER"] = {{damageType = "iDamage"}, {damageType = "fireChance"}}

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local statBoosts = statChargers[weapon and weapon.blueprint and weapon.blueprint.name]
    if statBoosts then
        local boost = weapon.queuedProjectiles:size()
        weapon.queuedProjectiles:clear() -- Delete all other projectiles
        for _, statBoost in ipairs(statBoosts) do -- Apply all damageType boosts
            if weapon.blueprint.name == "CO_RAIL_ASTREAUS" then
                projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod + 10 * boost
                if statBoost.calc then
                    projectile.damage[statBoost.damageType] = statBoost.calc(0.67 * boost, projectile.damage[statBoost.damageType])
                else
                    projectile.damage[statBoost.damageType] = 0.67 * boost + projectile.damage[statBoost.damageType]
                end
            end
            if weapon.blueprint.name == "CO_EMITTER_ASSEMBLER" then
                if statBoost.calc then
                    projectile.damage[statBoost.damageType] = statBoost.calc(1 + boost, projectile.damage[statBoost.damageType])
                else
                    projectile.damage[statBoost.damageType] = 1 + boost + projectile.damage[statBoost.damageType]
                end
                projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod + 15 * boost
                projectile.speed_magnitude = projectile.speed_magnitude + projectile.speed_magnitude * boost * 0.5
                projectile.target = get_random_point_in_radius(projectile.target, 50 - 10 * boost)
            end
        end
    end
end)


mods.co.cooldownChargers = {}
local cooldownChargers = mods.co.cooldownChargers
cooldownChargers["CO_RAIL_ASTREAUS"] = 2
cooldownChargers["CO_EMITTER_ASSEMBLER"] = 1.5

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
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
                                --print(weapon.chargeLevel, "weapon is fully charged")
                                weapon.cooldown.first = weapon.cooldown.second
                                if weapon.blueprint.name == "CO_RAIL_ASTREAUS" then
                                    Hyperspace.Sounds:PlaySoundMix("co_charon_shot", -1, false)
                                    ship:DamageHull(1, true)
                                    ship:GetSystem(3):AddDamage(1)
                                    if Hyperspace.ships.enemy then
                                        local spaceManager = Hyperspace.App.world.space
                                        local otherShip = Hyperspace.ships(1 - ship.iShipId)
                                        local target = otherShip:GetRandomRoomCenter()
                                        local astreausShot = spaceManager:CreateLaserBlast(
                                            Hyperspace.Blueprints:GetWeaponBlueprint("CO_RAIL_ASTREAUS"),
                                            weapon_center(weapon, 42, -32), -- -14, 28
                                            ship.iShipId,
                                            ship.iShipId,
                                            target,
                                            otherShip.iShipId,
                                            0
                                        )
                                        astreausShot.damage.iDamage = 4
                                        astreausShot.damage.breachChance = 4
                                        astreausShot.damage.iShieldPiercing = 4
                                    end
                                    weapon.chargeLevel = 0
                                    weapon.cooldown.first = 0
                                end
                                if weapon.blueprint.name == "CO_EMITTER_ASSEMBLER" then
                                    Hyperspace.Sounds:PlaySoundMix("co_trigger_shot", -1, false)
                                    weapon.chargeLevel = 0
                                    weapon.cooldown.first = 0
                                    local roomWeapons = ship:GetSystemRoom(3)
                                    ship:StartFire(roomWeapons)
                                end
                            else
                                --print(weapon.chargeLevel, "charges are charged")
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
end)

