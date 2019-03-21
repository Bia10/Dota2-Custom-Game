
function OnSpellStart( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability
	
	local unit = caster
	local modifier_health_name = 'modifier_mjz_lycan_shapeshift_relieve_health'

	local modifier_shapeshift = unit:FindModifierByName('modifier_lycan_shapeshift')
	local modifier_shapeshift_aura = unit:FindModifierByName('modifier_lycan_shapeshift_aura')
	local modifier_shapeshift_speed = unit:FindModifierByName('modifier_lycan_shapeshift_speed')

	if  modifier_shapeshift then
		modifier_shapeshift:SetDuration(0.1, false)
		if modifier_shapeshift_aura then
			modifier_shapeshift_aura:SetDuration(0.1, false)
		end

		if unit:HasModifier(modifier_health_name) then
			unit:RemoveModifierByName(modifier_health_name)	
		end
	end
end

function OnCreated( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability

end

function OnIntervalThink( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability
	
	local unit = caster
	local modifier_health_name = 'modifier_mjz_lycan_shapeshift_relieve_health'

	local modifier_shapeshift = unit:FindModifierByName('modifier_lycan_shapeshift')
	local modifier_shapeshift_aura = unit:FindModifierByName('modifier_lycan_shapeshift_aura')
	local modifier_shapeshift_speed = unit:FindModifierByName('modifier_lycan_shapeshift_speed')

	if unit:HasScepter() and modifier_shapeshift then
		modifier_shapeshift:SetDuration(20.0, false)
		if modifier_shapeshift_aura then
			modifier_shapeshift_aura:SetDuration(20.0, false)
		end

		if not unit:HasModifier(modifier_health_name) then
			unit:AddNewModifier(unit, ability, modifier_health_name, {})
			-- ability:ApplyDataDrivenModifier(ability, unit, modifier_health_name, {})
		end
	else
		unit:RemoveModifierByName(modifier_health_name)	
	end
end

--------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_lycan_shapeshift_relieve_health", "abilities/hero_lycan/mjz_lycan_shapeshift_relieve.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_lycan_shapeshift_relieve_health = class({})
function modifier_mjz_lycan_shapeshift_relieve_health:IsHidden()
    return true
end
function modifier_mjz_lycan_shapeshift_relieve_health:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
    return funcs
end
function modifier_mjz_lycan_shapeshift_relieve_health:GetModifierHealthRegenPercentage( params )
	return -1.0
end


