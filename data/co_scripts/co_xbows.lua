local vter = mods.multiverse.vter


script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(shipManager, projectile, location, damage, shipFriendlyFire)
    local shipBoltCount = 0
    for crew in vter(shipManager.vCrewList) do
        if crew.blueprint.name == "co_xbow_artemis_bolt" and crew.iShipId ~= shipManager.iShipId then
            shipBoltCount = shipBoltCount + 1
        end
    end
    if shipBoltCount >= 7 then
        --print("incoming damage SHOULD BE increased by", shipBoltCount // 7)
		if damage.iDamage > 0 or projectile.extend.name == "CO_XBOW_ARTEMIS" or projectile.extend.name == "CO_XBOW_ARTEMIS_ARTILLERY"  or projectile.extend.name == "CO_SLAYER_DRONE_STINGER_1_WEAPON" then
			damage.iDamage = damage.iDamage + shipBoltCount // 7
			damage.iPersDamage = damage.iPersDamage - shipBoltCount // 7
		end
	else
        if projectile.extend.name == "CO_XBOW_ARTEMIS" or projectile.extend.name == "CO_SLAYER_DRONE_STINGER_1_WEAPON" then
            --print(6 - shipBoltCount, "bolts are left til the perk")
        end
    end
end)