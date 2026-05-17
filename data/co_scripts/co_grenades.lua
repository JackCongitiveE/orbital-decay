mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot
local get_room_at_location = mods.multiverse.get_room_at_location
local get_adjacent_rooms = mods.multiverse.get_adjacent_rooms



script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    local shldBuff = shipManager:GetSystemPower(0) // 2
    local engBuff = shipManager:GetSystemPower(1) // 2
    local artyBuff = shipManager:GetSystemPower(11)

    for weapon in vter(shipManager:GetWeaponList()) do
        if weapon.blueprint.name == "CO_GRENADE_YONGWANG" then
            if weapon.table.CO_YONGWANG_WASPOWERED ~= weapon.powered then
                if weapon.powered then
                    print("weapon was powered")
                    weapon.table.CO_YONGWANG_WASPOWERED = weapon.powered
                end
                if not weapon.powered then
                    print("weapon was depowered")
                    if shipManager:GetSystem(0) then
                        shipManager:GetSystem(0):AddLock(0)
                    end
                    if shipManager:GetSystem(1) then
                        shipManager:GetSystem(1):AddLock(0)
                    end
                    weapon.table.CO_YONGWANG_WASPOWERED = weapon.powered
                end
            end
            if weapon.powered then
                --print("weapon is powered")
                weapon.numShots = weapon.blueprint.shots + math.max(engBuff, 0) + math.max(shldBuff, 0) - math.max(artyBuff, 0)
                weapon.baseCooldown = weapon.baseCooldown + math.max(engBuff, 0) + math.max(shldBuff, 0) * 1.5 + math.max(artyBuff * 1.5, 0)
                    if shipManager:GetSystem(0) then
                        shipManager:GetSystem(0):LockSystem(-1)
                    end
                    if shipManager:GetSystem(1) then
                        shipManager:GetSystem(1):LockSystem(-1)
                    end
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    for weapon in vter(shipManager:GetWeaponList()) do
        if weapon.blueprint.name == "CO_GRENADE_YONGWANG" then
            if weapon.powered then
                print("weapon is powered")
                if shipManager:GetSystem(0) then
                    shipManager:GetSystem(0):LockSystem(-1)
                end
                if shipManager:GetSystem(1) then
                    shipManager:GetSystem(1):LockSystem(-1)
                end
            end
            if not weapon.powered then
                print("weapon is depowered")
                if shipManager:GetSystem(0) then
                    shipManager:GetSystem(0):AddLock(0)
                end
                if shipManager:GetSystem(1) then
                    shipManager:GetSystem(1):AddLock(0)
                end
            end
        end
    end
end)