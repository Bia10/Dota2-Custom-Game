

function OnToggleOn( keys )
    local caster = keys.caster
    local ability = keys.ability
    local modifierName = keys.ModifierName
    if caster:IsRangedAttacker() then       -- 单位的攻击类型是否是远程攻击
        ability:ApplyDataDrivenModifier(caster, caster, modifierName, {})
    end
end


--[[Author: Pizzalol
	Date: 04.03.2015.
	Creates additional attack projectiles for units within the specified radius around the caster]]
function SplitShotLaunch( keys )
    local caster = keys.caster
    local caster_location = caster:GetAbsOrigin()
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    if not caster:IsRangedAttacker() then
        return
    end

    -- Targeting variables
    local target_type = ability:GetAbilityTargetType()
    local target_team = ability:GetAbilityTargetTeam()
    local target_flags = ability:GetAbilityTargetFlags()
    local attack_target = caster:GetAttackTarget()

    -- Ability variables
    local radius = ability:GetLevelSpecialValueFor("range", ability_level)
    local max_targets = ability:GetLevelSpecialValueFor("arrow_count", ability_level)
    local projectile_speed = caster:GetProjectileSpeed() -- ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
    local split_shot_projectile = keys.split_shot_projectile

    local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local flagModifierName = ""
    if keys.is_special_attack == "true" then
        flagModifierName = "modifier_item_mjz_split_shot_special_attack_flag"
    else
        flagModifierName = "modifier_item_mjz_split_shot_general_attack_flag"
    end

    -- Create projectiles for units that are not the casters current attack target
    for _,v in pairs(split_shot_targets) do
        if v ~= attack_target then
            local projectile_info = 
            {
                EffectName = split_shot_projectile,
                Ability = ability,
                vSpawnOrigin = caster_location,
                Target = v,
                Source = caster,
                bHasFrontalCone = false,
                iMoveSpeed = projectile_speed,
                bReplaceExisting = false,
                bProvidesVision = false
            }
            ProjectileManager:CreateTrackingProjectile(projectile_info)
            max_targets = max_targets - 1

            -- 添加标记，防止循环触发 
            -- v:AddNewModifier(caster, ability, flagModifierName, {duration=10})
            ability:ApplyDataDrivenModifier(caster, v, flagModifierName, {})
        
        end
        -- If we reached the maximum amount of targets then break the loop
        if max_targets == 0 then break end
    end
end

-- Apply the auto attack damage to the hit unit
function SplitShotDamage( keys )
    local caster = keys.caster
    local target = keys.target

    -- 防止循环触发 OnProjectileHitUnit
    -- 查看是否有标记，有就消耗掉这次攻击
    local generalModifierName = "modifier_item_mjz_split_shot_general_attack_flag"
    local specialModifierName = "modifier_item_mjz_split_shot_special_attack_flag"
    
    if target:FindModifierByName(generalModifierName) then
        target:RemoveModifierByName(generalModifierName)
        SplitShotDamage_General(keys)

    elseif target:FindModifierByName(specialModifierName) then
        target:RemoveModifierByName(specialModifierName)
        SplitShotDamage_Special(keys)
    
    end

end

--  攻击目标（不能触发攻击特效）
function SplitShotDamage_General( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local damage = caster:GetAverageTrueAttackDamage(target)    --caster:GetAttackDamage()

    local damage_table = {
        attacker = caster,
        victim = target,
        damage_type = ability:GetAbilityDamageType(),
        damage = damage
    }

    ApplyDamage(damage_table)
end

--  TODO: 实现功能
--  攻击目标（能触发攻击特效）
function SplitShotDamage_Special( keys )
    local BaseNPC = EntIndexToHScript(keys.caster_entindex)   --物品携带者
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability


    local attacker = BaseNPC

    -- local attacksPerSecond = attacker:GetAttacksPerSecond()
	-- local attackSpeed = ( 1 / attacksPerSecond )
	-- local attackAnimationPoint = attacker:GetAttackAnimationPoint()
    -- ability:StartCooldown(attackSpeed)
    
    attacker:PerformAttack (
        target,     -- handle hTarget 
        true,       -- bool bUseCastAttackOrb, 
        true,       -- bool bProcessProcs,
        true,       -- bool bSkipCooldown
        false,      -- bool bIgnoreInvis
        false,      -- bool bUseProjectile
        false,      -- bool bFakeAttack
        false       -- bool bNeverMiss
    )

end