mods.co = {}


local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    if shipManager:HasAugmentation("CO_RAVAGER_ENERSHIELD")>0 then

        local shieldPower = shipManager.shieldSystem.shields.power
        local coShdPw = shieldPower.second
        --print("You could have", coShdPw, "bubbles rn")
        if shieldPower.first > 0 then
            for coEshd = 1, coShdPw do
                shieldPower.first = math.max(0, shieldPower.first - 1)
                shipManager.shieldSystem:AddSuperShield(shipManager.shieldSystem.superUpLoc)
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE, function(shipManager, augName, augValue)
    if augName == "SHIELD_RECHARGE" and shipManager:HasAugmentation("CO_RAVAGER_ENERSHIELD")>0 then
        local shieldPower = shipManager:GetShieldPower()
        augValue = augValue + (shieldPower.second*0.25)
        --print(shieldPower.second)
    end
    return Defines.Chain.CONTINUE, augValue
end, -100)