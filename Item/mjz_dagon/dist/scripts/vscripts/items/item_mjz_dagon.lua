

function OnSpellStart(keys)
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
	

    local kill_count = ability:GetCurrentCharges()
    local damage = keys.Damage + damage_per_kill * kill_count

    --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.    
    local particle_effect_intensity = 300 + 100 * 5    --(100 * ability_level)  
    caster:EmitSound("DOTA_Item.Dagon.Activate")
    
    for j,unit in ipairs(units) do
        local victim = unit --target
        --添加死亡监听器
        if victim:IsHero() then
            local modifier_death = keys.ModifierDeath
            ability:ApplyDataDrivenModifier(caster, victim, modifier_death, {duration=kill_grace_duration})
        end

        local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(dagon_particle, 1, victim, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
        ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	
        victim:EmitSound("DOTA_Item.Dagon5.Target")
        
        ApplyDamage({victim = victim, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end


function TargetOnDeath(keys)	
	--Search for an Urn of Shadows in the aura creator's inventory.  If there are multiple Urns in the player's inventory,
	--the one with the least charges receives a charge (this may work differently in the standard Dota 2 mode).
    local urn_with_least_charges = nil
    local ability_item_name = keys.ItemName
	
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			local current_item_name = current_item:GetName()
			
			if current_item_name == ability_item_name then
				if urn_with_least_charges == nil then
					urn_with_least_charges = current_item
				elseif current_item:GetCurrentCharges() < urn_with_least_charges:GetCurrentCharges() then
					urn_with_least_charges = current_item
				end
			end
		end
	end

	if urn_with_least_charges ~= nil then
		if urn_with_least_charges:GetCurrentCharges() == 0 then
			urn_with_least_charges:SetCurrentCharges(1)
		else
			urn_with_least_charges:SetCurrentCharges(urn_with_least_charges:GetCurrentCharges() + 1)
		end
	end
end

