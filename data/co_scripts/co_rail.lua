mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter


mods.co.charonPerkCharge = {}
local charonPerkCharge = mods.co.charonPerkCharge
charonPerkCharge["CO_RAIL_ADAPTER"] = {maxShots = 2, pState = true}
charonPerkCharge["CO_RAIL_THYRSUS"] = {maxShots = 1, pState = true}
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
------------------------------------------------------------------------------------------------------
                local charon = Hyperspace.Blueprints:GetWeaponBlueprint("CO_RAIL_CHARON_PERK")
                local coCharonPerk = {}
                coCharonPerk.CO_RAIL_CHARON = charon
                coCharonPerk.CO_RAIL_CHARON_CHAOS = charon
                local charonProjReplacement = coCharonPerk[weapon.blueprint.name]
------------------------------------------------------------------------------------------------------
                local adapter = Hyperspace.Blueprints:GetWeaponBlueprint("CO_RAIL_ADAPTER_PERK")
                local coAdapterPerk = {}
                coAdapterPerk.CO_RAIL_ADAPTER = adapter
                local adapterProjReplacement = coAdapterPerk[weapon.blueprint.name]
------------------------------------------------------------------------------------------------------
                local thyrsus = Hyperspace.Blueprints:GetWeaponBlueprint("CO_RAIL_ADAPTER_PERK")
                local coThyrsusPerk = {}
                coThyrsusPerk.CO_RAIL_THYRSUS = thyrsus
                local thyrsusProjReplacement = coThyrsusPerk[weapon.blueprint.name]
------------------------------------------------------------------------------------------------------
                if charonProjReplacement then
                    projectile:Kill()
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                        local charonProj = spaceManager:CreateLaserBlast(
                        charonProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
                        projectile.target, projectile.destinationSpace, projectile.heading)
                        charonProj.entryAngle = projectile.entryAngle
                    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
                elseif adapterProjReplacement then
                    projectile:Kill()
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                        local adapterProj = spaceManager:CreateLaserBlast(
                        adapterProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
                        projectile.target, projectile.destinationSpace, projectile.heading)
                        adapterProj.entryAngle = projectile.entryAngle
                    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
                elseif thyrsusProjReplacement then
                    projectile:Kill()
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                        local adapterProj = spaceManager:CreateLaserBlast(
                        thyrsusProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
                        projectile.target, projectile.destinationSpace, projectile.heading)
                        adapterProj.entryAngle = projectile.entryAngle
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