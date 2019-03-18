
function OnSpellStart( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability
	
	local unit = caster
	local modifier_health_name = 'modifier_mjz_terrorblade_metamorphosis_relieve_health'

	local modifier_metamorphosis = unit:FindModifierByName('modifier_terrorblade_metamorphosis')
	local modifier_metamorphosis_transform_aura = unit:FindModifierByName('modifier_terrorblade_metamorphosis_transform_aura')

	if modifier_metamorphosis and modifier_metamorphosis_transform_aura then
		modifier_metamorphosis:SetDuration(0.1, false)
		modifier_metamorphosis_transform_aura:SetDuration(0.1, false)

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
	local modifier_health_name = 'modifier_mjz_terrorblade_metamorphosis_relieve_health'

	local modifier_metamorphosis = unit:FindModifierByName('modifier_terrorblade_metamorphosis')
	local modifier_metamorphosis_transform_aura = unit:FindModifierByName('modifier_terrorblade_metamorphosis_transform_aura')

	if unit:HasScepter() and modifier_metamorphosis and modifier_metamorphosis_transform_aura then
		modifier_metamorphosis:SetDuration(40.0, false)
		modifier_metamorphosis_transform_aura:SetDuration(40.0, false)

		if not unit:HasModifier(modifier_health_name) then
			unit:AddNewModifier(unit, ability, modifier_health_name, {})
			-- ability:ApplyDataDrivenModifier(ability, unit, modifier_health_name, {})
		end
	else
		unit:RemoveModifierByName(modifier_health_name)	
	end
end


LinkLuaModifier("modifier_mjz_terrorblade_metamorphosis_relieve_health", "abilities/hero_terrorblade/mjz_terrorblade_metamorphosis_relieve.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_terrorblade_metamorphosis_relieve_health = class({})
function modifier_mjz_terrorblade_metamorphosis_relieve_health:IsHidden()
    return true
end
function modifier_mjz_terrorblade_metamorphosis_relieve_health:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
    return funcs
end
function modifier_mjz_terrorblade_metamorphosis_relieve_health:GetModifierHealthRegenPercentage( params )
	return -1.0
end


