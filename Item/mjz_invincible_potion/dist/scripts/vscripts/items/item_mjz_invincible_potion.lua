  
function Invulnerability(keys)
    local caster = keys.caster
	local Unit = EntIndexToHScript( keys.caster_entindex )
    local ability = keys.ability
    local Item = keys.ability
    local modifier = "modifier_invulnerable"
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

    if not caster:HasModifier(modifier) then 
        caster:AddNewModifier(caster, nil, modifier, {duration = duration})

        if Item:GetCurrentCharges() > 1 then
            Item:SetCurrentCharges(Item:GetCurrentCharges()-1)
        else
            Unit:RemoveItem(Item)
        end
    end
end
