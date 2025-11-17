mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, 
function(projectile, weapon)
    if weapon.blueprint.name == "CO_PLASMA_PROMETHEUS" then
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size() --Assumes the weapon does not charge faster than it fires
        projectile.damage.fireChance = shotNumber + 1  --10% for the first shot, 50% for the last shot, scales linearly 
        --print("Fire chance", projectile.damage.fireChance)
    elseif weapon.blueprint.name == "CO_PLASMA_HELIOS" then
        if is_first_shot(weapon, true) then
            userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count) --Unique string identifier for each volley from a particular gun.
        --print("identifier inited", userdata_table(projectile, "mods.co.volley").identifier)
    end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
  if projectile.extend.name == "CO_PLASMA_HELIOS" then
    local ship_volley_table = userdata_table(ship, "mods.co.volley")
    local identifier = userdata_table(projectile, "mods.co.volley").identifier
    print("identifier on hit", identifier)
    ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
    print("hits in volley", ship_volley_table[identifier])
    if ship_volley_table[identifier] == 5 then
      ship:GetSystem(1):AddDamage(1)
    end 
  end
end)