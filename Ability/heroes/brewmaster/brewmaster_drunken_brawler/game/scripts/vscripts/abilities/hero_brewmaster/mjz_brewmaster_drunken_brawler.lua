
mjz_brewmaster_drunken_brawler = class({})

if IsServer() then
	local ability_class = mjz_brewmaster_drunken_brawler

	function ability_class:GetIntrinsicModifierName()
		return "modifier_mjz_brewmaster_drunken_brawler"
	end

	function ability_class:OnSpellStart( )
		local caster = self:GetCaster()
		local ability = self
		local duration = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1  ) 
		local dodge_chance = ability:GetLevelSpecialValueFor( "dodge_chance" , ability:GetLevel() - 1  )

		local modifier_name = "modifier_mjz_brewmaster_drunken_brawler_active"
		caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
	end
end

----------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_brewmaster_drunken_brawler", "abilities/hero_brewmaster/mjz_brewmaster_drunken_brawler.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_brewmaster_drunken_brawler = class ({})
local modifier_class = modifier_mjz_brewmaster_drunken_brawler

function modifier_class:IsHidden()
    return true
end
function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end
function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,	-- 暴击伤害
		MODIFIER_PROPERTY_EVASION_CONSTANT,			-- 闪避
		MODIFIER_EVENT_ON_ATTACK_START,			-- 当拥有modifier的单位开始攻击某个目标
		MODIFIER_EVENT_ON_ATTACK_LANDED,		-- 当拥有modifier的单位攻击到某个目标时
	}
	return funcs
end

function modifier_class:GetModifierEvasion_Constant(kv)
	return self.evasion_constant
end
function modifier_class:GetModifierPreAttack_CriticalStrike(kv)
	return self.crit_strike
end

function modifier_class:OnAttackStart( keys )
	local caster = self:GetParent()
	local unit = self:GetParent()
	local ability = self:GetAbility()

	self.crit = false
	self.crit_strike = 0

	if RandomInt(1, 100) <= self.crit_chance then
		self.crit = true
	end

	if ability and self.crit then
		unit:EmitSound("Hero_Brewmaster.Brawler.Crit")	-- EmitSoundOn("Hero_Brewmaster.Brawler.Crit", unit)	

		if ability._active then
			self.crit_strike = ability:GetSpecialValueFor("crit_multiplier_active")						
		else
			self.crit_strike = ability:GetSpecialValueFor("crit_multiplier")						
		end
	end
end
function modifier_class:OnAttackLanded(keys)
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local attacker = keys.attacker

	if attacker == self:GetParent() then
		local target = keys.target

		if self.crit then
			local crit_effect_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunken_brawler_crit.vpcf"
			local crit_effect = ParticleManager:CreateParticle(crit_effect_name, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:ReleaseParticleIndex(crit_effect)
		end
	end
end

function modifier_class:OnRefresh(kv)		-- 当执行 ForceRefresh() 时，触发此事件
	self:_Init(kv)
end

function modifier_class:OnCreated( kv )
	self:_Init()
end

function modifier_class:_Init( )
	local unit = self:GetParent()
	local ability = self:GetAbility()

	if ability then
		if ability._active then
			self.evasion_constant = ability:GetSpecialValueFor("dodge_chance_active")			
			self.crit_chance = ability:GetSpecialValueFor("crit_chance_active")
		else
			self.evasion_constant = ability:GetSpecialValueFor("dodge_chance")			
			self.crit_chance = ability:GetSpecialValueFor("crit_chance")	
		end
	else
		self.evasion_constant = 0
		self.crit_chance = 0
	end
end

-----------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_brewmaster_drunken_brawler_active", "abilities/hero_brewmaster/mjz_brewmaster_drunken_brawler.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_brewmaster_drunken_brawler_active = class ({})
local modifier_active = modifier_mjz_brewmaster_drunken_brawler_active

function modifier_active:IsHidden()
    return false
end
function modifier_active:OnCreated( kv )
	local unit = self:GetParent()
	local caster = unit
	local ability = self:GetAbility()

	ability._active = true

	if IsServer() then
		local modifier = unit:FindModifierByName('modifier_mjz_brewmaster_drunken_brawler')
		if modifier then
			modifier:ForceRefresh()
		end
		
		local effect_evade_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunkenbrawler_evade.vpcf"
		self.effect_evade = ParticleManager:CreateParticle(effect_evade_name, PATTACH_ABSORIGIN_FOLLOW, caster)
				
		local effect_crit_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunkenbrawler_crit.vpcf"
		self.effect_crit = ParticleManager:CreateParticle(effect_crit_name, PATTACH_ABSORIGIN_FOLLOW, caster)	

	end
end
function modifier_active:OnDestroy( kv )
	local unit = self:GetParent()
	local caster = unit
	local ability = self:GetAbility()

	ability._active = false

	if IsServer() then
		local modifier = unit:FindModifierByName('modifier_mjz_brewmaster_drunken_brawler')
		if modifier then
			modifier:ForceRefresh()
		end
		
		ParticleManager:DestroyParticle(self.effect_evade, true)
		ParticleManager:DestroyParticle(self.effect_crit, true)
		ParticleManager:ReleaseParticleIndex(self.effect_evade)
		ParticleManager:ReleaseParticleIndex(self.effect_crit)
	end
end

