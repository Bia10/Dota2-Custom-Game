if modifier_mjz_templar_assassin_proficiency_debuff == nil then
	modifier_mjz_templar_assassin_proficiency_debuff = class ({})
end

local modifier_class = modifier_mjz_templar_assassin_proficiency_debuff

function modifier_class:IsHidden()
    return false
end

function modifier_class:GetTexture()
	return "modifiers/mjz_templar_assassin_proficiency_debuff"
end

function modifier_class:IsDebuff()
	return true
end

function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end	

function modifier_class:OnRefresh(kv)		-- 当执行 ForceRefresh() 时，触发此事件
	self:_Init(kv)
end

function modifier_class:OnCreated( kv )
	-- if not IsServer() then return end

	self:_Init(kv)
	
	if IsInToolsMode() and true then
		print("modifier_mjz_templar_assassin_proficiency_debuff : OnCreated")
		for k,v in pairs(kv) do
			print("    ",k,v)
		end

		print("    ", "armor_bonus", self.armor_bonus)
	end
		
end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		-- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS_UNIQUE_ACTIVE
	}
	return funcs
end

function modifier_class:GetModifierPhysicalArmorBonus(kv)
	-- if not self:GetParent():IsBuilding() then return end
	return self.armor_bonus
end

function modifier_class:GetModifierPhysicalArmorBonusUniqueActive( )
	return self.armor_bonus
end

function modifier_class:_Init( kv )
	-- local caster = self:GetCaster()
	local ability = self:GetAbility()
	if ability then
		self.armor_reduction_percent = ability:GetSpecialValueFor("armor_reduction_percent")			
	else
		self.armor_reduction_percent = 1
	end

	local unit = self:GetParent()
	local bonus = unit:GetPhysicalArmorValue() * self.armor_reduction_percent / 100
	if math.abs( bonus ) < 1 then bonus = 1 end
	self.armor_bonus = bonus * -1

end