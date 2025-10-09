mods.co = {}

-- this is arc's code
-- play his addons

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter


-- most of this code is arc's code
-- play his addons you must 👁


local co_aurora_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_AURORA_BEAM")
local co_aurora_beam_enemy = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_AURORA_BEAM_ENEMY")
--local co_athena_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_ATHENA_BEAM")
local co_trigger_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_TRIGGER_BEAM")
local co_destructor_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_DESTRUCTOR_BEAM")

local coBurstsToBeams = {}
coBurstsToBeams.CO_PLASMA_AURORA = co_aurora_beam
coBurstsToBeams.CO_PLASMA_AURORA_ENEMY = co_aurora_beam_enemy
--coBurstsToBeams.CO_PLASMA_ATHENA = co_athena_beam
coBurstsToBeams.CO_PLASMA_TRIGGER = co_trigger_beam
coBurstsToBeams.CO_PLASMA_DESTRUCTOR = co_destructor_beam


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local beamReplacement = coBurstsToBeams[weapon.blueprint.name]
    if beamReplacement then
        local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
        local projDesSp = projectile.destinationSpace
        local coBeam = spaceManager:CreateBeam(
            beamReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
            projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1),
            projectile.destinationSpace, 1, projectile.heading)
        coBeam.sub_start.x = 500*math.cos(projectile.entryAngle)
        coBeam.sub_start.y = 500*math.sin(projectile.entryAngle)
        coBeam.entryAngle = projectile.entryAngle
        local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
        projectile:Kill()
    end
end)


mods.co.coTriggerLikeShoot = {}
local coTriggerLikeShoot = mods.co.coTriggerLikeShoot
coTriggerLikeShoot["CO_PLASMA_TRIGGER"] = {maxShots = 49, pState = true}
coTriggerLikeShoot["CO_PLASMA_DESTRUCTOR"] = {maxShots = 49, pState = true}


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local coPerkCharge = nil
    pcall(function() coPerkCharge = coTriggerLikeShoot[weapon.blueprint.name] end)
    if coPerkCharge then
        local perkDataTable = userdata_table(weapon, "mods.coTrigger.shots")
        if perkDataTable.pChargeProgress then
            local ship = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
            local projDesSp = projectile.destinationSpace
            perkDataTable.pChargeProgress = math.max(perkDataTable.pChargeProgress - 1, 0)
            if perkDataTable.pChargeProgress == 44 then
------------------------------------------------------------------------------------------------------
                local trigger = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_TRIGGER_BOOM")
                local coTriggerPerk = {}
                coTriggerPerk.CO_PLASMA_TRIGGER = trigger
                local triggerProjReplacement = coTriggerPerk[weapon.blueprint.name]
------------------------------------------------------------------------------------------------------
                local destructor = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_DESTRUCTOR_BOOM")
                local coDestructorPerk = {}
                coDestructorPerk.CO_PLASMA_DESTRUCTOR = destructor
                local destructorProjReplacement = coDestructorPerk[weapon.blueprint.name]
------------------------------------------------------------------------------------------------------
                if triggerProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_trigger_long', -1, false)
                elseif destructorProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_destructor_long', -1, false)
                end
            elseif perkDataTable.pChargeProgress == 0 then
                perkDataTable.pChargeProgress = nil
------------------------------------------------------------------------------------------------------
                local trigger = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_TRIGGER_BOOM")
                local coTriggerPerk = {}
                coTriggerPerk.CO_PLASMA_TRIGGER = trigger
                local triggerProjReplacement = coTriggerPerk[weapon.blueprint.name]
------------------------------------------------------------------------------------------------------
                local destructor = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_DESTRUCTOR_BOOM")
                local coDestructorPerk = {}
                coDestructorPerk.CO_PLASMA_DESTRUCTOR = destructor
                local destructorProjReplacement = coDestructorPerk[weapon.blueprint.name]
------------------------------------------------------------------------------------------------------
                if triggerProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_trigger_shot', -1, false)
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                    local coBeam = spaceManager:CreateBeam(
                        triggerProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
                        projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1),
                        projDesSp, 1, projectile.heading)
                    coBeam.sub_start.x = 500*math.cos(projectile.entryAngle)
                    coBeam.sub_start.y = 500*math.sin(projectile.entryAngle)
                    coBeam.entryAngle = projectile.entryAngle
                    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
                    projectile:Kill()
                elseif destructorProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_destructor_shot', -1, false)
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                    local coBeam = spaceManager:CreateBeam(
                        destructorProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
                        projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1),
                        projDesSp, 1, projectile.heading)
                    coBeam.sub_start.x = 500*math.cos(projectile.entryAngle)
                    coBeam.sub_start.y = 500*math.sin(projectile.entryAngle)
                    coBeam.entryAngle = projectile.entryAngle
                    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
                    projectile:Kill()
                end
            elseif weapon.powered == false then
                perkDataTable.pChargeProgress = nil
            end
        else
            userdata_table(weapon, "mods.coTrigger.shots").pChargeProgress = coPerkCharge.maxShots
        end
    end
end)


script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    local triggerWeaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() triggerWeaponData = coTriggerLikeShoot[weapon.blueprint.name] end)
        if triggerWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.coTrigger.shots")
            if perkDataTable.pChargeProgress then
                perkDataTable.pChargeProgress = nil
            end
        end
    end
end)


script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    local triggerWeaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() triggerWeaponData = coTriggerLikeShoot[weapon.blueprint.name] end)
        if triggerWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.coTrigger.shots")
            if perkDataTable.pChargeProgress then
                if weapon.powered == false then
                    perkDataTable.pChargeProgress = nil
                end
            end
        end
    end
end)
