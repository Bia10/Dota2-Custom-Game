


modifier_mjz_lina_laguna_blade_bonus = class({})
function modifier_mjz_lina_laguna_blade_bonus:IsBuff()
    return true
end
function modifier_mjz_lina_laguna_blade_bonus:IsPermanent()
    return true
end


modifier_mjz_lina_laguna_blade_creature = class({})
function modifier_mjz_lina_laguna_blade_creature:IsHidden()
    return true
end
function modifier_mjz_lina_laguna_blade_creature:IsPermanent()
    return true
end


modifier_mjz_lina_laguna_blade_death = class({})
function modifier_mjz_lina_laguna_blade_death:IsDebuff()
    return true
end
function modifier_mjz_lina_laguna_blade_death:IsPurgable()	-- 能否被驱散
	return false
end

if IsServer() then
    function modifier_mjz_lina_laguna_blade_death:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
    end
    function modifier_mjz_lina_laguna_blade_death:OnDeath(event)
        if event.unit == self:GetParent() and self:GetAbility() then
            local unit = self:GetParent()
            local ability = self:GetAbility()
    
            self:OnTargetDeath(unit)
        end
    end	
    
    function modifier_mjz_lina_laguna_blade_death:OnTargetDeath( target )
        if target:IsIllusion() then return end

        local owner = self:GetCaster()
        local ability = self:GetAbility()
        local victim = target
        local can_charge = false

        if victim:IsRealHero() then
            can_charge = true

        elseif victim:IsCreature() then
            local creature_enabled = ability:GetSpecialValueFor("creature_enabled")
            local creature_health = ability:GetSpecialValueFor("creature_health")

            if creature_enabled and creature_enabled > 0 then
                local victim_health = victim:GetMaxHealth()
                if victim_health > creature_health then
                    can_charge = true
                else
                    local modifier_creature = 'modifier_mjz_lina_laguna_blade_creature'
                    local creature_total = owner:GetModifierStackCount(modifier_creature, nil)
                    if (creature_total + victim_health) > creature_health then
                        can_charge = true
                        creature_total = 0
                    else
                        can_charge = false
                        creature_total = creature_total + victim_health
                    end
                    SetModifierStackCount(owner, ability, modifier_creature, creature_total)            
                end
            end
        end

        if can_charge then
            local modifier_name = 'modifier_mjz_lina_laguna_blade_bonus'
            local kill_count = owner:GetModifierStackCount(modifier_name, nil)
            kill_count = kill_count + 1
            
            SetModifierStackCount(owner, ability, modifier_name, kill_count)            
        end
    end

end


function SetModifierStackCount(owner, ability, modifier_name, count)
    if not owner:HasModifier(modifier_name) then
        owner:AddNewModifier(owner, ability, modifier_name, {})            
    end
    owner:SetModifierStackCount(modifier_name, owner, count)    
end