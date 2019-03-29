
modifier_mjz_stifling_dagger_slow = class({})
local modifier_slow = modifier_mjz_stifling_dagger_slow

function modifier_slow:IsHidden()
    return false
end
function modifier_slow:IsPurgable()	-- 能否被驱散
	return true
end
function modifier_slow:IsDebuff()
	return true
end
function modifier_slow:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end

function modifier_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_slow:GetModifierMoveSpeedBonus_Percentage( )
    return self:GetAbility():GetSpecialValueFor('move_slow')
end


modifier_mjz_stifling_dagger_attack = class({})
local modifier_attack = modifier_mjz_stifling_dagger_attack

function modifier_attack:IsHidden()
    return true
end
function modifier_attack:IsPurgable()	-- 能否被驱散
	return false
end
function modifier_attack:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true   -- When attacking uphill, cannot miss units but can still miss buildings.
	}
end
function modifier_attack:DeclareFunctions()
	local funcs = {
        -- MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end
-- function modifier_attack:GetModifierBaseAttack_BonusDamage( )
--     return self:GetAbility():GetSpecialValueFor('base_damage')    
-- end
function modifier_attack:GetModifierDamageOutgoing_Percentage( )
    return self:GetAbility():GetSpecialValueFor('attack_factor')    
end
