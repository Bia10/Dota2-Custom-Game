LinkLuaModifier("modifier_mjz_stifling_dagger_slow", "modifiers/hero_phantom_assassin/modifier_mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_stifling_dagger_attack", "modifiers/hero_phantom_assassin/modifier_mjz_phantom_assassin_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE)


function OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_count =  GetTalentSpecialValueFor(ability, "target_count")
	local effect_name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf"
	local dagger_speed = ability:GetSpecialValueFor('dagger_speed')

	local projectile_info = 
	{
		Target = unit,
		Source = caster,
		Ability = ability,	
		EffectName = effect_name,
			iMoveSpeed = dagger_speed,
		vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
		bDrawsOnMinimap = false,                          -- Optional
			bDodgeable = true,                                -- Optional
			bIsAttack = false,                                -- Optional
			bVisibleToEnemies = true,                         -- Optional
			bReplaceExisting = false,                         -- Optional
			flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 400,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}

	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")

	local count = 0
	local units = GetTargets(caster, ability, target)
	for _,unit in pairs(units) do
		if count < target_count then
			count = count + 1

			projectile_info.Target = unit
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end

end

function OnProjectileHitUnit( keys )

	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local base_damage = GetTalentSpecialValueFor(ability, "base_damage")
	local slow_duration = GetTalentSpecialValueFor(ability, 'duration')
	local modifier_slow = 'modifier_mjz_stifling_dagger_slow'
	local modifier_attack = 'modifier_mjz_stifling_dagger_attack'

	if target:GetTeam() ~= caster:GetTeam() and target:TriggerSpellAbsorb(ability) then
		return
	end

	ApplyDamage({
		victim = target, 
		attacker = caster, 
		ability = ability, 
		damage = base_damage, 
		damage_type = ability:GetAbilityDamageType()
	})

	caster:AddNewModifier(caster, ability, modifier_attack, {duration = 0.1})
	-- caster:AttackReady()
	-- print('PerformAttack ....')
	caster:PerformAttack (
        target,     -- handle hTarget 
        true,       -- bool bUseCastAttackOrb, 
        true,       -- bool bProcessProcs,
        true,       -- bool bSkipCooldown
        false,      -- bool bIgnoreInvis
        false,       -- bool bUseProjectile
        false,      -- bool bFakeAttack
        true        -- bool bNeverMiss  可敌先机
	)
	-- print('PerformAttack done.')
	caster:RemoveModifierByName(modifier_attack)

	target:AddNewModifier(caster, ability, modifier_slow, {duration = slow_duration})
end

function GetTargets( caster, ability, target )
	local radius = GetTalentSpecialValueFor(ability, "radius")
	return FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 
		radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 
		ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
end


function RandomFromTable(table, count)
	return table[RandomInt(1, #table)]
end


-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 仅针对可见的单位、忽视建筑物、支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end
