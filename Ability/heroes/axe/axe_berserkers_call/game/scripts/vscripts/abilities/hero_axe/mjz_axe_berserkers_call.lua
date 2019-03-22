
-- Forces the target to attack the caster 
function BerserkersCall( keys )
	local caster = keys.caster
	local target = keys.target

	-- Clear the force attack target
	target:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	if caster:IsAlive() then
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else
		target:Stop()
	end

	-- Set the force attack target to be the caster
	target:SetForceAttackTarget(caster)
end

-- Clears the force attack target upon expiration
function BerserkersCallEnd( keys )
	local target = keys.target

	target:SetForceAttackTarget(nil)
end


function FindEnemy( keys )
	if not IsServer() then return nil end

	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local ModifierName = keys.ModifierName

	local duration = ability:GetLevelSpecialValueFor('duration', ability_level)
	local radius = GetTalentSpecialValueFor(ability, 'radius')

	local enemy_list = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)

	for _,enemy in pairs(enemy_list) do
		ability:ApplyDataDrivenModifier(caster, enemy, ModifierName, {duration = duration})
	end

end


function OnArmorModifierCreated( keys )
	ArmorBonus(keys)
	AttachEffect(keys)
end

function ArmorBonus( keys )
	if not IsServer() then return nil end

	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local ModifierName = 'modifier_mjz_axe_berserkers_call_armor_bonus'
	local duration = ability:GetLevelSpecialValueFor('duration', ability_level)

	-- ability:ApplyDataDrivenModifier(caster, caster, ModifierName, {duration = duration})
	caster:AddNewModifier(caster, ability, ModifierName, {duration = duration})
end

function AttachEffect( keys )
	if not IsServer() then return nil end

	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- local radius = ability:GetLevelSpecialValueFor('radius', ability_level)
	local radius = GetTalentSpecialValueFor(ability, 'radius')

	local EffectName = "particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf"
	local p = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(p, 2, Vector(radius, 1, 1))
end

-----------------------------------------------------------------------------

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 忽视建筑物、支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end


-- 是否学习指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
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



--------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_axe_berserkers_call_armor_bonus", "abilities/hero_axe/mjz_axe_berserkers_call.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_axe_berserkers_call_armor_bonus = class({})
local modifier_class = modifier_mjz_axe_berserkers_call_armor_bonus

function modifier_class:IsHidden()
    return true
end

function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end

function modifier_class:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS		
    }
    return funcs
end

function modifier_class:GetModifierPhysicalArmorBonus( params )
	return self.bonus_armor
end

function modifier_class:OnCreated( kv )
	local unit = self:GetParent()
	local ability = self:GetAbility()

	local bonus_armor_base = ability:GetSpecialValueFor( "bonus_armor")
	local bonus_armor_per = ability:GetSpecialValueFor( "bonus_armor_per")

	local current_armor = unit:GetPhysicalArmorValue()
	
	self.bonus_armor = bonus_armor_base + current_armor * (bonus_armor_per / 100)
end


