mods.co.acariPerk = {}

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
    if Projectile then
        local roomDamage = mods.co.acariPerk[Projectile.extend.name]
        if roomDamage then
            local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
            local blueprint = Hyperspace.Blueprints:GetWeaponBlueprint(roomDamage)
            local impactOwner = Projectile.ownerId
            local targetSpace = ShipManager.iShipId
            local weaponName = Projectile.extend.name
            Projectile.extend.name = ""
            for roomNumber = 0, Hyperspace.ShipGraph.GetShipInfo(targetSpace):RoomCount() - 1 do
                local cSRoom = ShipManager:GetSystemInRoom(roomNumber)
                if not cSRoom then
                    local target = ShipManager:GetRoomCenter(roomNumber)
                    local blast = SpaceManager:CreateLaserBlast(blueprint, target, targetSpace, impactOwner, target, targetSpace, 0)
                end
            end
            Projectile.extend.name = weaponName
        end
    end
    return Defines.Chain.CONTINUE
end)

local acariPerk = mods.co.acariPerk
acariPerk.CO_RAIL_ACARI = "CO_RAIL_ACARI_STATBOOST"