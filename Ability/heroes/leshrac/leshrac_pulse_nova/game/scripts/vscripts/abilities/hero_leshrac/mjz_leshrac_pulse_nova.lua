
function pulse_nova_take_mana( params )
	local caster = params.caster
	local ability = params.ability
	
    if ability:GetToggleState() == false then
        return
    end

	local mana_per_sec = ability:GetLevelSpecialValueFor("mana_cost_per_second", ability:GetLevel() - 1)
	caster:ReduceMana(mana_per_sec)
	
    if caster:GetMana() < mana_per_sec then
        ability:ToggleAbility()
    end
end

function pulse_nova_damage( params )
	local caster = params.caster
	local ability = params.ability
	local target = params.target
	
    if ability:GetToggleState() == false then
        return
    end

	-- local ability_level = ability:GetLevel() - 1
	-- local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	-- local damage_scepter = ability:GetLevelSpecialValueFor("damage_scepter", ability_level)
	local damage_normal = GetTalentSpecialValueFor(ability, "damage")
	local damage_scepter = GetTalentSpecialValueFor(ability, "damage_scepter")
	local damage_intelligence_per = GetTalentSpecialValueFor(ability, "damage_intelligence_per")

	local damage_amount = damage_normal
    if caster:HasScepter() then
		damage_amount = damage_scepter
	end
	
	local damage_intelligence = caster:GetIntellect() * (damage_intelligence_per / 100)
	damage_amount = damage_amount + damage_intelligence

	local dmg_table_target = {
		victim = target,
		attacker = caster,
		damage = damage_amount,
        damage_type = ability:GetAbilityDamageType(),
        -- damage_flags = ability:GetAbilityTargetFlags(), 
	    ability = ability,
	}
	ApplyDamage(dmg_table_target)

end

function pulse_nova_stop( keys )
    local caster = keys.caster
    local sound = "Hero_Leshrac.Pulse_Nova"

    StopSoundEvent(sound, caster)
end

------------------------------------------------------------------------------

-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
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

