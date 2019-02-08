
function OnAbilityPhaseStart( keys )
    local caster = EntIndexToHScript(keys.caster_entindex)   --物品携带者

    EmitSoundOn("Hero_MonkeyKing.Strike.Cast", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_bot", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_top", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
end

function OnSpellStart( keys )
    local caster = EntIndexToHScript(keys.caster_entindex)   --物品携带者
    local ability = keys.ability
    local abilityLevel = ability:GetLevel() -1


	
	local ability_range = ability:GetLevelSpecialValueFor("strike_cast_range", abilityLevel)
	local ability_radius = ability:GetLevelSpecialValueFor("strike_radius", abilityLevel)
	local ability_duration = 1 --ability:GetLevelSpecialValueFor("ability_duration", abilityLevel)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", abilityLevel)
	local crit_mult = ability:GetLevelSpecialValueFor("strike_crit_mult", abilityLevel)
	local width = ability_radius --ability:GetLevelSpecialValueFor("width", abilityLevel)
	local offset =  0 --ability:GetLevelSpecialValueFor("offset", abilityLevel)
    
    
    -- Position and direction variables
	local direction = caster:GetForwardVector()
	local startPos = caster:GetAbsOrigin() + direction * offset
    local endPos = caster:GetAbsOrigin() + direction * ability_range
    
    EmitSoundOnLocationWithCaster(startPos, "Hero_MonkeyKing.Strike.Impact", caster)
	EmitSoundOnLocationWithCaster(endPos, "Hero_MonkeyKing.Strike.Impact.EndPos", caster)

    -- Renders the fissure particle in a line
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, startPos)
	ParticleManager:SetParticleControl(particle, 1, endPos)
	ParticleManager:SetParticleControl(particle, 2, Vector(ability_duration, 0, 0 ))

    -- Units to be moved by the fissure
	local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, width, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
    
    local moved = keys.moved            --金箍棒是否能弹开其他单位
    if moved == "true" then
        -- Loops through targets
        for i,unit in ipairs(units) do
            -- Does not move the caster
            if unit ~= caster then
                -- The target's distance and direction from the front of the fissure
                local target_vector_distance = unit:GetAbsOrigin() - startPos
                local target_distance = (target_vector_distance):Length2D()
                local target_direction = (target_vector_distance):Normalized()
            
                -- Get the target's angle in relation to the front of the fissure
                local target_angle_radian = math.atan2(target_direction.y, target_direction.x)
                
                -- Gets the direction of the fissure in the world
                local fissure_angle_radian = math.atan2(direction.y, direction.x)
            
                -- Gets the distance from the front of the fissure to the point on the fissure perpendicular to the target
                local perpen_distance = math.abs(math.cos(fissure_angle_radian - target_angle_radian)) * target_distance
                
                -- Gets the position of the the perpendicular point
                local perpen_position = startPos + perpen_distance * direction
            
                -- Gets the distance and direction the target will move
                local motion_vector_distance = unit:GetAbsOrigin() - perpen_position
                local motion_distance = width
                local motion_direction = (motion_vector_distance):Normalized()
            
                -- Moves the target
                unit:SetAbsOrigin(unit:GetAbsOrigin() + motion_distance * motion_direction)
            end
        end
    end
    
    -- Units to be stunned and damaged by the fissure
	units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, ability_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
    
    -- crit damage
    -- GetAttackDamage              获得基础攻击力（不含绿字）
    -- GetAverageTrueAttackDamage   获得绿字的攻击力
    local attackDamage = caster:GetAttackDamage() + caster:GetAverageTrueAttackDamage(caster)
    local damage = attackDamage * crit_mult / 100

    local debuff_name = keys.debuff_name
    local debuff_duration = keys.debuff_duration

	-- Loops through the targets
	for j,unit in ipairs(units) do
		-- Applies the stun modifier to the target
        unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
        
        -- debuff
        ability:ApplyDataDrivenModifier(caster, unit, debuff_name, {Duration = debuff_duration})
        
        -- Applies the damage to the target        
		ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
    end
    
	ability.startPos = startPos
	ability.endPos = endPos
    ability.direction = direction
    
end


