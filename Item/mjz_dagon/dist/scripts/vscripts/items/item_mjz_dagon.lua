
function OnSpellStart(keys)
    if IsServer() then
        _OnSpellStart(keys)
    end
end

function OnEquip( keys )
    if IsServer() then
        local ability = keys.ability
        ability._modifier_tooltip = keys.ModifierTooltip 
        _UpdateTooltip(ability)
    end
end

function OnUnequip( keys )
    if IsServer() then
        local caster = keys.caster
        local ability = keys.ability
        local modifier_tooltip = keys.ModifierTooltip

        caster:RemoveModifierByName(modifier_tooltip)
    end
end

function TargetOnDeath(keys)
    if IsServer() then
        _TargetOnDeath(keys)
    end
end

function _OnSpellStart(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel()
    local kill_grace_duration = ability:GetLevelSpecialValueFor("kill_grace_duration", ability_level)
    local damage_per_kill = ability:GetLevelSpecialValueFor("damage_per_kill", ability_level)
    local splash_radius_scepter = ability:GetLevelSpecialValueFor("splash_radius_scepter", ability_level)
    
    -- find units
    local units = nil
    if caster:HasScepter() then
        local target_type = ability:GetAbilityTargetType()
        local target_team = ability:GetAbilityTargetTeam()
        local target_flags = ability:GetAbilityTargetFlags()
        local radius = splash_radius_scepter
        local position = target:GetAbsOrigin()
        units = FindUnitsInRadius(caster:GetTeam(), position, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
    else
        units = {target}
    end
	

    -- local kill_count = ability:GetCurrentCharges()
    local kill_count = ability._kill_count or 0
    local damage = keys.Damage + damage_per_kill * kill_count

    --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.    
    local particle_effect_intensity = 300 + 100 * 5    --(100 * ability_level)  
    caster:EmitSound("DOTA_Item.Dagon.Activate")
    
    for j,unit in ipairs(units) do
        local victim = unit
        --添加死亡监听器
        if not victim:IsIllusion() then
            if victim:IsRealHero() or victim:IsCreature() then
                local modifier_death = keys.ModifierDeath
                ability:ApplyDataDrivenModifier(caster, victim, modifier_death, {duration=kill_grace_duration})
            end
        end
       

        local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(dagon_particle, 1, victim, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
        ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	
        victim:EmitSound("DOTA_Item.Dagon5.Target")
        
        ApplyDamage({victim = victim, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end


function _TargetOnDeath(keys)	
    local victim = keys.unit
    if victim:IsIllusion() then return end

	local item_dagon = nil
    local ability_item_name = keys.ItemName
    -- find item
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			local current_item_name = current_item:GetName()
			
			if current_item_name == ability_item_name then
				if item_dagon == nil then
					item_dagon = current_item
				elseif current_item:GetCurrentCharges() < item_dagon:GetCurrentCharges() then
					item_dagon = current_item
				end
			end
		end
    end

    if item_dagon ~= nil then
        local can_charge = false

        if victim:IsRealHero() then
            can_charge = true

        elseif victim:IsCreature() then
            local ability_level = item_dagon:GetLevel()
            local creature_enabled = item_dagon:GetLevelSpecialValueFor("creature_enabled", ability_level)
            local creature_health = item_dagon:GetLevelSpecialValueFor("creature_health", ability_level)
        
            if creature_enabled and creature_enabled > 0 then
                local victim_health = victim:GetMaxHealth()
                if victim_health > creature_health then
                    can_charge = true
                else
                    local creature_total = item_dagon._creature_total or 0
                    if (creature_total + victim_health) > creature_health then
                        can_charge = true
                        item_dagon._creature_total = 0
                    else
                        can_charge = false
                        item_dagon._creature_total = creature_total + victim_health
                    end
                end
            end
        end

        if can_charge then
            --[[
            if item_dagon:GetCurrentCharges() == 0 then
                item_dagon:SetCurrentCharges(1)
            else
                item_dagon:SetCurrentCharges(item_dagon:GetCurrentCharges() + 1)
            end
            ]]

            local kill_count = item_dagon._kill_count or 0
            item_dagon._kill_count = kill_count + 1
            
            _UpdateTooltip(item_dagon)
        end
	end
end

function _UpdateTooltip( item_dagon )
    local owner = item_dagon:GetOwner()
    local modifier = item_dagon._modifier_tooltip
    local count = item_dagon._kill_count or 0
	-- local newCount = owner:GetModifierStackCount(modifier, owner) + 1

    if not owner:HasModifier(modifier) then
        item_dagon:ApplyDataDrivenModifier(owner, owner, modifier, nil)
    end
    owner:SetModifierStackCount(modifier, owner, count)    
end
